function rearrangeDataPAM(pathRoot)

%% Set up the directories
pathSource1 = fullfile(pathRoot,'sourcedata21');%deltaM
pathSource2 = fullfile(pathRoot,'sourcedata11');%deltaM without M0
pathSource3 = fullfile(pathRoot,'sourcedata22');%control/label
pathSource4 = fullfile(pathRoot,'sourcedata12');%control/label without M0
pathSource5 = fullfile(pathRoot,'sourcedata23');%control/label - single-file CCCLLL
pathSource6 = fullfile(pathRoot,'sourcedata13');%control/label without M0 - single-file CCCLLL
pathOriginal = fullfile(pathRoot,'originaldata');
xASL_adm_CreateDir(pathSource1);
xASL_adm_CreateDir(pathSource2);
xASL_adm_CreateDir(pathSource3);
xASL_adm_CreateDir(pathSource4);
xASL_adm_CreateDir(pathSource5);
xASL_adm_CreateDir(pathSource6);

%% Go through all subjects
listSubjects = xASL_adm_GetFileList(pathOriginal,[],'List', [], true);

for iSubject = 1:length(listSubjects)
	% Go through all sessions for each subject
	listSessions = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject}),[],'List', [], true);
	for iSession = 1:length(listSessions)
		%% If the first subdirectory is scans (e.g. 01007, 02005, 03034_2)
		listMainDir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession}),'^scans$','List', [], true);
		% And sometimes the subdirectories come before the 'scans' directory
		listMainDirAlt = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession}),'^\d{3}-.*','List', [], true);
		
		% In case the directory is 'scans/101' without sequence name added, then go for another branch
		if ~isempty(listMainDir)
			listOnlySequenceNumber = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},'scans'),'^\d{3}$','List', [], true);
		end
		
		if ~isempty(listMainDirAlt) || (~isempty(listMainDir) && isempty(listOnlySequenceNumber))
			% The look for folder names that do not start with 0, starts with three numbers and the third number is one
			%listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}(1).*$','List', [], true);
			
			if ~isempty(listMainDirAlt)
				inputPath = fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession});
			else
				inputPath = fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1});
			end			
			
			% Either finds pCASL - Flavor type 1 
			listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}(1).*pCASL.*$','List', [], true);
			if ~isempty(listSequenceDir)
				% pCASL
				outputDir = fullfile(pathSource2,listSubjects{iSubject},listSessions{iSession});
				xASL_Copy(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),fullfile(outputDir,'ASL'));
			else
				% Or finds SOURCE___ASL with full dynamics - Flavor type 2 
				listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}.*SOURCE___ASL.*$','List', [], true);
				if ~isempty(listSequenceDir) %3034_2, 6003_2
					outputDir = fullfile(pathSource3,listSubjects{iSubject},listSessions{iSession});
					xASL_Copy(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),fullfile(outputDir,'ASL'));
				else
					% Or finds -ASL_ - Flavor type 3 2005, 4001
					listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}(1).*-ASL_.*$','List', [], true);
					listFiles = xASL_adm_GetFileList(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),'^.*$','List',[],false);
					if numel(listFiles) > 1 %99001_1
						outputDir = fullfile(pathSource1,listSubjects{iSubject},listSessions{iSession});
					else
						outputDir = fullfile(pathSource5,listSubjects{iSubject},listSessions{iSession});
					end
					if ~isempty(listSequenceDir)
						xASL_Copy(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),fullfile(outputDir,'ASL'));
					else
						fprintf(['Missing ASL for ' listSessions{iSession} '\n']);
					end
				end
				
				% -M0_
				listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}(1).*-M0_.*$','List', [], true);
				if ~isempty(listSequenceDir)
					xASL_Copy(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),fullfile(outputDir,'M0'));
				else
					fprintf(['Missing M0 for ' listSessions{iSession} '\n']);
				end
			end
			% T1W_3D_TFE
			listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}(1).*T1W_3D_TFE.*$','List', [], true);
			if ~isempty(listSequenceDir)
				xASL_Copy(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),fullfile(outputDir,'T1w'));
			else
				fprintf(['Missing T1w for ' listSessions{iSession} '\n']);
			end
				
			% T2_FLAIR
			listSequenceDir = xASL_adm_GetFileList(inputPath,'^(?!(0))\d{1}\d{1}(1).*T2_FLAIR.*$','List', [], true);
			if ~isempty(listSequenceDir)
				xASL_Copy(fullfile(inputPath,listSequenceDir{1},'resources','DICOM','files'),fullfile(outputDir,'FLAIR'));
			else
				fprintf(['Missing FLAIR for ' listSessions{iSession} '\n']);
			end

		else
			%% If the first subdirectory is DICOM (e.g. 01001, 03034_1)
			listMainDir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession}),'^DICOM$','List', [], true);
			if ~isempty(listMainDir)
				% And then all sequences are mixed in a single directory, each in a single DICOM file
				listSequences = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1}),'^IM.*_.*$','List', [], false);
				cellSequence = cell(length(listSequences),2);
				% Go through all files
				for iSequence = 1:length(listSequences)
					% Read with DCMTK
					headerDCM = xASL_io_DcmtkRead(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1},listSequences{iSequence}),0);
					% Read and save all sequence types
					if ~isempty(headerDCM.SeriesDescription)
						cellSequence{iSequence,1} = headerDCM.SeriesDescription;
					else
						cellSequence{iSequence,1} = headerDCM.ProtocolName;
					end
					cellSequence{iSequence,2} = listSequences{iSequence};
				end
				% Check if we have the pCASL or SOURCE or ASL type and send to the correct flavor
				bSearchM0 = 0;
				if sum(cellfun(@(y) ~isempty(strfind(y,'SOURCE')),cellSequence(:,1)))  %2021_1, 3034_1
					listFiles = find(cellfun(@(y) ~isempty(strfind(y,'SOURCE')),cellSequence(:,1)));
					if numel(listFiles)>1
						outputDir = fullfile(pathSource3,listSubjects{iSubject},listSessions{iSession});
					else
						outputDir = fullfile(pathSource5,listSubjects{iSubject},listSessions{iSession});
					end
					bSearchM0 = 1;
					copy_single_DICOM(cellSequence, 'SOURCE', 'ASL', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, outputDir);
				elseif sum(cellfun(@(y) ~isempty(strfind(y,'pCASL')),cellSequence(:,1))) % 1001
					outputDir = fullfile(pathSource6,listSubjects{iSubject},listSessions{iSession});
					copy_single_DICOM(cellSequence, 'pCASL', 'ASL', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, outputDir);
				elseif sum(cellfun(@(y) ~isempty(strfind(y,'ASL')),cellSequence(:,1))) % 2008_2, 3026_1
					outputDir = fullfile(pathSource1,listSubjects{iSubject},listSessions{iSession});
					bSearchM0 = 1;
					copy_single_DICOM(cellSequence, 'ASL', 'ASL', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, outputDir);
				else
					outputDir = fullfile(pathSource1,listSubjects{iSubject},listSessions{iSession});
				end
				
				% If M0 expected than copy it
				if bSearchM0
					copy_single_DICOM(cellSequence, 'M0', 'M0', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, outputDir);
				end
				
				% Copy also T1w and FLAIR
				copy_single_DICOM(cellSequence, 'T1W_3D', 'T1W', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, outputDir);
				copy_single_DICOM(cellSequence, 'FLAIR', 'FLAIR', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, outputDir);
			else
				%% If the first subdirectory is number of format like 1160867_1 or 0240058 and then either scans or subdirectories (e.g. 01008, 02008, 04001, 06006)
				listMainDir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession}),'^\d{5}.*$','List', [], true);
				if ~isempty(listMainDir)
					% Some have an extra subdirectory 'scans'
					listScanDir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1}),'^scans$','List', [], true);
					if ~isempty(listScanDir)
						listMainDir{1} = fullfile(listMainDir{1},listScanDir{1});
					end
				else
					% Or go for a dir that starts directly with 'scans'
					listMainDir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession}),'^scans$','List', [], true);
				end
				if ~isempty(listMainDir)
					
					% And then subdirectories have sequence numbers, but without sequence names
					% Go through all directories with 3 numbers and more and not starting by a zero
					listSequences = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1}),'^(?!(0|I))\d{1}\d{2}.*$','List', [], true);
					% The subdirectory is them 'DICOM' or 'resources/DICOM'
					listSubdir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1},listSequences{1}),'^DICOM$','List', [], true);
					if ~isempty(listSubdir)
						subdirName = 'DICOM';
					else
						listSubdir = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1},listSequences{1},'resources','DICOM'),'^files$','List', [], true);
						if ~isempty(listSubdir)
							subdirName = fullfile('resources','DICOM','files');
						else
							subdirName = fullfile('resources','DICOM');
						end
					end
					cellSequence = cell(length(listSequences),2);
					for iSequence = 1:length(listSequences)
						% Look at the first DICOM file in 'DICOM' or 'resources/DICOM' subdirectories
						listFile = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1},listSequences{iSequence},subdirName),'^.*$','List', [], false);
						headerDCM = xASL_io_DcmtkRead(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1},listSequences{iSequence},subdirName,listFile{1}),0);
						% Read and save all sequence types
						if ~isempty(headerDCM.SeriesDescription)
							cellSequence{iSequence,1} = headerDCM.SeriesDescription;
						else
							cellSequence{iSequence,1} = headerDCM.ProtocolName;
						end
						cellSequence{iSequence,2} = listSequences{iSequence};
					end
					
					% Make a list of directories and sort them then
					% Check if we have the pCASL or SOURCE or ASL type and send to the correct flavor
					bSearchM0 = 0;
					if sum(cellfun(@(y) ~isempty(strfind(y,'SOURCE')),cellSequence(:,1))) %3048_1, 6002_2
						outputDir = fullfile(pathSource3,listSubjects{iSubject},listSessions{iSession});
						bSearchM0 = 1;
						copy_single_DIR(cellSequence, 'SOURCE', 'ASL', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, subdirName, outputDir);
					elseif sum(cellfun(@(y) ~isempty(strfind(y,'pCASL')),cellSequence(:,1))) %1008
						outputDir = fullfile(pathSource4,listSubjects{iSubject},listSessions{iSession});
						copy_single_DIR(cellSequence, 'pCASL', 'ASL', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, subdirName, outputDir);
					elseif sum(cellfun(@(y) ~isempty(strfind(y,'ASL')),cellSequence(:,1)))
						% Those with 19 files exactly put to deltaM folder
						iSequence = find(cellfun(@(y) ~isempty(strfind(y,'ASL')),cellSequence(:,1)));
						listFile = xASL_adm_GetFileList(fullfile(pathOriginal,listSubjects{iSubject},listSessions{iSession},listMainDir{1},listSequences{iSequence},subdirName),'^.*$','List', [], false);
						if length(listFile) == 19 %4001
							outputDir = fullfile(pathSource1,listSubjects{iSubject},listSessions{iSession});
						else %2008_1, 6006_1
							outputDir = fullfile(pathSource3,listSubjects{iSubject},listSessions{iSession});
						end
						bSearchM0 = 1;
						copy_single_DIR(cellSequence, 'ASL', 'ASL', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, subdirName, outputDir);
					else
						outputDir = fullfile(pathSource1,listSubjects{iSubject},listSessions{iSession});
					end
					
					% If M0 expected than copy it
					if bSearchM0
						copy_single_DIR(cellSequence, 'M0', 'M0', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, subdirName, outputDir);
					end
					
					% Copy also T1w and FLAIR
					copy_single_DIR(cellSequence, 'T1W_3D', 'T1W', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, subdirName, outputDir);
					copy_single_DIR(cellSequence, 'FLAIR', 'FLAIR', pathOriginal, listSubjects{iSubject}, listSessions{iSession}, listMainDir{1}, subdirName, outputDir);
					
				else
					fprintf(['Type of directory structure not recognized ' listSessions{iSession} '\n']);
				end
			end
		end
	end
