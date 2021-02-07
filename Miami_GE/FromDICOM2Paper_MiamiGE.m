ExploreASL_Master('',0); % initialize ExploreASL paths etc
% The ExploreASL import has a nice flexible regular expression structure,
% which takes some time to understand. Unfortunately it works based on
% folder and file names only, so as a quick fix the next script check the
% SeriesDescription (or ProtocolName) for each dicom and puts it in a
% folder with this name).
/CustomScripts/ConvertDicomFolderStructure_CarefulSlow('PathDICOMs'); % this can be replaced by a faster step that performs this per folder instead of per DICOM, this is a bit overkill QC
% Make sure that all folders and subfolders are converted. This will allow
% us to set the correct folders for ASL, FLAIR & T1w
% create a general study folder (e.g. c:\BackupWork\ASL in this example)
% Make a study folder that has the same name as the "StudyID" used inside
% ExploreASL_ImportConfig.m
% put the DICOM data in a raw subfolder ( c:\BackupWork\ASL\QSMSC\raw'
% Then run:
/ExploreASL_Import(ExploreASL_ImportConfig('c:\BackupWork\ASL\Miami_GE')); % in this example. Important to provide the full path, and last folder/layer is the study ID
% this should convert all to NIfTI in the c:\BackupWork\ASL\QSMSC\analysis\
% folder
% see in 'C:\BackupWork\ASL\QSMSC\analysis\ -\ Copy' how this should look
% Now you need to split the M0 & ASL data (recorded in the same scan run):
xASL_io_SplitASL_M0('C:\BackupWork\ASL\Miami_GE\analysis\RMCI_HIM_409\ASL_1\ASL4D.nii',[2]); % meaning that the first 2 volumes are M0 (this will always be the case, unless Philips changes this in a future update...)
% move the DataPar.m file into the analysis folder (this will be the
% analysis root folder) see in /CustomScripts/Miami_GE/DataPar.m for a copy
ExploreASL_Master('C:\BackupWork\ASL\Miami_GE\analysis\DataPar.m');
% now it should run, after finishingd Compare the result with C:\BackupWork\ASL\QSMSC\analysis