%% Jordana re-open 24 & 25

im24name    = 'C:\Backup\ASL\JordanaNifti\24_1\T1.nii';
im24im    = xASL_io_ReadNifti(im24name);

im24im.mat  = im24im.mat0;

create(im24im);
clear im24im
