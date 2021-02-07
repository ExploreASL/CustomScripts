%% Hardy data sorting

ROOT_1      = 'C:\Backup\ASL\Hardy\HD_complete_sequences\Baseline_visit';

Flist       = xASL_adm_GetFsList(ROOT_1,'^HD\d{3}.*$',1);
for iL=1:length(Flist)
    List{iL,1}  = Flist{iL};
    List{iL,2}  = [Flist{iL}(1:5) '_1'];
    
    xASL_Rename(fullfile(ROOT_1,Flist{iL}),[Flist{iL}(1:5) '_1']);
end
    
clear List
ROOT_2      = 'C:\Backup\ASL\Hardy\HD_complete_sequences\Yr2_visit';

Flist       = xASL_adm_GetFsList(ROOT_2,'^HD\d{3}.*$',1);
for iL=1:length(Flist)
    List{iL,1}  = Flist{iL};
    List{iL,2}  = [Flist{iL}(1:5) '_2'];
    
    xASL_Rename(fullfile (ROOT_2,Flist{iL}),[Flist{iL}(1:5) '_2']);
end


%% Sort dicoms correctly
ROOT_all    = 'C:\Backup\ASL\Hardy\raw';
Dlist       = xASL_adm_GetFsList(ROOT_all,'^HD\d{3}_\d$',1);
for iD=1:length(Dlist)
    xASL_TrackProgress(iD,length(Dlist));
    ROOT    = fullfile(ROOT_all,Dlist{iD},'DICOM');
    if  isdir(ROOT)

        
        FileList    = {'FLAIR.mlimage' 'T1.mlimage' 'T2.mlimage'};
        
        for iL=1:3
            File2Del    = fullfile(ROOT,FileList{iL});
            if  exist( File2Del ,'file')
                delete(File2Del)
            end
        end
        
        ConvertDicomFolderStructure(ROOT);        
        
        clear Dlist2
        Dlist2  = xASL_adm_GetFsList(ROOT,'.*.',1,0,0,[0 Inf]);
        for iD2=3:length(Dlist2)
            if  ~isempty(str2num(Dlist2{iD2}))
                clear Flist
                Flist   = xASL_adm_GetFileList(fullfile(ROOT,Dlist2{iD2}),'.*','FPListRec',[0 Inf]);
                if  isempty(Flist)
                    rmdir( fullfile(ROOT,Dlist2{iD2}), 's' );
                end
            else
                xASL_Move(fullfile(ROOT,Dlist2{iD2}),fullfile(ROOT_all,Dlist{iD},Dlist2{iD2}),1);
            end
        end
        %% Check if dicom dir is now empty, then remove
        clear Flist
        Flist   = xASL_adm_GetFileList(ROOT,'.*','FPListRec',[0 Inf]);
        if  isempty(Flist)
            rmdir( ROOT, 's' );
        end        
    end
end
            
%% Move dicoms correctly
ROOT_all    = 'C:\Backup\ASL\Hardy\raw';
Dlist       = xASL_adm_GetFsList(ROOT_all,'^HD\d{3}_\d$',1);
for iD=1:length(Dlist)
    xASL_TrackProgress(iD,length(Dlist));
    CircList    = xASL_adm_GetFsList(fullfile(ROOT_all,Dlist{iD}),'^CIRC.*',1,0,0,[0 Inf]);
    if ~isempty(CircList)
        OldDir  = fullfile(ROOT_all,Dlist{iD},CircList{1});
        DList2  = xASL_adm_GetFsList(OldDir,'^.*$',1,0,0,[0 Inf]);
        for ii=3:length(DList2)
            if ~isempty(str2num(DList2{ii}))
                if  isempty(xASL_adm_GetFileList(fullfile(OldDir,DList2{ii}),'.*','FPListRec',[0 Inf]))
                    rmdir( fullfile(OldDir,DList2{ii}), 's' );
                end
            else
                xASL_Move(fullfile(OldDir,DList2{ii}),fullfile(ROOT_all,Dlist{iD},DList2{ii}));
            end
        end
        if  isempty(xASL_adm_GetFileList(OldDir,'.*','FPListRec',[0 Inf]))
            rmdir( OldDir, 's' );
        end
    end
end


%% Keep first niftis, later ones have biasfield correction, want to correct FLAIR with same biasfield correction as T1w
ROOT_all    = 'C:\Backup\ASL\Hardy\analysis';
Dlist       = xASL_adm_GetFileList(ROOT_all,'^(T1|FLAIR)_1\.(nii|nii\.gz)$','FPListRec',[0 Inf]);

length(Dlist)

for iD=1:length(Dlist)
    xASL_Move(Dlist{iD},[Dlist{iD}(1:end-6) '.nii']);
end

%% Delete MPRAGE reconstructions
ROOT_all    = 'C:\Backup\ASL\Hardy\raw';
Dlist       = xASL_adm_GetFsList(ROOT_all,'^HD\d{3}_\d$',1);

for iD=1:length(Dlist)
    Get1    = xASL_adm_GetFsList(fullfile(ROOT_all,Dlist{iD}),'^SAG_MPRAGE.*SS$',1,0,0,[0 Inf]);
    if  ~isempty(Get1)
        Dir2    = fullfile(ROOT_all,Dlist{iD},[Get1{1} '_AX MPRAGE']);
        Dir3    = fullfile(ROOT_all,Dlist{iD},[Get1{1} '_COR MPRAGE']);
        
        if  isdir(Dir2)
            rmdir(Dir2,'s');
        end
        if  isdir(Dir3)
            rmdir(Dir3,'s');
        end
    end
end

%% Create Empty Folders for tracking
ROOT_all    = 'C:\Backup\ASL\Hardy\raw';
ROOT_ana    = 'C:\Backup\ASL\Hardy\analysis';
Dlist       = xASL_adm_GetFsList(ROOT_all,'^HD\d{3}_\d$',1);

for iD=1:length(Dlist)
    CheckDir    = fullfile(ROOT_ana,Dlist{iD});
    xASL_adm_CreateDir(CheckDir);
end
