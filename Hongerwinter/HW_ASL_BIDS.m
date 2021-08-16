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
    [StartI, EndI] = regexp(Subj, '\d{3}$'); % the last 3 digits - subjects' number
    SubjName = ['sub-0',Subj(StartI:EndI)]; %sub-0425 e.g.
    
    DestSubjDir = fullfile(Ddir, SubjName); 
    if isempty(dir(DestSubjDir))
        xASL_adm_CreateDir(DestSubjDir); %creates a folder with the sub name
    end
    
    
    
end