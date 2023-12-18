function [outputArg1,outputArg2] = untitled(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% x.dir.xASLDerivatives = '/Users/hjmutsaerts/ExploreASL/test_Insight46/derivatives/ExploreASL';

% intermediateFilesToRemove = 

rootDir = x.dir.xASLDerivatives;

popDir = fullfile(rootDir, 'Population');

preFixList = {'rT1_ORI_' 'rT1_' 'rFLAIR_' '(m|)rc\dT1_' 'noSmooth_M0_' 'mean_control_' 'PWI_' 'SliceGradient_' 'SNR'}
nPrefixes = length(preFixList);

popDir = '/data/radv/radG/RAD/share/Twins/Twins_bids/Twins_ExploreASL/Population';

    if isunix()
        for iPreFix=1:nPrefixes
		    PathToSearch = popDir;
            iPreFix
		    [exit_code, system_result] = system(['cd ' PathToSearch '; find . -maxdepth 1 -name ' preFixList{iPreFix} '\*.nii\* -exec rm -f {} \;'])
        end
    end





preFixList = {'PWI4D'};



end