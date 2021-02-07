function register_ASL_VENDORCOMPARISON_rigid(x)
% function register_ASL_VENDORCOMPARISON_rigid(filename)
%
% Input:  filename - 4D nifti
% Output: resampled & realigned 3D nifti
%
% 1)    Estimate motion from mean head position using SPM_realign or SPM_realign_asl
% 2)    Reslice all images to MNI space (currently 1.5 mm^3)
% 3)    Calculate and plot position and motion parameters
%
% Requires SPM8
%
% Matthan Caan, AMC 2013
% HJ Mutsaerts, ExploreASL AMC 2016
%
% 1    Registration ASL -> T1 (& M0 if there is a separate M0 or mean_control image without background suppression)
% 2    Create slice gradient image for quantification reference, in case of 2D ASL
% 3    Reslice ASL time series to MNI space (currently 1.5 mm^3)
% 4    Create mean control image, masking to 20% of max value if used as M0 (no background suppression)
% 5    Smart smoothing mean_control if used as M0
%
% BACKGROUND INFORMATION
% 
% RESAMPLING TO ISOTROPY
% Resampling is performed with SPM. The SPM resampling script smooths a bit more than "real linear interpolation",
% (this could be because of the Fourier interpolation?) This choice is made since it is desirable to have the majority of the pipeline
% based on existing, proved, scripts (SPM8); and because the penalty of a small degree of smoothing is small.
%
% Care was taken to limit the amount of individual interpolation steps, without letting
% computation time rise too much because of operations in higher resolution (e.g. 1.5 mm^3)


    %% Administration

    [path file ext]                 = fileparts(x.despiked_raw_asl);
    [path_dummy x.P.SessionID dummy] 	= fileparts(path);
    [path_dummy x.P.SubjectID dummy] 	= fileparts(path_dummy);
    clear dummy ext path_dummy

    x.x.P.SubjectID              = x.P.SubjectID;

    temp_name       = fullfile(x.SESSIONDIR, ['temp_' file '.nii']);
    temp_mat        = fullfile(x.SESSIONDIR, ['temp_' file '.mat']);
    rtemp_name      = fullfile(x.SESSIONDIR, ['rtemp_' file '.nii']);

    T1_nii              = fullfile(x.SUBJECTDIR, [     x.P.STRUCT '.nii']);
    GM_nii              = fullfile(x.SUBJECTDIR, ['c1' x.P.STRUCT '.nii']);
    wGM_nii             = fullfile(x.SUBJECTDIR, ['wc1' x.P.STRUCT '.nii']);
    if ~exist( GM_nii ,'file')
        error(['GM probability map ' GM_nii ' did not exist!']);
    end

    tempnii             = xASL_nifti(x.despiked_raw_asl);
    min_voxelsize       = double(min(tempnii.hdr.pixdim(2:4) )); % repmat, 1,3
    nFrames             = double(tempnii.hdr.dim(5));

    %% 1    Registration ASL -> ASL

    mean_PWI_Clipped   = fullfile(x.SESSIONDIR, 'mean_PWI_Clipped.nii');
    MASKname        = fullfile(x.SESSIONDIR, 'PWI_GradualMask.nii');
    M0name          = fullfile(x.SESSIONDIR, 'M0.nii');
    NEWM0           = fullfile(x.SESSIONDIR, 'temp_M0.nii');
    ASLname         = fullfile(x.SESSIONDIR, 'mean_PWI_Clipped.nii');
    ASLnameCopy     = fullfile(x.SESSIONDIR, 'PWI_6par_reg.nii');
    ASLname_SN      = fullfile(x.SESSIONDIR, 'mean_PWI_Clipped_sn.mat');
    M0nameCopy      = fullfile(x.SESSIONDIR, 'M0_6par_reg.nii');
    ASL_MNI         = fullfile(x.SESSIONDIR, 'wPWI_6par_reg.nii');

    clear matlabbatch REGNAME
    fprintf('%s\n',['Rigid registration session ' x.P.SessionID ]);



    next    = 1;    
    if      ~isempty(strfind(x.SESSIONDIR,'M0_T1'))

            matlabbatch{1}.spm.spatial.coreg.estimate.ref               = { T1_nii };
            matlabbatch{1}.spm.spatial.coreg.estimate.source            = { NEWM0 };
            delete(mean_PWI_Clipped); % to avoid confusion

    elseif  ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))

            matlabbatch{1}.spm.spatial.coreg.estimate.ref               = { GM_nii };
            matlabbatch{1}.spm.spatial.coreg.estimate.source            = { mean_PWI_Clipped };
            delete(NEWM0); % to avoid confusion

    else
            error('Can"t define registration option');
    end

    temp_ASL    = spm_vol( x.despiked_raw_asl );
    % 
    for ii=1:length(temp_ASL) % fill candidate list for matrix transformation
        matlabbatch{1}.spm.spatial.coreg.estimate.other{next,1}    = [temp_ASL(ii).fname ',' num2str(temp_ASL(ii).n(1))];
        next    = next+1;
    end

    switch x.M0
    case 'separate_scan' % if there is a separate M0-scan

        % Apply registration to all frames!
        temp_M0    = spm_vol(M0name);
    % 
        for ii=1:length(temp_M0) % fill candidate list for matrix transformation
            matlabbatch{1}.spm.spatial.coreg.estimate.other{next,1}    = [temp_M0(ii).fname ',' num2str(temp_M0(ii).n(1))];
            next    = next+1;
        end    
    end


    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2 1];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

    spm_jobman('run',matlabbatch); close all


end