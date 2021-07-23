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
	xDoc = xmlread(xmlFile);
	allListItems = getElementsByTagName(xDoc,'listitem');


end




end


