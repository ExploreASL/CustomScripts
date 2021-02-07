%% Comparison registration

%% Administration
clear
BMASK   = 'C:\ASL_pipeline_HJ\Maps\rbrainmask.nii';
BMASK   = xASL_nifti(BMASK);
BMASK   = xASL_im_rotate(BMASK.dat(:,:,:),90);

% bMASK   = zeros(size(BMASK,1),size(BMASK,2),size(BMASK,3));
% bMASK(BMASK>0.8)    = 1;
% bMASK(BMASK<0.8 & BMASK>0.7)    = 0.8;
% bMASK(BMASK<0.7 & BMASK>0.6)    = 0.6;
% bMASK(BMASK<0.6 & BMASK>0.5)    = 0.4;
% bMASK(BMASK<0.5 & BMASK>0.4)    = 0.2;

bMASK   = zeros(size(BMASK,1),size(BMASK,2),size(BMASK,3));
bMASK(BMASK>0.8)    = 1;
bMASK(BMASK<0.85 & BMASK>0.75)    = 0.8;
bMASK(BMASK<0.75 & BMASK>0.7)    = 0.6;
bMASK(BMASK<0.7 & BMASK>0.65)    = 0.4;
bMASK(BMASK<0.65 & BMASK>0.6)    = 0.2;

GMmask  = 'C:\ASL_pipeline_HJ\Maps\rgrey.nii';
GMmask  = xASL_nifti(GMmask);
GMmask  = xASL_im_rotate(GMmask.dat(:,:,:),90);

for iSlice=1:size(GMmask,3)
    GMMASK(:,:,iSlice)   = GMmask(:,:,iSlice)>(0.6*max(max(GMmask(:,:,iSlice))));
end
GMMASK  = GMMASK.*(BMASK>0.8);
GMMASK  = logical(GMMASK);
GMMASK(:,:,1:29)    = 0;

OUTPUTDIR   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis';
INPUTDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\pGM_COMPARISON';

jet_256         = jet(256);
jet_256(1,:)    = 0;

% Create MNI ROIs
piet{1}         = GMMASK;
GMMASK          = piet;
clear piet

MNI_large_load                             = fullfile( 'C:\ASL_pipeline_HJ\Maps', 'rMNI_large_ROI_maps.nii');
MNI_large                                  = xASL_nifti( MNI_large_load);
NextN                                      = 2;
for iMask=[3 4 8 6] % frontal insular temporal parietal
    GMMASK{NextN}                          = logical( single(GMMASK{1}) .* xASL_im_rotate(single(MNI_large.dat(:,:,:,iMask))>0,90) );
    NextN                                  = NextN+1;
end

% for iMask=9 % thalamus, no multiplication with individual GM mask
%             % since the segmentation is incorrect
%     GMMASK{iMask+1}                        = logical(single(xASL_im_rotate(MNI_large.dat(:,:,:,iMask),90))>0);
% end           

%% 1) Get List Names
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor';
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_NOMASK' 'PWI_pGM_MASK' 'PWI_pGM_NOMASK'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};
% DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

for iReg=1
    for iV=1:4
        NameList{iV}    = xASL_adm_GetFsList( fullfile( ROOT, RegCat{iReg },Vendors{iV}) ,'^(C9ORF|MAPT|GRN)\d{3}$',1);
    end
end

%% 1) Load files
iD=1;
for iReg=1
    for iV=1:4
        for iN=1:12
            FILELOAD    = xASL_nifti( fullfile( INPUTDIR, ['rc1T1_' NameList{iV}{iN} '.nii'] ) );
            TOTALIM{iReg}{iV}{iD}(:,:,:,iN)    = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
        end
    end
end

%% Mask
BMASK12     = repmat(bMASK,[1 1 1 12]);

for iR=1
    for iV=1:4
        for iD=1:length(TOTALIM{iR}{iV})
            
            TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}.*BMASK12;
            
        end
    end
end

%% Normalize all per sequence
GMMASK12     = repmat(GMMASK{1},[1 1 1 12]);
for iR=1
    for iV=1:4
        for iD=1:length(TOTALIM{iR}{iV})
            meanInt                 = xASL_stat_MeanNan( TOTALIM{iR}{iV}{iD}(GMMASK12));
            TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}./meanInt.*50;
            clear meanInt
        end
    end
end

%% Regrid data in all vendors together - total group

% Regrid images
for iV=1:4
    for iR=1
        if iR>2
             lengthSlice=3;
        else lengthSlice=2;
        end
        for iD=1
            TOTALIM{iR}{5}{iD}(:,:,:,(iV-1)*12+1:iV*12)     = TOTALIM{iR}{iV}{iD};
        end
    end
end


