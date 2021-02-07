%% Data admin BioCog

ROOT{1}     = 'C:\Backup\ASL\BioCog\BERLIN_controls'; % wait for answer Ilse
ROOT{2}     = 'C:\Backup\ASL\BioCog\BERLIN_DF1'; 
ROOT{3}     = 'C:\Backup\ASL\BioCog\Utrecht_DF1_plusCo';
ROOT{4}     = 'C:\Backup\ASL\BioCog\Utrecht_DF2';

Flist       = xASL_adm_GetFsList(ROOT{1},'^BioCog_BICON\d{3}.*$',1);

for iF=1:length(Flist)
    clear IndX SubjN
    
    IndX    = find(Flist{iF}=='_');
    SubjN   = Flist{iF}(IndX(1)+1:IndX(2)-1);
    
    if     ~isempty(strfind(Flist{iF},'pre'))
            SubjN   = [SubjN '_1'];
    elseif ~isempty(strfind(Flist{iF},'post'))
            SubjN   = [SubjN '_2'];
    else error('No pre or post name');
    end
    
    ScanDate{iF,1}  = SubjN;
    ScanDate{iF,2}  = Flist{iF}(IndX(length(IndX))+1:end);
    
    xASL_Rename(fullfile(ROOT{1},Flist{iF}),SubjN);
end
       
save( fullfile(ROOT{1},'ScanDate.mat'),'ScanDate');



%% 2
clear ScanDate Flist
Flist       = xASL_adm_GetFsList(ROOT{2},'^BioCog_.*$',1);
for iF=1:length(Flist)
    clear IndX SubjN
    
    IndX    = find(Flist{iF}=='_');
    SubjN   = Flist{iF}(IndX(1)+1:IndX(2)-1);
    
    if     ~isempty(strfind(Flist{iF},'pre'))
            SubjN   = [SubjN '_1'];
    elseif ~isempty(strfind(Flist{iF},'post'))
            SubjN   = [SubjN '_2'];
    else error('No pre or post name');
    end
    
    ScanDate{iF,1}  = SubjN;
    ScanDate{iF,2}  = Flist{iF}(IndX(length(IndX))+1:end);
    ScanDate{iF,3}  = Flist{iF};
    
    xASL_Rename(fullfile(ROOT{2},Flist{iF}),SubjN);
end

save( fullfile(ROOT{2},'ScanDate.mat'),'ScanDate');


%% 3
clear ScanDate Flist
Flist       = xASL_adm_GetFsList(ROOT{3},'^(BCU|CCC).*$',1);
for iF=1:length(Flist)
    clear IndX SubjN
    
    SubjN   = Flist{iF}(1:6);
    
    if     ~isempty(strfind(Flist{iF},'pre')) || ~isempty(strfind(Flist{iF},'PRE'))
            SubjN   = [SubjN '_1'];
    elseif ~isempty(strfind(Flist{iF},'post')) || ~isempty(strfind(Flist{iF},'POST'))
            SubjN   = [SubjN '_2'];
    else error('No pre or post name');
    end
    
    ScanDate{iF,1}  = SubjN;
    ScanDate{iF,2}  = Flist{iF}(7:end);
    ScanDate{iF,3}  = Flist{iF};
    
    xASL_Rename(fullfile(ROOT{3},Flist{iF}),SubjN);
end

save( fullfile(ROOT{3},'ScanDate.mat'),'ScanDate');


%% 4
clear ScanDate Flist
Flist       = xASL_adm_GetFsList(ROOT{4},'^BCU.*$',1);
for iF=1:length(Flist)
    clear IndX SubjN
    
    SubjN   = Flist{iF}(1:6);
    
    if     ~isempty(strfind(Flist{iF},'pre')) || ~isempty(strfind(Flist{iF},'PRE'))
            SubjN   = [SubjN '_1'];
    elseif ~isempty(strfind(Flist{iF},'post')) || ~isempty(strfind(Flist{iF},'POST'))
            SubjN   = [SubjN '_2'];
    else error('No pre or post name');
    end
    
    ScanDate{iF,1}  = SubjN;
    ScanDate{iF,2}  = Flist{iF}(7:end);
    ScanDate{iF,3}  = Flist{iF};
    
    xASL_Rename(fullfile(ROOT{4},Flist{iF}),SubjN);
end

save( fullfile(ROOT{4},'ScanDate.mat'),'ScanDate');
