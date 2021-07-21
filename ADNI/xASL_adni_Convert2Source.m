%xASL_adni_Convert2Source Main script to convert ADNI data to source data
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Main script to convert ADNI data to source data.
%
% EXAMPLE:      xASL_adni_Convert2Source;
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

%% Initialization
x = ExploreASL;
clc

% Get user
if isunix
    [~,username] = system('id -u -n');
    username=username(1:end-1);
else
    username = getenv('username');
end

% Determine if we run this on ADNI-2 or ADNI-3
ADNI_VERSION = 2;

% Define user
customUser = 'matlab';

% Get ADNI "original" directory
if strcmp(username,customUser)
    if ADNI_VERSION==2
        adniDirectory = 'E:\ASPIRE\ADNI\ADNI2\original';
        adniDirectoryResults = 'M:\SoftwareDevelopment\MATLAB\m.stritt\Server_xASL\adni-2';
    else
        adniDirectory = 'E:\ASPIRE\ADNI\ADNI3\original';
        adniDirectoryResults = 'M:\SoftwareDevelopment\MATLAB\m.stritt\Server_xASL\adni-3';
    end
else
    adniDirectory = uigetdir([], 'Select ADNI directory...');
    adniDirectoryResults = uigetdir([], 'Select ADNI results directory...');
end

% Get directory list
adniCases = xASL_adm_GetFsList(adniDirectory,'^\d{3}_.+$',true);

% Check if list is not empty
if isempty(adniCases)
    error('No ADNI cases found...');
end

% Transpose list
adniCases = adniCases';

%% Check which cases contain an ASL scan
fprintf('Searching for ADNI cases with ASL scans...\n');
for iCase = 1:numel(adniCases)
    % Get current case directory
    currentDir = fullfile(adniDirectory,adniCases{iCase,1});
    % Get all modalities within this case
    currentModalities = xASL_adm_GetFsList(currentDir,'^.+$',true);
    currentModalities = currentModalities';
    % Iterate over modalities
    foundASL = false;
    foundT1 = false;
    for iModality = 1:numel(currentModalities)
        if regexpi(currentModalities{iModality,1}, 'ASL')
            foundASL = true;
        end
    end
    for iModality = 1:numel(currentModalities)
        if regexpi(currentModalities{iModality,1}, 'ASL')
            foundASL = true;
        end
        if ~isempty(regexpi(currentModalities{iModality,1}, 'MPRAGE')) || ~isempty(regexpi(currentModalities{iModality,1}, 'FSPGR'))
            foundT1 = true;
        end
    end
    % Write value back
    adniCases{iCase,2} = foundASL;
    % Write value back
    adniCases{iCase,3} = foundT1;
end

% Free up memory
clear currentDir currentModalities foundASL iCase iModality

% Define sourceStructure template

% token 1: (.+), token 2: (session_\\d{1}), token 3: (ASL|T1w|M0|T2|FLAIR)
sourceStructure.folderHierarchy = {'^sub-(.+)$','^(session_\d{1}).+$','^(ASL|T1w|M0|T2|FLAIR)$', 'S.+$'};
% subject: token 1, visit: token 2, session: none, scan: token 3
sourceStructure.tokenOrdering = [1,2,0,3];
% visit/session/scan aliases
sourceStructure.tokenVisitAliases = {'session_1','_1','session_2','_2','session_3','_3','session_4','_4','session_5','_5','session_6','_6','session_7','_7'};
sourceStructure.tokenSessionAliases = {'', ''};
sourceStructure.tokenScanAliases = {'^ASL$','ASL4D','^T1w$','T1w','^M0$','M0','^T2$','T2w','^FLAIR$','FLAIR'};
% Match directories
sourceStructure.bMatchDirectories = true;

% Define studyPar template
studyPar.Authors = 'ADNI';
studyPar.DatasetType = 'raw';
studyPar.License = 'RandomText';
studyPar.Authors = {'RandomText'};
studyPar.Acknowledgements = 'RandomText';
studyPar.HowToAcknowledge = 'Please cite this paper: https://www.ncbi.nlm.nih.gov/pubmed/001012092119281';
studyPar.Funding = {'RandomText'};
studyPar.EthicsApprovals = {'RandomText'};
studyPar.ReferencesAndLinks = {'RandomText'};
studyPar.DatasetDOI = 'RandomText';
studyPar.VascularCrushing = false;
studyPar.LabelingType = 'PASL';
studyPar.PASLType = 'PICORE';
studyPar.BackgroundSuppression = false;
studyPar.M0 = false;
studyPar.LabelingLocationDescription = 'Fixed, 9 cm below ACPC';
studyPar.ASLContext = 'm0scan,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label';

