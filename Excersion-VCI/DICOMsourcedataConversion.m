clc
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Datafolder = '/home/mdijsselhof/lood_storage/divi/Projects/ExploreASL/ExcersionVCI/16012023/test_conversion/'; % enter location of data folder
SubjectRegExp = '^.*$'; % Regular expression to find all subjects

% New DICOM names to be copied from original DICOM names
ASLSinglePLDDICOMNewName = 'ASLSinglePLD';
ASLMultiPLDDICOMNewName = 'ASLMultiPLD';
M0DICOMNewName = 'M0';
T1DICOMNewName = 'T1w';
FLAIRDICOMNewName = 'FLAIR';

% DICOM names
ASLSinglePLDDICOMname = 'ASL PLD700 8phs'; % DICOM name for ASL sequence
ASLMultiPLDDICOMname = 'ASL PLD700 8phs'; % DICOM name for ASL sequence
M0DICOMname = 'M0 meting SENSE'; % DICOM name for M0 sequence
T1DICOMname = 's T1W_3D_TFE'; % DICOM name for T1 sequence
FLAIRDICOMname = '3D_Brain_FLAIR_View_SHC'; % DICOM name for FLAIR sequence



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DICOMdata = fullfile(Datafolder,'DICOM/'); % location of sourcedata folder
SourceData = fullfile(Datafolder,'sourcedata/'); % location of sourcedata folder
xASL_adm_CreateDir(SourceData); % creates sourcedata folder


SubjectList = xASL_adm_GetFileList(DICOMdata,SubjectRegExp,'List',[],true); % all subjects

for iSubject = 1 : numel(SubjectList) % make list of session amount per subject
    SubjectPath = strcat(DICOMdata,cellstr(SubjectList(iSubject)),'/'); % subject path
    SubjectSessionAmount(iSubject,1) = numel(xASL_adm_GetFileList(SubjectPath,[],'List',[],true)); % sessions per Subject
end

% Determine Subject and Sessions number, next read DICOM to check name of
% series and create appropriate NIFTI conversion compatible filename

for Subject = 1 : numel(SubjectList)
   
    % subject details
    SubjectName = SubjectList(Subject);
    SubjectPath = strcat(DICOMdata,cellstr(SubjectName),'/'); % subject path
    SessionPathList = xASL_adm_GetFileList(SubjectPath,[],'List',[],true); % sessions per Subject
    
    % session details
    for iSession = 1:SubjectSessionAmount(Subject)
        
        % List scans per session
        SessionPath = strcat(SubjectPath,cellstr(SessionPathList(iSession)),'/'); % create session path
        
        DecreaseSession = 0; % Set session boolean for subject to 0
        
        % check which is baseline and follow-up
        if contains(SessionPath,'AE')
            SessionName = char(SessionPathList(iSession));
            Date = SessionName(7:14); % Extract scan date from Session for use in new foldername
            
        elseif contains(SessionPath,'UE')
            SessionName = char(SessionPathList(iSession));
            DateStart = strfind(SessionName,'20');  % find scan date
            Date = SessionName(DateStart:DateStart+7); % Extract scan date from Session for use in new foldername
        end
        
        SessionScanList = xASL_adm_GetFileList(SessionPath,[],'List',[],true);
        SessionScanAmount = size(SessionScanList,1);
        
        % New paths
        SubjectPathNew = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/'); % Conversion compatible path
        
        % read DICOM scan tags and create appropriate NIFTI conversion
        % compatible names
        for iScan = 1 : SessionScanAmount
            ScanPath = char(strcat(SessionPath,cellstr(SessionScanList(iScan)),'/DICOM/'));
            ScanDICOMfiles = xASL_adm_GetFileList(ScanPath,[],'List',[]);
            ScanDICOMpath = char(strcat(ScanPath,ScanDICOMfiles(1))); % first DICOM file
            ScanDICOM = xASL_io_DcmtkRead(ScanDICOMpath); % read DICOM file
            ScanNameDICOM = ScanDICOM.SeriesDescription; % DICOM scan name
            
            % check filename and create new filename accordingly
            if contains(ScanNameDICOM,ASLSinglePLDDICOMname)
                ScanDICOMsourcedataPath = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/Session_1/',ASLSinglePLDDICOMNewName,'/');
                xASL_Copy(ScanPath,ScanDICOMsourcedataPath);
            elseif contains(ScanNameDICOM,ASLMultiPLDDICOMname)
                ScanDICOMsourcedataPath = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/Session_1/',ASLMultiPLDDICOMNewName,'/');
                xASL_Copy(ScanPath,ScanDICOMsourcedataPath);
            elseif contains(ScanNameDICOM,M0DICOMname)
                ScanDICOMsourcedataPath = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/Session_1/',M0DICOMNewName,'/');
                xASL_Copy(ScanPath,ScanDICOMsourcedataPath);
            elseif contains(ScanNameDICOM,T1DICOMname)
                ScanDICOMsourcedataPath = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/Session_1/',T1DICOMNewName,'/');
                xASL_Copy(ScanPath,ScanDICOMsourcedataPath);
            elseif contains(ScanNameDICOM,FLAIRDICOMname)
                ScanDICOMsourcedataPath = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/Session_1/',FLAIRDICOMNewName,'/');
                xASL_Copy(ScanPath,ScanDICOMsourcedataPath);
            else
                DICOMNewName = regexprep(ScanNameDICOM,' ','_'); % replace spaces with underscores
                ScanDICOMsourcedataPath = strcat(SourceData,char(SubjectName),'_',num2str(Date),'/Session_1/',DICOMNewName,'/');
                xASL_Copy(ScanPath,ScanDICOMsourcedataPath);
            end
        end
        
        FinishMessage = ['Subject ' char(SubjectName) ' Session ' num2str(iSession) ' finished copying']; % message copying of files is finished
        disp(FinishMessage)
        
    end
    
end
