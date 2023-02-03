%% AFIVASC sorting script:  rearranging the rawdata

% In this case: 
% (BIDS format)
% ses-1 = Moderate exercise (day1), ses-2 = Vigorous exercise(day2)
% run-1 = ASL1 (1800ms), run-2 = ASL1 (2000ms), run3 = ASL2 (1800ms)
% run-4 = ASL2 (2000ms), run-5 = ASL3 (1800ms), run6 = ASL3 (2000ms)
%
% EX:
% rawdata:
%
% sub-001/ses-1/perf/sub-001_ses-1_run-1_asl.json   
%                    sub-001_ses-1_run-1_asl.nii.gz
%                    sub-001_ses-1_run-1_aslcontext.tsv  
%                    sub-001_ses-1_run-2_asl.json   
%                    sub-001_ses-1_run-2_asl.nii.gz
%                    sub-001_ses-1_run-2_aslcontext.tsv
%                    sub-001_ses-1_run-3_asl.json   
%                    sub-001_ses-1_run-3_asl.nii.gz
%                    sub-001_ses-1_run-3_aslcontext.tsv
%                    (.....)
%              /anat/sub-001_ses-1_T1w.json
%                   /sub-001_ses-1_T1w.nii.gz 
%                   /sub-001_ses-1_FLAIR.json
%                   /sub-001_ses-1_FLAIR.nii.     
%                      
%        /ses-2/perf/sub-001_ses-2_run-1_ASL.json
%                    sub-001_ses-2_run-2_ASL.json
%                    sub-001_ses-2_run-3_ASL.json
%                    sub-001_ses-2_run-4_ASL.json
%                    sub-001_ses-1_run-5_ASL.json
%                    sub-010_ses-1_run-6_ASL.json
%              /anat/sub-010_ses-1_T1.json
%                   /sub-010_ses-1_T1.nii.gz
%                   /sub-010_ses-1_FLAIR.json
%                   /sub-010_ses-1_FLAIR.nii.gz
% sub-010/ses-1/ etc
%
% !!!!! BEFORE RUNNING, be sure that the file AFIVASC_ACUTE_COMPLETE/rawdata_1/aslcontext.tsv' exists !!!!!!!!!!!

ExploreASL_Master('',0);

% rootDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLETE/';
% Odir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLEASLfilenameTE/rawdata_1';
% Ddir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLETE/rawdata';

rootDir='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/Correct_n11';
Odir='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/Correct_n11/rawdata_1';
Ddir='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/Correct_n11/rawdata';

xASL_adm_CreateDir(Ddir);

SubList = xASL_adm_GetFileList(Odir, '^(.)', 'FPList',[0 Inf], true); 

for iSub=1:length(SubList)
    
    [~, SubNum] = fileparts(SubList{iSub});
    ses = ['ses-',SubNum(end)]; %ses-1 if sub-001_1 and ses-2 if sub-001_2
    
    if ~isempty(regexp(SubNum,'sub-\d{4}','ONCE')) %if sub-0010 we want sub-010
        [StartI, EndI] = regexp(SubNum,'\d{4}');
        SubN = SubNum(StartI+1:EndI);
        sub= ['sub-',SubN];
    else 
        [StartI, EndI] = regexp(SubNum,'\d{3}');
        SubN = SubNum(StartI:EndI);
        sub= ['sub-',SubN];
    end
    
    SesList = xASL_adm_GetFileList(SubList{iSub}, '^ses-', 'FPList',[0 Inf], true); 

    for iSes=1:length(SesList)
        [~, SesNum] = fileparts(SesList{iSes});
        
        %==ASL==%
        ASLList = xASL_adm_GetFileList(SesList{iSes}, '(asl.json)|(asl.nii.gz)', 'FPListRec',[0 Inf], false);
        for iA=1:length(ASLList)
            [dir, ASLfilename,ext] = fileparts(ASLList{iA});
            
            %Correcting ASL.jsons
            if strcmp(ext,'.json')
                jsonASL = xASL_io_ReadJson(ASLList{iA});
                
                %We need PostLabelingDelay, M0Type, LabelingDuration, ArterialSpinLabelingType=PCASL
                
                jsonASL.ArterialSpinLabelingType='PCASL';
                jsonASL.M0Type='Absent';
                jsonASL.LabelingDuration=1.800;
                jsonASL.BackgroundSuppression=false;
                %jsonASL.BackgroundSuppressionNumberPulses=2;
                %jsonASL=rmfield(jsonASL,'BackgroundSuppressionNumberPulses');
