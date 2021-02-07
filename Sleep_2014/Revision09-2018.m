%% Aim to rescue previously used data

DDIR    = 'C:\Backup\ASL\SleepStudy\analysis2\Population\STATS_MAPS\DataReTry';
Flist   = xASL_adm_GetFileList(DDIR,'^Set1subject\d{5}\.nii$');

for iL=1:length(Flist)
    x.S.DAT(iL,:)   = xASL_im_IM2Column(xASL_io_Nifti2Im(Flist{iL}),x.S.VBAmask);
end


%% Restore other data
Odir    = 'C:\Backup\ASL\SleepStudy\analysis2\Population\OLD_Backup';
Ddir    = 'C:\Backup\ASL\SleepStudy\analysis2\Population';

TypeOld     = {'DARTEL_CBF' 'DARTEL_M0' 'DARTEL_mean_control' 'DARTEL_SD' 'DARTEL_slice_gradient'};
TypeNew     = {'qCBF'       'M0'        'mean_control'        'SD'        'slice_gradient'};



for iT=2:length(TypeOld)
    Flist   = xASL_adm_GetFileList(Odir,['^' TypeOld{iT} '.*\.(nii|nii\.gz)$']);
    for iL=1:length(Flist)
        [~, Ffile, ~]   = xASL_fileparts(Flist{iL});
        OldName         = Flist{iL};
        SubjectN        = Ffile(length(TypeOld{iT})+2:end);
        NewName         = fullfile(Ddir,[TypeNew{iT} '_' SubjectN '.nii']);
        xASL_Move(OldName,NewName);
    end
end

`
