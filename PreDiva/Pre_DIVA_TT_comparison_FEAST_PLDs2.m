% Manual include spatial processing turbo_QUASAR in pipeline

% 0) check M0 raw non-destr registered to MNI
% Check, registration M0->MNI (rgrey.nii) & M0->individual c1T1 is OK

% 1) copy TT & raw to ASL_1 dir
clear all
ROOT{1}    = 'E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison1000\analysis';
ROOT{2}    = 'E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison1500\analysis';
ROOT{3}    = 'E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison2000\analysis';
dlist       = xASL_adm_GetFsList(ROOT{1}, '^\d{6}$', 1);

%% Visualization (GM segmentation is same for all PLDs)

    MapsDir     = 'C:\ASL_pipeline_HJ\Maps';

    meanGM      = fullfile(ROOT{1}, 'dartel', 'DARTEL_T1_template.nii');
    brainmask   = fullfile(MapsDir, 'rbrainmask.nii');
    meanGM      = xASL_io_ReadNifti(meanGM);
    brainmask   = xASL_io_ReadNifti(brainmask);
    meanGM      = single(meanGM.dat(:,:,:));
    brainmask   = single(brainmask.dat(:,:,:) );

    A_L         = fullfile( MapsDir, 'r_vasc_ant_L.nii');
    A_R         = fullfile( MapsDir, 'r_vasc_ant_R.nii');
    M_L         = fullfile( MapsDir, 'r_vasc_mid_L.nii');
    M_R         = fullfile( MapsDir, 'r_vasc_mid_R.nii');
    P_L         = fullfile( MapsDir, 'r_vasc_pos_L.nii');
    P_R         = fullfile( MapsDir, 'r_vasc_pos_R.nii');
    A_L         = xASL_io_ReadNifti(A_L);
    A_R         = xASL_io_ReadNifti(A_R);
    M_L         = xASL_io_ReadNifti(M_L);
    M_R         = xASL_io_ReadNifti(M_R);
    P_L         = xASL_io_ReadNifti(P_L);
    P_R         = xASL_io_ReadNifti(P_R);
    A_L         = single( A_L.dat(:,:,:) );
    A_R         = single( A_R.dat(:,:,:) );
    M_L         = single( M_L.dat(:,:,:) );
    M_R         = single( M_R.dat(:,:,:) );
    P_L         = single( P_L.dat(:,:,:) );
    P_R         = single( P_R.dat(:,:,:) );

    A           = A_L+A_R;
    M           = M_L+M_R;
    P           = P_L+P_R;

    for iSlice=1:size(meanGM,3)
        GMmask(:,:,iSlice)  = meanGM(:,:,iSlice)>0.5.* max(max(max(meanGM(:,:,iSlice) )) );
    end

    GMmask          = GMmask.*single(brainmask>0.85);

    GMmask          = (A+M+P).*GMmask;
    GMmask(:,:,104:end)     = 0;
    GMmask          = logical(GMmask);

    A               = A.*GMmask;
    M               = M.*GMmask;
    P               = P.*GMmask;

    % Visualize mean & SD TT maps for both techniques
    pos_size        =size(GMmask,2);
    R_size          =size(GMmask,1);
    inf_size        =size(GMmask,2);

    ant_crop         = 9  -5;
    pos_crop         = 9  -5;
    sup_crop         =-3  -5;
    inf_crop         =21  -5;
    L_crop           =13  -5;
    R_crop           =13  -5;

    pos_crop_final  =pos_size-pos_crop;
    R_crop_final    =R_size-R_crop;
    inf_crop_final  =inf_size-inf_crop;

    jet255          = jet(256);
    jet255(1,:)     = 0;




%% Create single mean & SD ATT maps

for iRoot=1:3
    clear TotalNii MeanNii SDNii CVnii

    for iList=1:length(dlist)
        tnii                    = xASL_io_ReadNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']) );
        TotalNii(:,:,:,iList)   = single(tnii.dat(:,:,:));
    end

    MeanNii     = xASL_stat_MeanNan( TotalNii, 4 );
    SDNii       = xASL_stat_StdNan(  TotalNii, [], 4 );
    CVnii       = (SDNii./MeanNii) .* 100;
    xASL_io_SaveNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']), fullfile( ROOT{iRoot}, 'dartel', 'Mean_TT.nii'), MeanNii );
    xASL_io_SaveNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']), fullfile( ROOT{iRoot}, 'dartel', 'SD_TT.nii'  ), SDNii );
    xASL_io_SaveNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']), fullfile( ROOT{iRoot}, 'dartel', 'CV_TT.nii'  ), CVnii );
