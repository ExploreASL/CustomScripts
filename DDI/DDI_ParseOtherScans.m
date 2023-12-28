x = ExploreASL;
addpath(genpath(fullfile(x.opts.MyPath, 'WorkInProgress')));

rootDir = '/data/radv/radG/RAD/share/DDI/D21L_GE_1.5T/sourcedata';

list = XASL_adm_GetFileList(rootDir, 'OtherScans', 'FPListRec', [], 1);

for iList=1:length(list)
    ConvertDicomFolderStructure_CarefulSlow(list{1}, 1);
end