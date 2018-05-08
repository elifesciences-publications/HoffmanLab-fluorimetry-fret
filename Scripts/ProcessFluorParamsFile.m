% This script adds relevant folder containing the images to be analyzed and
% reads in experimental parameters from the Exp_Params text file.

addpath(folder)
params_file = file_search('Fluor_Param\w+.txt',folder);
p = fileread(params_file{1});
eval(p);
clear p params_file