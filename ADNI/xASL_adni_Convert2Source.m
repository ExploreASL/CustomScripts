%xASL_adni_Convert2Source Main script to convert ADNI data to source data
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Main script to convert ADNI data to source data.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      xASL_adni_Convert2Source;
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

%% Initialization
x = ExploreASL;
clc

% Basic settings
fprintf('Convert raw ADNI data to sourcedata...\n');
fprintf('ExploreASL:         %s\n',x.Version);
[userConfig,adniDirectory,adniDirectoryResults] = xASL_adni_BasicSettings();

% Get ADNI cases
[adniCases,foundASL,foundT1] = xASL_adni_GetData(adniDirectory);

% Get default JSONs
[sourceStructure,studyPar] = xASL_adni_BasicJsons();


%% Get sessions from date strings
fprintf('Determining sessions from date strings...\n');

% Modalities of interest
modalitiesOfInterest = {'ASL','MPRAGE','FLAIR','CALIBRATION','M0','FSPGR'}';

% Iterate over datasets
for iCase = 1:size(adniCases,1)
    xASL_adni_CreateSourceSubject(adniCases,userConfig,adniDirectory,adniDirectoryResults,...
                                  sourceStructure,studyPar,iCase,modalitiesOfInterest);
end



