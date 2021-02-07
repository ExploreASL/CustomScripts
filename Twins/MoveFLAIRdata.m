%% FLAIR

InDir       = '/home/s.ingala/data/Twins/WMH/FLAIR';
OutDir      = '/home/s.ingala/data/Twins/';

unpacked_files = xASL_adm_UnzipOrCopy(InDir, '*.gz',InDir);

FileList    = xASL_adm_GetFileList(InDir,'^FLAIR_\d{3}\.(nii|nii\.gz)$');

for ii=1:length(FileList)
    clear NewDir NewName path file ext
    delete([FileList{ii} '.gz']);
    [path file ext]     = fileparts(FileList{ii});
    NewDir     = fullfile(OutDir,['EMI_' file(7:9)]);
    if  isdir(NewDir)
        NewFile     = fullfile(NewDir,'FLAIR.nii');
        xASL_Move(FileList{ii},NewFile,1);
    end
end

%% Lesion segmentation

InDir       = '/home/s.ingala/data/Twins/WMH/LesionSeg';
OutDir      = '/home/s.ingala/data/Twins/';

unpacked_files = xASL_adm_UnzipOrCopy(InDir, '*.gz',InDir);


FileList    = xASL_adm_GetFileList(InDir,'^LesionCorrected.*\.(nii|nii\.gz)$');

for ii=1:length(FileList)
    clear NewDir NewName path file ext
    delete([FileList{ii} '.gz']);
    [path file ext]     = fileparts(FileList{ii});
    NewDir     = fullfile(OutDir,['EMI_' file(64:66)]);
    if  isdir(NewDir)
        NewFile     = fullfile(NewDir,'WMH_SEGM.nii');
        xASL_Move(FileList{ii},NewFile,1);
    end
end
