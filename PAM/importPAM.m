%% Set up the directories
pathRoot = '/pet/projekte/asl/data/PAM';

%% Manually change some files with irregular names
pathOriginal = fullfile(pathRoot,'originaldata');

xASL_Move(fullfile(pathOriginal,'06006','06006_1','lwitlox-20180516_123831','06006_1'),fullfile(pathOriginal,'06006','06006_1','06006_1'));
xASL_delete(fullfile(pathOriginal,'06006','06006_1','lwitlox-20180516_123831'));
xASL_delete(fullfile(pathOriginal,'06006','06006_1','DICOM'),1);

xASL_Move(fullfile(pathOriginal,'04001','04001_1','04001_1 RDS','04001_1'),fullfile(pathOriginal,'04001','04001_1','04001_1'));
xASL_delete(fullfile(pathOriginal,'04001','04001_1','04001_1 RDS'));

%% Prepare the structure for import
rearrangeDataPAM(pathRoot);

%% Run the import for the 4 flavors
% Import from DICOM to BIDS
importTypes = {'11','12','13','21','22','23'};

for iType = 1:length(importTypes)
	% Rename the correct one
	xASL_Move(fullfile(pathRoot,['studyPar' importTypes{iType} '.json']), fullfile(pathRoot,'studyPar.json'));
	xASL_Move(fullfile(pathRoot,['sourcedata' importTypes{iType}]), fullfile(pathRoot,'sourcedata'));
	system(['rm -r ' fullfile(pathRoot,'derivatives','ExploreASL','lock','xASL_module_Import')]);
	
	% For sourcedata13 and sourcedata23, we need to reorder the NII from CCCLLL to CLCLCL
	if strcmp(importTypes{iType},'13') || strcmp(importTypes{iType},'23')
		ExploreASL(pathRoot,[1 0 0],0);
		% Go to derivatives/ExploreASL/temp a reorder everything there
		
		% Get all the subject names
		subjectList = xASL_adm_GetFileList(fullfile(pathRoot,'derivatives','ExploreASL','temp'),[],false,[],true);
		
		% Go through all subjects
		for iSubject = 1:length(subjectList)
			if xASL_exist(fullfile(pathRoot,'derivatives','ExploreASL','temp',subjectList{iSubject},'ASL_1'),'dir') &&...
				xASL_exist(fullfile(pathRoot,'derivatives','ExploreASL','temp',subjectList{iSubject},'ASL_1','ASL4D.nii'),'file')
				% Load and reorder
				imOld = xASL_io_Nifti2Im(fullfile(pathRoot,'derivatives','ExploreASL','temp',subjectList{iSubject},'ASL_1','ASL4D.nii'));
				imReorder = zeros(size(imOld));
				if (size(imOld,4))>=2
					imReorder(:,:,:,1:2:end) = imOld(:,:,:,1:(size(imOld,4)/2));
					imReorder(:,:,:,2:2:end) = imOld(:,:,:,(size(imOld,4)/2 + 1):end);
					xASL_io_SaveNifti(fullfile(pathRoot,'derivatives','ExploreASL','temp',subjectList{iSubject},'ASL_1','ASL4D.nii'),...
						fullfile(pathRoot,'derivatives','ExploreASL','temp',subjectList{iSubject},'ASL_1','ASL4D.nii'),imReorder);
				else
					warning(['Dataset ' fullfile(subjectList{iSubject},'ASL_1','ASL4D.nii') ' is expected to have more than 1 repetition']);
				end
			end
		end
		ExploreASL(pathRoot,[0 1 0 ],0);
	else
		%ExploreASL(pathRoot,[1 1 0 ],0);
		ExploreASL(pathRoot,[1 0 0],0);
		ExploreASL(pathRoot,[0 1 0],0);
	end
	
	% Return back
	xASL_Move(fullfile(pathRoot,'studyPar.json'), fullfile(pathRoot,['studyPar' importTypes{iType} '.json']));
	xASL_Move(fullfile(pathRoot,'sourcedata'), fullfile(pathRoot,['sourcedata' importTypes{iType}]));
end

%% Run import from BIDS to ASL Legacy data format
% Now that all is nicely in BIDS, we can prepare it for processing
ExploreASL(pathRoot);

%% Run the processing
ExploreASL(pathRoot,0,1);
