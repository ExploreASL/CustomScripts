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

WMmask  = 'C:\ASL_pipeline_HJ\Maps\Enhanced_TPM\Enhanced_TPM.nii';
WMmask  = xASL_nifti(WMmask);
WMmask  = xASL_im_rotate(WMmask.dat(:,:,:,2),90);

for iSlice=1:size(GMmask,3)
    GMMASK(:,:,iSlice)   = GMmask(:,:,iSlice)>(0.6 *max(max(GMmask(:,:,iSlice))));
    WMMASK(:,:,iSlice)   = WMmask(:,:,iSlice)>(0.8 *max(max(WMmask(:,:,iSlice))));
    WMMASK(:,:,iSlice)   = imerode(WMMASK(:,:,iSlice),strel('disk',5));
 end

GMMASK  = GMMASK.*(BMASK>0.8);
GMMASK  = logical(GMMASK);
GMMASK(:,:,1:29)    = 0;

WMMASK  = WMMASK.*(BMASK>0.8);
WMMASK  = logical(WMMASK);
WMMASK(:,:,1:29)    = 0;

ROOT_OUTPUTDIR   = 'C:\Backup\ASL\GENFI\Inter-vendor_Paper\Inter-vendor_analysis';

jet_256         = jet(256);
jet_256(1,:)    = 0;

% Create MNI ROIs
piet{1}         = GMMASK;
GMMASK          = piet;
clear piet

PermList12     = UniquePartialPermutations([1:1:12]);
PermList48     = UniquePartialPermutations([1:1:48]);

% MNI_large_load                             = fullfile( 'C:\ASL_pipeline_HJ\Maps', 'rMNI_large_ROI_maps.nii');
% MNI_large                                  = xASL_nifti( MNI_large_load);
% NextN                                      = 2;
% for iMask=[3 4 8 6] % frontal insular temporal parietal
%     GMMASK{NextN}                          = logical( single(GMMASK{1}) .* xASL_im_rotate(single(MNI_large.dat(:,:,:,iMask))>0,90) );
%     NextN                                  = NextN+1;
% end

% dip_image([GMMASK{1} GMMASK{2} GMMASK{3} GMMASK{4} GMMASK{5}])

%% 1) Load files

ROOT    = 'C:\Backup\ASL\GENFI\Inter-vendor_Paper\Inter-vendor';
% RegCat  = { 'M0_T1_NOMASK'};
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'}; % first two vendors, to save memory
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

iRChoice        = [1 2 4 5];
iVChoice        = [1 2 3 4];
iV5orNot{1}     = 1:4;
iV5orNot{2}     = 5;

