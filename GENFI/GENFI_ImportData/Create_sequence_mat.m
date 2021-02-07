%% Create Sequence.mat

ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis';
Dlist       = xASL_adm_GetFsList(ROOT, '^.*(C9ORF|GRN|MAPT).*_\d$',1);

for iS=1:length(Dlist)
    Sequence{iS,1}  = Dlist{iS};
    
    if     ~isempty(findstr(Dlist{iS},'GE'))
            Sequence{iS,2}  = '3D_spiral';
    elseif ~isempty(findstr(Dlist{iS},'PH_Achieva_Bsup'))
            Sequence{iS,2}  = '2D_EPI_Bsup';
    elseif ~isempty(findstr(Dlist{iS},'PH_Achieva_noBsup'))
            Sequence{iS,2}  = '2D_EPI_noBsup';
    elseif ~isempty(findstr(Dlist{iS},'SI_'))
            Sequence{iS,2}  = '3D_GRASE';
    end
end

save(fullfile(ROOT,'Sequence.mat'),'Sequence');
