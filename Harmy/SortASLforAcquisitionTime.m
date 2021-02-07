ROOT            = 'C:\Backup\ASL\Hardy\raw';
SUBJECTS        = xASL_adm_GetFsList(ROOT, '^HD\d{3}_(1|2)$',1)';

% % Acquiring data structure information
% fprintf('%s\n','Running...  ');
% for iS=1:length(SUBJECTS)
%     xASL_TrackProgress(iS,length(SUBJECTS));
%     SubjDir             = fullfile(ROOT,SUBJECTS{iS});
%     ASLlist             = xASL_adm_GetFsList(SubjDir,'^.*PCASL.*$',1,[],[],[0 Inf])';
%     TotalList{iS,1}     = SUBJECTS{iS};
%     TotalList(iS,2:length(ASLlist)+1)     = ASLlist;
% end
% fprintf('\n');
        
% Re-ordering

for iS=1:length(SUBJECTS)
    fprintf(['Subject ' num2str(iS) ': ']);
    clear SubjDir ASLlist ASLdirTemp status
    SubjDir             = fullfile(ROOT,SUBJECTS{iS});
    ASLlist             = xASL_adm_GetFsList(SubjDir,'^.*PCASL.*$',1,[],[],[0 Inf])';
    
    if length(ASLlist)>0

        % Put all dicoms into temporary ASL directory
        ASLdirTemp          = fullfile(SubjDir,'ASL_Temp');
        xASL_adm_CreateDir(ASLdirTemp);

        fprintf('%s\n','Moving to temp...  ');
        for iA=1:length(ASLlist)
            clear ASLdirOri Flist
            ASLdirOri       = fullfile(SubjDir,ASLlist{iA});
            Flist           = xASL_adm_GetFileList(ASLdirOri,'^.*$','FPlist',[0 Inf]);
            for iL=1:length(Flist)
                xASL_TrackProgress((iA-1)+iL,iA*length(Flist));
                [Fpath Ffile Fext]  = fileparts(Flist{iL});
                xASL_Move(Flist{iL},fullfile(ASLdirTemp,[Ffile Fext]));
            end
            rmdir(ASLdirOri);
        end

        % Sort dicoms for acquisition time DICOM header field
        clear Flist AcqTimeN
        Flist               = xASL_adm_GetFileList(ASLdirTemp,'^.*$','FPlist',[0 Inf]);
        fprintf('%s\n','Sorting...  ');
        for iL=1:length(Flist)
            xASL_TrackProgress(iL,length(Flist));
            clear tDCM
            try
                tDCM            = dicominfo(Flist{iL});
                AcqTimeN(iL,1)  = iL;
                AcqTimeN(iL,2)  = str2double(tDCM.AcquisitionTime)/10000;
            catch
                error(['Oops, ' Flist{iL} ' not a dicom file?']);
            end
        end

        clear nASL
        nASL                = length(AcqTimeN)/46;

        AcqTimeN            = sortrows(AcqTimeN,2);
        AcqTimeN(2:end,3)   = AcqTimeN(2:end,2) - AcqTimeN(1:end-1,2);
        AcqTimeN(:,3)       = round(AcqTimeN(:,3)*100000);


        % Save them again, in the correct order
        fprintf('%s\n','Saving...  ')
        for iA=1:floor(nASL)

            clear ASLdir
            ASLdir          = fullfile(SubjDir,['ASL_' num2str(iA)]);
            xASL_adm_CreateDir(ASLdir);
            for iL=1:46
                clear DicomN OldFileN OldFile NewFile
                DicomN      = (iA-1)*46+iL;
                xASL_TrackProgress(DicomN,nASL*46);
                OldFileN    = AcqTimeN(DicomN,1);
                OldFile     = Flist{OldFileN};
                NewFile     = fullfile(ASLdir,[sprintf('%0.5d',iL) '.dcm']);
                xASL_Move(OldFile,NewFile);
            end
        end

        if  length(xASL_adm_GetFileList(ASLdirTemp,'^.*$',[],[0 Inf]))>0
            xASL_Rename(ASLdirTemp,'ASL_residualDicoms');
        else    
            rmdir(ASLdirTemp);
        end
        fprintf('\n');
    end
end
    
    
