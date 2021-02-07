tFile   = 'C:\Backup\ASL\TwinExample\twins_ASL\EMI_332\PET\EMI_332_R1.nii';
tIM     = xASL_io_Nifti2Im(tFile);
tIM(:,:,[1:5 90-13:90])  = 0;
xASL_io_SaveNifti(tFile,tFile,tIM);
