x.D.ROOT    = 'C:\Backup\ASL\JordanaNifti';
Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_(1|2)$',1);

%% Load images

clear IM
for iF=1:length(Flist)
    clear tName tIM
    tName       = fullfile( x.D.ROOT, Flist{iF}, 'T1.nii');
    tIM         = xASL_io_ReadNifti(tName);
    tIM         = tIM.dat(:,:,:);
    IM{iF}      = tIM;
    SizeIM(iF,:)= size(IM{iF});
end

%% Reslice it first
TemplateName    = 'C:\Backup\ASL\JordanaNifti\dartel\SPECT.nii';
TemplateIM      = xASL_io_ReadNifti(TemplateName);
TemplateIM      = TemplateIM.dat(:,:,:);
TemplateIM      = TemplateIM./max(TemplateIM(:)); % rescale for DARTEL

clear matlabbatch
matlabbatch{1}.spm.spatial.coreg.write.ref = {'C:\Backup\ASL\JordanaNifti\dartel\SPECT.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

for iF=1:length(Flist)
    clear tName tIM
    tName       = fullfile( x.D.ROOT, Flist{iF}, 'T1.nii,1');
    matlabbatch{1}.spm.spatial.coreg.write.source = {tName};
    spm_jobman('run',matlabbatch);
end

%% Load resliced images
clear IM
for iF=1:length(Flist)
    clear tName tIM
    tName       = fullfile( x.D.ROOT, Flist{iF}, 'rT1.nii');
    tIM         = xASL_io_ReadNifti(tName);
    tIM         = tIM.dat(:,:,:);
    IM(:,:,:,iF)= tIM;
end

AverageIM       = mean(IM,4);
AverageIM1      = mean(IM(:,:,:,[1:2:end-1]),4);
AverageIM2      = mean(IM(:,:,:,[2:2:end-0]),4);
dip_image(AverageIM)
dip_image(AverageIM1)
dip_image(AverageIM2)

%% Get mean values & SD
for iF=1:length(Flist)
    clear tIM
    tIM                 = IM(:,:,:,iF);
    MeanValue(iF,1)     = mean(tIM(:));
    MeanValue(iF,2)     = std(tIM(:));
end
MeanValue(:,3)          = 100.*(MeanValue(:,2)./MeanValue(:,1));

%% First step  is linear registration of 2 to 1
%% Second step is linear registration of 1 to template, using 2 as co
%% Third step is resampling & image intensity resorting (Jan)
%% Fourth     is old_normalize for all to template (with settings Jan)
%% Fifth      is resample & check if single additional DARTEL iteration helps
%% (first DARTEL iteration settings, but without smoothing applied). Do this for session 2 to 1, and
%% for session 1 & 2 (paired per subject) to the group average

%% 1) Linear registration of 2 to 1 (if 2 exist)
Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_1$',1);

clear matlabbatch
matlabbatch{1}.spm.spatial.coreg.estimate.other             = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [6 4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

for iF=1:length(Flist)
    clear tName tName2

    tName       = fullfile( x.D.ROOT, Flist{iF}, 'T1.nii');
    tName2      = fullfile( x.D.ROOT, [Flist{iF}(1:end-1) '2'], 'T1.nii');
    matlabbatch{1}.spm.spatial.coreg.estimate.ref             = {[tName ',1']};

    if  exist(tName2,'file')
        matlabbatch{1}.spm.spatial.coreg.estimate.source      = {[tName2 ',1']};
        spm_jobman('run',matlabbatch);
    end
end

%% 2) Linear registration of 1 to template, 2 as co if exist
Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_1$',1);

clear matlabbatch
matlabbatch{1}.spm.spatial.coreg.estimate.ref               = {'C:\Backup\ASL\JordanaNifti\dartel\SPECT.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [6 4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

for iF=1:length(Flist)
    clear tName tName2
    tName       = fullfile( x.D.ROOT, Flist{iF}, 'T1.nii');
    tName2      = fullfile( x.D.ROOT, [Flist{iF}(1:end-1) '2'], 'T1.nii');

    matlabbatch{1}.spm.spatial.coreg.estimate.source        = {[tName  ',1']};

    if  exist(tName2,'file')
        matlabbatch{1}.spm.spatial.coreg.estimate.other     = {[tName2 ',1']};
    else
        matlabbatch{1}.spm.spatial.coreg.estimate.other     = {''};
    end

    spm_jobman('run',matlabbatch);
end

%% 3) Reslice them, create mean -> A) rT1 (linear registration)
%% Load resliced images
clear IM
for iF=1:length(Flist)
    clear tName tIM
    tName       = fullfile( x.D.ROOT, Flist{iF}, 'rT1.nii');
    tIM         = xASL_io_ReadNifti(tName);
    tIM         = tIM.dat(:,:,:);
    IM(:,:,:,iF)= tIM;
end

AverageIM       = mean(IM,4);

AverageIM       = ImRescaleJan( AverageIM, TemplateIM ); % rescale

