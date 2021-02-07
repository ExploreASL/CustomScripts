%% GENFI ASL file management GE MR750

% ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis';
ROOT        = 'C:\Backup\ASL\22q11\analysis';
dList       = xASL_adm_GetFsList( ROOT, '^\d*$',1);
DOUBLEIM    = {''};

for iList=1:length(dList)
    ASLfile     = fullfile( ROOT, dList{iList}, 'ASL_1', 'ASL4D.nii');
    ASLnii      = xASL_nifti( ASLfile );
    if      size(ASLnii.dat,4)==2
            PWIim   = ASLnii.dat(:,:,:,1);
            M0im    = ASLnii.dat(:,:,:,2);
    elseif  size(ASLnii.dat,4)==4
            PWIim   = ASLnii.dat(:,:,:,1:2);
            M0im    = ASLnii.dat(:,:,:,3:4);
            DOUBLEIM{end+1,1}   = dList{iList};

    else    error('Wrong dimension');
    end

    % Check dim size
    if  length(size(ASLnii.dat))~=4
        error('dimsize');
    end

    M0file      = fullfile( ROOT, dList{iList}, 'ASL_1', 'M0.nii');
    M0mat       = fullfile( ROOT, dList{iList}, 'ASL_1', 'M0_parms.mat');
    TempFile    = fullfile( ROOT, dList{iList}, 'ASL_1', 'temp.nii');
    ASLmat      = fullfile( ROOT, dList{iList}, 'ASL_1', 'ASL4D_parms.mat');

    if  exist(M0file);delete(M0file);end
    if  exist(M0mat) ;delete(M0mat) ;end

    xASL_io_SaveNifti( ASLfile, M0file, M0im, size(M0im,4) );

    xASL_io_SaveNifti( ASLfile, TempFile, PWIim, size(PWIim,4) );

    delete( ASLfile );
    xASL_Move( TempFile, ASLfile );
    xASL_Copy( ASLmat, M0mat );
end

% Only 2 two frames: GRN114 & GRN080
% First of site 'CV' batch of 21 scans, so probably first different
% settings
% No visible motion, so simply averaged the scans.

ASLname     = fullfile( ROOT, 'GRN080', 'ASL_1','ASL4D.nii');
tempName    = fullfile( ROOT, 'GRN080', 'ASL_1','temp_SL4D.nii');
ASLnii      = xASL_nifti( ASLname );
ASLim       = xASL_stat_MeanNan( ASLnii.dat(:,:,:,:),4);
xASL_io_SaveNifti( ASLname, tempName, ASLim, 1,16 );
delete(ASLname);
xASL_Move(tempName,ASLname);

ASLname     = fullfile( ROOT, 'GRN080', 'ASL_1','M0.nii');
tempName    = fullfile( ROOT, 'GRN080', 'ASL_1','temp_M0.nii');
ASLnii      = xASL_nifti( ASLname );
ASLim       = xASL_stat_MeanNan( ASLnii.dat(:,:,:,:),4);
xASL_io_SaveNifti( ASLname, tempName, ASLim, 1,16 );
delete(ASLname);
xASL_Move(tempName,ASLname);

ASLname     = fullfile( ROOT, 'GRN114', 'ASL_1','ASL4D.nii');
tempName    = fullfile( ROOT, 'GRN114', 'ASL_1','temp_SL4D.nii');
ASLnii      = xASL_nifti( ASLname );
ASLim       = xASL_stat_MeanNan( ASLnii.dat(:,:,:,:),4);
xASL_io_SaveNifti( ASLname, tempName, ASLim, 1,16 );
delete(ASLname);
xASL_Move(tempName,ASLname);

ASLname     = fullfile( ROOT, 'GRN114', 'ASL_1','M0.nii');
tempName    = fullfile( ROOT, 'GRN114', 'ASL_1','temp_M0.nii');
ASLnii      = xASL_nifti( ASLname );
ASLim       = xASL_stat_MeanNan( ASLnii.dat(:,:,:,:),4);
xASL_io_SaveNifti( ASLname, tempName, ASLim, 1,16 );
delete(ASLname);
xASL_Move(tempName,ASLname);