% Remove ADNI cases without ASL scan
removeIndex = find(~[adniCases{:,2}])';
adniCases(removeIndex,:) = [];

% Remove ADNI cases without T1 scan
removeIndex2 = find(~[adniCases{:,3}])';
adniCases(removeIndex2,:) = [];

%% Get sessions from date strings
fprintf('Determining sessions from date strings...\n');
% Modalities of interest
modalitiesOfInterest = {'ASL','MPRAGE','FLAIR','CALIBRATION','M0','FSPGR'}';
for iCase = 1:size(adniCases,1)
    % Get current case directory
    currentDir = fullfile(adniDirectory,adniCases{iCase,1});
    % Get all modalities within this case
    currentModalities = xASL_adm_GetFsList(currentDir,'^.+$',true);
    currentModalities = currentModalities';
    % Initialize empty lists
    ASL_name = [];
    MPRAGE_name = [];
    FLAIR_name = [];
    CALIBRATION_name = [];
    M0_name = [];
    dateList_ASL = [];
    dateList_MPRAGE = [];
    dateList_FLAIR = [];
    dateList_CALIBRATION = [];
    dateList_M0 = [];
    % Iterate over modalities
    for iModality = 1:numel(currentModalities)
        checkModality = regexpi(currentModalities{iModality},modalitiesOfInterest);
        % Check if we want to have this modality
        if sum([checkModality{:,1}])>0
            % Get dates of this modality
            if regexpi(currentModalities{iModality},'ASL')
                dateList_ASL = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                ASL_name = currentModalities{iModality};
            elseif ~isempty(regexpi(currentModalities{iModality},'MPRAGE')) || ...
                   ~isempty(regexpi(currentModalities{iModality},'FSPGR'))
                dateList_MPRAGE = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                MPRAGE_name = currentModalities{iModality};
            elseif regexpi(currentModalities{iModality},'FLAIR')
                dateList_FLAIR = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                FLAIR_name = currentModalities{iModality};
            elseif regexpi(currentModalities{iModality},'CALIBRATION')
                dateList_CALIBRATION = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                CALIBRATION_name = currentModalities{iModality};
            elseif regexpi(currentModalities{iModality},'M0')
                dateList_M0 = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                M0_name = currentModalities{iModality};
            end  
        end
    end
    % Compare lists with ASL list
    if ~isempty(dateList_ASL)
        fprintf('Copy %s...    ',adniCases{iCase,1});
        xASL_TrackProgress(iCase/size(adniCases,1)*100);
        fprintf('\n');
        iSessionsNum = 1;
        % Iterate over ASL sessions
        for iSessions = 1:numel(dateList_ASL)
            
            % Write new session format
            dateList_ASL{iSessions,2} = dateList_ASL{iSessions,1};
            
            % Check if ASL has a corresponding T1w, if not then skip the this visit
            foundT1wForASL = false;
            for iSessions_MPRAGE = 1:numel(dateList_MPRAGE)
                if strcmp(dateList_MPRAGE{iSessions_MPRAGE,1},dateList_ASL{iSessions,1})
                    foundT1wForASL = true;
                end
            end
            
            % If a T1w and an ASL scan were found, we do the copying and so on for each modality
            if foundT1wForASL
                [json, newCaseRoot] = xASL_adni_CopyAndModifySession(iSessionsNum, iSessions, iCase, dateList_ASL, currentDir, ADNI_VERSION, ...
                                        dateList_MPRAGE, dateList_FLAIR, dateList_CALIBRATION, dateList_M0, ...
                                        ASL_name, MPRAGE_name, FLAIR_name, CALIBRATION_name, M0_name, adniCases, adniDirectoryResults);
            end
            
        end
        
        % Merge identical dataPar.json files
        xASL_adni_MergeJsons(newCaseRoot);
        
        % Add sourceStructure.json and studyPar.json
        spm_jsonwrite(fullfile(newCaseRoot,'sourceStructure.json'),sourceStructure);
        spm_jsonwrite(fullfile(newCaseRoot,'studyPar.json'),studyPar);
        
        
    else
        warning('The ASL date list should not be empty...');
    end
    
    % Fee up space
    clear ASL_name MPRAGE_name FLAIR_name CALIBRATION_name M0_name
    clear dateList_ASL dateList_MPRAGE dateList_FLAIR dateList_CALIBRATION dateList_M0 

end


