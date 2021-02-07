% Custom analysis Sleep 2018

%% -----------------------------------------------------------------------------------
%% 1) Average T1s
xASL.ROOT    = 'C:\Backup\ASL\Sleep_2018\analysis';
Flist           = xASL_adm_GetFileList(xASL.ROOT,'^T1\.nii','FPListRec');

for iL=1:length(Flist)
    clear tIM
    xASL_TrackProgress(iL,length(Flist));
    [Fpath Ffile Fext]  = xASL_fileparts(Flist{iL});
    tIM                 = xASL_io_Nifti2Im(Flist{iL});
    BackupName          = fullfile(Fpath,[Ffile '_backup.nii.gz']);
    xASL_Copy(Flist{iL},BackupName);
    xASL_io_SaveNifti(Flist{iL},Flist{iL},mean(tIM,4),[],0);
end

%% 2) Move M0s
xASL.ROOT    = 'C:\Backup\ASL\Sleep_2018\analysis';
Dlist           = xASL_adm_GetFsList(xASL.ROOT,'^Sub-\d{5}_\d$',1);

for iD=62:63 % 1:length(Dlist)
    xASL_TrackProgress(iD,length(Dlist));
    clear tIM
    ASLname     = fullfile('','ASL4D.nii');
    BackupName  = fullfile(xASL.ROOT,Dlist{iD},'ASL_1','ASL4D_Backup.nii.gz');
    xASL_Copy(ASLname,BackupName);
    M0name      = fullfile(xASL.ROOT,Dlist{iD},'ASL_1','M0.nii');
    tIM         = xASL_io_Nifti2Im(ASLname);
    xASL_io_SaveNifti(ASLname,M0name ,tIM(:,:,:,1),[],0);
    xASL_io_SaveNifti(ASLname,ASLname,tIM(:,:,:,4:end),[],0);

    ASLparmsFile    = fullfile(xASL.ROOT,Dlist{iD},'ASL_1','ASL4D_parms.mat');
    M0parmsFile     = fullfile(xASL.ROOT,Dlist{iD},'ASL_1','M0_parms.mat');
    xASL_Copy(ASLparmsFile,M0parmsFile);
end


% %% 3) Flipsign CBF images
% Flist   = xASL_adm_GetFileList(xASL.PopDir,'^qCBF_untreated.*\.(nii|nii\.gz)$');
% for iL=1:length(Flist)
%     xASL_TrackProgress(iL,length(Flist));
%     xASL_io_SaveNifti(Flist{iL},Flist{iL}, abs(xASL_io_Nifti2Im(Flist{iL})),[],0);
% end
