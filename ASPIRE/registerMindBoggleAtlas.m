% Paths
path_pGM_mni = '/Users/hjmutsaerts/Downloads/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_gm_tal_nlin_sym_09c.nii';
path_pWM_mni = '/Users/hjmutsaerts/Downloads/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_wm_tal_nlin_sym_09c.nii';

dirRegistration = '/Users/hjmutsaerts/ExploreASL/ASL/RegistrationMindBoggle';
xASL_adm_CreateDir(dirRegistration);

path_Combined_mni = fullfile(dirRegistration, 'combined_MNI.nii');

path_rCombined_mni = fullfile(dirRegistration, 'rcombined_MNI.nii');
path_Combined_cat = fullfile(dirRegistration, 'combined_CAT.nii');

path_pGM_cat = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/rc1T1.nii';
path_pWM_cat = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/rc2T1.nii';

path_mb_old = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/Atlases/Mindboggle_OASIS_DKT31_CMA.nii';
path_mb_new = fullfile(dirRegistration, 'Mindboggle_OASIS_DKT31_CMA.nii');
path_mb_rnew = fullfile(dirRegistration, 'rMindboggle_OASIS_DKT31_CMA.nii');
path_sn = fullfile(dirRegistration, 'rcombined_MNI_sn.mat');

% Thicken cortical atlas
%   Copy auxiliary maps
pathCentrifugal = '/Users/hjmutsaerts/surfdrive - Mutsaerts, H.J.M.M. (Henk-Jan)@surfdrive.surf.nl/HolidayPics/ExploreASL/MapsExploreASLUnused/CentrifugalIM.nii.gz';
pathWMdistance = '/Users/hjmutsaerts/surfdrive - Mutsaerts, H.J.M.M. (Henk-Jan)@surfdrive.surf.nl/HolidayPics/ExploreASL/MapsExploreASLUnused/WM_DistanceMap.nii.gz';
pathCentrifugal_new = fullfile(dirRegistration, 'CentrifugalIM.nii');
pathWMdistance_new = fullfile(dirRegistration, 'WM_DistanceMap.nii');

xASL_Copy(pathCentrifugal, pathCentrifugal_new);
xASL_Copy(pathWMdistance, pathWMdistance_new);

%   Open images
im_mb = xASL_io_Nifti2Im(path_mb_new);

im_mb_dilated = xASL_im_DilateErodeFull(im_mb, 'dilate', xASL_im_DilateErodeSphere(3));


figure(1); imshow([im_mb(:,:,53) im_mb_dilated(:,:,53)], [], 'InitialMagnification', 250)


% 1. Dilate each ROI and give each dilation/layer a distance number (can we do this with xASL_im_DistanceTransform)?
%    We do this e.g. 6 times
% 2. Assign each voxel to the ROI with the smallest distance number 



% Create combined MNI template
im_pGM_mni = xASL_io_Nifti2Im(path_pGM_mni);
im_pWM_mni = xASL_io_Nifti2Im(path_pWM_mni);

im_combined_mni = im_pGM_mni .* 3 + im_pWM_mni;

figure(1); imshow([im_combined_mni(:,:,100) im_pGM_mni(:,:,100) im_pWM_mni(:,:,100)], [], 'InitialMagnification', 250)

xASL_io_SaveNifti(path_pWM_mni, path_Combined_mni, im_combined, [], 0, [], [], [], [], 1);

% Resample

xASL_spm_reslice(path_Combined_cat, path_Combined_mni, [], [], 1, path_rCombined_mni);



% Create combined CAT template
im_pGM_cat = xASL_io_Nifti2Im(path_pGM_cat);
im_pWM_cat = xASL_io_Nifti2Im(path_pWM_cat);

im_combined_cat = im_pGM_cat .* 3 + im_pWM_cat;

xASL_io_SaveNifti(path_pWM_cat, path_Combined_cat, im_combined_cat);

figure(2); imshow([im_combined_cat(:,:,100) im_pGM_cat(:,:,100) im_pWM_cat(:,:,100)], [], 'InitialMagnification', 250)

clear all


% Visualize
im_combined_mni = xASL_io_Nifti2Im(path_rCombined_mni);
im_combined_cat = xASL_io_Nifti2Im(path_Combined_cat);

figure(1); imshow([im_combined_mni(:,:,53) im_combined_cat(:,:,53)], [], 'InitialMagnification', 250)

% Copy mindboggle atlas

xASL_Copy(path_mb_old, path_mb_new, 1);

xASL_spm_affine(path_rCombined_mni, path_Combined_cat, 8, 8, [], 1, 1);

% Apply the deformations

matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {'/Users/hjmutsaerts/ExploreASL/ASL/RegistrationMindBoggle/rcombined_MNI_sn.mat'};
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {'/Users/hjmutsaerts/ExploreASL/ASL/RegistrationMindBoggle/Mindboggle_OASIS_DKT31_CMA.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savepwd = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';

spm_jobman('run', matlabbatch);