for iV5=1:2
    for iC=1:length(iRChoice)
        iRLoop      = iRChoice(iC);

        if      iRLoop>3
                iDChoice=[1 3];
        else    iDChoice=1;        
        end

        for iDL=1:length(iDChoice)
            iDLoop = iDChoice(iDL);

            clear TOTALIM

            for iR=iRLoop   % 1:length(RegCat)
                for iV=1:length(Vendors)
            %         if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
                    if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=[1 3];else;iD_length=[1];end

                    for iD=iDLoop % iD_length
                        FDIR    = fullfile( ROOT, RegCat{iR }, Vendors{iV}, 'dartel', DegFree{iD});
                        FLIST   = xASL_adm_GetFileList( FDIR, '^qCBF_(C9ORF|MAPT|GRN)\d{3}\.(nii|nii\.gz)$');
                        for iN=1:12
                            FILELOAD    = xASL_nifti(FLIST{iN});
                            TOTALIM{iR}{iV}{iD}(:,:,:,iN)    = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
                        end
                    end
                end
            end


            %% Mask & normalize per sequence
            BMASK12     = repmat(bMASK,[1 1 1 12]);
            GMMASK12    = repmat(GMMASK{1},[1 1 1 12]);

            for iR=iRLoop   % 1:length(TOTALIM)
                if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=[1 3];else;iD_length=[1];end

                for iV=1:length(TOTALIM{iR})
                    for iD=iDLoop % iD_length % 1:length(TOTALIM{iR}{iV})
                        % Mask
                        TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}.*BMASK12;
                        % Normalize all per sequence
                        meanInt                 = xASL_stat_MeanNan( TOTALIM{iR}{iV}{iD}(GMMASK12));
                        TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}./meanInt.*50;
                        clear meanInt            
                    end
                end
            end


            for iR=iRLoop % 1:length(TOTALIM)
                if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=[1 3];else;iD_length=[1];end

                for iV=1:length(TOTALIM{iR})
                    for iD=iDLoop % iD_length % 1:length(TOTALIM{iR}{iV})
                        % Remove Nans
                        TOTALIM{iR}{iV}{iD}(isnan(TOTALIM{iR}{iV}{iD}))     = 0;
                    end
                end
            end

            clear BMASK12 GMMASK12

            %% Significant inter-sequence difference
            % OUTPUTDIR               = fullfile( ROOT_OUTPUTDIR, '5-7. MainFigure', 'SignificantDiff');
            % xASL_adm_CreateDir(OUTPUTDIR);
            % 
            % slicesLarge             = [53 62 72 87];
            % 
            % for iR=1:length(TOTALIM)
            %     clear SLICE lengthSlice
            %     
            %     if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
            %     
            %         for iD=1:iD_length
            %             clear SLICEPRINT
            %             
            %             for iX=1:size(squeeze( TOTALIM{iR}{1}{iD}(:,:,72,:) ),1)
            %                 for iY=1:size(squeeze( TOTALIM{iR}{1}{iD}(:,:,72,:) ),2)
            %                     [p anovatab stats]  = kruskalwallis( [squeeze( TOTALIM{iR}{1}{iD}(iX,iY,72,:) ) squeeze( TOTALIM{iR}{2}{iD}(iX,iY,72,:) ) squeeze( TOTALIM{iR}{3}{iD}(iX,iY,72,:) ) squeeze( TOTALIM{iR}{4}{iD}(iX,iY,72,:) ) ], [], 'off' );
            %                     if  p<0.001
            %                         CHI_SQR{iR}{iD}(iX,iY)  = anovatab{2,5};
            %                     else
            %                         CHI_SQR{iR}{iD}(iX,iY)  = 0;
            %                     end
            %                 end
            %             end
            %         end
            %         
            % for iR=1:length(TOTALIM)        
            %     if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
            %         for iD=1:iD_length
            %         
            %         close all
            %         fig = figure('Visible','off'); figure(1)
            %         imshow(CHI_SQR{iR}{iD},[10 35],'border','tight','Colormap',jet_256,'InitialMagnification',200);
            %         colorbar;
            % %         print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,['ChiSq_' RegCat{iR} '_' DegFree{iD} '.jpg']));
            %         print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,['ChiSq_' RegCat{iR} '_' DegFree{iD} '.eps']));
            %         end
            % end    




            %% Visualization single-subject CBF
            % Get Figure per vendor to check
            % First scroll through, then print overview of slice 72
            % 
            % OUTPUTDIR               = fullfile( ROOT_OUTPUTDIR, 'OverviewAll');
            % 
            % slicesLarge             = [53 62 72 87];
            % 
            % for iR=1:length(TOTALIM)
            %     clear SLICE lengthSlice
            %     
            %     if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
            %     
            %     for iV=1:4
            %         for iD=1:iD_length
            %             clear SLICEPRINT
            %             SLICEPRINT{1}  = singlesequencesort( squeeze( TOTALIM{iR}{iV}{iD}(:,:,53,:) ), 4);
            %             SLICEPRINT{2}  = singlesequencesort( squeeze( TOTALIM{iR}{iV}{iD}(:,:,62,:) ), 4);
            %             SLICEPRINT{3}  = singlesequencesort( squeeze( TOTALIM{iR}{iV}{iD}(:,:,72,:) ), 4);
            %             SLICEPRINT{4}  = singlesequencesort( squeeze( TOTALIM{iR}{iV}{iD}(:,:,87,:) ), 4);
            %                 
            %             SLICEPRINT      = [SLICEPRINT{1} SLICEPRINT{2}; SLICEPRINT{3} SLICEPRINT{4}];
            %             
            %             close all
            %             fig = figure('Visible','off');
            %             imshow(SLICEPRINT,[0 90],'border','tight');
            %             print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_' Vendors{iV} '_' DegFree{iD} '.jpg']));
            %         end
            %     end
            % end



            %% Regrid data to put all vendors together in 5th (total) group

            if iV5==2
                % Regrid images
                for iV=1:4
                    for iR=iRLoop % 1:length(TOTALIM)

                %         if ~isempty(strfind(RegCat{iR},'PWI_pGM'));iD_length=3;else;iD_length=1;end
                        if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=[1 3];else;iD_length=[1];end

                        for iD=iDLoop % iD_length % 1:iD_length        
                            TOTALIM{iR}{5}{iD}(:,:,:,(iV-1)*12+1:iV*12)     = TOTALIM{iR}{iV}{iD};
                            TOTALIM{iR}{iV}{iD}                             = 0;
                        end
                    end
                end

                for iV=1:4
                    for iR=iRLoop
                        TOTALIM{iR}{iV}  = 1;
                    end
                end
            end
            
            % 
            % % dip_image(squeeze(TOTALIM{3}{5}{1}(:,:,52,:)))
            % % dip_image([mean(TOTALIM{1}{5}{1},4)./std(TOTALIM{1}{5}{1},[],4) mean(TOTALIM{3}{5}{1},4)./std(TOTALIM{3}{5}{1},[],4)])



            %% Visualization mean CBF
            % Get Figure for all vendors
            % 
            % OUTPUTDIR               = fullfile( ROOT_OUTPUTDIR, 'MainFigure');
            % 
            % for iR=1:length(TOTALIM)
            %     clear SLICE lengthSlice
            % 
            %     if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
            %     
            %     for iD=1:iD_length
            %         AllVendorSlice     = (xASL_stat_MeanNan(TOTALIM{iR}{1}{iD}(:,:,72,:),4) + xASL_stat_MeanNan(TOTALIM{iR}{2}{iD}(:,:,72,:),4) + xASL_stat_MeanNan(TOTALIM{iR}{3}{iD}(:,:,72,:),4) + xASL_stat_MeanNan(TOTALIM{iR}{4}{iD}(:,:,72,:),4))./4;
            % %         SLICE(:,:,iSlice)  = [xASL_stat_MeanNan(TOTALIM{iR}{1}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{2}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{3}{iSlice}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{4}{iSlice}(:,:,72,:),4)];
            %         SLICE(:,:,iD)      = [xASL_stat_MeanNan(TOTALIM{iR}{1}{iD}(:,:,72,:),4).*1.14 xASL_stat_MeanNan(TOTALIM{iR}{2}{iD}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{3}{iD}(:,:,72,:),4) xASL_stat_MeanNan(TOTALIM{iR}{4}{iD}(:,:,72,:),4) AllVendorSlice];
            %     end
            % 
            % %     slicesLarge             = [53 62 74 87];
            % % 
            % %     for iSlice=1:length(slicesLarge)
            % %         IMSHOWTOTAL(:,:,iSlice)     = MEANim(:,:,slicesLarge(iSlice));
            % %     end
            % % 
            % %     IMSHOWTOTAL2(:,:,iD)    = singlesequencesort(IMSHOWTOTAL,4);
            % %     clear IMSHOWTOTAL    
            %     
            %     
            %     close all
            % %     figure(1);imshow(singlesequencesort(SLICE,1),[0 90]);
            % %     print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_meanVendor_gray.eps']));
            %     figure(1);imshow(singlesequencesort(SLICE,1),[0 90],'Colormap',jet_256);
            %     print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} 'meanVendor_color.eps']));
            %     
            % %     figure(1);imshow(singlesequencesort(SLICE,1),[0 90],'Colormap',jet_256);
            % %     print(gcf,'-djpeg','-r300',fullfile(OUTPUTDIR,[RegCat{iR} 'meanVendor_color.jpg']));
            % 
            % 
            %     clear SLICE AllVendorSlice
            % end


            %% Subject-wise stats: get TC & Pearson correlation coefficient
            %  Change this next time, to create map only of best option (BET PWI), save
            %  RAM otherwise by only creating list of values within GM mask

            clear TCmap

            for iR=iRLoop % 1:length(TOTALIM)

            %     if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
                if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=[1 3];else;iD_length=[1];end

                for iD=iDLoop % iD_length % 1:iD_length
                    iD
                    for iV=iV5orNot{iV5}

                        if  iV==5
                            PermList    = PermList48;
                        else
                            PermList    = PermList12;
                        end


                        %% Get TC
                        for iPerm=1:length(PermList)
                            IM1                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,1));
                            IM2                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,2));
                            MASK                = bMASK & isfinite(IM1) & isfinite(IM2) & IM1>0  & IM2>0;
                            TESTTEMP(:,:,:,1)   = IM1.*single(MASK);
                            TESTTEMP(:,:,:,2)   = IM2.*single(MASK);

                            CorrTemp            = corrcoef(nonzeros(TESTTEMP(:,:,:,1)),nonzeros(TESTTEMP(:,:,:,2)),'rows','complete');
                            CorrPerm{iR}{iD}{iV}(iPerm,1)   = CorrTemp(1,2);
                            TC                  = min(TESTTEMP,[],4)./max(TESTTEMP,[],4);

                            TCmap{iR}{iD}{iV}(:,:,:,iPerm)          = TC;

                            clear CorrTemp TESTTEMP TC IM1 IM2 MASK
                        end

                    end
                end
            end

            clear TC X N
            for iR=iRLoop % 1:length(TOTALIM)

            %     if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
                if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=[1 3];else;iD_length=[1];end

                for iD=iDLoop % iD_length % 1:iD_length
                    iD
                    for iV=iV5orNot{iV5} % 1:length(TOTALIM{iR})

                        if  iV==5
                            PermList    = PermList48;
                        else
                            PermList    = PermList12;
                        end

                        %% Get corr_coef & TC
                        for iMask=1:length(GMMASK)
                            for iPerm=1:length(PermList)
                                TC                                                          = TCmap{iR}{iD}{iV}(:,:,:,iPerm);
                                TCoeff{iR}{iD}{iV}(iPerm,iMask)                             = median(TC(isfinite(TC) & GMMASK{iMask} ));

                                [X{iR}{iD}{iV}(:,iPerm,iMask) N{iR}{iD}{iV}(:,iPerm,iMask)] = hist(TC(isfinite(TC)  & GMMASK{iMask} )  ,25);
                                X{iR}{iD}{iV}(:,iPerm,iMask)                                = X{iR}{iD}{iV}(:,iPerm,iMask)./sum(X{iR}{iD}{iV}(:,iPerm,iMask));
                                clear TC
                            end

                            TCoeffMedian(iD,iV,iR,:,iMask)        = xASL_stat_MedianNan(TCoeff{iR}{iD}{iV}(:,iMask),1);
                            TCoeffMAD(iD,iV,iR,:,iMask)           = xASL_stat_MadNan(TCoeff{iR}{iD}{iV}(:,iMask),[],1);
                            CorrMedian(iD,iV,iR)                  = xASL_stat_MedianNan(CorrPerm{iR}{iD}{iV});
                            CorrMAD(iD,iV,iR)                     = xASL_stat_MadNan(CorrPerm{iR}{iD}{iV});
                        end
                    end
                end
            end
        end
    end
