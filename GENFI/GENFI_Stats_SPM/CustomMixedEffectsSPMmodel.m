%% Repeat this for different thresholds

OUTPUTdir   = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_AI_Absolute\permute_LongitudinalTimePoint\N2_N8_Covar_spatialCoV';
xASL_adm_CreateDir(OUTPUTdir);
PrThr       = [0.001 0.005 0.01 0.001 0.005 0.01]; % define thresholds
UnThr       = [0.05  0.05  0.05 0.1   0.1   0.1];

for iThr=1:length(PrThr)
    % Select thresholds
    x.S.clusterPthr   = PrThr(iThr);
    x.S.uncorrThresh  = UnThr(iThr);
    Out2Dir         = fullfile(OUTPUTdir,[num2str(x.S.clusterPthr) '_' num2str(x.S.uncorrThresh)]);
    xASL_adm_CreateDir(Out2Dir);


    %% GENFI STATS SPM

    MaskName    = fullfile(x.D.PopDir,'VBA_mask_final.nii');
    MaskName    = fullfile(x.D.PopDir,'VBA_AI_mask.nii');

    %% Administration
    clear nSubjects nSets scans

    if ~isfield(x.S,'GlobalNormalization')
        x.S.GlobalNormalization=0;
    end

    nSets               = length(x.S.DATASETS);
    for ii=1:nSets
        nSubjects{ii}   = size(x.S.DATASETS{ii},1);
    end

    TotalSubjects       = 0;
    for ii=1:nSets
        TotalSubjects       = TotalSubjects+nSubjects{ii};
    end

    if ~isfield(x.S,'CoVar')
        x.S.CoVar     = x.S.SetsID;
    %     if  size(x.S.CoVar,1)<TotalSubjects
    %         % if dataset has been subdivided, do this with subjects for x.S.iCurrentSet
    %         RESTR                 = restructure_populations( x.S.CoVar, x.S.SetsID(:,1) );
    %         x.S.CoVar               = RESTR{1};
    %     end
    end

    %% 1. Start running SPM
    SPMmat          = fullfile(SPMdir, 'SPM.mat');
    spm('defaults','PET');
    % CopyFileList

    xASL_adm_DeleteFileList(SPMdir,'^spm(T|F)_\d{4}\.(nii|nii\.gz)$');
    xASL_adm_DeleteFileList(SPMdir,'^SPM\.mat$');
    xASL_adm_DeleteFileList(SPMdir,'^spm.*\.pdf$');
    xASL_adm_DeleteFileList(SPMdir,'^spmT.*Masked\.(nii|nii\.gz)$');

    cd(SPMdir); % root dir with all niftis

    MatDir{1}   = fullfile(SPMdir,'1_NoFamModel');
    MatDir{2}   = fullfile(SPMdir,'3_rndFamModel'); % rnddir=regexprep(indir,'fSite','fSite_rndFamily');

    for ii=1:2
        if  isdir( MatDir{ii} )
            xASL_adm_DeleteFileList(fullfile(MatDir{ii}),'SPM\.mat$');
            xASL_adm_DeleteFileList(fullfile(MatDir{ii}),'.*\.(nii|nii\.gz)$');
            rmdir(MatDir{ii});
        end
    end

    %% Find sets indices
    SetsNames   = {'GM_ICVRatio' 'MutationStatus7' 'Family' 'sex' 'Yrs_AAO' 'age' 'Site' 'CBF_spatial_CoV'};

    for iSetN=1:length(SetsNames)
        eval(['clear ' SetsNames{iSetN} ' n' SetsNames{iSetN}]);

        for iS=1:length(x.S.SetsName)
            if      strcmp(x.S.SetsName{iS},SetsNames{iSetN}) && ~exist(['n' SetsNames{iSetN}],'var')
                    eval(['n' SetsNames{iSetN} ' = iS;'])
            elseif  strcmp(x.S.SetsName{iS},SetsNames{iSetN}) &&  exist(['n' SetsNames{iSetN}],'var')
                    error(['Multiple sets ' SetsNames{iSetN} ' were found']);
            end
        end

        if ~exist(['n' SetsNames{iSetN}],'var')
            error(['Set ' SetsNames{iSetN} ' was not found']);
        end
    end


    %% 1) Design SPM

    % Create separate directories to store each SPM.mat
    for ii=1:2
        xASL_adm_CreateDir(MatDir{ii});
    end

    clear matlabbatch

        % Subjects
    for iSet=1:nSets
        scans{iSet}                                                     = sort(xASL_adm_GetImageList3D( SPMdir, ['^Set' num2str(iSet) 'subject\d*\.(nii|nii\.gz)$']));
    end

    matlabbatch{1}.spm.stats.factorial_design.dir                       = {SPMdir};

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

    % f sub all = factor subjects or all scans/factors
    % spec all  = specify all
    % -> with specify all, put scans under scans & a factor matrix with all
    % conditions under imatrix (so not inverse matrix but matrix "I")
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans      = scans{1};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix    = double([ones(length(x.S.CoVar(:,nMutationStatus7)),1) x.S.CoVar(:,nMutationStatus7) ones(length(x.S.CoVar(:,nMutationStatus7)),1)  ones(length(x.S.CoVar(:,nMutationStatus7)),1)]);

    % maininters = main effects & interactions
    % fmain = main factor/effect
    % fnum  = factor number


    % matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1,2}.fmain.fnum=2;

    % cov = covariants
    % sex
    matlabbatch{1}.spm.stats.factorial_design.cov(1).c              = double(x.S.CoVar(:,nsex)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(1).cname          = x.S.SetsName{nsex}; % sex
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI           = 1; % 1==no interactions
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC            = 1; % 5==no mean centering
    % % Yrs_AAO
    matlabbatch{1}.spm.stats.factorial_design.cov(2).c              = double(x.S.CoVar(:,nYrs_AAO)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(2).cname          = x.S.SetsName{nYrs_AAO}; % Yrs_AAO
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI           = 2; % 1==no interactions, 2 = with factor 1
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC            = 1; % 5==no mean centering
    % age
    % matlabbatch{1}.spm.stats.factorial_design.cov(2).c              = double(x.S.CoVar(:,nage)); % vector data
    % matlabbatch{1}.spm.stats.factorial_design.cov(2).cname          = x.S.SetsName{nage}; % Yrs_AAO
    % matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI           = 2; % 1==no interactions, 2 = with factor 1
    % matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC            = 1; % 5==no mean centering
    % % Atrophy
    % PositionI       = size(matlabbatch{1}.spm.stats.factorial_design.cov,2)+1;
    % matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).c              = double(x.S.CoVar(:,nGM_ICVRatio)); % vector data
    % matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).cname          = x.S.SetsName{nGM_ICVRatio}; % GM_ICVRatio
    % matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).iCFI           = 1; % 1==no interactions, 2 = with factor 1
    % matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).iCC            = 1; % 5==no mean centering

    PositionI       = size(matlabbatch{1}.spm.stats.factorial_design.cov,2)+1;
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).c              = double(x.S.CoVar(:,nCBF_spatial_CoV)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).cname          = x.S.SetsName{nCBF_spatial_CoV}; % nCBF_spatial_CoV
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).iCFI           = 1; % 1==no interactions, 2 = with factor 1
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).iCC            = 1; % 5==no mean centering

    PositionI       = size(matlabbatch{1}.spm.stats.factorial_design.cov,2)+1;
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).c              = double(x.S.CoVar(:,nSite)); % vector data
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).cname          = x.S.SetsName{nSite}; % Site
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).iCFI           = 1; % 1==no interactions, 2 = with factor 1
    matlabbatch{1}.spm.stats.factorial_design.cov(PositionI).iCC            = 1; % 5==no mean centering

    matlabbatch{1}.spm.stats.factorial_design.multi_cov             = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none    = 1; % threshold masking
    matlabbatch{1}.spm.stats.factorial_design.masking.im            = 0; % implicit masking doesn't always work, can crash
    matlabbatch{1}.spm.stats.factorial_design.masking.em            = { MaskName }; % explicit masking always works
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
    xASL_Move( fullfile(SPMdir,'SPM.mat'),fullfile(MatDir{1},'SPM.mat'));


    %% Copy paste from AddFamRndmEffect.m

    indir   = MatDir{1};
    N       = length(scans{1});

    load( fullfile(indir,'SPM.mat'));

    % SPM.xX.X contains design matrix, without/with family for matrix1&matrix2
    % here only the original SPM design is used, and SPM.xVI gets addition of
    % the random factor. here we add factors, first is diagonal only (eye) for
    % MutationStatus7 (which is fixed)
    % Second is sparse matrix of Family
    % Third is sparse matrix of Subject

    % Create random factor Family
    U   =   unique(x.S.CoVar(:,nFamily));
    for iI=1:length(U)
        Xfam(:,iI)     = x.S.CoVar(:,nFamily)==U(iI);
    end
    Vfam=double(Xfam)*double(Xfam)';

    % % Create random factor Site
    % U   =   unique(x.S.CoVar(:,nSite));
    % for iI=1:length(U)
    %     Xsite(:,iI)     = x.S.CoVar(:,nSite)==U(iI);
    % %     Xsite2(:,iI)     = (x.S.CoVar(:,nSite)==U(iI)).*iI; image
    % end
    % Vsite=double(Xsite)*double(Xsite)';
    % % Vsite2=double(Xsite2)*double(Xsite2)'; image

    % Create random factor Subject
    IndexN              = 1;
    SubjectList         = zeros(x.nSubjects,1);
    for iS=1:x.nSubjects
        clear IsVolume VolumeList VolumeN IndicesAre
        [ IsVolume VolumeList VolumeN ] = LongRegInit( x, x.SUBJECTS{iS} );
        IndicesAre                  = find(VolumeList(:,2)~=0);
        if  sum(SubjectList(IndicesAre,1))==0 % skips processed subjects
            SubjectList(IndicesAre,1)   = IndexN;
            IndexN                      = IndexN+1;
        end
    end

    if  size(x.S.CoVar,1)<x.nSubjects
        % if dataset has been subdivided, do this with subjects for x.S.iCurrentSet
        SubjectList_RESTR               = restructure_populations( SubjectList, x.S.SetsID(:,S.iCurrentSet) );
        SubjectList                     = SubjectList_RESTR{1};
    end

    U   =   unique(SubjectList);
    for iI=1:length(U)
        Xsub(:,iI)     = SubjectList==U(iI);
    end
    Vsub=double(Xsub)*double(Xsub)';

    % Insert factors in SPM.xVi
    SPM.xVi     = rmfield(SPM.xVi, 'V'); % Here we remove a default identity covariance matrix
    SPM.xVi.Vi{1}=speye(double(N));
    % when including site, this is higher in the tree than family
    % SPM.xVi.Vi{2}=sparse(double(Vsite));
    SPM.xVi.Vi{size(SPM.xVi.Vi,2)+1}=sparse(double(Vfam));

    if  size(x.S.CoVar,1)<x.nSubjects
        % don't include subject
    else
        SPM.xVi.Vi{size(SPM.xVi.Vi,2)+1}=sparse(double(Vsub));
    end
    save( fullfile(MatDir{2},'SPM.mat'),'SPM');



    %% 1 Review model
    if  x.S.PrintSPMOutput
        clear matlabbatch
        matlabbatch{1}.spm.stats.review.spmmat              = { fullfile(MatDir{2},'SPM.mat') };
        matlabbatch{1}.spm.stats.review.display.matrix      = 1;
        matlabbatch{1}.spm.stats.review.print               = 'pdf';
        spm_jobman('run',matlabbatch);
        close
    end

    %% 2 Estimate model
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_est.spmmat            = { fullfile(MatDir{2},'SPM.mat') };
    matlabbatch{1}.spm.stats.fmri_est.write_residuals   = 0; % don't write residual maps
    matlabbatch{1}.spm.stats.fmri_est.method.Classical  = 1; % restrict maximum likelihood

    tic
    spm_jobman('run',matlabbatch);
    toc
    % Get cluster extent (crashes if no inmask voxels)
    if      strcmp(x.S.MultiComparisonCorrType,'FWE') || strcmp(x.S.MultiComparisonCorrType,'uncorrected')
            ClusterExtent   = 0;
    elseif  strcmp(x.S.MultiComparisonCorrType,'cluster')
            load(fullfile(MatDir{2},'SPM.mat'));
            [k,Pc] = CorrClusTh(SPM,S.clusterPthr,S.uncorrThresh,1:50000);
            ClusterExtent   = k;
    end

    %% 3    Contrast creation
        for ii=1:4
            tFile1{ii}      = fullfile(MatDir{2},['spmT_000' num2str(ii) '.nii']);
            tFile2{ii}      = fullfile(   SPMdir,['spmT_000' num2str(ii) '.nii']);
        end

        spmFile1    = fullfile(MatDir{2},'SPM.mat');
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

        if ~exist(fullfile(MatDir{2},'SPM.mat')) && exist(fullfile(SPMdir,'SPM.mat'))
            xASL_Move (fullfile(SPMdir,'SPM.mat'),fullfile(MatDir{2},'SPM.mat'));
        end

        clear matlabbatch
        matlabbatch{1}.spm.stats.con.spmmat                             = { fullfile(MatDir{2},'SPM.mat') };
        matlabbatch{1}.spm.stats.con.delete                             = 0;

        for ii=1:4
            matlabbatch{1}.spm.stats.con.consess{ii}.tcon.weights       = zeros(1,size(SPM.xX.X,2));
            matlabbatch{1}.spm.stats.con.consess{ii}.tcon.sessrep       = 'none';
        end


    %     % interaction Yrs_AAO for sympt mutation carriers C9ORF vs GRN
    %     matlabbatch{1}.spm.stats.con.consess{1}.tcon.name               = 'C9ORF_GRN';
    %     matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights(10)        = -1;
    %     matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights(11)        =  1;
    %
    %     % interaction Yrs_AAO for sympt mutation carriers C9ORF vs MAPT
    %     matlabbatch{1}.spm.stats.con.consess{2}.tcon.name               = 'C9ORF_MAPT';
    %     matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights(10)        = -1;
    %     matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights(12)        =  1;
    %
    %     % interaction Yrs_AAO for sympt mutation carriers GRN vs MAPT
    %     matlabbatch{1}.spm.stats.con.consess{3}.tcon.name               = 'GRN_MAPT';
    %     matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights(11)        = -1;
    %     matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights(12)        =  1;
    %
        % interaction Yrs_AAO for asympt mutation carriers vs. no-carriers
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name               = 'Yrs_Interact_all';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights(9)         = -1;
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights(10:12)     =  1/3;
    %
        % interaction Yrs_AAO for C9ORF72 vs. no-carriers
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name               = 'Yrs_Interact_C9ORF';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights(9)         = -1;
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights(10)        =  1;

        % interaction Yrs_AAO for GRN vs. no-carriers
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name               = 'Yrs_Interact_GRN';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights(9)         = -1;
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights(11)        =  1;

        % interaction Yrs_AAO for MAPT vs. no-carriers
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name               = 'Yrs_Interact_MAPT';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights(9)         = -1;
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights(12)        =  1;

        spm_jobman('run',matlabbatch);

        for ii=1:4
            if  exist(tFile1{ii},'file') & ~exist(tFile2{ii},'file')
                xASL_Move (tFile1{ii}, tFile2{ii});
            end
        end
        if  exist(spmFile1,'file') & ~exist(spmFile2,'file')
            xASL_Move (spmFile1, spmFile2);
        end

        %% 4 Load contrast & make absolute (+ve)
        for ii=1:4
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


        %% Get Results
        if  nSets>2
            ContrastMap         = xASL_nifti( fullfile( SPMdir, 'spmF_0001.nii') );
            MaskMap             = xASL_nifti( fullfile( SPMdir, 'spmF_0001_Masked.nii') );
        else
            ContrastMap         = xASL_nifti( fullfile( SPMdir, 'spmT_0001.nii') );
            MaskMap             = xASL_nifti( fullfile( SPMdir, 'spmT_0001_Masked.nii') );
        end

        ContrastMap             = ContrastMap.dat(:,:,:);
        MaskMap                 = MaskMap.dat(:,:,:);

        if  x.S.GlobalNormalization==1
            printTitleORI      = [printTitleORI ', ScaleGlblMean'];
        end
    %
        %% GENFI combine clusters
    %     % Print overview clusters (MaskMap)
    %     PRINT_MAPS_LABEL_statistics(MaskMap,x,printTitleORI);
    %     ClusterFile             = fullfile(x.S.StatsDir,['Clusters_' printTitleORI '.nii']);
    %     ClusterIM               = xASL_nifti(ClusterFile);
    %     ClusterIM               = ClusterIM.dat(:,:,:);
    %
    % % %     %     p0.001, p0.05FWE, adjust spatial CoV
    % %     % Merge clusters 2 3 4, 5 6 7, 9 10 11
    % %     ClusterIM(ClusterIM== 3) =  2;
    % %     ClusterIM(ClusterIM== 4) =  2;
    % %     ClusterIM(ClusterIM== 6) =  5;
    % %     ClusterIM(ClusterIM== 7) =  5;
    % %     ClusterIM(ClusterIM==10) =  9;
    % %     ClusterIM(ClusterIM==11) =  9;
    % % %
    % %     % Re-order
    % %     ClusterIM(ClusterIM== 5) =  3;
    % %     ClusterIM(ClusterIM== 8) =  4;
    % %     ClusterIM(ClusterIM== 9) =  5;
    %
    %     %     p0.001, p0.05FWE, adjust spatial CoV & site
    %     % Merge clusters 2 3 4, 7 8, 9 10
    %     ClusterIM(ClusterIM== 3) =  2;
    %     ClusterIM(ClusterIM== 4) =  2;
    %     ClusterIM(ClusterIM== 8) =  7;
    %     ClusterIM(ClusterIM==10) =  9;
    % %
    %     % Re-order
    %     ClusterIM(ClusterIM== 5) =  3;
    %     ClusterIM(ClusterIM== 6) =  4;
    %     ClusterIM(ClusterIM== 7) =  5;
    %     ClusterIM(ClusterIM== 9) =  6;
    %
    %     % Later by Arron, add cluster 3 to 2
    %     ClusterIM(ClusterIM== 3) =  2;
    %
    %     % Re-order
    %     ClusterIM(ClusterIM== 4) =  3;
    %     ClusterIM(ClusterIM== 5) =  4;
    %     ClusterIM(ClusterIM== 6) =  5;
    %
    %
    %     xASL_io_SaveNifti(ClusterFile,ClusterFile,ClusterIM);
    %
    %     x.S.SPMdir        = SPMdir;
    %     PRINT_ROI_CBF_FROM_MAPS_ROI(x,printTitleORI);

    % Copy the output
    PDFlist     = xASL_adm_GetFileList(SPMdir,'^spm.*\.pdf$');
    for iP=2:length(PDFlist)
        clear Fpath Ffile Fext
        [Fpath Ffile Fext]  = fileparts(PDFlist{iP});
        xASL_Move(PDFlist{iP},fullfile(Out2Dir,[Ffile Fext]));
    end
end
