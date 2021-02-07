%% Iris merge scans

MAIN    = 'C:\Backup\ASL\Unilateral_Stenosis\analysis';
Dlist   = xASL_adm_GetFsList(MAIN,'^\d{3}$',1);

BackupDir   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\BackupDir';
DartelDir   = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel';
xASL_adm_CreateDir(BackupDir);

for iD=1:length(Dlist)
    CountCode(iD,length(Dlist));

%     % Rename old directories
%     for iA=1:length(ASL_list)
%         xASL_Rename(fullfile(MAIN,Dlist{iD},ASL_list{iA}),['2' ASL_list{iA}]);
%     end
%     % Create new directories (2 sessions)
%     oDir1   = fullfile(MAIN,Dlist{iD},'ASL_1');
%     oDir2   = fullfile(MAIN,Dlist{iD},'ASL_2');
%     xASL_adm_CreateDir(oDir1);
%     xASL_adm_CreateDir(oDir2);

    MergeType   = {'qCBF' 'qCBF_untreated' 'mean_control' 'PWI' 'slice_gradient' 'FoV' 'SD' 'SNR'};

    for iT=[5 7] % 1:length(MergeType)
        
        clear qCBF ASL_list qCBF1 qCBF2 File1 File2
        ASL_list    = xASL_adm_GetFileList(DartelDir,['^' MergeType{iT} '_' Dlist{iD} '_ASL_\d\.(nii|nii\.gz)$']);

        if ~isempty(ASL_list)
            % Load images & backup niftis
            for iA=1:length(ASL_list)
                clear FileName IM
                FileName        = fullfile(DartelDir,[MergeType{iT} '_' Dlist{iD} '_ASL_' num2str(iA) '.nii']);
                IM              = niftiXASL(FileName);
                qCBF(:,:,:,iA)  = IM.dat(:,:,:);
                xASL_Move(FileName,fullfile(BackupDir,[MergeType{iT} '_' Dlist{iD} '_ASL_' num2str(iA) '.nii']),1);
            end

            qCBF1               = xASL_stat_MeanNan(qCBF(:,:,:,1:2:end-1),4);
            qCBF2               = xASL_stat_MeanNan(qCBF(:,:,:,2:2:end-0),4);

            File1               = fullfile(DartelDir,[MergeType{iT} '_' Dlist{iD} '_ASL_1.nii']);
            File2               = fullfile(DartelDir,[MergeType{iT} '_' Dlist{iD} '_ASL_2.nii']);

            save_nii_spm( fullfile(BackupDir,[MergeType{iT} '_' Dlist{iD} '_ASL_' num2str(1) '.nii']), File1, qCBF1);
            save_nii_spm( fullfile(BackupDir,[MergeType{iT} '_' Dlist{iD} '_ASL_' num2str(2) '.nii']), File2, qCBF2);
        end
    
    end
    
end
    
