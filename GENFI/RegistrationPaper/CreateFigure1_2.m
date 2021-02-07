%% Create first Figure GENFI ASL methods paper

% First determine representable subjects
% Get subjects with highest & lowest spatial CoV for all sequences
% Using the PWI-masked approach
% ('C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK')

%% Administration

BMASK   = 'C:\ASL_pipeline_HJ\Maps\rbrainmask.nii';
BMASK   = xASL_nifti(BMASK);
BMASK   = BMASK.dat(:,:,:);
BMASK   = BMASK>0.5;

x.piet=1;

x = vis_settings( x );

ROOT{1}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis';
ROOT{2}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis';
ROOT{3}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva no Bsup\analysis';
ROOT{4}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\SI Trio\analysis';

vName       = {'GE' 'PhBsup' 'PHnoBsup' 'SI'};
Subject     = {'GRN029' 'GRN006' 'C9ORF007' 'C9ORF019'};

ODIR        = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis\Figure1_rawIM';

% HC with lowest spatial CoV

%% Prepare M0/mean_control
% for iV=1:4
%
%     clear matlabbatch NewM0File
%
%     % M0
%     if  iV==3
%         IM_name{4}{iV}  = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'ASL4D.nii'); % M0
%         tnii            = xASL_nifti( IM_name{4}{iV} );
%         tnii            = tnii.dat(:,:,:,:);
%         tnii            = mean(tnii(:,:,:,1:2:end-1),4);
%         NewM0File       = fullfile(ODIR,'M0.nii');
%         xASL_io_SaveNifti( IM_name{4}{iV}, NewM0File, tnii,1);
%
%         IM_name{4}{iV}  = NewM0File;
%     else
%         IM_name{4}{iV}     = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'M0.nii'); % M0
%     end
%
%     % Deformation tool, register M0 to MNI
%     clear matlabbatch
%     matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( ROOT{iV}, Subject{iV}, 'y_T1.nii')};
%
%     if      iscell(IM_name{4}{iV})
%             matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = IM_name{4}{iV};
%     else    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = {IM_name{4}{iV}};
%     end
%
%     matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {ODIR};
%
%     matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 4;
%
%     matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
%     matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];
%
%     spm_jobman('run',matlabbatch);
%
%     NewM0File   = fullfile(ODIR,['M0_' Subject{iV} '.nii']);
%     xASL_Move(fullfile(ODIR,'wM0.nii'), NewM0File);
%
%     delete(fullfile(ODIR,'M0.nii'));
%     delete(fullfile(ODIR,'M0.mat'));

% end

%% Prepare PWI
for iV=1:4

    clear matlabbatch NewM0File

    IM_name{3}{iV}  = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'ASL4D.nii'); % M0
    tnii            = xASL_nifti( IM_name{3}{iV} );
    tnii            = tnii.dat(:,:,:,:);

    if  size(tnii,4)>1
        tnii            = tnii(:,:,:,[1:2:end-1]) - tnii(:,:,:,[2:2:end]);

        if iV==4; tnii=-tnii; end

        tnii            = xASL_stat_MeanNan(tnii,4);
    end

    NewM0File       = fullfile(ODIR,'PWI.nii');
    xASL_io_SaveNifti( IM_name{3}{iV}, NewM0File, tnii,1);

    IM_name{3}{iV}  = NewM0File;

    % Deformation tool, register M0 to MNI
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( ROOT{iV}, Subject{iV}, 'y_T1.nii')};

    if      iscell(IM_name{4}{iV})
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = IM_name{3}{iV};
    else    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = {IM_name{3}{iV}};
    end

    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {ODIR};

    matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 4;

    matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];

    spm_jobman('run',matlabbatch);

    NewM0File   = fullfile(ODIR,['PWI_' Subject{iV} '.nii']);
    xASL_Move(fullfile(ODIR,'wPWI.nii'), NewM0File);

    delete(fullfile(ODIR,'PWI.nii'));
    delete(fullfile(ODIR,'PWI.mat'));
end

%% Prepare T1
for iV=1:4

    clear matlabbatch NewM0File

    IM_name{1}{iV}  = fullfile( ROOT{iV}, Subject{iV}, 'T1.nii');

    % Deformation tool, register M0 to MNI
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( ROOT{iV}, Subject{iV}, 'y_T1.nii')};

    if      iscell(IM_name{4}{iV})
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = IM_name{1}{iV};
    else    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = {IM_name{1}{iV}};
    end

    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {ODIR};

    matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 4;

    matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];

    spm_jobman('run',matlabbatch);

    NewM0File   = fullfile(ODIR,['T1_' Subject{iV} '.nii']);
    xASL_Move(fullfile(ODIR,'wT1.nii'), NewM0File);

end

%% Prepare pGM
for iV=1:4

    clear matlabbatch NewM0File

    IM_name{2}{iV}  = fullfile( ROOT{iV}, Subject{iV}, 'c1T1.nii');

    % Deformation tool, register M0 to MNI
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( ROOT{iV}, Subject{iV}, 'y_T1.nii')};

    if      iscell(IM_name{4}{iV})
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = IM_name{2}{iV};
    else    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = {IM_name{2}{iV}};
    end

    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {ODIR};

    matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 4;

    matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];

    spm_jobman('run',matlabbatch);

    NewM0File   = fullfile(ODIR,['c1T1_' Subject{iV} '.nii']);
    xASL_Move(fullfile(ODIR,'wc1T1.nii'), NewM0File);

end

%% Define filenames

for iV=1:4
    IM_name{1}{iV}     = fullfile( ODIR    , ['T1_' Subject{iV} '.nii']);
    IM_name{2}{iV}     = fullfile( ODIR    , ['c1T1_' Subject{iV} '.nii']);
    IM_name{3}{iV}     = fullfile( ODIR    , ['PWI_' Subject{iV} '.nii']);
    IM_name{4}{iV}     = fullfile( ODIR    , ['M0_' Subject{iV} '.nii']);
end

%% Load them
for iV=1:4
    for iIM=1:4
        clear tnii
        tnii                = xASL_nifti( IM_name{iIM}{iV} );
        tnii                = tnii.dat(:,:,:);
        IM{iIM}(iV,:,:,:)   = tnii./(xASL_stat_MedianNan(tnii(BMASK))/40); % Scaling
        IM{iIM}(IM{iIM}<0)  = 0; % clip sub-zero
    end
end

%% Rescale
IM{3}(1,:,:,:)   = IM{3}(1,:,:,:) .* 1.1; % GE CBF
IM{3}(4,:,:,:)   = IM{3}(4,:,:,:) .* 0.75; % SI CBF



%% Show them
clear view_IM
x.S.ConcatSliceDims           = 1; % 0 = vertical, 1 = horizontal

x.S.TraSlices                 = 53; % x.slices; % [30+([1:20]-1).*round((100-30)/19)]; % 30 - 100
x.S.CorSlices                 = 74; % or 53; x.slices; % [15+([1:20]-1).*round((130-15)/19)]; % 15 - 130
x.S.SagSlices                 = 53; % x.slices; % [15+([1:20]-1).*round((110-15)/19)]; % 15 - 110

for iIM=1:4
    view_IM{iIM} = TransformDataViewDimension( IM{iIM}, x );
end

figure(1);imshow([singlesequencesort(view_IM{1},4);singlesequencesort(view_IM{2},4);singlesequencesort(view_IM{4},4);singlesequencesort(view_IM{3},4)],[0 100])
