function [userConfig,adniDirectory,adniDirectoryResults] = xASL_adni_BasicSettings()
%xASL_adni_BasicSettings Basic settings for ADNI data
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Basic settings for ADNI data.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      [userConfig,adniDirectory,adniDirectoryResults] = xASL_adni_BasicSettings();
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Get script
    scriptPath = mfilename('fullpath');
    ADNI_DIR = fileparts(scriptPath);
    
    % Check if JSON with ADNI_VERSION, ADNI_ORIGINAL_DIR, ADNI_OUTPUT_DIR exists
    if xASL_exist(fullfile(ADNI_DIR,'userConfig.json'),'file')
        userConfig = spm_jsonread(fullfile(ADNI_DIR,'userConfig.json'));
    else
        fprintf('We could not find a userConfig.json file...\n');
        fprintf('Consider creating this JSON file with the following fields:\n');
        fprintf('ADNI_VERSION, ADNI_ORIGINAL_DIR, ADNI_OUTPUT_DIR\n');
        userConfig = struct;
    end

    % Check if there is a predefined ADNI version, otherwise use 2 on default
    if ~isfield(userConfig,'ADNI_VERSION')
        fprintf('No ADNI version defined, we will use ADNI-2...\n');
        userConfig.ADNI_VERSION = 2;
    end
    
    % Predefined matlab user (M. Stritt)
    if isfield(userConfig,'ADNI_ORIGINAL_DIR') && isfield(userConfig,'ADNI_OUTPUT_DIR')
        adniDirectory = userConfig.ADNI_ORIGINAL_DIR;
        adniDirectoryResults = userConfig.ADNI_OUTPUT_DIR;
    else
        adniDirectory = uigetdir([], 'Select ADNI directory...');
        adniDirectoryResults = uigetdir([], 'Select ADNI results directory...');
        userConfig.ADNI_ORIGINAL_DIR = adniDirectory;
        userConfig.ADNI_OUTPUT_DIR = adniDirectoryResults;
        userConfig.ADNI_PROCESSED = fullfile(adniDirectoryResults,'data.tsv');
        userConfig.ADNI_VERSION = 2;
    end

    % Print userConfig fields
    if isfield(userConfig,'ADNI_ORIGINAL_DIR')
        fprintf('ADNI_ORIGINAL_DIR:  %s\n',userConfig.ADNI_ORIGINAL_DIR);
    end
    if isfield(userConfig,'ADNI_OUTPUT_DIR')
        fprintf('ADNI_OUTPUT_DIR:    %s\n',userConfig.ADNI_OUTPUT_DIR);
    end
    if isfield(userConfig,'ADNI_PROCESSED')
        fprintf('ADNI_PROCESSED:     %s\n',userConfig.ADNI_PROCESSED);
    end
    if isfield(userConfig,'ADNI_VERSION')
        fprintf('ADNI_VERSION:       %d\n',userConfig.ADNI_VERSION);
    end

end


