%% Create LeftRight atlas
ExploreASL_Master('',0);

VascIm          = xASL_io_Nifti2Im('C:\ExploreASL\Maps\Atlases\VascularTerritories\LabelingTerritories.nii');

LeftRightIm             = zeros(size(VascIm),'uint8');
LeftRightIm(1:61,:,:)   = 2;
LeftRightIm(62:121,:,:) = 1;

xASL_io_SaveNifti(x.D.ResliceRef, fullfile(x.D.AtlasDir,'LeftRight.nii'), LeftRightIm, 16, 0);
