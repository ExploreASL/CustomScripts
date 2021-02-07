%% Rename BioCog Data based on key

x.MYPATH  = 'c:\ExploreASL';
addpath(fullfile(x.MYPATH,'Development','dicomtools'));
addpath(fullfile(x.MYPATH,'spmwrapperlib'));

ROOT    = 'C:\Backup\ASL\BioCog\XNAT_BioCog\BioCog';
load('C:\Backup\ASL\BioCog\key.mat');

Dlist   = xASL_adm_GetFsList(ROOT,'^.*$',1);

for iD=1:length(Dlist)
    for iK=1:length(key)
        if  strcmp(Dlist{iD},key{iK,2})
            clear OldDir NewDir
            OldDir  = fullfile(ROOT,Dlist{iD});
            NewDir  = key{iK,1};
            xASL_Rename(OldDir,NewDir);
        end
    end
end

%% Within the subdirectory, choose the directory that has "T1" or "TP3" for _1 or _2

Dlist   = xASL_adm_GetFsList(ROOT,'^(BCU|BIC|BIM)\d{3}$',1);

for iD=1:length(Dlist)
    Dlist2      = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD}),'^.*_T1$',1,[],[],[0 Inf]);
    
    if  length(Dlist2)==1
        NewDir  = fullfile(ROOT,[Dlist{iD} '_1']);
        OldDir  = fullfile(ROOT, Dlist{iD}, Dlist2{1});
        xASL_Move(OldDir,NewDir);
    end
    
    Dlist2      = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD}),'^.*_T3$',1,[],[],[0 Inf]);
    if  length(Dlist2)==1
        NewDir  = fullfile(ROOT,[Dlist{iD} '_3']);
        OldDir  = fullfile(ROOT, Dlist{iD}, Dlist2{1});
        xASL_Move(OldDir,NewDir);
    end    
    
    Dlist2      = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD}),'^.*$',1,[],[],[0 Inf]);
    if      isempty(Dlist2)
            rmdir(fullfile(ROOT,Dlist{iD}));
    else    error('Dir not empty');
    end
end
    
%% Rename directories into ASL or M0, depending on length

Dlist   = xASL_adm_GetFsList(ROOT,'^BCU\d{3}_(1|3)$',1);
NN=1;
for iD=1:length(Dlist)
    Dlist2      = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD},'scans'),'^.*$',1,[],[],[0 Inf]);
    for iD2=1:length(Dlist2)
        Dlist3  = xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD},'scans',Dlist2{iD2},'DICOM'),'^.*\.dcm$');
        if      length(Dlist3)==19
                 xASL_Rename(fullfile(ROOT,Dlist{iD},'scans',Dlist2{iD2}),'M0');
        elseif  length(Dlist3)==19*2*34
                 xASL_Rename(fullfile(ROOT,Dlist{iD},'scans',Dlist2{iD2}),'ASL');
        elseif  length(Dlist3)==1
                OneList{NN,1}   = Dlist{iD};
                NN=NN+1;
            
        else    error(['Unknown length ' Dlist{iD}]);
        end
    end
end



Dlist   = xASL_adm_GetFsList(ROOT,'^BCU\d{3}_(1|3)$',1);
NN=1;
for iD=1:length(Dlist)
    Dlist2      = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD},'scans'),'^.*$',1,[],[],[0 Inf]);
    if  length(xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD},'scans',Dlist2{1},'DICOM'),'^.*\.dcm$'))==1
        if  ~strcmp(Dlist2{1}, 'ASL') && ~strcmp(Dlist2{2}, 'ASL')
            xASL_Rename(fullfile(ROOT,Dlist{iD},'scans',Dlist2{1}),'ASL');
            xASL_Rename(fullfile(ROOT,Dlist{iD},'scans',Dlist2{2}),'M0');
        end
    end
end



%% Rename _3 into _2 (TP2 was a non-MRI TP)
Dlist   = xASL_adm_GetFsList(ROOT,'^(BCU|BIM|BIC)\d{3}_3$',1);
for iD=1:length(Dlist)
    if  str2num(Dlist{iD}(end))==3
        xASL_Rename(fullfile(ROOT,Dlist{iD}),[Dlist{iD}(1:end-1) '2']);
    end
end

    
%% Remove dirs with single files, and otherwise rename to FLAIR

ROOT    = 'C:\Backup\ASL\BioCog\XNAT_BioCog\BioCog';
Dlist   = xASL_adm_GetFsList(ROOT,'^(BCU|BIM|BIC)\d{3}_(1|2)$',1);

for iD=1:length(Dlist)
    Dlist2      = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD},'scans'),'^.*$',1);
    for iD2=1:length(Dlist2)
        Dlist3      = xASL_adm_GetFileList( fullfile(ROOT,Dlist{iD},'scans',Dlist2{iD2},'DICOM'),'^.*\..*$','FPList',[0 Inf]);
        if  length(Dlist3)<40
            % delete all files, this is not a true FLAIR scan
            for iD3=1:length(Dlist3)
                delete(Dlist3{iD3});
            end
        else % rename folder to FLAIR
            if     ~isdir(fullfile(ROOT,Dlist{iD},'scans','FLAIR'))
                    xASL_Rename(fullfile(ROOT,Dlist{iD},'scans',Dlist2{iD2}), 'FLAIR');
            else    xASL_Rename(fullfile(ROOT,Dlist{iD},'scans',Dlist2{iD2}), 'FLAIR2'); 
            end
        end
    end
end
            
    
    
