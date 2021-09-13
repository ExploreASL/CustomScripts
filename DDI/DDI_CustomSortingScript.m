%% Custom Sorting script - DDI data

ExploreASL_Master('',0);

BasePath = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/DDI';
Odir = fullfile(BasePath,'ASL_dicoms');
Ddir = fullfile(BasePath,'sourcedata');

xASL_adm_CreateDir(Ddir);
%Slist1 = xASL_adm_GetFileList(Odir, '^D1\d{4}', 'FPList',[0 Inf], true);
Slist1 = xASL_adm_GetFileList(Odir, '^D', 'FPList',[0 Inf], true);

fprintf('Converting DDI data to ExploreASL-compatible:   ');
iElement=1;
% 
% for iS1=1:length(Slist1)
%     xASL_TrackProgress(iS1, length(Slist1));
%     clear DestSubjDir
%     %== Create a directory with the name of the subject ==%
%     [~, Subj] = fileparts(Slist1{iS1});
%     [StartI, EndI] = regexp(Subj, '-\d*|\D-\d*'); % -digit or letter-digit
%     SubjName = Subj(1:StartI-1); %D10001
%     SessionName = Subj(1:length(Subj)); %D10001M-2
%     Sessions{iS1} = SessionName; 
%     
%     DestSubjDir = fullfile(Ddir, SubjName); % ending with /D10001
%     if isempty(dir(DestSubjDir))
%         xASL_adm_CreateDir(DestSubjDir);
%     end
%     
%     DestSubjSesDir = fullfile(DestSubjDir,SessionName); % ending with /D10001M-2
%     
%     xASL_adm_CreateDir(DestSubjSesDir);
%     %If the folder already exists, skip the next part (to be faster to repeat this script only for some of the subjects)
%     
%     SubjFolderList = xASL_adm_GetFileList(Slist1{iS1}, '^1*', 'FPList',[0 Inf], true); %identifies folders inside the subject's folder
%     for iF=1:length(SubjFolderList)
%         DicomsList = xASL_adm_GetFileList(SubjFolderList{iF});
%         DR = xASL_io_DcmtkRead (DicomsList{1});
%         Scan = DR.SeriesDescription;
%         if ~isempty(regexpi(Scan,'PCASL')) %ASL folder with 1400 DICOMs
%             DestASLDir = fullfile(DestSubjSesDir, 'ASL');
%             xASL_adm_CreateDir(DestASLDir);
%             xASL_Copy(SubjFolderList{iF}, DestASLDir, true);
%             
%         elseif ~isempty(regexpi(Scan,'M0')) %M0 DICOMs
%             DestM0Dir = fullfile(DestSubjSesDir, 'M0');
%             xASL_adm_CreateDir(DestM0Dir);
%             xASL_Copy(SubjFolderList{iF}, DestM0Dir, true);
%             
%         elseif ~isempty(regexpi(Scan,'PCA5NEX')) %Labeling plane scans
%             DestLPSDir = fullfile(DestSubjSesDir, 'LabelingPlaneScans');
%             xASL_adm_CreateDir(DestLPSDir);
%             xASL_Copy(SubjFolderList{iF}, DestLPSDir, true);
%             
%         elseif ~isempty(regexpi(Scan,'Perfusion_Weighted')) %Perfusion Weighted scans
%             DestPWDir = fullfile(DestSubjSesDir, 'PerfusionWeightedScans');
%             xASL_adm_CreateDir(DestPWDir);
%             xASL_Copy(SubjFolderList{iF}, DestPWDir, true);
%             
%         elseif ~isempty(regexpi(Scan,'relCBF')) %rel CBF scans
%             Dest_rBCFDir = fullfile(DestSubjSesDir, 'relCBFScans');
%             xASL_adm_CreateDir(Dest_rBCFDir);
%             xASL_Copy(SubjFolderList{iF}, Dest_rBCFDir, true);
%         else
%             fprintf(['warning: unexpected scan:', Scan, 'saving it in a folder called OtherScans']);%warning if none of the cases
%             Dest_OthersDir = fullfile(DestSubjSesDir, 'OtherScans');
%             xASL_adm_CreateDir(Dest_OthersDir);
%             xASL_Copy(SubjFolderList{iF}, Dest_OthersDir, true);
%         end
%         
%     end
%     
% end

%% T1 & FLAIR
% == T1 ==

