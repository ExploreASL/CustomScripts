%% AFIVASC sorting script:  sorted by Moderate and Vigorous exercise

% In this case: 
% ses-1 = ASL1 (basal), ses-2 = ASL2 (after exercise), ses-3 =ASL3 (after resting)
% run-1 = 1800ms , run-2 = 2000ms (PLD)
%
% EX:
% rawdata:
%
% Moderate:sub-0010_1/ses-1/perf/sub-0010_ses-1_run-1_ASL.json
%                          /anat/sub-0010_ses-1_run-1_T1.json
%                    /ses-2/perf/sub-0010_ses-2_run-1_ASL.json
%                          /anat/sub-0010_ses-2_run-1_T1.json
%                    /ses-3/perf/sub-0010_ses-3_run-1_ASL.json
%                          /anat/sub-0010_ses-3_run-1_T1.json
% Vigorous:sub-0010_2/ses-1/ etc
%

ExploreASL_Master('',0);

% == Change Ddir for Moderate or Vigorous exercise == %

Odir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLETE/sourcedata_Moderate'; 
Ddir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLETE/rawdata_1';
%Odir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLETE/sourcedata_Vigorous';
 
xASL_adm_CreateDir(Ddir);

Runs = xASL_adm_GetFileList(Odir, '^R1_', 'FPList',[0 Inf], true); % R1 for Moderate
%Runs = xASL_adm_GetFileList(Odir, '^R2_', 'FPList',[0 Inf], true); % R2 for Vigorous 

for iR=1:length(Runs)
   %== Run Number (1800 or 2000) -> session1 or session2 ==%
    if ~isempty (regexp(Runs{iR},'1800','ONCE'))
        run = 'run-1';
    elseif ~isempty (regexp(Runs{iR},'2000','ONCE'))
        run= 'run-2';
    end
    
    %=== Copy T1, FLAIR, and ASL for rawdata folder ===%
    SubjsDir=fullfile(Runs{iR},'analysis');
    
    ASLJsonPath=xASL_adm_GetFileList(SubjsDir, '(.json)','FPList',[0 Inf]);
    ASLJson=fullfile(ASLJsonPath{1});
    
    SubjList=xASL_adm_GetFileList(SubjsDir, '^Sub-', 'FPList',[0 Inf], true);
    for iS=1:length(SubjList)
        %== Create a directory with the name of the subject ==%
        [~, Name] = fileparts(SubjList{iS});
        %Name = regexprep(Name,'_1','_2'); %%%%%%%% _2 ONLY FOR VIGOROUS %%%%%%%%
        sub = regexprep(Name,'S','s'); % sub-001 instead of Sub-001
        
        DestSubjDir = fullfile(Ddir, sub); %...rawdata/sub-xxx
        xASL_adm_CreateDir(DestSubjDir);
        
        %%% From each subject we want: ASL.json/nii.gz, T1.json/nii.gz, FLAIR.nii.gz
        
        % ==== ASL ==== %
        ASLfolderList=xASL_adm_GetFileList(SubjList{iS}, '^ASL_\d{1}','FPListRec',[0 Inf],true); %true for directories
        
        for iASL=1:length(ASLfolderList)
            [~, ASLn] = fileparts(ASLfolderList{iASL});
            Session = ASLn(5);  %5th position of ASL_n is always the number of the session
            ses = ['ses-',Session];
            DestDir=fullfile(DestSubjDir,ses,'perf'); %ASL folders -> perf folder
            xASL_adm_CreateDir(DestDir);
            
            ASLList=xASL_adm_GetFileList(ASLfolderList{iASL}, '(.json)|(.nii.gz)','FPList',[0 Inf]);
            
            for i=1:length(ASLList)
                if ~isempty(regexp(ASLList{i},'_bold','ONCE'))
                    xASL_delete(ASLList{i})
                elseif ~isempty(regexp(ASLList{i},'.json','ONCE'))
                    DestFile = fullfile(DestDir, [sub, '_', ses, '_',run,'_','asl.json']);
                    xASL_Copy(ASLJson,DestFile, true);
                else
                    DestFile = fullfile(DestDir, [sub, '_', ses, '_',run,'_','asl.nii.gz']);
                    xASL_Copy(ASLList{i}, DestFile, true); %Copy the file to BIDS directory
                end
                
            end
        end
        
        
        % ==== T1 and FLAIR ==== %ONLY FOR RUN_1 (for Run_2 is the same)
        T1FLAIRList=xASL_adm_GetFileList(SubjList{iS}, '(MPRAGE)|(dark_fluid_sag_fs)', 'FPListRec',[0 Inf],false); %false for files

        for iTF=1:length(T1FLAIRList)
            
            DestDir=fullfile(DestSubjDir,ses,'anat'); %T1 or FLAIR -> anat folder
            xASL_adm_CreateDir(DestDir);
            
            [~, Scan] = fileparts(T1FLAIRList{iTF});
            if ~isempty(regexp(Scan,'MPRAGE','ONCE')) %MPRAGE = T1
                if ~isempty(regexp(T1FLAIRList{iTF},'.json','ONCE'))
                    DestFile1 = fullfile(DestSubjDir,'ses-1','anat', [sub, '_', 'T1w.json']);  %same T1 for the three sessions
                    DestFile2 = fullfile(DestSubjDir,'ses-2','anat', [sub, '_', 'T1w.json']);
                    DestFile3 = fullfile(DestSubjDir,'ses-3','anat', [sub, '_', 'T1w.json']);
                else
                    DestFile1 = fullfile(DestSubjDir,'ses-1','anat', [sub, '_', 'T1w.nii.gz']);
                    DestFile2 = fullfile(DestSubjDir,'ses-2','anat', [sub, '_', 'T1w.nii.gz']);
                    DestFile3 = fullfile(DestSubjDir,'ses-3','anat', [sub, '_', 'T1w.nii.gz']);
                end
            elseif ~isempty(regexp(Scan,'dark_fluid','ONCE')) %dark_fluid = FLAIR
                if ~isempty(regexp(T1FLAIRList{iTF},'.json','ONCE'))
                    DestFile1 = fullfile(DestSubjDir,'ses-1','anat', [sub, '_', 'FLAIR.json']); %same FLAIR for the three sessions
                    DestFile2 = fullfile(DestSubjDir,'ses-2','anat', [sub, '_', 'FLAIR.json']);
                    DestFile3 = fullfile(DestSubjDir,'ses-3','anat', [sub, '_', 'FLAIR.json']);
                else
                    DestFile1 = fullfile(DestSubjDir,'ses-1','anat', [sub, '_', 'FLAIR.nii.gz']);
                    DestFile2 = fullfile(DestSubjDir,'ses-2','anat', [sub, '_', 'FLAIR.nii.gz']);
                    DestFile3 = fullfile(DestSubjDir,'ses-3','anat', [sub, '_', 'FLAIR.nii.gz']);
                end
                
            end
            
            xASL_Copy(T1FLAIRList{iTF}, DestFile1, true); %Copy the file to BIDS directory
            xASL_Copy(T1FLAIRList{iTF}, DestFile2, true); 
            xASL_Copy(T1FLAIRList{iTF}, DestFile3, true);
        end
    end
end

            