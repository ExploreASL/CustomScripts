function reslice_ASL_VENDORCOMPARISON(x)
% function reslice_ASL_VENDORCOMPARISON(filename)
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

temp_name       = fullfile(x.SESSIONDIR, ['temp_' file '.nii']);
temp_mat        = fullfile(x.SESSIONDIR, ['temp_' file '.mat']);
rtemp_name      = fullfile(x.SESSIONDIR, ['rtemp_' file '.nii']);

GM_nii              = fullfile(x.SUBJECTDIR, ['c1' x.P.STRUCT '.nii']);
if ~exist( GM_nii ,'file')
    error(['GM probability map ' GM_nii ' did not exist!']);
end

tempnii             = xASL_nifti(x.despiked_raw_asl);
min_voxelsize       = double(min(tempnii.hdr.pixdim(2:4) )); % repmat, 1,3
nFrames             = double(tempnii.hdr.dim(5));




%% 2    Create slice gradient image for quantification reference, in case of 2D ASL
switch x.readout_dim
    case '2D'
        tic
        create_slice_gradient_ASL_VENDORCOMPARISON(x);
        toc
    case '3D'
    fprintf('%s\n','Slice gradient creation skipped, because of 3D readout');
    otherwise error('Invalid x.readout_dim!!!');
end

%% 3    Reslice ASL time series to MNI space (currently 1.5 mm^3)
%       Applies motion correction, registration etc. in high resolution

% 3.1 First convert to single precision, if not already
%     Otherwise precious precision is lost in reslicing and subsequent
%     post-processing steps

fprintf('%s\n','Convert ASL time series to single precision');

% Whatsoever, create temporary copy, since original ASL file needs to be preserved
convert_nii_spm_single_precision( x.despiked_raw_asl,temp_name );

OUTPUTname  = 'ASL4D';

NativeDeformations_VENDORCOMPARISON(x,x.P.SubjectID,temp_name,OUTPUTname);

%
% flags.mask      = true; % masking could help when interpolating motion time series
% flags.mean      = false;
% flags.interp    = x.InterpolationSetting;
% flags.which     = 1;     % reslice all images (except first)
%
% fprintf('%s\n','Reslicing ASL time series to MNI');
% spm_reslice({x.D.ResliceRef,temp_name},flags);
% clear flags

%% 4    Create mean control image
% if used as M0 (no background suppression):
% 5 masking to 20% of max value
% 6 smoothing
% 7 correction quantification

if ~isempty(strfind(x.SESSIONDIR, 'PHnonBsup'))

    % Destination folders
    RegNames                = {'1_6par_linear'};

    if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))
       RegNames             = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};
    end

    for iF=1:length(RegNames)
        clear dFOLDER INPUTname tnii temp_nii control_im label_im SortValue mask_im mean_control_im M0_parms_file

        dFOLDER         = fullfile(x.D.PopDir,RegNames{iF});
        INPUTname       = fullfile(dFOLDER,['ASL4D_' x.P.SubjectID '.nii']);

        if exist(INPUTname)

            tnii            = xASL_nifti( INPUTname );
            temp_nii        = single(tnii.dat(:,:,:,:));

            % Get control-label order, switch if necessary
            [ control_im label_im] = Check_control_label_order( temp_nii );
            clear label_im

            % New masking
            SortValue                   = sort(control_im(:));
            mask_im                     = control_im>SortValue(round(0.2*length(SortValue)));

            if  size(mask_im,4)>1
                mask_im                     = min(mask_im,[],4);
                for iFrame=1:size(control_im,4)
                    mask_im(:,:,:,iFrame)   = mask_im(:,:,:,1);
                end
            end

            control_im(mask_im==0)          = NaN;
            mean_control_im                 = xASL_stat_MeanNan(control_im,4);

            clear masked_control_im mask_im

            %% 6)   Smoothing

            % Smooth M0 map before division
            % Currently, same smoothing kernel for 2D & 3D, to remove e.g. Gibbs
            % ringing artifact in 3D data

            % This should be considerable large smoothing,
            % because of the noise that would be introduced by
            % voxel-wise division. See Beaumont's thesis, chapter 4

            FWHM                    = 28; % mm smoothing kernel (2D)
            FwHm2SD                 = (2*(2*reallog(2))^0.5);
            FWHM                    = FWHM/1.5; % to divide by voxel-size for number of voxels
            SD                      = round(FWHM/FwHm2SD);

            % smooth maps, ignoring NaNs
            % CAVE: NaNs are kept, to secure masked division
            % hence the maps should be masked later!
            mean_control_im         = xASL_im_ndnanfilter(mean_control_im,'rect',[SD SD SD],1);


            %% 7 Correct for scale slope
            % Load ASL parameter file, use for M0 (mean_control)
            M0_parms_file           = fullfile(x.SESSIONDIR, x.ASLPARMSFILE);
            mean_control_im         = QuantifyM0( mean_control_im, x, M0_parms_file);
            clear control_im
            OUTPUTname              = fullfile(dFOLDER,['M0_' x.P.SubjectID '.nii']);

            xASL_io_SaveNifti(INPUTname, OUTPUTname ,mean_control_im,1,32);

            % Remove despiked_ASL4D.nii if exists. Leave despiked_ASL4D.mat, since
            % this facilitates observing which ones have frames taken out.
        end
    end
end


end
