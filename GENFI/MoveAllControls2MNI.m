for iS=1:x.nSubjects
    x.P.SubjectID  = x.SUBJECTS{iS};
    x.SUBJECTDIR  = fullfile(x.D.ROOT,x.P.SubjectID);
    x.P.SessionID='ASL_1';
    x.SESSIONDIR  = fullfile(x.SUBJECTDIR,x.P.SessionID);
    
    nativeMeanControl   = fullfile(x.SESSIONDIR,'mean_control.nii');
    MNI_MeanControl     = fullfile(x.D.PopDir,['mean_control_' x.P.SubjectID '_' x.P.SessionID '.nii']);
    
    xASL_spm_deformations(x,x.P.SubjectID,nativeMeanControl,MNI_MeanControl,2);
end