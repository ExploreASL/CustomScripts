%% GENFI check Philips scale slopes

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva no Bsup\analysis'; % CAVE check dir!
dirlist = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$', 1);

[data, text, rawData]       = xlsread( 'C:/Backup/ASL/GENFI/GENFI_DF1_MASTER.xlsx','MAIN');
load('C:\Backup\ASL\GENFI/GENFI_dcms.mat');
DcmList                     = TotalList;
clear data text TotalList

for iList=1:length(dirlist)

    %% Subject
    TotalList{iList,13}  = dirlist{iList};
    
    %% Site
    CountSub=0;
    for iRaw=2:size(rawData,1)
        if  strcmp(rawData{iRaw,2}, dirlist{iList})
            TotalList{iList,14}  = rawData{iRaw,1};
            CountSub=1;
        end
    end
    if  CountSub~=1
        error('Subject not found or double found in rawDataList');
    end

    %% Software version
    CountSub=0;
    for iDcm=2:size(DcmList,1)
        if  strcmp(DcmList{iDcm,1}, dirlist{iList})
            TotalList{iList,15}  = DcmList{iDcm,11};
            CountSub=1;
        end
    end
    if  CountSub~=1
        error('Subject not found or double found in rawDataList');
    end
    
    
    %% T1
    clear tnii T1file
    T1file          = fullfile( ROOT, dirlist{iList}, 'T1.nii');
    
    if  exist(T1file,'file')
        tnii    = xASL_nifti( T1file );
        % Datatype scaleslope
        TotalList{iList,1}  = tnii.dat.dtype;
        TotalList{iList,2}  = tnii.dat.scl_slope;
        TotalList{iList,3}  = tnii.dat.scl_inter;
    end
    
    clear tnii T1parmsfile
    T1parmsfile     = fullfile( ROOT, dirlist{iList}, 'T1_parms.mat');

    if  exist(T1parmsfile,'file')
        tnii    = load( T1parmsfile );
        % Datatype scaleslope 
        TotalList{iList,4}  = tnii.parms.RescaleSlopeOriginal;
        TotalList{iList,5}  = tnii.parms.MRScaleSlope;
        TotalList{iList,6}  = tnii.parms.RescaleIntercept;
    end
    
    %% ASL
    clear tnii T1file 
    T1file          = fullfile( ROOT, dirlist{iList}, 'ASL_1', 'ASL4D.nii');
    
    if  exist(T1file,'file')
        tnii    = xASL_nifti( T1file );
        % Datatype scaleslope
        TotalList{iList,7}  = tnii.dat.dtype;
        TotalList{iList,8}  = tnii.dat.scl_slope;
        TotalList{iList,9}  = tnii.dat.scl_inter;
    end
    
    clear tnii T1parmsfile
    T1parmsfile     = fullfile( ROOT, dirlist{iList}, 'ASL_1', 'ASL4D_parms.mat');

    if  exist(T1parmsfile,'file')
        tnii    = load( T1parmsfile );
        % Datatype scaleslope 
        TotalList{iList,10}  = tnii.parms.RescaleSlopeOriginal;
        TotalList{iList,11}  = tnii.parms.MRScaleSlope;
        TotalList{iList,12}  = tnii.parms.RescaleIntercept;
    end
    
    %% FLAIR
    clear tnii T1file 
    T1file          = fullfile( ROOT, dirlist{iList}, 'FLAIR.nii');
    
    if  exist(T1file,'file')
        tnii    = xASL_nifti( T1file );
        % Datatype scaleslope
        TotalList{iList,16}  = tnii.dat.dtype;
        TotalList{iList,17}  = tnii.dat.scl_slope;
        TotalList{iList,18}  = tnii.dat.scl_inter;
    end
    
    clear tnii T1parmsfile
    T1parmsfile     = fullfile( ROOT, dirlist{iList}, 'FLAIR_parms.mat');

    if  exist(T1parmsfile,'file')
        tnii    = load( T1parmsfile );
        % Datatype scaleslope 
        TotalList{iList,19}  = tnii.parms.RescaleSlopeOriginal;
        TotalList{iList,20}  = tnii.parms.MRScaleSlope;
        TotalList{iList,21}  = tnii.parms.RescaleIntercept;
    end    
    
    %% M0
    clear tnii T1file 
    T1file          = fullfile( ROOT, dirlist{iList}, 'ASL_1', 'M0.nii');
    
    if  exist(T1file,'file')
        tnii    = xASL_nifti( T1file );
        % Datatype scaleslope
        TotalList{iList,22}  = tnii.dat.dtype;
        TotalList{iList,23}  = tnii.dat.scl_slope;
        TotalList{iList,24}  = tnii.dat.scl_inter;
    end
    
    clear tnii T1parmsfile
    T1parmsfile     = fullfile( ROOT, dirlist{iList}, 'ASL_1', 'M0_parms.mat');

    if  exist(T1parmsfile,'file')
        tnii    = load( T1parmsfile );
        % Datatype scaleslope 
        TotalList{iList,25}  = tnii.parms.RescaleSlopeOriginal;
        TotalList{iList,26}  = tnii.parms.MRScaleSlope;
        TotalList{iList,27}  = tnii.parms.RescaleIntercept;
    end    
end
