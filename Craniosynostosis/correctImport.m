%% Init
rawDir = '/pet/projekte/asl/data/Craniosynostosis';
%% Run the import
imPar = ExploreASL_ImportConfig(rawDir);
ExploreASL_Import(imPar,false, true, false, true, false);

%% Rename the second ASL to M0
patientNameList = xASL_adm_GetFileList(fullfile(rawDir,'analysis'), '^C.*$', 'List', [], 1);

for iL = 1:length(patientNameList)
	if exist(fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1'),'dir')
		xASL_Move(fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','ASL4D_a_2.json'),fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','M0.json'));
		xASL_Move(fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','ASL4D_a_2.nii'),fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','M0.nii'));
		xASL_Move(fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','ASL4D_1.json'),fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','ASL4D.json'));
		xASL_Move(fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','ASL4D_1.nii'),fullfile(rawDir,'analysis',patientNameList{iL},'ASL_1','ASL4D.nii'));
	end
end

%% Flip several ASLs and M0
for iL = [1,2,6,7,8,10,11,12,13,15,17,19]
	xASL_Move(fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.json'),fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.json'));
	xASL_Move(fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.nii.gz'),fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.nii.gz'));
	xASL_Move(fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','M0.json'),fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.json'));
	xASL_Move(fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','M0.nii.gz'),fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.nii.gz'));
	xASL_Move(fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.json'),fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','M0.json'));
	xASL_Move(fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.nii.gz'),fullfile(rawDir,'analysis',['Controle-' num2str(iL,'%.4d')] ,'ASL_1','M0.nii.gz'));
end

for iL = [11,12,13,14,15,17,18,19,21,23,25,27,29,30,34,35,38,39,40,43,46,48,52]
	xASL_Move(fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.json'),fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.json'));
	xASL_Move(fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.nii.gz'),fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.nii.gz'));
	xASL_Move(fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','M0.json'),fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.json'));
	xASL_Move(fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','M0.nii.gz'),fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D.nii.gz'));
	xASL_Move(fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.json'),fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','M0.json'));
	xASL_Move(fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','ASL4D2.nii.gz'),fullfile(rawDir,'analysis',['Cranio-' num2str(iL,'%.4d')] ,'ASL_1','M0.nii.gz'));
end

%% Remove all of the T1s to run an ASL analysis only...
for iL = 1:length(patientNameList)
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'T1.json'));
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'T1.nii'));
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'T1_parms.mat'));
end

for iL = 1:length(patientNameList)
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'y_T1.nii'));
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'c1T1.nii'));
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'c2T1.nii'));
end

for iL = 1:length(patientNameList)
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'FLAIR.json'));
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'FLAIR.nii'));
	xASL_delete(fullfile(rawDir,'analysis',patientNameList{iL},'FLAIR_parms.mat'));
end
%%
ExploreASL_Master('/pet/projekte/asl/data/Craniosynostosis/analysis/Craniosynostosis.json',1,1)

