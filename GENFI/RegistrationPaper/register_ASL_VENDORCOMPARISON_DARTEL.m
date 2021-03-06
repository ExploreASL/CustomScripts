function register_ASL_VENDORCOMPARISON_DARTEL(x)
% function register_ASL_VENDORCOMPARISON_DARTEL(filename)
%
% Input:  filename - 4D nifti
% Output: resampled & realigned 3D nifti
%
% 1)    Estimate motion from mean head position using SPM_realign or SPM_realign_asl
% 2)    Reslice all images to MNI space (currently 1.5 mm^3)
% 3)    Calculate and plot position and motion parameters
%
% Requires SPM8
%
% Matthan Caan, AMC 2013
% HJ Mutsaerts, ExploreASL AMC 2016
%
% 1    Registration ASL -> T1 (& M0 if there is a separate M0 or mean_control image without background suppression)
% 2    Create slice gradient image for quantification reference, in case of 2D ASL
% 3    Reslice ASL time series to MNI space (currently 1.5 mm^3)
% 4    Create mean control image, masking to 20% of max value if used as M0 (no background suppression)
% 5    Smart smoothing mean_control if used as M0
%
% BACKGROUND INFORMATION
%
% RESAMPLING TO ISOTROPY
% Resampling is performed with SPM. The SPM resampling script smooths a bit more than "real linear interpolation",
% (this could be because of the Fourier interpolation?) This choice is made since it is desirable to have the majority of the pipeline
% based on existing, proved, scripts (SPM8); and because the penalty of a small degree of smoothing is small.
%
% Care was taken to limit the amount of individual interpolation steps, without letting
% computation time rise too much because of operations in higher resolution (e.g. 1.5 mm^3)


%% Administration

[path file ext]                 = fileparts(x.despiked_raw_asl);
[path_dummy x.P.SessionID dummy] 	= fileparts(path);
[path_dummy x.P.SubjectID dummy] 	= fileparts(path_dummy);
clear dummy ext path_dummy

x.x.P.SubjectID              = x.P.SubjectID;

temp_name       = fullfile(x.SESSIONDIR, ['temp_' file '.nii']);
temp_mat        = fullfile(x.SESSIONDIR, ['temp_' file '.mat']);
rtemp_name      = fullfile(x.SESSIONDIR, ['rtemp_' file '.nii']);

T1_nii              = fullfile(x.SUBJECTDIR, [     x.P.STRUCT '.nii']);
GM_nii              = fullfile(x.SUBJECTDIR, ['c1' x.P.STRUCT '.nii']);
wGM_nii             = fullfile(x.SUBJECTDIR, ['wc1' x.P.STRUCT '.nii']);
if ~exist( GM_nii ,'file')
    error(['GM probability map ' GM_nii ' did not exist!']);
end

tempnii             = xASL_nifti(x.despiked_raw_asl);
min_voxelsize       = double(min(tempnii.hdr.pixdim(2:4) )); % repmat, 1,3
nFrames             = double(tempnii.hdr.dim(5));

%% 1    Registration ASL -> ASL

mean_PWI_Clipped   = fullfile(x.SESSIONDIR, 'mean_PWI_Clipped.nii');
MASKname        = fullfile(x.SESSIONDIR, 'PWI_GradualMask.nii');
M0name          = fullfile(x.SESSIONDIR, 'M0.nii');
NEWM0           = fullfile(x.SESSIONDIR, 'temp_M0.nii');
ASLname         = fullfile(x.SESSIONDIR, 'mean_PWI_Clipped.nii');
% ASLnameCopy     = fullfile(x.SESSIONDIR, 'PWI_6par_reg.nii');
ASLname_SN      = fullfile(x.SESSIONDIR, 'mean_PWI_Clipped_sn.mat');
M0nameCopy      = fullfile(x.SESSIONDIR, 'M0_6par_reg.nii');
ASL_MNI         = fullfile(x.SESSIONDIR, 'rmean_PWI_Clipped.nii');

clear matlabbatch REGNAME


%% DARTEL
if ~isempty(strfind(x.SESSIONDIR,'PWI_pGM'))

    %% Remove previous files
    xASL_adm_DeleteFileList( x.SESSIONDIR, '^Template_\d\.(nii|nii\.gz)$' );
    delete( fullfile( x.SESSIONDIR, 'u_rmean_PWI_Clipped_Template.nii') );
    delete( fullfile( x.SESSIONDIR, 'DARTEL_PWI_pGM.m') );
    delete( fullfile( x.D.ROOT, x.P.SubjectID, 'u_wc1T1_Template.nii') );


    %% Apply deformations for temporal resampled PWI
    if ~exist(ASL_MNI)
        clear matlabbatch

%         Now only 3) rigid+DARTEL
%         matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname         = {ASLname_SN};
%         matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox             = [NaN NaN NaN];
%         matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb              = [NaN NaN NaN
%                                                                        NaN NaN NaN];
%         matlabbatch{1}.spm.util.defs.comp{2}.def                    = {fullfile( x.D.ROOT, x.P.SubjectID, ['y_' x.P.STRUCT '.nii'])};
        matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( x.D.ROOT, x.P.SubjectID, ['y_' x.P.STRUCT '.nii'])};
        matlabbatch{1}.spm.util.defs.out{1}.pull.fnames             = {ASLname};
        matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc    = 1; % saves in SUBJECTDIR, because we need to rename still
        matlabbatch{1}.spm.util.defs.out{1}.pull.interp             = 4;
        matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
        matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];

        spm_jobman('run',matlabbatch);
    end

    %% Apply deformations for temporal resampled pGM
    if ~exist(wGM_nii)
        clear matlabbatch

        matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( x.D.ROOT, x.P.SubjectID, ['y_' x.P.STRUCT '.nii'])};
        matlabbatch{1}.spm.util.defs.out{1}.pull.fnames             = {GM_nii};
        matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc    = 1; % saves in SUBJECTDIR, because we need to rename still
        matlabbatch{1}.spm.util.defs.out{1}.pull.interp             = 4;
        matlabbatch{1}.spm.util.defs.out{1}.pull.mask               = 1;
        matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm               = [0 0 0];

        spm_jobman('run',matlabbatch);
    end

    %% Clip & rescale PWI to 0-1

    ASLload                        = xASL_nifti(ASL_MNI);
    newASL                         = ASLload.dat(:,:,:);
    newASL                         = ClipVesselImage( newASL, 0.95);
    newASL                         = newASL./max(newASL(:));
    newASL(newASL<0)               = 0;
    xASL_io_SaveNifti(ASL_MNI, ASL_MNI, newASL);


    %% Run DARTEL
    clear matlabbatch
    matlabbatch{1}.spm.tools.dartel.warp.images = {
                                                {[ASL_MNI ',1']
                                                [wGM_nii ',1']
                                                }
                                                }';
    matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
    matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

    spm_jobman('run',matlabbatch);

    REGNAME                                                     = 'DARTEL_PWI_pGM.m';
    save( fullfile(x.SESSIONDIR,REGNAME),'ASLname');

end



end
