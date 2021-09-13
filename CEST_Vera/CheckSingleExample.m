% Start ExploreASL
pathExploreASL = '/scratch/hjmutsaerts/ExploreASL';
cd(pathExploreASL);
ExploreASL;

datasetRoot = '/home/hjmutsaerts/lood_storage/divi/Projects/ExploreASL/CEST_Vera/P11';
derivativesDir = fullfile(datasetRoot, 'derivatives', 'ExploreASL', 'sub-P11');
xASL_adm_CreateDir(derivativesDir);

% Copy T1w
destT1 = fullfile(derivativesDir, 'T1.nii.gz');
pathT1 = xASL_adm_GetFileList(datasetRoot, '.*_T1\.nii$');
if length(pathT1)~=1
    warning('Something wrong with pathT1');
else
    xASL_Copy(pathT1{1}, destT1, 1);
end

% Copy FLAIR
destFLAIR = fullfile(derivativesDir, 'FLAIR.nii.gz');
pathFLAIR = xASL_adm_GetFileList(datasetRoot, '.*_FLAIR\.nii$');
if length(pathFLAIR)~=1
    warning('Something wrong with pathFLAIR');
else
    xASL_Copy(pathFLAIR{1}, destFLAIR, 1);
end

% Copy CEST (as ASL)
dirCEST = fullfile(derivativesDir, 'ASL_1');
destCEST = fullfile(dirCEST, 'ASL4D.nii.gz');
pathCEST = xASL_adm_GetFileList(datasetRoot, '.*_apt2T1\.nii$');
if isempty(pathCEST)
    warning('Something wrong with pathCEST');
else
    xASL_adm_CreateDir(dirCEST);
    xASL_Copy(pathCEST{2}, destCEST, 1); %%%%%%%%%%%%%%%%%%%%%%%%% NB this can be the wrong one
end

% Copy lesion map
pathVOI = fullfile(dirCEST, 'P11_enhancingAreaONLY.voi');
destVOI = fullfile(derivativesDir, 'Lesion_T1.nii.gz');
xASL_Copy(pathVOI, destVOI, 1);

% Run ExploreASL on high quality
ExploreASL('/home/hjmutsaerts/lood_storage/divi/Projects/ExploreASL/CEST_Vera/P11',0, [1 0 0]);