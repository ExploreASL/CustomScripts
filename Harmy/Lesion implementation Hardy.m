% DATA IS COMPLETE!


%% Register brains & copy ROIs

% DDIR    = 'C:\Backup\ASL\Hardy\CMI_substudy';
% ODIR    = 'C:\Backup\ASL\Hardy\CMI_data';
%
% Flist   = xASL_adm_GetFileList(ODIR,'^(HD|hd|Hd|hD)\d{3}_mT1\.nii$','List',[0 Inf]);
%
% DeleteLockList  = {'999_ready.status' '010_visualize.status' '009_reslice2DARTEL.status'};
% PassedList      = {''};
% PassedList2     = {''};
% EmptyList       = {''};
%
%
% for iL=1:length(Flist)
%     clear Subj ref src OtherList NewName
%     xASL_TrackProgress(iL,length(Flist));
%     Subj        = ['HD' Flist{iL}(3:5)];
%     ref         = fullfile(DDIR,[Subj '_1'],'T1.nii');
%     src         = fullfile(ODIR,Flist{iL});
%     OtherList   = fullfile(ODIR,[Subj '_gT1.nii']);
%     NewName     = fullfile(DDIR,[Subj '_1'],'ROI_T1_1.nii');
%
%     if  ( exist(ref,'file') || exist([ref '.gz'],'file') ) && exist(src,'file')
%         if  ~exist(NewName,'file')
%
%
%             xASL_io_ReadNifti(ref); xASL_io_ReadNifti(src); xASL_io_ReadNifti(OtherList);
%
%             xASL_spm_coreg( ref, src, OtherList, [], Subj, [4 2]);
%
%
%
%             xASL_Move(OtherList,NewName);
%
%             % Redo resampling & visual stuff structural module
%             LOCKDIR             = fullfile(DDIR,'lock','Struct',[Subj '_1'],'Struct_module');
%             for iLD=1:length(DeleteLockList)
%                 LockFile2Del    = fullfile(LOCKDIR,DeleteLockList{iLD});
%                 if  exist(LockFile2Del,'file'); delete(LockFile2Del); end
%             end
%         else
%             delete(OtherList);
%             delete(src);
%         end
%     else
%         PassedList{end+1}   = Subj;
%     end
% end
%
% % 55 skipped
%
% % Questions: I assume all baseline? Only 58 subjects?

%% Copy lesions

clear PassedList
ODIR    = 'C:\Backup\ASL\Hardy\InfarctsWMH other';
DDIR    = 'C:\Backup\ASL\Hardy\CMI_substudy';

Dlist   = xASL_adm_GetFsList(ODIR,'^HD\d{3}$',1,[],[],[0 Inf]);

DeleteLockList  = {'999_ready.status' '010_visualize.status' '009_reslice2DARTEL.status' '008_TissueVolume.status' '007_segment_T1w.status' '006_Get_WMH_vol.status' '005_LesionFilling.status' '004_segment_FLAIR.status' '003_resample_FLAIR2T1w.status' '002_coreg_FLAIR2T1w.status'};

for iL=1:length(Dlist)
    clear Subj ref src OtherList NewName NewName2
    xASL_TrackProgress(iL,length(Dlist));
    Subj            = Dlist{iL}(1:5);
    ref             = fullfile(DDIR,[Subj '_1'],'FLAIR.nii');
    refORI          = fullfile(DDIR,[Subj '_1'],'FLAIR_ORI.nii');
    src             = fullfile(ODIR,Dlist{iL},'FLAIR.nii');
    OtherList{1,1}    = fullfile(ODIR,Dlist{iL},'FLAIR.if.nii');
    OtherList{2,1}    = fullfile(ODIR,Dlist{iL},'FLAIR.WMH.nii');

    if  exist(ref,'file') || exist([ref '.gz'],'file'); xASL_io_ReadNifti(ref); end
    if  exist(src,'file') || exist([src '.gz'],'file'); xASL_io_ReadNifti(src); end
    if  exist(OtherList{1},'file') || exist([OtherList{1} '.gz'],'file'); xASL_io_ReadNifti(OtherList{1}); end
    if  exist(OtherList{2},'file') || exist([OtherList{2} '.gz'],'file'); xASL_io_ReadNifti(OtherList{2}); end

    if  exist(src,'file')
        xASL_Move(src,ref,1);
    end

    if  exist(OtherList{1},'file')
        NewName         = fullfile(DDIR,[Subj '_1'],'Lesion_FLAIR_1.nii');
        if  xASL_stat_SumNan(xASL_stat_SumNan(xASL_stat_SumNan(xASL_io_Nifti2Im(OtherList{1}))))>0
            xASL_Move(OtherList{1,1},NewName,1);
        else
            delete(OtherList{1,1});
        end

        if  exist(NewName,'file') && exist([NewName '.gz'],'file')
            delete([NewName '.gz']);
        end
    end

    if  exist(OtherList{2},'file')
        NewName2         = fullfile(DDIR,[Subj '_1'],'WMH_SEGM.nii');
        if  xASL_stat_SumNan(xASL_stat_SumNan(xASL_stat_SumNan(xASL_io_Nifti2Im(OtherList{2}))))>0
            xASL_Move(OtherList{2},NewName2,1);
        else
            delete(OtherList{1,1});
        end

        if  exist(NewName2,'file') && exist([NewName2 '.gz'],'file')
            delete([NewName2 '.gz']);
        end
    end

    % save second FLAIR Only
    FLAIRim     = xASL_io_Nifti2Im(ref);
    if  size(FLAIRim,5)>1
        xASL_io_SaveNifti(ref,ref,FLAIRim(:,:,:,1,2));
    end


    % Redo partly structural module
    LOCKDIR             = fullfile(DDIR,'lock','Struct',[Subj '_1'],'Struct_module');
    for iLD=1:length(DeleteLockList)
        LockFile2Del    = fullfile(LOCKDIR,DeleteLockList{iLD});
        if  exist(LockFile2Del,'file'); delete(LockFile2Del); end
    end

    rmdir(fullfile(ODIR,Dlist{iL}));
end

%% Spread out the ROI CMIs
DDIR    = 'C:\Backup\ASL\Hardy\Cortical infarcts other';
Flist   = xASL_adm_GetFileList(DDIR,'^ROI_T1_1\.nii$','FPListRec',[0 Inf]);

for iL=1:length(Flist)
    xASL_TrackProgress(iL,length(Flist));
    if  exist(Flist{iL},'file') && ~exist([Flist{iL}(1:end-5) '2.nii.gz'],'file')
        clear tNII BackupPath Fpath Ffile Fext I X Y Z IM
        tNII    = xASL_io_Nifti2Im(Flist{iL});

        if  xASL_stat_SumNan(tNII(:))>1
            % split the ROIs
            [Fpath Ffile Fext]  = xASL_fileparts(Flist{iL});
            BackupPath          = fullfile(Fpath,[Ffile(1:end-2) '_Backup' Fext]);
            xASL_io_SaveNifti(Flist{iL},BackupPath,tNII,8,1 ); % Backup ROI

            I   = find(tNII~=0);
            for iI=1:length(I)
                [X(iI) Y(iI) Z(iI)]         = ind2sub(size(tNII),I(iI));
                IM                          = zeros(size(tNII));
                IM(X(iI), Y(iI), Z(iI))     = 1;
                xASL_io_SaveNifti(Flist{iL},fullfile(Fpath,['ROI_T1_' num2str(iI) '.nii']),IM,8);
            end
        elseif xASL_stat_SumNan(tNII(:))==0
            delete(Flist{iL});
        end

    end
end
