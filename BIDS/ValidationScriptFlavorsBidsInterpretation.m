Rdir = '/Users/henk/ExploreASL/FlavorDatabase';
folderList = xASL_adm_GetFileList(Rdir, '.*', 'FPList', [0 Inf], 1);
for iFolder=1:numel(folderList)
    rawdataFolder = fullfile(folderList{iFolder}, 'rawdata');
    if exist(rawdataFolder, 'dir')
        BIDS = bids.layout(rawdataFolder);
    end
end