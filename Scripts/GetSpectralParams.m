%% Header
% Compiles parameters pertinent to spectral FRET experiments

%% Extract information about donor and acceptor from FPs.xls
FPinfo = importdata('FPs.xls');
ECcol = 4; % Column containing extinction coefficient data
PEAKcol = 2; % Column containing peak emission wavelength data
[drow,~] = find(cellfun(@(x,y) isequal(x,donor),FPinfo.textdata));
dEC = FPinfo.data(drow-1,ECcol);
dPeak_lit = FPinfo.data(drow-1,PEAKcol);
[arow,~] = find(cellfun(@(x,y) isequal(x,acceptor),FPinfo.textdata));
aEC = FPinfo.data(arow-1,ECcol);
aPeak_lit = FPinfo.data(arow-1,PEAKcol);

%% Extract spectral information
%%%% Absorbance Spectra %%%%
ABSspectra = importdata(abs_spectra_file);
% Donor
[~,dcol] = find(cellfun(@(x,y) isequal(x,donor),ABSspectra.colheaders));
d_abs_spectra = [ABSspectra.data(:,1),ABSspectra.data(:,dcol)];
p1 = interp1(d_abs_spectra(:,1),d_abs_spectra(:,2),lambda_donor);
p1 = p1*dEC;
% Acceptor
[~,acol] = find(cellfun(@(x,y) isequal(x,acceptor),ABSspectra.colheaders));
a_abs_spectra = [ABSspectra.data(:,1),ABSspectra.data(:,acol)];
p2 = interp1(a_abs_spectra(:,1),a_abs_spectra(:,2),lambda_donor);
p2 = p2*aEC;
p3 = interp1(a_abs_spectra(:,1),a_abs_spectra(:,2),lambda_acceptor);
p3 = p3*aEC;
clear dcol acol

%%%% Emission Spectra %%%%
EMspectra = importdata(em_spectra_file);
% Donor
[~,dcol] = find(cellfun(@(x,y) isequal(x,donor),EMspectra.colheaders));
d_em_spectra = [EMspectra.data(:,1),EMspectra.data(:,dcol)];
dPeak = find(d_em_spectra(:,2) == max(d_em_spectra(:,2)));
dPeak = d_em_spectra(dPeak,1);
% Acceptor
[~,acol] = find(cellfun(@(x,y) isequal(x,acceptor),EMspectra.colheaders));
a_em_spectra = [EMspectra.data(:,1),EMspectra.data(:,acol)];
aPeak = find(a_em_spectra(:,2) == max(a_em_spectra(:,2)));
aPeak = a_em_spectra(aPeak,1);

%% Compile spectral parameters into params structure
params.lambda1 = dPeak - 5;
params.lambda2 = dPeak + 5;
params.acceptor_peak = aPeak;
params.p1 = p1;
params.p2 = p2;
params.p3 = p3;
params.bdd = d_em_spectra;
params.baa = a_em_spectra;
params.ylim = ylim;
%%%%% still need lambda_start for acceptor spectra -> min(acceptor read)
save(fullfile(folder,['SpectralParams_' donor '_' acceptor '.mat']),'params');
%% Clean up
clear dPeak aPeak p1 p2 p3 d_em_spectra a_em_spectra dcol acol EMspectra ABSspectra PEAKcol ECcol dEC aEC arow dPeak_lit aPeak_lit