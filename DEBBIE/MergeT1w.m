function MergeT1w(pathRoot, pathRawdata)
% Get T1ws from the rawdata and move to the appropriate folder if possible
% RenameT1w('/pet/projekte/asl/data/LCBC/part0','/pet/projekte/asl/data/LCBC/rawdata');

% Read subjects in the destination folder
subjectPaths = xASL_adm_GetFileList(fullfile(pathRoot, 'rawdata'), '^sub.*', 'FPList', [], true);

% Go through all subjects
for iSub = 1:length(subjectPaths)
	[~, subjectName,~] = xASL_fileparts(subjectPaths{iSub});
	% Check if a counterpart is found in the pathRawdata folder. if yes, then move it
	if exist(fullfile(pathRawdata, subjectName), 'dir')
		% Check if there are files in the anat folder and move them then
		t1Path = xASL_adm_GetFileList(fullfile(pathRawdata, subjectName, 'anat'), '^sub.*', 'FPList', [], false);
		xASL_adm_CreateDir(fullfile(subjectPaths{iSub}, 'anat'));
		for iFile = 1:length(t1Path)
			[fPath, fName, fExt] = xASL_fileparts(t1Path{iFile});
			xASL_Move(t1Path{iFile}, fullfile(subjectPaths{iSub}, 'anat', [fName, fExt]), true, true);
			fprintf('Move %s to %s\n', t1Path{iFile},  fullfile(subjectPaths{iSub}, 'anat', [fName, fExt]));
		end
	end
		
end
end