%% Helper function Siemens
function [xasl, json, studyPar] = xASL_adni_PhoenixFix(xasl, studyPar, ADNI_VERSION, adniCases, iCase)

    if ~isfield(xasl,'SoftwareVersions')
        xasl.SoftwareVersions = 'unknown';
    end
    if ~isfield(xasl,'PulseSequenceType')
        xasl.PulseSequenceType = 'unknown';
    end

    % Add dataPar.json
    if ADNI_VERSION==2
        xasl.PLD = 1900;
    else
        xasl.PLD = 2000;
    end
    xasl.labelingDuration = 700;

    if regexpi(xasl.PulseSequenceType,'2D')
        xasl.M0inASLsequence = 1;
    else
        xasl.M0inASLsequence = 0;
    end

    % Fix slice timings
    if regexpi(xasl.SoftwareVersions,'B15')
        if regexpi(xasl.PulseSequenceType,'2D')
            studyPar.SliceTiming = {0,0.0275,0.0575,0.085,0.115,0.1425,0.1725,...
                0.2025,0.23,0.26,0.2875,0.3175,0.345,...
                0.375,0.405,0.4325,0.4625,0.49,0.52,...
                0.55,0.5775,0.6075,0.635,0.665};
        end
    else
        if regexpi(xasl.PulseSequenceType,'2D')
            if isfield(studyPar,'SliceTiming')
                studyPar = rmfield(studyPar,'SliceTiming');
            end
        end
    end

    if regexpi(xasl.PulseSequenceType,'3D')
        if isfield(studyPar,'SliceTiming')
            studyPar = rmfield(studyPar,'SliceTiming');
        end
    end

    % Create x struct
    json.x = struct;
    json.x.name = adniCases{iCase,1};
    %json.x.subject_regexp = '';
    if xasl.M0inASLsequence
        json.x.M0PositionInASL4D = 1;
    else
        json.x.M0 = 'UseControlAsM0';
    end
    json.x.Q.LabelingType = 'PASL';
    json.x.Q.Initial_PLD = xasl.PLD;
    json.x.Q.LabelingDuration = xasl.labelingDuration;
    % json.x.Q.SliceReadoutTime = xasl.sliceReadoutTime;
    json.x.Q.readoutDim = xasl.PulseSequenceType;
    json.x.Quality = 1;
    json.x.Vendor = 'Siemens';


end


%% Helper function Philips
function json = xASL_adni_GetJsonPhilips(headerDCM, ADNI_VERSION, adniCases, iCase)

    % Tested with 006_S_6681

    % Create x struct
    json.x = struct;
    json.x.name = adniCases{iCase,1};
    json.x.M0 = 'UseControlAsM0';
    json.x.Q.LabelingType = 'PASL';
    json.x.Quality = 1;
    json.x.Vendor = 'Philips';
    if isfield(headerDCM,'SeriesDescription')
        if ischar(headerDCM.SeriesDescription)
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PASL'))
                json.x.Q.LabelingType = 'PASL';
            end
        end
    end


end


%% Helper function GE
function json = xASL_adni_GetJsonGE(headerDCM, ADNI_VERSION, adniCases, iCase)

    % Tested with 027_S_5079

    % Create x struct
    json.x = struct;
    json.x.name = adniCases{iCase,1};
    % json.x.M0 = 'UseControlAsM0'; % 027_S_5079 should have M0 within the ASL sequence
    json.x.Q.LabelingType = 'PCASL';
    json.x.Quality = 1;
    json.x.Vendor = 'GE';
    if isfield(headerDCM,'GELabelingDuration')
        if isnumeric(headerDCM.GELabelingDuration)
            json.x.Q.Initial_PLD = headerDCM.GELabelingDuration; % I think there's a little mix-up here :)
        end
    end
    if isfield(headerDCM,'SeriesDescription')
        if ischar(headerDCM.SeriesDescription)
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PCASL'))
                json.x.Q.LabelingType = 'PCASL';
            end
        end
    end
    json.x.Q.LabelingDuration = 700;


end


%% Merge dataPar.json files
function xASL_adni_MergeJsons(newCaseRoot)

    dataParJsons = xASL_adm_GetFileList(newCaseRoot,'^dataPar.+\.json$','FPListRec');
    if numel(dataParJsons)>1
        for iJson = 1:numel(dataParJsons)
            fileID = fopen(dataParJsons{iJson},'r');
            dataParJSON.(['file_' num2str(iJson)]) = fileread(dataParJsons{iJson});
            % Check if files two to end are the same as the first one
            allAreTheSame = true;
            if iJson>1
                if ~strcmp(dataParJSON.(['file_' num2str(1)]),dataParJSON.(['file_' num2str(iJson)]))
                    allAreTheSame = false;
                end
            end
        end
        % Merge (keep and rename first, delete others)
        if allAreTheSame
            close all
            fclose all;
            for iJson = 1:numel(dataParJsons)
                if iJson==1
                    newName = strrep(dataParJsons{iJson},'-session_1','');
                    xASL_Copy(dataParJsons{iJson},newName);
                    xASL_delete(dataParJsons{iJson},1);
                else
                    xASL_delete(dataParJsons{iJson});
                end
            end
        end
    else
        % Rename the single session to "dataPar.json" instead of "dataPar-session...json"
        close all
        fclose all;
        dataParJsons = xASL_adm_GetFileList(newCaseRoot,'^dataPar.+\.json$','FPListRec');
        newName = strrep(dataParJsons{1},'-session_1','');
        xASL_Copy(dataParJsons{1},newName);
        xASL_delete(dataParJsons{1});
    end

