IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\M0_T1_NOMASK_2\GE';
ODIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\BET_trial';
FList   = xASL_adm_GetFsList( IDIR, 'GRN\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'M0.nii');
    oCopy       = fullfile( ODIR, ['GE_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\M0_T1_NOMASK_2\SI';
ODIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\BET_trial';
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'M0.nii');
    oCopy       = fullfile( ODIR, ['SI_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\M0_T1_NOMASK_2\PHBsup';
ODIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\BET_trial';
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:12
    clear iCopy oCopy
    iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'M0.nii');
    oCopy       = fullfile( ODIR, ['PHBsup_' FList{iF} '_M0.nii']);
    xASL_Copy( iCopy, oCopy);
end
%%
IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva no Bsup\analysis';
ODIR    = fullfile(IDIR, 'BET_mean_control');
xASL_adm_CreateDir(ODIR);
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:length(FList)
    clear iCopy oCopy tnii control_im label_im OrderContLabl

    iCopy           = fullfile( IDIR, FList{iF}, 'ASL_1', 'despiked_ASL4D.nii');
    if ~exist(iCopy,'file')
        iCopy       = fullfile( IDIR, FList{iF}, 'ASL_1', 'ASL4D.nii');
    end

    oCopy           = fullfile( ODIR, ['mean_control_' FList{iF} '.nii']);
    tnii        = xASL_nifti(iCopy);
    tnii        = tnii.dat(:,:,:,:);
    [ control_im label_im OrderContLabl] = Check_control_label_order( tnii );
    xASL_io_SaveNifti(iCopy,oCopy,mean(control_im,4),1);
    oCopy           = fullfile( ODIR, ['mean_PWI_Clipped_' FList{iF} '.nii']);
    xASL_io_SaveNifti(iCopy,oCopy,mean(control_im-label_im,4),1);
end

%% BETted Ph noBsup

IDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva no Bsup\analysis';
ODIR    = fullfile(IDIR, 'BET_mean_control');
xASL_adm_CreateDir(ODIR);
FList   = xASL_adm_GetFsList( IDIR, '(GRN|C9ORF|MAPT)\d{3}',1 );

for iF=1:length(FList)
    MaskFile        = fullfile( ODIR, [ 'mean_control_' FList{iF} '_bet.nii']);
    PWI_File        = fullfile( ODIR, ['mean_PWI_Clipped_' FList{iF} '.nii']);

    Masknii         = xASL_nifti(MaskFile);
    PWInii          = xASL_nifti(PWI_File);
    Masknii         = Masknii.dat(:,:,:);
    PWInii          = PWInii.dat(:,:,:);

    MaskPWI         = PWInii.*single(logical(Masknii));

    OutputFile      = fullfile( IDIR, FList{iF}, 'ASL_1', 'mean_PWI_Clipped.nii');

    delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'PWI_GradualMask.nii') );
    delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'rwmask_ICV.nii') );
    delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'wmask_ICV.nii') );
    delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'mean_PWI_Clipped.nii') );

    if  exist( fullfile( IDIR, FList{iF}, 'ASL_1', 'despiked_ASL4D.nii'), 'file')
        delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_despiked_ASL4D.nii') );
        delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_despiked_ASL4D.mat') );
        delete( fullfile( IDIR, FList{iF}, 'ASL_1','rtemp_despiked_ASL4D.nii') );
    else
        delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_ASL4D.nii') );
        delete( fullfile( IDIR, FList{iF}, 'ASL_1', 'temp_ASL4D.mat') );
        delete( fullfile( IDIR, FList{iF}, 'ASL_1','rtemp_ASL4D.nii') );
    end

    xASL_io_SaveNifti( PWI_File, OutputFile, MaskPWI);
end
