%% Creating a folder with WMH_SEGM files

PRdir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/derivatives/ExploreASL_PreviousRun';
PRList = xASL_adm_GetFileList(PRdir, 'Siemens', 'FPList',[0 Inf], true);
DestDir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/rawdata/WMH_files';
xASL_adm_CreateDir(DestDir);

for iScannerPR=1:length(PRList)
    SubjList = xASL_adm_GetFileList(PRList{iScannerPR}, '^OAS', 'FPList',[0 Inf], true); %List all the WMH_SEGM files
    for iSubj=1:length(SubjList)
        [~, SubjSesName] = fileparts(SubjList{iSubj});
        [StartI, EndI] = regexp(SubjSesName, '_\d*');
        Subj=SubjSesName(1:StartI);
        Session = SubjSesName(StartI+1:EndI);
        Ses = ['ses-d',Session];
        if ~isempty(fullfile(SubjList{iSubj},'WMH_SEGM.nii.gz'));
            WMH_file=(fullfile(SubjList{iSubj},'WMH_SEGM.nii.gz'));
            WMH=dir(WMH_file);
            WMHnewname = [Subj Ses '_' WMH.name];
            DestFile= fullfile(DestDir, WMHnewname);
            xASL_Copy(WMH_file, DestFile, true);
        end
    end
end
