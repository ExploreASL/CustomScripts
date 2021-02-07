% Create list CMI
RootDir     = 'C:\Backup\ASL\Hardy\CMI_substudy';
Dlist       = xASL_adm_GetFsList(RootDir,'^HD\d{3}_(1|2)$',1);
for iD=1:length(Dlist)
    xASL_TrackProgress(iD,length(Dlist));
    CMIcount{iD,1}          = Dlist{iD};
    CMIcountTemp            = 0;
    for iC=1:44
        if ~isempty(xASL_adm_GetFileList(fullfile(RootDir,Dlist{iD}),['ROI.*' num2str(iC) '\.(nii|nii\.gz)$'],'List',[0 Inf]))
        CMIcountTemp        = CMIcountTemp + 1;
        end
    end
    if  CMIcountTemp==0
        CMI_YesNo(iD,1)     = 0;
    else
        CMI_YesNo(iD,1)     = 1;
    end
    CMIcount{iD,2}          = CMIcountTemp;
end
    
