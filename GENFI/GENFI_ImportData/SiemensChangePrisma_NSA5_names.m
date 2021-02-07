%% Change all Prisma & NSA5 names into Trio

%% analysis Dirs & lock-dirs

DIR     = {'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis' 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\lock\ASL' 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\lock\T1'};

for iD=1:length(DIR)

    Flist   = xASL_adm_GetFsList(DIR{iD},'^SI_Prisma.*$',1);

    for iL=1:length(Flist)
        xASL_Rename( fullfile(DIR{iD}, Flist{iL}),['SI_Trio_' Flist{iL}(11:end)] );
    end


    Flist   = xASL_adm_GetFsList(DIR{iD},'^SI_Trio_NSA5.*$',1);

    for iL=1:length(Flist)
        xASL_Rename( fullfile(DIR{iD}, Flist{iL}),['SI_Trio_' Flist{iL}(14:end)] );
    end
end

%% Subdirs within darteldir

DIR     = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel';
Flist   = xASL_adm_GetFileList(DIR,'^.*SI_Prisma.*$','FPListRec');

for iF=1:length(Flist)
    clear Path File Ext Index
    [Path File Ext]     = fileparts( Flist{iF} );
    Index   = strfind(File,'Prisma');
    xASL_Rename(Flist{iF}, [File(1:Index-1) 'Trio' File(Index+6:end) Ext]);
end

Flist   = xASL_adm_GetFileList(DIR,'^.*SI_Trio_NSA5.*$','FPListRec');

for iF=1:length(Flist)
    clear Path File Ext Index
    [Path File Ext]     = fileparts( Flist{iF} );
    Index   = strfind(File,'NSA5');
    xASL_Rename(Flist{iF}, [File(1:Index-1) File(Index+5:end) Ext]);
end

%% Do the same with *.mat file
for iF=1:length(Education)
    clear Index
    Index   = strfind(Education{iF,1},'Prisma');
    if ~isempty(Index)
        Education{iF,1}     = [Education{iF,1}(1:Index-1) 'Trio' Education{iF,1}(Index+6:end)];
    end
end

for iF=1:length(Education)
    clear Index
    Index   = strfind(Education{iF,1},'NSA5');
    if ~isempty(Index)
        Education{iF,1}     = [Education{iF,1}(1:Index-1) Education{iF,1}(Index+5:end)];
    end
end

Education   = sortrows(Education,1);

%% Same Family
        
