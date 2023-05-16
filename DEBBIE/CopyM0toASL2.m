function CopyM0toASL2(pathRoot)
% Goes through all subjects in the derivatives directory and all ASL sessions and removes all FSL symbolic links

subjectPaths = xASL_adm_GetFileList(fullfile(pathRoot, 'rawdata'), '^sub.*', 'FPList', [], true);

% Go through all subjects
for iSub = 1:length(subjectPaths)
	% Find ASL sessions
	m0Path = xASL_adm_GetFileList(fullfile(subjectPaths{iSub}, 'perf'), '^.*dir-.._run-1.*.json', 'FPList', [], false);

	% If the M0 file exists
	if length(m0Path)
		% There can be only one
		m0Path = m0Path{1};

		% Then we copy the JSON to session 2
		indexRun = regexp(m0Path, 'run-1');
		m0PathNew = m0Path;
		m0PathNew(indexRun+4) = '2';
		
		xASL_Copy(m0Path, m0PathNew, 1);
		
		% Copy the NII to session 2
		xASL_Copy([m0Path(1:end-4) 'nii.gz'], [m0PathNew(1:end-4) 'nii.gz'], 1);

		% Alter the JSON to point to a correct ASL
		m0Json = xASL_io_ReadJson(m0PathNew);
		indexRun = regexp(m0Json.IntendedFor, 'run-1');
		m0Json.IntendedFor(indexRun+4) = '2';
		xASL_io_WriteJson(m0PathNew, m0Json, 1);

		% Alter the JSON of ASL_2
		aslPath = xASL_adm_GetFileList(fullfile(subjectPaths{iSub}, 'perf'), '^.*run-2.*asl.*json', 'FPList', [], false);
		aslPath = aslPath{1};
		aslJson = xASL_io_ReadJson(aslPath);
		aslJson.M0Type = 'Separate';
		xASL_io_WriteJson(aslPath, aslJson, 1);

		% Check for existence of the fmap M0
		m0Path = xASL_adm_GetFileList(fullfile(subjectPaths{iSub}, 'fmap'), '^.*dir-.._run-1.*.json', 'FPList', [], false);
		if length(m0Path)

			m0Path = m0Path{1};

			% Copy the JSON of PE-rev M0
			indexRun = regexp(m0Path, 'run-1');
			m0PathNew = m0Path;
			m0PathNew(indexRun+4) = '2';

			xASL_Copy(m0Path, m0PathNew, 1);

			% Copy the NII of PE-rev M0
			xASL_Copy([m0Path(1:end-4) 'nii.gz'], [m0PathNew(1:end-4) 'nii.gz'], 1);

			% Adjust the JSON
			m0Json = xASL_io_ReadJson(m0PathNew);
			indexRun = regexp(m0Json.IntendedFor, 'run-1');
			m0Json.IntendedFor(indexRun+4) = '2';
			xASL_io_WriteJson(m0PathNew, m0Json, 1);
		end
	end
end
end