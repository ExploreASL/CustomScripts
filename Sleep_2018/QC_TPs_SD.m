mDir        = 'C:\Backup\ASL\Sleep_2018\analysis\dartel';
SubjList    = xASL_adm_GetFileList(mDir,'^qCBF_untreated_Sub-596\d{2}_1_ASL_1\.(nii|nii\.gz)$','List');

for iS=1:length(SubjList)
    xASL_TrackProgress(iS,length(SubjList));
    clear IM TPlist
    TPlist  = xASL_adm_GetFileList(mDir,[SubjList{iS}(1:length('qCBF_untreated_Sub-59600_')) '\d_ASL_1\.(nii|nii\.gz)$'],'List');
    for iM=1:length(TPlist)
        IM(:,:,:,iM)    = xASL_io_Nifti2Im(fullfile(mDir,TPlist{iM}));
    end
    SDim(:,:,:,iS)    = std(IM,[],4);
    SDim(:,:,:,iS)    = xASL_im_ndnanfilter(SDim(:,:,:,iS),'gauss',[6 6 6]);
end

AvSD    = mean(SDim,4);
SDnorm  = SDim./repmat(AvSD,[1 1 1 size(SDim,4)]);
