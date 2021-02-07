for ii=1:5
    FList{ii} = xASL_adm_GetFileList(x.D.PopDir,['^qCBF_untreated_\d*_ASL_' num2str(ii) '\.(nii|nii\.gz)$']);
    for iJ=1:length(FList{ii})
        clear tIM
        tIM     = xASL_io_ReadNifti(FList{ii}{iJ});
        IM{ii}(:,:,:,iJ)    = tIM.dat(:,:,:);
    end
    meanIM{ii}  = xASL_stat_MeanNan(IM{ii},4);
    stdIM{ii}   = xASL_stat_StdNan(IM{ii},[],4);
    snrIM{ii}   = meanIM{ii}./stdIM{ii};
end

EvDir   = 'C:\Backup\ASL\Divers_Bonn\analysis\dartel\Templates\permute_session';
Fname{1}    = fullfile(EvDir,'Mean_sessionbaseline.nii');
Fname{2}    = fullfile(EvDir,'Mean_sessionearly hypoxia.nii');
Fname{3}    = fullfile(EvDir,'Mean_sessionlate hypoxia.nii');
Fname{4}    = fullfile(EvDir,'Mean_sessionearly recovery.nii');
Fname{5}    = fullfile(EvDir,'Mean_sessionlate recovery.nii');

for iF=1:5
    clear tIM
    tIM     = xASL_io_ReadNifti(Fname{iF});
    MeanIM2{iF}     = tIM.dat(:,:,:);
end

for ii=1:5
    clear tIM
    tIM     = ((meanIM{ii} - MeanIM2{ii})).*x.skull;
    xASL_stat_MeanNan(tIM(:))
%     minnan(tIM(:))
%     maxnan(tIM(:))
end



%%%%%%

1 10 11 12 13 14 15 2
% tIM1    = squeeze(ASL_untreated.Data.data(40,:,:,:));

tIM3    = squeeze(x.S.DAT(33,:,:,:));

tIM2    = xASL_io_ReadNifti(fullfile(x.D.PopDir,'qCBF_untreated_15_ASL_3.nii'));
tIM2    = tIM2.dat(:,:,:).*x.skull;

tIM     = (tIM2-tIM3);
xASL_stat_MeanNan(tIM(:))
