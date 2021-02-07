tIM=xASL_io_Nifti2Im('rbrainmask.nii');
tIM=single(tIM>0.5);
Rate = 1.15;

while sum(sum(sum(tIM==0)))>0
    NewFactor = min(nonzeros(tIM))/Rate;
    NewIm = xASL_im_DilateErodeFull(tIM>0, 'dilate', xASL_im_DilateErodeSphere(1));
    tIM(logical(NewIm - (tIM>0))) = NewFactor;
end

dip_image([tIM tIM.^0.5])

dip_image(tIM)

xASL_io_SaveNifti('rbrainmask.nii', 'rbrainmask_prob.nii', tIM, [], false);