end

end

function copy_single_DICOM(cellSequence, seqWild, seqName, pathOriginal, subjectName, sessionName, mainDir, outputDir)

iSequence = find(cellfun(@(y) ~isempty(strfind(y,seqWild)),cellSequence(:,1)));
if ~isempty(iSequence)
	if length(iSequence)>1
		iExclude = find(cellfun(@(y) ~isempty(strfind(y,'WIP')),cellSequence(:,1)));
		
		iSequenceClean = iSequence; %copy the original sequence list
		% Exclude those with unwanted strings
		for iEx = 1:length(iExclude)
			iSequenceClean(iSequenceClean == iExclude(iEx)) = 0;
		end
		iSequenceClean = iSequenceClean(iSequenceClean ~=0);
		
		if length(iSequenceClean) == 1
			xASL_Copy(fullfile(pathOriginal,subjectName,sessionName,mainDir,cellSequence{iSequenceClean,2}),fullfile(outputDir,seqName,cellSequence{iSequenceClean,2}));
		else
			if strcmp(seqWild,'SOURCE') || strcmp(seqWild,'M0') || length(iSequenceClean) > 10
				% But it is OK for ASL - SOURCE or M0...
				for iSC = 1:length(iSequenceClean)
					xASL_Copy(fullfile(pathOriginal,subjectName,sessionName,mainDir,cellSequence{iSequenceClean(iSC),2}),fullfile(outputDir,seqName,cellSequence{iSequenceClean(iSC),2}));
				end
			else
				% In case of repeated entries, keep skipping
				fprintf(['Error. Session ' sessionName '. Found multiple ' seqWild ', using the first one.\n']);
				xASL_Copy(fullfile(pathOriginal,subjectName,sessionName,mainDir,cellSequence{iSequenceClean(1),2}),fullfile(outputDir,seqName,cellSequence{iSequenceClean(1),2}));
			end
		end
	else
		xASL_Copy(fullfile(pathOriginal,subjectName,sessionName,mainDir,cellSequence{iSequence,2}),fullfile(outputDir,seqName,cellSequence{iSequence,2}));
	end
else
	fprintf(['Session ' sessionName '. Found no ' seqWild '\n']);
end

end

function copy_single_DIR(cellSequence, seqWild, seqName, pathOriginal, subjectName, sessionName, mainDir, subdirName, outputDir)

iSequence = find(cellfun(@(y) ~isempty(strfind(y,seqWild)),cellSequence(:,1)));
if ~isempty(iSequence)
	if length(iSequence)>1
		fprintf(['Session ' sessionName '. Found multiple ' seqWild '\n']);
		iSequence = iSequence(1);
	end
	xASL_Copy(fullfile(pathOriginal,subjectName,sessionName,mainDir,cellSequence{iSequence,2}, subdirName),fullfile(outputDir,seqName));
else
	fprintf(['Session ' sessionName '. Found no ' seqWild '\n']);
end

end