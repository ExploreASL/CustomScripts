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
% Test case 1: 006_S_6681
% Test case 2: 011_S_4105
% Test case 3: 027_S_5079
%
%
% EXAMPLE:      xASL_adni_Convert2Source;
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

%% Initialization
clear
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

% Iterator for error list
iE = 1;
listFailed = {};

% Iterate over datasets
for iCase = 1:size(adniCases,1)
    if ~xASL_exist(fullfile(adniDirectoryResults,adniCases{iCase,1}),'dir')
        try
            xASL_adni_CreateSourceSubject(adniCases,userConfig,adniDirectory,adniDirectoryResults,...
                                          sourceStructure,studyPar,iCase,modalitiesOfInterest);
        catch ME
            fprintf(2,'Something went wrong for %s...\n',adniCases{iCase,1});
            fprintf(2, 'Error message: %s\n', ME.message);
            listFailed{iE,1} = adniCases{iCase,1};
            listFailed{iE,2} =  ME.message;
            iE = iE+1;
        end
    else
        fprintf('The sourcedata for %s was already created...\n',adniCases{iCase,1});
    end
end

fprintf('\n====================================================================================================\n');
% Check if there were errors
if isempty(listFailed)
    fprintf('No errors during conversion...\n');
else
    fprintf('Some errors during conversion...\n');
    fprintf('Please check the listFailed cell array...\n');
end
% Check missing cases (cases without asl or t1 are excluded, so you wont get the exact same number of input folders)
outputCases = xASL_adm_GetFsList(adniDirectoryResults,'^\d{3}_.+$',true)';
if size(adniCases,1)~=size(outputCases,1)
    fprintf('Number of input cases is not equal to number of output cases...\n');
    % Print missing cases
    for iCase=1:size(adniCases,1)
        if ~ismember(adniCases{iCase,1},outputCases(:,1))
            fprintf('Missing %s...\n',adniCases{iCase,1});
        end
    end
end






