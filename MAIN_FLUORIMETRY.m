function MAIN_FLUORIMETRY(varargin)
%% Function designed to process multiple fluorometric measurements
% simultaneously given an FluorParams.txt file

%% Fluorimetry Parameter Processing
% Check to see if anything has been passed as parameter, if anything has
% been passed, make sure it is a folder.
addpath(genpath(pwd));
if (not(isempty(varargin)))
    if (exist(varargin{1},'dir'))
        folder = varargin{1};
    else
        error('Expected first parameter to be a folder with images to process.');
    end
else
    %% Set up
    clear;
    close all;
    clc;
end

%% Read in Pre-processing parameters

if (exist('folder','var'))
    [~,params_file] = GetFluorParamsFile(folder);
else
    [folder,params_file] = GetFluorParamsFile;
end
ProcessFluorParamsFile;

%% Create destination folders for figures and add everything to path
addpath(genpath(folder));
if ~exist('Figures','dir')
    mkdir(fullfile(folder,'Figures'));
    addpath(genpath(folder));
else
end

%% Compile just the raw text files
CompileRaw

%% Perform background subtraction
if strcmpi(bkg_sub,'y')
    BackgroundSubtration
end

% Perform additional modifications to files depending on inputs including
% (1) truncation
% (2) smoothing
% (3) normalization
if strcmpi(trunc,'y') || strcmpi(smth,'y') || strcmpi(nrm,'y')
    TruncSmoothNorm
end

%% Get parameters pertinent to spectral FRET experiments for your specific FRET-pair
if strcmpi(exp_type,'FRET')
    GetSpectralParams;
end

%% Run FRET analysis
if strcmpi(exp_type,'FRET')
    RunFluorFRET;
end
rmpath(genpath(pwd));