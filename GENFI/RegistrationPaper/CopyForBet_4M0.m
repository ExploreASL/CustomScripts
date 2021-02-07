IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\NoReg\GE';
ODIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\MASK_HJ_trial_M0';
xASL_adm_CreateDir(ODIR);
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\NoReg\GE';
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_M0.nii');
    oCopy       = fullfile( ODIR, ['GE_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\NoReg\SI';
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_M0.nii');
    oCopy       = fullfile( ODIR, ['SI_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\NoReg\PHBsup';
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_M0.nii');
    oCopy       = fullfile( ODIR, ['PHBsup_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\NoReg\PHnonBsup';
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_M0.nii');
    oCopy       = fullfile( ODIR, ['PHnonBsup_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
    
    
