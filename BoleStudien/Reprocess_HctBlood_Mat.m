iCohort     = 5;
Cohort      = x.S.SetsID(:,iCohort);
CountN      = 0;
List        = '';

for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects);
    matPath     = fullfile(x.D.ROOT,x.SUBJECTS{iS},'ASL_1','ASL4D_parms.mat');
    if ~exist(matPath,'file')
        error('didnt exist');
    end
    
    mat     = load(matPath,'parms');
    parms   = mat.parms;
    
    %% Insert Cohort value
    parms.Cohort    = x.S.SetsOptions{iCohort}{Cohort(iS,1)};
    
    %% Get hematocrit value
    switch Cohort(iS,1)
        case 1
            HctShouldBe     = 0.50;
        case 2
            HctShouldBe     = 0.44;
        case 3
            HctShouldBe     = 0.42;
    end
    
    %% If didnt have hematocrit value, re-quantify, insert hct value, otherwise check if it was processed correctly
    if ~isfield(parms,'hematocrit')
        LockDir     = fullfile(x.D.ROOT,'lock','xASL_module_ASL',x.SUBJECTS{iS},'xASL_module_ASL_ASL_1');
        xASL_delete(fullfile(LockDir,'005_quantification.status'));
        xASL_delete(fullfile(LockDir,'999_ready.status'));
        parms.hematocrit    = HctShouldBe;
        CountN              = CountN+1;
        List{end+1}         = x.SUBJECTS{iS};
    else
        if  parms.hematocrit~=HctShouldBe
            error('parms.hematocrit & HctShouldBe were not equal');
        end
    end    
    
    save(matPath,'parms');
end


%% Redo processing for previous-users

iCohort     = 5;
Cohort      = x.S.SetsID(:,iCohort);
CountN      = 0;
List        = '';

for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects);
    if  Cohort(iS,1)==2 % Previous user
        LockDir     = fullfile(x.D.ROOT,'lock','xASL_module_ASL',x.SUBJECTS{iS},'xASL_module_ASL_ASL_1');
        xASL_delete(fullfile(LockDir,'004_realign_reslice_M0.status'));
        xASL_delete(fullfile(LockDir,'005_quantification.status'));
        xASL_delete(fullfile(LockDir,'999_ready.status'));
        CountN              = CountN+1;
        List{end+1}         = x.SUBJECTS{iS};
    end
end
