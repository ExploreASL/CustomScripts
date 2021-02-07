%% Try T1 skull stripping with integration c1 c2 c3
ROOT     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis\C9ORF047';

T1{1}    = fullfile(ROOT, 'T1.nii');
T1{2}    = fullfile(ROOT, 'c1T1.nii');
T1{3}    = fullfile(ROOT, 'c2T1.nii');
T1{4}    = fullfile(ROOT, 'c3T1.nii');

for ii=1:4
    T1file{ii}  = xASL_nifti(T1{ii});
    T1file{ii}  = xASL_im_rotate(T1file{ii}.dat(:,:,:),90);
end

MASK    = T1file{2} + T1file{3} + T1file{4};
dip_image([T1file{1} MASK.*1400 T1file{1}.*MASK])

%% Try T1 skullstripping by warping

INPUTname   = fullfile(ROOT, 'rbrainmask.nii');

clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( ROOT, 'y_T1.nii')};

if      iscell(INPUTname)
        matlabbatch{1}.spm.util.defs.out{1}.push.fnames     = INPUTname;
else    matlabbatch{1}.spm.util.defs.out{1}.push.fnames     = {INPUTname};
end

matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc    = 1; % saves in SUBJECTDIR, because we need to rename still
matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {T1{1}};

% matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [NaN NaN NaN
%                                                          NaN NaN NaN];
% matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];


spm_jobman('run',matlabbatch);

MASK    = xASL_nifti( fullfile(ROOT, 'wrbrainmask.nii') );
MASK    = xASL_im_rotate(MASK.dat(:,:,:),90);

MASKnew             = zeros(size(MASK,1),size(MASK,2),size(MASK,3));
MASKnew(MASK>0.5)   = 1;
MASKnew(MASK>0.4 & MASK<0.5)   = 0.8;
MASKnew(MASK>0.3 & MASK<0.4)   = 0.6;
MASKnew(MASK>0.2 & MASK<0.3)   = 0.4;
MASKnew(MASK>0.1 & MASK<0.2)   = 0.2;

dip_image([T1file{1}./1400 MASKnew.*10 T1file{1}.*single(MASKnew)./1400.*5])


