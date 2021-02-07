function create_slice_gradient_ASL_VENDORCOMPARISON(x)
% create_slice_gradient_ASL
%
%
% 1    Create slice gradient in same space as input file
% 2    Reslice slice gradient to MNI (using existing ASL matrix changes from e.g. registration to MNI, motion correction, registration to GM)
% 3    Creating average slice gradient
%
% BACKGROUND INFORMATION
% When a 2D readout is used with ASL, post-label delay and hence T1 decay will be dependent on slice timing
% Therefore, quantification part needs slice reference to quantify per slice and correct for effective post-label delay differences
%
% This function uses exact same ASL matrix changes that occurred due to registration to MNI, motion correction and registration to T1
%
% Script dependencies: SPM8
%
% HJ Mutsaerts, ExploreASL 2016

%% Administration

[input_dir_ASL file ext]    = fileparts(x.despiked_raw_asl);

[path_dummy x.P.SessionID dummy] 	= fileparts(input_dir_ASL);
[path_dummy x.P.SubjectID dummy] 	= fileparts(path_dummy);
clear dummy path_dummy

input_file                  = [file ext];
output_file                 = fullfile(input_dir_ASL,'slice_gradient.nii');
r_output_file               = fullfile(input_dir_ASL,'rslice_gradient.nii');
r2_output_file              = fullfile(input_dir_ASL,'r2slice_gradient.nii');
outputFileDartel            = fullfile(x.D.PopDir,['slice_gradient_' x.P.SubjectID '_' x.P.SessionID '.nii']);
reg_file                    = fullfile(input_dir_ASL,'rslice_gradient.nii');

%% 1    Create slice gradient in same space as input file
temp            = xASL_nifti(x.despiked_raw_asl);
temp_im         = temp.dat(:,:,:,:);
dim             = size(temp_im);

for ii=1:dim(3)
    new_im(1:dim(1),1:dim(2),ii,1:dim(4))    = ii;
end

% 16 bit keeps integers of distinct slices, which is OK because numbers
% only identify slices (hence integer, e.g. 1-17)
% We will average only control and label & then apply for each pair separately
% However, it doesn't show all slices, therefore use gradient instead
xASL_io_SaveNifti(x.despiked_raw_asl,output_file,new_im,dim(4),16);

clear temp temp_im dim new_im

%% 2    Apply motion correction

clear matlabbatch
tnii        = xASL_nifti(output_file);
nFrames     = size(tnii.dat,4);

for iFrame=1:nFrames
    matlabbatch{1}.spm.spatial.realign.write.data{iFrame,1} = [output_file ',' num2str(iFrame)];
end

matlabbatch{1}.spm.spatial.realign.write.roptions.which     = [2 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.interp    = 4;
matlabbatch{1}.spm.spatial.realign.write.roptions.wrap      = [0 0 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.mask      = 1;
matlabbatch{1}.spm.spatial.realign.write.roptions.prefix    = 'r';

spm_jobman('run',matlabbatch);
clear matlabbatch

clear tnii nFrames

%% 3    Average slice gradient
tnii    = xASL_nifti( r_output_file );
IM      = xASL_stat_MeanNan(tnii.dat(:,:,:,:),4);

% This should be single precision, since otherwise precision is lost in
% averaging and subsequent reslicing step
xASL_io_SaveNifti(x.despiked_raw_asl,r2_output_file,IM,1,32);

clear tnii IM

%% 4    Reslice slice gradient to MNI (using existing ASL matrix changes from e.g. registration to MNI, motion correction, registration to GM)

OUTPUTname      = 'slice_gradient';

NativeDeformations_VENDORCOMPARISON(x,x.P.SubjectID,r2_output_file,OUTPUTname);


% Housekeeping
xASL_adm_DeleteFilePair(output_file, 'mat');
xASL_adm_DeleteFilePair(r_output_file, 'mat');
xASL_adm_DeleteFilePair(r2_output_file, 'mat');

end
