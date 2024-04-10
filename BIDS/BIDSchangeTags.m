pathFlavors = '/pet/projekte/asl/data/BIDS/FlavorDatabase/';
fileRegexpList = {'ASL4D.json','M0.json','ASL4D_source.json','.*asl.json','.*m0scan.json'};

% Go through all files
for iFileRegexpList = 1:numel(fileRegexpList)
	fileList = xASL_adm_GetFileList(pathFlavors, fileRegexpList{iFileRegexpList}, 'FPListRec', [], false);
	for iFileList = 1:numel(fileList)
		json = xASL_io_ReadJson(fileList{iFileList});
		bModified = false;
		if isfield(json, 'PulseSequenceType')
			switch(json.PulseSequenceType)
				case '3D_GRASE'
					json.PulseSequenceType = 'GRASE';
					bModified = true;
				case '3D_spiral'
					json.PulseSequenceType = 'spiral';
					bModified = true;
				case '2D_EPI'
					json.PulseSequenceType = 'EPI';
					bModified = true;
			end
		end
		if bModified
			xASL_io_WriteJson(fileList{iFileList}, json, true);
		end
	end
end