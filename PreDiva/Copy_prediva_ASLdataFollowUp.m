%% Copy pre-DIVA ASL data
clear;clc;close all
addpath(genpath('c:\ASL_pipeline_HJ'));

%% follow up only

ODIR            = 'Z:\divi\Projects\prediva\DICOM';
DDIR            = 'E:\Backup\ASL_E\pre_DIVA_pipeline\follow-up';

LIST            = xASL_adm_GetFsList( ODIR, '^2016.*_.*$', 1);
xASL_adm_CreateDir(DDIR)

T1Count             = 0;
FLAIRCount          = 0;
noCrushCount        = 0;
CrushCount          = 0;
CrushM0Count        = 0;
noCrushM0Count      = 0;

for iSubject        = 1:length(LIST)
    xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject} ) );

    % T1 copy
    T1List          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iSubject} ), '^.*_ADNI$', 1);
    if length(T1List)>0
        xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject}, 'T1' ) );
        dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iSubject} , T1List{1} ), '^.*\.dcm$');
        for iDcm    = 1:length(dcmList)
            [path file ext]     = fileparts(char(dcmList(iDcm)));
            if ~exist( fullfile( DDIR, LIST{iSubject}, 'T1', [file ext]) )
                xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR, LIST{iSubject}, 'T1', [file ext]) );
                clear path file ext
            end
        end
        clear dcmList
        T1Count     = T1Count+1;
    end

    % FLAIR copy
    FLAIRList          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iSubject} ), '^.*FLAIR.*$', 1);
    if length(FLAIRList)>0
        xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject}, 'FLAIR' ) );
        dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iSubject} , FLAIRList{1} ), '^.*\.dcm$');
        for iDcm    = 1:length(dcmList)
            [path file ext]     = fileparts(char(dcmList(iDcm)));
            if ~exist( fullfile( DDIR, LIST{iSubject}, 'FLAIR', [file ext]) )
                xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR, LIST{iSubject}, 'FLAIR', [file ext]) );
                clear path file ext
            end
        end
        clear dcmList
        FLAIRCount     = FLAIRCount+1;
    end

    % non-crushed copy
    noCrushList          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iSubject} ), '^.*pseudo_nocrush.*$', 1);
    if length(noCrushList)>0
        xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject}, 'noCrush' ) );
        dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iSubject} , noCrushList{1} ), '^.*\.dcm$');
        for iDcm    = 1:length(dcmList)
            [path file ext]     = fileparts(char(dcmList(iDcm)));
            if ~exist( fullfile( DDIR, LIST{iSubject}, 'noCrush', [file ext]) )
                xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR, LIST{iSubject}, 'noCrush', [file ext]) );
                clear path file ext
            end
        end
        clear dcmList
        noCrushCount        = noCrushCount+1;
    end

    % crushed copy
    CrushList               = xASL_adm_GetFsList( fullfile( ODIR, LIST{iSubject} ), '^.*pseudo_crush.*$', 1);
    if length(CrushList)>0
        xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject}, 'Crush' ) );
        dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iSubject} , CrushList{1} ), '^.*\.dcm$');
        for iDcm    = 1:length(dcmList)
            [path file ext]     = fileparts(char(dcmList(iDcm)));
            if ~exist( fullfile( DDIR, LIST{iSubject}, 'Crush', [file ext]) )
                xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR, LIST{iSubject}, 'Crush', [file ext]) );
                clear path file ext
            end
        end
        clear dcmList
        CrushCount          = CrushCount+1;
    end

    % non-crushed M0 copy
    noCrushM0List          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iSubject} ), '^.*NOCRUSH_M0.*$', 1);
    if length(noCrushM0List)>0
        xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject}, 'noCrushM0' ) );
        dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iSubject} , noCrushM0List{1} ), '^.*\.dcm$');
        for iDcm    = 1:length(dcmList)
            [path file ext]     = fileparts(char(dcmList(iDcm)));
            if ~exist( fullfile( DDIR, LIST{iSubject}, 'noCrushM0', [file ext]) )
                xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR, LIST{iSubject}, 'noCrushM0', [file ext]) );
                clear path file ext
            end
        end
        clear dcmList
        noCrushM0Count        = noCrushM0Count+1;
    end

    % crushed M0 copy
    CrushM0List               = xASL_adm_GetFsList( fullfile( ODIR, LIST{iSubject} ), '^.*crush_m0.*$', 1);
    if length(CrushM0List)>0
        xASL_adm_CreateDir( fullfile( DDIR, LIST{iSubject}, 'CrushM0' ) );
        dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iSubject} , CrushM0List{1} ), '^.*\.dcm$');
        for iDcm    = 1:length(dcmList)
            [path file ext]     = fileparts(char(dcmList(iDcm)));
            if ~exist( fullfile( DDIR, LIST{iSubject}, 'CrushM0', [file ext]) )
                xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR, LIST{iSubject}, 'CrushM0', [file ext]) );
                clear path file ext
            end
        end
        clear dcmList
        CrushM0Count          = CrushM0Count+1;
    end

end


