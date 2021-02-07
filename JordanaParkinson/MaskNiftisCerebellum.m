%% 1) When you load this nifti with e.g. mriCron, check under info what the
% voxel-size is. This should be the same as the voxel-size of your perfusion images
% If you use the wT1.nii that I gave you, these are in 2x2x2 mm voxels,
% whereas the mask is in 1.5x1.5x1.5 mm voxels. You can reslice the mask to
% be in the same voxel-size using SPM-reslice.
% If the mask is already in the correct voxel-size, you can skip this part
%
% open SPM with "spm_jobman" in matlab command line
% here you select "spatial->Coregister->Coregister: Reslice"
% As "Image Defining Space" you select one of your perfusion images that
% are in the correct voxel-size
% As "Images to Reslice" you select your mask, which you want to reslice to
% the same voxel-size as the perfusion image. Leave the rest of the
% settings unchanged. This should create a copy of the mask with prefix "r"
% that you can use

%% 2) Load cerebellar mask
CerebellumMaskFileName = 'c:\ASL_pipeline_HJ\Maps\rrcerebellum_ROI_FNIRT_25threshold.nii';
CerebellumMaskNifti = xASL_io_ReadNifti(CerebellumMaskFileName);
CerebellumMaskImage = CerebellumMaskNifti.dat(:,:,:);

% check the CerebellumMask image

dip_image(CerebellumMaskImage)
% in this viewer, use control-L to scale intensities
% do e.g. Sizes-400 % for larger view
% with the keys "n" & "p" you can scroll through the image
% with the mouse you will see that the mask is 1 and background is 0
% so it is a dichotomous mask, as opposed to a probability map, which would have
% a continuous scale

%% 3) Loop through subjects & load images
% Now we will load the images, by looping across the subjects

ROOT            = 'C:\Backup\ASL\JordanaNifti';
DirectoryList   = dir(fullfile(ROOT,'*.')); % search for directories
DirectoryList   = DirectoryList(3:end);

for iDir=1:length(DirectoryList) % first two in this list are not directories, so we start our loop with 3
    clear PerfusionFileName PerfusionNifti PerfusionImage CerebellarCBFvalues % for each iteration, remove previous data from memory

    PerfusionFileName   = fullfile( ROOT, DirectoryList(iDir).name, 'CBF.nii'); % change this name for your perfusion images
    PerfusionNifti      = xASL_io_ReadNifti(PerfusionFileName);
    PerfusionImage      = PerfusionNifti.dat(:,:,:);

    % dip_image([PerfusionImage CerebellarMaskImage PerfusionImage.*CerebellarMaskImage])
    % This shows you the perfusion image, the mask-image & the perfusion image masked with cerebellar mask

    % Get average CBF value within cerebellar mask:
    CerebellarCBFvalues         = PerfusionImage(logical(CerebellumMaskImage));
    meanCerebellarCBF(iDir,1)   = mean(CerebellarCBFvalues(:));

    % Divide the perfusion image by cerebellar perfusion (i.e. the
    % normalization);
    PerfusionImageNew           = PerfusionImage./meanCerebellarCBF(iDir,1);

    % Now the whole perfusion image is around 1, and the mean perfusion in
    % the cerebellar mask is 1 right?
    % If you want, you can multiply each PerfusionImage with the same value that
    % you want the mean perfusion to be, e.g. 50, so that you still have
    % perfusion values instead of ratios;

    PerfusionImageNew           = PerfusionImageNew.*50;
    % compare the old & new perfusion images
    % dip_image([PerfusionImage PerfusionImageNew])

    % save the normalized perfusion image
    PerfusionFileNameNew        = fullfile( ROOT, DirectoryList(iDir).name, 'normalized_CBF.nii');
    xASL_io_SaveNifti(PerfusionFileName,PerfusionFileNameNew,PerfusionImageNew);
end
