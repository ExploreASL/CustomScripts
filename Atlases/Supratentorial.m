PathIn = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/brainmask_supratentorial.nii';
PathOut = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/brainmask_supratentorial_New.nii';

IM = xASL_io_Nifti2Im(PathIn);

IM = xASL_im_DilateErodeFull(IM,'dilate',xASL_im_DilateErodeSphere(3));

%%%%%%%%%%%%%

% pathIn = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/WholeBrain.nii.gz';
% pathOut = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/brainmask_supratentorial_New2.nii';

pathDK = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/Atlases/Desikan_Killiany_MNI_SPM12.nii';
imDK = xASL_io_Nifti2Im(pathDK);

pathMindboggle = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/Atlases/Mindboggle_OASIS_DKT31_CMA.nii';
imMindboggle = xASL_io_Nifti2Im(pathMindboggle);


% IM = xASL_io_Nifti2Im(pathIn);
% %% DK
% IM(imDK== 3) = 0; % 3 cerebellum WM
% IM(imDK== 4) = 0; % 4 cerebellum cortex
% IM(imDK== 9) = 0; % 9 3rd ventricle
% IM(imDK==10) = 0; % 10 4rd ventricle
% IM(imDK==11) = 0; % 11 brainstem
% IM(imDK==16) = 0; % 16 ventral dentate nucleus

%% Mindboggle
IM(imMindboggle== 1) = 0; % 1 cerebellum exterior
IM(imMindboggle== 2) = 0; % 2 cerebellum WM
IM(imMindboggle==10) = 0; % 10 ventral dentate nucleus
IM(imMindboggle==11) = 0; % 11 basal forebrain
IM(imMindboggle==12) = 0; % 12 cerebellar vermal
IM(imMindboggle==13) = 0; % 13 cerebellar vermal
IM(imMindboggle==14) = 0; % 14 cerebellar vermal


xASL_io_SaveNifti(PathIn, PathOut, IM);