end

%% Create single mean & SD slice gradient/PLD-map

for iRoot=1:3
    clear TotalNii MeanNii SDNii CVnii

    for iList=1:length(dlist)
        for iSession=1:2
            tnii                                    = xASL_io_ReadNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_slice_gradient_' dlist{iList} '_ASL_' num2str(iSession) '.nii']) );
            TotalNii(:,:,:,(iList*2)-2+iSession)    = tnii.dat(:,:,:);
            clear tnii
        end
    end
    TotalNii                    = single(TotalNii);

    MeanNii     = single(xASL_stat_MeanNan( TotalNii, 4 ));
    SDNii       = single(xASL_stat_StdNan( TotalNii, [], 4 ));
    CVnii       = (SDNii./MeanNii) .* 100;
    xASL_io_SaveNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']), fullfile( ROOT{iRoot}, 'dartel', 'Mean_slicegradient.nii'), MeanNii );
    xASL_io_SaveNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']), fullfile( ROOT{iRoot}, 'dartel', 'SD_slicegradient.nii'), SDNii );
    xASL_io_SaveNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']), fullfile( ROOT{iRoot}, 'dartel', 'CV_slicegradient.nii'), CVnii );
end


%% Visualization

% A mask with GM
% B divide in 3, do same with TT. Should be comparable with paper.


% Load

InitPLD     = [1000 1525 2000];

for iRoot=1:3
	clear meanPLD meanSG CVSG meanGM meanTT CVTT Mean_PLD_visual Mean_TT_visual



    meanSG      = fullfile( ROOT{iRoot}, 'dartel', 'Mean_slicegradient.nii');
    CVSG        = fullfile( ROOT{iRoot}, 'dartel', 'CV_slicegradient.nii');
    meanTT      = fullfile( ROOT{iRoot}, 'dartel', 'mean_TT.nii');
    CVTT        = fullfile( ROOT{iRoot}, 'dartel', 'CV_TT.nii');

    meanSG      = xASL_io_ReadNifti( meanSG );
    CVSG        = xASL_io_ReadNifti( CVSG );
    meanTT      = xASL_io_ReadNifti( meanTT );
    CVTT        = xASL_io_ReadNifti( CVTT );

    meanSG      = single(meanSG.dat(:,:,:));
    CVSG        = single(CVSG.dat(:,:,:));
    meanTT      = single(meanTT.dat(:,:,:));
    CVTT        = single(CVTT.dat(:,:,:));

    meanPLD                 = InitPLD(iRoot)+((meanSG-1).*40.2);

    % Mean_PLD
    Mean_PLD_visual{1}      = xASL_vis_CropParmsApply( xASL_im_rotate(squeeze(meanPLD     (:,:,53,:) .* GMmask(:,:,53)),90)  ,ant_crop,pos_crop_final,L_crop,R_crop_final);
    Mean_PLD_visual{2}      = xASL_vis_CropParmsApply( xASL_im_rotate(squeeze(meanPLD     (:,:,67,:) .* GMmask(:,:,67)),90)  ,ant_crop,pos_crop_final,L_crop,R_crop_final);
    Mean_PLD_visual{3}      = xASL_vis_CropParmsApply( squeeze(xASL_im_rotate(FlipOrientation_isotropic(meanPLD(:,63,:,:) .* GMmask(:,63,:)),90))  ,sup_crop,inf_crop_final,L_crop,R_crop_final);
    Mean_PLD_visual{4}      = xASL_vis_CropParmsApply( squeeze(xASL_im_rotate(FlipOrientation_isotropic(meanPLD(:,95,:,:) .* GMmask(:,95,:)),90))  ,sup_crop,inf_crop_final,L_crop,R_crop_final);
    Mean_PLD_visual{5}      = xASL_vis_CropParmsApply( squeeze(FlipOrientation2_isotropic(meanPLD    (68,:,:,:) .* GMmask(68,:,:)))  ,sup_crop,inf_crop_final,ant_crop,pos_crop_final);
    Mean_PLD_visual{6}      = xASL_vis_CropParmsApply( squeeze(FlipOrientation2_isotropic(meanPLD    (76,:,:,:) .* GMmask(76,:,:)))  ,sup_crop,inf_crop_final,ant_crop,pos_crop_final);
    Mean_PLD_visual         = [ Mean_PLD_visual{1} Mean_PLD_visual{2} Mean_PLD_visual{3} Mean_PLD_visual{4} Mean_PLD_visual{5} Mean_PLD_visual{6} ];

    % Mean_TT
    Mean_TT_visual{1}       = xASL_vis_CropParmsApply( xASL_im_rotate(squeeze(meanTT     (:,:,53,:) .* GMmask(:,:,53)),90)  ,ant_crop,pos_crop_final,L_crop,R_crop_final);
    Mean_TT_visual{2}       = xASL_vis_CropParmsApply( xASL_im_rotate(squeeze(meanTT     (:,:,67,:) .* GMmask(:,:,67)),90)  ,ant_crop,pos_crop_final,L_crop,R_crop_final);
    Mean_TT_visual{3}       = xASL_vis_CropParmsApply( squeeze(xASL_im_rotate(FlipOrientation_isotropic(meanTT(:,63,:,:) .* GMmask(:,63,:)),90))  ,sup_crop,inf_crop_final,L_crop,R_crop_final);
    Mean_TT_visual{4}       = xASL_vis_CropParmsApply( squeeze(xASL_im_rotate(FlipOrientation_isotropic(meanTT(:,95,:,:) .* GMmask(:,95,:)),90))  ,sup_crop,inf_crop_final,L_crop,R_crop_final);
    Mean_TT_visual{5}       = xASL_vis_CropParmsApply( squeeze(FlipOrientation2_isotropic(meanTT    (68,:,:,:) .* GMmask(68,:,:)))  ,sup_crop,inf_crop_final,ant_crop,pos_crop_final);
    Mean_TT_visual{6}       = xASL_vis_CropParmsApply( squeeze(FlipOrientation2_isotropic(meanTT    (76,:,:,:) .* GMmask(76,:,:)))  ,sup_crop,inf_crop_final,ant_crop,pos_crop_final);
    Mean_TT_visual          = [ Mean_TT_visual{1} Mean_TT_visual{2} Mean_TT_visual{3} Mean_TT_visual{4} Mean_TT_visual{5} Mean_TT_visual{6} ];

    figure(1);imshow( Mean_PLD_visual, [1000 2500], 'Colormap', jet255, 'InitialMagnification', 200 )
    figure(2);imshow( Mean_TT_visual,  [2000 2800], 'Colormap', jet255, 'InitialMagnification', 200 )
