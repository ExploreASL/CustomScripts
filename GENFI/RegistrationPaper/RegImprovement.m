% %% Try registration improvement/masking
% 
% clear matlabbatch
% 
% matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\RegImprovement\GRN006\c1T1.nii,1'};
% matlabbatch{1}.spm.spatial.coreg.estimate.source = {'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\RegImprovement\GRN006\ASL_1\mean_PWI_Clipped.nii,1'};
% matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% 
% tic
% spm_jobman('run',matlabbatch)
% toc

x.D.ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis';
x.P.SubjectID      = 'C9ORF028';
x.P.STRUCT    = 'T1';
INPUTname       = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis\C9ORF028\ASL_1\mean_PWI_Clipped.nii';
x.D.PopDir       = fullfile(x.D.ROOT, 'dartel');


    %% Deformation tool
    clear matlabbatch
    matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( x.D.ROOT, x.P.SubjectID, ['y_' x.P.STRUCT '.nii'])};

    if T1_DARTEL==1
       matlabbatch{1}.spm.util.defs.comp{2}.dartel.flowfield    = {fullfile( x.D.PopDir,  ['u_rc1' x.P.STRUCT '_' x.P.SubjectID '_' x.P.STRUCT '_template.nii']) };
       matlabbatch{1}.spm.util.defs.comp{2}.dartel.times        = [1 0];
       matlabbatch{1}.spm.util.defs.comp{2}.dartel.K            = 7;
       matlabbatch{1}.spm.util.defs.comp{2}.dartel.template     = {''};
    end    

    if      iscell(INPUTname)
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = INPUTname;
    else    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = {INPUTname};
    end
    
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc    = 1; % saves in SUBJECTDIR, because we need to rename still

    if      x.Quality==1
            matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 4;
    else    matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 1;
    end

    matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];

    spm_jobman('run',matlabbatch);

    if  iscell(INPUTname)
            for iL=1:length(INPUTname)
                clear path file ext wname
                [path file ext]     = fileparts(INPUTname{iL});
                wname               = fullfile(path,['w' file ext]);
                xASL_Move( wname, OUTPUTname{iL}, 1);
            end
    else    
        [path file ext]     = fileparts(INPUTname);
        wname               = fullfile(path,['w' file ext]);        
        xASL_Move( wname, OUTPUTname, 1);
    end
