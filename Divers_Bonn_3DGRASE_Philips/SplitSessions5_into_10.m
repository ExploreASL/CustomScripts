%% Divers split 5 sessions data into 10 sessions

ROOT    = 'C:\Backup\ASL\Divers_Bonn\analysis_10_DataPoints';

%% Clone data into twice sessions
for iS=1:x.nSubjects
    SubjDir     = fullfile(ROOT,x.SUBJECTS{iS});

    OriDir      = fullfile(SubjDir,'ASL_5');
    DestDir     = fullfile(SubjDir,'ASL_10');
    DestDir2    = fullfile(SubjDir,'ASL_09');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_4');
    DestDir     = fullfile(SubjDir,'ASL_08');
    DestDir2    = fullfile(SubjDir,'ASL_07');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_3');
    DestDir     = fullfile(SubjDir,'ASL_06');
    DestDir2    = fullfile(SubjDir,'ASL_05');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_2');
    DestDir     = fullfile(SubjDir,'ASL_04');
    DestDir2    = fullfile(SubjDir,'ASL_03');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_1');
    DestDir     = fullfile(SubjDir,'ASL_02');
    DestDir2    = fullfile(SubjDir,'ASL_01');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);
end

%% Split
for iS=1:x.nSubjects
    SubjDir     = fullfile(ROOT,x.SUBJECTS{iS});
    ASLdirs     = xASL_adm_GetFsList(SubjDir, '^ASL_\d{2}$',1);

    for iA=1:10
        ASLfile = fullfile(SubjDir, ASLdirs{iA},'ASL4D.nii');
        ASLim   = xASL_io_Nifti2Im(ASLfile);

        ASL1    = ASLim(:,:,:,1:2);
        ASL2    = ASLim(:,:,:,3:4);

        if  (iA/2)==round(iA/2) % if even
            xASL_io_SaveNifti(ASLfile,ASLfile,ASL2);
        else
            xASL_io_SaveNifti(ASLfile,ASLfile,ASL1);
        end

        DelList  = {'ASL4D.mat','ASL_module.log','mean_control.nii','rp_ASL4D.txt','slice_gradient.mat','slice_gradient.nii','mean_PWI_Clipped.nii','PWI.nii'};

        for iD=1:length(DelList)
            DelFile     = fullfile(SubjDir, ASLdirs{iA},DelList{iD});
            if exist(DelFile,'file')
                delete(DelFile);
            end
        end
    end
end

%% Manage lock files
%% First all lock files were deleted except for 0035_PV_prepare & 004_reslice_M0
for iS=1:x.nSubjects
    SubjDir     = fullfile(ROOT,'lock','ASL',x.SUBJECTS{iS});

    OriDir      = fullfile(SubjDir,'ASL_module_ASL_5');
    DestDir     = fullfile(SubjDir,'ASL_module_ASL_10');
    DestDir2    = fullfile(SubjDir,'ASL_module_ASL_09');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);


    OriDir      = fullfile(SubjDir,'ASL_module_ASL_4');
    DestDir     = fullfile(SubjDir,'ASL_module_ASL_08');
    DestDir2    = fullfile(SubjDir,'ASL_module_ASL_07');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_module_ASL_3');
    DestDir     = fullfile(SubjDir,'ASL_module_ASL_06');
    DestDir2    = fullfile(SubjDir,'ASL_module_ASL_05');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_module_ASL_2');
    DestDir     = fullfile(SubjDir,'ASL_module_ASL_04');
    DestDir2    = fullfile(SubjDir,'ASL_module_ASL_03');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = fullfile(SubjDir,'ASL_module_ASL_1');
    DestDir     = fullfile(SubjDir,'ASL_module_ASL_02');
    DestDir2    = fullfile(SubjDir,'ASL_module_ASL_01');

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);
end

%% Manage MNI M0 files
for iS=1:x.nSubjects
    StartName   = fullfile(x.D.PopDir,['M0_' x.SUBJECTS{iS}]);

    OriDir      = [StartName '_ASL_5.nii'];
    DestDir     = [StartName '_ASL_10.nii'];
    DestDir2    = [StartName '_ASL_09.nii'];

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = [StartName '_ASL_4.nii'];
    DestDir     = [StartName '_ASL_08.nii'];
    DestDir2    = [StartName '_ASL_07.nii'];

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);


    OriDir      = [StartName '_ASL_3.nii'];
    DestDir     = [StartName '_ASL_06.nii'];
    DestDir2    = [StartName '_ASL_05.nii'];

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);


    OriDir      = [StartName '_ASL_2.nii'];
    DestDir     = [StartName '_ASL_04.nii'];
    DestDir2    = [StartName '_ASL_03.nii'];

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);

    OriDir      = [StartName '_ASL_1.nii'];
    DestDir     = [StartName '_ASL_02.nii'];
    DestDir2    = [StartName '_ASL_01.nii'];

    xASL_Move(OriDir,DestDir);
    xASL_Copy(DestDir,DestDir2);
end