%                 jsonASL=rmfield(jsonASL,'M0');
                jsonASL.RepetitionTimePreparation=5.6;
                jsonASL.AcquisitionVoxelSize=[3.7 3.7 3.9]; %this is from MRIcron, officially is 3.8 3.8 4.0
                jsonASL.VascularCrushing=false;
                
                if ~isempty(regexp(ASLfilename,'_run-1','ONCE')) 
                    jsonASL.PostLabelingDelay=1.800;
                elseif ~isempty(regexp(ASLfilename,'_run-2','ONCE'))
                    jsonASL.PostLabelingDelay=2.000; %run-2
                end
                
                xASL_io_WriteJson(ASLList{iA} ,jsonASL);
            end
            
            if ~isempty(regexp(ASLfilename,'ses-1_run-1','ONCE')) %run-1
                DestFile = fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-1_','asl', ext]);
                DestAslcontext= fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-1_','aslcontext.tsv']);
                
            elseif ~isempty(regexp(ASLfilename,'ses-1_run-2','ONCE')) %run-2
                DestFile = fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-2_','asl', ext]);
                DestAslcontext= fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-2_','aslcontext.tsv']);
                
            elseif ~isempty(regexp(ASLfilename,'ses-2_run-1','ONCE')) %run-3
                DestFile = fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-3_','asl', ext]);
                DestAslcontext= fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-3_','aslcontext.tsv']);
                
            elseif ~isempty(regexp(ASLfilename,'ses-2_run-2','ONCE')) %run-4
                DestFile = fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-4_','asl', ext]);
                DestAslcontext= fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-4_','aslcontext.tsv']);
                
            elseif ~isempty(regexp(ASLfilename,'ses-3_run-1','ONCE')) %run-5
                DestFile = fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-5_','asl', ext]);
                DestAslcontext= fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-5_','aslcontext.tsv']);
                
            elseif ~isempty(regexp(ASLfilename,'ses-3_run-2','ONCE')) %run-6
                DestFile = fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-6_','asl', ext]);
                DestAslcontext= fullfile(Ddir,sub,ses,'perf', [sub, '_',ses,'_','run-6_','aslcontext.tsv']);
            end
            
            xASL_Copy(ASLList{iA}, DestFile, true);
            % aslcontext='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/AFIVASC_ACUTE_COMPLETE/rawdata_1/aslcontext.tsv';
            aslcontext='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/ABBA/AFIVASC/Correct_n11/rawdata_1/aslcontext.tsv';
            xASL_Copy(aslcontext,DestAslcontext,true);
        end
        
        %==T1==%
        T1FLAIRList = xASL_adm_GetFileList(fullfile(SesList{1},'anat'), '(.json)|(.nii.gz)', 'FPList',[0 Inf], false); %only from the first session because the T1s and FLAIRs are the same for all sessions
        for iTF=1:length(T1FLAIRList)
            [~, filename,ext] = fileparts(T1FLAIRList{iTF});
            if ~isempty(regexp(filename,'FLAIR','ONCE')) 
                DestFile = fullfile(Ddir,sub,ses,'anat', [sub, '_',ses,'_','FLAIR', ext]);
                
            elseif ~isempty(regexp(filename,'T1','ONCE')) 
                DestFile = fullfile(Ddir,sub,ses,'anat', [sub, '_',ses,'_','T1w', ext]);
            
            end
            
             xASL_Copy(T1FLAIRList{iTF}, DestFile, true);
        end
        
    end
end