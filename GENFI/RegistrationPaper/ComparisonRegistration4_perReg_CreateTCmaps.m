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

%% 1) Load names
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor';
% RegCat  = { 'M0_T1_NOMASK'};
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI'}; % first two vendors, to save memory
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

for iR=1:length(RegCat)


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
        for iR=1:length(TOTALIM)

            if ~isempty(strfind(RegCat{iR},'PWI_pGM'));iD_length=3;else;iD_length=1;end

            for iD=1:iD_length
                TOTALIM{iR}{5}{iD}(:,:,:,(iV-1)*12+1:iV*12)     = TOTALIM{iR}{iV}{iD};
%                 TOTALIM{iR}{iV}{iD}                             = 0;
            end
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


            %% Get TC
            for iPerm=1:length(PermList)
                IM1                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,1));
                IM2                 = TOTALIM{iR}{iV}{iD}(:,:,:,PermList(iPerm,2));
                MASK                = bMASK & isfinite(IM1) & isfinite(IM2) & IM1>0  & IM2>0;
                TESTTEMP(:,:,:,1)   = IM1.*single(MASK);
                TESTTEMP(:,:,:,2)   = IM2.*single(MASK);

                TC                  = min(TESTTEMP,[],4)./max(TESTTEMP,[],4);

                TCmap{iR}{iD}{iV}(:,:,:,iPerm)          = TC;

                clear CorrTemp TESTTEMP TC IM1 IM2 MASK
            end

            RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
            VendorsName = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'Multi-vendor'};
            DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

            MedianTC_map            = xASL_stat_MedianNan( TCmap{iR}{iD}{iV} ,4);
            MedianTC_map            = xASL_im_rotate(MedianTC_map,270);
            SaveFile                = fullfile( ROOT_OUTPUTDIR, 'TCmaps', [RegCat{iR} '_' DegFree{iD} '_' VendorsName{iV} '.nii']);
            OriFile                 = 'C:\ASL_pipeline_HJ\Maps\rbrainmask.nii';
            xASL_io_SaveNifti( OriFile, SaveFile, MedianTC_map );
            clear MedianTC_map SaveFile
            TCmap{iR}{iD}{iV}       = 0;
        end
    end
end

%% Create histograms for pGM
RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
VendorsName = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'Multi-vendor'};
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};

MASK    = logical(bMASK);
pGMn    = GMmask(MASK);

for iR=[1 4] %1:length(RegCat)
    for iV=1:5
        if ~isempty(strfind(RegCat{iR },'PWI_pGM'));iD_length=3;else;iD_length=1;end

        for iD=1:iD_length
            clear SaveFile SCmap CBFn
            SaveFile                = fullfile( ROOT_OUTPUTDIR, '10. TCmaps', [RegCat{iR} '_' DegFree{iD} '_' VendorsName{iV} '.nii']);
            SCmap                   = xASL_nifti(SaveFile);
            SCmap                   = SCmap.dat(:,:,:);

            % Get numbers within mask
            CBFn    = SCmap(MASK);

            if  max(size(pGMn)~=size(CBFn))>0
                error('not same size');
            end

            clear BinN BinSize MASKn

            BinN        = 25;
            BinSize     = 1/BinN;
            X{iR}{iV}{iD}           = [0:BinSize:1];

            for iBin=1:BinN
                MASKn       = pGMn>X{iR}{iV}{iD}(iBin) & pGMn<X{iR}{iV}{iD}(iBin+1);
                Y{iR}{iV}{iD}(iBin)     = mean(CBFn(MASKn & isfinite(CBFn)));
            end

            X{iR}{iV}{iD}   = X{iR}{iV}{iD}(2:end);

            figure(3);plot(X{iR}{iV}{iD},Y{iR}{iV}{iD})
            axis([0 1 0.5 0.85]);
            SaveFile                = fullfile( ROOT_OUTPUTDIR, '10. TCmaps', 'PV_hist', [RegCat{iR} '_' DegFree{iD} '_' VendorsName{iV} '.eps']);
            print(gcf,'-depsc','-r300', SaveFile);
        end
    end
end

for iV=1:5
    figure(3);plot(X{1}{iV}{1},Y{1}{iV}{1},'b',X{4}{iV}{1},Y{4}{iV}{1},'r',X{4}{iV}{2},Y{4}{iV}{2},'k',X{4}{iV}{3},Y{4}{iV}{3},'g')
    axis([0 1 0.5 0.85]);
    SaveFile                = fullfile( ROOT_OUTPUTDIR, '10. TCmaps', 'PV_hist', [VendorsName{iV} '.eps']);
    print(gcf,'-depsc','-r300', SaveFile);
end


%
%                 [X N]   = hist(nonzeros(GMmask));
%                 figure(1);plot(N,X)
%
%
%                 [X N]   = hist(nonzeros(SCmap(logical(bMASK))));
%                 figure(2);plot(N,X)





%% Load all maps



%% Rescale MNI GM map to 0 - 1
% then create bins. This map is more continuous/smooth than the
% population map
