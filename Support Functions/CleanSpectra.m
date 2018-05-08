function data = CleanSpectra(file,bkg_file,trunc,smth,norm,folder)
% Background subtracts, truncates, smooths, and normalizes
% emission spectra data from .prn files

% Optional truncation of data is possible (trunc parameter)

%% Load data and background data
[data,~] = importdata(fullfile(folder,file));
[bkg,~] = importdata(fullfile(folder,bkg_file));

% Truncate start of donor and/or acceptor fluorescence files where
% excitation light has bled through
data = data(trunc+1:end-trunc,:);
bkg = bkg(trunc+1:end-trunc,:);

%% Background subtract, smooth, normalize data
lambda = data(:,1);
int1 = data(:,2);
background = bkg(:,2);
int = int1 - background; % Subtract background
if strmpi(smth,'n')
    int_smth = int;
else
    int_smth = smooth(int, smth);% Smooth the data
    data(:,3) = int_smth; % Save smoothed data in column 3
end
if strcmpi(norm,'y')
    mx = max(int_smth);% Find maximum intensity of the smoothed data
    int_smth_norm = int_smth./mx; % Normalize to the maximum intensity
    data(:,4) = int_smth_norm; % Save normalized data as column 4
    data(data<0) = 0; % Get rid of non-real negative values
    save(fullfile(folder,['smth_norm_' file(1:end-4) '.txt']),'-ascii','data')
else
    data(data<0) = 0; % Get rid of non-real negative values
    save(fullfile(folder,['smth_' file(1:end-4) '.txt']),'-ascii','data')
end

end

