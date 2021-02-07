function average_quantify_ASL_VENDORCOMPARISON( x )
%average_quantify_ASL % Quantification is performed here according to ASL consensus paper (Alsop, MRM 2016)
%
%
%
%
% 1    Prepare M0 image
% 2    Prepare CBF image
% 3    Load slice gradient if 2D
% 4    CBF quantification equation
% 5    Outlier rejection
% 6    Division by M0 & scale slopes
% 7    Remove non-perfusion values
%
%       BACKGROUND INFORMATION


%% Administration

% Cave: file can either be equal to x.P.ASL4D, or to ['despiked_' x.P.ASL4D]

[path file ext]                 = fileparts(x.despiked_raw_asl);
[path_dummy x.P.SessionID dummy] 	= fileparts(path);
[path_dummy x.P.SubjectID dummy] 	= fileparts(path_dummy);
clear dummy path_dummy path ext


% Destination folders
RegNames                = {'1_6par_linear'};

if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))
   RegNames             = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};
end

for iF=1:length(RegNames)
    clear dFOLDER M0_nii CBF_nii tnii M0_im slice_gradient_load qCBF_nii
    clear ASL_im control_im label_im qnt_slice_gradient new_mean

    dFOLDER                 = fullfile(x.D.PopDir,RegNames{iF});
    M0_nii                  = fullfile( dFOLDER, [x.P.M0 '_' x.P.SubjectID '.nii']);
    CBF_nii                 = fullfile( dFOLDER, [x.P.ASL4D '_' x.P.SubjectID '.nii']);
    slice_gradient_load     = fullfile( dFOLDER, ['slice_gradient_' x.P.SubjectID '.nii']);
    qCBF_nii                = fullfile( dFOLDER, ['qCBF_' x.P.SubjectID '.nii']);

    if  exist(M0_nii) && exist(CBF_nii) && ~exist(qCBF_nii)

        tnii            = xASL_nifti(CBF_nii); % Load CBF nifti

        M0_im           = xASL_nifti(M0_nii);
        M0_im           = single(M0_im.dat(:,:,:)); % Get M0 image
        M0_im           = M0_im ./ x.Q.Lambda;
        fprintf('%s\n',['M0 image corrected for Labda: ' num2str(x.Q.Lambda)]);
        % qnt_labda (0.9) = brain-blood partition coefficient.




        %% 2    Prepare CBF image
        fprintf('%s\n','Preparing ASL image');

        % Load ASL parameter file
        ASL_parms_file= fullfile(x.SESSIONDIR, x.ASLPARMSFILE);
        if exist(ASL_parms_file,'file')
            ASL_P = load(ASL_parms_file);
            if isfield(ASL_P,'parms')
                ASL_parms = ASL_P.parms;
            else
                fprintf(2,'ERROR in module_ASL: could not load ASL parameters from:\n%s\n',M0_parms_file);
                return % exit with an error
            end
            clear ASL_P ASL_parms_file
        end


        % Load ASL time series (after being pre-processed)
        ASL_im                  = single(tnii.dat(:,:,:,:));

        if  size(ASL_im,4)>1 % if the ASL file has multiple frames

            % Get control-label order, switch if necessary
            [ control_im label_im]  = Check_control_label_order( ASL_im );

            % Paired subtraction
            ASL_im                  = control_im - label_im;
            clear control_im label_im
        end

        %% 4    Outlier rejection
        if  size(ASL_im,4)>2
            ASL_im                      = outlier_rejection_ASL( ASL_im, x );
        else
            fprintf('%s\n',['No outlier rejection performed because of only ' num2str(size(ASL_im,4)) ' frame(s)']);
        end


        % Create factor, single compartment model, including T2* correction (if M0 = number)
        % Take care of PLD
        switch x.Q.SliceReadoutTime
            case '3D'
                fprintf('%s\n','3D sequence, not accounting for SliceReadoutTime (homogeneous PLD for complete volume)');
                qnt_slice_gradient         = x.Q.Initial_PLD;

            case '2D' % Load slice gradient
                fprintf('%s\n','2D sequence, accounting for SliceReadoutTime (inhomogeneous/slice-specific PLD)');

                if ~isfield(x.Q,'SliceReadoutTime')
                    error('x.Q.SliceReadoutTime was not defined!');

                else
                    if  isnumeric(x.Q.SliceReadoutTime)
                        fprintf('%s\n',['Using SliceReadoutTime ' num2str(x.Q.SliceReadoutTime) ' ms']);

                    else
                        switch x.Q.SliceReadoutTime
                            case 'individual'
                                if isfield(ASL_parms,'SliceReadoutTime')
                                    x.Q.SliceReadoutTime     = ASL_parms.SliceReadoutTime;
                                    fprintf('%s\n',['Using individual SliceReadoutTime ' num2str(x.Q.SliceReadoutTime) ' ms']);
                                else error('ASL_parms.SliceReadoutTime expected but did not exist!');
                                end
                            otherwise;   error('Invalid x.Q.SliceReadoutTime!');
                        end
                    end
                end

        %% 3    Load slice gradient if 2D
                slice_grad_nii          = xASL_nifti( slice_gradient_load );
                qnt_slice_gradient      = single(slice_grad_nii.dat(:,:,:));

                qnt_slice_gradient(qnt_slice_gradient>0 & qnt_slice_gradient<1)     = 1;
                qnt_slice_gradient      = x.Q.Initial_PLD + ((qnt_slice_gradient-1) .* x.Q.SliceReadoutTime); % effective PLD

                qnt_slice_gradient      = repmat(qnt_slice_gradient,[1 1 1 size(ASL_im,4)]);
                % Now slice gradient has effective PLD numbers
            otherwise; error('Wrong x.readout_dim value!');
        end

        %% 3    Labeling efficiency
        switch x.Q.LabelingType
            case 'PASL'
                x.Q.LabelingEfficiency                     = 0.98; % (concensus paper, Wong, MRM 1998)
            case 'CASL'
                x.Q.LabelingEfficiency                     = 0.85; % (concensus paper, Dai, MRM 2008)
        end

        switch x.M0
            case 'no_background_suppression'
                x.Q.LabelingEfficiency                     = 0.85; % 0.85 is standard assumed labeling efficiency (Alsop et al, MRM 2016; Heijtel et al. NeuroImage 2016)
            otherwise
                switch x.Q.BackGrSupprPulses
                    case 2
                        x.Q.LabelingEfficiency             = x.Q.LabelingEfficiency*0.83; % 0.83 = 2 background suppression pulses (Garcia et al., MRM 2005), Philips or Siemens
                    case 5
                        x.Q.LabelingEfficiency             = x.Q.LabelingEfficiency*0.75; % 0.75 = 5 background suppression pulses (GE FSE) (Garcia et al., MRM 2005)
                end
        end


        %% 3    CBF quantification equation for CASL & PASL
        fprintf('%s\n','Getting quantification factor');

        switch x.Q.LabelingType
            case 'PASL'
                DivisionFactor                     = x.Q.LabelingDuration; % (concensus paper)
            case 'CASL'
                DivisionFactor                     = x.Q.BloodT1 .* (1- exp(-x.Q.LabelingDuration./x.Q.BloodT1)); % (concensus paper)
        end


        qnt_slice_gradient              = exp(qnt_slice_gradient./x.Q.BloodT1) / (2.*x.Q.LabelingEfficiency.* DivisionFactor );
        %                                 correcting T1-decay from PLD to label_duration
        fprintf('%s\n','ASL quantification:');
        fprintf('%s\n',['labda = ' num2str(x.Q.Lambda)]);
        fprintf('%s\n',['labeling efficiency = ' num2str(x.Q.LabelingEfficiency)]);
        fprintf('%s\n',['T1 arterial blood = ' num2str(x.Q.BloodT1) ' ms']);

        switch x.Q.LabelingType
            case 'PASL'
                fprintf('%s\n',['TI1 = ' num2str(x.Q.LabelingDuration) ' ms']);
                fprintf('%s\n',['initial TI  = ' num2str(x.Q.Initial_PLD) ' ms']);
            case 'CASL'
                fprintf('%s\n',['labeling duration = ' num2str(x.Q.LabelingDuration) ' ms']);
                fprintf('%s\n',['initial post-label delay = ' num2str(x.Q.Initial_PLD) ' ms']);
        end

        % Now slice gradient has quantification factor numbers
        qnt_slice_gradient              = qnt_slice_gradient*60000*100;
        % Now slice gradient has quantification factor numbers scaled to physiological units ( ml/gr/ms =>ml/100gr/min =>(60,000 ms=>min)(1 gr=>100gr) )

        ASL_im                          = ASL_im .* qnt_slice_gradient;
        clear qnt_slice_gradient
        % Now ASL_image has been scaled with the quantification factors, acknowledging multi-slice acquisitions




        %% 5    Compute PWI images

        new_mean                          = xASL_stat_MeanNan(ASL_im,4);
    %     new_mean                        = PWI;
    %
    %     if  size(ASL_im,4)>1
    %         new_std                         = xASL_stat_StdNan( ASL_im,0,4);
    %         new_SNR                         = new_mean./new_std;
    %         new_SNR(new_SNR<0)              = 0; % clip @ zero
    %
    %         xASL_io_SaveNifti(CBF_nii,fullfile(x.D.PopDir,['SD_'  x.P.SubjectID '_' x.P.SessionID '.nii']),new_std,1,32);
    %         xASL_io_SaveNifti(CBF_nii,fullfile(x.D.PopDir,['SNR_' x.P.SubjectID '_' x.P.SessionID '.nii']),new_SNR,1,32);
    %         fprintf('%s\n','2D & SNR images saved');
    %     else
    %         fprintf('%s\n',['SD & SNR maps were not created because of only ' num2str(size(ASL_im,4)) ' frame(s)']);
    %     end
    %
        clear ASL_im


        %% 7    Division by M0 & scale slopes
        % Correct scale slopes
        new_mean                        = new_mean./(ASL_parms.RescaleSlopeOriginal*ASL_parms.MRScaleSlope);
        fprintf('%s\n',['ASL image corrected for dicom scale slopes ' num2str(ASL_parms.RescaleSlopeOriginal) ' and ' num2str(ASL_parms.MRScaleSlope)]);
        % nifti scale slope has already been corrected for by SPM nifti

        % Division by M0
        if isnumeric(x.M0) % do T2* correction of arterial blood
            % in case of separate M0, or M0 because of no background suppression,
            % T2* effect is similar in both images and hence removed by division
                T2_star_factor          = exp(ASL_parms.EchoTime/x.Q.T2art);
                PWI                     = new_mean .* T2_star_factor;

                fprintf('%s\n',['ASL image corrected for T2* decay during TE, TE was ' num2str(ASL_parms.EchoTime) ' ms, using T2* ' num2str(x.Q.T2art) ' ms, this resulting in factor ' num2str(T2_star_factor)]);
        end

        new_mean                        = new_mean./M0_im;fprintf('%s\n','ASL image divided by M0 image');

        clear M0_im


        %% 8    Vendor quantification correction

        if strcmp(x.Vendor,'GE')>0

                if ~isfield(ASL_parms,'NumberOfAverages')
                    % GE accumulates signal instead of averaging by NEX, therefore division by NEX is required
                    error('GE-data expected, "NumberOfAverages" should be a dicom-field, but was not found!!!')
                end

                switch x.Vendor
                    % For some reason the older GE Alsop Work in Progress (WIP) version
                    % has a different scale factor than the current GE product sequence

                    case 'GE_product' % GE new version

                    qnt_R1gain          = 1/32;          % R1 analogue gain/ simple multiplier
                    qnt_C1              = 6000;          % GE constant multiplier

                    qnt_GEscaleFactor   = (qnt_C1*qnt_R1gain)/(ASL_parms.NumberOfAverages);
                    new_mean            = new_mean./qnt_GEscaleFactor;

                    case 'GE_WIP' %     GE old version

                    qnt_RGcorr          = 45.24;         % Correction for receiver gain in PDref (but not used apparently?)
                    qnt_GEscaleFactor   = qnt_RGcorr*ASL_parms.NumberOfAverages;
                end

                new_mean            = new_mean./qnt_GEscaleFactor;

        elseif    strcmp(x.Vendor,'Siemens') && strcmp(x.M0,'separate_scan')
                switch x.readout_dim
                    % For some reason the 2D Siemens readout doesn't rescale M0 whereas the 3D has divided M0 by 10
                    case '3D'
                  new_mean            = new_mean./10;
                  end
        end



        %% 9     Remove non-perfusion values

        % Remember, PWI is used for DARTEL only
        % Non-perfusion values should be removed, because they may result in erroneous deformation fields
    %   PWI(PWI<0)                  = 0; % used to be NaN, but resulted in gaps with DARTEL
        % up_threshold                = xASL_stat_MeanNan(PWI(:))+(6*xASL_stat_StdNan(PWI(:)));
        % PWI(PWI>up_threshold)       = up_threshold;
        % PWI                         = PWI./max(PWI(:));
        %
        % % Actual perfusion image is untouched (except for previously masked M0, if there is any, or if mean control image is used)
        % if  x.CLIP_ZERO
        %     new_mean(new_mean<0)            = 0;
        %
        %     upThreshold                     = xASL_stat_MeanNan(new_mean(:))+(10*xASL_stat_StdNan(new_mean(:)));
        %     new_mean(new_mean>upThreshold)  = upThreshold;
        % end

    %     %% 9.5 MASK BOTH
    %     if  exist(MASKname,'file')
    %         MASK    = xASL_nifti(MASKname);
    %
    %         new_mean= new_mean.*MASK.dat(:,:,:);
    %     end


        %% 10	Save files

        fprintf('%s\n','Saving PWI & CBF niftis');

        % % Remove very low & high intensities (vascular signal) for PWI-driven DARTEL
        % PWI     = ClipVesselImage(PWI);

        xASL_io_SaveNifti(M0_nii, qCBF_nii ,new_mean,1,32); % single precision for better precision

        delete(CBF_nii);
        if  exist(slice_gradient_load)
            delete(slice_gradient_load);
        end
    end
end

end