xASL_io_SaveNifti(tName, fullfile( x.D.ROOT,'dartel','AveragePopTemp.nii'),AverageIM);

%% Old normalize (affine & elastic registration)

clear matlabbatch
matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source = {'C:\Backup\ASL\JordanaNifti\dartel\AveragePopTemp.nii,1'};
matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = {'C:\Backup\ASL\JordanaNifti\dartel\AveragePopTemp.nii,1'};
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = {'C:\Backup\ASL\JordanaNifti\dartel\SPECT.nii,1'};
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 0;
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'subj';
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb = [NaN NaN NaN
                                                         NaN NaN NaN];
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox = [2 2 2];
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix = 'w';

spm_jobman('run',matlabbatch);

%% Resample all images with the first affine registration -> B) wT1 (average -> template)

    clear matlabbatch

    matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {'C:\Backup\ASL\JordanaNifti\dartel\AveragePopTemp_sn.mat'};
    matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN
                                                      NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';

    x.D.ROOT    = 'C:\Backup\ASL\JordanaNifti';
    Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_1$',1); % estimate only on 1st now

    for iF=1:length(Flist)
        matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {fullfile( x.D.ROOT, Flist{iF}, 'T1.nii')};
        spm_jobman('run',matlabbatch);
    end

    %% Normalize them to the template
    for iF=1:length(Flist)
        SourceName      = fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii');
        SourceIM        = xASL_io_ReadNifti(SourceName);
        SourceIM        = SourceIM.dat(:,:,:);
        SourceIM        = ImRescaleJan(SourceIM,TemplateIM);
        xASL_io_SaveNifti(SourceName,SourceName,SourceIM);
    end

