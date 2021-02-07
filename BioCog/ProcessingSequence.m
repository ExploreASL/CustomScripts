%% 1) import scans Utrecht -> best quality FLAIR, so use these anatomical scans
% Ran full pipeline, with LPA, only 603, 604 and 607 with LGA

x.S.jet_256         = jet(256);
x.S.jet_256(1,:)    = 0;
x.S.TraSlices     = 34:7:90;
x.S.StatsDir      = fullfile(x.D.PopDir,'STATS_SPM');

%% 2) restructure ASL scans Utrecht
% for iS=1:x.nSubjects
%     xASL_TrackProgress(iS,x.nSubjects);
%     Fname   =     fullfile(x.D.ROOT, x.SUBJECTS{iS}, 'ASL_1', 'ASL4D.nii');
%     tIM     = xASL_io_Nifti2Im(Fname);
%     clear cIM
%     cIM(:,:,1:2:17,:)     = tIM(:,:, 1: 9,:);
%     cIM(:,:,2:2:17,:)     = tIM(:,:,10:17,:);
%
%     xASL_io_SaveNifti(Fname,Fname,cIM);
% end

%% 3) Import PCASL Berlin as ASL_2

% -> rewrite without session independency -> if session exist, register
% with T1



%% 4) excluded 003 -> went wrong in Utrecht (checked with the scanner-calculated DICOM)


%% Load all images
clear IMutrech IMBerlin pGM pWM
for iS=1:x.nSubjects
    clear tNII
    xASL_TrackProgress(iS,x.nSubjects)
    tnII                 = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_1.nii']));
    IMutrech(iS,:,:,:)   = xASL_im_ndnanfilter(tnII,'gauss',[1.885 1.885 1.885]);

    clear tNII
    tnII                 = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_2.nii'])).*10;
    IMBerlin(iS,:,:,:)   = xASL_im_ndnanfilter(tnII,'gauss',[1.885 1.885 1.885]);
%     PrintCBF_BioCog(IMBerlin(iS,:,:,:),IMutrech(iS,:,:,:),x,iS,0,150,'grey');
end

for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects)
    pGM(iS,:,:,:)   = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['rc1T1_' x.SUBJECTS{iS} '.nii']));
    pWM(iS,:,:,:)   = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['rc2T1_' x.SUBJECTS{iS} '.nii']));
end

Mean_pGM        = squeeze(xASL_stat_MeanNan(pGM,1));
Mean_pWM        = squeeze(xASL_stat_MeanNan(pWM,1));
MeanU           = squeeze(xASL_stat_MeanNan(IMutrech,1));
MeanB           = squeeze(xASL_stat_MeanNan(IMBerlin,1));

PrintCBF_BioCog(MeanB,MeanU,x,1,0,150);

%% Rescale based on median images
clear MeanU MeanB ScalefU ScalefB
MeanU           = squeeze(xASL_stat_MedianNan(IMutrech,1));
MeanB           = squeeze(xASL_stat_MedianNan(IMBerlin,1));
ScalefU         = 60/xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(MeanU(logical(x.SteepSkullMap)))));
ScalefB         = 60/xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(MeanB(logical(x.SteepSkullMap)))));

IMutrech        = IMutrech.*ScalefU;
IMBerlin        = IMBerlin.*ScalefB;

MeanU           = squeeze(xASL_stat_MeanNan(IMutrech,1));
MeanB           = squeeze(xASL_stat_MeanNan(IMBerlin,1));

PrintCBF_BioCog(MeanB,MeanU,x,2,0,150);

% for iS=1:x.nSubjects
%     PrintCBF_BioCog(IMBerlin(iS,:,:,:),IMutrech(iS,:,:,:),x,iS,0,150,'grey');
% end

%% Smooth Utrecht to the same resolution
for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects)
    IMutrech(iS,:,:,:)   = dip_array(smooth(IMutrech(iS,:,:,:),0.85));
end

PrintCBF_BioCog(MeanU,xASL_stat_MeanNan(IMutrech,1),x,3,0,150);
MeanU           = squeeze(xASL_stat_MeanNan(IMutrech,1));
PrintCBF_BioCog(MeanB,MeanU,x,4,0,150);

