cd('c:\ExploreASL');
ExploreASL_master('',0);

%% Process new DICOMs MR7

% 1) delete 'DTI' 'CSF' 'DW' 'SURVEY' 'coil laag op tafel' 'QF bas min' 'QF min'
% 2) rename ' ' with '_' & add .dcm suffix recursively, both files & folders

%% 3) manage data directories
ROOT        = 'C:\Backup\ASL\BioCog\BioCogUtrechtMR7_DICOMsorted';
ID          = xASL_adm_GetFsList(ROOT,'BCU\d{3}',1);

for iD=1:length(ID)
    xASL_TrackProgress(iD,length(ID));
    clear mDir DateID DateNum Indic mDirNew
    
    mDir    = fullfile(ROOT,ID{iD});
    DateID  = xASL_adm_GetFsList(mDir,'\d{8}',1);
    if      length(DateID)==1 || length(DateID)==2
            % sort them
            for iDate=1:length(DateID)
                DateNum(iDate)      = str2num(DateID{iDate});
            end
            
            Indic(1)                = find(DateNum==min(DateNum));
            
            if  length(DateNum)==2
                Indic(2)            = find(DateNum==max(DateNum));
            end
            for iI=1:length(Indic)
                mDirNew{iI}         = [mDir '_' num2str(iI)];
                oDir{iI}            = fullfile(mDir,DateID{Indic(iI)});
                xASL_Move(oDir{iI},mDirNew{iI});
            end
            
    else
            error('strange length(DateID)');
    end

    % Rename unknown dirs
    UnknownDir  = fullfile(mDir,'UNKNOWN');
    mDirNewUnk  = [mDir 'Unknown'];
    if  isdir(UnknownDir)
        xASL_Move(UnknownDir,mDirNewUnk);
    end
        
    % delete empty dirs
    DirData     = dir(mDir);
    if  DirData(1).bytes==0
        rmdir(mDir);
    end
end

%% 4) if both TE=14 ms & TE=17 ms exist for M0, delete the 14 ms
ROOT        = 'C:\Backup\ASL\BioCog\BioCogUtrechtMR7_DICOMsorted';
ID          = xASL_adm_GetFsList(ROOT,'BCU\d{3}_(1|2)',1)';

for iD=1:length(ID)
    mDir        = fullfile(ROOT,ID{iD});
    M0_14list   = xASL_adm_GetFsList(mDir,'^.*M0_14.*$',1);
    M0_17list   = xASL_adm_GetFsList(mDir,'^.*M0_17.*$',1);
    
    if  length(M0_14list)==1 && length(M0_17list)==1
        RemoveDir   = fullfile(mDir,M0_14list{1});
        rmdir(RemoveDir,'s');
    end
end
