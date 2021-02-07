%% Store CBF for Inge2 check

IngeOut     = 'C:\Backup\ASL\BoleStudien\OutInge';
Ind         = 'C:\Backup\ASL\BoleStudien\Bolestudie';
Dlist       = xASL_adm_GetFsList(Ind,'^\d{3}$',1);

for iL=1:length(Dlist)
    xASL_TrackProgress(iL,length(Dlist));
    iPath   = fullfile(Ind    ,Dlist{iL},'ASL_1','CBF.nii.gz');
    oPath   = fullfile(IngeOut,['CBF' num2str(iL) '.nii.gz']);
    
    if  xASL_exist(iPath,'file') && ~xASL_exist(oPath,'file')
        xASL_Copy(iPath,oPath);
    end
end
