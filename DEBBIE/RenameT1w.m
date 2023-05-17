function RenameT1w(pathRoot)
% Goes through all subjects and renames T1w and subjects names from sub-sub* to sub*

subjectPaths = xASL_adm_GetFileList(fullfile(pathRoot, 'rawdata'), '^sub-sub.*', 'FPList', [], true);

% Go through all subjects
for iSub = 1:length(subjectPaths)
	% Find all anatomical files - irrespective of the extension
	t1Path = xASL_adm_GetFileList(fullfile(subjectPaths{iSub}, 'anat'), '^sub-sub.*', 'FPList', [], false);

	% If the files exist, rename all
	for iFile = 1:length(t1Path)
		% Then we copy the JSON to session 2
		[fPath, fName, fExt] = xASL_fileparts(t1Path{iFile});
		indexSub = regexp(fName, '^sub-sub');
		if ~isempty(indexSub)
			t1PathNew = fullfile(fPath, [fName([1:4,8:end]) fExt]);
			xASL_Move(t1Path{iFile}, t1PathNew);
		end
	end
	[fPath, fName, ~] = xASL_fileparts(subjectPaths{iSub});
	indexSub = regexp(fName, '^sub-sub');
	if ~isempty(indexSub)
		subPathNew = fullfile(fPath, fName([1:4, 8:end]));
		xASL_Move(subjectPaths{iSub}, subPathNew);
	end
end
end
