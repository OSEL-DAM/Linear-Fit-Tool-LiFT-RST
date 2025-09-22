function SampleName = ValidVarName(SampleName)
% This function is to generate a valid variable name for the Sample name
% which is name of the direct folder where the data is read from.
% Additionally, 'Sample_' prefix will be added to the variable name if
% the original sample name does not have the 'sample'.

% Inputs:
%   SampleName <string> - The name of the direct folder where the data is
%                         read from

% Author: Junfei Tong, Ph.D. and Snehal Shetye, Ph.D.
% Author affiliation: Division of Applied Mechanics, Office of Science and 
% Engineering Laboratories, Center for Devices and Radiological Health,
% U.S. Food and Drug Administration
% Website: 
% July, 2024; Last revision: July 24, 2024

%------------------------BEGIN CODE----------------------------------------
if ~isvarname(SampleName)
    SampleName = strrep(SampleName,'-','_');
    SampleName = strrep(SampleName,'.','_');
end
SampleName = strrep(SampleName,' ','_');
if ~contains(SampleName,'sample','IgnoreCase',true)
    SampleName = strcat('Sample_',SampleName);
end
end
%----------------------------END OF CODE-----------------------------------