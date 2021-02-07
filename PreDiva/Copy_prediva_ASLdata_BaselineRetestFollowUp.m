%% Administration

ODIR            = 'Z:\divi\Projects\prediva\DICOM';
DDIR{1}         = 'D:\Backup\ASL_E\Pre_DIVA_repetition\Baseline';
DDIR{2}         = 'D:\Backup\ASL_E\Pre_DIVA_repetition\Retest6mnd';
DDIR{3}         = 'D:\Backup\ASL_E\Pre_DIVA_repetition\FollowUp';

LIST{1}         = {'20120629_241313' '20120627_151015' '20120629_154027' '20120711_191024' '20120711_191023' '20120627_191019' '20120629_151001' '20120704_154004'};
LIST{2}         = {'20130227_241313' '20130130_151015' '20130116_154027' '20130109_191024' '20130109_191023' '20121221_191019' '20121212_151001' '20121212_154004'};
LIST{3}         = {'20150227_241313' '20150325_151015' '20150325_154027' '20150429_191024' '20150429_191023' '20150401_191019' '20150417_151001' '20150320_154004'};

%% CHECK
% Check last 6 digits same
clear DATESLIST SUBJECTLIST
for iL=1:3
    for iD=1:length(LIST{iL})
        DATESLIST(iD,iL)   = str2num(LIST{iL}{iD}(1:8));
        SUBJECTLIST(iD,iL) = str2num(LIST{iL}{iD}(10:end));
    end
end

% Check unique subjects
length(unique(SUBJECTLIST))==size(SUBJECTLIST,1)

for iL=1:2
    for iD=1:length(LIST{iL})
        if  SUBJECTLIST(iD,iL) ~= SUBJECTLIST(iD,iL+1)
            error('');
        end
    end
end

for i2=1:size(DATESLIST,2)
    for i1=1:size(DATESLIST,1)
        year(i1,i2)     = floor(DATESLIST(i1,i2)/10000);
        month(i1,i2)    = floor((DATESLIST(i1,i2)-(year(i1,i2)*10000))/100);
        day(i1,i2)      = floor(DATESLIST(i1,i2)-(year(i1,i2)*10000)-(month(i1,i2)*100));
    end
end
    
DELTADATE(:,1)          = datenum(year(:,2),month(:,2),day(:,2))-datenum(year(:,1),month(:,1),day(:,1));
DELTADATE(:,2)          = datenum(year(:,3),month(:,3),day(:,3))-datenum(year(:,2),month(:,2),day(:,2));

DELTADATEmnths          = DELTADATE./30;
DELTADATEyrs            = DELTADATEmnths./12;
    
mean(DELTADATEyrs(:,1))
mean(DELTADATEyrs(:,2))

%% Start copying

for iL=1:3
    T1Count             = 0;
    FLAIRCount          = 0;
    noCrushCount        = 0;
    CrushCount          = 0;
    
    xASL_adm_CreateDir(DDIR{iL});
    
    

    for iSubject        = 1:length(LIST{iL})
        xASL_adm_CreateDir( fullfile( DDIR{iL}, LIST{iL}{iSubject} ) );
 
        % T1 copy
        T1List          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iL}{iSubject} ), '^.*(ADNI|adni).*$', 1);
        if length(T1List)>0
            xASL_adm_CreateDir( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'T1' ) );
            dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iL}{iSubject} , T1List{1} ), '^.*\.dcm$');
            for iDcm    = 1:length(dcmList)
                [path file ext]     = fileparts(char(dcmList(iDcm)));
                if ~exist( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'T1', [file ext]) )
                    xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'T1', [file ext]) );
                    clear path file ext
                end
            end
            clear dcmList
            T1Count     = T1Count+1;
        end
 
%         % FLAIR copy
%         FLAIRList          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iL}{iSubject} ), '^.*(FLAIR|flair).*$', 1);
%         if length(FLAIRList)>0
%             xASL_adm_CreateDir( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'FLAIR' ) );
%             dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iL}{iSubject} , FLAIRList{1} ), '^.*\.dcm$');
%             for iDcm    = 1:length(dcmList)
%                 [path file ext]     = fileparts(char(dcmList(iDcm)));
%                 if ~exist( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'FLAIR', [file ext]) )
%                     xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'FLAIR', [file ext]) );
%                     clear path file ext
%                 end
%             end
%             clear dcmList
%             FLAIRCount     = FLAIRCount+1;
%         end
 
        % non-crushed copy
        noCrushList          = xASL_adm_GetFsList( fullfile( ODIR, LIST{iL}{iSubject} ), '^.*(pseudo_nocrush|PSEUDO_NOCRUSH|psuedo_nocrush|PSUEDO_NOCRUSH).*$', 1);
        if length(noCrushList)>0
            xASL_adm_CreateDir( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'noCrush' ) );
            dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iL}{iSubject} , noCrushList{1} ), '^.*\.dcm$');
            for iDcm    = 1:length(dcmList)
                [path file ext]     = fileparts(char(dcmList(iDcm)));
                if ~exist( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'noCrush', [file ext]) )
                    xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'noCrush', [file ext]) );
                    clear path file ext
                end
            end
            clear dcmList
            noCrushCount        = noCrushCount+1;
        end
 
        % crushed copy
        CrushList               = xASL_adm_GetFsList( fullfile( ODIR, LIST{iL}{iSubject} ), '^.*(pseudo_crush|PSEUDO_CRUSH|psuedo_crush|PSUEDO_CRUSH).*$', 1);
        if length(CrushList)>0
            xASL_adm_CreateDir( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'Crush' ) );
            dcmList     = xASL_adm_GetFileList( fullfile( ODIR, LIST{iL}{iSubject} , CrushList{1} ), '^.*\.dcm$');
            for iDcm    = 1:length(dcmList)
                [path file ext]     = fileparts(char(dcmList(iDcm)));
                if ~exist( fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'Crush', [file ext]) )
                    xASL_Copy( char(dcmList(iDcm)), fullfile( DDIR{iL}, LIST{iL}{iSubject}, 'Crush', [file ext]) );
                    clear path file ext
                end
            end
            clear dcmList
            CrushCount          = CrushCount+1;
        end
 
 
    end

end