end


TCoeffMedian    = round(TCoeffMedian.*1000)./10;
TCoeffMAD       = round(TCoeffMAD.*1000)./10;
CorrMedian      = round(CorrMedian.*100)./100;
CorrMAD         = round(CorrMAD.*100)./100;

File60          = 'C:\Backup\ASL\GENFI\Inter-vendor_Paper\Inter-vendor_analysis\SC_Data_pGM_0.6.mat';
File25          = 'C:\Backup\ASL\GENFI\Inter-vendor_Paper\Inter-vendor_analysis\SC_Data_pGM_0.25.mat';

% save(File60 ,'TCoeffMedian','TCoeffMAD','CorrMedian','CorrMAD','TCoeff','CorrPerm');
% save(File25 ,'TCoeffMedian','TCoeffMAD','CorrMedian','CorrMAD','TCoeff','CorrPerm');
clear TCoeffMedian TCoeffMAD CorrMedian CorrMAD TCoeff CorrPerm
load(File25);


%% total GM frontal insular temporal parietal
% RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
% Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};
% DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

GEcoeffGM           = nonzeros(squeeze(TCoeffMedian(:,5,:,:,:)))
PHcoeffGM           = nonzeros(squeeze(TCoeffMedian(:,5,:,:,1)))
PHcoeffGM           = nonzeros(squeeze(TCoeffMedian(:,3,:,:,1)))
SIcoeffGM           = nonzeros(squeeze(TCoeffMedian(:,4,:,:,1)))
GEcoeffGM           = nonzeros(squeeze(TCoeffMAD(:,5,:,:,:)))
PHcoeffGM           = nonzeros(squeeze(TCoeffMAD(:,5,:,:,1)))
PHcoeffGM           = nonzeros(squeeze(TCoeffMAD(:,5,:,:,5)))
SIcoeffGM           = nonzeros(squeeze(TCoeffMAD(:,4,:,:,5)))

