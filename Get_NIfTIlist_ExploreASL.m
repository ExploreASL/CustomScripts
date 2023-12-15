%% Create overview list of stored NIfTIs

ExploreASL;

RootFolder = '/Users/hjmutsaerts/ExploreASL/TestDataSet_DELETEME/derivatives/ExploreASL';
IndexIs = length(RootFolder)+1;
NIfTIlist = xASL_adm_GetFileList(RootFolder, '.*\.nii', 'FPListRec');

FullList = {'FileName' 'Size (Mb)'};


for iNii=1:length(NIfTIlist)
    [FolderList{iNii}, fileList{iNii}] = xASL_fileparts(NIfTIlist{iNii});
    fileList{iNii} = fullfile(FolderList{iNii}(IndexIs:end), [fileList{iNii} '.nii.gz']);
    tempDir = dir(NIfTIlist{iNii});
    Mb = round(tempDir.bytes/1024^2, 2);
    FullList{iNii+1,1} = fileList{iNii};
    FullList{iNii+1,2} = Mb;
end