end

% Print GM histograms

clear N_ROI X_ROI bin_nr min_nr max_nr bin_size myfilter N N2 X X2

bin_nr      = 100;
min_nr      = 800;
max_nr      = max([max(meanTT(:)) max(meanPLD(:))]);
bin_size    =(max_nr-min_nr)/bin_nr;
myfilter    =fspecial('gaussian',[bin_nr,1],0.02*bin_nr);
% This is 117/ 180 = 0.65 bins per mL/100g/min, histograms shown have 120 range which would have been 78 bins

% Mean PLD histograms

% dip_image(meanPLD.*GMmask)
%
% [N X]       = hist(meanPLD(GMmask & isfinite(meanPLD) ),[min_nr:(max_nr-min_nr)/bin_nr:max_nr]);
% [N2 X2]     = hist(meanTT( GMmask & isfinite(meanTT ) ),[min_nr:(max_nr-min_nr)/bin_nr:max_nr]);

[N X]       = hist(meanPLD(P & isfinite(meanPLD) ),[min_nr:(max_nr-min_nr)/bin_nr:max_nr]);
[N2 X2]     = hist(meanTT( P & isfinite(meanTT ) ),[min_nr:(max_nr-min_nr)/bin_nr:max_nr]);

N           = N ./sum(N) ./bin_size;
N2          = N2./sum(N2)./bin_size;

figure(1);  plot(X,100.*N,'r',X2,100.*N2,'b');
axis([1000 3000 0 0.5]);
xlabel('Time (ms)');
ylabel('Normalized frequency (%)');
title('Red = PLD, blue = FEAST-TT');
print(gcf,'-depsc','E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison1000\Results\Hist_2000_PCA.eps');
close



%% Compare FEAST TT with slice gradients
clear all

ROOT{1}    = 'E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison1000\analysis';
ROOT{2}    = 'E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison1500\analysis';
ROOT{3}    = 'E:\Backup\ASL_E\Pre_DIVA_FEAST_comparison2000\analysis';

dlist       = xASL_adm_GetFsList(ROOT{1}, '^\d{6}$', 1);

PLD_init    = [1000 1525 2000];

