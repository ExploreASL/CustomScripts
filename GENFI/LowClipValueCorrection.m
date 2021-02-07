%% Low clip value correction
%% DOESNT WORK

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor';
FLIST   = xASL_adm_GetFileList(ROOT, '^PWI_6par_reg\.(nii|nii\.gz)$','FPListRec');

for iF=1:length(FLIST)
    tnii    = xASL_nifti(FLIST{iF});
    tnii    = tnii.dat(:,:,:);
    
    if  min(tnii(:))>0
        tnii(tnii==min(tnii(:)))    = 0;
    end
    
    dip_image(tnii)
