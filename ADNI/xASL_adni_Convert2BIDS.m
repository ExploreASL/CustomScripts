%xASL_adni_Convert2BIDS Script to convert the cases in source structure to ASL-BIDS using ExploreASL
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Script to convert the cases in source structure to ASL-BIDS using ExploreASL.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      xASL_adni_Convert2BIDS;
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

%% Initialization
x = ExploreASL;
clc

% Basic settings
fprintf('Convert raw ADNI data to sourcedata...\n');
fprintf('ExploreASL:         %s\n',x.Version);
[userConfig,adniDirectory,adniDirectoryResults] = xASL_adni_BasicSettings();

% Get directory list
adniCases = xASL_adm_GetFsList(adniDirectoryResults,'^\d{3}_.+$',true);

% Check if list is not empty
if isempty(adniCases)
    error('No ADNI cases found...');
end

% Transpose list
adniCases = adniCases';

% Iterator for error list
iE = 1;
listFailed = {};

%% Iterate over cases
for iCase = 1:size(adniCases,1)
    % Get current case directory
    currentDir = fullfile(adniDirectoryResults,adniCases{iCase,1});
    if ~xASL_exist(fullfile(currentDir,'rawdata'),'dir')
        fprintf('Import %s...    ',adniCases{iCase,1});
        xASL_TrackProgress(iCase/size(adniCases,1)*100);
        fprintf('\n');
        % Run ExploreASL DCM2BIDS
        try
            x = ExploreASL(currentDir,[1 1 0 1],0); % All import modules besides defacing
        catch ME
            warning('Import of %s failed...',adniCases{iCase,1});
            listFailed{iE,1} = adniCases{iCase,1};
            listFailed{iE,2} =  ME.message;
            iE = iE+1;
        end
        % Add custom participants.tsv
        xASL_adni_AddParticipantsTSV(currentDir,adniCases{iCase,1});
    else
        fprintf('The rawdata for %s was already created...\n',adniCases{iCase,1});
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