%% Visualization mean CBF
% Get Figure for all vendors

for iR=1
    clear SLICE lengthSlice
    if iR>2
        lengthSlice=3;
    else lengthSlice=2;
    end
    
    for iSlice=1
        AllVendorSlice      = (xASL_stat_MeanNan(TOTALIM{iR}{1}{iSlice}(:,:,72,:),4) + xASL_stat_MeanNan(TOTALIM{iR}{2}{iSlice}(:,:,72,:),4) + xASL_stat_MeanNan(TOTALIM{iR}{3}{iSlice}(:,:,72,:),4) + xASL_stat_MeanNan(TOTALIM{iR}{4}{iSlice}(:,:,72,:),4))./4;
%         SLICE(:,:,iSlice)  = [xASL_stat_MeanNan(TOTALIM{iR}{1}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{2}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{3}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{4}{iSlice}(:,:,72,:),4)];
        SLICE(:,:,iSlice)  = [xASL_stat_MeanNan(TOTALIM{iR}{1}{iSlice}(:,:,72,:),4).*1.14 xASL_stat_MeanNan(TOTALIM{iR}{2}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{3}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{4}{iSlice}(:,:,72,:),4) AllVendorSlice];
    end

%     slicesLarge             = [53 62 74 87];
% 
%     for iSlice=1:length(slicesLarge)
%         IMSHOWTOTAL(:,:,iSlice)     = MEANim(:,:,slicesLarge(iSlice));
%     end
% 
%     IMSHOWTOTAL2(:,:,iD)    = singlesequencesort(IMSHOWTOTAL,4);
%     clear IMSHOWTOTAL    
    
    
    close all
    figure(1);imshow(singlesequencesort(SLICE,1),[0 90],'Colormap',jet_256);
    print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_pGM_meanVendor_color.jpg']));
    print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_pGM_meanVendor_color.eps']));

    clear SLICE AllVendorSlice

end





%% Subject-wise stats: get corr_coef & TC

clear CorrMean CorrMAD TCoeffMean TCoeffMedian TCoeffMAD TCoeffstd

PermList12     = UniquePartialPermutations([1:1:12]);
PermList48     = UniquePartialPermutations([1:1:48]);

for iR=1
    iR
    if iR>2
         lengthSlice=3;
    else lengthSlice=2;
    end
    for iD=1
        iD
        for iV=1:5
            
            if  iV==5
                PermList    = PermList48;
            else
                PermList    = PermList12;
            end
            
            iMask   = 1;
            
            %% Get TC
            for iPerm=1:length(PermList)
                IM1                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,1));
                IM2                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,2));
                MASK                = GMMASK{1} & isfinite(IM1) & isfinite(IM2) & IM1>0  & IM2>0;
                TESTTEMP(:,:,:,1)   = IM1.*single(MASK);
                TESTTEMP(:,:,:,2)   = IM2.*single(MASK);

                TC                  = min(TESTTEMP,[],4)./max(TESTTEMP,[],4);
                TCoeff{iR}{iD}{iV}(iPerm,iMask)                             = median(TC(isfinite(TC) & GMMASK{iMask} ));
%                 [X{iR}{iD}{iV}(:,iPerm,iMask) N{iR}{iD}{iV}(:,iPerm,iMask)] = hist(TC(isfinite(TC)   & GMMASK{iMask} ) ,25);
                X{iR}{iD}{iV}(:,iPerm,iMask)                                = X{iR}{iD}{iV}(:,iPerm,iMask)./sum(X{iR}{iD}{iV}(:,iPerm,iMask));
                clear TC IM1 IM2 MASK TESTTEMP
            end

        end
    end
end







% 
% % Get regional values
% for iR=1
%     iR
%     if iR>2
%          lengthSlice=3;
%     else lengthSlice=2;
%     end
%     for iD=1
%         iD
%         for iV=1:5
%             
%             if  iV==5
%                 PermList    = PermList48;
%             else
%                 PermList    = PermList12;
%             end
%             
%             
%             %% Get corr_coef & TC
%             for iPerm=1:length(PermList)
%                 
%                 TESTTEMP                                                        = TCmap{iR}{iD}{iV}(:,:,:,iPerm);
%                 
%                 for iMask=1:5
%                     TCoeff{iR}{iD}{iV}(iPerm,iMask)                             = mean(TESTTEMP(GMMASK{iMask} & isfinite(TESTTEMP)));
%                     TCoeffMEDIANMASK{iR}{iD}{iV}(iPerm,iMask)                   = median(TESTTEMP(GMMASK{iMask} & isfinite(TESTTEMP)));
% 
%                     [X{iR}{iD}{iV}(:,iPerm,iMask) N{iR}{iD}{iV}(:,iPerm,iMask)] = hist(TESTTEMP(GMMASK{iMask} & isfinite(TESTTEMP))  ,25);
%                     X{iR}{iD}{iV}(:,iPerm,iMask)                                = X{iR}{iD}{iV}(:,iPerm)./sum(X{iR}{iD}{iV}(:,iPerm));
%                 end
%                 clear TESTTEMP
%             end
%             
% %             TCoeffMean(iD,iV,iR,:)          = xASL_stat_MeanNan(TCoeff{iR}{iD}{iV},1);
% %             TCoeffstd(iD,iV,iR,:)           = xASL_stat_StdNan(TCoeff{iR}{iD}{iV},[],1);
%             TCoeffMedian(iD,iV,iR,:)        = xASL_stat_MedianNan(TCoeff{iR}{iD}{iV},1);
%             TCoeffMAD(iD,iV,iR,:)           = xASL_stat_MadNan(TCoeff{iR}{iD}{iV},[],1);
%             
%         end
%     end
% end

