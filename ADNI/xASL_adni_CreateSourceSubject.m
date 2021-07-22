function xASL_adni_CreateSourceSubject(adniCases,userConfig,adniDirectory,adniDirectoryResults,sourceStructure,studyPar,iCase,modalitiesOfInterest)
%xASL_adni_CreateSourceSubject Create sourcedata of current subject
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Create sourcedata of current subject.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Get current case directory
    currentDir = fullfile(adniDirectory,adniCases{iCase,1});
    
    % Get all modalities within this case
    currentModalities = xASL_adm_GetFsList(currentDir,'^.+$',true);
    currentModalities = currentModalities';
    
    % Initialize empty lists
    names.ASL_name = [];
    names.MPRAGE_name = [];
    names.FLAIR_name = [];
    names.CALIBRATION_name = [];
    names.M0_name = [];
    dateLists.dateList_ASL = [];
    dateLists.dateList_MPRAGE = [];
    dateLists.dateList_FLAIR = [];
    dateLists.dateList_CALIBRATION = [];
    dateLists.dateList_M0 = [];
    
    % Check modalities and get the directories
    [dateLists, names] = xASL_adni_GetDateListAndNames(dateLists, names, currentModalities, modalitiesOfInterest, currentDir);
    
    % Compare lists with ASL list
    if ~isempty(dateLists.dateList_ASL)
        fprintf('Copy %s...    ',adniCases{iCase,1});
        xASL_TrackProgress(iCase/size(adniCases,1)*100);
        fprintf('\n');
        iSessionsNum = 1;
        % Iterate over ASL sessions
        for iSessions = 1:numel(dateLists.dateList_ASL)
            
            % Write new session format
            dateLists.dateList_ASL{iSessions,2} = dateLists.dateList_ASL{iSessions,1};
            
            % Check if ASL has a corresponding T1w, if not then skip the this visit
            foundT1wForASL = false;
            for iSessions_MPRAGE = 1:numel(dateLists.dateList_MPRAGE)
                if strcmp(dateLists.dateList_MPRAGE{iSessions_MPRAGE,1},dateLists.dateList_ASL{iSessions,1})
                    foundT1wForASL = true;
                end
            end
            
            % If a T1w and an ASL scan were found, we do the copying and so on for each modality
            if foundT1wForASL
                dataset.iSessionsNum = iSessionsNum;
                dataset.iSessions = iSessions;
                dataset.iCase = iCase;
                dataset.currentDir = currentDir;
                [json, newCaseRoot, iSessionsNum, studyPar] = xASL_adni_CopyAndModifySession(dataset, ...
                    userConfig, dateLists, studyPar, names, adniCases, adniDirectoryResults);
            end
            
        end
        
        % Merge identical dataPar.json files
        xASL_adni_MergeJsons(newCaseRoot);
        
        % Add sourceStructure.json and studyPar.json
        spm_jsonwrite(fullfile(newCaseRoot,'sourceStructure.json'),sourceStructure);
        spm_jsonwrite(fullfile(newCaseRoot,'studyPar.json'),studyPar);
        
        
    else
        warning('The ASL date list should not be empty...');
    end
    

end


