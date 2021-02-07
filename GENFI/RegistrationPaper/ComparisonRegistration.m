%% Comparison registration

%% Scripting without pipeline
clear
x.MYPATH   = 'c:\ASL_pipeline_HJ';
AdditionalToolboxDir    = 'C:\ASL_pipeline_HJ_toolboxes'; % provide here ROOT directory of other toolboxes used by this pipeline, such as dip_image & SPM12
if ~isdeployed
    addpath(x.MYPATH);

    subfolders_to_add = { 'ANALYZE_module_scripts', 'ASL_module_scripts', fullfile('Development','dicomtools'), fullfile('Development','Filter_Scripts_JanCheck'), 'MASTER_scripts', 'spm_jobs','spmwrapperlib' };
    for ii=1:length(subfolders_to_add)
        addpath(fullfile(x.MYPATH,subfolders_to_add{ii}));
    end
end

addpath(fullfile(AdditionalToolboxDir,'DIP','common','dipimage'));

[x.SPMDIR, x.SPMVERSION] = xASL_adm_CheckSPM('FMRI',fullfile(AdditionalToolboxDir,'spm12') );
addpath( fullfile(AdditionalToolboxDir,'spm12','compat') );

if isempty(which('dip_initialise'))
    fprintf('%s\n','CAVE: Please install dip_image toolbox!!!');
else dip_initialise
end


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

bMASK                           = zeros(size(BMASK,1),size(BMASK,2),size(BMASK,3));
bMASK(BMASK>0.8)                = 1;
bMASK(BMASK<0.85 & BMASK>0.75)  = 0.8;
bMASK(BMASK<0.75 & BMASK>0.7)   = 0.6;
bMASK(BMASK<0.7 & BMASK>0.65)   = 0.4;
bMASK(BMASK<0.65 & BMASK>0.6)   = 0.2;

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

% dip_image([GMMASK{1} GMMASK{2} GMMASK{3} GMMASK{4} GMMASK{5}])

%% 1) Load files
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor';
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

for iReg=[1 7]
    for iV=1:4
        
        if ~isempty(strfind(RegCat{iReg },'PWI_pGM'))
                iD_length=3;
        else    iD_length=1;
        end
        
        for iD=1:iD_length
            FDIR    = fullfile( ROOT, RegCat{iReg }, Vendors{iV}, 'dartel', DegFree{iD});
            FLIST   = xASL_adm_GetFileList( FDIR, '^qCBF_(C9ORF|MAPT|GRN)\d{3}\_ASL_1.(nii|nii\.gz)$');
            for iN=1:12
                FILELOAD    = xASL_nifti(FLIST{iN});
                TOTALIM{iReg}{iV}{iD}(:,:,:,iN)    = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
            end
        end
    end
end

%% Mask
BMASK12     = repmat(bMASK,[1 1 1 12]);

for iR=1:length(TOTALIM)
    for iV=1:length(TOTALIM{iR})
        for iD=1:length(TOTALIM{iR}{iV})
            TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}.*BMASK12;
        end
    end
end

%% Normalize all per sequence
GMMASK12     = repmat(GMMASK{1},[1 1 1 12]);
for iR=[1 3]
    for iV=1:4
        for iD=1:length(TOTALIM{iR}{iV})
            meanInt                 = xASL_stat_MeanNan( TOTALIM{iR}{iV}{iD}(GMMASK12));
            TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}./meanInt.*50;
            clear meanInt
        end
    end
end

% %% Normalize all subject-wise
% for iR=[1 3]
%     for iV=1:4
%         for iD=1:length(TOTALIM{iR}{iV})
%             for iS=1:12
%                 temp                            = TOTALIM{iR}{iV}{iD}(:,:,:,iS);
%                 meanInt                         = xASL_stat_MeanNan( temp(GMMASK));
%                 TOTALIM{iR}{iV}{iD}(:,:,:,iS)   = TOTALIM{iR}{iV}{iD}(:,:,:,iS)./meanInt.*50;
%                 clear meanInt
%             end
%         end
%     end
% end

