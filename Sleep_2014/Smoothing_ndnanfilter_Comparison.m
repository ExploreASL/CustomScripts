function xASL_wrp_spm_GLM( x, InputDataStr,AsymIndex)
%xASL_wrp_spm_GLM
% INPUT
% x = from ExploreASL
% masks   = physically loaded masks for each subject
% ASL     = the data to be analyzed. Could be ASL, or e.g. SD or SNR masks
%
%
% By HJMM Mutsaerts, ExploreASL 2016
%
% AsymIndex==1 -> Asymmetry Index
% AsymIndex==2 -> Average of left & right


%% ------------------------------------------------------------------------------
%% Admin
MaskPath    = fullfile(x.D.PopDir,'GMSliceMask.nii');
if  xASL_exist(MaskPath)
    x.S.VBAmask   = xASL_io_Nifti2Im(MaskPath);
end

if ~isfield(x.S,'VBAmask')  % Creation of mask, with attention to segmentation of thalamus & globus pallidus
    x.S.VBAmask       = logical(xASL_io_Nifti2Im(fullfile(x.D.TemplateDir,'Philips_2DEPI_Bsup_QC_mask.nii')) .* xASL_io_Nifti2Im(fullfile(x.D.TemplateDir,'rc1T1.nii'))>0.5);
end
if ~isfield(x,'LabEffNorm')
    x.LabEffNorm        = 0;
end

xASL_adm_CreateDir( x.StatsMaps);

if ~exist('AsymIndex','var')
    AsymIndex       = 0;
end
if ~isfield(x.S,'OutputID')
    x.S.OutputID    = InputDataStr;
end


%% ------------------------------------------------------------------------------
%% Smoothing
SmoothASL_LoadFile  = fullfile(x.D.PopDir,['Smooth' InputDataStr '.dat']);

if  exist(SmoothASL_LoadFile,'file') % load the already smoothed data
    try
        InputData       = memmapfile(SmoothASL_LoadFile,'Format',{'single' double([x.nSubjectsSessions sum(x.S.VBAmask(:))]) 'data'});
        x.S.DAT         = InputData.Data.data;
    catch % if not compressed yet
        InputData       = memmapfile(SmoothASL_LoadFile,'Format',{'single' double([x.nSubjectsSessions size(x.S.VBAmask)]) 'data'});
        for iS=1:x.nSubjectsSessions
            x.S.DAT(iS,:)   = xASL_im_IM2Column(squeeze(InputData.Data.data(iS,:,:,:)),x.S.VBAmask);
        end
    end


else % do memory mapping first
    LoadFile        = xASL_wrp_Load4DMemMapping( x, InputDataStr, 'Image');
    % Smoothing is performed spatially, so we need images instead of columns here
    InputData       = memmapfile(LoadFile,'Format',{'single' [x.nSubjectsSessions 121 145 121] 'data'});


    % Skip smoothing for 3D sequence:
    for iS=1:length(x.S.SetsName)
        if  strcmp(x.S.SetsName{iS},'Sequence')
            SeqID   = iS;
        end
    end

    fprintf('%s','Smoothing images for VBA...  ');
    for iSS=1:size(InputData.Data.data,1)
        xASL_TrackProgress(iSS,size(InputData.Data.data,1));
        clear tempASL bSmooth

        tempASL             = squeeze(InputData.Data.data(iSS,:,:,:));



        if  x.LabEffNorm % normalize labeling efficiency
            tempASL         = xASL_im_NormalizeLabelingTerritories( tempASL, x.S.VBAmask, x);
        end


        bSmooth     = 1; % default
        if isfield(x,'Vendor')
            if  strcmp(x.Vendor,'GE_product')
                % don't smooth, image is already smooth
                bSmooth     = 0;
            elseif exist('SeqID','var') % multi-sequence study that has a "sequence" variable
                   if  strcmp(x.S.SetsOptions{SeqID}{x.S.SetsID(iSS,SeqID)},'3D spiral')
                       % don't smooth, image is already smooth
                       bSmooth  = 0;
                   else
                       bSmooth  = 1;
                   end
            end
        end

        tempASL                 = x.S.VBAmask .* tempASL; % mask before smoothing
        tempASL(tempASL==0)     = NaN;

        if  bSmooth
			x.VoxelSize 		= 1.5;
            tempASL1            = xASL_im_ndnanfilter( tempASL ,'gauss', [3.76 3.76 3.76],1);
            tempASL2            = ndnanfilter(tempASL ,'GaussWinImage', [4 4 4],[],[],[],1);

            DiffIM              = tempASL1-tempASL2;
            MeanIM              = 0.5.*(tempASL1+tempASL2);
            RepIM               = DiffIM./MeanIM;
            figure(1);imshow(RepIM(:,:,53),[-0.1 0.1],'colormap',jet)


        elseif ~bSmooth
            % don't smooth
        else
            error('Invalid smooth option');
        end


        x.S.DAT(iSS,:)      = xASL_im_IM2Column(tempASL,x.S.VBAmask);
    end


    %% ------------------------------------------------------------------------------
    %% Create FoV probability map & remove voxels that don't contain valid data in >2.5% of population
    fprintf('%s\n','Create FoV probability map & remove voxels that don"t contain valid data in >0.025 of population');
    VBA_mask_File           = fullfile(x.D.PopDir,'VBA_mask_final.nii');

    NaNmap                  = single(isnan(x.S.DAT));
    MeanNanMap              = squeeze(mean(~NaNmap,1));

    % % Code that visualizes this "FoV probability map"
    % view_ASL = xASL_vis_TransformData2View( MeanNanMap, x );
    % jet_256=jet;
    % jet_256(1,:)    = 0;
    % figure(1);imshow(view_ASL.*241,[0.9 1].*241,'Colormap',jet_256);

    FoVFraction             = 0.975*mean(MeanNanMap(MeanNanMap~=0));
    RemoveVoxelsMask        = MeanNanMap<FoVFraction & MeanNanMap~=0;

    RemoveVoxelsMask        = repmat(RemoveVoxelsMask,size(x.S.DAT)./size(RemoveVoxelsMask) );
    x.S.DAT(RemoveVoxelsMask) = NaN;


    %% ------------------------------------------------------------------------------
    %% Interpolate the remaining missing data in the 4th dimension
    MeanCBFmap              = xASL_stat_MeanNan(x.S.DAT,1);
    MeanCBFmap              = repmat(MeanCBFmap,size(x.S.DAT)./size(MeanCBFmap));
    x.S.DAT(isnan(x.S.DAT)) = MeanCBFmap(isnan(x.S.DAT));

    MaskIM                  = squeeze(mean(x.S.DAT,1));
    MaskIM(isnan(MaskIM))   = 0;
    MaskIM                  = squeeze(logical(MaskIM));

    %% Save final VBA_mask
    xASL_io_SaveNifti( x.D.ResliceRef, VBA_mask_File, xASL_im_Column2IM(MaskIM,x.S.VBAmask) );





    %% ------------------------------------------------------------------------------
    %% Clip outliers
    x.S.DAT(x.S.DAT<=0)         = NaN; % set zeros to NaNs & clip negative values

