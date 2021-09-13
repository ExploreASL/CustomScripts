%#### CEST data sorting ####
%
% Sorting CEST into Legacy format
%
% derivatives/ExploreASL/sub-ZZZTestPpMri501/
%                                           /T1.nii
%                                           /T1.json
%                                           /ASL_1/
%                                                 /ASL4D.nii
%                                                 /ASL4D.json
%                                           /ASL_2
%                                                 /ASL4D.nii
%                                                 /ASL4D.json
%
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
DestDir = fullfile (OrigDir,'/derivatives/ExploreASL');

SubList = xASL_adm_GetFileList(OrigDir, '^.*$', 'FPList',[0 Inf],true);

xASL_adm_CreateDir(DestDir);

for iS = 1:length(SubList)
    
    [~, SubjName] = fileparts(SubList{iS});
    
    %#### Copy T1.nii + T1.json ####
    pathT1 = xASL_adm_GetFileList(SubList{iS}, '.*_T1.nii.gz$', 'FPListRec');
    [~, T1FileName] = fileparts(pathT1{1});
    
    FileNumber = T1FileName(1); %5_T1.nii.gz correponds to 5.json
    pathT1json = xASL_adm_GetFileList(SubList{iS}, ['^' FileNumber '.json$'], 'FPListRec'); %5.json
    
    destT1 = fullfile(DestDir,SubjName, 'T1.nii.gz');
    destT1json = fullfile(DestDir,SubjName, 'T1.json');
    
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
    
    %#### Copy CEST (as ASL) ####
    pathCEST = xASL_adm_GetFileList(SubList{iS}, '.*_apt2T1.nii.gz$', 'FPListRec');
    
    if isempty(pathCEST)
        warning('Something wrong with pathCEST');
    else
        
        % Check for sessions (ses1 = ASL_1, ses2 = ASL_2)
        for iC = 1:length(pathCEST)
            if  ~isempty(regexp(pathCEST{iC}, 'ses1','ONCE'));
                dirCEST = fullfile(DestDir,SubjName, 'ASL_1');
            elseif ~isempty(regexp(pathCEST{iC}, 'ses2','ONCE'));
                dirCEST = fullfile(DestDir,SubjName, 'ASL_2');
            else
                warning('Something wrong with CEST subject-session');
            end
        end
        
        destCEST = fullfile(dirCEST, 'ASL4D.nii.gz');
        xASL_adm_CreateDir(dirCEST);
        xASL_Copy(pathCEST{iC}, destCEST, 1);
        
        
    end

end