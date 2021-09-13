%% Custom Sorting script - Hunger Winter cohort (Dutch Famine study)

ExploreASL_Master('',0);

BIDSPath = '/home/bestevespadrela/lood_storage/divi/Projects/hw_2019/BIDS';

Odir= '/home/bestevespadrela/lood_storage/divi/Projects/hw_2019/incoming/dicom/';
Ddir = fullfile(BIDSPath,'sourcedata_ASL/');

SubList = xASL_adm_GetFileList(Odir, '\d$', 'FPList',[0 Inf], true); %81 subjects -> subjects' folders end with a number

fprintf('Converting ASL data from HungerWinter cohort to BIDS-compatible:   ');


for iS=1:length(SubList)
    xASL_TrackProgress(iS, length(SubList));
    clear DestSubjDir
    %== Create a directory with the name of the subject ==%
    [~, Subj] = fileparts(SubList{iS});
    [StartI, EndI] = regexp(Subj, '\d{2,}$'); % the last 3 digits - subjects' number
    if length(Subj(StartI:EndI)) ==2
        SubjName = ['sub-00',Subj(StartI:EndI)]; %if sub-30 -> sub-0030
    elseif length(Subj(StartI:EndI)) ==3
        SubjName = ['sub-0',Subj(StartI:EndI)]; %if sub-123 -> sub-0123
    else %4 digits
        SubjName = ['sub-',Subj(StartI:EndI)]; %sub-0425 e.g.
    end
    
    DestSubjDir = fullfile(Ddir, SubjName); 
    if isempty(dir(DestSubjDir))
        xASL_adm_CreateDir(DestSubjDir); %creates a folder with the sub name
    end
    
    %MR folder has zips with the scans
    MRList = xASL_adm_GetFileList(SubList{iS}, '^MR', 'FPListRec',[0 Inf], true); 
    
    if ~isempty(MRList)
        ScansZipList = xASL_adm_GetFileList(MRList{1}, 'zip$', 'FPListRec',[0 Inf]);  %There should be only one MR folder
        
        for iSc = 1:length(ScansZipList)
            
            if ~isempty(regexpi(ScansZipList{iSc},'(M0|ASL|MPRAGE|FLAIR'))
                
                [ScanPath,ScanName,~] = fileparts(ScansZipList{iSc});
                ScanUnzip = unzip(ScansZipList{iSc},ScanPath);
                [ScanUnzipPath,~,~] = fileparts(ScanUnzip{1});
                
                [StartI, EndI] = regexp(ScanName, '\d*_'); %ScanName = 00901_ASL
                ScanName = ScanName(EndI+1:end); %ScanName = ASL
                
                %DestScanDir = fullfile(DestSubjDir, ScanName); 
                % We could create a folder to every type of scan, 
                % but below I only have the ones I need for ASL processing
                
                if ~isempty(regexpi(ScanName,'M0'))
                DestScanDir = fullfile(DestSubjDir, 'M0'); %folder named M0
                elseif ~isempty(regexpi(ScanName,'ASL'))
                DestScanDir = fullfile(DestSubjDir, 'ASL');
                elseif ~isempty(regexpi(ScanName,'MPRAGE'))
                DestScanDir = fullfile(DestSubjDir, 'T1');
                elseif ~isempty(regexpi(ScanName,'FLAIR'))
                DestScanDir = fullfile(DestSubjDir, 'FLAIR');
                end
                
                xASL_adm_CreateDir(DestScanDir);
                xASL_Copy(ScanUnzipPath, DestScanDir, true);
                
            end
        end
    end
    
    
end