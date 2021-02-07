%% Preparing for 3) rigid-DARTEL rather than 3)rigid-normalize-DARTEL
clear
ROOT{1}   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_BETMASK';
ROOT{2}   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_NOMASK';
ROOT{3}   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_PWIMASK';

DDIR{1}   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_BETMASK_DARTEL_AFTER_NORM';
DDIR{2}   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_NOMASK_DARTEL_AFTER_NORM';
DDIR{3}   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_PWIMASK_DARTEL_AFTER_NORM';

FILES2L     = {'wc1T1.nii' 'u_wc1T1_Template.nii' 'mean_PWI_Clipped_sn.mat' 'Template_0.nii' 'Template_1.nii' 'Template_2.nii' 'Template_3.nii' 'Template_4.nii' 'Template_5.nii' 'Template_6.nii' 'u_rmean_PWI_Clipped_Template.nii' 'rmean_PWI_Clipped.nii' 'DARTEL_PWI_pGM.m'};

for iR=1:3
    for iF=1:length(FILES2L)

        FLIST   = xASL_adm_GetFileList(ROOT{iR}, ['^' FILES2L{iF} '$'],'FPListRec');

        for iFF=1:length(FLIST)
            [path file ext]     = fileparts(FLIST{iFF});
            NewPath     = [DDIR{iR} path(length(ROOT{iR})+1:end)];
            xASL_adm_CreateDir(NewPath);
            xASL_Move(FLIST{iFF}, fullfile(NewPath,[file ext]));
        end
    end
end

% So copied here from original dir to "DARTEL_AFTER_NORM" dir.
% Used the DARTEL without normalization, so remove the ones with
% normalization.
