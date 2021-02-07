%% Create visualization territories

ResultsDir                  = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\ResultsNew';
TatuName                    = 'C:\ExploreASL\Maps\Atlases\VascularTerritories\CortVascTerritoriesTatu.nii';
Tatu                        = nifti2IM(TatuName);
ICAim                       = (Tatu==1 | Tatu==2);
ICA_L                       = ICAim;
ICA_L(1:61,:,:)             = 0;
% ICA_L(:,:,[1:69 71:end])    = 0;
ICA_R                       = ICAim;
ICA_R(62:121,:,:)           = 0;
% ICA_R(:,:,[1:69 71:end])    = 0;

% CBFfactor                   = 1.67;
% CBFim                       = CBFim./CBFfactor;

Subjects    = {'002' '003' '005' '008' '009'};
for iS=1:length(Subjects)
    c1Path  = fullfile('C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel',['PV_pGM_' Subjects{iS} '.nii']);
    c1IM    = nifti2IM(c1Path)>0.5;
    ICA_Lim = c1IM.*ICA_L;
    ICA_Rim = c1IM.*ICA_R;
    
    ICApathL    = fullfile(ResultsDir,['ICA_L_' Subjects{iS} '.jpg']);
    ICApathR    = fullfile(ResultsDir,['ICA_R_' Subjects{iS} '.jpg']);

    save_nii_spm(TatuName,ICApathL,ICA_Lim,[],0);
    save_nii_spm(TatuName,ICApathR,ICA_Rim,[],0);
end