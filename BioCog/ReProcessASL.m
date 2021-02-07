%% Redo ASL processing

% List2Proc   = x.SUBJECTS;
List2Proc   = {''};
LOCKDIR     = fullfile(x.D.ROOT, 'lock', 'ASL');

% Restore original orientation (probably something went wrong here with
% multiple times processing of T1w by bug-fixing?
for iL=1:length(List2Proc)
    RestoreOrientation(fullfile(x.D.ROOT,List2Proc{iL},'ASL_1','ASL4D.nii'));
    RestoreOrientation(fullfile(x.D.ROOT,List2Proc{iL},'ASL_2','ASL4D.nii'));
%     RestoreOrientation(fullfile(x.D.ROOT,List2Proc{iL},'ASL_1','M0.nii'));
    
    File2Delete     = {'ASL_module.log' 'ASL4D.mat' 'despiked_ASL4D.mat' 'despiked_ASL4D.nii' 'mean_control.nii' 'mean_control_beforeMoCo.nii' 'mean_PWI_beforeMoCo.nii' 'rp_ASL4D_BeforeSpikeExclusion.txt' 'rp_ASL4D.txt' 'SD_control_beforeMoCo.nii' 'SD_PWI_beforeMoCo.nii' 'slice_gradient.mat' 'slice_gradient.nii' 'SNR_control_beforeMoCo.nii' 'SNR_PWI_beforeMoCo.nii' 'mean_PWI_Clipped.nii' 'PWI.nii' 'TempFilter_ASL4D.nii' 'TempFilter_despiked_ASL4D.nii'};
    
    
    for iF=1:length(File2Delete)
        FileNow     = fullfile(x.D.ROOT,List2Proc{iL},'ASL_1',File2Delete{iF});
        if  exist(FileNow,'file')
            delete(FileNow);
        end
        FileNow     = fullfile(x.D.ROOT,List2Proc{iL},'ASL_2',File2Delete{iF});
        if  exist(FileNow,'file')
            delete(FileNow);
        end        
    end
    


    LockDirNow  = fullfile(LOCKDIR, List2Proc{iL},'ASL_module_ASL_1');
    Flist       = xASL_adm_DeleteFileList(LockDirNow,'^(003|004|005|006|0025|0035|999)_.*\.status$');
    LockDirNow  = fullfile(LOCKDIR, List2Proc{iL},'ASL_module_ASL_2');
    Flist       = xASL_adm_DeleteFileList(LockDirNow,'^(003|004|005|006|0025|0035|999)_.*\.status$');    
end

% Remove lock files & reprocess





exclude because of artifacts
BCU015_2
BCU023_1
BCU028_2
