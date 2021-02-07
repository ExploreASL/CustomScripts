FLAIRdir    = 'C:\Backup\ASL\Score\flair';

for iS=1:x.nSubjects
    Dir1    = fullfile(FLAIRdir,[x.SUBJECTS{iS} '_1']);
    Dir2    = fullfile(FLAIRdir,[x.SUBJECTS{iS} '_2']);
    xASL_adm_CreateDir(Dir1);
    xASL_adm_CreateDir(Dir2);
    
%     Flist   = xASL_adm_GetFileList(FLAIRdir,['^nu_SCORE_' x.SUBJECTS{iS} '_2-FLAIR.*\.(nii|nii\.gz)$']);
    Flist   = xASL_adm_GetFileList(FLAIRdir,['^nu_SCORE_' x.SUBJECTS{iS} '-FLAIR.*\.(nii|nii\.gz)$']);
    if  length(Flist)==1
        xASL_Move(Flist{1},fullfile(Dir1, 'FLAIR.nii'));
    end
end

for iS=1:x.nSubjects
    Dir1    = fullfile(FLAIRdir,[x.SUBJECTS{iS} '_1']);
    Dir2    = fullfile(FLAIRdir,[x.SUBJECTS{iS} '_2']);
    xASL_adm_CreateDir(Dir1);
    xASL_adm_CreateDir(Dir2);
    
    OriDir1     = fullfile(x.D.ROOT,x.SUBJECTS{iS},'ASL_1');
    OriDir2     = fullfile(x.D.ROOT,x.SUBJECTS{iS},'ASL_2');
    
    ASL1        = fullfile(OriDir1,'ASL4D.nii');
    ASL2        = fullfile(OriDir2,'ASL4D.nii');
    ASL1parms   = fullfile(OriDir1,'ASL4D_parms.mat');
    ASL2parms   = fullfile(OriDir2,'ASL4D_parms.mat'); 
    
    ASL1dirnew  = fullfile(Dir1,'ASL_1');
    ASL2dirnew  = fullfile(Dir2,'ASL_1');
    xASL_adm_CreateDir(ASL1dirnew);
    xASL_adm_CreateDir(ASL2dirnew);    
    
    if  exist(ASL1,'file')    
        xASL_Move(ASL1,fullfile(ASL1dirnew,'ASL4D.nii'));
        xASL_Move(ASL1parms,fullfile(ASL1dirnew,'ASL4D_parms.mat'));
    end
    
    if  exist(ASL2,'file')
        xASL_Move(ASL2,fullfile(ASL2dirnew,'ASL4D.nii'));    
        xASL_Move(ASL2parms,fullfile(ASL2dirnew,'ASL4D_parms.mat')); 
    end
  
end

% RestoreOrientation
Flist   = xASL_adm_GetFileList(FLAIRdir,'^ASL4D\.(nii|nii\.gz)$', 'FPListRec');
for iL=1:length(Flist)
    RestoreOrientation(Flist{iL});
end



