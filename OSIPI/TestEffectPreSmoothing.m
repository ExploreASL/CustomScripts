% 1. Get ASL and M0 NIfTIs
ExploreASL;
pathData = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic';
folderList = xASL_adm_GetFileList(pathData, '^sub-DRO\d', 'FPList', [0 Inf], 1);

for iFolder=1:numel(folderList)

    NIIlist = xASL_adm_GetFileList(folderList{iFolder}, '^.*(m0scan|asl)\.nii$', 'FPListRec');

    for iNii=2:length(NIIlist)
        [Fpath, Ffile] = xASL_fileparts(NIIlist{iNii});
        pathT1 = xASL_adm_GetFileList(fullfile(fileparts(Fpath), 'anat'), '^.*T1w\.nii');
        pathTemp = fullfile(Fpath, [Ffile '_temp.nii']);

        % 1) reslice them back to T1w
        xASL_spm_reslice(pathT1, NIIlist{iNii}, [], [], 1, pathTemp, 4);

        % 2) smooth them
        xASL_spm_smooth(pathTemp, [5 5 5], pathTemp);

        % 3) 
        xASL_spm_reslice(NIIlist{iNii}, pathTemp, [], [], 1, NIIlist{iNii}, 4);
        % 4) Delete temp
        xASL_delete(pathTemp);
    end

    % 5) Re-zip all files
    xASL_adm_GzipAllFiles(folderList{iFolder});
end