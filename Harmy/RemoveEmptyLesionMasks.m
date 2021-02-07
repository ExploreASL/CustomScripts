DDIR    = 'C:\Backup\ASL\Hardy\CMI_substudy';

Dlist   = xASL_adm_GetFsList(DDIR,'^HD\d{3}_1$',1,[],[],[0 Inf]);

for iL=1:length(Dlist)
    xASL_TrackProgress(iL,length(Dlist));
    NewName         = fullfile(DDIR,Dlist{iL},'Lesion_FLAIR_1.nii');
    if  exist(NewName)
        if  xASL_stat_SumNan(xASL_stat_SumNan(xASL_stat_SumNan(xASL_io_Nifti2Im(NewName))))==0
            delete(NewName);
        end
    end
end
