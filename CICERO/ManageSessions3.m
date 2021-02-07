%% Manage 2 vs 3 ASL sessions

% For those with 3 ASL sessions, the first session seemed invalid.
% These were 003_2, 004_1, 058_1, 061_1, 064_1
% So we took only sessions 2 & 3 (is this correct?)
% For 100_1, all 3 sessions were correct

% 1) load DataPar file

for iSubject=1:x.nSubjects
    xASL_TrackProgress(iSubject,x.nSubjects);
    SessionDir{1} = fullfile(x.D.ROOT,x.SUBJECTS{iSubject},'ASL_1');
    SessionDir{2} = fullfile(x.D.ROOT,x.SUBJECTS{iSubject},'ASL_2');
    SessionDir{3} = fullfile(x.D.ROOT,x.SUBJECTS{iSubject},'ASL_3');
    if exist(SessionDir{1},'dir') && exist(SessionDir{2},'dir') && exist(SessionDir{3},'dir')
        % check if SessionDir{3} doesnt contain NIfTIs
        if isempty(xASL_adm_GetFileList(SessionDir{3},'^.*\.nii$','FPListRec',[0 Inf]))
            % then remove this folder
            xASL_adm_DeleteFileList(SessionDir{3},'.*');
            xASL_delete(SessionDir{3});
        else
            % remove folder ASL_1 & rename folders ASL_2 & ASL_3 to ASL_1 &
            % ASL_2, assuming the first ASL scan failed
            xASL_adm_DeleteFileList(SessionDir{1},'.*');
            xASL_delete(SessionDir{1});
            xASL_Move(SessionDir{2},SessionDir{1});
            xASL_Move(SessionDir{3},SessionDir{2});
        end
    end
end

% Also delete their lock files, for the new names in Population folder