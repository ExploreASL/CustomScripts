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

%% Iterate over cases
for iCase = 1:size(adniCases,1)
    % Get current case directory
    currentDir = fullfile(adniDirectoryResults,adniCases{iCase,1});
    fprintf('Import %s...    ',adniCases{iCase,1});
    xASL_TrackProgress(iCase/size(adniCases,1)*100);
    fprintf('\n');
    % Run ExploreASL DCM2BIDS
    try
        x = ExploreASL(currentDir,[1 1 0 1],0); % All import modules besides defacing
    catch
        warning('Import of %s failed...',adniCases{iCase,1});
    end
    % Add custom participants.tsv
    xASL_adni_AddParticipantsTSV(currentDir,adniCases{iCase,1});
    
end




