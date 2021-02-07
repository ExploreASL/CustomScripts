%% Create brain probability map

MaskName                = 'C:\ExploreASL\Maps\rbrainmask.nii';
MaskName2               = 'C:\ExploreASL\Maps\Templates\brainmask.nii';
ProbMaskname            = 'C:\ExploreASL\Maps\Prob_rbrainmask.nii';
DefacedProbMaskname     = 'C:\ExploreASL\Maps\anon_Prob_rbrainmask.nii';
FoVmask                 = 'C:\ExploreASL\Maps\FoVmask.nii';
DefaceMask              = 'C:\ExploreASL\Maps\DefaceMask.nii';
T1_template             = 'C:\ExploreASL\Maps\Templates\T1.nii';
DefaceT1temp            = 'C:\ExploreASL\Maps\Templates\anon_T1.nii';
JointMaskName           = 'C:\ExploreASL\Maps\Templates\RegistrationMask.nii';

%% Create Deface mask
clear matlabbatch
matlabbatch{1}.spm.util.deface.images = {T1_template};
spm_jobman('run', matlabbatch);

DefaceIM                = xASL_io_ReadNifti(DefaceT1temp);
DefaceIM                = DefaceIM.dat(:,:,:);
T1_im                   = xASL_io_ReadNifti(T1_template);
T1_im                   = T1_im.dat(:,:,:);

FaceMaskim              = DefaceIM~=T1_im;
FaceMaskim              = logical(~FaceMaskim);

FaceMaskim              = imerode(FaceMaskim,strel('disk',7));

xASL_io_SaveNifti(DefaceT1temp, DefaceMask, FaceMaskim);

%% Create joint BrainMask
Mask1IM                 = xASL_io_ReadNifti(MaskName);
Mask1IM                 = Mask1IM.dat(:,:,:);
Mask1IM                 = Mask1IM>0.5.*max(Mask1IM(:));

Mask2IM                 = xASL_io_ReadNifti(MaskName2);
Mask2IM                 = Mask2IM.dat(:,:,:);
Mask2IM                 = Mask2IM>0.5.*max(Mask2IM(:));

JointMask               = Mask1IM.*Mask2IM; %.*FaceMaskim;

xASL_io_SaveNifti(T1_template, JointMaskName, JointMask);

%% Create MaskMap

BrainMaskProbMap( JointMaskName, JointMaskName, 0.25, 5 );
% join masks again
ProbIM                  = xASL_io_ReadNifti(JointMaskName);
ProbIM                  = ProbIM.dat(:,:,:);
% JointMask               = ProbIM.*FaceMaskim;
xASL_io_SaveNifti(JointMaskName, JointMaskName, ProbIM);
