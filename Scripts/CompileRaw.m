%% Header
% Function designed to compile raw PRN files into a single xlsx file
% col1: wavelength (nm)
% col2: sample   1
% col3: sample   2
% col4: sample (n-1)
% .
% .
% .

if strcmpi(suffix,'PRN') || strcmpi(suffix,'TXT')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% FRET EXPERIMENTS %%%%%%      exp_type = 'FRET';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmpi(exp_type,'FRET')
        n_exp = length(exp_cols);
        % READ IN EXPERIMENTAL DATA FILES
        for i = 1:n_exp
            expfile_D = file_search([exp_cols{i} '\w+D.' suffix],folder);
            expfile_A = file_search([exp_cols{i} '\w+A.' suffix],folder);
            [dat_D(:,(2*i-1):(2*i)),~] = importdata(expfile_D{1});
            [dat_A(:,(2*i-1):(2*i)),~] = importdata(expfile_A{1});
            headers_dat(1,(2*i-1):(2*i)) = {'Wavelength (nm)',exp_cols{i}};
        end
        if n_exp > 1
            dat_D(:,3:2:end) = [];
            dat_A(:,3:2:end) = [];
            headers_dat(:,3:2:end) = [];
        end
        
        % DETERMINE # OF BACKGROUND FILES
        n_bkg = length(bkg_cols);
        if n_bkg == n_exp
            % READ IN BACKGROUND DATA FILES
            for i = 1:n_bkg
                bkgfile_D = file_search([bkg_cols{i} '\w+D.' suffix],folder);
                bkgfile_A = file_search([bkg_cols{i} '\w+A.' suffix],folder);
                [bkg_D(:,(2*i-1):(2*i)),~] = importdata(bkgfile_D{1});
                [bkg_A(:,(2*i-1):(2*i)),~] = importdata(bkgfile_A{1});
                headers_bkg(1,(2*i-1):(2*i)) = {'Wavelength (nm)',bkg_cols{i}};
            end
            if n_exp > 1
                bkg_D(:,3:2:end) = [];
                bkg_A(:,3:2:end) = [];
                headers_bkg(:,3:2:end) = [];
            end
            bkg_sub = 'y';
        elseif n_bkg == 1
            % read in single bkg_file
            % allocate bkg_file + n as header_bkg
            bkgfile_D = file_search([bkg_cols{1} '\w+D.' suffix],folder);
            bkgfile_A = file_search([bkg_cols{1} '\w+A.' suffix],folder);
            [bkg_D(:,1:2),~] = importdata(bkgfile_D{1});
            [bkg_A(:,1:2),~] = importdata(bkgfile_A{1});
            headers_bkg(1,1:2) = {'Wavelength',strcat(bkg_cols{1},num2str(1))};
            if n_exp > 1
                bkg_D(:,3:n_exp+1) = repmat(bkg_D(:,2),[1,length(3:n_exp+1)]);
                bkg_A(:,3:n_exp+1) = repmat(bkg_A(:,2),[1,length(3:n_exp+1)]);
                for i = 1:n_exp-1
                    headers_bkg{1,i+2} = strcat(bkg_cols{1},num2str(i+1));
                end
            end
            bkg_sub = 'y';
        elseif n_bkg == 0
            disp('Background files not found and background subtraction will not be performed');
            bkg_sub = 'n';
        end
        
        prefix = 'raw_';
        
        % OUTPUT EXPERIMENTAL AND BACKGROUND DATA
        % output raw_data_D.xlsx and raw_data_A.xlsx with exp_name as column header
        dat_D_out = num2cell(dat_D);
        dat_D_out = vertcat(headers_dat,dat_D_out);
        xlswrite(fullfile(folder,[prefix 'data_D.xlsx']),dat_D_out);
        dat_A_out = num2cell(dat_A);
        dat_A_out = vertcat(headers_dat,dat_A_out);
        xlswrite(fullfile(folder,[prefix 'data_A.xlsx']),dat_A_out);
        % output bkgs_D.xlsx and bkgs_A.xlsx with header_bkg as column header
        bkg_D_out = num2cell(bkg_D);
        bkg_D_out = vertcat(headers_bkg,bkg_D_out);
        xlswrite(fullfile(folder,[prefix 'bkgs_D.xlsx']),bkg_D_out);
        bkg_A_out = num2cell(bkg_A);
        bkg_A_out = vertcat(headers_bkg,bkg_A_out);
        xlswrite(fullfile(folder,[prefix 'bkgs_A.xlsx']),bkg_A_out);
        clear n_bkg expfile_D expfile_A bkgfile_D bkgfile_A i dat_D_out dat_A_out bkg_D_out bkg_A_out
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% MEASURED SPECTRA %%%%%%     exp_type = 'Spectra';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmpi(exp_type,'Spectra')
        n_exp = length(exp_cols);
        % READ IN EXPERIMENTAL DATA FILES
        for i = 1:n_exp
            expfile = file_search([exp_cols{i} '\w+.' suffix],folder);
            [temp,~] = importdata(expfile{1});
            dat(:,(2*i-1):(2*i)) = pad(temp,[200 900]);
            headers_dat(1,(2*i-1):(2*i)) = {'Wavelength (nm)',exp_cols{i}};
            clear temp
        end
        if n_exp > 1
            dat(:,3:2:end) = [];
            headers_dat(:,3:2:end) = [];
        end
        
        % DETERMINE # OF BACKGROUND FILES
        n_bkg = length(bkg_cols);
        if n_bkg == n_exp
            % READ IN BACKGROUND DATA FILES
            for i = 1:n_bkg
                bkgfile = file_search([bkg_cols{i} '\w+.' suffix],folder);
                [temp,~] = importdata(bkgfile{1});
                bkg(:,(2*i-1):(2*i)) = pad(temp,[200 900]);
                headers_bkg(1,(2*i-1):(2*i)) = {'Wavelength (nm)',bkg_cols{i}};
            end
            if n_exp > 1
                bkg(:,3:2:end) = [];
                headers_bkg(:,3:2:end) = [];
            end
            bkg_sub = 'y';
        elseif n_bkg == 0
            disp('Background files not found and background subtraction will not be performed');
            bkg_sub = 'n';
        end
        
        prefix = 'raw_';
        
        % OUTPUT EXPERIMENTAL AND BACKGROUND DATA
        % output raw_data.xlsx with exp_name as column header
        dat_out = num2cell(dat);
        dat_out = vertcat(headers_dat,dat_out);
        xlswrite(fullfile(folder,[prefix 'data.xlsx']),dat_out);
        if strcmpi(bkg_sub,'y')
            % output bkgs.xlsx with header_bkg as column header
            bkg_out = num2cell(bkg);
            bkg_out = vertcat(headers_bkg,bkg_out);
            xlswrite(fullfile(folder,[prefix 'bkgs.xlsx']),bkg_out);
            clear bkgfile bkg_out
        end
        clear n_bkg expfile i dat_out
    else
        error('Choose a valid exp_type')
    end
end