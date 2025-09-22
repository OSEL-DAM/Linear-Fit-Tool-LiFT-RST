function [DQM1,DQM2,DQM3,DQM4] = DataQuality(data) %DQM:Data quality matrix 
% This function is to calculate the data qualitry metrics for the final line
% per ASTM % E3076.

% Inputs:
%   data <val> - the data used for calculting the data quality matrix
%                (either x or y)

% Outputs: Fit quality matrix (FQM)
%   DQM1 <val> - Relative Noise level
%   DQM2 <val> - Relative resolution
%   DQM3 <val> - Percentage at this resolution
%   DQM4 <val> - Percentage in zeroth resolution

% Author: Junfei Tong, Ph.D. and Snehal Shetye, Ph.D.
% Author affiliation: Division of Applied Mechanics, Office of Science and 
% Engineering Laboratories, Center for Devices and Radiological Health,
% U.S. Food and Drug Administration
% Website: 
% May, 2024; Last revision: May 30, 2024

%------------------------BEGIN CODE----------------------------------------
% 1st Data quality metric
delta = data(2:end)-data(1:end-1);
delta_r = delta - mean(delta);
DQM1 = std(delta_r)/0.005; %Relative Noise level

%2nd Data quality metric
ddelta = abs(delta(2:end)-delta(1:end-1));
bins = -1/2^13:1/2^12:(500+1)/2^13;
NoP = histcounts(ddelta,bins);
Percent = NoP/length(ddelta)*100;
[DQM3,I] = max(Percent(2:end)); %Percentage at this resolution
DQM4 = Percent(1); %Percentage in zeroth resolution 
DQM2 = I/3; %Relative resolution 
end
%----------------------------END OF CODE-----------------------------------