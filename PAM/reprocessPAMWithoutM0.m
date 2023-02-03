% Specify the data folder
pathRoot = '/pet/projekte/asl/data/PAM/lastVersionTest';

% Go through all subjects

subjectList = xASL_adm_GetFileList(fullfile(pathRoot,'derivatives','ExploreASL'),'^sub-.+$',false,[],true);
		
% Go through all subjects
for iSubject = 1:length(subjectList)
	nameSubject = subjectList{iSubject};
	
	% Delete the M0 files
	xASL_delete(fullfile(pathRoot,'derivatives','ExploreASL',nameSubject,'ASL_1','M0.json'));
	xASL_delete(fullfile(pathRoot,'derivatives','ExploreASL',nameSubject,'ASL_1','M0.nii'));
	xASL_delete(fullfile(pathRoot,'derivatives','ExploreASL',nameSubject,'ASL_1','rM0.nii'));
	
	% Modify the ASL.json
	% Correct M0 type
	if xASL_exist(fullfile(pathRoot,'derivatives','ExploreASL',nameSubject,'ASL_1','ASL4D.json'))
		jsonASL = xASL_io_ReadJson(fullfile(pathRoot,'derivatives','ExploreASL',nameSubject,'ASL_1','ASL4D.json'));
		if isfield(jsonASL,'M0Type')
			jsonASL = rmfield(jsonASL,'M0Type');
		end
		if isfield(jsonASL,'M0Estimate')
			jsonASL = rmfield(jsonASL,'M0Estimate');
		end
		jsonASL.M0 = 'UseControlAsM0';
		
		% Round the BSup Time
		jsonASL.BackgroundSuppressionPulseTime = round(jsonASL.BackgroundSuppressionPulseTime*1000)/1000;
		xASL_io_WriteJson(fullfile(pathRoot,'derivatives','ExploreASL',nameSubject,'ASL_1','ASL4D.json'),jsonASL);
	end
	
	% Delete the locks for the ASL module
	xASL_delete(fullfile(pathRoot,'derivatives','ExploreASL','lock','xASL_module_ASL',nameSubject),true);
end

%%
% Rerun the ASL module
ExploreASL(pathRoot,0,[0 1 0]);