% 
% % Check normalization
% for iR=1:4
%     for iV=1:4
%         for iD=1:length(TOTALIM{iR}{iV})
%             for iSub=1:12
%                 temp                    = TOTALIM{iR}{iV}{iD}(:,:,:,iSub);
%                 meanInt(iSub,iD,iV,iR)  = xASL_stat_MeanNan( temp(GMMASK));
%             end
%                 
%         end
%     end
% end

%% Regrid data in all vendors together - total group

% Regrid images
for iV=1:4
    for iR=[1 3]
        if iR>2
             lengthSlice=3;
        else lengthSlice=2;
        end
        for iD=1:lengthSlice        
            TOTALIM{iR}{5}{iD}(:,:,:,(iV-1)*12+1:iV*12)     = TOTALIM{iR}{iV}{iD};
%             TOTALIM{iR}{iV}{iD}=1;
        end
    end
end
% 
% % dip_image(squeeze(TOTALIM{3}{5}{1}(:,:,52,:)))
% % dip_image([mean(TOTALIM{1}{5}{1},4)./std(TOTALIM{1}{5}{1},[],4) mean(TOTALIM{3}{5}{1},4)./std(TOTALIM{3}{5}{1},[],4)])



%% Visualization mean CBF
% Get Figure for all vendors

for iR=[1 3]
    clear SLICE lengthSlice
    if iR>2
        lengthSlice=3;
    else lengthSlice=2;
    end
    
    for iSlice=1:lengthSlice
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
    print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,[RegCat{iR} 'meanVendor_color.jpg']));
    print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} 'meanVendor_color.eps']));

    clear SLICE AllVendorSlice

end






% %% Voxel-wise stats: get SNR/ wsCV
% for iR=[1 3]
%     if iR>2
%          lengthSlice=3;
%     else lengthSlice=2;
%     end
%     for iD=1:lengthSlice
%         for iV=5 %1:4
%         
% %         % Get SNR
%         SNRim                   = xASL_stat_MeanNan(TOTALIM{iR}{iV}{iD},4)./xASL_stat_StdNan(TOTALIM{iR}{iV}{iD},[],4).*bMASK;
%         SNRmedian(iD,iV,iR)     = xASL_stat_MedianNan(SNRim(GMMASK & isfinite(SNRim)));
%         SNRmad(iD,iV,iR)        = xASL_stat_MadNan(SNRim(GMMASK & isfinite(SNRim)));
%         SNRmean(iD,iV,iR)       = xASL_stat_MeanNan(SNRim(GMMASK & isfinite(SNRim)));
%         SNRstd(iD,iV,iR)        = std(SNRim(GMMASK & isfinite(SNRim)));
% 
%         % Get wsCV
%         wsCVim                  = 100.*xASL_stat_StdNan(TOTALIM{iR}{iV}{iD},[],4)./xASL_stat_MeanNan(TOTALIM{iR}{iV}{iD},4);
%         wsCVmean(iD,iV,iR)      = mean(wsCVim(GMMASK & isfinite(wsCVim)));
%         wsCVstd(iD,iV,iR)       = std(wsCVim(GMMASK & isfinite(wsCVim)));             
%         wsCVmedian(iD,iV,iR)    = median(wsCVim(GMMASK & isfinite(wsCVim)));
%         wsCVmad(iD,iV,iR)       = xASL_stat_MadNan(wsCVim(GMMASK & isfinite(wsCVim)));             
% 
%        
%         
% %         slicesLarge             = [53 62 74 87];
% %         
% %         for iSlice=1:length(slicesLarge)
% %             IMSHOWTOTAL(:,:,iSlice)     = SNRim(:,:,slicesLarge(iSlice));
% %         end
% %         
% %         IMSHOWTOTAL2(:,:,iD)    = singlesequencesort(IMSHOWTOTAL,4);
% %         clear IMSHOWTOTAL
% %     end
% %     
% %         figure(1);imshow(singlesequencesort(IMSHOWTOTAL2,1),[0 4.5],'Colormap',jet_256);
% %         print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_SNR.jpg']));
% %         print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_SNR.eps']));
% %         close all
% %         
% %         clear IMSHOWTOTAL2
% 
% %         [X{iD}{iV}{iR} N{iD}{iV}{iR}]   = hist(wsCVim(GMMASK & isfinite(wsCVim)),100);
% %         X{iD}{iV}{iR}                   = X{iD}{iV}{iR}./sum(X{iD}{iV}{iR});
% 
%         clear SNRim CorrPerm TCoeff wsCVim
% 
%         end
%     end
% end
% 
% wsCVmean    = round(wsCVmean.*10)./10;
% wsCVstd     = round(wsCVstd.*10)./10;
% 
% VENDORNAME  = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'AllTogether'};
% 
% % Create wsCV histograms
% for iR=[1 3]
%     for iV=5 %1:4
%         if iR>2
%             figure(1);plot(N{1}{iV}{iR},X{1}{iV}{iR},'r',N{2}{iV}{iR},X{2}{iV}{iR},'b',N{3}{iV}{iR},X{3}{iV}{iR},'k');
%         else
%             figure(1);plot(N{1}{iV}{iR},X{1}{iV}{iR},'r',N{2}{iV}{iR},X{2}{iV}{iR},'b');
%         end
%         axis([0 150 0 0.1])
%         
%         print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,'Histograms',[RegCat{iR} '_' VENDORNAME{iV} '.jpg']));
%         print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,'Histograms',[RegCat{iR} '_' VENDORNAME{iV} '.eps']));
% 
%         close all
%     end
% end




