function [FQM1,FQM2,FQM3,FQM4] = FitQuality(Nx,Residual,Coeffcient) 
% This function is to calculate the fit qualitry metrics for the final line
% per ASTM % E3076.

% Inputs:
%   Nx <val> - normalized x array
%   Residual <val> - y residual of the final line
%   Coefficient <val> - the slope of the final line

% Outputs: Fit quality matrix (FQM)
%   FQM1 <val> - 1st quartile relative residual slope
%   FQM2 <val> - Number of points in the 1st quartile
%   FQM3 <val> - 4th quartile relative residual slope
%   FQM4 <val> - Number of points in the 4th quartile

% Author: Junfei Tong, Ph.D. and Snehal Shetye, Ph.D.
% Author affiliation: Division of Applied Mechanics, Office of Science and 
% Engineering Laboratories, Center for Devices and Radiological Health,
% U.S. Food and Drug Administration
% Website: 
% May, 2024; Last revision: May 30, 2024

%------------------------BEGIN CODE----------------------------------------
Nmin_x = min(Nx);
Nmax_x = max(Nx);
range = Nmax_x - Nmin_x; 

%Q1 and Q4 percentile
Q1 = find(Nx <= Nmin_x+0.25*range);
Q4 = find(Nx >= Nmin_x+0.75*range);
Q1_polyfit = polyfit(Nx(Q1),Residual(Q1),1);
Q4_polyfit = polyfit(Nx(Q4),Residual(Q4),1);
FQM1 = Q1_polyfit(1)/(0.05*Coeffcient);  % Relative_Q1_slope
FQM2 = length(Q1); % Q1 Number of points
FQM3 = Q4_polyfit(1)/(0.05*Coeffcient); % Relative_Q4_slope
FQM4 = length(Q4); % Q4 Number of points
end
%----------------------------END OF CODE-----------------------------------