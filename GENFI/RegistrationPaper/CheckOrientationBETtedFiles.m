%% Check if different orientation matrix of BETted maps differs

DIRBET      = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendorOLD\BET_trial\OriginalFilesUsed';
DIRBET      = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendorOLD\BET_trial\BET_robust';
DIRORI      = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\M0_T1_BETMASK';

FILEBET     = fullfile(DIRBET, 'PHnonBsup_GRN021_M0.nii_bet3.nii');
FILEORI     = fullfile(DIRORI, 'PHnonBsup', 'GRN021','ASL_1','temp_M0.nii');

LOADBET     = xASL_nifti(FILEBET);
LOADORI     = xASL_nifti(FILEORI);

IMBET       = LOADBET.dat(:,:,:);
IMORI       = LOADORI.dat(:,:,:);
IMPROC      = single(logical(LOADBET.dat(:,:,:))).*LOADORI.dat(:,:,:);

dip_image([IMBET IMPROC IMORI])