%% Subject-wise stats: get corr_coef & TC

clear CorrMean CorrMAD TCoeffMean TCoeffMAD

PermList12     = UniquePartialPermutations([1:1:12]);
PermList48     = UniquePartialPermutations([1:1:48]);

for iR=[1 3]
    iR
    if iR>2
         lengthSlice=3;
    else lengthSlice=2;
    end
    for iD=1:lengthSlice
        iD
        for iV=1:5
            
            if  iV==5
                PermList    = PermList48;
            else
                PermList    = PermList12;
            end
            
            
            %% Get corr_coef & TC
            for iPerm=1:length(PermList)
                IM1                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,1));
                IM2                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,2));
                MASK                = GMMASK & isfinite(IM1) & isfinite(IM2) & IM1>0  & IM2>0;
                TESTTEMP(:,:,:,1)   = IM1.*single(MASK);
                TESTTEMP(:,:,:,2)   = IM2.*single(MASK);
            
%                 CorrTemp            = corrcoef(TESTTEMP,'rows','complete');
%                 CorrPerm{iR}{iD}{iV}(iPerm,1)   = CorrTemp(1,2);
                TC                  = min(TESTTEMP,[],4)./max(TESTTEMP,[],4);
                
                TCmap{iR}{iD}{iV}(:,:,:,iPerm)          = TC;
                
                clear CorrTemp TESTTEMP TC IM1 IM2 MASK
            end

%             CorrMedian(iD,iV,iR)    = xASL_stat_MedianNan(CorrPerm{iR}{iD}{iV});
%             CorrMAD(iD,iV,iR)       = xASL_stat_MadNan(CorrPerm{iR}{iD}{iV});
%             CorrMean(iD,iV,iR)      = xASL_stat_MeanNan(CorrPerm{iR}{iD}{iV});
%             Corrstd(iD,iV,iR)       = xASL_stat_StdNan(CorrPerm{iR}{iD}{iV});            
            
        end
    end
end


