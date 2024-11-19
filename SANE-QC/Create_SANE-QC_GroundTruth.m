PathGM = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/rc1T1.nii';
PathWM = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/rc2T1.nii';
PathCSF = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/rc3T1.nii';
PathMask = '/Users/hjmutsaerts/ExploreASL/ExploreASL/External/SPMmodified/MapsAdded/brainmask.nii';

PathNew = '/Users/hjmutsaerts/ExploreASL/ASL/JanineTemplates/SANE-QC_GroundTruth.nii.gz';

pGM=xASL_io_Nifti2Im(PathGM);
pWM=xASL_io_Nifti2Im(PathWM);
pCSF=xASL_io_Nifti2Im(PathCSF);
Mask = xASL_io_Nifti2Im(PathMask);

% Verified that min & max is 0 & 1 for each

NewIm = zeros(size(pGM));
pGMmask = pGM>0.25;
pWMmask = pWM>0.05;
% pCSFmask = pCSF>0.05;

%NewIm(pCSFmask) = 1;
NewIm(pWMmask) = 1;
NewIm(pGMmask) = 2;

% imshow3D([pGM.*3 pWM.*3 pCSF.*3 NewIm])

xASL_io_SaveNifti(PathMask, PathNew, NewIm);