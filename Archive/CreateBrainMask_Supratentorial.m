%% Create new BrainMask without cerebellum & without brainstem
BmaskFile = fullfile(x.D.TemplateDir, 'brainmask_SPM.nii');
SavePath = fullfile(x.D.TemplateDir, 'brainmask_supratentorial.nii');
Hammer = fullfile(x.D.AtlasDir, 'Hammers.nii');

Bmask = xASL_io_Nifti2Im(BmaskFile);
Hammer = xASL_io_Nifti2Im(Hammer);
ThrowAway = Hammer==9 | Hammer==10;
ThrowAway = xASL_im_DilateErodeFull(ThrowAway, 'dilate', xASL_im_DilateErodeSphere(3));
% dip_image(Bmask+ThrowAway)
Bmask(:,:,1:12) = 0;
Bmask(ThrowAway) = 0;
xASL_io_SaveNifti(BmaskFile, SavePath, Bmask, [], 0);