for iR=[1 3]
    iR
    if iR>2
         lengthSlice=3;
    else lengthSlice=2;
    end
    for iD=1:lengthSlice
        iD
        for iV=1:5
            
            if  iV==5
                PermList    = PermList48;
            else
                PermList    = PermList12;
            end

            %% Get corr_coef & TC
            for iPerm=1:length(PermList)

                TESTTEMP                                                        = TCmap{iR}{iD}{iV}(:,:,:,iPerm);
                
                for iMask=1:5                

                    TCoeff{iR}{iD}{iV}(iPerm,1)             = mean(TC(isfinite(TC)));
                    TCoeffMEDIANMASK{iR}{iD}{iV}(iPerm,1)   = median(TC(isfinite(TC)));

                    [X{iR}{iD}{iV}(:,iPerm) N{iR}{iD}{iV}(:,iPerm)] = hist(TC(isfinite(TC))  ,25);
                    X{iR}{iD}{iV}(:,iPerm)                          = X{iR}{iD}{iV}(:,iPerm)./sum(X{iR}{iD}{iV}(:,iPerm));
                end
                clear TESTTEMP
            end
%             TCoeffMean(iD,iV,iR,:)          = xASL_stat_MeanNan(TCoeff{iR}{iD}{iV},1);
%             TCoeffstd(iD,iV,iR,:)           = xASL_stat_StdNan(TCoeff{iR}{iD}{iV},[],1);
            TCoeffMedian(iD,iV,iR,:)        = xASL_stat_MedianNan(TCoeff{iR}{iD}{iV},1);
            TCoeffMAD(iD,iV,iR,:)           = xASL_stat_MadNan(TCoeff{iR}{iD}{iV},[],1);
        end
    end
end
                    

TCoeffMedian    = round(TCoeffMedian*1000)./10;
TCoeffMAD       = round(TCoeffMAD*1000)./10;

% Get TC histograms
VENDORNAME  = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'AllTogether'};

% Create TC histograms
for iR=[1 3]
    for iV=1:5
        if iR>2
            figure(1);plot(mean(N{iR}{1}{iV},2),mean(X{iR}{1}{iV},2),'r',mean(N{iR}{2}{iV},2),mean(X{iR}{2}{iV},2),'k',mean(N{iR}{3}{iV},2),mean(X{iR}{3}{iV},2),'g');
        else
            figure(1);plot(mean(N{iR}{1}{iV},2),mean(X{iR}{1}{iV},2),'r',mean(N{iR}{2}{iV},2),mean(X{iR}{2}{iV},2),'k');
        end
        
        axis([0 1 0 0.08])
        
        print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,'TC_Histograms',[RegCat{iR} '_' VENDORNAME{iV} '_sequence_scaled.jpg']));
        print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,'TC_Histograms',[RegCat{iR} '_' VENDORNAME{iV} '_sequence_scaled.eps']));

        close all
    end
end

%% Kruskal-Wallis
% The t-stat or Chi-square stat linearly scales with number of subjects

% For T1-approach
iV=5; iR=1;
[p anovatab stats]  = kruskalwallis( [TCoeff{iR}{1}{iV} TCoeff{iR}{2}{iV} ] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR}{1}{iV})/48)
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





%% Same for pGM

% GMMASK_RESHAPED   = reshape(GMMASK,[145*121*121 1]);
% 
% % First try GM_masks as reference
% GM_ROOT     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\pGM_COMPARISON';
% FLIST_GM    = xASL_adm_GetFileList(GM_ROOT, '^rc1T1_(C9ORF|MAPT|GRN)\d{3}\.(nii|nii\.gz)$');
% for iF=1:length(FLIST_GM)
%     clear tnii
%     tnii                    = xASL_nifti(FLIST_GM{iF});
%     GM_EXAMPLE(:,:,:,iF)    = xASL_im_rotate(tnii.dat(:,:,:),90);
% end
% 
% MEANimGM                   = xASL_stat_MeanNan(GM_EXAMPLE,4).*bMASK;
% 
% slicesLarge             = [53 62 74 87];
% 
% for iSlice=1:length(slicesLarge)
%     IMSHOWTOTAL(:,:,iSlice)     = MEANimGM(:,:,slicesLarge(iSlice));
% end
% 
% 
% 
% figure(1);imshow(singlesequencesort(IMSHOWTOTAL,4).*50,[0 60],'Colormap',jet_256);
% print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,['pGM_MEAN.jpg']));
% print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,['pGM_MEAN.eps']));
% close all
