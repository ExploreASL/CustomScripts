%% Restore orientation for OASIS for ExploreASL registration comparison

for iSubject=1:x.nSubjects
    xASL_TrackProgress(iSubject,x.nSubjects);
    SubjectDir = fullfile(x.D.ROOT,x.SUBJECTS{iSubject});
    % 1) Set original orientation to all T1w images
    Path{1} = fullfile(SubjectDir, 'T1.nii');
    Path{2} = fullfile(SubjectDir, 'c1T1.nii');
    Path{3} = fullfile(SubjectDir, 'c2T1.nii');
    Path{4} = fullfile(SubjectDir, 'c3T1.nii');
    
    for ii=1:4
        nii{ii} = xASL_io_ReadNifti(Path{ii});
    end
    
    NewMat = nii{1}.mat0;
    for ii=1:4
        nii{ii}.mat = NewMat;
        nii{ii}.mat0 = NewMat;
        create(nii{ii});
    end
    
    % 2) Restore orientation of ASL NIFTI
    Path_ASL = fullfile(SubjectDir, 'ASL_1' ,'ASL4D.nii');
    xASL_im_RestoreOrientation(Path_ASL);
    
end

% Then now run only 1st linear registration T1w & apply on all