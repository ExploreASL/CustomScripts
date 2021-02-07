%% Resort source files Sleep 2018

ExploreASL_Master('',0);

Ddir    = 'C:\Backup\ASL\Sleep_2018\raw';
Odir    = 'C:\Backup\ASL\Sleep_2018\DataNew';

Dlist   = xASL_adm_GetFsList(Odir,'^\d{5}$',1);

for iD=1:length(Dlist)
    xASL_TrackProgress(iD,length(Dlist));
    DateList                    = xASL_adm_GetFsList(fullfile(Odir,Dlist{iD}),'^\d{8}_\d{6}$',1);
    for iL=1:length(DateList)
        OldDir                  = fullfile(Odir,Dlist{iD},DateList{iL});
        NewDir                  = fullfile(Ddir,['Sub-' Dlist{iD} '_' num2str(iL)]);
        
        xASL_adm_CreateDir(NewDir);
        
        OldDir1                 = fullfile(OldDir,'ASL');
        OldDir2                 = fullfile(OldDir,'MEMPRAGE RMS');
        NewDir1                 = fullfile(NewDir,'ASL');
        NewDir2                 = fullfile(NewDir,'MEMPRAGE RMS');
        
        xASL_Move(OldDir1, NewDir1);
        xASL_Move(OldDir2, NewDir2);

        rmdir(OldDir);
    end
    rmdir( fullfile(Odir,Dlist{iD}) );
end