%% Try new affine/elastic

    clear matlabbatch
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = {'C:\Backup\ASL\JordanaNifti\dartel\SPECT.nii,1'};
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 0;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'subj';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb = [NaN NaN NaN
                                                             NaN NaN NaN];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox = [2 2 2];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp = 1;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix = 'w';

    for iF=24 % 1:length(Flist)
        matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source   = {fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii,1')};
        matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = {fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii,1')};
        spm_jobman('run',matlabbatch);
    end

%% Resample all images with the first affine registration -> C) wT1 (average -> template)

clear matlabbatch

matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {'C:\Backup\ASL\JordanaNifti\dartel\AveragePopTemp_sn.mat'};
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';

x.D.ROOT    = 'C:\Backup\ASL\JordanaNifti';
Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_1$',1); % estimate only on 1st now

for iF=1:length(Flist)
    matlabbatch{1}.spm.util.defs.comp{2}.sn2def.matname = {fullfile( x.D.ROOT, Flist{iF}, 'wT1_sn.mat')};
    matlabbatch{1}.spm.util.defs.comp{2}.sn2def.vox = [NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.comp{2}.sn2def.bb = [NaN NaN NaN
                                                      NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {fullfile( x.D.ROOT, Flist{iF}, 'T1.nii')};
    spm_jobman('run',matlabbatch);
end

for iF=1:length(Flist)
    FileName    = fullfile( x.D.ROOT, [Flist{iF}(1:end-1) '2'], 'T1.nii');

    if exist(FileName, 'file')

        matlabbatch{1}.spm.util.defs.comp{2}.sn2def.matname = {fullfile( x.D.ROOT, Flist{iF}, 'wT1_sn.mat')};
        matlabbatch{1}.spm.util.defs.comp{2}.sn2def.vox = [NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.comp{2}.sn2def.bb = [NaN NaN NaN
                                                          NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { FileName };
        spm_jobman('run',matlabbatch);
    end
end

%% Create new average (C -> individual to template)
%% Load resliced images
clear IM
for iF=1:length(Flist)
    clear tName tIM
    tName       = fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii');
    tIM         = xASL_io_ReadNifti(tName);
    tIM         = tIM.dat(:,:,:);
    IM(:,:,:,iF)= tIM;
end

AverageIM       = mean(IM,4);
xASL_io_SaveNifti(tName, fullfile( x.D.ROOT,'dartel','wwAveragePopTemp.nii'),AverageIM);

% %% Make ready for DARTEL
% TemplateIM  = TemplateIM./max(TemplateIM(:));
%
% for iF=1:length(Flist)
%     SourceName      = fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii');
%     SourceIM        = xASL_io_ReadNifti(SourceName);
%     SourceIM        = SourceIM.dat(:,:,:);
%     SourceIM        = ImRescaleJan(SourceIM,TemplateIM);
%     xASL_io_SaveNifti(SourceName,SourceName,SourceIM);
%
%     FileName    = fullfile( x.D.ROOT, [Flist{iF}(1:end-1) '2'], 'wT1.nii');
%
%     if exist(FileName, 'file')
%         SourceName      = fullfile( FileName );
%         SourceIM        = xASL_io_ReadNifti(SourceName);
%         SourceIM        = SourceIM.dat(:,:,:);
%         SourceIM        = ImRescaleJan(SourceIM,TemplateIM);
%         xASL_io_SaveNifti(SourceName,SourceName,SourceIM);
%     end
% end

% %% DARTEL
%
% % repeat to get better estimate
%
% clear matlabbatch warp
% Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_1$',1);
%
% for iF=1:length(Flist)
%     warp.images{1}{iF,1}             = fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii,1');
% end
%
% iIT=6;
%
% warp.settings.rform             = 0;
% warp.settings.optim.its         = 3;
% warp.settings.optim.lmreg       = 0.01;
% warp.settings.optim.cyc         = 3;
%
% fprintf('\n\n\n');
% fprintf(['\nDARTEL is run']);
%
% rparam1     = [4  2   1  0.5 0.25   0.25];
% rparam2     = [2  1 0.5 0.25 0.125 0.125];
% K           = [0  0   2    4    6      8];
%
% warp.settings.param(1).its      = 3;
% warp.settings.param(1).rparam   = [rparam1(iIT) rparam2(iIT) 1e-06];
% warp.settings.param(1).K        = K(iIT);
% warp.settings.param(1).slam     = 0;
%
% matlabbatch{1}.spm.tools.dartel.warp   = warp;
%
% spm_jobman('run',matlabbatch);
%
% %% Resample all images with the first DARTEL -> D) wT1 (average -> template)
%
% clear matlabbatch
%
% matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {'C:\Backup\ASL\JordanaNifti\dartel\AveragePopTemp_sn.mat'};
% matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
% matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN
%                                                   NaN NaN NaN];
% matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
% matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 1;
% matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
% matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
% matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'ww';
%
% x.D.ROOT    = 'C:\Backup\ASL\JordanaNifti';
% Flist           = xASL_adm_GetFsList(x.D.ROOT, '^\d{2}_1$',1); % estimate only on 1st now
%
% for iF=1:30 % :length(Flist)
%     matlabbatch{1}.spm.util.defs.comp{2}.sn2def.matname = {fullfile( x.D.ROOT, Flist{iF}, 'wT1_sn.mat')};
%     matlabbatch{1}.spm.util.defs.comp{2}.sn2def.vox = [NaN NaN NaN];
%     matlabbatch{1}.spm.util.defs.comp{2}.sn2def.bb = [NaN NaN NaN
%                                                       NaN NaN NaN];
%    matlabbatch{1}.spm.util.defs.comp{3}.dartel.flowfield    = {fullfile( x.D.ROOT, Flist{iF}, 'u_wT1_Template.nii')};
%    matlabbatch{1}.spm.util.defs.comp{3}.dartel.times        = [1 0];
%    matlabbatch{1}.spm.util.defs.comp{3}.dartel.K            = 6;
%    matlabbatch{1}.spm.util.defs.comp{3}.dartel.template     = {''};
%
%     matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {fullfile( x.D.ROOT, Flist{iF}, 'T1.nii')};
%     spm_jobman('run',matlabbatch);
% end
%
% % for iF=1:length(Flist)
% %     FileName    = fullfile( x.D.ROOT, [Flist{iF}(1:end-1) '2'], 'T1.nii');
% %
% %     if exist(FileName, 'file')
% %
% %         matlabbatch{1}.spm.util.defs.comp{2}.sn2def.matname = {fullfile( x.D.ROOT, Flist{iF}, 'wT1_sn.mat')};
% %         matlabbatch{1}.spm.util.defs.comp{2}.sn2def.vox = [NaN NaN NaN];
% %         matlabbatch{1}.spm.util.defs.comp{2}.sn2def.bb = [NaN NaN NaN
% %                                                           NaN NaN NaN];
% %        matlabbatch{1}.spm.util.defs.comp{3}.dartel.flowfield    = {fullfile( x.D.ROOT, Flist{iF}, 'u_wT1_Template.mat')};
% %        matlabbatch{1}.spm.util.defs.comp{3}.dartel.times        = [1 0];
% %        matlabbatch{1}.spm.util.defs.comp{3}.dartel.K            = 6;
% %        matlabbatch{1}.spm.util.defs.comp{3}.dartel.template     = {''};
% %         matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { FileName };
% %         spm_jobman('run',matlabbatch);
% %     end
% % end
%
% %% Load resliced images
% clear IM
% for iF=1:length(Flist)
%     clear tName tIM
%     tName       = fullfile( x.D.ROOT, Flist{iF}, 'wT1.nii');
%     tIM         = xASL_io_ReadNifti(tName);
%     tIM         = tIM.dat(:,:,:);
%     IM(:,:,:,iF)= tIM;
% end
%
% AverageIM       = mean(IM,4);
% xASL_io_SaveNifti(tName, fullfile( x.D.ROOT,'dartel','wwwAveragePopTemp.nii'),AverageIM);
%
%
% % Check results DARTEL
% % Check non NaNs in wT1.nii for DARTEL
%
%
% %% 25_1 was weirdly reconstructed
