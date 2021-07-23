function patientList = getPatientDirListXML(rootDir,outputDir)
%getPatientDirListXML Get patient dir list
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Get patient dir list.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

% Warning
fprintf('Reading all XML files can take a while, checking if the file a label file exists already...\n');

if exist(fullfile(outputDir,'labels.tsv'),'file')
	patientList = xASL_tsvRead(fullfile(outputDir,'labels.tsv'));
else

	% Individual directories
	subjectDirs = xASL_adm_GetFsList(rootDir,'^.+$',true);

	patientList{1,1} = 'PatientID';
	patientList{1,2} = 'PatientSex';
	patientList{1,3} = 'PatientDir';

	for iSubject = 1:numel(subjectDirs)

		% Read XML file
		xmlFile = fullfile(rootDir,subjectDirs{iSubject},'SECTRA','CONTENT.XML');
		xmlStruct = xml2struct(xmlFile);

		if isfield(xmlStruct,'content') && ...
			isfield(xmlStruct.content,'patient') && ...
			isfield(xmlStruct.content.patient,'patient_data') && ...
			isfield(xmlStruct.content.patient.patient_data,'personal_id')
			thisPatientID = xmlStruct.content.patient.patient_data.personal_id.Text;
			thisSex = xmlStruct.content.patient.patient_data.sex.Text;
			fprintf('%s ...\n',thisPatientID);
		else
			warning('It was not possible to extract the patient ID...');
			thisPatientID = 'unknown';
			thisSex = 'unknown';
		end

		patientList{iSubject+1,1} = thisPatientID;
		patientList{iSubject+1,2} = thisSex;
		patientList{iSubject+1,3} = subjectDirs{iSubject};

	end

	xASL_tsvWrite(patientList,fullfile(outputDir,'labels.tsv'));

end


end


