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

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis\TCmaps';

RegCat  = { 'M0_T1_NOMASK' 'M0_T1_BETMASK' 'M0_T1_PWIMASK' 'PWI_pGM_NOMASK' 'PWI_pGM_BETMASK' 'PWI_pGM_PWIMASK' 'NoReg'};
Vendors = {'GE' 'PHBsup' 'PHnonBsup' 'SI' 'Multi-vendor'};
DegFree = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};


%% 1) Load files

clear TOTALIM
for iV=1:length(Vendors)
    iR=4;
    iD=1;

    FNAME                   = fullfile( ROOT, [RegCat{iR} '_' DegFree{iD} '_' Vendors{iV} '.nii'] );
    FILELOAD                = xASL_nifti( FNAME );
    IMLOAD                  = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
    slicesLarge             = [53 62 72 87];
    for iS=1:4
        TOTALIM{iV}(:,:,iS) = IMLOAD(:,:,slicesLarge(iS) );
    end
    TOTALIM{iV}             = singlesequencesort(TOTALIM{iV},1);
end

SLICE                       = [TOTALIM{1} TOTALIM{2} TOTALIM{3} TOTALIM{4} TOTALIM{5}];


close all
%     figure(1);imshow(singlesequencesort(SLICE,1),[0 90]);
%     print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_meanVendor_gray.eps']));
figure(1);imshow( SLICE ,[],'Colormap',jet_256);
print(gcf,'-depsc','-r300',fullfile(ROOT,['rigid-body.eps']));

clear TOTALIM
for iV=1:length(Vendors)
    iR=4;
    iD=3;

    FNAME                   = fullfile( ROOT, [RegCat{iR} '_' DegFree{iD} '_' Vendors{iV} '.nii'] );
    FILELOAD                = xASL_nifti( FNAME );
    IMLOAD                  = xASL_im_rotate(FILELOAD.dat(:,:,:),90);
    slicesLarge             = [53 62 72 87];
    for iS=1:4
        TOTALIM{iV}(:,:,iS) = IMLOAD(:,:,slicesLarge(iS) );
    end
    TOTALIM{iV}             = singlesequencesort(TOTALIM{iV},1);
end

SLICE                       = [TOTALIM{1} TOTALIM{2} TOTALIM{3} TOTALIM{4} TOTALIM{5}];


close all
%     figure(1);imshow(singlesequencesort(SLICE,1),[0 90]);
%     print(gcf,'-depsc','-r300',fullfile(OUTPUTDIR,[RegCat{iR} '_meanVendor_gray.eps']));
figure(1);imshow( SLICE ,[],'Colormap',jet_256);
print(gcf,'-depsc','-r300',fullfile(ROOT,['DARTEL.eps']));

