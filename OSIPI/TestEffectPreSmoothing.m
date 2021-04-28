% 1. Get ASL and M0 NIfTIs
ExploreASL;
pathData = '/scratch/hjmutsaerts/OSIPI_TF6.1/Synthetic';
NIIlist = xASL_adm_GetFileList(pathData, '^.*(M0|asl)\.nii$', 'FPListRec');

for iNii=1:length(NIIlist)
    [Fpath, Ffile] = xASL_fileparts(NIIlist{iNii});
    pathT1 = fullfile(xASL_fileparts(NIIlist{iNii}), 'T1.nii');
    pathSmooth = fullfile(Fpath, [Ffile '_smooth.nii']);
    
    % 1) reslice them back to T1w
    xASL_spm_reslice(pathT1, NIIlist{iNii}, [], [], 1, pathSmooth, 4);
    
    % 2) smooth them
    xASL_spm_smooth(pathSmooth, [5 5 5], pathSmooth);
    
    % 3) 
    xASL_spm_reslice(NIIlist{iNii}, pathSmooth, [], [], 1, pathSmooth, 4);
end    

% Re-zip all files
xASL_adm_GzipAllFiles(pathData);