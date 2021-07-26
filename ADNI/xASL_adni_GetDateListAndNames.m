function [dateLists, names] = xASL_adni_GetDateListAndNames(dateLists, names, currentModalities, modalitiesOfInterest, currentDir)
%xASL_adni_GetDateListAndNames Check modalities and get the directories
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Check modalities and get the directories.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Iterate over modalities
    for iModality = 1:numel(currentModalities)
        checkModality = regexpi(currentModalities{iModality},modalitiesOfInterest);
        % Check if we want to have this modality
        if sum([checkModality{:,1}])>0
            % Get dates of this modality
            if regexpi(currentModalities{iModality},'ASL')
                dateLists.dateList_ASL = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                names.ASL_name = currentModalities{iModality};
            elseif ~isempty(regexpi(currentModalities{iModality},'MPRAGE')) || ...
                   ~isempty(regexpi(currentModalities{iModality},'FSPGR'))
                dateLists.dateList_MPRAGE = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                names.MPRAGE_name = currentModalities{iModality};
            elseif regexpi(currentModalities{iModality},'FLAIR')
                dateLists.dateList_FLAIR = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                names.FLAIR_name = currentModalities{iModality};
            elseif regexpi(currentModalities{iModality},'CALIBRATION')
                dateLists.dateList_CALIBRATION = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                names.CALIBRATION_name = currentModalities{iModality};
            elseif regexpi(currentModalities{iModality},'M0')
                dateLists.dateList_M0 = xASL_adm_GetFsList(fullfile(currentDir,currentModalities{iModality}),'^.+$',true)';
                names.M0_name = currentModalities{iModality};
            end  
        end
    end
    
end


