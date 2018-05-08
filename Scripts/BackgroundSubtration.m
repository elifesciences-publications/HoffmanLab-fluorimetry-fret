%% HEADER
% Function designed to perform background subtraction on multiple
% experimental groups

for i = 2:n_exp+1
    if strcmpi(exp_type,'FRET')
        dat_D(:,i) = dat_D(:,i) - bkg_D(:,i);
        dat_A(:,i) = dat_A(:,i) - bkg_A(:,i);
    elseif strcmpi(exp_type,'Spectra')
        dat(:,i) = dat(:,i) - bkg(:,i);
    else
        error('Choose a valid exp_type.');
    end
end

prefix = ['bs_' prefix];

if strcmpi(exp_type,'FRET')
    dat_D_out = num2cell(dat_D);
    dat_D_out = vertcat(headers_dat,dat_D_out);
    xlswrite(fullfile(folder,[prefix 'data_D.xlsx']),dat_D_out);
    dat_A_out = num2cell(dat_A);
    dat_A_out = vertcat(headers_dat,dat_A_out);
    xlswrite(fullfile(folder,[prefix 'data_A.xlsx']),dat_A_out);
elseif strcmpi(exp_type,'Spectra')
    dat_out = num2cell(dat);
    dat_out = vertcat(headers_dat,dat_out);
    xlswrite(fullfile(folder,[prefix 'data.xlsx']),dat_out);
else
    error('Choose a valid exp_type.');
end