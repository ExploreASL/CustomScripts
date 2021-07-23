%% Twins' DICOMDIR info extraction
% These fields have info about the dicoms, including PatientID, Study and Series (has the name of the MRI sequence)

% Clean-up
clear all

% Initialize ExploreASL
x=ExploreASL_Master('',0);
clc

% Set-up directories
rootDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/Twins/twins_FUscans/';

% Get all sub directories
baseDirs = xASL_adm_GetFsList(rootDir,'^.+$',true);

% Get items of each subject
patients = struct;
for iDir = 1:numel(baseDirs)
    currentDir = baseDirs{iDir};
    DicomDir=dicominfo(fullfile(rootDir,currentDir,'DICOMDIR'));
    % Get individual patient
    patients = getPatient(patients,DicomDir);
end


