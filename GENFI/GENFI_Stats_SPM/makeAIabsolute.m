% Make scans absolute

List    = xASL_adm_GetFileList(SPMdir,'^Set1subject\d*\.(nii|nii\.gz)$');
for iD=1:length(List);
    clear tIM
    tIM     = xASL_nifti(List{iD});
    tIM     = tIM.dat(:,:,:);
%     tIM     = abs(tIM);
    tIM(tIM==0)     = NaN;
    tIM     = xASL_im_ndnanfilter( tIM ,'gauss',[1.885 1.885 1.885],1);
    tIM(isnan(tIM))     = 0;
    xASL_io_SaveNifti(List{iD},List{iD},tIM);
end

%% Switch dirs -> non-abs (laterality)
SPMdir          = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_AI\permute_LongitudinalTimePoint\SPMdir';
x.S.StatsDir      = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_AI\permute_LongitudinalTimePoint';
x.S.output_ID     = 'CBF_AI';
cd(SPMdir);

%% Switch dirs -> abs (asymmetry)
SPMdir          = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_AI_abs\permute_LongitudinalTimePoint\SPMdir';
x.S.StatsDir      = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_AI_abs\permute_LongitudinalTimePoint';
x.S.output_ID     = 'CBF_AI_abs';
cd(SPMdir);

%% Create asymmetry mask
MaskIM      = squeeze(mean(x.S.DATASETS{1},1));
MaskIM      = MaskIM~=0 & isfinite(MaskIM);

VBAmask     = xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\VBA_mask_final.nii');
VBAmask     = VBAmask.dat(:,:,:);

dip_image([MaskIM VBAmask])

xASL_io_SaveNifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\VBA_mask_final.nii','C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\VBA_AI_mask.nii',MaskIM);

%% Search images without information
