function xASL_wrp_CreateSliceGradient(x)
% xASL_wrp_CreateSliceGradient
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
% Script dependencies: SPM12
%
% HJ Mutsaerts, ExploreASL 2016

%% Administ

x.D.ROOT;
x.SUBJECTS;
x.D.PopDir;

for iSubject=1:x.nSubjects
    ASLdir = fullfile(x.D.ROOT,x.SUBJECTS{iSubject},'ASL_1');
    Path_SliceGradient = fullfile(ASLdir,'SliceGradient.nii');
    Path_SliceGradient_mat = fullfile(ASLdir,'SliceGradient.mat');
    Pop_Path_SliceGradient = fullfile(x.D.PopDir, ['SliceGradient_' x.SUBJECTS{iSubject} '_ASL_1.nii']);
    Path_ASL4D = fullfile(ASLdir,'ASL4D.nii');
    Path_y_ASL = fullfile(x.D.ROOT,x.SUBJECTS{iSubject},'y_T1.nii');

    %% ------------------------------------------------------------------------------------
    %% 1    Create slice gradient in same space as input file
    tNII = xASL_io_ReadNifti(Path_ASL4D);
    dim = size(tNII.dat(:,:,:,:,:,:,:,:,:));
    dim = dim(1:3);
    SGim = zeros(dim);

    for iSlice=1:dim(3)
        SGim(:,:,iSlice) = iSlice;
    end

    % We skip motion correction here, to avoid edge artifacts
    xASL_io_SaveNifti(Path_ASL4D,Path_SliceGradient,SGim,8,0);
    xASL_delete(Path_SliceGradient_mat);

    %% ------------------------------------------------------------------------------------
    %%     Reslice slice gradient to MNI (using existing ASL matrix changes from e.g. registration to MNI, motion correction, registration to GM)
    xASL_spm_deformations([], Path_SliceGradient, Pop_Path_SliceGradient,0,[], [], Path_y_ASL); % nearest neighbor
end
