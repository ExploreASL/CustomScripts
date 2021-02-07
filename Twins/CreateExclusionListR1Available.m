for iSubj=1:x.nSubjects
    R1_available{iSubj,1}   = x.SUBJECTS{iSubj};
    if  isempty(xASL_adm_GetFileList(x.D.PopDir,['^R1_' x.SUBJECTS{iSubj} '\.(nii|nii\.gz)$'],'List',[0 Inf]))
         R1_available{iSubj,2}   = 0;
    else R1_available{iSubj,2}   = 1;
    end
end
    

save(fullfile(x.D.ROOT,'R1_available.mat'),'R1_available');
