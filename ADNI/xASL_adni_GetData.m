function [adniCases,foundASL,foundT1] = xASL_adni_GetData(adniDirectory)
%xASL_adni_BasicJsons Basic settings for ADNI data
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
% EXAMPLE:      [adniCases,foundASL,foundT1] = xASL_adni_GetData(adniDirectory);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

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
    
    % Remove ADNI cases without ASL scan
    removeIndex = find(~[adniCases{:,2}])';
    adniCases(removeIndex,:) = [];

    % Remove ADNI cases without T1 scan
    removeIndex2 = find(~[adniCases{:,3}])';
    adniCases(removeIndex2,:) = [];

    
end


