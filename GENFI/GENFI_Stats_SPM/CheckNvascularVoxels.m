%% Check nVoxels vascular treatment: negative & positive compressed

ROOTdir         = fullfile(x.D.PopDir,'DiffvascTreat'); 

% DiffImage = Treated-Untreated

for iS=1:x.nSubjects
    clear FileName IM
    FileName        = fullfile(ROOTdir,['diff_vasc_treat_' x.SUBJECTS{iS} '_ASL_1.nii']);
    IM              = xASL_nifti(FileName);
    IM              = IM.dat(:,:,:);
    nVoxels(iS,1)   = sum(sum(sum( IM<-1.1 | IM>1.1 & x.skull)));
end

mean(nVoxels)/sum(x.skull(:))
std(nVoxels)/sum(x.skull(:))
size(nVoxels)

