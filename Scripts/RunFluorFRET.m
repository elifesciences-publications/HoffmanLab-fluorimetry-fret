%% Header
% Function designed to run spect_E_fxn itteratively on a bunch of columns
% of data from "dat"
outdata = zeros(n_exp,5);
for i = 1:n_exp
    data.FRET = dat_D(:,[1,i+1]);
    data.Iaa = dat_A(:,[1,i+1]);
    output = spect_E(data,FRET_width,params);
    SpectraPlot(output,exp_cols{i},params,folder);
    save(fullfile(folder,['output_' exp_cols{i} '.mat']),'output')
    outdata(i,1) = output.Idd_max;
    outdata(i,2) = output.Iaa_max;
    outdata(i,3) = output.rat;
    outdata(i,4) = output.E;
    outdata(i,5) = outdata(i,4).*100;
end
outdata = num2cell(outdata);
outdata = horzcat(exp_cols',outdata);
headers = {...
    'Sample Name',...
    'Max Donor Intensity (a.u.)',...
    'Max Acceptor Intensity (a.u.)',...
    'mean(ratio)',...
    'mean(FRET Efficiency)',...
    'mean(FRET Efficiency) (%)'};
outdata = vertcat(headers,outdata);
xlswrite(fullfile(folder,'outdata.xlsx'),outdata);