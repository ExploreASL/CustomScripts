
mdir    = 'C:\Backup\ASL\StreamVCI\analysis';

%% Create directories
for iL=1:31
    DirName     = fullfile(mdir,sprintf('%03d',iL) );
    xASL_adm_CreateDir(DirName);
    ASLdir      = fullfile(mdir,sprintf('%03d',iL), 'ASL_1');
    xASL_adm_CreateDir(ASLdir);
end

ldir    = 'C:\Backup\ASL\StreamVCI\lesion';

%% Move Lesions
Flist   = xASL_adm_GetFileList(ldir,'Lesion.*\.nii\.gz');

for iL=1:length(Flist)
    [Fpath, Ffile,  Fext]   = xASL_fileparts(Flist{iL});
    NewPath                 = fullfile(mdir,Ffile(end-2:end),'WMH_SEGM.nii.gz');
    xASL_Move(Flist{iL},NewPath);
end

%% Move FLAIRas (already in T1 space, resampled by Carole)
Flist   = xASL_adm_GetFileList(ldir,'FLAIR.*\.nii\.gz');

for iL=1:length(Flist)
    [Fpath, Ffile,  Fext]   = xASL_fileparts(Flist{iL});
    NewPath                 = fullfile(mdir,Ffile(end-2:end),'FLAIR.nii.gz');
    xASL_Move(Flist{iL},NewPath);
end


%% Rename T1 files
Dlist   = xASL_adm_GetFsList(mdir,'\d{3}',1);
for iL=1:length(Dlist)
    AnatDir = fullfile(mdir,Dlist{iL});
    Flist   = xASL_adm_GetFileList(AnatDir,'T1','FPList',[0 Inf]);
    if ~isempty(Flist)
        Flist   = Flist{1};
        [Fpath, Ffile, Fext]    = xASL_fileparts(Flist);
        if  isempty(strfind(Ffile,'FLAIR')) && isempty(strfind(Ffile,'WMH_SEGM'))
            NewPath             = fullfile(AnatDir,'T1.nii.gz');
            xASL_Move(Flist,NewPath);
        end
    end
end

%% Rename ASL files
Dlist   = xASL_adm_GetFsList(mdir,'\d{3}',1);
for iL=1:length(Dlist)
    ASLDir = fullfile(mdir,Dlist{iL}, 'ASL_1');
    Flist   = xASL_adm_GetFileList(ASLDir,'.*','FPList',[0 Inf]);
    if  length(Flist)==1
        ASLPath     = fullfile(ASLDir,'ASL4D.nii');
        M0Path      = fullfile(ASLDir,'M0.nii');

        IM          = xASL_io_Nifti2Im(Flist{1});
        xASL_io_SaveNifti(Flist{1}, ASLPath, IM(:,:,:,1),[],0);
        xASL_io_SaveNifti(Flist{1}, M0Path , IM(:,:,:,2),[],0);
    end
end
