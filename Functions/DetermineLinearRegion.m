function [FLine,QM] = DetermineLinearRegion(x, y,offset,Percent_of_points)
% This function is to determine the linear region of the test data per ASTM
% E3076.

% Inputs:
%   x <val> - independent variable (displacement, angle, strain)
%   y <val> - depende variable (e.g., force, torque, stress)
%   offset <val> - offset criteria used to determine the yield point
%   Percent_of_points <val> - the percent of points used in the initial 
% search of linear region per ASTM E3076, the default value is 20%.


% Outputs:
%   FLine <struct> - The final line determined through the fitting algorithm
%                    The parameters of the Fline are listed below
%   FLine.Slope <val> - True slope of the final line
%   FLine.Intercept <val> - True intercept of the final line
%   FLine.OffsetPoint <val> - OffsetPoint used as the start of the search
%                             window for the linear fitting
%   FLine.TangentPoint <val> - TangentPoint used as the end of the search
%                              window for the linear fitting
%   FLine.YieldPoint <val> - Yield point for the test data based on the
%                            offset criterion applied.
%   FLine.Max <val> - Maximum value of the test data for both x and y
%   FLine.Rsquare <val> - Coefficient of determination of the linear
%   fit

%   QM <struct> - Quality metrics include both data quality metrics and
%              fit quality metrics
%   The parameters of the QM for data quality metrics are listed below
%   QM.x_Relative_resolution <val> - Relative resolution of x
%   QM.x_Percentage_resolution <val> - Percentage at this resolution in x
%   QM.x_Percentage_zeroth_bin <val> - Percentage in zeroth resolution in x
%   QM.y_Relative_resolution <val> - Relative resolution of y
%   QM.y_Percentage_resolution <val> - Percentage at this resolution in y
%   QM.y_Percentage_zeroth_bin <val> - Percentage in zeroth resolution in y
%   QM.x_Noise <val> - Relative Noise level in x
%   QM.y_Noise <val> - Relative Noise level in y
%   
%   The parameters of the QM for fit quality metrics are listed below
%   QM.FQM_Relative_Q1_Slope <val> - 1st quartile relative residual slope
%   QM.FQM_Q1_NoP <val> - Number of points in the 1st quartile
%   QM.FQM_Relative_Q4_Slope <val> - 4th quartile relative residual slope
%   QM.FQM_Q4_NoP <val> - Number of points in the 4th quartile
%   QM.FQM_Relative_Fit_Range <val> - Relative fit range


% Other m-files required: DataQuality.m and FitQuality.m


% Author: Junfei Tong, Ph.D. and Snehal Shetye, Ph.D.
% Author affiliation: Division of Applied Mechanics, Office of Science and 
% Engineering Laboratories, Center for Devices and Radiological Health,
% U.S. Food and Drug Administration
% Website: 
% July, 2024; Last revision: July 29, 2024

%------------------------BEGIN CODE----------------------------------------

FLine = struct();
QM = struct();

[FLine.Max(2),Tindex] = max(y);
FLine.Max(1) = x(Tindex);

Shift_x = x(1);
Shift_y = y(1);
x = x - x(1);
y = y - y(1);
[Max_y,Max_index] = max(y);
y(Max_index+1:end) = [];
x(Max_index+1:end) = [];

