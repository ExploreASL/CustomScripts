%% GENFI STATS SPM Dave Cash

%% Administration

if ~isfield(x.S,'GlobalNormalization')
    x.S.GlobalNormalization=0;
end

nSets               = length(x.S.DATASETS);
for ii=1:nSets
    nSubjects{ii}   = size(x.S.DATASETS{ii},1);
end

%% 1. Start running SPM
SPMmat          = fullfile(SPMdir, 'SPM.mat');
spm('defaults','PET');
% CopyFileList

xASL_adm_DeleteFileList(SPMdir,'spm(T|F)_\d{4}\.(nii|nii\.gz)$');
xASL_adm_DeleteFileList(SPMdir,'SPM\.mat$');

cd(SPMdir); % root dir with all niftis

MatDir{1}   = fullfile(SPMdir,'1_NoFamModel');
MatDir{2}   = fullfile(SPMdir,'2_FamModel');
MatDir{3}   = fullfile(SPMdir,'3_rndFamModel');

for ii=1:3
if  isdir( MatDir{ii} )
    xASL_adm_DeleteFileList(fullfile(MatDir{ii}),'SPM\.mat$');
    xASL_adm_DeleteFileList(fullfile(MatDir{ii}),'.*\.(nii|nii\.gz)$');
    rmdir(MatDir{ii});
    end
end

%% Find sets indices
clear nMutationStatus7 nFamily nSex nYrs_AAO nTimePoint
for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'MutationStatus7') & ~exist('nMutationStatus7','var')
            nMutationStatus7    = iS;
    elseif  strcmp(x.S.SetsName{iS},'MutationStatus7') &  exist('nMutationStatus7','var')
            error('Multiple sets MutationStatus7 found');
    end
end

if ~exist('nMutationStatus7','var')
    error('Set MutationStatus7 was not found');
end
for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'Family') & ~exist('nFamily','var')
            nFamily         = iS;
    elseif  strcmp(x.S.SetsName{iS},'Family') &  exist('nFamily','var')
            error('Multiple sets Family found');
    end
end
if ~exist('nFamily','var')
    error('Set Family was not found');
end

for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'sex') & ~exist('nSex','var')
            nSex         = iS;
    elseif  strcmp(x.S.SetsName{iS},'sex') &  exist('nSex','var')
            error('Multiple sets sex found');
    end
end
if ~exist('nSex','var')
    error('Set sex was not found');
end

for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'Yrs_AAO') & ~exist('nYrs_AAO','var')
            nYrs_AAO         = iS;
    elseif  strcmp(x.S.SetsName{iS},'Yrs_AAO') &  exist('nYrs_AAO','var')
            error('Multiple sets Yrs_AAO found');
    end
end
if ~exist('nYrs_AAO','var')
    error('Set Yrs_AAO was not found');
end

for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'LongitudinalTimePoint') & ~exist('nTimePoint','var')
            nTimePoint         = iS;
    elseif  strcmp(x.S.SetsName{iS},'LongitudinalTimePoint') &  exist('nTimePoint','var')
            error('Multiple sets TimePoint found');
    end
end
if ~exist('nTimePoint','var')
    error('Set TimePoint was not found');
end

% for iS=1:size(x.S.SetsID,1)
%     if      x.S.SetsID(iS,1)==1
%             x.S.SetsID(iS,1)=-1;
%     elseif  x.S.SetsID(iS,1)==2
%             x.S.SetsID(iS,1)= 1;
%     else
%             error('Wrong setting');
%     end
% end

% for iS=1:length(x.S.SetsName)
%     if      strcmp(x.S.SetsName{iS},'CBF_spatial_CoV') & ~exist('nCBF_spatial_CoV','var')
%             nCBF_spatial_CoV         = iS;
%     elseif  strcmp(x.S.SetsName{iS},'CBF_spatial_CoV') &  exist('nCBF_spatial_CoV','var')
%             error('Multiple sets CBF_spatial_CoV found');
%     end
% end
% if ~exist('nCBF_spatial_CoV','var')
%     error('Set CBF_spatial_CoV was not found');
% end
%
% Yrs=x.S.SetsID(:,nYrs_AAO);
% Yrs(Yrs==9999)=mean(Yrs(Yrs~=9999));
% x.S.SetsID(:,nYrs_AAO)=Yrs;

