%% Admin

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

%% Create vascular maps for regional labeling efficiency normalization
% Following analyses were with maps stored in:
% 'C:\ASL_pipeline_HJ\Manual_correction\Novice\CreationLabelingTerritories'

ORImap  = 'C:\ASL_pipeline_HJ\Maps\vascRegionsAlternative.nii';
ORImap  = xASL_io_ReadNifti(ORImap);
IM      = ORImap.dat(:,:,:);

IM(IM==1 | IM==3)  = 1;
IM(IM==2 | IM==4)  = 2;
IM(IM==5 | IM==6 | IM==7 | IM==8)  = 3;

dip_image(IM)

ORIim   = IM;

IM  = imdilate(IM,strel('disk',16));

dip_image(IM)

IMnew           = ORIim;
IMnew(IMnew==0) = IM(IMnew==0);

dip_image(IMnew)
dip_image(ORIim)

% 1 & 2 against 3 needs to be come 3
% remove GM, then dilate subcortical regions
% dilate GM

xASL_io_SaveNifti( ORImap, 'c:\ORImap.nii', IM );

MASK1       = 'C:\MASK3Mask.nii';
MASK        = xASL_io_ReadNifti(MASK1);
MASK        = MASK.dat(:,:,:);

dip_image(MASK)

IM  = ORIim;
IM(logical(MASK))    = 3;

% Load cortical mask
m1  = 'C:\ASL_pipeline_HJ\Maps\r_vasc_ant_L.nii';
m2  = 'C:\ASL_pipeline_HJ\Maps\r_vasc_ant_R.nii';
m3  = 'C:\ASL_pipeline_HJ\Maps\r_vasc_mid_L.nii';
m4  = 'C:\ASL_pipeline_HJ\Maps\r_vasc_mid_R.nii';
m5  = 'C:\ASL_pipeline_HJ\Maps\r_vasc_pos_L.nii';
m6  = 'C:\ASL_pipeline_HJ\Maps\r_vasc_pos_R.nii';

m1  = xASL_io_ReadNifti(m1);
m2  = xASL_io_ReadNifti(m2);
m3  = xASL_io_ReadNifti(m3);
m4  = xASL_io_ReadNifti(m4);
m5  = xASL_io_ReadNifti(m5);
m6  = xASL_io_ReadNifti(m6);

cortVasc    = m1.dat(:,:,:) + m2.dat(:,:,:) + m3.dat(:,:,:) + m4.dat(:,:,:) + m5.dat(:,:,:) + m6.dat(:,:,:);
dip_image(cortVasc + IM)


IM2     = logical(IM) & ~logical(cortVasc);

IM2(:,:,1:40)   = 0;
IM2(:,:,66:end)   = 0;

xASL_io_SaveNifti( ORImap, 'c:\ORImap.nii', IM );

nuclei  = 'c:\nuclei.nii';
nuclei  = xASL_io_ReadNifti(nuclei);
nuclei  = nuclei.dat(:,:,:);

nucleiIM    = nuclei.*IM;
nucleiIM2   = imdilate(nucleiIM,strel('disk',16));

dip_image(nucleiIM2)

IM(IM==0)   = nucleiIM2(IM==0);

dip_image(IM)
dip_image(imdilate(nucleiIM,strel('disk',16))+nucleiIM)

% Dilated nuclei
IM1             = imdilate(nucleiIM==1,strel('disk',512));
IM2             = imdilate(nucleiIM==2,strel('disk',512));
IM3             = imdilate(nucleiIM==3,strel('disk',512));

IM1(1:60,:,:)   = 0;
IM2(61:end,:,:) = 0;
IM3(:,70:end,:) = 0;
IM1(:,1:69,:)   = 0;
IM2(:,1:69,:)   = 0;

% Original map
NewMap  = 'C:\rORImap.nii';
NewMap  = xASL_io_ReadNifti(NewMap);
IM      = NewMap.dat(:,:,:);

IM(IM==0)       = IM3(IM==0).*3;
IM(IM==0)       = IM2(IM==0).*2;
IM(IM==0)       = IM1(IM==0).*1;

% Other regions
PseudoMap                       = zeros(121,145,121);
PseudoMap(61:end,70:end,:)      = 1;
PseudoMap( 1: 60,70:end,:)      = 2;
PseudoMap(     :, 1:69 ,1:82)   = 3;
PseudoMap(61:end,   :,83:end)   = 1;
PseudoMap( 1: 60,   :,83:end)   = 2;

IM(IM==0)       = PseudoMap(IM==0);
IM(:,:,83:end)  = PseudoMap(:,:,83:end);

dip_image(IM.*rbrainmask)
dip_image(PseudoMap.*rbrainmask)

% Brainmask

rbrainmask  = 'C:\ASL_pipeline_HJ\Maps\rbrainmask.nii';
rbrainmask  = xASL_io_ReadNifti(rbrainmask);
rbrainmask  = rbrainmask.dat(:,:,:)>0.01;

dip_image(rbrainmask)

xASL_io_SaveNifti( 'C:\ASL_pipeline_HJ\Maps\rbrainmask.nii', 'C:\VascMapNew.nii', IM .* rbrainmask)
