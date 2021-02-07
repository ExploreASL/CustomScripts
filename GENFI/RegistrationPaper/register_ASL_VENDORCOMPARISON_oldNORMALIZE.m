function register_ASL_VENDORCOMPARISON_oldNORMALIZE(x)
% function register_ASL_VENDORCOMPARISON_oldNORMALIZE(filename)
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

    %% 1    Old normalize

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
    fprintf('%s\n',['Affine registration, old normalize & elastic session ' x.P.SessionID]);

    %% Clip & rescale PWI to 0-1

    ASLload                        = xASL_nifti(mean_PWI_Clipped);
    newASL                         = ASLload.dat(:,:,:);
    newASL                         = ClipVesselImage( newASL, 0.95);
    newASL                         = newASL./max(newASL(:));
    newASL(newASL<0)               = 0;
    xASL_io_SaveNifti(mean_PWI_Clipped, mean_PWI_Clipped, newASL);


    matlabbatch{1}.spm.tools.oldnorm.est.subj.source            = {mean_PWI_Clipped};
    matlabbatch{1}.spm.tools.oldnorm.est.subj.wtsrc             = '';
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.template      = {GM_nii};
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.weight        = '';
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smosrc        = 1; % these smoothing settings empirically improved registration
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smoref        = 5; % these smoothing settings empirically improved registration
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.regtype       = 'subj'; % less zooming regularization, for within-subject use
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.cutoff        = 25;
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.nits          = 0; % disabling the elastic (non-linear) part, for within-subject use
    matlabbatch{1}.spm.tools.oldnorm.est.eoptions.reg           = 1;

    spm_jobman('run',matlabbatch); close all


end
