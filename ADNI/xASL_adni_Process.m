%xASL_adni_Process Script to process the ADNI BIDS datasets
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Script to process the ADNI BIDS datasets.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      xASL_adni_Process;
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

%% Initialization
x = ExploreASL;
clc

% Basic settings
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
    % On default the logging field should not exist
    loggingExists = false;
    % Get current case directory
    currentDir = fullfile(adniDirectoryResults,adniCases{iCase,1});
    fprintf('Process %s...    ',adniCases{iCase,1});
    xASL_TrackProgress(iCase/size(adniCases,1)*100);
    fprintf('\n');
    % Run ExploreASL processing
    try
        processDataset = xASL_adni_CheckProcessingTSV(adniCases{iCase,1},userConfig.ADNI_PROCESSED);
        if processDataset
            x = ExploreASL(currentDir,0,1);
        else
            % Dataset was already proessed successfully
            x = struct;
        end
    catch
        warning('Processing of %s failed...',adniCases{iCase,1});
        x = struct;
    end
    % Check logging to see if something went wrong
    if isfield(x,'logging')
        loggingExists = true;
    else
        loggingExists = false;
    end
    try
        xASL_adni_AddLineToTSV(adniCases{iCase,1},userConfig.ADNI_PROCESSED,loggingExists);
    catch
        warning('Can not read the TSV file...');
    end
    
end






