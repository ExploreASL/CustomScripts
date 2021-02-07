Root = '/Users/henk/ExploreASL/ASL/PreDivaFigure/PreDivaPop';

FileList{1} = xASL_adm_GetFileList(Root,'^qCBF_untreated_\d*_1_ASL_1\.nii$'); % crushed
FileList{2} = xASL_adm_GetFileList(Root,'^qCBF_untreated_\d*_2_ASL_1\.nii$'); % crushed

for iFile=1:length(FileList{1})
    xASL_TrackProgress(iFile,186);
    IM{1}(:,:,:,iFile) = xASL_io_Nifti2Im(FileList{1}{iFile});
end
for iFile=1:length(FileList{2})
    xASL_TrackProgress(iFile,125);
    IM{2}(:,:,:,iFile) = xASL_io_Nifti2Im(FileList{2}{iFile});
end

savePath = '/Users/henk/ExploreASL/ASL/PreDivaFigure/Templates/Template_CBF_TP1.nii';
xASL_io_SaveNifti(FileList{1}{1}, savePath, xASL_stat_MeanNan(IM{1}, 4));

savePath = '/Users/henk/ExploreASL/ASL/PreDivaFigure/Templates/Template_CBF_TP2.nii';
xASL_io_SaveNifti(FileList{1}{1}, savePath, xASL_stat_MeanNan(IM{2}, 4));