for iF=1:length(Family)
    clear Index
    Index   = strfind(Family{iF,1},'Prisma');
    if ~isempty(Index)
        Family{iF,1}     = [Family{iF,1}(1:Index-1) 'Trio' Family{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(Family)
    clear Index
    Index   = strfind(Family{iF,1},'NSA5');
    if ~isempty(Index)
        Family{iF,1}     = [Family{iF,1}(1:Index-1) Family{iF,1}(Index+5:end)];
    end
end
 
Family   = sortrows(Family,1);

%% Same GeneticStatus
        
for iF=1:length(GeneticStatus)
    clear Index
    Index   = strfind(GeneticStatus{iF,1},'Prisma');
    if ~isempty(Index)
        GeneticStatus{iF,1}     = [GeneticStatus{iF,1}(1:Index-1) 'Trio' GeneticStatus{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(GeneticStatus)
    clear Index
    Index   = strfind(GeneticStatus{iF,1},'NSA5');
    if ~isempty(Index)
        GeneticStatus{iF,1}     = [GeneticStatus{iF,1}(1:Index-1) GeneticStatus{iF,1}(Index+5:end)];
    end
end
 
GeneticStatus   = sortrows(GeneticStatus,1);

%% Same Handedness
        
for iF=1:length(Handedness)
    clear Index
    Index   = strfind(Handedness{iF,1},'Prisma');
    if ~isempty(Index)
        Handedness{iF,1}     = [Handedness{iF,1}(1:Index-1) 'Trio' Handedness{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(Handedness)
    clear Index
    Index   = strfind(Handedness{iF,1},'NSA5');
    if ~isempty(Index)
        Handedness{iF,1}     = [Handedness{iF,1}(1:Index-1) Handedness{iF,1}(Index+5:end)];
    end
end
 
Handedness   = sortrows(Handedness,1);


%% Same Sequence
        
for iF=1:length(Sequence)
    clear Index
    Index   = strfind(Sequence{iF,1},'Prisma');
    if ~isempty(Index)
        Sequence{iF,1}     = [Sequence{iF,1}(1:Index-1) 'Trio' Sequence{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(Sequence)
    clear Index
    Index   = strfind(Sequence{iF,1},'NSA5');
    if ~isempty(Index)
        Sequence{iF,1}     = [Sequence{iF,1}(1:Index-1) Sequence{iF,1}(Index+5:end)];
    end
end
 
Sequence   = sortrows(Sequence,1);

%% Same Site
        
for iF=1:length(Site)
    clear Index
    Index   = strfind(Site{iF,1},'Prisma');
    if ~isempty(Index)
        Site{iF,1}     = [Site{iF,1}(1:Index-1) 'Trio' Site{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(Site)
    clear Index
    Index   = strfind(Site{iF,1},'NSA5');
    if ~isempty(Index)
        Site{iF,1}     = [Site{iF,1}(1:Index-1) Site{iF,1}(Index+5:end)];
    end
end
 
Site   = sortrows(Site,1);

%% Same LongitudinalInterval
        
for iF=1:length(LongitudinalInterval)
    clear Index
    Index   = strfind(LongitudinalInterval{iF,1},'Prisma');
    if ~isempty(Index)
        LongitudinalInterval{iF,1}     = [LongitudinalInterval{iF,1}(1:Index-1) 'Trio' LongitudinalInterval{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(LongitudinalInterval)
    clear Index
    Index   = strfind(LongitudinalInterval{iF,1},'NSA5');
    if ~isempty(Index)
        LongitudinalInterval{iF,1}     = [LongitudinalInterval{iF,1}(1:Index-1) LongitudinalInterval{iF,1}(Index+5:end)];
    end
end
 
LongitudinalInterval   = sortrows(LongitudinalInterval,1);


%% Same CarrierYesNo
        
for iF=1:length(CarrierYesNo)
    clear Index
    Index   = strfind(CarrierYesNo{iF,1},'Prisma');
    if ~isempty(Index)
        CarrierYesNo{iF,1}     = [CarrierYesNo{iF,1}(1:Index-1) 'Trio' CarrierYesNo{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(CarrierYesNo)
    clear Index
    Index   = strfind(CarrierYesNo{iF,1},'NSA5');
    if ~isempty(Index)
        CarrierYesNo{iF,1}     = [CarrierYesNo{iF,1}(1:Index-1) CarrierYesNo{iF,1}(Index+5:end)];
    end
end
 
CarrierYesNo   = sortrows(CarrierYesNo,1);

%% Same MutationStatus
        
for iF=1:length(MutationStatus)
    clear Index
    Index   = strfind(MutationStatus{iF,1},'Prisma');
    if ~isempty(Index)
        MutationStatus{iF,1}     = [MutationStatus{iF,1}(1:Index-1) 'Trio' MutationStatus{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(MutationStatus)
    clear Index
    Index   = strfind(MutationStatus{iF,1},'NSA5');
    if ~isempty(Index)
        MutationStatus{iF,1}     = [MutationStatus{iF,1}(1:Index-1) MutationStatus{iF,1}(Index+5:end)];
    end
end
 
MutationStatus   = sortrows(MutationStatus,1);


%% Same MutationStatus7
        
for iF=1:length(MutationStatus7)
    clear Index
    Index   = strfind(MutationStatus7{iF,1},'Prisma');
    if ~isempty(Index)
        MutationStatus7{iF,1}     = [MutationStatus7{iF,1}(1:Index-1) 'Trio' MutationStatus7{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(MutationStatus7)
    clear Index
    Index   = strfind(MutationStatus7{iF,1},'NSA5');
    if ~isempty(Index)
        MutationStatus7{iF,1}     = [MutationStatus7{iF,1}(1:Index-1) MutationStatus7{iF,1}(Index+5:end)];
    end
end
 
MutationStatus7   = sortrows(MutationStatus7,1);

%% Same sex
        
for iF=1:length(sex)
    clear Index
    Index   = strfind(sex{iF,1},'Prisma');
    if ~isempty(Index)
        sex{iF,1}     = [sex{iF,1}(1:Index-1) 'Trio' sex{iF,1}(Index+6:end)];
    end
end
 
for iF=1:length(sex)
    clear Index
    Index   = strfind(sex{iF,1},'NSA5');
    if ~isempty(Index)
        sex{iF,1}     = [sex{iF,1}(1:Index-1) sex{iF,1}(Index+5:end)];
    end
end
 
sex   = sortrows(sex,1);



