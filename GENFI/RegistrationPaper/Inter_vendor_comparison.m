clear
NAMELISTFILE    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\HC_Listn12.mat';

%%1 %% Get random vendor lists
% clear NAMELIST
% VENDORLIST  = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};
% ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_OLD';
%
% for iV=1:4
%     clear FLIST RandList
%     FLIST   = xASL_adm_GetFileList( ROOT, ['^' VENDORLIST{iV} '_qCBF_(C9ORF|MAPT|GRN)\d{3}_ASL_1\.(nii|nii\.gz)$']);
%
%     % Pick randomly
%     RandList        = rand(length(FLIST),1);
%     RandList(:,2)   = [1:1:length(FLIST)];
%     RandList        = sortrows(RandList,1);
%
%     for iF=1:12
%         clear NUMBER PATH FILE EXT
%         NUMBER              = RandList(iF,2);
%         [PATH FILE EXT]     = fileparts(FLIST{NUMBER});
%         NAMELIST{iF,iV}     = FILE(length(VENDORLIST{iV})+7:end-6);
%     end
% end
%
% % SaveList
% save('C:\Backup\ASL\GENFI\GENFI_DF1_new\HC_Listn12.mat','NAMELIST');

load(NAMELISTFILE);

% % Copy Philips Bsup
% ODIR    = 'D:\Backup\ASL_E\GENFI\GENFI_RawDeleteInAWhile\GENFI_DF1\raw_PH Achieva';
% DDIR    = 'D:\Backup\ASL_E\GENFI\GENFI_RawDeleteInAWhile\GENFI_DF1\raw';
%
% for iN=1:12
%     ODIR1   = fullfile(ODIR, NAMELIST{iN,2});
%     DDIR1   = fullfile(DDIR, NAMELIST{iN,2});
%     xASL_Move( ODIR1, DDIR1);
% end

% % Copy Philips nonBsup
% ODIR    = 'D:\Backup\ASL_E\GENFI\GENFI_RawDeleteInAWhile\GENFI_DF1\raw_PH Achieva';
% DDIR    = 'D:\Backup\ASL_E\GENFI\GENFI_RawDeleteInAWhile\GENFI_DF1\raw';
%
% for iN=1:12
%     ODIR1   = fullfile(ODIR, NAMELIST{iN,3});
%     DDIR1   = fullfile(DDIR, NAMELIST{iN,3});
%     xASL_Move( ODIR1, DDIR1);
% end

% % Copy Siemens
% ODIR    = 'D:\Backup\ASL_E\GENFI\GENFI_RawDeleteInAWhile\GENFI_DF1\raw_SI Trio';
% DDIR    = 'D:\Backup\ASL_E\GENFI\GENFI_RawDeleteInAWhile\GENFI_DF1\raw';
%
% for iN=1:12
%     ODIR1   = fullfile(ODIR, NAMELIST{iN,4});
%     DDIR1   = fullfile(DDIR, NAMELIST{iN,4});
%     xASL_Move( ODIR1, DDIR1);
% end

% %%2 Do the same for T1
%
% Copy vendors
VENDORNAME1     = {'GE MR750' 'PH Achieva Bsup' 'PH Achieva no Bsup' 'SI Trio'};
VENDORNAME2     = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};

% FileN   = {'T1.nii' 'c1T1.nii' 'y_T1.nii'};
% FileN   = {'y_T1.nii'};

for iV=1:4
    clear ODIR DDIR

    ODIR    = fullfile( 'C:\Backup\ASL\GENFI\GENFI_DF1_new', VENDORNAME1{iV} ,'analysis');
    DDIR    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\pGM_COMPARISON';

    for iN=1:12
        clear ODIR1 DDIR1
%         DDIR1   = fullfile( DDIR, 'dartel');
%         xASL_adm_CreateDir(DDIR1);

        oFILE   = fullfile( ODIR, 'dartel', ['rc1T1_' NAMELIST{iN,iV} '.nii']);
        dFILE   = fullfile( DDIR,           ['rc1T1_' NAMELIST{iN,iV} '.nii']);

        xASL_Copy( oFILE, dFILE);

    end
