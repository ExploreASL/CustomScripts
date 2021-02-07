clear
NAMELISTFILE    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\HC_Listn12.mat';

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
% % Copy vendors
% VENDORNAME1     = {'GE MR750' 'PH Achieva Bsup' 'PH Achieva no Bsup' 'SI Trio'};
% VENDORNAME2     = {'GE' 'PHBsup' 'PHnonBsup' 'SI'};
% 
% FileN   = {'T1.nii' 'c1T1.nii' 'y_T1.nii'};
% 
% for iV=1:4
%     clear ODIR DDIR
%     
%     ODIR    = fullfile( 'C:\Backup\ASL\GENFI\GENFI_DF1_new', VENDORNAME1{iV} ,'analysis');
%     DDIR    = fullfile( 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor', VENDORNAME2{iV} );
% 
%     for iN=1:12
%         clear ODIR1 DDIR1
%         ODIR1   = fullfile(ODIR, NAMELIST{iN,iV});
%         DDIR1   = fullfile(DDIR, NAMELIST{iN,iV});
% 
%         for iF=1:length(FileN)
%             xASL_Copy( fullfile(ODIR1,FileN{iF}), fullfile(DDIR1,FileN{iF}));
%         end
% 
%     end
% end

%% 3) Skullstrip T1

