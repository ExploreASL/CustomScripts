function xASL_adni_MergeJsons(newCaseRoot)
%xASL_adni_MergeJsons Minor helper function
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Minor helper function.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      xASL_adni_MergeJsons(newCaseRoot);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL
    
    dataParJsons = xASL_adm_GetFileList(newCaseRoot,'^dataPar.+\.json$','FPListRec');
    if numel(dataParJsons)>1
        for iJson = 1:numel(dataParJsons)
            fileID = fopen(dataParJsons{iJson},'r');
            dataParJSON.(['file_' num2str(iJson)]) = fileread(dataParJsons{iJson});
            % Check if files two to end are the same as the first one
            allAreTheSame = true;
            if iJson>1
                if ~strcmp(dataParJSON.(['file_' num2str(1)]),dataParJSON.(['file_' num2str(iJson)]))
                    allAreTheSame = false;
                end
            end
        end
        % Merge (keep and rename first, delete others)
        if allAreTheSame
            close all
            fclose all;
            for iJson = 1:numel(dataParJsons)
                if iJson==1
                    newName = strrep(dataParJsons{iJson},'-session_1','');
                    xASL_Copy(dataParJsons{iJson},newName);
                    xASL_delete(dataParJsons{iJson},1);
                else
                    xASL_delete(dataParJsons{iJson});
                end
            end
        end
    else
        % Rename the single session to "dataPar.json" instead of "dataPar-session...json"
        close all
        fclose all;
        dataParJsons = xASL_adm_GetFileList(newCaseRoot,'^dataPar.+\.json$','FPListRec');
        newName = strrep(dataParJsons{1},'-session_1','');
        xASL_Copy(dataParJsons{1},newName);
        xASL_delete(dataParJsons{1});
    end


end

