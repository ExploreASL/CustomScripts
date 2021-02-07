%% Create pGM_pWM brainmask

MaskN{1}    = fullfile(x.D.TemplateDir,'Cmp_rc1T1.nii');
MaskN{2}    = fullfile(x.D.TemplateDir,'Cmp_rc2T1.nii');
MaskN{3}    = fullfile(x.D.MapsDir,'rbrainmask.nii');
MaskN{4}    = fullfile(x.D.TemplateDir,'Philips_2DEPI_Bsup_Template.nii');
MaskN{5}    = fullfile(x.D.TemplateDir,'Siemens_3DGRASE_Template.nii');
MaskN{6}    = fullfile(x.D.TemplateDir,'GE_3DSPIRAL_CBF_Template.nii');
MaskN{7}    = fullfile(x.D.TemplateDir,'rc1T1_smooth.nii');
MaskN{8}    = fullfile(x.D.TemplateDir,'rc2T1_smooth.nii');


pGMmaskFile     = fullfile(x.D.TemplateDir,'pGM_pWM_mask.nii');
GRASE_QCmask    = fullfile(x.D.TemplateDir,'Siemens_3DGRASE_QC_mask.nii');
EPI_QCmask      = fullfile(x.D.TemplateDir,'Philips_2DEPI_Bsup_QC_mask.nii');
SPIRAL_QCmask   = fullfile(x.D.TemplateDir,'GE_3Dspiral_QC_mask.nii');

for ii=1:8
    IM{ii}      = xASL_io_Nifti2Im(MaskN{ii});
end

TotalIM     = (IM{1}+IM{2}).*IM{3};
TotalIM     = TotalIM>0.5;

SPIRALmask  = TotalIM; % (IM{6}>0.2*max(IM{6}(:))) .*

GRASEmask   = (IM{5}>0.25*max(IM{5}(:))) .* TotalIM;
% GRASEmask(:,:,1:30)    = 0;

EPImask   = (IM{4}>0.25*max(IM{4}(:))) .* TotalIM;
EPImask(:,:,1:30)    = 0;

xASL_io_SaveNifti(MaskN{1},pGMmaskFile,TotalIM,1,8);
xASL_io_SaveNifti(MaskN{1},GRASE_QCmask,GRASEmask,1,8);
xASL_io_SaveNifti(MaskN{1},EPI_QCmask,EPImask,1,8);
xASL_io_SaveNifti(MaskN{1},SPIRAL_QCmask,SPIRALmask,1,8);

%
%
% dip_image([IM{5} IM{5}.*(IM{5}>(0.25*max(IM{5}(:))))])

pGMmask     = IM{7}>0.2*max(IM{7}(:));
pWMmask     = IM{8}>0.8*max(IM{8}(:));