%% Get biasfield
clear BiasfieldB BiasfieldU AvBiasfield
MeanU(~x.SteepSkullMap)   = NaN;
MeanB(~x.SteepSkullMap)   = NaN;
BiasfieldU      = xASL_im_ndnanfilter(MeanU,'gauss',[5.652 5.652 5.652]); % == FWHM 6.358 mm
BiasfieldB      = xASL_im_ndnanfilter(MeanB,'gauss',[5.652 5.652 5.652]); % == FWHM 6.358 mm
AvBiasfield     = (BiasfieldU+BiasfieldB)./2;
BiasfieldU      = AvBiasfield./BiasfieldU;
BiasfieldB      = AvBiasfield./BiasfieldB;

PrintCBF_BioCog(BiasfieldB,BiasfieldU,x,5,0.8,1.2);



%% Adapt for biasfield
IMutrech        = IMutrech.*repmat(reshape(BiasfieldU,[1 121 145 121]),[14 1 1 1]);
IMBerlin        = IMBerlin.*repmat(reshape(BiasfieldB,[1 121 145 121]),[14 1 1 1]);

MeanU           = squeeze(xASL_stat_MeanNan(IMutrech,1));
MeanB           = squeeze(xASL_stat_MeanNan(IMBerlin,1));
PrintCBF_BioCog(MeanB,MeanU,x,6,0,150);

FileSaveU       = fullfile( x.S.StatsDir, 'MeanU.nii');
FileSaveB       = fullfile( x.S.StatsDir, 'MeanB.nii');
FileSavepGM     = fullfile( x.S.StatsDir, 'Mean_pGM.nii');
FileSavepWM     = fullfile( x.S.StatsDir, 'Mean_pWM.nii');

xASL_io_SaveNifti(x.D.ResliceRef,FileSaveB, MeanB,32);
xASL_io_SaveNifti(x.D.ResliceRef,FileSaveU, MeanU,32);
xASL_io_SaveNifti(x.D.ResliceRef,FileSavepGM, Mean_pGM,16);
xASL_io_SaveNifti(x.D.ResliceRef,FileSavepWM, Mean_pWM,16);


%% Create pseudo-CBF image for non-linear registration

% % Preprocess images for DARTEL
% MeanU(isnan(MeanU))     = 0;
% MeanB(isnan(MeanB))     = 0;
% MeanU(MeanU>200)        = 200;
% MeanU(MeanU<0)          = 0;
% MeanB(MeanB>200)        = 200;
% MeanB(MeanB<0)          = 0;
% MeanU(~logical(x.SteepSkullMap))  = 0;
% MeanB(~logical(x.SteepSkullMap))  = 0;
% MeanU   = MeanU./200;
% MeanB   = MeanB./200;
%
% xASL_io_SaveNifti(x.D.ResliceRef,FileSaveB, MeanB,32);
% xASL_io_SaveNifti(x.D.ResliceRef,FileSaveU, MeanU,32);
%
% clear matlabbatch
% matlabbatch{1}.spm.tools.dartel.warp.images = {
%                                                {
%                                                'C:\Backup\ASL\BioCog_Repro\analysis\dartel\STATS_SPM\MeanB.nii,1'
%                                                'C:\Backup\ASL\BioCog_Repro\analysis\dartel\STATS_SPM\MeanU.nii,1'
%                                                }
%                                                }';
% matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
% matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
% matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
% matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
% matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
% matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;
%
% spm_jobman('run',matlabbatch);

%% Apply DARTEL
% Save all images first
SaveDir     = fullfile(x.S.StatsDir,'IMafterDARTEL');
% xASL_adm_CreateDir(SaveDir);
% for iS=1:x.nSubjects
%     FileName    = fullfile(SaveDir,['qCBF_treated_' num2str(iS) '_ASL_1.nii']);
%     xASL_io_SaveNifti(x.D.ResliceRef,FileName,squeeze(IMutrech(iS,:,:,:)),32);
%
%     FileName    = fullfile(SaveDir,['qCBF_treated_' num2str(iS) '_ASL_2.nii']);
%     xASL_io_SaveNifti(x.D.ResliceRef,FileName,squeeze(IMBerlin(iS,:,:,:)),32);
%
%     xASL_TrackProgress(iS,x.nSubjects);
% end
%
% % run transformations
% clear matlabbatch
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {'C:\Backup\ASL\BioCog_Repro\analysis\dartel\STATS_SPM\u_MeanU_Template.nii'};
% for iS=1:x.nSubjects; matlabbatch{1}.spm.util.defs.out{1}.pull.fnames{iS,1}   = fullfile(SaveDir,['qCBF_treated_' num2str(iS) '_ASL_1.nii']); end
%
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1 0];
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
% matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
% matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
% matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0;
% matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
% matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';
%
% spm_jobman('run',matlabbatch);
%
% clear matlabbatch
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {'C:\Backup\ASL\BioCog_Repro\analysis\dartel\STATS_SPM\u_MeanB_Template.nii'};
% for iS=1:x.nSubjects; matlabbatch{1}.spm.util.defs.out{1}.pull.fnames{iS,1}   = fullfile(SaveDir,['qCBF_treated_' num2str(iS) '_ASL_2.nii']); end
%
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1 0];
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
% matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
% matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
% matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
% matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0;
% matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
% matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';
%
% spm_jobman('run',matlabbatch);