mapGE               = xASL_stat_MedianNan((TCmap{5}{1}{5}),4);
mapPH               = xASL_stat_MedianNan((TCmap{2}{1}{5}),4);


figure(1);imshow(mapGE(:,:,53),[],'Colormap',jet_256)
figure(2);imshow(mapPH(:,:,53),[],'Colormap',jet_256)

% Get TC histograms
VENDORNAME  = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'AllTogether'};
OUTPUTDIR       = fullfile(ROOT_OUTPUTDIR, 'TC_Histograms');

% Create TC histograms
for iR=6 % PWI only
    for iV=5 %1:length(TOTALIM{iR})
        for iMask=1 % :length(GMMASK)
            
            if      iV==5
                    figure(1);plot(mean(N{iR}{1}{iV}(:,:,iMask),2),mean(X{iR}{1}{iV}(:,:,iMask),2),'r');
            else
                    figure(1);plot(mean(N{iR-3}{1}{iV}(:,:,iMask),2),mean(X{iR-3}{1}{iV}(:,:,iMask),2),'r--',mean(N{iR}{1}{iV}(:,:,iMask),2),mean(X{iR}{1}{iV}(:,:,iMask),2),'r',mean(N{iR}{2}{iV}(:,:,iMask),2),mean(X{iR}{2}{iV}(:,:,iMask),2),'k',mean(N{iR}{3}{iV}(:,:,iMask),2),mean(X{iR}{3}{iV}(:,:,iMask),2),'g');
            end
                    
            axis([0 1 0 0.08]);

            print(gcf,'-djpeg','-r300',fullfile( OUTPUTDIR, [RegCat{iR} '_' VENDORNAME{iV} '_mask' num2str(iMask) '.jpg']));
            print(gcf,'-depsc','-r300',fullfile( OUTPUTDIR, [RegCat{iR} '_' VENDORNAME{iV} '_mask' num2str(iMask) '.eps']));

            close all
        end
    end
