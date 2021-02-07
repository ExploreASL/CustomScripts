%% CreateFigure_SpatialCoV_Explanation

ResultsDir                  = 'C:\Users\henkj\Dropbox\Itinerant Science\04_SpatialCoV_carotid_occlusion\Figures\HJM_new';
CBFim                       = nifti2IM('C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\qCBF_untreated_012_ASL_1.nii');
TatuName                    = 'C:\ExploreASL\Maps\Atlases\VascularTerritories\CortVascTerritoriesTatu.nii';
Tatu                        = nifti2IM(TatuName);
ICAim                       = (Tatu==1 | Tatu==2).*nifti2IM(symbols.RESLICEREF)>0.5;
ICA_L                       = ICAim;
ICA_L(1:61,:,:)             = 0;
% ICA_L(:,:,[1:69 71:end])    = 0;
ICA_R                       = ICAim;
ICA_R(62:121,:,:)           = 0;
% ICA_R(:,:,[1:69 71:end])    = 0;

CBFfactor                   = 1.67;
CBFim                       = CBFim./CBFfactor;

ICApathL          = fullfile(ResultsDir,'ICA_L.nii');
ICApathR          = fullfile(ResultsDir,'ICA_R.nii');
save_nii_spm(TatuName,ICApathL,ICA_L,[],0);
save_nii_spm(TatuName,ICApathR,ICA_R,[],0);

meanL   = xASL_stat_MeanNan(CBFim(ICA_L))
meanR   = xASL_stat_MeanNan(CBFim(ICA_R))
sdL     = xASL_stat_StdNan(CBFim(ICA_L))
sdR     = xASL_stat_StdNan(CBFim(ICA_R))
sCoV_L  = sdL/meanL
sCoV_R  = sdR/meanR

[N_L X_L]   = hist(CBFim(ICA_L),15);
[N_R X_R]   = hist(CBFim(ICA_R),15);
N_L         = N_L/sum(N_L);
N_R         = N_R/sum(N_R);
figure(1);plot(X_L,N_L,'b-',X_R,N_R,'r-');
xlabel('Measured CBF (mL/100g/min)');
ylabel('Normalized frequency');

%% New Figure
clear S
S.TraSlices         = [51 55 62 76]; % 69 83
S.ConcatSliceDims   = 1;
S.Square            = 0;
S.SkullStrip        = 1;

CBFimLowestsCoV     = ndnanfilter(nifti2IM('C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\qCBF_untreated_033_ASL_1.nii'),'GaussWinImage',[2 2 2]);
CBFimHighestsCoV    = ndnanfilter(nifti2IM('C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\qCBF_untreated_024_ASL_1.nii'),'GaussWinImage',[2 2 2]);

IMlow               = TransformDataViewDimension(CBFimLowestsCoV,[],S) .*0.75;
IMhigh              = TransformDataViewDimension(CBFimHighestsCoV,[],S) .*1.25;

figure(1);imshow(IMlow,[0 255],'Border','tight')
figure(2);imshow(IMhigh,[0 255],'Border','tight')

dip_image([IMlow;IMhigh])
dip_image([IMlow(1:0.5*732,:) IMlow(0.5*732+1:end,:) IMhigh(1:0.5*732,:) IMhigh(0.5*732+1:end,:)])


