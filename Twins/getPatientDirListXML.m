function patientList = getPatientDirListXML(rootDir)
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


% Individual directories
subjectDirs = xASL_adm_GetFsList(rootDir,'^.+$',true);

for iSubject = 1:numel(subjectDirs)

	% Read XML file
	xmlFile = fullfile(rootDir,subjectDirs{iSubject},'SECTRA','CONTENT.XML');
	xmlStruct = xml2struct(xmlFile);

	if isfield(xmlStruct,'content') && ...
		isfield(xmlStruct.content,'patient') && ...
		isfield(xmlStruct.content.patient,'patient_data') && ...
		isfield(xmlStruct.content.patient.patient_data,'personal_id')
		thisPatientID = xmlStruct.content.patient.patient_data.personal_id;
		fprintf('%s ...\n',thisPatientID);
	else
		warning('It was not possible to extract the patient ID...');
		thisPatientID = 'unknown';
	end

	patientList{iSubject,1} = thisPatientID;
	patientList{iSubject,2} = subjectDirs{iSubject};

end




end


