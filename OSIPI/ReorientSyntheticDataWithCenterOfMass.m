
Root = '/Users/henk/surfdrive/OSIPI_TF6.1/Synthetic';
DirList = xASL_adm_GetFileList(Root, '^Dataset.*$', 'FPList', [0 Inf], 1);

for iList=2:length(DirList)
    OtherList = xASL_adm_GetFileList(DirList{iList}, '^(M0|asl).*\.nii$', 'FPList');
    T1list = xASL_adm_GetFileList(DirList{iList}, '^T1\.nii$', 'FPList');

    xASL_im_CenterOfMass(T1list{1}, OtherList);
    xASL_adm_GzipAllFiles(DirList{iList});
end