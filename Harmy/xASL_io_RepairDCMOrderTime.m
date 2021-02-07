function xASL_io_RepairDCMOrderTime(InputDir,IsRepair)
%xASL_io_RepairDCMOrderTime Tries to fix the order of dicoms according to their AcquisitionTime


if ~exist('IsRepair','var')
    IsRepair    = 0;
end

% Sort dicoms for acquisition time DICOM header field
clear Flist AcqTimeN AcqTime
Flist               = xASL_adm_GetFileList(InputDir,'^.*\.dcm$','list',[0 Inf]);
fprintf('%s\n','Sorting...  ');
for iL=1:length(Flist)
    xASL_TrackProgress(iL,length(Flist));
    clear tDCM
    
    try
        tDCM            = dicominfo(fullfile(InputDir,Flist{iL}));
        AcqTime{iL,1}   = Flist{iL};
        AcqTime{iL,2}   = tDCM.AcquisitionTime;
        AcqTimeN(iL,1)   = iL;
        AcqTimeN(iL,2)   = str2double(tDCM.AcquisitionTime);
    catch
        error(['Oops, ' Flist{iL} ' not a dicom file?']);
    end
end

AcqTimeN            = sortrows(AcqTimeN,2);
AcqTimeN(2:end,3)   = AcqTimeN(2:end,2) - AcqTimeN(1:end-1,2);
AcqTimeN(:,3)       = round(AcqTimeN(:,3));

% Save them again, in the correct order
% Check first if order was different than filenames
if ~(min(sort(AcqTimeN(:,1)) == AcqTimeN(:,1)))
    OrderNeedsRepairing     = 1;
else
    OrderNeedsRepairing     = 0;
end

if  IsRepair && OrderNeedsRepairing
    % First perform backup
    fprintf('%s\n','Create backup...  ')
    NewDir  = [InputDir '_Backup'];
    xASL_Copy(InputDir,NewDir);
    rmdir(InputDir,'s');
    
    fprintf('%s\n','Saving...  ')
    xASL_adm_CreateDir(InputDir);
    for iA=1:length(AcqTimeN)
        NewPath         = fullfile(InputDir  ,['DCM_' sprintf('%02d',iA) '.dcm']);
        OldPath         = fullfile(NewDir,Flist{AcqTimeN(iA,1)});
        xASL_Copy(OldPath,NewPath);
    end
    
end





end
