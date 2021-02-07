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

ROOT_OUTPUTDIR   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis';

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
% RegCat  = { 'M0_T1_NOMASK'};
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'}; % first two vendors, to save memory
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

for iR=1:length(RegCat)
    
    SaveFile    = fullfile( ROOT_OUTPUTDIR, ['SC_Data_' num2str(iR) '.mat']);
    
    if ~exist( SaveFile, 'file')
    

        for iV=1:length(Vendors)
            if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end

            for iD=1:iD_length
                FDIR    = fullfile( ROOT, RegCat{iR }, Vendors{iV}, 'dartel', DegFree{iD});
                FLIST   = xASL_adm_GetFileList( FDIR, '^qCBF_(C9ORF|MAPT|GRN)\d{3}\.(nii|nii\.gz)$');
                for iN=1:12
                    FILELOAD    = xASL_nifti(FLIST{iN});
                    TOTALIM{iR}{iV}{iD}(:,:,:,iN)    = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
                end
            end
        end

        %% Mask & normalize per sequence
        BMASK12     = repmat(bMASK,[1 1 1 12]);
        GMMASK12    = repmat(GMMASK{1},[1 1 1 12]);


        for iV=1:length(TOTALIM{iR})
            for iD=1:length(TOTALIM{iR}{iV})
                % Mask
                TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}.*BMASK12;
                % Normalize all per sequence
                meanInt                 = xASL_stat_MeanNan( TOTALIM{iR}{iV}{iD}(GMMASK12));
                TOTALIM{iR}{iV}{iD}     = TOTALIM{iR}{iV}{iD}./meanInt.*50;
                clear meanInt            
            end
        end


        for iV=1:length(TOTALIM{iR})
            for iD=1:length(TOTALIM{iR}{iV})
                % Remove Nans
                TOTALIM{iR}{iV}{iD}(isnan(TOTALIM{iR}{iV}{iD}))     = 0;
            end
        end
        clear BMASK12 GMMASK12

        %% Regrid data to put all vendors together in 5th (total) group

        % Regrid images
        for iV=1:4
                if ~isempty(strfind(RegCat{iR},'PWI_pGM'));iD_length=3;else;iD_length=1;end

                for iD=1:iD_length        
                    TOTALIM{iR}{5}{iD}(:,:,:,(iV-1)*12+1:iV*12)     = TOTALIM{iR}{iV}{iD};
    %                 TOTALIM{iR}{iV}{iD}                             = 0;
                end
        end

        %% Subject-wise stats: get TC
        %  Change this next time, to create map only of best option (BET PWI), save
        %  RAM otherwise by only creating list of values within GM mask


        PermList12     = UniquePartialPermutations([1:1:12]);
        PermList48     = UniquePartialPermutations([1:1:48]);

        clear TCoeffMean TCoeffMAD TCmap

        if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end

        for iD=1:iD_length
            iD
            for iV=1:length(TOTALIM{iR})

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

                    TC                                                          = min(TESTTEMP,[],4)./max(TESTTEMP,[],4);
%                     TCoeff{iR}{iD}{iV}(iPerm,iMask)                             = median(TC(isfinite(TC) & GMMASK{iMask} ));
%                     [X{iR}{iD}{iV}(:,iPerm,iMask) N{iR}{iD}{iV}(:,iPerm,iMask)] = hist(TC(isfinite(TC)   & GMMASK{iMask} ) ,25);
                    TCoeff{iR}{iD}{iV}(iPerm,iMask)                             = median(TC(isfinite(TC) & TC>0.5 & GMMASK{iMask} ));
                    [X{iR}{iD}{iV}(:,iPerm,iMask) N{iR}{iD}{iV}(:,iPerm,iMask)] = hist(  TC(isfinite(TC) & TC>0.5 & GMMASK{iMask} ) ,25);
                    X{iR}{iD}{iV}(:,iPerm,iMask)                                = X{iR}{iD}{iV}(:,iPerm,iMask)./sum(X{iR}{iD}{iV}(:,iPerm,iMask));
                    clear TC IM1 IM2 MASK TESTTEMP
                end
            end
        end 


        TOTALIM{iR}     = 0;
        save ( SaveFile, 'TCoeff', 'X', 'N');
    end
end

load( SaveFile );
   

% Get TC histograms
VENDORNAME  = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'AllTogether'};
OUTPUTDIR       = fullfile(ROOT_OUTPUTDIR, 'TC_Histograms');

% Create TC histograms
for iR=4:6 % PWI only
    for iV=1:length(X{iR}{1})
        for iMask=1 % :length(GMMASK)
            
            figure(1);plot(mean(N{iR-3}{1}{iV}(:,:,iMask),2),mean(X{iR-3}{1}{iV}(:,:,iMask),2),'b',mean(N{iR}{1}{iV}(:,:,iMask),2),mean(X{iR}{1}{iV}(:,:,iMask),2),'r',mean(N{iR}{2}{iV}(:,:,iMask),2),mean(X{iR}{2}{iV}(:,:,iMask),2),'k',mean(N{iR}{3}{iV}(:,:,iMask),2),mean(X{iR}{3}{iV}(:,:,iMask),2),'g');
            axis([0 1 0 0.1]);

            print(gcf,'-djpeg','-r300',fullfile( OUTPUTDIR, [RegCat{iR} '_' VENDORNAME{iV} '_mask' num2str(iMask) '.jpg']));
            print(gcf,'-depsc','-r300',fullfile( OUTPUTDIR, [RegCat{iR} '_' VENDORNAME{iV} '_mask' num2str(iMask) '.eps']));

            close all
        end
    end
