clear matlabbatch

FILE_IS     = 'C:\Backup\ASL\GENFI\SmoothExercise\2DEPI\mean_PWI_Clipped.nii';

matlabbatch{1}.spm.spatial.smooth.data = {[FILE_IS ',1']};
matlabbatch{1}.spm.spatial.smooth.fwhm = [1 1 1];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

spm_jobman('run',matlabbatch);


NIIfile     = 'C:\Backup\ASL\GENFI\SmoothExercise\RegEx\mean_PWI_Clipped.nii';
IM          = xASL_nifti(NIIfile);
IM          = IM.dat(:,:,:);
IM          = ClipVesselImage( IM,0.95);
IM(IM<0)    = 0;
IM          = IM./ max(IM(:));
xASL_io_SaveNifti(NIIfile, NIIfile, IM);
