%% Create scanners' folders

%xASL_io_DcmtkRead
scanners = unique(scannerlist(:,3));
root = fullfile(BasePath, 'DDI_sorted_August');

NoASLDest = fullfile (root,'SubjectsWithoutASL');
xASL_adm_CreateDir(NoASLDest);

for iScanner = 5:length(scanners) %The first two are GE, having correspondance only with T1 and FLAIR
    xASL_TrackProgress(iScanner, length(scanners));
    clear FinalDest

    % Copy all subjects that have this type to the directory
    for iElement = 1:size(scannerlist,1)
        if strcmp(scannerlist{iElement,3},scanners{iScanner})
            source = fullfile(Ddir,scannerlist{iElement,1},scannerlist{iElement,2});
            
            ASLfolder_find=xASL_adm_GetFileList(source, '^ASL', 'FPList',[0 Inf],true); % true for folders
            M0folder_find=xASL_adm_GetFileList(source, '^M0', 'FPList',[0 Inf],true); % true for folders
            
            if isempty (ASLfolder_find)
                FinalDest = fullfile(NoASLDest, 'sourcedata',scannerlist{iElement,1},scannerlist{iElement,2});
                xASL_adm_CreateDir(FinalDest);
                xASL_Copy(source,FinalDest,true); % Use the recursive option
                
             else
                % If ASL is present, create the output directory for the current scanner type
                ScannerDest=fullfile(root,scanners{iScanner});
                xASL_adm_CreateDir(ScannerDest);
                sourceASL = fullfile(Ddir,scannerlist{iElement,1},scannerlist{iElement,2},'ASL');
                
                FinalDestASL = fullfile(ScannerDest, 'sourcedata',scannerlist{iElement,1},scannerlist{iElement,2},'ASL');
                xASL_adm_CreateDir(FinalDestASL);
                xASL_Copy(sourceASL,FinalDestASL,true); % Use the recursive option
                
                if ~isempty(M0folder_find)
                sourceM0 = fullfile(Ddir,scannerlist{iElement,1},scannerlist{iElement,2},'M0');
                FinalDestM0 = fullfile(ScannerDest, 'sourcedata',scannerlist{iElement,1},scannerlist{iElement,2},'M0');
                xASL_Copy(sourceM0,FinalDestM0,true); % Use the recursive option
                end
                
            end
            
        end
        
    end
    
end

