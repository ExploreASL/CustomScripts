ODIR    = 'C:\Backup\ASL\BoleStudien\Bolestudie';
DDIR    = 'C:\Backup\ASL\BoleStudien\Excluded';

load(fullfile(ODIR,'age.mat'));
LoadL   = age(:,1);

List    = xASL_adm_GetFsList(ODIR,'^\d{3}$',1);
for iL=1:length(List)
    xASL_TrackProgress(iL,length(List));
    FoundDir    = 0;
    for iL2=1:length(LoadL)
        if  str2num(List{iL})==LoadL{iL2}
            FoundDir    = 1;
        end
    end
            
    if ~FoundDir
        iDir    = fullfile(ODIR,List{iL});
        oDir    = fullfile(DDIR,List{iL});
        xASL_Move(iDir,oDir);
    end
end
