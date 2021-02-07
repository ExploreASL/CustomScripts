function NativeDeformations_VENDORCOMPARISON(x,x.P.SubjectID,INPUTname,TYPEname)
% NativeDeformations_VENDORCOMPARISON Assumes MNI warp & DARTEL warps only, combines them
% into single interpolation




%% CAVE
%% Put this script back to original
%% Some parts have been changed for a re-run









% INPUTname can also be a cell-list of names, as long as OUTPUTname
% corresponds to it



% Reg 1 = linear 6 par registration, in header ASL niftis
% Reg 2 = 12 par affine + elastic old normalize, sn_mat file (if PWI)
% Reg 3 = warp from T1 to MNI space
% Reg 4 = PWI-based DARTEL (if PWI)
% Reg 5 =  T1-based DARTEL

% T1-based normalization to standard space
reg_3_MNI_nii      = fullfile(x.D.ROOT, x.P.SubjectID, 'y_T1.nii');
reg_5_DARTEL_nii   = fullfile(x.D.PopDir, ['u_rc1T1_' x.P.SubjectID '_T1_template.nii']);


% Warp of ASL to T1
if     ~isempty(strfind(x.SESSIONDIR,'M0_T1')) || ~isempty(strfind(x.SESSIONDIR,'NoReg'))
elseif ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))
        reg_2_12par_mat           = fullfile(x.SESSIONDIR,      'mean_PWI_Clipped_sn.mat');
        reg_4a_DARTEL_PWI         = fullfile(x.SESSIONDIR,      'u_rmean_PWI_Clipped_Template.nii');
        reg_4b_DARTEL_T1          = fullfile(x.D.ROOT,x.P.SubjectID, 'u_wc1T1_Template.nii');
end


% Destination folders
RegNames                = {'1_6par_linear'};

if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))
   RegNames             = {'1_6par_linear' '2_12par_affine_elast' '3_DARTEL'};
end

for iF=1:length(RegNames)
    dFOLDER{iF}     = fullfile(x.D.PopDir,RegNames{iF});
    xASL_adm_CreateDir(dFOLDER{iF});
end



%% Do warps
% Common part

def_MNI                         = { reg_3_MNI_nii };
dartel_T1.flowfield             = { reg_5_DARTEL_nii };
dartel_T1.times                 = [1 0]; % backward (normal)
dartel_T1.K                     = 6;
dartel_T1.template              = {''};

if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))

    sn2def_12par_affine.matname     = { reg_2_12par_mat };
    sn2def_12par_affine.vox         = [NaN NaN NaN];
    sn2def_12par_affine.bb          = [NaN NaN NaN
                                       NaN NaN NaN];    
    
    dartel_PWIa.flowfield           = { reg_4a_DARTEL_PWI };
    dartel_PWIa.times               = [1 0]; % backward (normal)
    dartel_PWIa.K                   = 6;
    dartel_PWIa.template            = {''};

    dartel_PWIb.flowfield           = { reg_4b_DARTEL_T1 };
    dartel_PWIb.times               = [0 1]; % forward (inverse)
    dartel_PWIb.K                   = 6;
    dartel_PWIb.template            = {''};
end              


clear matlabbatch
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames     = {INPUTname};
matlabbatch{1}.spm.util.defs.out{1}.pull.interp     = 4;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask       = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm       = [0 0 0];


% for iF=1:length(RegNames)
iF=2;
    if      iF==1; % 1_6par_linear

            matlabbatch{1}.spm.util.defs.comp{1}.def                = def_MNI;
            matlabbatch{1}.spm.util.defs.comp{2}.dartel             = dartel_T1;

    elseif  iF==2; % 2_12par_affine_elast
            matlabbatch{1}.spm.util.defs.comp{1}.sn2def             = sn2def_12par_affine;
            matlabbatch{1}.spm.util.defs.comp{2}.def                = def_MNI;
            matlabbatch{1}.spm.util.defs.comp{3}.dartel             = dartel_T1;    

    elseif  iF==3; % 3_DARTEL
%             matlabbatch{1}.spm.util.defs.comp{1}.sn2def             = sn2def_12par_affine;
%             matlabbatch{1}.spm.util.defs.comp{2}.def                = def_MNI;
%             matlabbatch{1}.spm.util.defs.comp{3}.dartel             = dartel_PWIa;
%             matlabbatch{1}.spm.util.defs.comp{4}.dartel             = dartel_PWIb;        
%             matlabbatch{1}.spm.util.defs.comp{5}.dartel             = dartel_T1;
            matlabbatch{1}.spm.util.defs.comp{1}.def                = def_MNI;
            matlabbatch{1}.spm.util.defs.comp{2}.dartel             = dartel_PWIa;
            matlabbatch{1}.spm.util.defs.comp{3}.dartel             = dartel_PWIb;        
            matlabbatch{1}.spm.util.defs.comp{4}.dartel             = dartel_T1;
    end


    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr= { dFOLDER{iF} };

    clear path file ext wname
    [path file ext]     = fileparts(INPUTname);
    wname               = fullfile(dFOLDER{iF},['w' file ext]);
    OUTPUTname          = fullfile(dFOLDER{iF},[TYPEname '_' x.P.SubjectID '.nii']);
    
    if ~exist(OUTPUTname,'file')
        spm_jobman('run',matlabbatch);
    end

    xASL_Move( wname, OUTPUTname, 1);    
    matlabbatch{1}.spm.util.defs                = rmfield(matlabbatch{1}.spm.util.defs,'comp');
    matlabbatch{1}.spm.util.defs.out{1}.pull    = rmfield(matlabbatch{1}.spm.util.defs.out{1}.pull,'savedir');


    
% end    
    

end
