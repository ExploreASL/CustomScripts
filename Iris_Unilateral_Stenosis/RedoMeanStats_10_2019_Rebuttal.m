%% Combine Tatu vascular territories in ICAs & PCA

TatuNii = 'C:\ExploreASL\Maps\Atlases\VascularTerritories\CortVascTerritoriesTatu.nii';
Path_TatuICA_PCA = 'C:\ExploreASL\Maps\Atlases\VascularTerritories\TatuICA_PCA.nii';
TatuIM = xASL_io_Nifti2Im(TatuNii);

TatuICA_PCAim = TatuIM;
TatuICA_PCAim(TatuICA_PCAim==2) = 1;
TatuICA_PCAim(TatuICA_PCAim==3) = 2;

xASL_io_SaveNifti(TatuNii, Path_TatuICA_PCA, TatuICA_PCAim, 8, 0);


%% Redo calculation CBF & sCoV
x.S.KISS                      = 1; 
x.S.LabEffNorm          = 0;
x.S.InputDataStr              = 'qCBF_untreated';
x.S.GetStats                  = 0;
x.S.InputAtlasPath            = fullfile(x.D.AtlasDir,'VascularTerritories','TatuICA_PCA.nii');
xASL_wrp_GetROIstatistics(x); % while setting computeCBF to mean instead of median
% previous values seem with PVC, but also, no M0, so scaled to 60


%% Create lower and upper slices ICA mask
Path_SliceGradient = fullfile(x.D.PopDir, 'Templates', 'SliceGradient_bs-mean_Unmasked.nii');
SliceGradientIM = xASL_io_Nifti2Im(Path_SliceGradient);

ICAmask = fullfile(x.D.AtlasDir,'VascularTerritories','TatuICA_PCA.nii');
ICAmask = xASL_io_Nifti2Im(ICAmask)==1;

SliceGradientIM(~ICAmask) = 0;
TopDownSlices = SliceGradientIM;
TopDownSlices(SliceGradientIM>=7) = 1;
TopDownSlices(SliceGradientIM>0 & SliceGradientIM<7) = 2;
Path_TopDownICA = fullfile(x.D.PopDir, 'Templates', 'TopDown_ICA.nii');
xASL_io_SaveNifti(Path_SliceGradient, Path_TopDownICA, TopDownSlices, 8, 0);

%% Redo calculation CBF & sCoV with upper & lower slices only
x.S.KISS                      = 1; 
x.S.LabEffNorm          = 0;
x.S.InputDataStr              = 'qCBF_untreated';
x.S.GetStats                  = 0;
x.S.InputAtlasPath            = fullfile(x.D.PopDir, 'Templates', 'TopDown_ICA.nii');
xASL_wrp_GetROIstatistics(x); % while setting computeCBF to mean instead of median
% previous values seem with PVC, but also, no M0, so scaled to 60

%% Store data from excel files

DataPathCBF   = 'C:\Users\kyrav\Desktop\Gdrive\XploreLab\ProjectsPending\sCoV_carotid_occlusion_Iris\Results\AllResults.xls';
[~, ~, DataCBF] = xlsread(DataPathCBF);

% Fill SubjSess
for iD=1:size(DataCBF,1)-2
    Subj{iD,1}  = num2str(DataCBF{iD+2,1}(1:3));
    Sess{iD,1}  = DataCBF{iD+2,1}(5:end);
end

UpperSlices_Left_ICA_CBF    = [Subj Sess];
UpperSlices_Right_ICA_CBF   = [Subj Sess];
UpperSlices_Left_ICA_CoV    = [Subj Sess];
UpperSlices_Right_ICA_CoV   = [Subj Sess];
LowerSlices_Left_ICA_CBF    = [Subj Sess];
LowerSlices_Right_ICA_CBF   = [Subj Sess];
LowerSlices_Left_ICA_CoV    = [Subj Sess];
LowerSlices_Right_ICA_CoV   = [Subj Sess];

% Fill data
UpperSlices_Left_ICA_CBF(:,3)    = DataCBF(3:end,26);
UpperSlices_Right_ICA_CBF(:,3)   = DataCBF(3:end,27);
UpperSlices_Left_ICA_CoV(:,3)    = DataCBF(3:end,30);
UpperSlices_Right_ICA_CoV(:,3)   = DataCBF(3:end,31);
LowerSlices_Left_ICA_CBF(:,3)    = DataCBF(3:end,28);
LowerSlices_Right_ICA_CBF(:,3)   = DataCBF(3:end,29);
LowerSlices_Left_ICA_CoV(:,3)    = DataCBF(3:end,32);
LowerSlices_Right_ICA_CoV(:,3)   = DataCBF(3:end,33);

save('F:\Archive_ASL\Unilateral_Stenosis\analysis\UpperSlices_Left_ICA_CBF.mat','UpperSlices_Left_ICA_CBF');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\UpperSlices_Right_ICA_CBF.mat','UpperSlices_Right_ICA_CBF');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\UpperSlices_Left_ICA_CoV.mat','UpperSlices_Left_ICA_CoV');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\UpperSlices_Right_ICA_CoV.mat','UpperSlices_Right_ICA_CoV');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\LowerSlices_Left_ICA_CBF.mat','LowerSlices_Left_ICA_CBF');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\LowerSlices_Right_ICA_CBF.mat','LowerSlices_Right_ICA_CBF');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\LowerSlices_Left_ICA_CoV.mat','LowerSlices_Left_ICA_CoV');
save('F:\Archive_ASL\Unilateral_Stenosis\analysis\LowerSlices_Right_ICA_CoV.mat','LowerSlices_Right_ICA_CoV');




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

