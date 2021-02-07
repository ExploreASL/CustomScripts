%% Create pseudo-T1
clear IM1 IM2 IM3 ROOT
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_Long_T2\analysis\PH_Achieva_noBsup_MAPT021_1';

IM1     = fullfile(ROOT, 'c1T1.nii');
IM2     = fullfile(ROOT, 'c2T1.nii');

IM1     = xASL_nifti(IM1);
IM2     = xASL_nifti(IM2);

IM1     = IM1.dat(:,:,:);
IM2     = IM2.dat(:,:,:);

IM3     = IM2.*1500 + IM1.*1000;

xASL_io_SaveNifti( fullfile(ROOT,'c1T1.nii'), fullfile(ROOT,'T1.nii'), IM3);

%%
clear IM1 IM2 IM3 ROOT

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_Long_T2\analysis\PH_Achieva_noBsup_MAPT021_2';

IM1     = fullfile(ROOT, 'c1T1.nii');
IM2     = fullfile(ROOT, 'c2T1.nii');

IM1     = xASL_nifti(IM1);
IM2     = xASL_nifti(IM2);

IM1     = IM1.dat(:,:,:);
IM2     = IM2.dat(:,:,:);

IM3     = IM2.*1500 + IM1.*1000;

xASL_io_SaveNifti( fullfile(ROOT,'c1T1.nii'), fullfile(ROOT,'T1.nii'), IM3);