end


%% Copy and modify session
function [json, newCaseRoot] = xASL_adni_CopyAndModifySession(iSessionsNum, iSessions, iCase, dateList_ASL, currentDir, ADNI_VERSION, ...
            dateList_MPRAGE, dateList_FLAIR, dateList_CALIBRATION, dateList_M0, ...
            ASL_name, MPRAGE_name, FLAIR_name, CALIBRATION_name, M0_name, adniCases, adniDirectoryResults)

    % Get this session
    thisSessions = ['session_' num2str(iSessionsNum)];
    iSessionsNum = iSessionsNum+1;
    dateList_ASL{iSessions,1} = [thisSessions '_' dateList_ASL{iSessions,2}];

    % Determine new case directory
    newCase = fullfile(adniDirectoryResults,adniCases{iCase,1},'sourcedata','sub-001',dateList_ASL{iSessions,1});
    newCaseRoot = fullfile(adniDirectoryResults,adniCases{iCase,1});

    % Copy ASL session to new directory
    xASL_Copy(fullfile(currentDir,ASL_name,dateList_ASL{iSessions,2}),fullfile(newCase,'ASL'),1);

    % Get Dicoms
    dcmPaths = xASL_adm_GetFileList(fullfile(newCase,'ASL'),'^.+\.dcm$','FPListRec');
    if ~isempty(dcmPaths)
        headerDCM = xASL_io_DcmtkRead(dcmPaths{1});

        % Determine manufacturer from DICOM
        if ~isempty(strfind(headerDCM.Manufacturer,'Siemens'))
            manufacturer = 'Siemens';
        elseif ~isempty(strfind(headerDCM.Manufacturer,'Philips'))
            manufacturer = 'Philips';
        elseif ~isempty(strfind(headerDCM.Manufacturer,'GE'))
            manufacturer = 'GE';
        else
            manufacturer = '';
        end

        switch manufacturer
            case 'Siemens'
                % Phoenix Protocol
                [xasl,parameters,parameterList,phoenixProtocol] = xASL_bids_GetPhoenixProtocol(dcmPaths{1},true);
                [xasl, json, studyPar] = xASL_adni_PhoenixFix(xasl, studyPar, ADNI_VERSION, adniCases, iCase);
            case 'Philips'
                json = xASL_adni_GetJsonPhilips(headerDCM, ADNI_VERSION, adniCases, iCase);
            case 'GE'
                json = xASL_adni_GetJsonGE(headerDCM, ADNI_VERSION, adniCases, iCase);
            otherwise
                warning('Unknown manufacturer...');
        end

        % Write JSON file
        spm_jsonwrite(fullfile(newCaseRoot,['dataPar-' thisSessions '.json']),json);

    end

    % Check if there are other modalities for this session
    for iSessions_MPRAGE = 1:numel(dateList_MPRAGE)
        if strcmp(dateList_MPRAGE{iSessions_MPRAGE,1},dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,MPRAGE_name,dateList_MPRAGE{iSessions_MPRAGE,1}),fullfile(newCase,'T1w'));
        end
    end
    for iSessions_FLAIR = 1:numel(dateList_FLAIR)
        if strcmp(dateList_FLAIR{iSessions_FLAIR,1},dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,FLAIR_name,dateList_FLAIR{iSessions_FLAIR,1}),fullfile(newCase,'FLAIR'));
        end
    end
    for iSessions_CALIBRATION = 1:numel(dateList_CALIBRATION)
        if strcmp(dateList_CALIBRATION{iSessions_CALIBRATION,1},dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,CALIBRATION_name,dateList_CALIBRATION{iSessions_CALIBRATION,1}),fullfile(newCase,'CALIBRATION'));
        end
    end
    for iSessions_M0 = 1:numel(dateList_M0)
        if strcmp(dateList_M0{iSessions_M0,1},dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,M0_name,dateList_M0{iSessions_M0,1}),fullfile(newCase,'M0'));
        end
    end


end





