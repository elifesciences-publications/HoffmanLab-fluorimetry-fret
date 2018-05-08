function [folder,params_file] = GetFluorParamsFile(varargin)

% This script obtains the relevant folder containing the images to be
% analyzed.

if (not(isempty(varargin)))
    folder = varargin{1};
else
    folder = input('Type the full path of the folder that contains your fluorimetry data: ','s');
end

params_file = file_search('Fluor_Param\w+.txt',folder);