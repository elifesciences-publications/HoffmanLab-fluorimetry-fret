function SpectraPlot(output,savename,params,savefolder)
%Plots fluorimetry curves quantitatively

%% Specify Colors
colors = load('colors.txt');
c_d = round(((params.lambda1-400)/200)*length(colors));
c_a = round(((params.acceptor_peak-400)/200)*length(colors));
c_d = colors(c_d,2:4)./255;
c_a = colors(c_a,2:4)./255;

%% Plot All Curves Quantitatively
figure('Position',[100 500 700 450]);
set(gcf,'Color','white');
hold on
plot(output.data_FRET(:,1),output.data_FRET(:,2),'Color',c_d,'LineStyle','-','LineWidth',1.5);
plot(output.data_Iaa(:,1),output.data_Iaa(:,2),'Color',c_a,'LineStyle','-','LineWidth',1.5);
plot(output.data_Idd(:,1),output.data_Idd(:,2),'Color',c_d,'LineStyle','--','LineWidth',1.5);
plot(output.data_Diff(:,1),output.data_Diff(:,2),'Color',c_a,'LineStyle','--','LineWidth',1.5);
set(gca,'FontName','Segoe UI');
set(gca,'FontSize',14);
set(gca,'Box','on');
set(gca,'LineWidth',1.5);
set(gca,'XLim',[min(output.data_FRET(:,1)),max(output.data_FRET(:,1))-10]);
xlabel('Wavelength (nm)');
ylabel('Normalized Emission Intensity (a.u.)');
legend({'Sample Dex','Sample Aex','Donor Only','FRET'},'Location','eastoutside','FontSize',10);
saveas(gcf,fullfile(savefolder,'Figures',['QuatPlot_' savename]),'png');
hold off
close

%% Plot FRET curve vs predicted FRET curve
% Experimental Data
exp_data(:,1) = output.data_FRET(:,1); % Specify Wavelengths
exp_data(:,2) = output.data_FRET(:,2)./output.Idd_max; % Normalize donor peak to 1

% Modeled Spectral Data
modeled_data(:,1) = output.data_FRET(:,1); % Specify Wavelengths

modeled_data(:,2) = output.data_Idd(:,2)./output.Idd_max; % 1 DONOR ONLY (Normalize donor peak to 1)
for i = 1:length(modeled_data)
    AOrows(i) = find(params.baa(:,1)==modeled_data(i,1));
end
modeled_data(:,3) = params.baa(AOrows,2).*output.Iaa_max.*(params.p2/params.p3)./output.Idd_max; % 2 ACCEPTOR ONLY (normalized to Iaa_max then scale by p2

Esim = output.E;
FRET_scale_factor = Esim.*(params.p1/params.p3);
modeled_data(:,4) = params.baa(AOrows,2).*output.Iaa_max.*FRET_scale_factor./output.Idd_max; % 3 FRET SIGNAL (normalize according to inverted Madjumdar equation)
modeled_data(:,5) = sum(modeled_data(:,2:4),2);

figure('Position',[100 500 840 450]);
set(gcf,'Color','white');
hold on
plot(exp_data(:,1),exp_data(:,2),'Color','k','LineStyle','-','LineWidth',1.5);
plot(modeled_data(:,1),modeled_data(:,2),'Color',c_d,'LineStyle','--','LineWidth',1.5);
plot(modeled_data(:,1),modeled_data(:,3),'Color',c_a,'LineStyle','--','LineWidth',1.5);
plot(modeled_data(:,1),modeled_data(:,3)+modeled_data(:,4),'Color',(c_d+c_a)./2,'LineStyle','--','LineWidth',1.5);
plot(modeled_data(:,1),modeled_data(:,5),'Color',(c_d+c_a)./2,'LineStyle','-','LineWidth',1.5);

x = modeled_data(:,1);
y2 = modeled_data(:,3)+modeled_data(:,4);
y1 = modeled_data(:,3);
x(y1==0)=[];
y1(y1==0)=[];
y2(y2==0)=[];
X=[x',fliplr(x')];
Y=[y1',fliplr(y2')];
f = fill(X,Y,'b');
set(f,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5,'LineStyle','none');

set(gca,'FontName','Segoe UI');
set(gca,'FontSize',14);
set(gca,'Box','on');
set(gca,'LineWidth',1.5);
set(gca,'XLim',[min(output.data_FRET(:,1)),max(output.data_FRET(:,1))-10]);
set(gca,'YLim',params.ylim);
xlabel('Wavelength (nm)');
ylabel('Normalized Emission Intensity (a.u.)');
Esim_str = num2str(Esim.*100);
legend({'Experiment','Donor Only Component','Acceptor Bleedthrough Component','FRET Component',['Total Spectra, Modeled E = ' Esim_str(1:4)]},'Location','eastoutside','FontSize',10);
saveas(gcf,fullfile(savefolder,'Figures',['SimFRET_' savename]),'png');
hold off
close
end

