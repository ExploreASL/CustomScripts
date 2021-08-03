function xASL_adni_AddParticipantsTSV(currentDir,adniCase)
%xASL_adni_AddParticipantsTSV Add a participants.tsv file to the corresponding BIDS dataset
%
% INPUT:        currentDir    - Case directory
%               adniCase      - Current ADNI case
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Add a participants.tsv file to the corresponding BIDS dataset.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    %% Add participants.tsv
    sessionList = xASL_adm_GetFsList(fullfile(currentDir,'sourcedata','sub-001'),'^session_.+$',true);
    
    % Initialize sessions cell array
    session{1,1} = 'participant_id';
    session{1,2} = 'session';
    session{1,3} = 'adni_id';
    session{1,4} = 'date';
    
    % Iterate over sessions
    for iSession=1:numel(sessionList)
        curSessionName = sessionList{iSession};
        fprintf('%s ...\n',curSessionName);
        regExpNum = regexp(curSessionName,'_\d{1}_');
        session{iSession+1,1} = 'sub-001';
        session{iSession+1,2} = ['ASL_' num2str(iSession)];
        session{iSession+1,3} = adniCase;
        session{iSession+1,4} = curSessionName(regExpNum+3:end);
    end
    
    xASL_tsvWrite(session,fullfile(currentDir,'derivatives','ExploreASL','participants.tsv'));
    


end