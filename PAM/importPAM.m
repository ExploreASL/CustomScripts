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
importTypes = {'11','12','13','21','22','23'};

for iType = 1:length(importTypes)
	% Rename the correct one
	xASL_Move(fullfile(pathRoot,['studyPar' importTypes{iType} '.json']), fullfile(pathRoot,'studyPar.json'));
	xASL_Move(fullfile(pathRoot,['sourcedata' importTypes{iType}]), fullfile(pathRoot,'sourcedata'));
	
	ExploreASL(pathRoot,1,0);
	
	% Return back
	xASL_Move(fullfile(pathRoot,'studyPar.json'), fullfile(pathRoot,['studyPar' importTypes{iType} '.json']));
	xASL_Move(fullfile(pathRoot,'sourcedata'), fullfile(pathRoot,['sourcedata' importTypes{iType}]));
end

%% Run the processing
ExploreASL(pathRoot,0,1);