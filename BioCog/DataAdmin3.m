%% DataAdmin3

% Remove files first
clear DelList Dlist
NewDir      = 'C:\Backup\ASL\BioCog\Utrecht_DF1_DF2';
DelList     = {'^BOLD\.(nii|nii\.gz)$' '.*\.m(l|I)image$' '^filling.*\.mat$' '^ples_lpa.*\.(nii|nii\.gz)$' '^DTI\.txt$' '^mFLAIR\.(nii|nii\.gz)$' '^mrFLAIR\.(nii|nii\.gz)$' '^rFLAIR\.(nii|nii\.gz)$'};
DelList     = {'DTI' '^dt_DW_HR_SENSE\.(nii|nii\.gz)$' '^dti_2x_30\.(nii|nii\.gz)$' '^FE_EPI_BERLIN\.(nii|nii\.gz)$' '^mrx3D_Brain_View_FLAIR_cvon.(nii|nii\.gz)$' '^PCA_survey\.(nii|nii\.gz)$' '^QF_bas.*\.(nii|nii\.gz)$' '^rx3D_Brain_View_FLAIR_cvon\.(nii|nii\.gz)$' 'sASL_substraction\.nii' 't_DW_HR\.(nii|nii\.gz)$' 'x3D_Brain_View_FLAIR.*\.(nii|nii\.gz)$'};

for iD=1:length(DelList)
    Dlist{iD}   = xASL_adm_GetFileList(NewDir,DelList{iD},'FPListRec',[0 Inf]);

    for iG=1:length(Dlist{iD})
        if  exist(Dlist{iD}{iG,1}, 'file')
            delete(Dlist{iD}{iG,1});
        end
    end
end



% Copy ASL files & scale slopes to Utrecht Data

OldDir  = 'C:\Backup\ASL\BioCog_OLD';
SubjList    = xASL_adm_GetFsList(OldDir,'^(BCU|CCC)\d{3}$',1);
ASL_files   = {'ASL4D.nii' 'ASL4D_parms.mat' 'M0.nii' 'M0_parms.mat'};

for iS=1:length(SubjList)
    clear ASL_old ASL_new T1w_old T1w_new
    ASL_old{1}    = fullfile(OldDir,SubjList{iS}, 'ASL_1');
    ASL_old{2}    = fullfile(OldDir,SubjList{iS}, 'ASL_2');
    
    ASL_new{1}    = fullfile(NewDir,[SubjList{iS} '_1'], 'ASL_1');
    ASL_new{2}    = fullfile(NewDir,[SubjList{iS} '_2'], 'ASL_1');
    
    for iN=1:2
        xASL_adm_CreateDir(ASL_new{iN});
        clear CountFileNew
        CountFileNew    = 0;
        
        for iA=1:4
            clear ASLfileOld ASLfileNew
            ASLfileOld     = fullfile(ASL_old{iN},ASL_files{iA});
            ASLfileNew     = fullfile(ASL_new{iN},ASL_files{iA});
            
            if ~exist(ASLfileNew,'file') && exist(ASLfileOld,'file')
                xASL_Move(ASLfileOld,ASLfileNew);
            end
            
            if  exist(ASLfileNew,'file')
                CountFileNew    = CountFileNew+1;
            end
        end
        
        clear ASLoldFile
        if  CountFileNew==4
            % Remove other ASL scans, if pre-existing ASL scans were copied
            % succesfully
            ASLoldFile{1}  = fullfile(NewDir,[SubjList{iS} '_' num2str(iN)],'ASL.nii');
            ASLoldFile{2}  = fullfile(NewDir,[SubjList{iS} '_' num2str(iN)],'M0.nii');
            ASLoldFile{3}  = fullfile(NewDir,[SubjList{iS} '_' num2str(iN)],'pCASL.nii');
            ASLoldFile{4}  = fullfile(NewDir,[SubjList{iS} '_' num2str(iN)],'dcmHeaders.mat');
            
            for iD=1:4
                if  exist(ASLoldFile{iD},'file')
                    delete(ASLoldFile{iD});
                end
            end
        end
    end
   
    T1w_old     = fullfile(OldDir,SubjList{iS}, 'T1.nii');
    T1w_new     = fullfile(NewDir,[SubjList{iS} '_1'], 'T1.nii');
    if  exist(T1w_old,'file')
        xASL_Move(T1w_old,T1w_new,1);
    end

    FLAIR_old     = fullfile(OldDir,SubjList{iS}, 'FLAIR.nii');
    FLAIR_new     = fullfile(NewDir,[SubjList{iS} '_1'], 'FLAIR.nii');
    if  exist(FLAIR_old,'file')
        xASL_Move(FLAIR_old,FLAIR_new,1);
    end    
    

    
end


NewDir      = 'C:\Backup\ASL\BioCog\Utrecht_DF1_DF2';
SubjList    = xASL_adm_GetFsList(NewDir,'^(BCU|CCC)\d{3}_(1|2)$',1);

for iS=1:length(SubjList)
    %% Check T1w's, use latest
    % 
    FileList2    = xASL_adm_GetFileList(fullfile(NewDir,SubjList{iS}),'^s_T1W_3D.*\.(nii|nii\.gz)$','FPList',[0 Inf]);
    if      length(FileList2)==2
        error('check');
%             NewFile     = fullfile(NewDir,SubjList{iS}, 'T1.nii');
%             xASL_Move(FileList2{2},NewFile);
%             delete(FileList2{1});
        
    elseif  length(FileList2)~=0
            error('wrong n Files');
    end
end

%% Move files to ASL_1 directory