% % % %     fprintf('%s\n','Clipping outliers in images ...  ');
% % % %     for iS=1:size(x.S.DAT,1)
% % % %         xASL_TrackProgress(iS,size(x.S.DAT,1));
% % % %         clear medianN madN tIM
% % % %         tIM         = x.S.DAT(iS,:,:,:);
% % % %         medianN     = xASL_stat_MedianNan(tIM(:));
% % % %         madN        = xASL_stat_MadNan(tIM(isfinite(tIM)),1);
% % % % %         piet(iS,1)  = sum(sum(sum(tIM>medianN+(12.5*madN))));
% % % % %         piet(iS,2)  = medianN+(12.5*madN);
% % % %         tIM(tIM>medianN+(12.5*madN))  = medianN+(12.5*madN);
% % % %         x.S.DAT(iS,:,:,:)             = tIM;
% % % %     end

    fileID = fopen(SmoothASL_LoadFile,'w');
    fwrite( fileID,x.S.DAT,'single');
    fclose(fileID);
end


%% ------------------------------------------------------------------------------
%% Calculate asymmetry index, if requested
if      AsymIndex>0
    for iS=1:size(x.S.DAT,1)
        clear tIM tIM_L tIM_R AI
        tIM                 = xASL_im_Column2IM(x.S.DAT(iS,:),x.S.VBAmask);

        % separate left & right part
        tIM_L               = tIM;
        tIM_R               = tIM;
        tIM_L( 1:61,:,:)    = NaN; % numel([62:121])=60
        tIM_R(61:end,:,:)   = NaN; % numel([1:60])  =60

        % flip right image
        tIM_R               = tIM_R(end:-1:1,:,:);

        if      AsymIndex==1
                % Create asymmetry index
                AI                  = 100.*(abs(tIM_L-tIM_R)./(0.5.*(tIM_L+tIM_R)));
%                 x.S.output_ID         = 'CBF_AI_notAbsolute';
                x.S.output_ID         = 'CBF_AI_Absolute';
        elseif  AsymIndex==2
                % Create average of left & right
                x.S.output_ID         = 'CBF_average';
                AI                  = 0.5.*(tIM_L+tIM_R);

        end
        x.S.DAT(iS,:)     = xASL_IM2Column(AI,x.S.VBAmask);
    end
end



%% Default parameters
x.LabEffNorm                  = 0;
x.S.PrintSPMOutput            = 1;
x.S.MultiComparisonCorrType   = 'cluster'; % OPTIONS uncorrected, FWE voxel-wise, cluster
x.S.uncorrThresh              = 0.05; % FWE threshold (clustersize in case of cluster correction)
x.S.clusterPthr               = 0.01; % cluster primary threshold

x.S.ConcatSliceDims           = 1; % 0 = vertical, 1 = horizontal
nIms                          = 10;
x.S.TraSlices                 = [30+([1:nIms+1]-1).*round((100-30)/nIms+1)]; % 30 - 100
x.S.CorSlices                 = [15+([1:nIms+1]-1).*round((130-15)/nIms+1)]; % 15 - 130
x.S.SagSlices                 = [15+([1:nIms+1]-1).*round((110-15)/nIms+1)]; % 15 - 110

x.S.NonSmoothNonMaskASL       = ASL_notScaled.Data.data;





%% ------------------------------------------------------------------------------
%% Initiation parameters for the GLM stats permutation over sets
x.S.StatsMaps         = fullfile( x.StatsMaps, x.S.OutputID);
x.S.oriDIR            = x.S.StatsMaps;
x.S.function2call     = @xASL_spm_GLM;
x.S.unit              = 'mL/100g/min';
fprintf('%s\n','Creating statistical maps');
x.S.KISS=0; % KISS=keep it stupid simple, this skips the 1-sample t-tests, ANOVAs & covariates

xASL_wrp_PermuteOverSets( x );


end
