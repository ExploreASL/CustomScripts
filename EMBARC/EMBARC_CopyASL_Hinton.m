xASL_path = '/scratch/hjmutsaerts/ExploreASL';
cd(xASL_path);
ExploreASL;
RootDir = '/data/projects/EMBARC';

OriDir = fullfile(RootDir, 'data_raw', 'image03');

DestDir = '/scratch/hjmutsaerts/EMBARC/ASL';
xASL_adm_CreateDir(DestDir);rsync

% copy ASL data
FileList = xASL_adm_GetFileList(OriDir, '.*_ASL\.tgz$');
for iFile=1:numel(FileList)
    xASL_TrackProgress(iFile, numel(FileList));
    [~, Ffile, Fext] = fileparts(FileList{iFile});
    NewPath = fullfile(DestDir, [Ffile Fext]);
    xASL_Copy(FileList{iFile}, NewPath);
end

DestDir = '/scratch/hjmutsaerts/EMBARC/T1w';
xASL_adm_CreateDir(DestDir);

% copy T1w data
FileList = xASL_adm_GetFileList(OriDir, '.*_MRI\.tgz$');
for iFile=1:numel(FileList)
    xASL_TrackProgress(iFile, numel(FileList));
    [~, Ffile, Fext] = fileparts(FileList{iFile});
    NewPath = fullfile(DestDir, [Ffile Fext]);
    xASL_Copy(FileList{iFile}, NewPath);
end