for iRoot=1:3
    clear Total_TT Total_SG BinMapTT_visual
    for iList=1:length(dlist)
        tnii                    = xASL_io_ReadNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_TT_' dlist{iList} '.nii']) );
        Total_TT(:,:,:,iList)   = single(tnii.dat(:,:,:));
        clear tnii
    end


    for iList=1:length(dlist)
        for iSession=1:2
            tnii                                    = xASL_io_ReadNifti( fullfile( ROOT{iRoot}, 'dartel', ['DARTEL_slice_gradient_' dlist{iList} '_ASL_' num2str(iSession) '.nii']) );
            temp_SG(:,:,:,iSession)                 = single(tnii.dat(:,:,:));
            clear tnii
        end
        Total_SG(:,:,:,iList)                       = xASL_stat_MeanNan(temp_SG,4);
        clear temp_SG
    end

    PLDslicereadout     = 40.2;

    Total_SG                                        = PLD_init(iRoot) + ((Total_SG-1) .* PLDslicereadout);

    GMmask10    = repmat(GMmask,[1 1 1 size(Total_SG,4)]);

    % Iterate for graph

    BinMapTT    = zeros(121,145,121);

    BinSizes                 = [1 10 [1:1:10].*50];
    for iNum=1:length(BinSizes)
        clear Total_SG_rounded Total_TT_rounded EqualVoxels
        BinSize(iNum)        = BinSizes(iNum);

        Total_SG_rounded     = round(Total_SG./BinSize(iNum)).*BinSize(iNum);
        Total_TT_rounded     = round(Total_TT./BinSize(iNum)).*BinSize(iNum);
        EqualVoxels          = (Total_SG_rounded==Total_TT_rounded) & GMmask10;
        TotalEqVox           = xASL_stat_MeanNan(EqualVoxels,4)>0.2;
        nEqualVox(iNum)      = (sum(EqualVoxels(:))/sum(GMmask10(:)) )*100;
        BinMapTT( TotalEqVox & BinMapTT==0 )   = iNum;
    end

    BinSizeRoot{iRoot}      = BinSize;
    nEqualVoxRoot{iRoot}    = nEqualVox;
end

    figure(1);plot(BinSizeRoot{1},nEqualVoxRoot{1},'r',BinSizeRoot{2},nEqualVoxRoot{2},'g',BinSizeRoot{3},nEqualVoxRoot{3},'b')
    title('Proportion of ATT-values measured by FEAST for which only PLD is responsible');
    xlabel('ATT bins (ms)');
    ylabel('Proportion (%)');
    axis([0 500 0 100]);

    % BinMapTT
    clear BinMapTT_visual
    BinMapTT_visual{1}           = xASL_vis_CropParmsApply( xASL_im_rotate(squeeze(BinMapTT     (:,:,53,:) .* GMmask(:,:,53)),90)  ,ant_crop,pos_crop_final,L_crop,R_crop_final);
    BinMapTT_visual{2}           = xASL_vis_CropParmsApply( xASL_im_rotate(squeeze(BinMapTT     (:,:,67,:) .* GMmask(:,:,67)),90)  ,ant_crop,pos_crop_final,L_crop,R_crop_final);
    BinMapTT_visual{3}           = xASL_vis_CropParmsApply( squeeze(xASL_im_rotate(FlipOrientation_isotropic(BinMapTT(:,63,:,:) .* GMmask(:,63,:)),90))  ,sup_crop,inf_crop_final,L_crop,R_crop_final);
    BinMapTT_visual{4}           = xASL_vis_CropParmsApply( squeeze(xASL_im_rotate(FlipOrientation_isotropic(BinMapTT(:,95,:,:) .* GMmask(:,95,:)),90))  ,sup_crop,inf_crop_final,L_crop,R_crop_final);
    BinMapTT_visual{5}           = xASL_vis_CropParmsApply( squeeze(FlipOrientation2_isotropic(BinMapTT    (68,:,:,:) .* GMmask(68,:,:)))  ,sup_crop,inf_crop_final,ant_crop,pos_crop_final);
    BinMapTT_visual{6}           = xASL_vis_CropParmsApply( squeeze(FlipOrientation2_isotropic(BinMapTT    (76,:,:,:) .* GMmask(76,:,:)))  ,sup_crop,inf_crop_final,ant_crop,pos_crop_final);
    BinMapTT_visual              = [ BinMapTT_visual{1} BinMapTT_visual{2} BinMapTT_visual{3} BinMapTT_visual{4} BinMapTT_visual{5} BinMapTT_visual{6} ];

    figure(2);imshow( BinMapTT_visual, [1 11], 'Colormap', jet255,'InitialMagnification',200)
