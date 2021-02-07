%% Visualize registration PET

for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects);
    x.T1_PETREGDIR    = fullfile(x.D.PopDir, 'T1_PETReg');
    x.P.SubjectID              = x.SUBJECTS{iS};
    visual_registration_check_MNI_1_5(x.D.PopDir, ['^R1_' x.P.SubjectID '\.(nii|nii\.gz)$'] ,['^rc2' x.P.STRUCT '_' x.P.SubjectID '\.(nii|nii\.gz)$'], x.T1_PETREGDIR,0.5,1);
end

% Redo: 515, 516 ->
%% Tweak template
tFile       = 'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite.nii';
tIM         = xASL_io_Nifti2Im(tFile);
tIM         = tIM.*single(tIM>0.17);
tIM(tIM<0)  = 0;
tMask       = xASL_io_Nifti2Im('C:\ExploreASL\Maps\Templates\RegistrationMask.nii');
tIM         = tIM.*tMask;

xASL_io_SaveNifti(tFile,tFile,tIM);

%% Create gradual mask from template
tFile       = 'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite.nii';
tMask       = 'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite_Mask.nii';
tIM         = logical(xASL_io_Nifti2Im(tFile)>0.2);
tIM(:,:,end-11:end)     = 0;

TrackN      = 1;
BuildIM     = single(tIM);
NewIM       = tIM;

% Dilate
while  sum(NewIM(:))<numel(NewIM(:))
    CurrIM      = logical(BuildIM);
    NewIM       = imdilate(logical(CurrIM),strel('sphere',1) );
    DiffIM      = NewIM-CurrIM;
    TrackN      = (TrackN-0.025);

    BuildIM     = BuildIM+TrackN.*DiffIM;
end
BuildIM(BuildIM<0)  = 0;

xASL_io_SaveNifti(tFile,tMask,BuildIM,32);
