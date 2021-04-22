pathOriginalASL = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/asl.nii.gz';
pathOriginalM0 = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/m0.nii.gz';
pathT1 = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/T1.nii.gz';

pathOriginalASLSmoothed = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/asl_smooth.nii.gz';
pathOriginalM0Smoothed = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/m0_smooth.nii.gz';

pathOriginalASL_highRes = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/asl_highRes.nii.gz';
pathOriginalM0_highRes = '/Users/henk/ExploreASL/OSIPI_TF6.1/Synthetic/Dataset_001/m0_highRes.nii.gz';

% 1) reslice them back to T1
xASL_spm_reslice(pathT1, pathOriginalM0, [], [], 1, pathOriginalM0_highRes, 2);
xASL_spm_reslice(pathT1, pathOriginalASL, [], [], 1, pathOriginalASL_highRes, 2);

% 2) smooth them
xASL_spm_smooth(pathOriginalM0_highRes, [5 5 5], pathOriginalM0_highRes);
xASL_spm_smooth(pathOriginalASL_highRes, [5 5 5], pathOriginalASL_highRes);

% 3) Downsample them
xASL_spm_reslice(pathOriginalM0, pathOriginalM0_highRes, [], [], 1, pathOriginalM0_highRes, 2);
xASL_spm_reslice(pathOriginalM0, pathOriginalASL_highRes, [], [], 1, pathOriginalASL_highRes, 2);