%% Redo calculation CBF
S.KISS                      = 1; 
symbols.LabEffNorm          = 0;
S.InputDataStr              = 'qCBF_untreated';
S.GetStats                  = 0;
S.InputAtlasPath            = fullfile(symbols.AtlasDir,'VascularTerritories','LabelingTerritories.nii');
xASL_wrp_GetROIstatistics( symbols, S); % while setting computeCBF to mean instead of median
% previous values seem with PVC, but also, no M0, so scaled to 60

%% Calculate for mean_control
S.KISS                      = 1; 
symbols.LabEffNorm          = 0;
S.InputDataStr              = 'mean_control';
S.GetStats                  = 0;
S.InputAtlasPath            = fullfile(symbols.AtlasDir,'VascularTerritories','LabelingTerritories.nii');
Get_ROI_statistics( symbols, S);

%% Calculate for PV_pGM
S.KISS                      = 1; 
symbols.LabEffNorm          = 0;
S.InputDataStr              = 'PV_pGM';
S.GetStats                  = 0;
S.InputAtlasPath            = fullfile(symbols.AtlasDir,'VascularTerritories','LabelingTerritories.nii');
Get_ROI_statistics( symbols, S);


%% Get data from excel files -> CBF
clear Subj Sess Left_ICA_CBF

DataPathCBF   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\STATS\median_qCBF_untreated_LabelingTerritories_n=31_30-Aug-2018_PVC0.csv';
DataPathCoV   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\STATS\spatialCoV_qCBF_untreated_LabelingTerritories_n=31_30-Aug-2018_PVC0.csv';

[~, ~, DataCBF] = xlsread(DataPathCBF);
[~, ~, DataCoV] = xlsread(DataPathCoV);

% Fill SubjSess
for iD=1:size(DataCBF,1)-2
    Subj{iD,1}  = num2str(DataCBF{iD+2,1}(1:3));
    Sess{iD,1}  = DataCBF{iD+2,1}(5:end);
end
    
Left_ICA_CBF    = [Subj Sess];
Right_ICA_CBF   = [Subj Sess];
Left_ICA_CoV    = [Subj Sess];
Right_ICA_CoV   = [Subj Sess];

% Fill data
Left_ICA_CBF(:,3)   = DataCBF(3:end,25);
Right_ICA_CBF(:,3)  = DataCBF(3:end,29);

Left_ICA_CoV(:,3)    = DataCoV(3:end,25);
Right_ICA_CoV(:,3)   = DataCoV(3:end,29);

save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Left_ICA_CBF.mat','Left_ICA_CBF');
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Right_ICA_CBF.mat','Right_ICA_CBF');
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Left_ICA_CoV.mat','Left_ICA_CoV');
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Right_ICA_CoV.mat','Right_ICA_CoV');



%% Get data from excel files -> MeanControl
clear Subj Sess Left_ICA_MC_MEAN
 
DataPathMC_MEAN   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\STATS\MeanControl\median_mean_control_LabelingTerritories_n=31_31-Aug-2018_PVC0.csv';
DataPathMC_CoV   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\STATS\MeanControl\spatialCoV_mean_control_LabelingTerritories_n=31_31-Aug-2018_PVC0.csv';
 
[~, ~, DataMC_MEAN] = xlsread(DataPathMC_MEAN);
[~, ~, DataMC_CoV] = xlsread(DataPathMC_CoV);
 
% Fill SubjSess
for iD=1:size(DataMC_MEAN,1)-2
    Subj{iD,1}  = num2str(DataMC_MEAN{iD+2,1}(1:3));
    Sess{iD,1}  = DataMC_MEAN{iD+2,1}(5:end);
end
    
Left_ICA_MC_MEAN    = [Subj Sess];
Right_ICA_MC_MEAN   = [Subj Sess];
Left_ICA_MC_CoV    = [Subj Sess];
Right_ICA_MC_CoV   = [Subj Sess];
 
% Fill data
Left_ICA_MC_MEAN(:,3)   = DataMC_MEAN(3:end,21);
Right_ICA_MC_MEAN(:,3)  = DataMC_MEAN(3:end,25);
 
Left_ICA_MC_CoV(:,3)    = DataMC_CoV(3:end,21);
Right_ICA_MC_CoV(:,3)   = DataMC_CoV(3:end,25);
 
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Left_ICA_MC_MEAN.mat','Left_ICA_MC_MEAN');
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Right_ICA_MC_MEAN.mat','Right_ICA_MC_MEAN');
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Left_ICA_MC_CoV.mat','Left_ICA_MC_CoV');
save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Right_ICA_MC_CoV.mat','Right_ICA_MC_CoV');



% %% Get data from excel files -> PV_pGM (requires modulation first)
% clear Subj Sess Left_ICA_PV_PGM_MEAN
%  
% DataPathPV_PGM_MEAN   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\STATS\PV_pGM\median_PV_pGM_LabelingTerritories_n=31_31-Aug-2018_PVC0.csv';
% DataPathPV_PGM_CoV   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\STATS\PV_pGM\spatialCoV_PV_pGM_LabelingTerritories_n=31_31-Aug-2018_PVC0.csv';
%  
% [~, ~, DataPV_PGM_MEAN] = xlsread(DataPathPV_PGM_MEAN);
% [~, ~, DataPV_PGM_CoV] = xlsread(DataPathPV_PGM_CoV);
%  
% % Fill SubjSess
% for iD=1:size(DataPV_PGM_MEAN,1)-2
%     Subj{iD,1}  = sprintf('%03d',DataPV_PGM_MEAN{iD+2,1});
% end
%     
% Left_ICA_PV_PGM_MEAN    = [Subj];
% Right_ICA_PV_PGM_MEAN   = [Subj];
% Left_ICA_PV_PGM_CoV    = [Subj];
% Right_ICA_PV_PGM_CoV   = [Subj];
%  
% % Fill data
% Left_ICA_PV_PGM_MEAN(:,2)   = DataPV_PGM_MEAN(3:end,21);
% Right_ICA_PV_PGM_MEAN(:,2)  = DataPV_PGM_MEAN(3:end,25);
%  
% Left_ICA_PV_PGM_CoV(:,2)    = DataPV_PGM_CoV(3:end,21);
% Right_ICA_PV_PGM_CoV(:,2)   = DataPV_PGM_CoV(3:end,25);
%  
% save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Left_ICA_PV_PGM_MEAN.mat','Left_ICA_PV_PGM_MEAN');
% save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Right_ICA_PV_PGM_MEAN.mat','Right_ICA_PV_PGM_MEAN');
% save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Left_ICA_PV_PGM_CoV.mat','Left_ICA_PV_PGM_CoV');
% save('C:\Backup\ASL\Unilateral_Stenosis\analysis\Right_ICA_PV_PGM_CoV.mat','Right_ICA_PV_PGM_CoV');