NewDir      = 'C:\Backup\ASL\BioCog\Utrecht_DF1_DF2';
SubjList    = xASL_adm_GetFsList(NewDir,'^(BCU|CCC)\d{3}_(1|2)$',1);
for iS=1:length(SubjList)
    
    ASLdir      = fullfile(NewDir,SubjList{iS},'ASL_1');
    xASL_adm_CreateDir(ASLdir);
    ASL4Dfile   = fullfile(ASLdir,'ASL4D.nii');
    M0file      = fullfile(ASLdir,'M0.nii');
    
    oldASL      = fullfile(NewDir,SubjList{iS},'pCASL.nii');
    oldASL2     = fullfile(NewDir,SubjList{iS},  'ASL.nii');
    oldM014     = fullfile(NewDir,SubjList{iS},'M0_14.nii');
    oldM017     = fullfile(NewDir,SubjList{iS},'M0_17.nii');   
    oldM0       = fullfile(NewDir,SubjList{iS},'M0.nii');   
    
    if  exist(oldM014,'file') && exist(oldM017,'file')
        delete(oldM014);
    end
    
    if     ~exist(M0file,'file') && exist(oldM017,'file')
            xASL_Move(oldM017,M0file);
    elseif ~exist(M0file,'file') && exist(oldM0,'file')
            xASL_Move(oldM0,M0file);
    end

    if     ~exist(ASL4Dfile,'file') && exist(oldASL,'file')
            xASL_Move(oldASL,ASL4Dfile);
    elseif ~exist(ASL4Dfile,'file') && exist(oldASL2,'file')
            xASL_Move(oldASL2,ASL4Dfile);
    end    
end

    
   
    
        
%% do dcmvalues thingy
addpath(fullfile(x.MYPATH,'Development','dicomtools'));

NewDir      = 'C:\Backup\ASL\BioCog\Utrecht_DF1_DF2';
SubjList    = xASL_adm_GetFsList(NewDir,'^(BCU|CCC)\d{3}_(1|2)$',1);

for iS=1:length(SubjList)
    clear parmsFile1 parmsFile2 dcmHeader DcmH H ASLdir
    ASLdir      = fullfile(NewDir,SubjList{iS},'ASL_1');
    xASL_adm_CreateDir(ASLdir);
    
    parmsFile1  = fullfile(ASLdir,'ASL4D_parms.mat');
    parmsFile2  = fullfile(ASLdir,'M0_parms.mat');
    dcmHeader   = fullfile(NewDir,SubjList{iS},'dcmHeaders.mat');
    
    if  exist(dcmHeader,'file') && (~exist(parmsFile1) || ~exist(parmsFile2))
        
        % Check dcmHeader
        DcmH    = load(dcmHeader);
        % Which fields
        H   = fieldnames(DcmH.h);
        for iH=1:length(H)
            %% ASL part
            if (~isempty(findstr(H{iH},'ASL')) || ~isempty(findstr(H{iH},'M0'))) && isempty(findstr(H{iH},'substraction'))  && isempty(findstr(H{iH},'perfusion'))
                
                clear ASLfields parms
                
                ASLfields   = eval(['DcmH.h.' H{iH}]);
                parms.EchoTime                  = ASLfields.EchoTime;
                parms.RepetitionTime            = ASLfields.RepetitionTime;
                parms.NumberOfTemporalPositions = ASLfields.NumberOfTemporalPositions;
                
                if      isfield(ASLfields,'RescaleSlope')
                        parms.RescaleSlopeOriginal  = ASLfields.RescaleSlope;
                        parms.RescaleSlope          = ASLfields.RescaleSlope;
                elseif  isfield(ASLfields,'RescaleSlopeOriginal')
                        parms.RescaleSlopeOriginal  = ASLfields.RescaleSlopeOriginal;
                        parms.RescaleSlope          = ASLfields.RescaleSlopeOriginal; 
                else    error('No RescaleSlope found');
                end
                if      isfield(ASLfields,'MRScaleSlope')
                        parms.MRScaleSlope          = ASLfields.MRScaleSlope;
                else
%                     
%                         
%                         ASLfields.Private_2005_140f.Item_1
%                         ASLfields.Private_2005_100e
                    
                        error('No MRScaleSlope found');
                end
                if      isfield(ASLfields,'AcquisitionTime')
                        parms.AcquisitionTime          = ASLfields.AcquisitionTime;
                else
                        parms.AcquisitionTime          = NaN;
                end
                if      isfield(ASLfields,'RescaleIntercept')
                        parms.RescaleIntercept          = ASLfields.RescaleIntercept;
                else
                        parms.RescaleIntercept          = 0;
                end     
                
                if ~isempty(findstr(H{iH},'ASL')) && ~isempty(findstr(H{iH},'M0'))
                    error('Wrong name both M0 & ASL');
                end
                
                if ~isempty(findstr(H{iH},'ASL'))
                    save(parmsFile1,'parms');
                elseif ~isempty(findstr(H{iH},'M0'))
                    save(parmsFile2,'parms');
                end
                
                clear parms
            end
        end
    end
end
                
 

%% Delete empty directories
NewDir      = 'C:\Backup\ASL\BioCog\Utrecht_DF1_DF2';
SubjList    = xASL_adm_GetFsList(NewDir,'^(BCU|CCC)\d{3}_(1|2)$',1);

for ii=1:length(SubjList)
    clear DirSearch
    DirSearch       = fullfile(NewDir,SubjList{ii});
    ASLsearch       = fullfile(NewDir,SubjList{ii},'ASL_1');
    if  length(xASL_adm_GetFileList(DirSearch,'^.*\.(nii|mat)$','FPListRec',[0 Inf]))==0
        if  isdir(ASLsearch)
            rmdir(ASLsearch);
        end
        rmdir(DirSearch);
    end
end





    