end

for iR=1:7
    for iV=1:5
        for iMask=1 %:length(GMMASK)
            if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end
            for iD=1:iD_length
            
                TCoeffMedian(iD,iV,iR,:,iMask)        = xASL_stat_MedianNan(TCoeff{iR}{iD}{iV}(:,iMask),1);
                TCoeffMAD(iD,iV,iR,:,iMask)           = xASL_stat_MadNan(TCoeff{iR}{iD}{iV}(:,iMask),[],1);
                
            end
        end
    end
end

%% Differences between sequences without registration
Seq1NoRegCoeff      = TCoeff{7}{1}{1}(:,1);
Seq2NoRegCoeff      = TCoeff{7}{1}{2}(:,1);
Seq3NoRegCoeff      = TCoeff{7}{1}{3}(:,1);
Seq4NoRegCoeff      = TCoeff{7}{1}{4}(:,1);

[p anovatab stats]  = kruskalwallis( [Seq1NoRegCoeff Seq2NoRegCoeff Seq3NoRegCoeff Seq4NoRegCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( Seq1NoRegCoeff) /12)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

%% Improvement of SC by registration strategies
round(((nonzeros(TCoeffMedian(:,5,1:6))./TCoeffMedian(1,5,7))-1).*1000)./10
min(round(((nonzeros(TCoeffMedian(:,5,1:6))./TCoeffMedian(1,5,7))-1).*1000)./10)
max(round(((nonzeros(TCoeffMedian(:,5,1:6))./TCoeffMedian(1,5,7))-1).*1000)./10)

%% NoReg NoMasking vs. M0-T1 NoMasking
M0NoMaskCoeff   = TCoeff{1}{1}{5}(:,1);
NoRegCoeff      = TCoeff{7}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff NoRegCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

%% PWI-pGM NoMasking vs. M0-T1 NoMasking
round(((nonzeros(TCoeffMedian(1,:,4))./nonzeros(TCoeffMedian(1,:,1)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{1}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{4}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{1}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{4}{1}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end


%% PWI-pGM BET vs. M0-T1 BET
round(((nonzeros(TCoeffMedian(1,:,5))./nonzeros(TCoeffMedian(1,:,2)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{2}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{5}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{2}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{5}{1}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end


%% PWI-pGM MNI-masking vs. M0-T1 MNI-masking
round(((nonzeros(TCoeffMedian(1,:,6))./nonzeros(TCoeffMedian(1,:,3)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{3}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{6}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{3}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{6}{1}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end

%% M0-T1 BET-masking versus M0-T1 NoMasking
round(((nonzeros(TCoeffMedian(1,:,2))./nonzeros(TCoeffMedian(1,:,1)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{1}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{2}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{1}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{2}{1}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end

%% M0-T1 MNI-masking versus M0-T1 NoMasking
round(((nonzeros(TCoeffMedian(1,:,3))./nonzeros(TCoeffMedian(1,:,1)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{1}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{3}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{1}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{3}{1}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end

%% PWI BET-masking or MNI-masking versus PWI NoMasking
round(((nonzeros(TCoeffMedian(1,:,5))./nonzeros(TCoeffMedian(1,:,4)))-1).*1000)./10
round(((nonzeros(TCoeffMedian(1,:,6))./nonzeros(TCoeffMedian(1,:,4)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{4}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{6}{1}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{1}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{3}{1}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end

%% PWI NoMask DARTEL versus rigid-body
round(((nonzeros(TCoeffMedian(3,:,4))./nonzeros(TCoeffMedian(1,:,4)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{4}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{4}{3}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{4}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{4}{3}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end

%% PWI NoMask affine versus rigid-bodyd
round(((nonzeros(TCoeffMedian(2,:,4))./nonzeros(TCoeffMedian(1,:,4)))-1).*1000)./10

M0NoMaskCoeff   = TCoeff{4}{1}{5}(:,1);
PWINoMaskCoeff  = TCoeff{4}{2}{5}(:,1);

[p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /48)
p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2);

for ii=1:4
    clear M0NoMaskCoeff PWINoMaskCoeff p anovatab stats CHI_SQR_CORRECTED
    M0NoMaskCoeff   = TCoeff{4}{1}{ii}(:,1);
    PWINoMaskCoeff  = TCoeff{4}{2}{ii}(:,1);

    [p anovatab stats]  = kruskalwallis( [M0NoMaskCoeff PWINoMaskCoeff] );
    CHI_SQR_CORRECTED   = anovatab{2,5}/ (length( M0NoMaskCoeff) /12);
    p                   = 1-chi2cdf(CHI_SQR_CORRECTED,2)
end
