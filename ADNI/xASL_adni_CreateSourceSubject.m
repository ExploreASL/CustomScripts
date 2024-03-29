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
%               Written by M. Stritt, 2021.
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
    
    % Are there any matches at all (ASL vs. T1w)?
    simpleList.ASL = dateLists.dateList_ASL;
    simpleList.MPRAGE = dateLists.dateList_MPRAGE;
    for iDate=1:numel(simpleList.ASL)
        simpleList.ASL{iDate} = simpleList.ASL{iDate}(1:10);
    end
    for iDate=1:numel(simpleList.MPRAGE)
        simpleList.MPRAGE{iDate} = simpleList.MPRAGE{iDate}(1:10);
    end
    matchesASLT1w = sum(ismember(simpleList.ASL,simpleList.MPRAGE))>0;
    
    % Check if there are matches
    if matchesASLT1w
    
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
                    currentT1w = dateLists.dateList_MPRAGE{iSessions_MPRAGE,1};
                    currentASL = dateLists.dateList_ASL{iSessions,1};
                    if strcmp(currentT1w(1:10),currentASL(1:10))
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
                else
                    % Fallback
                    newCaseRoot = '';
                end

            end

            % Merge identical dataPar.json files
            if ~isempty(newCaseRoot)
                xASL_adni_MergeJsons(newCaseRoot);
            else
                % For one of the sessions the T1w wasn't found, but we should
                % still be able to merge JSONs if there are multiple ones
                newCaseRoot = fullfile(adniDirectoryResults,adniCases{iCase,1});
                try
                    xASL_adni_MergeJsons(newCaseRoot);
                catch
                    warning('Something went wrong for %s ...', adniCases{iCase,1});
                end
            end

            % Add sourceStructure.json and studyPar.json
            if xASL_exist(fullfile(adniDirectoryResults,adniCases{iCase,1}),'dir')
                xASL_io_WriteJson(fullfile(newCaseRoot,'sourceStructure.json'),sourceStructure);
                xASL_io_WriteJson(fullfile(newCaseRoot,'studyPar.json'),studyPar);
            end


        else
            warning('The ASL date list should not be empty...');
        end
        
    end


end


