%% Fix image

ROOTdir         = 'C:\Backup\ASL\PreDiva\analysis';
SubjectList     = {'231070_1'};


    % Admin
    MapsDir             = 'C:\ExploreASL\Maps';
    LockDir             = fullfile(ROOTdir,'lock');
    StructLockDir       = fullfile(LockDir,'Struct');
    LongRegLockDir      = fullfile(LockDir,'LongReg_T1');
    TemplateDir         = fullfile(MapsDir,'Templates');
    BrainMaskIM         = fullfile(TemplateDir,'RegistrationMask.nii');
    wBrainMaskIM        = fullfile(TemplateDir,'wRegistrationMask.nii');
    DeleteListNative    = {'c1T1.nii' 'c2T1.nii' 'catreport_T1.pdf' 'LongReg_y_T1.nii' 'WMH_SEGM.nii' 'y_T1.nii'};

    SteepnessFactor     = 5;
    InitialDilations    = 5;

for iS=1:length(SubjectList)

    InDir           = fullfile(ROOTdir,SubjectList{iS});

    FLAIRname     = fullfile(InDir,'FLAIR.nii');
    T1wname       = fullfile(InDir,'T1.nii');
    ASLname       = fullfile(InDir,'ASL_1','ASL4D.nii');
    M0name        = fullfile(InDir,'ASL_1','M0.nii');
    FLAIRoriName  = fullfile(InDir,'FLAIR_ORI_ORI.nii');
    T1woriName    = fullfile(InDir,'T1w_ORI_ORI.nii');
    FLAIRoriName1 = fullfile(InDir,'FLAIR_ORI.nii');
    T1woriName1   = fullfile(InDir,'T1_ORI.nii');

    % rename etc, delete wrong files
    for iD=1:length(DeleteListNative)
        DelFile     = fullfile(InDir,DeleteListNative{iD});
        if exist(DelFile,'file')
            delete(DelFile);
        end
    end

    if      exist(FLAIRname,'file') && exist(FLAIRoriName1,'file') && ~exist(FLAIRoriName,'file')
            xASL_Move(FLAIRoriName1,FLAIRname,1);
    elseif  exist(FLAIRname,'file') && exist(FLAIRoriName,'file')
            xASL_Move(FLAIRoriName,FLAIRname,1);
    end
    if      exist(T1wname,'file') && exist(T1woriName1,'file') && ~exist(T1woriName,'file')
            xASL_Move(T1woriName1,T1wname,1);
    elseif  exist(T1wname,'file') && exist(T1woriName,'file')
            xASL_Move(T1woriName,T1wname,1);
    end
    if  exist(FLAIRoriName,'file'); delete(FLAIRoriName); end
    if  exist(T1woriName,'file'); delete(T1wname); end

    % Delete lock-files
    SubjLockDir     = fullfile(StructLockDir, SubjectList{iS},'Struct_module');
    Flist           = xASL_adm_GetFileList(SubjLockDir,'^.*\.status$','FPList',[0 Inf]);
    for iF=1:length(Flist); delete(Flist{iF}); end

    clear SubjectLR
    % Delete LongReg lock files, for 10 time points
    if  strcmp(SubjectList{iS}(end-1),'_')
        for iLR=1:9
            SubjectLR{iLR}  = [SubjectList{iS}(1:end-2) '_' num2str(iLR)];
        end
    else    SubjectLR{1}    = SubjectList{iS};
    end

    for iLR=1:length(SubjectLR)
        SubjLongRegLockDir     = fullfile(LongRegLockDir, SubjectLR{iLR},'LongReg_module');
        if  isdir(SubjLongRegLockDir)
            Flist           = xASL_adm_GetFileList(SubjLongRegLockDir,'^.*\.status$','FPList',[0 Inf]);
            for iF=1:length(Flist); delete(Flist{iF}); end
        end
    end


    RestoreOrientation(FLAIRname);
    RestoreOrientation(T1wname);
    RestoreOrientation(ASLname);
    RestoreOrientation(M0name);

end

parfor iS=1:length(SubjectList)

    InDir           = fullfile(ROOTdir,SubjectList{iS});

    FLAIRname     = fullfile(InDir,'FLAIR.nii');
    T1wname       = fullfile(InDir,'T1.nii');
    ASLname       = fullfile(InDir,'ASL_1','ASL4D.nii');
    M0name        = fullfile(InDir,'ASL_1','M0.nii');
    FLAIRoriName  = fullfile(InDir,'FLAIR_ORI_ORI.nii');
    T1woriName    = fullfile(InDir,'T1w_ORI_ORI.nii');
    FLAIRoriName1 = fullfile(InDir,'FLAIR_ORI.nii');
    T1woriName1   = fullfile(InDir,'T1_ORI.nii');

    %% Mask FLAIR
    SourceIM    = fullfile(TemplateDir,'Cmp_rFLAIR.nii');
    ReferenceIM = FLAIRname;
    ResampleIM  = BrainMaskIM;
    SmoothingSrc= 0;
    SmoothingRef= 8;
    OldNormalizeWrapper(SourceIM , ReferenceIM, ResampleIM, SmoothingSrc, SmoothingRef );

    NewMaskIM       = fullfile(InDir,'MaskFLAIR.nii');

    xASL_Move(wBrainMaskIM,NewMaskIM,1);

%     BrainMaskProbMap( NewMaskIM, NewMaskIM, SteepnessFactor, InitialDilations );

    xASL_Copy(FLAIRname,FLAIRoriName);

    IM          = xASL_io_ReadNifti(FLAIRname);
    IM          = IM.dat(:,:,:);
    IMmask      = xASL_io_ReadNifti(NewMaskIM);
    IMmask      = IMmask.dat(:,:,:);
    IM          = IMmask.*IM;
    xASL_io_SaveNifti(FLAIRname,FLAIRname,IM);

    delete(NewMaskIM);

    %% Mask T1w
    SourceIM    = fullfile(TemplateDir,'Cmp_rT1.nii');
    ReferenceIM = T1wname;
    ResampleIM  = BrainMaskIM;
    SmoothingSrc= 0;
    SmoothingRef= 8;
    OldNormalizeWrapper(SourceIM , ReferenceIM, ResampleIM, SmoothingSrc, SmoothingRef );

    NewMaskIM       = fullfile(InDir,'MaskT1w.nii');

    xASL_Move(wBrainMaskIM,NewMaskIM,1);

%     BrainMaskProbMap( NewMaskIM, NewMaskIM, SteepnessFactor, InitialDilations );

    xASL_Copy(T1wname,T1woriName);

    IM          = xASL_io_ReadNifti(T1wname);
    IM          = IM.dat(:,:,:);
    IMmask      = xASL_io_ReadNifti(NewMaskIM);
    IMmask      = IMmask.dat(:,:,:);
    IM          = IMmask.*IM;
    xASL_io_SaveNifti(T1wname,T1wname,IM);

    delete(NewMaskIM);


end