for iV=1:5
    TCoeffMedian(iD,iV,iR,:,iMask)        = xASL_stat_MedianNan(TCoeff{iR}{iD}{iV}(:,iMask),1);
    TCoeffMAD(iD,iV,iR,:,iMask)           = xASL_stat_MadNan(TCoeff{iR}{iD}{iV}(:,iMask),[],1);                
end
    
TCoeffMedian    = round(TCoeffMedian*1000)./10;
TCoeffMAD       = round(TCoeffMAD*1000)./10;

% Get TC histograms
VENDORNAME  = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'AllTogether'};

% Create TC histograms
for iR=1
    for iV=1:5
        for iMask=1:10
            figure(1);plot(mean(N{iR}{1}{iV},2,iMask),mean(X{iR}{1}{iV},2,iMask));

            axis([0 1 0 0.08])

            print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,'TC_Histograms',[RegCat{iR} '_' VENDORNAME{iV} '_pGM.jpg']));
            print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,'TC_Histograms',[RegCat{iR} '_' VENDORNAME{iV} '_pGM.eps']));

            close all
        end
    end
end

%% Kruskal-Wallis
% The t-stat or Chi-square stat linearly scales with number of subjects

% Registration difference between vendors for pGM

[p anovatab stats]  = kruskalwallis( [TCoeff{1}{1}{1} TCoeff{1}{1}{2} TCoeff{1}{1}{3} TCoeff{1}{1}{4} ] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{1}{1}{1})/48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

% For pGM-approach
iV=5; iR=3;
% p   = kruskalwallis( [TCoeff{iR}{1}{iV}(1:48) TCoeff{iR}{2}{iV}(1:48) TCoeff{iR}{3}{iV}(1:48)] );
[p anovatab stats]  = kruskalwallis( [TCoeff{iR}{1}{iV} TCoeff{iR}{2}{iV} TCoeff{iR}{3}{iV}] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR}{1}{iV})/48);
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

% For all together
[p anovatab stats]  = kruskalwallis( [TCoeff{1}{1}{iV} TCoeff{1}{2}{iV}   TCoeff{3}{1}{iV} TCoeff{3}{2}{iV} TCoeff{3}{3}{iV}] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR}{1}{iV})/48);
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);



% TC are much more "normally" distributed than corr_coeff,
% and are able to show the difference (ref Crum)
[X N]                   = hist(TCoeff{iR}{iD}{5}  ,25);

[X N]                   = hist(TC(isfinite(TC))  ,25);



figure(1);plot(N{iR}{iD}{iV}(:,iPerm),X{iR}{iD}{iV}(:,iPerm));
figure(2);plot(mean(N{iR}{iD}{iV},2),mean(X{iR}{iD}{iV},2));
axis([0 1 0 0.16])

iD=1;
iV=5;
iR=1;

TCoeffMean(iD,iV,iR)    = xASL_stat_MeanNan(TCoeff{iR}{iD}{iV}(TCoeff{iR}{iD}{iV}>0));
TCoeffstd(iD,iV,iR)     = xASL_stat_StdNan(TCoeff{iR}{iD}{iV}(TCoeff{iR}{iD}{iV}>0));
TCoeffMedian(iD,iV,iR)  = xASL_stat_MedianNan(TCoeff{iR}{iD}{iV}(TCoeff{iR}{iD}{iV}>0));
TCoeffMAD(iD,iV,iR)     = xASL_stat_MadNan(TCoeff{iR}{iD}{iV}(TCoeff{iR}{iD}{iV}>0));

TCoeffMean(iD,iV,iR)
TCoeffMedian(iD,iV,iR)
TCoeffstd(iD,iV,iR)
TCoeffMAD(iD,iV,iR)
