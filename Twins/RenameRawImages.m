% add ExploreASL scripts
x.MYPATH  = 'c:\ExploreASL';
addpath(fullfile(x.MYPATH,'spmwrapperlib'));

% start
x.D.ROOT    = '/home/projects/AD_Niftis/work/Vumc/Silvia/TwinData/raw';
DirList         = xASL_adm_GetFsList(ROOTdir, '^EMI\d{3}$',1); % Get directory list

for iDir=1:length(DirList)
    % within each EMIxxx directory, we create a list of all scan directories
    CurrSubjectDir  = fullfile(x.D.ROOT,DirList{iDir});
    DirList2        = xASL_adm_GetFsList(CurrSubjectDir,'.*',1); % the directory name can be anything
    FoundScans(iDir,1:3)    = 0;
    
    for iDir2=1:length(DirList2)
        clear CurrScanDir DicomList NewName
        
        CurrScanDir     = fullfile(x.D.ROOT,DirList{iDir},DirList2{iDir2});
        % now we loop across scan directories, and check the size of their
        % contents
        
        DicomList       = xASL_adm_GetFileList(CurrScanDir,'.*\.(dcm|DCM|IMA)$'); % the latter should contain the dicom extension
        
        % Now we rename the CurrScanDir to the ScanName
        if      length(DicomList)==1380
                % this is an ASL scan
                NewName     = fullfile(x.D.ROOT,DirList{iDir},'ASL_raw');
                xASL_Rename(CurrScanDir,NewName);
                % count the number of ASL scans that we found
                FoundScans(iDir,1)  = FoundScans(iDir,1)+1;
        elseif  length(DicomList)==180
                % this is a T1w scan
                NewName     = fullfile(x.D.ROOT,DirList{iDir},'T1w_raw');
                xASL_Rename(CurrScanDir,NewName);    
                % count the number of T1w scans that we found
                FoundScans(iDir,1)  = FoundScans(iDir,2)+1;                
        elseif  length(DicomList)==23
                % this is a T1w scan
                NewName     = fullfile(x.D.ROOT,DirList{iDir},'M0_raw');
                xASL_Rename(CurrScanDir,NewName);
                % count the number of M0 scans that we found
                FoundScans(iDir,1)  = FoundScans(iDir,3)+1;                
        else    % skip this
        end
    end
end
        
% so the number of found ASL, T1w and M0 scans are now in
% sum(FoundScans(:,1))
% sum(FoundScans(:,2)) and 
% sum(FoundScans(:,3))
% respectively

    
