clc
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Datafolder = '/home/mdijsselhof/lood_storage/divi/Projects/ExploreASL/ExcersionVCI/16012023/test_conversion/'; % enter location of data folder
Datafolder = '/home/janpetr/tmp/Excersion-VCI/ExcersionSubjects/';
SubjectRegExp = '^.*$'; % Regular expression to find all subjects

% New DICOM names to be copied from original DICOM names
nameConversionTable{1,1} = 'ASL SENSE';
nameConversionTable{1,2} = 'ASLSinglePLD';
nameConversionTable{2,1} = 'M0 meting SENSE';
nameConversionTable{2,2} = 'M0SinglePLD';
nameConversionTable{3,1} = 'ASL PLD700 8phs';
nameConversionTable{3,2} = 'ASLMultiPLD';
nameConversionTable{4,1} = 'ASL IR';
nameConversionTable{4,2} = 'M0MultiPLD';
nameConversionTable{5,1} = 'T1W';
nameConversionTable{5,2} = 'T1Wstruct';
nameConversionTable{6,1} = 'FLAIR';
nameConversionTable{6,2} = 'FLAIRstruct';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DICOMdata = fullfile(Datafolder, 'DICOM'); % location of sourcedata folder
SourceData = fullfile(Datafolder, 'sourcedata'); % location of sourcedata folder
xASL_adm_CreateDir(SourceData); % creates sourcedata folder

SubjectFirstList = xASL_adm_GetFileList(DICOMdata, SubjectRegExp,'List',[],true); % all subjects

for iSubjectFirst = 1 : numel(SubjectFirstList)
	SubjectList = xASL_adm_GetFileList(fullfile(DICOMdata, SubjectFirstList{iSubjectFirst}), SubjectRegExp,'List',[],true); % all subjects

	% Determine Subject and Sessions number, next read DICOM to check name of
	% series and create appropriate NIFTI conversion compatible filename

	for iSubject = 1 : numel(SubjectList)
		% subject details
		SubjectName = SubjectList{iSubject};
		SubjectPath = fullfile(DICOMdata, SubjectFirstList{iSubjectFirst}, SubjectName, 'scans'); % subject path
		SequenceList = xASL_adm_GetFileList(SubjectPath,[],'List',[],true); % sessions per Subject

		% session details
		for iSequence = 1:numel(SequenceList)
			ScanPath = fullfile(SubjectPath, SequenceList{iSequence}, 'resources', 'DICOM');
			ScanDICOMfiles = xASL_adm_GetFileList(ScanPath,[],'List',[]);
			if ~isempty(ScanDICOMfiles)
				ScanDICOM = xASL_io_DcmtkRead(fullfile(ScanPath, ScanDICOMfiles{1})); % read DICOM file
				ScanName = ScanDICOM.SeriesDescription; % DICOM scan name

				bConverted = 0;
				for iConversion = 1:size(nameConversionTable,1)
					if ~isempty(regexpi(ScanName, nameConversionTable{iConversion,1})) && ~bConverted
						xASL_Copy(ScanPath, fullfile(SourceData, SubjectName, nameConversionTable{iConversion, 2}));
						bConverted = 1;
					end
				end
			end
		end

		FinishMessage = ['Subject ' char(SubjectName) ' finished copying']; % message copying of files is finished
		disp(FinishMessage)

	end
end