T1dir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/DDI/T1_nii';
T1List = xASL_adm_GetFileList(T1dir, '\.nii$', 'FPList',[0 Inf]);
T1txtList = xASL_adm_GetFileList(T1dir, '\.txt$', 'FPList',[0 Inf]);
%  length(T1List) = 620

for iT=1:length(Slist1) 
    [~, SubjT1] = fileparts(T1List{iT});
    [StartT, EndT] = regexp(SubjT1, '-\d*|\D-\d*'); % -digit or letter-digit
    SubjNameT = SubjT1(1:StartT-1);
    SessionNameT = SubjT1(1:EndT);
    
    txtdir = T1txtList{iT};
    readText=readTextFile(txtdir);
    txt=convert2subjectValuePairs(readText);

    scannerlist{iT,1} = SubjNameT;
    scannerlist{iT,2} = SessionNameT;
    scannerlist{iT,3} = [txt.Manufacturer '_' txt.ModelName '_' strrep(txt.SoftwareVersion,'\','_')];
   
%     if ~isempty(strcmp(SessionNameT,Sessions))
%         indT1 = find(strcmp(SessionNameT,Sessions));
%         SesT1 = Sessions{indT1};
%         T1DestDir = fullfile(Ddir,SubjNameT,SesT1,'T1');
%         xASL_Copy(T1List{iT},T1DestDir,true); % Copies T1.nii file
%         T1txtDestDir = fullfile(Ddir,SubjNameT,SesT1, 'T1.txt');
%         xASL_Copy(T1txtList{iT},T1txtDestDir,true); % Copies T1.txt also
%     end
end

% == FLAIR ==

FLAIRdir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/DDI/FLAIR_nii';
FLAIRList = xASL_adm_GetFileList(FLAIRdir, '\.nii$', 'FPList',[0 Inf]);
FLAIRtxtList = xASL_adm_GetFileList(FLAIRdir, '\.txt$', 'FPList',[0 Inf]);
%  length(FLAIRList) = 620

for iF=1:length(Slist1)
    [~, SubjF] = fileparts(FLAIRList{iF});
    [StartF, EndF] = regexp(SubjF, '-\d*|\D-\d*'); % -digit or letter-digit
    SubjNameF = SubjF(1:StartF-1);
    SessionNameF = SubjF(1:EndF);
   
    if ~isempty(strcmp(SessionNameF,Sessions))
        indF = find(strcmp(SessionNameF,Sessions));
        SesF = Sessions{indF};
        FLAIRDestDir = fullfile(Ddir,SubjNameF,SesF, 'FLAIR');
        xASL_Copy(FLAIRList{iF},FLAIRDestDir,true); % Copies T1.nii file
        FLAIRtxtDestDir = fullfile(Ddir,SubjNameF,SesF, 'FLAIR.txt');
        xASL_Copy(FLAIRtxtList{iF},FLAIRtxtDestDir,true); % Copies T1.txt also 
    end
end

fprintf('T1 & FLAIR data sorting finished   ');

%% Create scanners' folders

%xASL_io_DcmtkRead
scanners = unique(scannerlist(:,3));
root = fullfile(BasePath, 'DDI_sorted_August');

NoASLDest = fullfile (root,'SubjectsWithoutASL');
xASL_adm_CreateDir(NoASLDest);

for iScanner = 1:length(scanners) 
    xASL_TrackProgress(iScanner, length(scanners));
    clear FinalDest

    % Copy all subjects that have this type to the directory
    for iElement = 1:size(scannerlist,1)
        if strcmp(scannerlist{iElement,3},scanners{iScanner})
            source = fullfile(Ddir,scannerlist{iElement,1},scannerlist{iElement,2});
            
            ASLfolder_find=xASL_adm_GetFileList(source, '^ASL', 'FPList',[0 Inf],true); % true for folders
            if isempty (ASLfolder_find)
                FinalDest = fullfile(NoASLDest, 'sourcedata',scannerlist{iElement,1},scannerlist{iElement,2});
            else
                % If ASL is present, create the output directory for the current scanner type
                ScannerDest=fullfile(root,scanners{iScanner});
                xASL_adm_CreateDir(ScannerDest);
                FinalDest = fullfile(ScannerDest, 'sourcedata',scannerlist{iElement,1},scannerlist{iElement,2});
            end
            
            xASL_adm_CreateDir(FinalDest);
            xASL_Copy(source,FinalDest,true); % Use the recursive option
        end
        
    end
    
end

