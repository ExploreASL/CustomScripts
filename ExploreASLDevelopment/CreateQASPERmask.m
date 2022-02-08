%% Create QASPER mask
% load paths
pathInlet = '/Users/henk/ExploreASL/ExploreASL/Maps/Templates/QASPER/InletBin2PCASLRescSmth.nii';
pathPorous = '/Users/henk/ExploreASL/ExploreASL/Maps/Templates/QASPER/PorousBin2PCASLRescSmth.nii';

pathMask = '/Users/henk/ExploreASL/ExploreASL/Maps/Templates/QASPER/QASPER_QC_mask.nii.gz';
% load images
imInlet = xASL_io_Nifti2Im(pathInlet);
imPorous = xASL_io_Nifti2Im(pathPorous);
% normalize
imInlet = imInlet./max(imInlet(:));
imPorous = imPorous./max(imPorous(:));

imMask = imInlet+imPorous;
imMask(imMask>1) = 1;

imMask = imMask>0.5;

% save image
xASL_io_SaveNifti(pathPorous, pathMask, imMask, 8, 1);