end

%% Kruskal-Wallis
% The t-stat or Chi-square stat linearly scales with number of subjects

for iV=1:length(TOTALIM{1})
    for iR=1:length(TOTALIM)
%         % For T1-approach
%         iR=1;
        [p anovatab stats]  = kruskalwallis( [TCoeff{iR}{1}{iV} TCoeff{iR}{2}{iV} ] );
        CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR}{1}{iV})/48)
        p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

%         % For pGM-approach
%         iR=3;
        % p   = kruskalwallis( [TCoeff{iR}{1}{iV}(1:48) TCoeff{iR}{2}{iV}(1:48) TCoeff{iR}{3}{iV}(1:48)] );
        [p anovatab stats]  = kruskalwallis( [TCoeff{iR}{1}{iV} TCoeff{iR}{2}{iV} TCoeff{iR}{3}{iV}] );
        CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR}{1}{iV})/48);
        p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

        % For all together
        [p anovatab stats]  = kruskalwallis( [TCoeff{1}{1}{iV} TCoeff{1}{2}{iV}   TCoeff{3}{1}{iV} TCoeff{3}{2}{iV} TCoeff{3}{3}{iV}] );
        CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR}{1}{iV})/48);
        p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);
    end
end


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



% images % transformation % vendor
%% For editor comment, checked the MAD of the differences between registration strategies.
% However, the median-median is not the same as doing pairwise difference &
% taking the median of that. The first was done when we submitted the
% paper, so I left it this way. And added the MAD of the pairwise
% differences.

% RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
% Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'}; % first two vendors, to save memory
% DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};


close all
iR1=4;
iR2=4;
iD1=1;
iD2=3;
iV1=4;
iV2=4;

if      iV1==5 && iV2==5
        nCorr   = 48;
else    nCorr   = 12;
end

piet=(CorrPerm{iR2}{iD2}{iV2} - CorrPerm{iR1}{iD1}{iV1})./((CorrPerm{iR1}{iD1}{iV1}+CorrPerm{iR2}{iD2}{iV2}).*0.5);
% piet(piet>1)=NaN;
% piet(piet<0)=NaN;

MedPiet     = median(piet(~isnan(piet)))
MadPiet     = xASL_stat_MadNan(piet,1)
% % % % piet(piet<MedPiet-4*MadPiet)    = MedPiet-4*MadPiet;
% % % % piet(piet>MedPiet+4*MadPiet)    = MedPiet+4*MadPiet;
% % % % 
% % % % MedPiet
% % % % MadPiet
% % % % MedPiet-2.9*xASL_stat_MadNan(piet,1)
% % % % MedPiet+2.9*xASL_stat_MadNan(piet,1)
% 
% MedPiet-2.5*MadPiet
% MedPiet+2.5*MadPiet

% % % median(TCoeff{iR2}{iD2}{iV2})/median(TCoeff{iR1}{iD1}{iV1})
% % % clear p anovatab stats CHI_SQR_CORRECTED
% % % [p anovatab stats]  = kruskalwallis( [TCoeff{iR2}{iD2}{iV2} TCoeff{iR1}{iD1}{iV1}] );
% % % CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(TCoeff{iR1}{iD1}{iV1})/48);
% % % p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

clear p anovatab stats CHI_SQR_CORRECTED
[p anovatab stats]  = kruskalwallis( [CorrPerm{iR2}{iD2}{iV2} CorrPerm{iR1}{iD1}{iV1}] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length(CorrPerm{iR1}{iD1}{iV1})/nCorr);
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
close all


% [p h stats]         = signtest(CorrPerm{iR2}{iD2}{iV2},CorrPerm{iR1}{iD1}{iV1});
[p h stats]         = ranksum(CorrPerm{iR2}{iD2}{iV2},CorrPerm{iR1}{iD1}{iV1},'method','approximate');
zval                = stats.zval/(length(CorrPerm{iR1}{iD1}{iV1})^0.5/nCorr^0.5);
TwoTailed           = (1-normcdf(zval,0,1))

% statsMWW            = mwwtest(CorrPerm{iR2}{iD2}{iV2},CorrPerm{iR1}{iD1}{iV1})
% 
% [h,p,ci,stats]      = ttestExploreASL(CorrPerm{iR2}{iD2}{iV2},CorrPerm{iR1}{iD1}{iV1});

% p = 1-tcdf(stats.tstat/(nCorr^0.5),nCorr-1)

%% For estimation resolution, GM-WM CBF ratio, on CBF-pGM registration

%% 1) Load files
ROOT    = 'C:\Backup\ASL\GENFI\Inter-vendor_Paper\Inter-vendor';
% RegCat  = { 'M0_T1_NOMASK'};
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'}; % first two vendors, to save memory
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