end
%
% %% 3) Skullstrip T1
%
% VENDORNAME      = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};
% ROOT            = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor';
% BMaskFile       = 'C:\ASL_pipeline_HJ\Maps\rbrainmask.nii';
%
% for iV=1:4
%     clear DDIR DLIST
%     DDIR        = fullfile(ROOT, VENDORNAME{iV})
%     DLIST       = xASL_adm_GetFsList( DDIR, '^(C9ORF|GRN|MAPT)\d{3}$',1 );
%
%     for iN=1:length(DLIST)
%         clear DDIR1 T1name INPUTname WARPmask T1OLD MASK MASKnew T1
%         DDIR1   = fullfile(DDIR, DLIST{iN});
%
%         % Copy brainmask
%         T1name      = fullfile( DDIR1, 'T1.nii');
%         INPUTname   = fullfile( DDIR1, 'T1mask.nii');
%         WARPmask    = fullfile( DDIR1, 'wT1mask.nii');
%         T1OLD       = fullfile( DDIR1, 'T1OLD.nii');
%         xASL_Copy(BMaskFile, INPUTname );
%
%         % Warp brainmask
%
%         clear matlabbatch
%         matlabbatch{1}.spm.util.defs.comp{1}.def                    = {fullfile( DDIR1, 'y_T1.nii')};
%
%         if      iscell(INPUTname)
%                 matlabbatch{1}.spm.util.defs.out{1}.push.fnames     = INPUTname;
%         else    matlabbatch{1}.spm.util.defs.out{1}.push.fnames     = {INPUTname};
%         end
%
%         matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc    = 1; % saves in SUBJECTDIR, because we need to rename still
%         matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
%         matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {T1name};
%         matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
%         matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
%
%
%         spm_jobman('run',matlabbatch);
%
%         MASK    = xASL_nifti( WARPmask );
%         T1      = xASL_nifti( T1name );
%         MASK    = MASK.dat(:,:,:);
%         T1      = single(T1.dat(:,:,:));
%
%         MASKnew             = zeros(size(MASK,1),size(MASK,2),size(MASK,3));
%         MASKnew(MASK>0.5)   = 1;
%         MASKnew(MASK>0.4 & MASK<0.5)   = 0.8;
%         MASKnew(MASK>0.3 & MASK<0.4)   = 0.6;
%         MASKnew(MASK>0.2 & MASK<0.3)   = 0.4;
%         MASKnew(MASK>0.1 & MASK<0.2)   = 0.2;
%
%         T1      = T1.*single(MASKnew);
%
%         xASL_Move( T1name, T1OLD);
%         xASL_io_SaveNifti( T1OLD, T1name, T1 );
%     end
% end
%
% %% Remove biasfield GE
% clear
% ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\GE';
% DLIST   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1 );
%
% for iN=1:length(DLIST)
%     clear DDIR1 T1name T1OLDname T1 matlabbatch BFIELD newT1 T1NORMOLD T1NORMNEW
%
%     DDIR1   = fullfile(ROOT, DLIST{iN});
%     T1name  = fullfile( DDIR1, 'T1.nii');
%     T1OLDname  = fullfile( DDIR1, 'T1OLD.nii');
%     T1      = xASL_nifti( T1name );
%     T1      = single(T1.dat(:,:,:));
%
%     matlabbatch{1}.spm.spatial.smooth.data  = {[T1OLDname ',1']};
%     matlabbatch{1}.spm.spatial.smooth.fwhm  = [32 32 32];
%     matlabbatch{1}.spm.spatial.smooth.dtype = 0;
%     matlabbatch{1}.spm.spatial.smooth.im    = 0;
%     matlabbatch{1}.spm.spatial.smooth.prefix = 's';
%     spm_jobman('run',matlabbatch);
%
%     BFIELDname  = fullfile(DDIR1, 'sT1OLD.nii');
%     BFIELD      = xASL_nifti( BFIELDname );
%     BFIELD      = single(BFIELD.dat(:,:,:));
%
%     newT1      = T1./BFIELD;
%     T1NORMOLD   = xASL_stat_MeanNan(T1(T1~=0));
%     T1NORMNEW   = xASL_stat_MeanNan(newT1(newT1~=0));
%     newT1       = newT1./T1NORMNEW.*T1NORMOLD;
%
%     xASL_Move( T1name, T1OLDname,1);
%
%     xASL_io_SaveNifti( T1OLDname, T1name, newT1 );
%     delete(BFIELDname);
% end
%
