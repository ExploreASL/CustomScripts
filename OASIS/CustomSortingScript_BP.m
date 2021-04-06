%% Custom Sorting script_BP

ExploreASL_Master('',0);

Odir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/test_sourcedata/';
Ddir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/rawdata';

xASL_adm_CreateDir(Ddir);
Slist1 = xASL_adm_GetFileList(Odir, '^OAS\d*', 'FPList',[0 Inf], true);

fprintf('Converting OASIS data to ExploreASL-compatible:   ');
iElement=1;

for iS1=1:length(Slist1)
    xASL_TrackProgress(iS1, length(Slist1));
    clear DestSubjDir
    %== Create a directory with the name of the subject ==%
    [~, SubjName] = fileparts(Slist1{iS1});
    sub = ['sub-',SubjName]; % in a separate var to be used in file naming
    DestSubjDir = fullfile(Ddir, sub); % ending with /sub-OAS30001
    xASL_adm_CreateDir(DestSubjDir);
    
    MRlist = xASL_adm_GetFileList(Slist1{iS1}, '^OAS\d*_MR_.*', 'FPList',[0 Inf], true); %identifies the MR folders inside the subject's folder
    for iMR=1:length(MRlist)
        if ~isempty(xASL_adm_GetFileList(MRlist{iMR}, '.*asl\.nii$', 'FPListRec',[0 Inf])) && ~isempty(xASL_adm_GetFileList(MRlist{iMR}, '.*T1w\.nii$', 'FPListRec',[0 Inf])) %goes through all the folders to find the T1 and asl files
            % if contains asl & T1w
            clear DestDir DestFile
            %== Create a subfolder with the name of the session ==%
            [~, SubjSesName] = fileparts(MRlist{iMR}); %subj+session name
            [StartI, EndI] = regexp(SubjSesName, '_d\d*');
            Session = SubjSesName(StartI+1:EndI);
            ses = ['ses-',Session]; % in a separate var to be used in file naming
            DestSubjSesDir = fullfile(DestSubjDir, ses); %.../OAS30001/ses2430
            xASL_adm_CreateDir(DestSubjSesDir);
            
            % BIDS folder -> dataset_description.JSON file
            BIDSfolder = xASL_adm_GetFileList(MRlist{iMR}, 'BIDS$', 'FPList',[0 Inf], true);
            JSONlist = xASL_adm_GetFileList(BIDSfolder, '\.json$', 'FPList',[0 Inf]);
            DestFile = fullfile(DestSubjSesDir, ['dataset_description.json']);
            xASL_Copy(JSONlist{1}, DestFile, true);
            
            % Scan folders (anat1, anat2, fmap1, fmap2, anat3, etc)
            ScanList = xASL_adm_GetFileList(MRlist{iMR}, '^.*\d$', 'FPList',[0 Inf], true);
            for iScan=1:length(ScanList)
                NiftiDir = fullfile(ScanList{iScan}, 'NIFTI');
                BIDSDir = fullfile(ScanList{iScan}, 'BIDS');
                ScanType = {'T1w','FLAIR','asl' 'fieldmap','TOF_angio', 'swi'}; % DICOM name
                SubDirName = {'anat' 'anat' 'perf' 'fmap' 'other' 'other'}; %these empty spaces can be 'Other' for TOF and swi
                FileName = {'T1' 'FLAIR' 'ASL4D' 'fieldmap' 'TOF_angio' 'swi'};
                for iType=1:length(ScanType)
                    
                    % == Inside NIFTI folder (to get scan.niis)  == %
                    NIIlist = xASL_adm_GetFileList(NiftiDir, ['.*' ScanType{iType} '\.nii$'], 'FPList',[0 Inf]);
                    if ~isempty(NIIlist)
                        for iNii=1:length(NIIlist) %this is only>1 if there is more than 1 scantype (ex:2 T1s)
                            [~, ScanTypeName] = fileparts(NIIlist{iNii});
                            clear DestDir DestFile
                            if iNii==1
                                DestDir = fullfile(DestSubjSesDir, SubDirName{iType});
                                if ~isempty(regexp(ScanTypeName, '_run-','ONCE'))
                                    [StartI, EndI] = regexp(ScanTypeName, '_run-\d*');
                                    run= ScanTypeName(StartI:EndI);
                                    DestFile = fullfile(DestDir, [sub, '_', ses, run, '_', FileName{iType} '.nii.gz']);
                                else
                                    DestFile = fullfile(DestDir, [sub, '_', ses, '_', FileName{iType} '.nii.gz']);
                                end
                            elseif iNii>1
                                DestDir = DestSubjSesDir;
                                DestFile = fullfile(DestDir, [sub, '_', ses, '_', FileName{iType} '_' num2str(iNii) '.nii.gz']);
                            else
                                warning(['Didnt know what to do for ' NIIlist{iNii}]);
                            end
                            
                            xASL_adm_CreateDir(DestDir);
                            xASL_Copy(NIIlist{iNii}, DestFile, true);
                        end
                    end
                    
                    % == Inside BIDS folder (to get scan.jsons) ==%
                    BIDSlist = xASL_adm_GetFileList(BIDSDir, ['.*' ScanType{iType} '\.json$'], 'FPList',[0 Inf]);
                    if ~isempty(BIDSlist)
                        for iBids=1:length(BIDSlist)
                            [~, JsonScanTypeName] = fileparts(BIDSlist{iBids});
                            clear DestDir DestFile
                            if iBids==1
                                DestDir = fullfile(DestSubjSesDir, SubDirName{iType});
                                if ~isempty(regexp(JsonScanTypeName, '_run-','ONCE'))
                                    [StartI, EndI] = regexp(JsonScanTypeName, '_run-\d*');
                                    run= JsonScanTypeName(StartI:EndI);
                                    DestFile = fullfile(DestDir, [sub, '_', ses, run, '_', FileName{iType} '.json']);
                                else
                                    DestFile = fullfile(DestDir, [sub, '_', ses, '_', FileName{iType} '.json']);
                                end
                            elseif iBids>1
                                DestDir = DestSubjSesDir;
                                DestFile = fullfile(DestDir, [sub, '_', ses, '_', FileName{iType} '_' num2str(iBids) '.json']);
                            else
                                warning(['Didnt know what to do for ' BIDSlist{iBids}]);
                            end
                            
                            xASL_adm_CreateDir(DestDir);
                            xASL_Copy(BIDSlist{iBids}, DestFile, true);
                            
                            
                            if strcmp(ScanType{iType},'T1w') % Extract information from first scan every time -> with this '_' before T1w it works with the runs
                                json = spm_jsonread(BIDSlist{iBids});
                                if isempty(regexp(ScanTypeName, '_run-0[2-9]|d+$','ONCE')) %digit>1 , between 2-9
                                    if isfield(json,'ManufacturersModelName')
                                        scannerList{iElement,1} = sub;
                                        scannerList{iElement,2} = ses;
                                        scannerList{iElement,3} = [json.Manufacturer '_' json.ManufacturersModelName '_' json.DeviceSerialNumber '_' json.SoftwareVersions];
                                        iElement = iElement+1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
              % UNCOMMENT FOR DERIVATIVES %
            
