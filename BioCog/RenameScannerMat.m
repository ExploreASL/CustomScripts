Scanner     = Site;

for iS=1:length(Site)
    if      strcmp(Site{iS,3},'Old_MR')
            Scanner{iS,3}   = 'UMCU_MR7';
    elseif  strcmp(Site{iS,3},'New_MR')
            Scanner{iS,3}   = 'UMCU_MR8';
    end
    if      strcmp(Scanner{iS,2},'ASL_1')
            Scanner{iS,1}      = [Scanner{iS,1} '_1'];
    elseif  strcmp(Scanner{iS,2},'ASL_2')
            Scanner{iS,1}      = [Scanner{iS,1} '_2'];
    end
end

ROOT    = 'C:\Backup\ASL\BioCog\BERLIN_DF1';
Dlist   = xASL_adm_GetFsList(ROOT,'^(BIC|BICON|BIM)\d{3}_(1|2)$',1);

for iD=1:length(Dlist)
    Scanner{268+iD,1}     = Dlist{iD};
    Scanner{268+iD,2}     = 'Berlin';
end

Scanner=Scanner(:,1:2);

ROOT    = 'C:\Backup\ASL\BioCog\Utrecht_DF1';
Dlist   = xASL_adm_GetFsList(ROOT,'^(CCC)\d{3}_(1|2)$',1);

for iD=1:length(Dlist)
    Scanner{664+iD,1}     = Dlist{iD};
    Scanner{664+iD,2}     = 'UMCU_MR8';
end