%% find the offset point and tangent point of the data (curve)
YoffsetPercentage = 0.15;
while 1
    index = find(y>0.05*Max_y,1);
    xoffset = x(index);
    yoffset = y(index)+YoffsetPercentage*Max_y;
    index = find(y>yoffset,1);
    Tangent_slope = (y(index:end)-yoffset)./(x(index:end)-xoffset);
    [~,I] = max(Tangent_slope);
    T_index = index+ I-1;
    Tangent_point = [x(T_index),y(T_index)];
    
    Nx = x(1:T_index)/x(T_index); %Normalized x 
    Ny = y(1:T_index)/y(T_index); %Nomralized y

    % Calculate the data quality metrics for both x and y
    [QM.X_Noise, QM.X_Relative_resolution,QM.X_Percentage_at_this_resolution,QM.X_Percentage_in_zeroth_bin] = DataQuality(Nx);
    [QM.Y_Noise,QM.Y_Relative_resolution,QM.Y_Percentage_at_this_resolution,QM.Y_Percentage_in_zeroth_bin] = DataQuality(Ny);
    temp = struct('X_Relative_resolution',[],'X_Percentage_at_this_resolution',[],'X_Percentage_in_zeroth_bin', [],...
        'Y_Relative_resolution', [],'Y_Percentage_at_this_resolution', [],'Y_Percentage_in_zeroth_bin',...
        [],'X_Noise', [],'Y_Noise',[]);
    QM = orderfields(QM,temp);
    %linear fitting initial search window height
    N = round(Percent_of_points*T_index/100);
    if N<10
        N = 10;
    end

    NormResidual = 1;
    %find the portion of data with least normal residual
    for i = 1:T_index-N+1
        for j = N:T_index-i+1
            xx = Nx(i:i+j-1);
            yy = Ny(i:i+j-1);
            Coef = corrcoef(xx,yy);
            temp = 1- Coef(2,1)^2;
            if temp<NormResidual
                NormResidual = temp;
                F_index = [i, j];
            end
        end
    end
    Range = F_index(1):F_index(1)+F_index(2)-1;
    if Range(end)<T_index
        break;
    end
    YoffsetPercentage = YoffsetPercentage+0.05; %increse the offset percentage by
    % 0.05 when the last point of the fitting line is the tangent point
end


Nx = Nx(Range);
Nx_extend = [ones(length(Range),1) Nx];
Ny = Ny(Range);
b = Nx_extend\Ny;
Intercept = b(1);
Slope = b(2);
Residual = Ny-Nx_extend*b;

FSlope = Slope*Tangent_point(2)/Tangent_point(1);
FIntercept = Intercept*Tangent_point(2);
TrueIntercept = FIntercept - Shift_x*FSlope+Shift_y;

temp = corrcoef(x(Range),y(Range));
Rsquare = temp(2,1)^2;

%% determine the yield point
if offset >0
    for i=Range(end):Max_index
        Distance(i) = (FSlope*(x(i)-offset)-y(i)+FIntercept)/sqrt(FSlope^2+1);
    end
    Index1 = find(Distance<0,1,'last');  %find the last point on the left side of the fitting line
    Index2 = find(Distance>0,1,'first'); %find the frist point on the right side of the fitting line

    if Index2 < length(y)
        c1 = (y(Index2)-y(Index1))/(x(Index2)-x(Index1));
        c0 = y(Index2)-x(Index2)*c1;
        YP(1) = (FSlope*-offset+FIntercept-c0)/(c1-FSlope);
        YP(2) = c1*YP(1)+c0;
    else
        disp('No yield point was found');
        YP = [];
    end
else
    disp("No offset is being applied")
    YP = [];
end

%% Output fit line property (struct)
FLine.Slope = FSlope;
FLine.Intercept = TrueIntercept;
FLine.Rsquare = Rsquare;
FLine.Range = Range;
FLine.OffsetPoint = [xoffset,yoffset]+[Shift_x,Shift_y];
FLine.TangentPoint = Tangent_point+[Shift_x,Shift_y];
if ~isempty(YP)
    FLine.YieldPoint = YP+[Shift_x,Shift_y];
else
    FLine.YieldPoint = [NaN,NaN];
end

%% Calculate the fit quality metrics
[QM.Q1_Relative_Residual_slope,QM.Number_Of_Points_in_Q1,QM.Q4_Relative_Residual_slope,QM.Number_Of_Points_in_Q4] = FitQuality(Nx,Residual,Slope);
QM.Relative_Fit_Range = 0.4/(max(Ny)-min(Ny));
QM.Final_slope = FSlope;
QM.True_Intercept = TrueIntercept;
QM.Lower_yBound = min(Ny)*Tangent_point(2)+Shift_y;
QM.Upper_yBound = max(Ny)*Tangent_point(2)+Shift_y;
QM.Lower_index = Range(1);
QM.Upper_index = Range(end);



end
%----------------------------END OF CODE-----------------------------------