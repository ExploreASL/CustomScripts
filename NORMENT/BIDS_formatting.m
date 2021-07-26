%% BIDS_formatting NORMENT
% This function creates paths of original NIFTI data, moves them to BIDS
% compliant folders, performs preprocessing and allows for processing of
% xASL NIFTI2BIDS and BIDS2LEGACY.
% Preprocessing consists of altering xASL flavor database jsons of
% ASL/T1w/FLAIR and copying those to the correct subject/sessions

datafolder = '/home/mdijsselhof/lood_storage/divi/Projects/ExploreASL/ABBA/NORMENT/FINAL_BIDS/';
datapath = [datafolder 'DATA/'];
BIDSrequiredFilesfolder = '/home/mdijsselhof/lood_storage/divi/Projects/ExploreASL/ABBA/NORMENT/Required_example_BIDS_files/';
SubjectRegExp = '^strokemri_.+$';
rawdata = [datafolder 'rawdata/'];
mkdir(rawdata)

% administration

SubjectList = xASL_adm_GetFsList(datapath,SubjectRegExp);
ASLloc = find(~cellfun(@isempty,strfind(SubjectList,'asl')));
ASL_list = SubjectList(ASLloc);


T1wloc = find(~cellfun(@isempty,strfind(SubjectList,'t1w')));
T1w_list = SubjectList(T1wloc);

Flairloc = find(~cellfun(@isempty,strfind(SubjectList,'flair')));
Flair_list = SubjectList(Flairloc);

nSubjects = numel(T1w_list);

Subject_t1w_json_path = [BIDSrequiredFilesfolder 'T1w.json'];
Subject_flair_json_path = [BIDSrequiredFilesfolder 'FLAIR.json'];
Subject_asl_json_path = [BIDSrequiredFilesfolder 'asl.json'];

% read JSONS
jsonT1w = spm_jsonread(Subject_t1w_json_path);
jsonFLAIR = spm_jsonread(Subject_flair_json_path);
jsonASL = spm_jsonread(Subject_asl_json_path);

% moving files and creating JSONS per subject/session

