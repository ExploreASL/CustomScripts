ROOT    = 'C:\Backup\ASL\BioCog\raw';
Flist   = xASL_adm_GetFsList(ROOT,'^(BIC|BICON|BIM).*',1);

for iL=1:length(Flist)
    xASL_TrackProgress(iL,length(Flist));
    try
        clear DirTry DirTry2 DirList DirWint 
        DirTry      = fullfile(ROOT, Flist{iL});
        DirTry      = xASL_adm_GetFsList(DirTry,'^BioCog.*$',1,[],[],[0 Inf]);
        DirTry      = fullfile(ROOT, Flist{iL}, DirTry{1});
        DirTry2     = xASL_adm_GetFsList(DirTry,'^(mri|MRI)$',1,[],[],[0 Inf]);
        DirTry      = fullfile(DirTry,DirTry2{1});

        DirWint     = xASL_adm_GetFsList(DirTry,'^WINTERER.*$',1,[],[],[0 Inf]);
        if  isempty(DirWint)
            DirWint     = fullfile(DirTry,'WINTERER_etc');
            xASL_adm_CreateDir(DirWint);
        else
            DirWint     = fullfile(DirTry,DirWint{1});
        end

        % Delete ND T1
        T1list          = xASL_adm_GetFsList(DirWint,'^.*t1_mprage.*$',1,[],[],[0 Inf]);
        % Remove ND
        if  length(T1list)>1
            % Search for ND directories & remove them
            for iT=1:length(T1list)
                if  strcmp(T1list{iT}(end-2:end),'_ND')
                    % Remove directory "ND" & its contents
                    ND_dir      = fullfile(DirWint,T1list{iT});
                    ND_list     = xASL_adm_GetFileList(ND_dir,'^.*$','FPList',[0 Inf]);
                    for iND=1:length(ND_list)
                        delete(ND_list{iND});
                    end
                    rmdir(ND_dir);
                end
            end
        end
        
        % Rename first T1
        T1list          = xASL_adm_GetFsList(DirWint,'^.*t1_mprage.*$',1,[],[],[0 Inf]);
        if      length(T1list)>2
                error('For some reason too many T1s');
        elseif  length(T1list)==2
                xASL_Rename(fullfile(DirWint,T1list{1}),'First_T1_for_EEG');
        end
        
        
        
        
        
        
        
        DirList     = xASL_adm_GetFsList(DirTry,'^.*$',1,[],[],[0 Inf]);

        for iD=1:length(DirList)
            if  isempty(strfind(DirList{iD},'WINTERER'))
                xASL_Move( fullfile(DirTry,DirList{iD}),fullfile(DirWint,DirList{iD}),1);
            end
        end
        
        Dlist2      = xASL_adm_GetFsList(DirWint,'^(BIC|BICON|BIM).*$',1,[],[],[0 Inf]);
        if  length(Dlist2)==1
            BicDir  = fullfile(DirWint, Dlist2{1});
            Dlist3  = xASL_adm_GetFsList(BicDir,'^.*$',1,[],[],[0 Inf]);
            for iD3=1:length(Dlist3)
                xASL_Move( fullfile(BicDir,Dlist3{iD3}), fullfile(DirWint,Dlist3{iD3}));
            end
            Dlist3  = xASL_adm_GetFileList(BicDir,'^.*$','list',[0 Inf]);
            for iD3=1:length(Dlist3)
                xASL_Move( fullfile(BicDir,Dlist3{iD3}), fullfile(DirWint,Dlist3{iD3}));
            end
            rmdir(BicDir);
        end
            
    end
end
