RootDir  = 'C:\Backup\ASL\Hardy\CMI_substudy\lock\Struct';
Flist    = xASL_adm_GetFileList(RootDir,'^0075.*\.status$','FPListRec',[0 Inf]);

DeleteLockList  = {'999_ready.status' '010_visualize.status' '009_reslice2DARTEL.status' '008_TissueVolume.status' '007_segment_T1w.status' '0075_Lesion_removal.status'};

for iL=1:length(Flist)
    [Fpath Ffile Fext]  = xASL_fileparts(Flist{iL});
    
    % Redo partly structural module
    for iLD=1:length(DeleteLockList)
        LockFile2Del    = fullfile(Fpath,DeleteLockList{iLD});
        if  exist(LockFile2Del,'file'); delete(LockFile2Del); end
    end    
end