for subject = 1:nSubjects
    SubjectName_loc = strfind(T1w_list{subject},'_');
    SubjectName = T1w_list{subject}(SubjectName_loc(1)+1:SubjectName_loc(2)-1);
    SessionName = T1w_list{subject}(SubjectName_loc(2)+2:SubjectName_loc(3)-1);
    SubjectFolder = [rawdata 'sub-' SubjectName '/'];
    SessionsFolder = [SubjectFolder 'ses-' SessionName '/'];
    Subject_anat =   [SessionsFolder 'anat/'];
    Subject_perf =   [SessionsFolder 'perf/'];
    
    if ~exist(Subject_anat)
        mkdir(Subject_anat)
        
    end
    if ~exist(Subject_perf)
        mkdir(Subject_perf)
        
    end

    % original
    Subject_t1w_path = [datapath T1w_list{subject}];
    Subject_flair_path = [datapath Flair_list{subject}];
    Subject_asl_path = [datapath T1w_list{subject}(1:SubjectName_loc(4)), 'asl.nii.gz'];
    Subject_asl_TSVCONTEXT_path = [BIDSrequiredFilesfolder 'aslcontext.tsv'];
    
    if ~exist(Subject_asl_TSVCONTEXT_path)
        disp('Create aslcontext.tsv first!')
        break
    end
    
    % BIDS
    Subject_t1w_BIDS_path = [Subject_anat 'sub-' SubjectName '_T1w.nii.gz'];
    Subject_flair_BIDS_path = [Subject_anat 'sub-' SubjectName '_FLAIR.nii.gz'];
    Subject_asl_BIDS_path = [Subject_perf 'sub-' SubjectName '_ses-' SessionName '_run-1_asl.nii.gz'];
    
    % BIDS add new files
    Subject_T1w_JSON_BIDS_path = [Subject_anat 'sub-' SubjectName '_T1w.json'];
    Subject_FLAIR_JSON_BIDS_path = [Subject_anat 'sub-' SubjectName '_FLAIR.json'];
    Subject_asl_JSON_BIDS_path = [Subject_perf 'sub-' SubjectName '_ses-' SessionName '_run-1_asl.json'];
    Subject_asl_TSVCONTEXT_BIDS_path = [Subject_perf 'sub-' SubjectName '_ses-' SessionName '_run-1_aslcontext.tsv'];
    
    % Moving
    xASL_Copy(Subject_t1w_path,Subject_t1w_BIDS_path); % move T1w to BIDS rawdata folder
    xASL_Copy(Subject_flair_path,Subject_flair_BIDS_path); % move FLAIR to BIDS rawdata folder
    if exist(Subject_asl_path,'file')
        xASL_Copy(Subject_asl_path,Subject_asl_BIDS_path); % move ASL to BIDS rawdata folder
    else
        disp('ASL.nii.gz does not exist, continuing with next subject/session')
    end
    xASL_Copy(Subject_asl_TSVCONTEXT_path,Subject_asl_TSVCONTEXT_BIDS_path); % move ASL context to BIDS rawdata folder
    
    % Create JSONS
    
    
    % T1w json
    jsonT1w.Manufacturer= 'GE' ;
    jsonT1w.ManufacturersModelName= 'DISCOVERY_MR750' ;
    jsonT1w.SoftwareVersions='24_LX_MR_Software_release:DV24.0_R02_1607.b' ;
    jsonT1w.MagneticFieldStrength= 3;
    jsonT1w.ReceiveCoilName= '32Ch_Head';
    jsonT1w.ScanningSequence= 'GR';
    jsonT1w.SequenceVariant= 'SS_SP_SK' ;
    jsonT1w.ScanOptions= 'FAST_GEMS_EDR_GEMS_FILTERED_GEMS_ACC_GEMS';
    jsonT1w.MRAcquisitionType= '3D';
    jsonT1w.EchoTime= 0.003024;
    jsonT1w.InversionTime= 0.45;
    jsonT1w.FlipAngle= 12;
    jsonT1w.RepetitionTime= 0.007332;
    
    % FLAIR json
    jsonFLAIR.Manufacturer= 'GE' ;
    jsonFLAIR.ManufacturersModelName= 'DISCOVERY_MR750' ;
    jsonFLAIR.SoftwareVersions='24_LX_MR_Software_release:DV24.0_R02_1607.b' ;
    jsonFLAIR.MagneticFieldStrength= 3;
    jsonFLAIR.ReceiveCoilName= '32Ch_Head';
    jsonFLAIR.ScanningSequence= 'GR';
    jsonFLAIR.SequenceVariant= 'SS_SP_SK' ;
    jsonFLAIR.ScanOptions= 'FAST_GEMS_EDR_GEMS_FILTERED_GEMS_ACC_GEMS';
    jsonFLAIR.MRAcquisitionType= '3D';
    jsonFLAIR.EchoTime= 0.127;
    jsonFLAIR.InversionTime= 2.240;
    jsonFLAIR.FlipAngle= 12;
    jsonFLAIR.RepetitionTime= 8;
    
    % ASL json
    jsonASL.Manufacturer= 'GE' ;
    jsonASL.ManufacturersModelName= 'DISCOVERY_MR750' ;
    jsonASL.SoftwareVersions= '24_LX_MR_Software_release:DV24.0_R02_1607.b' ;
    jsonASL.MagneticFieldStrength= 3 ;
    jsonASL.ReceiveCoilName= '32Ch_Head' ;
    jsonASL.PulseSequenceType= '3D_spiral' ;
    jsonASL.ScanningSequence= 'RM' ;
    jsonASL.SequenceVariant= 'NONE' ;
    jsonASL.ScanOptions= 'EDR_GEMS_SPIRAL_GEMS'  ;
    jsonASL.PulseSequenceDetails= 'DISCOVERY_MR750-24_LX_MR_Software_release:DV24.0_R02_1607.b' ;
    jsonASL.MRAcquisitionType= '3D' ;
    jsonASL.RepetitionTime= 5.025;
    jsonASL.EchoTime= 0.011072 ;
    jsonASL.FlipAngle= 111 ;
    jsonASL.ArterialSpinLabelingType= 'PCASL' ;
    jsonASL.PostLabelingDelay= 2.025 ;
    jsonASL.LabelingDuration= 1.45;
    jsonASL.TotalAcquiredPairs= 3 ;
    jsonASL.BackgroundSuppression= 1;
    jsonASL.M0Type= 'Included' ;
    jsonASL.VascularCrushing= 'false' ;
    jsonASL.AcquisitionVoxelSize= [4,4,8] ;
    jsonASL.BackgroundSuppressionNumberPulses= 4 ;
    jsonASL.BackgroundSuppressionPulseTime= [1.965,2.6,3.1,3.38] ;
    jsonASL.LabelingLocationDescription= 'Random description' ;
    jsonASL.LabelingDistance= 40 ;
    
    
    % write JSON's
    spm_jsonwrite(Subject_T1w_JSON_BIDS_path, jsonT1w);
    spm_jsonwrite(Subject_FLAIR_JSON_BIDS_path, jsonFLAIR);
    if exist(Subject_asl_path,'file')
        spm_jsonwrite(Subject_asl_JSON_BIDS_path, jsonASL);
    else
        disp('ASL.nii.gz does not exist, no ASL.json copied, continuing with next subject/session')
    end
    
    % finished
    disp(['BIDS conversion subject ' SubjectName ', n = ' num2str(subject) ' of ' num2str(nSubjects) ' is done'])
    
end