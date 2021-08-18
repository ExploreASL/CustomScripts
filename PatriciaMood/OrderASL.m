%% Admin
studyROOT = '/pet/projekte/asl/data/Mood';
% Note that the DICOM data should be put in a subfolder 'originaldata' - i.e. '.../Mood/originaldata'
ExploreASL_Initialize();
%% BEFORE IMPORT

subjectList = xASL_adm_GetFsList(fullfile(studyROOT,'originaldata'),'^SUB\d{3}$',1);

% Create a folder for sorted data
xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata'));

% Go through all subjects
for iSubject = 1:length(subjectList)
    % Put all labels to a single directory
	xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata',subjectList{iSubject},'ASL_TI1700'));
	
    fileList  = xASL_adm_GetFsList( fullfile(studyROOT,'originaldata',subjectList{iSubject}),'^NS_TE00_TI1700_\d{4}$',1);
    for iFile=1:length(fileList)
		%xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},['ASL_TI1700' num2str(iFile,'%.2d')],1);
		xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'ASL_TI1700'),1);
	end

	% Put all controls to a single directory
	xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata',subjectList{iSubject},'ASL_TI1700'));
	
    fileList  = xASL_adm_GetFsList( fullfile(studyROOT,'originaldata',subjectList{iSubject}),'^SS_TE00_TI1700_\d{4}$',1);
    for iFile=1:length(fileList)
		%xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},['ASL_TI1700' num2str(iFile,'%.2d')],1);
		xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'ASL_TI1700'),1);
	end
	
	% Put all M0s to a single directory
	xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata',subjectList{iSubject},'M0_TI5000_AP'));
	xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata',subjectList{iSubject},'M0_TI5000_PA'));
	xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata',subjectList{iSubject},'M0_TI5000_LR'));
	xASL_adm_CreateDir(fullfile(studyROOT,'sourcedata',subjectList{iSubject},'M0_TI5000_RL'));
	
    fileList  = xASL_adm_GetFsList( fullfile(studyROOT,'originaldata',subjectList{iSubject}),'^SS_TE00_TI5000_\d{4}$',1);
    for iFile=1:length(fileList)
		switch(iFile)
			case 1
				xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'M0_TI5000_AP'),1);
			case 2
				xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'M0_TI5000_PA'),1);
			case 3
				xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'M0_TI5000_LR'),1);
			case 4
				xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{iFile}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'M0_TI5000_RL'),1);
		end
	end
	
	% And copy the T1w data
	fileList  = xASL_adm_GetFsList( fullfile(studyROOT,'originaldata',subjectList{iSubject}),'^T1_MPRAGE.*',1);
	xASL_Copy( fullfile(studyROOT, 'originaldata',subjectList{iSubject},fileList{1}), fullfile(studyROOT, 'sourcedata',subjectList{iSubject},'T1_MPRAGE'),1);
end
%% PREPARE THE IMPORT JSONS
sourceStructure.folderHierarchy = {'^(.)+$','^(ASL_TI1700|T1_MPRAGE|M0_TI5000_AP|M0_TI5000_PA)$'};
sourceStructure.tokenOrdering = [1,0,0,2];
sourceStructure.tokenSessionAliases = {'',''};
sourceStructure.tokenScanAliases = {'^ASL_TI1700$','ASL4D','^T1_MPRAGE$','T1w','^M0_TI5000_AP$','M0','^M0_TI5000_PA$','M0-PA'};
sourceStructure.bMatchDirectories = true;

spm_jsonwrite(fullfile(studyROOT,'sourcestructure.json'),sourceStructure);

studyPar.DatasetType = 'raw';
studyPar.LabelingType = 'PASL';
studyPar.PostLabelingDelay = 1.8000;
studyPar.BackgroundSuppression = false;
studyPar.BolusCutOffFlag = true;
studyPar.BolusCutOffDelayTime = [0.7 1.6];
studyPar.BolusCutOffTechnique = 'Q2TIPS';
studyPar.ASLContext = 'label,control';
spm_jsonwrite(fullfile(studyROOT,'studyPar.json'),studyPar);

%% IMPORT DICOM TO NII
ExploreASL(studyROOT, [1 0 0 0],0);

%% IMPORT NII TO BIDS
ExploreASL(studyROOT, [0 1 0 0],0);

%% IMPORT BIDS to Legacy
ExploreASL(studyROOT, [0 0 0 1],0);

%% RUN PROCESSING
ExploreASL(studyROOT, [0 0 0 0],1);
