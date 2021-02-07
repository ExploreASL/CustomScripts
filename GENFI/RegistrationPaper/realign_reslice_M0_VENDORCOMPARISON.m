function realign_reslice_M0_VENDORCOMPARISON(x)
% function realign_reslice_M0_VENDORCOMPARISON(filename)
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
% HJ Mutsaerts, ExploreASL AMC 2016
%
% BACKGROUND INFORMATION
%
% This function processes an individual M0 scan, if there is any
%
%
% 1)   Motion correction if there are multiple frames
% This script processes additional M0-scans, if they exist.
% It checks whether there are multiple frames (if averaging is not done on the scanner but multiple frames are acquired).
% If there are multiple frames, it employs motion correction.
%
% 2)   Registration M0 -> mean_control_ASL image
% The script assumes that there has been created an average control ASL image.
% Either a single M0 frame is registered to this image, or an motion corrected average of the multiple frames.
%
% 3)   Smart smoothing
% 4)   Reslice M0 to MNI space (currently 1.5 mm^3)
%
% 5)   Averaging if multiple frames
% In any case, M0 is only once resampled into MNI space.
% Therefore, if there are multiple frames, they are all resampled into MNI space and averaged in this section.
%
% 6)    Masking
% Here, 20% max value is used as threshold (Wang et al, MRM 2012)
% Since the maximum is untouched, re-run will not change the nifti.

%% Administration

M0_nii          = fullfile(x.SESSIONDIR,[x.P.M0 '.nii']);
M0_mat          = fullfile(x.SESSIONDIR,[x.P.M0 '.mat']);
M0_temp_nii     = fullfile(x.SESSIONDIR,[x.P.M0 '_temp.nii']);
M0_temp_mat     = fullfile(x.SESSIONDIR,[x.P.M0 '_temp.mat']);

rp_M0           = fullfile(x.SESSIONDIR,['rp_' x.P.M0      '.txt']);
rM0_nii         = fullfile(x.SESSIONDIR,['r' x.P.M0 '.nii']);
rM0_mat         = fullfile(x.SESSIONDIR,['r' x.P.M0 '.mat']);
rrM0_nii        = fullfile(x.SESSIONDIR,['rr' x.P.M0 '.nii']);
rrrM0_nii       = fullfile(x.SESSIONDIR,['rrr' x.P.M0 '.nii']);

[path file ext]                 = fileparts(M0_nii);
[path_dummy x.P.SessionID dummy] 	= fileparts(path);
[path_dummy x.P.SubjectID dummy] 	= fileparts(path_dummy);
clear dummy ext path_dummy


%% 3)   Reslice M0 to MNI space (currently 1.5 mm^3)
% Smooth_nii is resliced to MNI (rsmooth_nii)

OUTPUTname  = 'M0';

NativeDeformations_VENDORCOMPARISON(x,x.P.SubjectID,M0_nii,OUTPUTname);


%% 4)   Masking
% rM0_nii is masked, using a temporary file temp_mask_nii

% Destination folders
RegNames                = {'1_6par_linear'};

if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))
   RegNames             = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};
end

for iF=1:length(RegNames)

    dFOLDER         = fullfile(x.D.PopDir,RegNames{iF});
    INPUTname       = fullfile(dFOLDER,[OUTPUTname '_' x.P.SubjectID '.nii']);

    if  exist(INPUTname)

        % Masking
        fprintf('%s\n','Masking M0 to 20% of max intensity');
        % if used as M0, little masking is desirable not to obtain very high noisy
        % values outside the brain
        % Standard is 20% (Wang, MRM 2012), which works if image is not background suppressed

        tnii                        = xASL_nifti(INPUTname);
        temp_im                     = single(tnii.dat(:,:,:));

        % Old masking
        % mask_im                     = single( temp_im> ( 0.2 * max(temp_im(:)) ) ); % Wang, MRM 2012

        % New masking
        SortValue                   = sort(temp_im(:));
        mask_im                     = temp_im>SortValue(round(0.2*length(SortValue)));

        % mask_im                     = double( temp_im> ( xASL_stat_MeanNan(temp_im(:)) - 1.96 * xASL_stat_StdNan(temp_im(:)) ) ); % bit conservative
        % alternatively               = double( temp_im> (0.5*(sum(sum(temp.^2))./sum(temp(:)))  )
        % most important is that masking is probably not needed for linear registration, but is required for non-linear registration on single subject level.
        % on multiple-subject level (such as DARTEL) masking only introduces extra differences between subjects, which makes the PWI DARTEL less thrustworthy

        mask_im                     = single(mask_im);
        mask_im(mask_im==0)         = NaN; % CAVE: don't use this in DARTEL, DARTEL does not appreciate NaNs
        new_im                      = temp_im .* mask_im;


        %% 6)   Smoothing

        % Smooth M0 map before division
        % Currently, same smoothing kernel for 2D & 3D, to remove e.g. Gibbs
        % ringing artifact in 3D data

        % This should be considerable large smoothing,
        % because of the noise that would be introduced by
        % voxel-wise division. See Beaumont's thesis, chapter 4

        FWHM                    = 28; % mm smoothing kernel (3D)

        FwHm2SD                 = (2*(2*reallog(2))^0.5);
        FWHM                    = FWHM/1.5; % to divide by voxel-size for number of voxels
        SD                      = round((FWHM/FwHm2SD)/2)*2; % should be even

        % smooth maps, ignoring NaNs
        % CAVE: NaNs are kept, to secure masked division
        % hence the maps should be masked later!
        % gausswin with even kernel (e.g. SD=8) performs best
        new_im                  = xASL_im_ndnanfilter(new_im,'gauss',[SD SD SD]./1.06,1);

        %% 7)   Correction scale slope & incomplete T1 recovery

        % Load M0 parameter file
        M0_parms_file   = fullfile(x.SESSIONDIR, x.M0PARMSFILE);
        new_im          = QuantifyM0(new_im, x, M0_parms_file);

        %% 8)   Saving
        xASL_io_SaveNifti(INPUTname,INPUTname,new_im);
    end
end

end
