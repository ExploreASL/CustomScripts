%% Smooth Utrecht to the same resolution
for iS=1:length(x.S.SetsName)
    if  strcmp(x.S.SetsName{iS},'Site')
        iSet=iS;
    end
end


for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects)
    SetsOption  = x.S.SetsOptions{iSet}(x.S.SetsID(iS,iSet));
    if  ~isempty(findstr(SetsOption{1},'UMCU'))
        FilePath    = fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_1.nii']);
        if  exist(FilePath,'file') || exist([FilePath '.gz'],'file')
            %xASL_io_SaveNifti(FilePath,FilePath,dip_array(smooth(xASL_io_Nifti2Im(FilePath),0.85)) );
			xASL_io_SaveNifti(FilePath,FilePath,xASL_im_ndnanfilter(xASL_io_Nifti2Im(FilePath),'gauss',[0.85 0.85 0.85]*2.335,0));
        end
    end
end
