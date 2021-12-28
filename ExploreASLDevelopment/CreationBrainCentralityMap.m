%% Create a brain mask centrality probability map
brainMap = xASL_io_Nifti2Im('rbrainmask_prob.nii');
DistanceMatrix = xASL_io_Nifti2Im('CentrifugalIM.nii');
DistanceMatrix = 1-(DistanceMatrix./max(DistanceMatrix(:)));
brainMap = brainMap.*DistanceMatrix;
brainMap = single(xASL_im_ndnanfilter(brainMap,'gauss',double([2 2 2])));

Path2Save = '/scratch/hjmutsaerts/ExploreASL/External/SPMmodified/MapsAdded/brainCentralityMap.nii';


xASL_io_SaveNifti('rbrainmask_prob.nii', Path2Save, brainMap, [], 0);
