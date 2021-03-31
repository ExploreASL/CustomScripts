%% Renaming WMH_SEGM files

PRdir = '/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/derivatives/ExploreASL_PreviousRun';
PRList = xASL_adm_GetFileList(PRdir, 'Siemens', 'FPList',[0 Inf], true);

for iScannerPR=1:length(PRList)
    SubjList = xASL_adm_GetFileList(PRList{iScannerPR}, '^OAS', 'FPList',[0 Inf], true);
    WMH_SEGMList=1;
    for iSubj=1:length(SubjList)
        [~, SubjSesName] = fileparts(SubjList{iSubj});
        [StartI, EndI] = regexp(SubjSesName, '_\d*');
        Subj=SubjSesName(1:StartI);
        Session = SubjSesName(StartI+1:EndI);
        Ses = ['ses-',Session];
        WMH=dir(fullfile(SubjList{iSubj},'WMH_SEGM.nii.gz'));
        WMHnewname = [Subj Ses '_' WMH.name];
        movefile(WMH.name, WMHnewname);
    end
end