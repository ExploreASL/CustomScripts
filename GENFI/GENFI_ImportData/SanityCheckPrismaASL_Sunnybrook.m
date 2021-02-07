%% Check sanity Prisma ASL scans

ROOT    = '\\srlabs\synapse\shared\data\incoming\MRI\GENFI';
DDIR    = 'D:\GENFI_Prisma';
Dlist   = xASL_adm_GetFsList(ROOT, '^.*$',1);

for iD=1:length(Dlist)
    clear IsSiemens Dlist2
    IsSiemens   = 0;
    Dlist2  = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD}), '^.*$',1);
    
    for iD2=1:length(Dlist2)
        if  ~isempty(findstr( Dlist2{iD2},'asl3d'))
            IsSiemens=1;
        end
    end
    

    
    if  IsSiemens==1
        xASL_adm_CreateDir( fullfile(DDIR, Dlist{iD}) );
        
        for iD2=1:length(Dlist2)
            if ~isempty(findstr( Dlist2{iD2},'asl3d'))
                xASL_adm_CreateDir( fullfile(DDIR, Dlist{iD}, Dlist2{iD2}) );
                clear Dlist3
                Dlist3  = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}, Dlist2{iD2} ), '^.*.dcm$' );
                for iD3=1:length(Dlist3)
                    xASL_Copy( fullfile(ROOT, Dlist{iD}, Dlist2{iD2}, Dlist3{iD3} ), fullfile(DDIR, Dlist{iD}, Dlist2{iD2}, Dlist3{iD3} ) );
                end
            end
        end
    end
   
    if  IsSiemens==0 && length(Dlist2)>0% also try subdir 1 further
        clear Dlist4
        Dlist4  = xASL_adm_GetFsList(fullfile(ROOT,Dlist{iD},Dlist2{1}), '^.*$',1);
        
        for iD4=1:length(Dlist4)
            if  ~isempty(findstr( Dlist4{iD4},'asl3d'))
                IsSiemens=1;
            end
        end
        
        if  IsSiemens==1
            xASL_adm_CreateDir( fullfile(DDIR, Dlist{iD}) );

            for iD4=1:length(Dlist4)
                if ~isempty(findstr( Dlist4{iD4},'asl3d'))
                    xASL_adm_CreateDir( fullfile(DDIR, Dlist{iD}, Dlist4{iD4}) );
                    clear Dlist3
                    Dlist3  = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}, Dlist2{1}, Dlist4{iD4} ), '^.*.dcm$' );
                    for iD3=1:length(Dlist3)
                        xASL_Copy( fullfile(ROOT, Dlist{iD}, Dlist2{1}, Dlist4{iD4}, Dlist3{iD3} ), fullfile(DDIR, Dlist{iD}, Dlist4{iD4}, Dlist3{iD3} ) );
                    end
                end
            end
        end        
        
    end
    
end
