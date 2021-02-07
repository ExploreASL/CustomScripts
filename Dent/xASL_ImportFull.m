%% Default import ExploreASL

%% Specify parameters
InputFolder = '/Users/henk/ExploreASL/ASL/Dent';
RawFolder = fullfile(InputFolder, 'raw');
bUseDCMTK = 0;
bCheckPermissions = 0;
bClone2Source = 0;
bRunDCM2NII = 1;
bCopySingleDicoms = 0;

% Define ExploreASL_Import settings
[Fpath, Ffile, Fext] = fileparts(InputFolder);
imPar.studyID = [Ffile Fext];
imPar.AnalysisRoot = Fpath;
imPar.RawRoot = Fpath;
imPar.bMatchDirectories = true;
imPar.bVerbose = true;
imPar.bOverwrite = false; % if we want to redo stuff, best to simply remove the analysisDir
imPar.SkipSubjectIfExists = true;

%% Step 1) Put the DICOMs in folders with the SeriesDescription as name, and
% add DICOM extension if needed

ConvertDicomFolderStructure_CarefulSlow(InputFolder, bUseDCMTK, 1);

%% Step 2) Move data to 'raw' folder
xASL_adm_CreateDir(RawFolder);
SubjectList = xASL_adm_GetFileList(InputFolder, '^sub-.*$', 'List', [0 Inf], true);
for iSubject=1:length(SubjectList)
    xASL_Move(fullfile(InputFolder, SubjectList{iSubject}), fullfile(RawFolder, SubjectList{iSubject}));
end


%% Step 3: here we need a recognition of the names, for now, keep this
% manual
imPar.tokenOrdering = [1 0 0 2]; % Subject Visit Session Scan
imPar.tokenSessionAliases = {''};
imPar.tokenVisitAliases = {''};
imPar.folderHierarchy = {'(sub-novaTest)' '^DICOM$' '^(3D_FLAIR|WIP_SOURCE_M0|WIP_SOURCE_3D_pCASL|cs_T1w).*$'};
imPar.tokenScanAliases = {'^cs_T1w$', 'T1'; '^3D_FLAIR$', 'FLAIR'; '^WIP_SOURCE_3D_pCASL$', 'ASL4D'; '^WIP_SOURCE_M0$', 'M0'};



%% run import script
ExploreASL_Import(imPar, bCopySingleDicoms, bUseDCMTK, bCheckPermissions, bRunDCM2NII, bClone2Source);


%% Step 4) Create data par with:

subject_regexp = '^sub-.*$';