% Reload images

clear IMutrech IMBerlin
for iS=1:x.nSubjects
    clear tNII
    xASL_TrackProgress(iS,x.nSubjects)
    IMutrech(iS,:,:,:)          = xASL_io_Nifti2Im(fullfile(SaveDir,['wqCBF_treated_' num2str(iS) '_ASL_1.nii']));

    clear tNII
    IMBerlin(iS,:,:,:)          = xASL_io_Nifti2Im(fullfile(SaveDir,['wqCBF_treated_' num2str(iS) '_ASL_2.nii']));
end

MeanU           = squeeze(xASL_stat_MeanNan(IMutrech,1));
MeanB           = squeeze(xASL_stat_MeanNan(IMBerlin,1));
PrintCBF_BioCog(MeanB,MeanU,x,7,0,150);


%% For comparing reproducibility, smooth a bit more
for iS=1:x.nSubjects
    clear tNII
    xASL_TrackProgress(iS,x.nSubjects)
    tnII                 = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_1.nii']));
    IMutrech(iS,:,:,:)   = xASL_im_ndnanfilter(tnII,'gauss',[3.76 3.76 3.76]);

    clear tNII
    tnII                 = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_2.nii'])).*10;
    IMBerlin(iS,:,:,:)   = xASL_im_ndnanfilter(tnII,'gauss',[3.76 3.76 3.76]);
%     PrintCBF_BioCog(IMBerlin(iS,:,:,:),IMutrech(iS,:,:,:),x,iS,0,150,'grey');
end

%% Get bsCV
bsCVu           = xASL_stat_StdNan(IMutrech,[],1)./xASL_stat_MeanNan(IMutrech,1).*100;
bsCVb           = xASL_stat_StdNan(IMBerlin,[],1)./xASL_stat_MeanNan(IMBerlin,1).*100;
bsCVu(~logical(x.SteepSkullMap))   = NaN;
bsCVb(~logical(x.SteepSkullMap))   = NaN;
bsCVu           = xASL_im_ndnanfilter(bsCVu,'gauss',[1.885 1.885 1.885]);
bsCVb           = xASL_im_ndnanfilter(bsCVb,'gauss',[1.885 1.885 1.885]);
bsCVu           = xASL_im_ndnanfilter(bsCVu,'gauss',[1.885 1.885 1.885],2);
bsCVb           = xASL_im_ndnanfilter(bsCVb,'gauss',[1.885 1.885 1.885],2);
bsCVu(~logical(x.SteepSkullMap))   = NaN;
bsCVb(~logical(x.SteepSkullMap))   = NaN;

PrintCBF_BioCog(bsCVb,bsCVu,x,8,0,100);

AvBS            = (bsCVu+bsCVb)/2;

%% Get wsCV
diffIM          = IMutrech - IMBerlin;
MeanDiff        = squeeze(xASL_stat_MeanNan(diffIM,1));
SDdiff          = squeeze(xASL_stat_StdNan(diffIM,[],1));
MeanU           = squeeze(xASL_stat_MeanNan(IMutrech,1));
MeanB           = squeeze(xASL_stat_MeanNan(IMBerlin,1));
wsCV            = SDdiff./(0.5.*(MeanU+MeanB)).*100;
wsCV            = xASL_im_ndnanfilter(wsCV,'gauss',[1.885 1.885 1.885],0);
wsCV            = xASL_im_ndnanfilter(wsCV,'gauss',[1.885 1.885 1.885],2);

PrintCBF_BioCog(AvBS,wsCV,x,9,0,100);

PrintCBF_BioCog(wsCV./squeeze(AvBS),wsCV./squeeze(AvBS),x,5,0,2);

%% Volume of caudate nucleus:
MaskNucleus     = xASL_io_Nifti2Im('C:\ExploreASL\Maps\rMNI_structural_maps.nii');
MaskNucleus     = MaskNucleus(:,:,:,1)./100;
sum(MaskNucleus(:)).*1.5^3

10^3
