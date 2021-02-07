%% Start ExploreASL
%% Make sure you have for each patient: rT1*.nii (T1w in ASL MNI space) & qCBF_untreated*.nii (CBF in ASL MNI space) & *MRI2PET.img (T1w in PET native space) & *R1.img (R1 in PET native space).
%  And be careful, the PET image does not seem to be sufficiently
%  registered to the T1w in PET space!

% Loop over all subjects
for iS=1:x.nSubjects
    % Define file names
    PET_R1_FileName     = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','R1.nii');
    T1w_R1_FileName     = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','MRI2PET.nii');
    T1_ASL_FileName     = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','T1in_ASL_native_space.nii');
    CBF_ASL_FileName    = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','qCBFin_ASL_native_space.nii');
    T1_ASL_FileNameORI  = fullfile(x.D.ROOT,x.SUBJECTS{iS},'T1.nii');
    
    
    %% Copy T1w to PET folder
    xASL_Copy(T1_ASL_FileNameORI,T1_ASL_FileName);
    
    %% First put the ASL in MNI space back into native space
    xASL_spm_deformations(x,x.SUBJECTS{iS},fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_1.nii']),fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','qCBFin_ASL_native_space.nii'),4,x.D.ResliceRef);

    %% Then register the T1w & apply to ASL orientation matrix in NIfTI header
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.estimate.ref                   = {T1w_R1_FileName}; % T1w file in PET space
    matlabbatch{1}.spm.spatial.coreg.estimate.source                = {T1_ASL_FileName}; % T1w file in ASL space
    matlabbatch{1}.spm.spatial.coreg.estimate.other                 = {CBF_ASL_FileName}; % ASL file
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun     = 'nmi'; % cost function
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep          = [4 2]; % quality
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol          = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm         = [7 7];

    spm_jobman('run',matlabbatch);


    %% Resample the ASL image into PET space. This puts it in the same resolution as the PET image ([2 2 2]), and apply the ASL NIfTI header transformation to the ASL NIfTI image
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.write.ref                      = {PET_R1_FileName}; % PET file in PET space
    matlabbatch{1}.spm.spatial.coreg.write.source                   = {CBF_ASL_FileName}; % ASL file in ASL space
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp          = 4; % quality
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap            = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask            = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix          = 'r'; % name change new ASL file

    spm_jobman('run',matlabbatch);
end
