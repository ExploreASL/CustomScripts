%% RescaleVendorCBF

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
BMASK   = BMASK.dat(:,:,:);

bMASK   = BMASK>0.8;

bMASK_grad                                      = zeros(size(BMASK,1),size(BMASK,2),size(BMASK,3));
bMASK_grad(BMASK>0.8)                           = 1;
bMASK_grad(BMASK<0.85 & BMASK>0.75)             = 0.95;
bMASK_grad(BMASK<0.75 & BMASK>0.7)              = 0.9;
bMASK_grad(BMASK<0.7  & BMASK>0.65)             = 0.85;
bMASK_grad(BMASK<0.65 & BMASK>0.6)              = 0.8;
bMASK_grad(BMASK<0.6)                           = 0.8;

GMmask  = 'C:\ASL_pipeline_HJ\Maps\rgrey.nii';
GMmask  = xASL_nifti(GMmask);
GMmask  = GMmask.dat(:,:,:);

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


IM1     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\AllVendorData\dartel\DARTEL_mean_T1_template.nii';
IM1     = xASL_nifti(IM1);
IM1     = IM1.dat(:,:,:);

IM2     = 'C:\Backup\ASL\Sleep2\analysis\dartel\DARTEL_mean_T1_template.nii';
IM2     = xASL_nifti(IM2);
IM2     = IM2.dat(:,:,:);



IM1MASK     = IM1.*bMASK;
IM2MASK     = IM2.*bMASK;

IM1_outside     = IM1.*~bMASK;
IM2_outside     = IM2.*~bMASK;

sort_IM1    = sort(nonzeros(IM1_outside));
Value9      = sort_IM1(round(0.999*length(sort_IM1)));
IM1_outside(IM1_outside>Value9)     = Value9;
IM1_outside     = IM1_outside ./ max(nonzeros(IM1_outside)) .* 1500;

sort_IM2    = sort(nonzeros(IM2_outside));
Value9      = sort_IM2(round(0.999*length(sort_IM2)));
IM2_outside(IM2_outside>Value9)     = Value9;
IM2_outside     = IM2_outside ./ max(nonzeros(IM2_outside)) .* 1500;

sort_IM1    = sort(nonzeros(IM1MASK));
Value9      = sort_IM1(round(0.999*length(sort_IM1)));
IM1MASK(IM1MASK>Value9)     = Value9;
IM1MASK     = IM1MASK ./ max(nonzeros(IM1MASK)) .* 1750;

sort_IM2    = sort(nonzeros(IM2MASK));
Value9      = sort_IM2(round(0.999*length(sort_IM2)));
IM2MASK(IM2MASK>Value9)     = Value9;
IM2MASK     = IM2MASK ./ max(nonzeros(IM2MASK)) .* 1750;

IM1     = IM1MASK+IM1_outside;
IM2     = IM2MASK+IM2_outside;

IM1     = IM1.*bMASK_grad;
IM2     = IM2.*bMASK_grad;


