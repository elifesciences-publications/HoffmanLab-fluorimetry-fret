%% Header
% Script designed to truncate, smooth, and normalize data if the user
% desires


%% Manipulate data
if strcmpi(exp_type,'FRET')
    if strcmpi(trunc,'y')
        dat_D = dat_D(trunc_D1+1:end,:);
        dat_D = dat_D(1:end-trunc_D2,:);
        dat_A = dat_A(trunc_A1+1:end,:);
        dat_A = dat_A(1:end-trunc_A2,:);
        prefix = ['trunc_' prefix];
    end
    if strcmpi(smth,'y')
        for i = 1:n_exp
            dat_D(:,i+1) = smooth(dat_D(:,i+1),smth_D);
            dat_A(:,i+1) = smooth(dat_A(:,i+1),smth_a);
        end
        prefix = ['smth_' prefix];
    end
    if strcmpi(nrm,'y')
        error('You really shouldnt normalize FRET data');
    end
elseif strcmpi(exp_type,'Spectra')
    if strcmpi(trunc,'y')
        for i = 1:n_exp
            start_row = find(dat(:,i+1)~=0);
            end_row = start_row(end);
            start_row = start_row(1);
            dat(start_row-1:start_row+trunc1-1,i+1) = 0;
            dat(end_row-trunc2+1:end_row+1,i+1) = 0;
        end
        clear start_row end_row
        prefix = ['trunc_' prefix];
    end
    if strcmpi(smth,'y')
        for i = 1:n_exp
            dat(:,i+1) = smooth(dat(:,i+1),smth1);
        end
        prefix = ['smth_' prefix];
    end
    if strcmpi(nrm,'y')
        for i = 1:n_exp
            dat(:,i+1) = dat(:,i+1)./max(dat(:,i+1));
        end
        prefix = ['norm_' prefix];
    end
else
    error('Choose a valid experiment type')
end

%% Save data
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