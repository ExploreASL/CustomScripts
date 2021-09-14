%#### CEST data sorting ####
%
% Sorting CEST into Legacy format
%
% derivatives/ExploreASL/sub-ZZZTestPpMri501/
%                                           /T1.nii
%                                           /T1.json
%                                           /ASL_1/
% ASL_1,2,3,4 = ses1                              /ASL4D.nii
% ASL_5,6 = ses2                                  /ASL4D.json
%                                           /ASL_2
%                                                 /ASL4D.nii
%                                                 /ASL4D.json
%                                           /ASL_3
%                                           /ASL_4
%                                           /ASL_5
%                                           /ASL_6
%
% Where '.*_T1\.nii$' = T1.nii
% and '.*_apt2T1\.nii$' = ASL4D.nii

clear
clc

% Start ExploreASL
pathExploreASL = '/scratch/bestevespadrela/ExploreASL3/ExploreASL';
cd(pathExploreASL);
ExploreASL;

%Data paths
OrigDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/CEST_20210713/controls/sourcedata/';
DestDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/CEST_20210713/controls/derivatives/ExploreASL';

SubList = xASL_adm_GetFileList(OrigDir, '^.*$', 'FPList',[0 Inf],true);

xASL_adm_CreateDir(DestDir);

for iS = 1:length(SubList)
    
    [~, SubjName] = fileparts(SubList{iS});
    
    %#### Copy T1.nii + T1.json ####
     pathT1 = xASL_adm_GetFileList(SubList{iS}, '.*_T1.nii.gz$', 'FPListRec');
    [~, T1FileName] = fileparts(pathT1{1});
    
    FileNumber = T1FileName(1); %5_T1.nii.gz correponds to 5.json
    pathT1json = xASL_adm_GetFileList(SubList{iS}, ['^' FileNumber '.json$'], 'FPListRec'); %5.json
    
    destT1 = fullfile(DestDir,['sub-' SubjName], 'T1.nii.gz');
    destT1json = fullfile(DestDir,['sub-' SubjName], 'T1.json');
    
    if length(pathT1)~=1 %should have one T1 for each subject
        warning('Something wrong with T1.nii path');
    else
        xASL_Copy(pathT1{1}, destT1, 1);
    end
    
    if length(pathT1json)~=1
        warning('Something wrong with T1.json path');
    else
        xASL_Copy(pathT1json{1}, destT1json, 1);
    end
    
    %#### Copy CEST (as ASL) for ses1 ####
    pathCEST1 = xASL_adm_GetFileList(fullfile(SubList{iS},'ses1'), '.*_apt2T1.nii.gz$', 'FPListRec');
    
    CESTfileNumbersSes1 = cell(1,length(pathCEST1));
    
    for iC = 1:length(pathCEST1) %we need to take the numbers form the file names to sort them
        
        [FilePath1, FileName] = fileparts(pathCEST1{iC});
        [StartI, ~] = regexp(FileName, '_');
        FileNumber = FileName(1:StartI-1);
        CESTfileNumbersSes1{iC} = FileNumber;
        
    end
    
    FilesNumbersSorted1 = sort(str2double(CESTfileNumbersSes1));
    LegacyASLNames = {'ASL_1' 'ASL_2' 'ASL_3' 'ASL_4'}; % we have 4 CEST for ses1
    
    for iNS = 1:length(FilesNumbersSorted1)
        
        dirCEST1 = fullfile(DestDir,['sub-' SubjName], LegacyASLNames{iNS});
        destCEST1 = fullfile(dirCEST1, 'ASL4D.nii.gz');
        xASL_adm_CreateDir(dirCEST1);
        
        origCEST1 = fullfile (FilePath1,[num2str(FilesNumbersSorted1(iNS)) '_apt2T1.nii']);
        xASL_Copy(origCEST1, destCEST1, 1);
        
    end
    
    %#### Copy CEST (as ASL) for ses2 ####
    pathCEST2 = xASL_adm_GetFileList(fullfile(SubList{iS},'ses2'), '.*_apt2T1.nii.gz$', 'FPListRec');
    
    CESTfileNumbersSes2 = cell(1,length(pathCEST2));
    
    for iC = 1:length(pathCEST2)
        
        [FilePath2, FileName] = fileparts(pathCEST2{iC});
        [StartI, ~] = regexp(FileName, '_');
        FileNumber = FileName(1:StartI-1);
        CESTfileNumbersSes2{iC} = FileNumber;
        
    end
    
    FilesNumbersSorted2 = sort(str2double(CESTfileNumbersSes2));
    LegacyASLNames = {'ASL_5' 'ASL_6'}; % we have 2 CEST for ses2
    
    for iNS = 1:length(FilesNumbersSorted2)
        
        dirCEST2 = fullfile(DestDir,['sub-' SubjName], LegacyASLNames{iNS});
        destCEST2 = fullfile(dirCEST2, 'ASL4D.nii.gz');
        xASL_adm_CreateDir(dirCEST2);
        
        origCEST2 = fullfile (FilePath2,[num2str(FilesNumbersSorted2(iNS)) '_apt2T1.nii']);
        xASL_Copy(origCEST2, destCEST2, 1);
        
    end
    
end