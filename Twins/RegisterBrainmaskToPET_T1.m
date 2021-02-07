
% Loop over all subjects
for iS=1:x.nSubjects
    % Define file names for each iteration
    MNI_BrainMask       = fullfile('ForPET_T1_reg','rbrainmask.nii'); % you can try both brainmasks
    MNI_T1image         = fullfile('ForPET_T1_reg','Cmp_rT1.nii'); % try both the blurred and non-blurred template
    T1_PET_FileName     = fullfile('SubjectFolder','T1in_PET_native_space.nii');
    
    clear matlabbatch
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source           = {MNI_T1image}; 
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc            = '';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample         = {MNI_BrainMask};
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template     = {T1_PET_FileName};
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight       = '';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc       = 3; % or try 0 or 5, depends on smoothness MNI T1w template image
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref       = 5; % or try 3, depends on the smoothness of the subjects' T1w in PET space
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype      = 'mni';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff       = 25;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits         = 16;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg          = 1;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve     = 0;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb           = [NaN NaN NaN
                                                                       NaN NaN NaN];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox          = [NaN NaN NaN];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp       = 1;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap         = [0 0 0];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix       = 'w';
    
    spm_jobman('run',matlabbatch);

    %% Multiply the T1w in PET-space with the brainmask, for brainmask>0.5 (if it is a smooth map rather than binary mask)
    %% Notice the 'w' prefix for the mask

    spm_jobman('run',matlabbatch);
end