%% Siemens subtraction wrong, Z-axis aliasing
clear
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\ExcludedTempArtifacts\_1\RegistrationIssue\SI_Trio_C9ORF085_1\ASL_1';
FName   = fullfile(ROOT, 'ASL4D.nii');

nii     = xASL_nifti(FName);
nii     = nii.dat(:,:,:,:);
nii     = nii(:,:,:,1)-nii(:,:,:,2);
dip_image(nii)

clear
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\ExcludedTempArtifacts\_1\RegistrationIssue\SI_Trio_C9ORF041_1\ASL_1';
FName   = fullfile(ROOT, 'ASL4D.nii');

nii     = xASL_nifti(FName);
nii     = nii.dat(:,:,:,:);
nii     = nii(:,:,:,1)-nii(:,:,:,2);
dip_image(nii)