%             % == Copying the WMH_SEG from OASIS/derivatives/ExploreASL_PreviousRun ==
%             % FIRST RUN 'renameWMH_SEGMfiles.m'
%             clear WMHsesList
%             WMHfilesDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/rawdata/WMH_files';
%             WMHsesList= xASL_adm_GetFileList(WMHfilesDir, [SubjName '_' ses '\_WMH_SEGM.nii.gz$'], 'FPList',[0 Inf]); %List all the WMH_SEGM files with the ses of the subject
%             if ~isempty (WMHsesList)
%                 for i=1:length(WMHsesList)
%                     [~, WMHsesname] = fileparts(WMHsesList{i});
%                     DestFile= fullfile(DestSubjSesDir, WMHsesname);
%                     xASL_Copy(WMHsesList{i}, DestFile, true);
%                 end
%             end
        end
    end
end


scanners = unique(scannerList(:,3));
root = Ddir;

NoASLDest=fullfile(root,'SubjectsWithoutASL'); %Create a folder for subjects with no ASL scans
xASL_adm_CreateDir(NoASLDest);

for iScanner = 1:length(scanners)
    
    % Create the output directory for the current scanner type
   
    FinalDest_Temp=fullfile(root,scanners{iScanner});
    xASL_adm_CreateDir(FinalDest_Temp);
    
    
    % Copy all subjects that have this type to the directory
    for i = 1:size(scannerList,1)
        if strcmp(scannerList{i,3},scanners{iScanner})
            source = fullfile(root,scannerList{i,1},scannerList{i,2});
            ASL_dir=fullfile(source, 'perf');
            ASLfile_find=xASL_adm_GetFileList(ASL_dir, '\ASL4D.nii.gz$', 'FPList',[0 Inf]); %check if ther
            if isempty (ASLfile_find)
                FinalDest = fullfile(NoASLDest, scannerList{i,1},scannerList{i,2});
            else
                FinalDest = fullfile(FinalDest_Temp, scannerList{i,1},scannerList{i,2});
            end
            
            xASL_Move(source,FinalDest,true); % Use the recursive option
        end
    end
end