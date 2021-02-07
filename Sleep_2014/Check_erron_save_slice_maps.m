%% Check erroneously saved slice_gradient_maps
clear
ROOT    = 'C:\Backup\ASL\Sleep2\analysis\dartel';
FList   = xASL_adm_GetFileList(ROOT, '^DARTEL_slice_gradient_\d{3}_ASL_(1|2|3)\.(nii|nii\.gz)$');

ERRORN  = 1;
for iF=1:length(FList)
    clear tnii tnii2
    tnii    = xASL_io_ReadNifti(FList{iF});
    tnii    = tnii.dat(:,:,:);

    if  max(tnii(:))>50 | min(tnii(:))<-50
        error(FList{iF});
    end
end


%             LIST_ERROR{ERRORN,1}    = FList{iF};
%         ERRORN  = ERRORN+1;
%
%         LIST_ERROR{ERRORN,2}    = sum(tnii(:)>50);

        tnii2    = xASL_io_ReadNifti(FList{iF-1});
        tnii2    = tnii2.dat(:,:,:);

        tnii(tnii>50 | tnii<-50)   = tnii2(tnii>50 | tnii<-50);
        xASL_io_SaveNifti( FList{iF}, FList{iF}, tnii );


clear matlabbatch

matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {'C:\Backup\ASL\Sleep2\analysis\dartel\u_rc1T1_130_T1_template.nii'};
matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1 0];
matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
matlabbatch{1}.spm.util.defs.comp{2}.dartel.flowfield = {'C:\Backup\ASL\Sleep2\analysis\dartel\u_wPWI_130_ASL_1_PWI_template.nii'};
matlabbatch{1}.spm.util.defs.comp{2}.dartel.times = [1 0];
matlabbatch{1}.spm.util.defs.comp{2}.dartel.K = 6;
matlabbatch{1}.spm.util.defs.comp{2}.dartel.template = {''};
matlabbatch{1}.spm.util.defs.comp{3}.sn2def.matname = {'C:\Backup\ASL\Sleep2\analysis\dartel\PWI_template_3_sn.mat'};
matlabbatch{1}.spm.util.defs.comp{3}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{3}.sn2def.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{4}.sn2def.matname = {'C:\Backup\ASL\Sleep2\analysis\dartel\T1_template_6_sn.mat'};
matlabbatch{1}.spm.util.defs.comp{4}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{4}.sn2def.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {'C:\Backup\ASL\Sleep2\analysis\dartel\slice_gradient_130_ASL_2.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];

spm_jobman('run',matlabbatch);
