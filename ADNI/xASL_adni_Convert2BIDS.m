%xASL_adni_Convert2BIDS Script to convert the cases in source structure to ASL-BIDS using ExploreASL
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Script to convert the cases in source structure to ASL-BIDS using ExploreASL.
%
% EXAMPLE:      xASL_adni_Convert2BIDS;
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

% Get ADNI "original" directory
if strcmp(username,'matlab') % M. Stritt user
    adniDirectoryResults = 'M:\SoftwareDevelopment\MATLAB\m.stritt\Server_xASL\adni-2';
else
    adniDirectoryResults = uigetdir([], 'Select ADNI results directory...');
end

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
    
end






