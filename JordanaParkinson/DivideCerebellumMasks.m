%% Divide cerebellum mask in 2 halfs

ORImaskName     = 'C:\ASL_pipeline_HJ\Maps\rcerebellum_ROI_FNIRT_25threshold.nii';
ORImaskim       = xASL_io_ReadNifti(ORImaskName);
ORImaskim       = ORImaskim.dat(:,:,:);

ORImaskLeft             = ORImaskim;
ORImaskRight            = ORImaskim;

ORImaskLeft(  1: 60,:,:)   = 0;
ORImaskRight(62:121,:,:)   = 0;

dip_image([ORImaskim ORImaskLeft ORImaskRight]);

xASL_io_SaveNifti(ORImaskName,'C:\ASL_pipeline_HJ\Maps\rcerebellum_Left.nii' ,ORImaskLeft,1,8);
xASL_io_SaveNifti(ORImaskName,'C:\ASL_pipeline_HJ\Maps\rcerebellum_Right.nii',ORImaskRight,1,8);
