function output = spect_E(data,FRET_width,params)
%% Designed for specifically the Venus-Cherry FRET-pair

%PURPOSE
%A little program to read in spectra from a spectrometer and calculates FRET
%efficiency, based upon the derivation from
%Clegg Meths Enzy 1992 and specfically Eq 11. in Majumadar JMB 2005 (assume
%gamma=1 beta=0)

%INPUTS
%bfd - base for filenames of spectra from FRET construct excited with
%donor wavelength light (text files)
%bfa - base for filenames of spectra from FRET construct excited with
%acceptor wavelength light (text files)
%bkgd - base for filenames of spectra from blank samples excited with
%donor wavelength light (text files)
%bkga - base for filenames of spectra from blank samples excited with
%acceptor wavelength light (text files)
%source_folder - contains text files mentioned above


%INTERNAL INPUTS
%params - a list extinction coefficients necessary for calculation of
%efficiency and boundaries for fitting window
%params(1) - extinction coeff of donor at donor excitation wavelength
%params(2) - extinction coeff of acceptor at donor exitation wavelength
%params(3) - extinction coeff of acceptor at acceptor excitation wavelength

%Notes about determining extinction coeffecients for mClover - mRuby2 set
%       Venus values taken from Day Journal of Biomedical Optics 2008
%       mCherry values taken from http://nic.ucsf.edu/FPvisualization/
%       which cites Shaner NatBiotech 2004
%       e_Venus(peak, 515) = 93,000 1/M/cm
%       e_mCherry(peak, 610) = 72,000 1/M/cm
%       These can be converted to different wavelengths by multiplying by
%       value of normalized extinction spectrum, so:
%       params(1) = e_Venus(480) = ~0.3258 * e_mVenus(peak) = 30,300 1/M/cm
%       params(2) = e_mCherry(480) = ~0.053 * e_mCherry(peak) = 3,816 1/M/cm
%       params(3) = e_mCherry(580) = ~0.941 * e_mCherry(peak) = 67,752 1/M/cm
%       params(3,new) = e_mCherry(560) = ~0.629 * e_mCherry(peak) = 45288 1/M/cm

%Some pertinent notes about the literature
% 1) Evers Biochemestry used the wrong formula that is only good for
% fluorophpores where the donor does not emit in acceptor visualization
% range, as stated in Lakowitz, Flourensence Spetroscopy.

% 2) The frickin' paper everybody cites about this stuff (Clegg, Methods
% Enzymology, 1992) has A FRICKIN' ALGEBRA error in it!!! Subsequent papers
% have the formula corrected or re-derived using the same "formalism".
% Sometimes I can't believe this shit...

%***********************************************START**************************************************************
%% Extract pertienent data from "data" and "params"
% FRET curves
fnfd = data.FRET;
fnfa = data.Iaa;

%Donor-Only and Acceptor-Only Curves
fndd = params.bdd;
fnaa = params.baa;

% Truncate Donor-Only and Acceptor-Only curves to match FRET data
fndd(fndd(:,1)<min(fnfd(:,1)),:) = []; % Exclude bdd data outside input data range
fndd(fndd(:,1)>max(fnfd(:,1)),:) = []; % Exclude bdd data outside input data range
fnaa(fnaa(:,1)<min(fnfa(:,1)),:) = []; % Exclude baa data outside input data range
fnaa(fnaa(:,1)>max(fnfa(:,1)),:) = []; % Exclude baa data outside input data range

%% Normalize donor only curve (bdd) to FRET curve (fnfd)
% Find the max of fnfd between the specified wavelengths (lambda1, lambda2)
fndd_max = max(fndd(fndd(:,1)<params.lambda2 & fndd(:,1)>params.lambda1,2));
fnfd_max = max(fnfd(fnfd(:,1)<params.lambda2 & fnfd(:,1)>params.lambda1,2));
fndd(:,2) = fndd(:,2).*(fnfd_max/fndd_max);

%% Subtract donor only curve (bdd) from FRET curve (fnfd)
diff(:,1) = fnfd(:,1);
diff(:,2) = fnfd(:,2) - fndd(:,2);
diff(diff(:,2)<0,2) = 0;

%% Quantitative calculations
% Calculate ratios
w3 = fndd(:,1)==params.acceptor_peak;
w4 = fnfa(:,1)==params.acceptor_peak;
rat(1) = mean(diff(w3,2)./fnfa(w4,2));
for j = 1:FRET_width
    w3 = fndd(:,1) <= params.acceptor_peak + j & fndd(:,1) >= params.acceptor_peak - j;
    w4 = fnfa(:,1) <= params.acceptor_peak + j & fnfa(:,1) >= params.acceptor_peak - j;
    rat(j+1) = mean(diff(w3,2)./fnfa(w4,2));
end
w3_new = find(w3==1);
w3_new = w3_new(1);
w4_new = find(w4==1);
w4_new = w4_new(1);

%% Alternative quantitative calculation of area under curve
% Start and end of fnfa curve
v1s = 1;
TenPerc = max(fnfa(:,2))./10; % 10percent intensity
tmp = fnfa(:,2)-TenPerc;
[v1e,~] = find(abs(tmp) == min(abs(tmp)));

% Start and end of diff curve
[v2s,~] = find(diff(:,1) == min(fnfa(:,1)));
v2e = v2s+v1e-1;

% Verify we got the correct wavelengths
disp(['Iaa start: ' num2str(fnfa(v1s,1)) '      Iaa end: ' num2str(fnfa(v1e,1)) 10 'diff start: ' num2str(diff(v2s,1)) '     diff end: ' num2str(diff(v2e,1))])
% Calculate stuff
val1 = trapz(fnfa(w4_new:w4_new+4*FRET_width,1),fnfa(w4_new:w4_new+4*FRET_width,2));
val2 = trapz(diff(w3_new:w3_new+4*FRET_width,1),diff(w3_new:w3_new+4*FRET_width,2));
rat_new = val2/val1;

% Calculate efficiencies
e = params.p3/params.p1*(rat-params.p2/params.p3);
e_new = params.p3/params.p1*(rat_new-params.p2/params.p3);
disp(['E_OLD = ' num2str(mean(e)) 10 'E_NEW = ' num2str(e_new)]);

%% Display average FRET efficiency
output.data_Idd = fndd;
output.data_FRET = fnfd;
output.data_Iaa = fnfa;
output.data_Diff = diff;
output.Idd_max = fnfd_max;
output.Iaa_max = max(fnfa(:,2));
output.rat = mean(rat);
output.E = mean(e_new);