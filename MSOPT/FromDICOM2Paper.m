% Unzip folders

% Initialization ExploreASL
x = ExploreASL;
addpath(genpath(x.opts.MyPath));

SourcePath = '/scratch/hjmutsaerts/MSOPT/sourcedata/';
ZipList = xASL_adm_GetFileList(SourcePath, '^MSOPT.*.*\.zip$','FPList',[0 Inf], 0);
for iZip=1:numel(ZipList) % iterate over subjects
    
    OutputFileName = unzip(ZipList{iZip}, SourcePath);
    OldFolderName = fileparts(OutputFileName{1})
    [~, ZipFileName] = fileparts(ZipList{iZip});
    NewFolderName = fullfile(SourcePath, ZipFileName);
    xASL_Move(OldFolderName, NewFolderName);
    
    % feedback to screen
    fprintf(['Running subject ' ZipFileName '\n']);

    % delete zip file
    xASL_delete(ZipList{iZip});

    % Put DICOMs in foldernames with SeriesDescription as foldername

    ConvertDicomFolderStructure_CarefulSlow(NewFolderName, 1, 1);
end

