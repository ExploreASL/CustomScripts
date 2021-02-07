%% combine flow field with registration to go from PET space into MNI space

% program unzip & zip

for iS=1:x.nSubjects % iS=9 to try
    try
        % Define file names
        T1_PET              = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_T1PET.nii']);
        T1_xASL             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'T1.nii');
        matname             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_T1PET_sn.mat']);
        def_xASL            = fullfile(x.D.ROOT,x.SUBJECTS{iS},'y_T1.nii');
        PETdir              = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET');

        xASL_adm_UnzipNifti(T1_PET);
        xASL_adm_UnzipNifti(T1_xASL);

        % Do the registration
        clear matlabbatch
        matlabbatch{1}.spm.tools.oldnorm.est.subj.source                = {T1_PET};
        matlabbatch{1}.spm.tools.oldnorm.est.subj.wtsrc                 = '';
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.template          = {T1_xASL};
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.weight            = '';
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smosrc            = 8;
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smoref            = 8;
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.regtype           = 'none';
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.cutoff            = Inf;
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.nits              = 0;
        matlabbatch{1}.spm.tools.oldnorm.est.eoptions.reg               = Inf;
        spm_jobman('run',matlabbatch);


        % Combine the registration transformation with the xASL 2 MNI
        % transformation
        clear matlabbatch
        matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname             = {matname};
        matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox                 = [NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb                  = [NaN NaN NaN
                                                                           NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.comp{2}.def                        = {def_xASL};
        matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname              = 'PET_2_MNI_space';
        matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr     = {PETdir};
        spm_jobman('run',matlabbatch);
        delete(matname);

        if  exist(T1_PET,'file') && exist([T1_PET '.gz'],'file')
            delete(T1_PET);
        end
        if  exist(T1_xASL,'file') && exist([T1_xASL '.gz'],'file')
            delete(T1_xASL);
        end
    end
end

%% Bring all PET to MNI space

for iS=1:x.nSubjects % iS=9 to try
    try
    % Define file names
%     asl_PET             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} 'qCBF_untreated_PET.nii']);
    r1_PET              = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_R1.nii']);
    wr1_PET             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',['w' x.SUBJECTS{iS} '_R1.nii']);
    def_PET             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','y_PET_2_MNI_space.nii');
    PETdir              = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET');
    r1_DARTEL           = fullfile(x.D.PopDir,['R1_' x.SUBJECTS{iS} '.nii']);

%     xASL_adm_UnzipNifti(asl_PET);
    xASL_adm_UnzipNifti(r1_PET);

    % Clip below zero
    IM                  = single(xASL_io_Nifti2Im(r1_PET));
    IM(IM<0)            = 0;

    % Convert them first to floating point
    xASL_io_SaveNifti(r1_PET,r1_PET, IM  ,32);

    % Unzip first!
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.def                            = {def_PET};
    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames                     = {r1_PET};
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc            = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.interp                     = 4;
    matlabbatch{1}.spm.util.defs.out{1}.pull.mask                       = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm                       = [0 0 0];
    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix                     = '';
    spm_jobman('run',matlabbatch);

    xASL_Move(wr1_PET, r1_DARTEL,1);

    end
end


%% Move one image from PET to MNI space
% Unzip first!
clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.def                            = {'C:\Backup\ASL\TwinExample\twins_ASL\EMI_325\PET\y_PET_2_MNI_space.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames                     = {'C:\Backup\ASL\TwinExample\twins_ASL\EMI_325\PET\EMI_325qCBF_untreated_PET.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc            = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.interp                     = 4;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask                       = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm                       = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix                     = '';
spm_jobman('run',matlabbatch);


%% Move one image from MNI to PET space

clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def                = {'C:\Backup\ASL\TwinExample\twins_ASL\EMI_370\y_T1.nii'};
matlabbatch{1}.spm.util.defs.comp{1}.inv.space                      = {'C:\Backup\ASL\TwinExample\twins_ASL\EMI_370\PET\EMI_370_R1.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames                     = {'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr            = {'C:\Backup\ASL\TwinExample\twins_ASL\EMI_370\PET'};
matlabbatch{1}.spm.util.defs.out{1}.pull.interp                     = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask                       = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm                       = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix                     = '';
spm_jobman('run',matlabbatch);







%% Try registration in native space

for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects);

    %% Put template into PET space
    % Define file names
    R1_PET              = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_R1.nii']);
    R1_PET_Backup       = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_R1_Backup.nii']);

    T1_xASL             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'T1.nii');
    matname             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_T1PET_sn.mat']);
    def_PET             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','y_PET_2_MNI_space.nii');
    PETdir              = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET');
    TemplatePET         = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','wTemplate_mean_R1_SingleSite.nii');
    MaskPET             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET','wTemplate_mean_R1_SingleSite_Mask.nii');
    R1_Masked           = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',[x.SUBJECTS{iS} '_R1_Masked.nii']);

    wr1_PET             = fullfile(x.D.ROOT,x.SUBJECTS{iS},'PET',['w' x.SUBJECTS{iS} '_R1.nii']);
    r1_DARTEL           = fullfile(x.D.PopDir,['R1_' x.SUBJECTS{iS} '.nii']);

    % Move template to native space
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def                = {def_PET};
    matlabbatch{1}.spm.util.defs.comp{1}.inv.space                      = {R1_PET};
    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames                     = {'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite.nii';'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite_Mask.nii'};
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr            = {PETdir};
    matlabbatch{1}.spm.util.defs.out{1}.pull.interp                     = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.mask                       = 0;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm                       = [0 0 0];
    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix                     = '';
    spm_jobman('run',matlabbatch);

    % Backup original
    xASL_Copy(R1_PET,R1_PET_Backup);

    % Mask the image
    IM          = single(xASL_io_Nifti2Im(MaskPET).*xASL_io_Nifti2Im(R1_PET));
    IM(IM<0)    = 0;
    xASL_io_SaveNifti(R1_PET, R1_Masked, IM, 32 );

%     %% Re-register
%     clear matlabbatch
%     matlabbatch{1}.spm.spatial.coreg.estimate.ref                   = {TemplatePET};
%     matlabbatch{1}.spm.spatial.coreg.estimate.source                = {R1_PET};
%     matlabbatch{1}.spm.spatial.coreg.estimate.other                 = {''};
%     matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun     = 'nmi';
%     matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep          = [4 2];
%     matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol          = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
%     matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm         = [7 7];
%     spm_jobman('run',matlabbatch);


    %% Re-register
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.estimate.ref                   = {TemplatePET};
    matlabbatch{1}.spm.spatial.coreg.estimate.source                = {R1_Masked};
    matlabbatch{1}.spm.spatial.coreg.estimate.other                 = {R1_PET};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun     = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep          = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol          = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm         = [7 7];
    spm_jobman('run',matlabbatch);

    delete(TemplatePET); delete(R1_Masked); delete(MaskPET);

    % Update the R1 standard space image
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.def                            = {def_PET};
    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames                     = {R1_PET};
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc            = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.interp                     = 4;
    matlabbatch{1}.spm.util.defs.out{1}.pull.mask                       = 0;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm                       = [0 0 0];
    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix                     = '';
    spm_jobman('run',matlabbatch);

    xASL_Move(wr1_PET, r1_DARTEL,1);
end
