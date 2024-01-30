% Admin

dirLegacy = '/Users/hjmutsaerts/Downloads/BoleStudienFlavor/rawdata';
dirRawdata = '/Users/hjmutsaerts/ExploreASL/ASL/BoleStudienFlavor/rawdataNew';

% Get subject numbers
listSubjects = xASL_adm_GetFileList(dirLegacy, '\d{3}', 'list', [], 1);

% populate participants.tsv: who is which hematocrit and which cohort
participants = {'participant_id' 'cohort' 'hematocrit'}
nSubjects = length(listSubjects);
participants(2:nSubjects+1,1) = listSubjects';


% iterate over subjects
for iSubject=1:nSubjects
    xASL_TrackProgress(iSubject, nSubjects);
    dirSubjectOld = fullfile(dirLegacy, listSubjects{iSubject});
    dirSubjectNew = fullfile(dirRawdata, ['sub-' listSubjects{iSubject}]);
    xASL_adm_CreateDir(dirSubjectNew);

    % anatomic
    dirAnatNew = fullfile(dirSubjectNew, 'anat');
    xASL_adm_CreateDir(dirAnatNew);
    
    pathT1old = fullfile(dirSubjectOld, 'T1_ORI.nii');
    pathT1new = fullfile(dirAnatNew, ['sub-' listSubjects{iSubject} '_T1.nii.gz']);
    xASL_Copy(pathT1old, pathT1new, 1);

    pathFLAIRold = fullfile(dirSubjectOld, 'FLAIR.nii');
    pathFLAIRnew = fullfile(dirAnatNew, ['sub-' listSubjects{iSubject} '_FLAIR.nii.gz']);
    xASL_Copy(pathFLAIRold, pathFLAIRnew, 1);

    % ASL
    dirPerfOld = fullfile(dirSubjectOld, 'ASL_1');
    dirPerfNew = fullfile(dirSubjectNew, 'perf');
    xASL_adm_CreateDir(dirPerfNew);

    pathPerfOld = fullfile(dirPerfOld, 'ASL4D.nii');
    pathPerfnew = fullfile(dirPerfNew, ['sub-' listSubjects{iSubject} '_asl.nii.gz']);
    xASL_Copy(pathPerfOld, pathPerfnew, 1);

    % get parameters
    pathMatOld = fullfile(dirPerfOld, 'ASL4D_parms.mat');
    parms = load(pathMatOld, '-mat');
    % add to json
    json = struct;
    json.RepetitionTimePreparation = parms.parms.RepetitionTime/1000;
    json.EchoTime = parms.parms.EchoTime/1000;
    json.AcquisitionTime = parms.parms.AcquisitionTime;
    % add to participants.tsv
    participants{iSubject+1, 2} = parms.parms.Cohort;
    participants{iSubject+1, 3} = parms.parms.hematocrit;

    % create aslContext.tsv
    aslContextTsv{1} = 'volume_type';
    oddVolumes = 1:2:139;
    evenVolumes = 2:2:140;
    aslContextTsv(1+oddVolumes,1) = {'label'};
    aslContextTsv(1+evenVolumes,1) = {'control'};
    
    pathContext = fullfile(dirPerfNew, ['sub-' listSubjects{iSubject} '_aslcontext.tsv']); 
    xASL_tsvWrite(aslContextTsv, pathContext, 1);

    % create the rest of the json
    pathJsonNew = fullfile(dirPerfNew, ['sub-' listSubjects{iSubject} '_asl.json']);

    json.Manufacturer = 'Siemens';
    json.MagneticFieldStrength = 3;
    json.PulseSequenceType = '2D_EPI';
    json.MRAcquisitionType = '2D';
    json.EchoTime = 0.012;
    
    json.RepetitionTimePreparation = 4.36;
    json.ArterialSpinLabelingType = 'PCASL';
    json.PostLabelingDelay = 1.711;
    json.BackgroundSuppression = false;
    json.M0Type = 'Absent';
    json.VascularCrushing = false;
    json.LabelingDuration = 1.8;
    json.TotalAcquiredPairs = 70;
    
    SliceReadoutTime = (json.RepetitionTimePreparation-json.LabelingDuration-json.PostLabelingDelay)/20;
    json.SliceTiming = round([0:19]*SliceReadoutTime,5); % 20 slices

    xASL_io_WriteJson(pathJsonNew, json);
end

pathParticipants = fullfile(dirRawdata, 'participants.tsv');
xASL_tsvWrite(participants, pathParticipants, 1);