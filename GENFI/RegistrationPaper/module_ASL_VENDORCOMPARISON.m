function result = module_ASL_VENDORCOMPARISON(job, x)
% $Rev:: 294                   $:  Revision of last commit
% $Author:: hjmutsaerts        $:  Author of last commit
% $Date:: 2016-09-24 18:05:01 #$:  Date of last commit

%% ASL module of ExploreASL Paul, Matthan, Henk-Jan


%% 0. INPUT

[path   x.P.SessionID ext]     = fileparts(x.SESSIONDIR);
[dummy x.P.SubjectID ext]      = fileparts(path);

xASL_adm_CreateDir(x.D.ASLCheckDir);
xASL_adm_CreateDir(x.MotionDir);   xASL_adm_CreateDir(x.ExclusionDir);
xASL_adm_CreateDir(x.OUTLIERDIR);  xASL_adm_CreateDir(x.SNRdir);
xASL_adm_CreateDir(x.RawEPIdir);

if  strcmp(x.M0,'separate_scan')
    xASL_adm_CreateDir(x.D.M0CheckDir);  xASL_adm_CreateDir(x.D.M0regASLdir);
end
if  strcmp(x.M0,'no_background_suppression')
    xASL_adm_CreateDir(x.D.RawDir);
end

x     = GenericMutexModules( x, 'ASL' ); % starts mutex locking process to ensure that everything will run only once
result      = false;

%% 0.9 change working directory to make sure that unspecified output will go there...
oldFolder = cd(x.SESSIONDIR);

%% Check file existence
% get input path
asl4D_raw_nii = xASL_adm_GetFsList(x.SESSIONDIR, x.ASL4DFILE);
nFiles = length(asl4D_raw_nii);
if nFiles==0
    error('AslPipeline:missingFile', 'No file found that matches "%s" in "%s"', x.ASL4DFILE, x.SESSIONDIR);
elseif nFiles>1
    error('AslPipeline:incorrectNrOfFiles', 'Expected exactly one nifti file "%s", but found %d', x.ASL4DFILE, nFiles);