iR=4;
iD=1;
iV=1;

for iR=4
    for iV=1:length(Vendors)
        if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
        
        for iD=1
            FDIR    = fullfile( ROOT, RegCat{iR }, Vendors{iV}, 'dartel', DegFree{iD});
            FLIST   = xASL_adm_GetFileList( FDIR, '^qCBF_(C9ORF|MAPT|GRN)\d{3}\.(nii|nii\.gz)$');
            for iN=1:12
                FILELOAD    = xASL_nifti(FLIST{iN});
                TOTALIM{iR}{iV}{iD}(:,:,:,iN)    = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
            end
        end
    end
end

% Obtain GM-WM CBF ratios

for iV=1:4
    for iIM=1:size(TOTALIM{4}{iV}{1},4)
        tempIM              = TOTALIM{4}{iV}{1}(:,:,:,iIM);
        GMcbf(iIM,iV)       = mean(tempIM(isfinite(tempIM) & tempIM>0 & GMMASK{1}));
        WMcbf(iIM,iV)       = mean(tempIM(isfinite(tempIM) & tempIM>0 & WMMASK));
        CbfRatio(iIM,iV)    = GMcbf(iIM,iV)/WMcbf(iIM,iV);
    end
end

ScaleSlope  = 1./(mean(GMcbf,1)./60);
%         
% dip_image(TOTALIM{4}{3}{1}(:,:,:,12))     

meanRatio   = median(CbfRatio,1)
StdRatio    = xASL_stat_MadNan(CbfRatio,[],1)

% Obtain graphs in-plane
LineROI     = zeros(size(GMMASK{1}));
Z=75;
Y=67;
X=15:105;
LineROI(Y,X,Z)=1;

% dip_image(GMMASK{1}+LineROI)
clear ROIcbf
for iV=1:4
    for iIM=1:size(TOTALIM{4}{iV}{1},4)
        tempIM              = TOTALIM{4}{iV}{1}(:,:,:,iIM);
        ROIcbf(iIM,:,iV)    = tempIM(logical(LineROI));
    end
end

meanROI     = squeeze(mean(ROIcbf,1));
for iV=1:4
    meanROI(:,iV)   = meanROI(:,iV).*ScaleSlope(iV);
end

figure(1);plot([1:91],meanROI(:,1).*1.2,'r',[1:91],meanROI(:,2).*1.05,'b',[1:91],meanROI(:,3),'k',[1:91],meanROI(:,4).*0.9,'g')
title('GM-WM CBF contrast. Red=3D spiral, Blue=2D EPI Bsup, Black=2D EPI noBsup, Green=3D GRASE');
xlabel('Voxel position left/right direction');
ylabel('mean CBF (mL/100g/min (n=12 each sequence)');

% Obtain graphs through-plane
LineROI     = zeros(size(GMMASK{1}));
Z=60:90;
Y=63;
X=85;
LineROI(Y,X,Z)=1;

% dip_image(GMMASK{1}+LineROI)
clear ROIcbf
for iV=1:4
    for iIM=1:size(TOTALIM{4}{iV}{1},4)
        tempIM              = TOTALIM{4}{iV}{1}(:,:,:,iIM);
        ROIcbf(iIM,:,iV)    = tempIM(logical(LineROI));
    end
end

meanROI     = squeeze(mean(ROIcbf,1));
for iV=1:4
    meanROI(:,iV)   = meanROI(:,iV).*ScaleSlope(iV);
end

figure(1);plot([1:31],meanROI(:,1).*1.25,'r',[1:31],meanROI(:,2).*0.8,'b',[1:31],meanROI(:,3).*1.25,'k',[1:31],meanROI(:,4).*0.95,'g')
title('GM-WM CBF contrast. Red=3D spiral, Blue=2D EPI Bsup, Black=2D EPI noBsup, Green=3D GRASE');
xlabel('Voxel position inferior/superior direction');
ylabel('mean CBF (mL/100g/min (n=12 each sequence)');
