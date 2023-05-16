function RemoveFSLsymbolic(pathDerivatives)
% Goes through all subjects in the derivatives directory and all ASL sessions and removes all FSL symbolic links

subjectPaths = xASL_adm_GetFileList(fullfile(pathDerivatives, 'derivatives', 'ExploreASL'), '^sub.*', 'FPList', [], true);

% Go through all subjects
for iSub = 1:length(subjectPaths)
	% Find ASL sessions
	sessionPaths = xASL_adm_GetFileList(subjectPaths{iSub}, '^ASL.*', 'FPList', [], true);

	% Go through all sessions
	for iSession = 1:length(sessionPaths)
		% Unlink the entire output
		if xASL_exist(fullfile(sessionPaths{iSession}, 'FSL_Output_latest'), 'dir')
			system(['unlink ' fullfile(sessionPaths{iSession}, 'FSL_Output_latest')]);
		end
		% If FSL_Output session exists
		if xASL_exist(fullfile(sessionPaths{iSession}, 'FSL_Output'), 'dir')
			% Then unlink all symbolic subdirs
			latestPaths = xASL_adm_GetFileList(fullfile(sessionPaths{iSession}, 'FSL_Output'), '^step.*latest', 'FPList', [], true);
			for iLatest = 1:length(latestPaths)
				system(['unlink ' latestPaths{iLatest}]);
			end
		end
	end
end
end