end
x.P.ASL4D = fullfile(x.SESSIONDIR, asl4D_raw_nii{1}); % remove cell array from this single element
clear asl4D_raw_nii



    % 1    Motion correction

    if ~x.mutex.HasState('002_realign_ASL')

        % First, check matrix size: throw error if 2D data with 3 dimensions only
        TempNii     = xASL_nifti( x.P.ASL4D);
        if      strcmp(x.readout_dim,'2D') && length(size(TempNii.dat))~=4
                fprintf('%s\n',['Error!!! ' x.P.ASL4D ' should have > 3 dimensions, because of 2D readout!']);
                return;
        elseif  strcmp(x.readout_dim,'2D') && size(TempNii.dat,4)/2~=round(size(TempNii.dat,4)/2)
                fprintf('%s\n','Error!!! Uneven number of control-label frames, incomplete pairs!');
                return;
        end

        % 1    Estimate motion from mean head position using SPM_realign_asl (saved in matrix)
        % 2    Calculate and plot position and motion parameters

        if  size(TempNii.dat,4)>1
            realign_ASL(x);
        else
            fprintf('%s\n',['Skipping motion correction of subject ' x.P.SubjectID ' session ' x.P.SessionID ' because it had only ' num2str(size(TempNii.dat,4)) ' 3D frames.']);
        end

        x.mutex.AddState('002_realign_ASL');
    else    fprintf('%s\n','002_realign_ASL session has already been performed, skipping...');
    end

    % Use despiked ASL only if spikes were detected and new file has been created
    % Otherwise, despiked_raw_asl = same as original file
    [path file ext]     = fileparts(x.P.ASL4D);
    x.despiked_raw_asl    = fullfile(path,['despiked_' file '.nii']);
    despiked_raw_asl2           = fullfile(path,['rtemp_despiked_' file '.nii']);
    if ~exist( x.despiked_raw_asl ,'file') && ~exist( despiked_raw_asl2 ,'file')
        x.despiked_raw_asl = x.P.ASL4D;
    end

    %% 2    First reslice (to get temp files)
    if ~x.mutex.HasState('002_reslice_ASL')

        INPUTFILE               = x.despiked_raw_asl;

        OUTPUTFILE   = fullfile(x.SESSIONDIR,'mean_PWI_Clipped.nii');
        paired_subtraction_averaging_ASL( INPUTFILE,OUTPUTFILE,0,0,x);

        if     ~isempty(strfind(x.SESSIONDIR, 'PHnonBsup'))
                % if Philips no Bsup, then mean control == M0
                OUTPUTFILE   = fullfile(x.SESSIONDIR,'temp_M0.nii');
                paired_control_averaging_ASL(INPUTFILE,OUTPUTFILE,0,0);

        elseif ~isempty(strfind(x.SESSIONDIR, 'PHBsup')) || ~isempty(strfind(x.SESSIONDIR, 'SI'))
                % if Philips Bsup or Siemens, create mean_control & copy M0
                OUTPUTFILE   = fullfile(x.SESSIONDIR,'temp_mean_control.nii');
                paired_control_averaging_ASL(INPUTFILE,OUTPUTFILE,0,0);

                OUTPUTFILE   = fullfile(x.SESSIONDIR,'temp_M0.nii');
                xASL_Copy( fullfile(x.SESSIONDIR, 'M0.nii') ,OUTPUTFILE);

        elseif  max(strfind(x.SESSIONDIR, 'GE'))>40 % not 'GENFI' but 'GE'
                % if GE, no mean control can be created
                OUTPUTFILE   = fullfile(x.SESSIONDIR,'temp_M0.nii');
                xASL_Copy( fullfile(x.SESSIONDIR, 'M0.nii') ,OUTPUTFILE);
        end

        x.mutex.AddState('002_reslice_ASL');
    else    fprintf('%s\n','002_reslice_ASL session has already been performed, skipping...');
    end

    %%  3 Register M0 -> mean_control for all vendors except GE
    if  ~isempty(strfind(x.SESSIONDIR, 'PHBsup')) || ~isempty(strfind(x.SESSIONDIR, 'SI'))
        % If it is PhBsup or SI
        if ~x.mutex.HasState('0021_register_M0_mean_control')
            clear matlabbatch
            matlabbatch{1}.spm.spatial.coreg.estimate.ref               = { fullfile(x.SESSIONDIR,'temp_mean_control.nii') };
            matlabbatch{1}.spm.spatial.coreg.estimate.source            = { fullfile(x.SESSIONDIR,'temp_M0.nii') };
            matlabbatch{1}.spm.spatial.coreg.estimate.other             = { fullfile(x.SESSIONDIR,'M0.nii') };
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2 1];

            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

            spm_jobman('run',matlabbatch); close all

            x.mutex.AddState('0021_register_M0_mean_control');
        else    fprintf('%s\n','0021_register_M0_mean_control session has already been performed, skipping...');
        end
    end

    %%   (4 Clone data for other registration/masking combinations)

    %%  5 Mask PWI
    if  ~isempty(strfind(x.SESSIONDIR, 'PWIMASK'))
        if ~x.mutex.HasState('0022_PWIMASK')

            OUTPUTFILE      = fullfile(x.SESSIONDIR,'mean_PWI_Clipped.nii');
            MaskASLGradually_VENDORCOMPARISON( OUTPUTFILE, x );

            M0_file         = fullfile(x.SESSIONDIR,'temp_M0.nii');
            MaskFile        = fullfile(x.SESSIONDIR,'PWI_GradualMask.nii');

            %% Apply the same mask to M0
            if ~isempty(strfind(x.SESSIONDIR, 'PHBsup'))
                % PhBsup has different FoV for M0 than for PWI

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.write.ref              = {[ M0_file ',1']};
                matlabbatch{1}.spm.spatial.coreg.write.source           = {[MaskFile ',1']};
                matlabbatch{1}.spm.spatial.coreg.write.roptions.interp  = 1;
                matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap    = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.write.roptions.mask    = 0;
                matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix  = 'r';

                spm_jobman('run',matlabbatch);
                MaskFile        = fullfile(x.SESSIONDIR,'rPWI_GradualMask.nii');

            end

            M0_load         = xASL_nifti(  M0_file );
            MaskLoad        = xASL_nifti( MaskFile );

            M0IM            = M0_load.dat(:,:,:).*MaskLoad.dat(:,:,:);
            xASL_io_SaveNifti( MaskFile, M0_file, M0IM);

            x.mutex.AddState('0022_PWIMASK');
        else    fprintf('%s\n','0022_PWIMASK session has already been performed, skipping...');
        end
    end

    %%  5 Mask BET

    if  ~isempty(strfind(x.SESSIONDIR, 'BETMASK'))
        if ~x.mutex.HasState('0023_BETMASK')

            BETdir  = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendorOLD\BET_trial\BET_robust';
            PWI_FILE    = fullfile(x.SESSIONDIR,'mean_PWI_Clipped.nii');
            M0_FILE     = fullfile(x.SESSIONDIR,'temp_M0.nii');

            if ~isempty(strfind(x.SESSIONDIR, 'GE')) && isempty(strfind(x.SESSIONDIR, 'PHBsup')) && isempty(strfind(x.SESSIONDIR, 'PHnonBsup')) && isempty(strfind(x.SESSIONDIR, 'SI'))
                VENDORNAME  = 'GE';
            elseif ~isempty(strfind(x.SESSIONDIR, 'PHBsup'))
                VENDORNAME  = 'PHBsup';
            elseif ~isempty(strfind(x.SESSIONDIR, 'PHnonBsup'))
                VENDORNAME  = 'PHnonBsup';
            elseif ~isempty(strfind(x.SESSIONDIR, 'SI'))
                VENDORNAME  = 'SI';
            end

            BET_FILE    = fullfile( BETdir,[VENDORNAME '_' x.SUBJECT '_M0.nii_bet3.nii']);

            if  ~isempty(strfind(x.SESSIONDIR, 'PHBsup'))
                % Mask M0 first
                M0_IM       = xASL_nifti(M0_FILE);
                BET_IM      = xASL_nifti(BET_FILE);
                M0_IM       =  M0_IM.dat(:,:,:) .* single(logical(BET_IM.dat(:,:,:)));
                xASL_io_SaveNifti( BET_FILE, M0_FILE, M0_IM);

                % Resample M0 to PWI FOV
                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.write.ref              = {[ PWI_FILE ',1']};
                matlabbatch{1}.spm.spatial.coreg.write.source           = {[M0_FILE ',1']};
                matlabbatch{1}.spm.spatial.coreg.write.roptions.interp  = 1;
                matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap    = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.write.roptions.mask    = 0;
                matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix  = 'r';

                spm_jobman('run',matlabbatch);

                % Mask PWI with resampled masked M0
                BET_FILE    = fullfile( x.SESSIONDIR, 'rtemp_M0.nii')
                PWI_IM      = xASL_nifti(PWI_FILE);
                BET_IM      = xASL_nifti(BET_FILE);
                PWI_IM      = PWI_IM.dat(:,:,:) .* single(logical(BET_IM.dat(:,:,:)));
                xASL_io_SaveNifti( BET_FILE, PWI_FILE, PWI_IM);

            else
                PWI_IM      = xASL_nifti(PWI_FILE);
                M0_IM       = xASL_nifti(M0_FILE);
                BET_IM      = xASL_nifti(BET_FILE);

                PWI_IM      = PWI_IM.dat(:,:,:) .* single(logical(BET_IM.dat(:,:,:)));
                M0_IM       =  M0_IM.dat(:,:,:) .* single(logical(BET_IM.dat(:,:,:)));

                xASL_io_SaveNifti( BET_FILE, PWI_FILE, PWI_IM);
                xASL_io_SaveNifti( BET_FILE, M0_FILE, M0_IM);
            end

            x.mutex.AddState('0023_BETMASK');
        else    fprintf('%s\n','0023_BETMASK session has already been performed, skipping...');
        end
    end

    %% 3    Rigid registration

    if ~x.mutex.HasState('003_register_ASL_rigid') && isempty(findstr(x.SESSIONDIR, 'NoReg'))

        register_ASL_VENDORCOMPARISON_rigid(x);

        x.mutex.AddState('003_register_ASL_rigid');
    else    fprintf('%s\n','003_register_ASL_rigid       has already been performed, skipping...');
    end

    %% 4    Old Normalize
    if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))

        if ~x.mutex.HasState('004_register_ASL_oldNORMALIZE') && x.mutex.HasState('003_register_ASL_rigid')

            register_ASL_VENDORCOMPARISON_oldNORMALIZE(x);

            x.mutex.AddState('004_register_ASL_oldNORMALIZE');
        else    fprintf('%s\n','004_register_ASL_oldNORMALIZE       has already been performed, skipping...');
        end
    end

    %% 5    DARTEL
    if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))

        if ~x.mutex.HasState('005_register_ASL_DARTEL') && x.mutex.HasState('003_register_ASL_rigid') && x.mutex.HasState('004_register_ASL_oldNORMALIZE')

            register_ASL_VENDORCOMPARISON_DARTEL(x);

            x.mutex.AddState('005_register_ASL_DARTEL');
        else    fprintf('%s\n','005_register_ASL_DARTEL       has already been performed, skipping...');
        end
    end

    %% 6    Reslice ASL
    if ~x.mutex.HasState('006_reslice_ASL')

        % 2    Create slice gradient image for quantification reference, in case of 2D ASL
        % 3    Reslice ASL time series to MNI space (currently 1.5 mm^3)
        % 4    Create mean control image, masking to 20% of max value if used as M0 (no background suppression)
        % 5    Smart smoothing mean_control if used as M0

        % This only reslices slice_gradient
        reslice_ASL_VENDORCOMPARISON(x);

        x.mutex.AddState('006_reslice_ASL');
    else    fprintf('%s\n','006_reslice_ASL       has already been performed, skipping...');
    end
    %
    %
        %% 4    Process separate M0, if exists (all sequences except PHnonBsup)
    if isempty(strfind(x.SESSIONDIR, 'PHnonBsup'))
        if ~x.mutex.HasState('007_realign_reslice_M0')

                % 1)    Motion correction if there are multiple frames
                % 2)    Registration M0 -> mean_control_ASL image
                % 3)    Smart smoothing
                % 4)    Reslice M0 to MNI space (currently 1.5 mm^3)
                % 5)    Averaging if multiple frames
                % 6)    Masking
                % 7)    Correction for scale slopes & incomplete T1 recovery

            realign_reslice_M0_VENDORCOMPARISON(x);

            x.mutex.AddState('007_realign_reslice_M0');
        else    fprintf('%s\n','007_realign_reslice_M0                 has already been performed, skipping...');
        end
    end
        %
        %
    %% 5    Averaging & quantification
    % Quantification is performed here according to ASL consensus paper (Alsop, MRM 2016)
    if ~x.mutex.HasState('008_quantification')

        % 1    Prepare M0 image
        % 2    Prepare CBF image
        % 3    Load slice gradient if 2D
        % 4    CBF quantification equation
        % 5    Outlier rejection
        % 6    Division by M0 & scale slopes
        % 7    Remove non-perfusion values & divide by 1000 for DARTEL (DARTEL assumes probability maps with values <1)

        fprintf('%s\n','Quantifying ASL');
        average_quantify_ASL_VENDORCOMPARISON( x);

        x.mutex.AddState('008_quantification');
    else    fprintf('%s\n','008_quantification                     has already been performed, skipping...');
    end


%         %% 999 Ready
%         x.mutex.AddState('999_ready');


cd(oldFolder);

x.mutex.Unlock();
x.result  = true;
result          = true;

end