%% 1) Design NoFamModel (1) & (2)

for ii=1:2

    % Create separate directories to store each SPM.mat
    xASL_adm_CreateDir(MatDir{ii});

    clear matlabbatch

        % Subjects
    for iSet=1:nSets
        scans{iSet}                                                     = sort(xASL_adm_GetImageList3D( SPMdir, ['^Set' num2str(iSet) 'subject\d*\.(nii|nii\.gz)$']));
    end

    matlabbatch{1}.spm.stats.factorial_design.dir   = {SPMdir};

    x.S.RegressionCOVAR=0;
    printTitleORI   = 'GENFI_check';

    % fblock = flexible factorial
    % fac = factor

    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name    = x.S.SetsName{nMutationStatus7}; % MutationStatus7
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept    = 0; % independence
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance= 0; % unequal variance
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca   = 0; % grand mean scaling
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova  = 0; %
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum     = 1;

    if  ii==2
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name    = x.S.SetsName{nFamily}; % Family
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept    = 0; % independence
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance= 0; % unequal variance
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca   = 0; % grand mean scaling
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova  = 0; %
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum     = 2;
    end

    % f sub all = factor subjects or all scans/factors
    % spec all  = specify all
    % -> with specify all, put scans under scans & a factor matrix with all
    % conditions under imatrix (so not inverse matrix but matrix "I")
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans      = scans{1};

    if      ii==1 % MutationStatus7
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix    = double([ones(length(x.S.CoVar(:,nMutationStatus7)),1) x.S.CoVar(:,nMutationStatus7) ones(length(x.S.CoVar(:,nMutationStatus7)),1)  ones(length(x.S.CoVar(:,nMutationStatus7)),1)]);
    elseif ii==2
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix    = double([ones(length(x.S.CoVar(:,nFamily)),1)          x.S.CoVar(:,nMutationStatus7)          x.S.CoVar(:,nFamily)                  ones(length(x.S.CoVar(:,nFamily)),1)]);
    end


    % maininters = main effects & interactions
    % fmain = main factor/effect
    % fnum  = factor number


    % matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1,2}.fmain.fnum=2;

    % cov = covariants
    % -> TimePoint interacts with MutationStatus (asking whether the
    % perfusion difference between TimePoints is larger for presymp than
    % non-carriers) with Yrs_AAO as fixed covariate
    matlabbatch{1}.spm.stats.factorial_design.cov(1).c              = double(x.S.CoVar(:,nSex)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(1).cname          = x.S.SetsName{nSex}; % sex
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI           = 1; % 1==no interactions
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC            = 1; % 5==no mean centering

    matlabbatch{1}.spm.stats.factorial_design.cov(2).c              = double(x.S.CoVar(:,nTimePoint)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(2).cname          = 'TimePoint';
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI           = 2; % 1==no interactions, 2 = with factor 1
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC            = 1; % 5==no mean centering

    matlabbatch{1}.spm.stats.factorial_design.cov(3).c              = double(x.S.CoVar(:,nYrs_AAO)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(3).cname          = x.S.SetsName{nYrs_AAO}; % Yrs_AAO
    matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI           = 1; % 1==no interactions, 2 = with factor 1
    matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC            = 1; % 5==no mean centering

%     matlabbatch{1}.spm.stats.factorial_design.cov(3).c              = double(x.S.CoVar(:,nCBF_spatial_CoV)); % vector data
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).cname          = x.S.SetsName{nCBF_spatial_CoV}; % nCBF_spatial_CoV
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI           = 1; % 1==no interactions, 2 = with factor 1
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC            = 1; % 5==no mean centering
%
    matlabbatch{1}.spm.stats.factorial_design.multi_cov             = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none    = 1; % threshold masking
    matlabbatch{1}.spm.stats.factorial_design.masking.im            = 0; % implicit masking doesn't always work, can crash
    matlabbatch{1}.spm.stats.factorial_design.masking.em            = { fullfile(x.D.PopDir,'VBA_mask_final.nii') }; % explicit masking always works
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no= 1; % no grand mean scaling

    if  x.S.GlobalNormalization==1
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_mean        = 1; % calculate mean
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm       = 2; % normalize each image (proportional)
    else
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit        = 1; % don't calculate mean
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm       = 1; % no global normalization
    end

    spm_jobman('run',matlabbatch);

    % Move SPM.mat to separate directory
    xASL_Move( fullfile(SPMdir,'SPM.mat'),fullfile(MatDir{ii},'SPM.mat'));

end

%% Copy paste from AddFamRndmEffect.m

indir   = MatDir{1};
famdir  = MatDir{2};
N       = length(scans{1});

load( fullfile(indir,'SPM.mat')); % load(strcat(indir,'/SPM')); % this loads first SPM.mat
fam         = load( fullfile(famdir,'SPM.mat'));  % fam=load(strcat(famdir,'/SPM')); % this loads second SPM.mat
xASL_adm_CreateDir(MatDir{3}); % if exist(rnddir,'dir')==0;mkdir(rnddir);end

clear FoundStr
Next    = 1;
for iFam=1:length(fam.SPM.xX.name)
    if  ~isempty(findstr(fam.SPM.xX.name{iFam},'Family'))
        FoundStr(Next,1)    = iFam;
        Next                = Next+1;
    end
end

Xfam=double(fam.SPM.xX.X(:,min(FoundStr):max(FoundStr))); % this needs column adjustment, depending on imatrix above
Vfam=Xfam*Xfam';
size(Xfam);
rank(Xfam);
SPM.xVi= rmfield(SPM.xVi, 'V'); % Why do we remove field "V" but replace it with field "Vi" here?
SPM.xVi.Vi=cell(2,1);
SPM.xVi.Vi{1}=speye(double(N));
SPM.xVi.Vi{2}=sparse(double(Vfam)); % this needed conversion to double
SPM.xVi.Vi{1};
SPM.xVi.Vi{2};
save( fullfile(MatDir{3},'SPM.mat'),'SPM'); % save(strcat(rnddir,'/SPM.mat'),'SPM');

%% 1 Review model
if  x.S.PrintSPMOutput
    try
        clear matlabbatch
        matlabbatch{1}.spm.stats.review.spmmat              = { fullfile(MatDir{3},'SPM.mat') };
        matlabbatch{1}.spm.stats.review.display.matrix      = 1;
        matlabbatch{1}.spm.stats.review.print               = 'pdf';
        spm_jobman('run',matlabbatch);
        close
    end
else
    % Skip review
end


%% 2 Estimate model

try % This part crashes if the implicitly created mask contains no voxels
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_est.spmmat            = { fullfile(MatDir{3},'SPM.mat') };
    matlabbatch{1}.spm.stats.fmri_est.write_residuals   = 0; % don't write residual maps
    matlabbatch{1}.spm.stats.fmri_est.method.Classical  = 1; % restrict maximum likelihood
    spm_jobman('run',matlabbatch);
    InMask=1;

    % Get cluster extent (crashes if no inmask voxels)
    if      strcmp(x.S.MultiComparisonCorrType,'FWE') || strcmp(x.S.MultiComparisonCorrType,'uncorrected')
            ClusterExtent   = 0;
    elseif  strcmp(x.S.MultiComparisonCorrType,'cluster')
            load(fullfile(MatDir{3},'SPM.mat'));
            [k,Pc] = CorrClusTh(SPM,S.clusterPthr,S.uncorrThresh,1:50000);
            ClusterExtent   = k;
    end

catch % if no inmask voxels, just use the background only
    InMask          = 0;
    ClusterExtent   = 0;
    k               = 0;

    dummyVar        = '';
    DummyWarnFile   = fullfile( x.S.StatsDir, 'EmptyMasksWarning.mat');
    save( DummyWarnFile, 'dummyVar');
end



%% 3    Contrast creation

    for ii=1:3
        tFile1{ii}      = fullfile(MatDir{3},['spmT_000' num2str(ii) '.nii']);
        tFile2{ii}      = fullfile(   SPMdir,['spmT_000' num2str(ii) '.nii']);
    end

    spmFile1    = fullfile(MatDir{3},'SPM.mat');
    spmFile2    = fullfile(   SPMdir,'SPM.mat');

    if  exist(spmFile2,'file') & ~exist(spmFile1,'file')
        xASL_Move (spmFile2, spmFile1);
    end

    % Get type of multiple comparison correction
    if      strcmp(x.S.MultiComparisonCorrType,'FWE')
            ThreshType      = 'FWE';
            PrintTitleStats = ['p=' num2str(x.S.uncorrThresh) ', Bonferroni FWE'];

    elseif  strcmp(x.S.MultiComparisonCorrType,'cluster')
            ThreshType      = 'none';
            PrintTitleStats = ['primThr p=' num2str(x.S.clusterPthr) ', cluster FWE p=' num2str(x.S.uncorrThresh) ', clustersize ' num2str(k) ' voxels'];

    elseif  strcmp(x.S.MultiComparisonCorrType,'uncorrected')
            ThreshType      = 'none';
            PrintTitleStats = ['p=' num2str(x.S.uncorrThresh) ', unc.'];
    end

    if ~exist(fullfile(MatDir{3},'SPM.mat')) && exist(fullfile(SPMdir,'SPM.mat'))
        xASL_Move (fullfile(SPMdir,'SPM.mat'),fullfile(MatDir{3},'SPM.mat'));
    end

    clear matlabbatch
    matlabbatch{1}.spm.stats.con.spmmat                             = { fullfile(MatDir{3},'SPM.mat') };
    matlabbatch{1}.spm.stats.con.delete                             = 0;

    for ii=1:3
        matlabbatch{1}.spm.stats.con.consess{ii}.tcon.weights       = zeros(1,16);
        matlabbatch{1}.spm.stats.con.consess{ii}.tcon.sessrep       = 'none';
    end



    % For non-carriers, difference between TimePoints
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name               = 'TP_non-carriers';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights(9)         =  1;
%
    % For presympt carriers, difference between TimePoints
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name               = 'TP_presympt';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights(10:12)     = 1;

    % interaction TP & MutationStatus (decrease with TP larger in
    % presympt?)
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.name               = 'TP_pre_vs_nc';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights(9)         = -1;
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights(10:12)     =  1;


    spm_jobman('run',matlabbatch);

    for ii=1:3
        if  exist(tFile1{ii},'file') & ~exist(tFile2{ii},'file')
            xASL_Move (tFile1{ii}, tFile2{ii});
        end
    end
    if  exist(spmFile1,'file') & ~exist(spmFile2,'file')
        xASL_Move (spmFile1, spmFile2);
    end

    %% 4 Load contrast & make absolute (+ve)
    for ii=1:3
        ContrastMapFile     = fullfile( SPMdir, ['spmT_000' num2str(ii) '.nii']);

        ContrastMap         = xASL_nifti( ContrastMapFile );
        ContrastMap         = ContrastMap.dat(:,:,:);
        % Save contrast map for later
        diff_view_mean{1}   = ContrastMap; % abs T-stat map
        ContrastMap         = abs(ContrastMap);
        xASL_io_SaveNifti( ContrastMapFile, ContrastMapFile, ContrastMap );
        clear ContrastMap ContrastMapFile
    end

     %% 4    Create masks

    clear matlabbatch

    matlabbatch{1}.spm.stats.results.spmmat             = { SPMmat };
    matlabbatch{1}.spm.stats.results.conspec.titlestr   = '';
    matlabbatch{1}.spm.stats.results.conspec.contrasts  = Inf; % use all existing contrasts
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = ThreshType; % 'FWE'; % family-wise error

    if  strcmp(x.S.MultiComparisonCorrType,'cluster')
        matlabbatch{1}.spm.stats.results.conspec.thresh = x.S.clusterPthr;  % height threshold
    else
        matlabbatch{1}.spm.stats.results.conspec.thresh = x.S.uncorrThresh; % height threshold
    end

    matlabbatch{1}.spm.stats.results.conspec.extent     = ClusterExtent;  % width threshold (k)
    matlabbatch{1}.spm.stats.results.conspec.mask.none  = 1; % masking is already done
    matlabbatch{1}.spm.stats.results.units              = 1;

    if  x.S.PrintSPMOutput
        matlabbatch{1}.spm.stats.results.print          = 'pdf';
    else
        matlabbatch{1}.spm.stats.results.print          = 0;
    end

    matlabbatch{1}.spm.stats.results.write.tspm.basename = 'Masked'; % save masked t-stats
    spm_jobman('run',matlabbatch);
    close all
