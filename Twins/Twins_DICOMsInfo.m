%Twins_DICOMsInfo Main script for the database conversion
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Main script for the database conversion.
%               These fields have info about the dicoms, including PatientID, 
%               Study and Series (has the name of the MRI sequence)
%
%               Written by M. Stritt & B. Padrela, 2021.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

% Clean-up
clear all

% Initialize ExploreASL
x=ExploreASL_Master('',0);
clc

% Get user
if isunix
    [~,username] = system('id -u -n');
    username=username(1:end-1);
else
    username = getenv('username');
end

% Warning
fprintf('This script uses label files and mat files if they already exist, to get a clean start you can delete them...\n');

% Get basic settings
switch username
    case 'strittm'
        outputDir = '/home/strittm/lood_storage/divi/Projects/ExploreASL/Twins/BIDS';
        rootDir = '/home/strittm/lood_storage/divi/Projects/ExploreASL/Twins/twins_FUscans/';
    case 'bestevespadrela'
        outputDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/Twins/BIDS';
        rootDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/Twins/twins_FUscans/';
    otherwise
        fprintf('Unknown user...\n');
        return;
end

% Create output directory
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

% Get all sub directories
baseDirs = xASL_adm_GetFsList(rootDir,'^.+$',true);

% Get patient directory list
patientList = getPatientDirListXML(rootDir,outputDir);

%% Set-up patients structure
fprintf('Determine patients...\n');

% Get items of each subject
if ~exist(fullfile(outputDir,'Patients.mat'),'file')
    patients = struct;
    for iDir = 1:numel(baseDirs)
        currentDir = baseDirs{iDir};
        if exist(fullfile(rootDir,currentDir,'DICOMDIR'),'file')
            DicomDir=dicominfo(fullfile(rootDir,currentDir,'DICOMDIR'));
            % Get individual patient
            patients = getPatient(patients,DicomDir,iDir,numel(baseDirs));
        else
            warning('DICOMDIR does not exist...');
        end
    end
    save(fullfile(outputDir,'Patients.mat'),'patients');
else
    data = load(fullfile(outputDir,'Patients.mat'));
    patients = data.patients;
end

%% Now we create our BIDS sourcedata
fprintf('Create BIDS sourcedata...\n');

% Defaults
sourceStructure.folderHierarchy = {'^sub-(.+)$','^(session-\\d{1}).+$','^(ASL|T1w|M0|T2|FLAIR)$'};
sourceStructure.tokenOrdering = [1,2,0,3];
sourceStructure.tokenVisitAliases = {'session-1','_1'};
sourceStructure.tokenSessionAliases = {'',''};
sourceStructure.tokenScanAliases = {'^ASL$','ASL4D','^T1w$','T1w','^M0$','M0','^T2$','T2w','^FLAIR$','FLAIR'};
sourceStructure.bMatchDirectories = true;
dataPar.subject_regexp = '';

% Iterate over patients & series
allPatients = fieldnames(patients);
for iPatient = 1:numel(allPatients)
    % Create output directory
    thisPatient = allPatients{iPatient};
    % Check if directory already exists
    if ~exist(fullfile(outputDir,thisPatient),'dir')
        mkdir(fullfile(outputDir,thisPatient));
        % Create sourcedata
        mkdir(fullfile(outputDir,thisPatient,'sourcedata'));
        % Create subject
        mkdir(fullfile(outputDir,thisPatient,'sourcedata','sub-001'));
        % Create session
        mkdir(fullfile(outputDir,thisPatient,'sourcedata','sub-001','session-1'));

        % Create sourceStructure.json
        xASL_io_WriteJson(fullfile(outputDir,thisPatient,'sourceStructure.json'),sourceStructure);

        % Create dataPar.json
        dataPar.name = thisPatient;
        xASL_io_WriteJson(fullfile(outputDir,thisPatient,'dataPar.json'),dataPar);

        % Copy series
        copySeriesTwins(patients,thisPatient,outputDir);

    else
        fprintf('Patient %s already exists...\n', thisPatient);
    end

end


