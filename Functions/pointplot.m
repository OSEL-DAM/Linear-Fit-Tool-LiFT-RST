function pointplot(varargin)
% This function is to plot essential points of the test data.

% Inputs:
%   Varargin 1 <struct> - the fit line properties (e.g., FLine)
%   Varargin 2 <val> - a 1 by 2 matrix for determining the distance between
%                      the essential points so that the annotation could be
%                      placed in the correct places (e.g., [max(x),max(y)])
%   
%   Varargin 3 to 5 <string> - the name of the essential points (e.g.,
%   OffsetPoint, TangentPoint, and YieldPoint)

% Examples:
% pointplot(FL,[X(index),max(Y)],'OffsetPoint','TangentPoint','YieldPoint');
% pointplot(FL,[X(index),max(Y)],'OffsetPoint','YieldPoint');
% pointplot(FL,[X(index),max(Y)],'YieldPoint');

% Author: Junfei Tong, Ph.D. and Snehal Shetye, Ph.D.
% Author affiliation: Division of Applied Mechanics, Office of Science and 
% Engineering Laboratories, Center for Devices and Radiological Health,
% U.S. Food and Drug Administration
% Website: 
% May, 2024; Last revision: May 30, 2024


%------------------------BEGIN CODE----------------------------------------
FL = varargin(1);
FL = FL{1,1};
Gap = 0.05*varargin{2};
Names = fieldnames(FL);

for i= 3:length(varargin)
    index = find(contains(Names,varargin{i})==1);
    value = FL.(Names{index});
    if isempty(value)
        continue
    end
    x = value(1);
    y = value(2);
    plot(x,y,'or');
    if i == 3
        text_positionX = x;
    else
        text_positionX = x-2*Gap(1);
    end
    text(text_positionX,y-Gap(2),varargin{i},AffectAutoLimits="on");
end

end
%----------------------------END OF CODE-----------------------------------