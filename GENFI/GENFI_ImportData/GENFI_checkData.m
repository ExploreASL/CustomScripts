%% GENFI inventory
clear ROOT Dlist
ROOT        = 'C:/Backup/ASL/GENFI/GENFI_DF1';
Dlist       = xASL_adm_GetFsList(ROOT,'^.*$',1)';

[data, text, rawData]     = xlsread( 'C:/Backup/ASL/GENFI/GENFI_DF1_MASTER.xlsx','MAIN');

%% 1) Checking number of subjects

BLINDID     = rawData(2:end,2);

list1       = Dlist;
list2       = BLINDID;

[ NewList ] = CompareLists( list1, list2 );

% Create list missing files
Next    = 1;
for iList=1:length(NewList)
    if  NewList{iList,2}==0
        MissingList{Next,1}     = NewList{iList,1};
        Next = Next+1;
    end
end

% MissingList = subjects
{'C9ORF020';'GRN104';'GRN105';'GRN116';'MAPT016';'MAPT018';}
%% 2) Checking first directory structure: first sublevel
clear DiffList
next=1;
for  iList=1:length(Dlist)
    % First sublevel only includes 1 directory?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,0);
      Dlist{iList,2}    = length(TempList)-2;
      if  length(TempList)~=3
          DiffList{next,1}  = Dlist{iList,1};
          next=next+1;
      end      
end

clear DiffList
next=1;
for  iList=1:length(Dlist)
    % First sublevel includes 0 files?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',0,0);
      Dlist{iList,3}    = length(TempList);
      if  length(TempList)~=0
          DiffList{next,1}  = Dlist{iList,1};
          next=next+1;
      end      
end


% {'GRN052';'GRN077';'MAPT027';} had multiple sessions, merged them into 1
% session
% 'GRN052';'GRN077' 14 May 2D T2 & 2D FLAIR, 28 May 3D T1 done in separate
% session (probably forgotten?) Same center indeed
% Nonimage removed
% 'MAPT027' -> twice T1, twice ASL. 6 June versions look best.
% prefixed with '9' to enable merging directories

% -> now 1st sublevel only contains 1 directory with varying name 
% (e.g. BLINDID with MR session ID), no files
%% 3) Checking first directory structure: 2nd sublevel
clear DiffList
next=1;
for  iList=1:length(Dlist)
    % Second sublevel only includes 1 directory?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}), '^.*$',1,0);
      Dlist{iList,4}    = length(TempList2)-2;
      if  length(TempList2)~=3
          DiffList{next,1}  = Dlist{iList,1};
          next=next+1;
      end      
end

clear DiffList
next=1;
for  iList=1:length(Dlist)
    % Second sublevel includes 0 files?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}), '^.*$',0,0);
      Dlist{iList,5}    = length(TempList2);
      if  length(TempList2)~=0
          DiffList{next,1}  = Dlist{iList,1};
          next=next+1;
      end      
end

clear DiffList
next=1;
for  iList=1:length(Dlist)
    % Second sublevel includes only 1 directory with name "scans"?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}), '^.*$',1,1);
      Dlist{iList,6}    = TempList2{1};
      if  ~strcmp(TempList2{1},'scans')
          DiffList{next,1}  = Dlist{iList,1};
          next=next+1;
      end      
end

% -> 2nd sublevel only contains 1 directory, which is called "scans"
%% 3) Checking first directory structure: 3rd sublevel
clear DiffList numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
for  iList=1:length(Dlist)
    % Get list of possible directories 3rd sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,0);
      
      for iOption=1:length(TempList2)
              % Skip '.' and '..'
          if  ~(strcmp(TempList2{iOption},'.') || strcmp(TempList2{iOption},'..'))
              % if is a number
              if        ~isempty(str2num(TempList2{iOption}))
                        numberList(Numnext,1)    = str2num(TempList2{iOption});
                        Numnext = Numnext+1;
              else      stringList{Strnext,1}   = TempList2{iOption};
                        Strnext = Strnext+1;
              end
              if  strcmp(TempList2{iOption},'DICOM')
                  DICOMcount    = DICOMcount+1;
              end
          end
      end
end

% Count how many of the numbers for each
UniqueList  = unique(numberList);
UniqueList(:,2)=0;
for iU=1:length(UniqueList)
    for iNum=1:length(numberList)
        if  UniqueList(iU,1)==numberList(iNum,1)
            UniqueList(iU,2)=UniqueList(iU,2)+1;
        end
    end
end

clear DiffList
next=1;
for  iList=1:length(Dlist)
    % Third sublevel includes 0 files?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',0,0);
      Dlist{iList,7}    = length(TempList2);
      if  length(TempList2)~=0
          DiffList{next,1}  = Dlist{iList,1};
          next=next+1;
      end      
end

% There were no strings, all were numbers
% 1000-2301 seems to be GE, with part of 301-901 (e.g. 601)
% 301-901 majority Philips
% 2-99 Siemens
% no files
%% Are there subdirectories on 4th level?
clear DiffList numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
TotalScanNumber=0;
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1);
      for iScan=1:length(TempList2)
          TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans',TempList2{iScan}), '^.*$',1,0);

          for iOption=1:length(TempList3)
              
                  % Skip '.' and '..'
              if  ~(strcmp(TempList3{iOption},'.') || strcmp(TempList3{iOption},'..'))
                  % if is a number
                  if        ~isempty(str2num(TempList3{iOption}))
                            numberList(Numnext,1)    = str2num(TempList3{iOption});
                            Numnext = Numnext+1;
                  else      stringList{Strnext,1}   = TempList3{iOption};
                            Strnext = Strnext+1;
                  end
                  if    strcmp(TempList3{iOption},'DICOM')
                        DICOMcount      = DICOMcount+1;
                  else  noCount         = noCount+1;
                  end
                  TotalScanNumber   = TotalScanNumber+1;
              end
          end
      end
end

clear DiffList numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
TotalScanNumber=0;
for  iList=1:length(Dlist)
    % Get list of possible files 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1);
      for iScan=1:length(TempList2)
          TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans',TempList2{iScan}), '^.*$',0,0);

          for iOption=1:length(TempList3)
              
                  % Skip '.' and '..'
              if  ~(strcmp(TempList3{iOption},'.') || strcmp(TempList3{iOption},'..'))
                  % if is a number
                  if        ~isempty(str2num(TempList3{iOption}))
                            numberList(Numnext,1)    = str2num(TempList3{iOption});
                            Numnext = Numnext+1;
                  else      stringList{Strnext,1}   = TempList3{iOption};
                            Strnext = Strnext+1;
                  end
                  if    strcmp(TempList3{iOption},'DICOM')
                        DICOMcount      = DICOMcount+1;
                  else  noCount         = noCount+1;
                  end
                  TotalScanNumber   = TotalScanNumber+1;
              end
          end
      end
end

% All have DICOM directory, no files
%% Are there subdirectories on 5th level?
clear DiffList numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
TotalScanNumber=0;
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1);
      for iScan=1:length(TempList2)
          TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans',TempList2{iScan},'DICOM'), '^.*$',1,0);

          for iOption=1:length(TempList3)
              
                  % Skip '.' and '..'
              if  ~(strcmp(TempList3{iOption},'.') || strcmp(TempList3{iOption},'..'))
                  % if is a number
                  if        ~isempty(str2num(TempList3{iOption}))
                            numberList(Numnext,1)    = str2num(TempList3{iOption});
                            Numnext = Numnext+1;
                  else      stringList{Strnext,1}   = TempList3{iOption};
                            Strnext = Strnext+1;
                  end
                  if    strcmp(TempList3{iOption},'DICOM')
                        DICOMcount      = DICOMcount+1;
                  else  noCount         = noCount+1;
                  end
                  TotalScanNumber   = TotalScanNumber+1;
              end
          end
      end
end

% No further subdirectories after 4th level ('DICOM')
%% What are the file extensions on the 5th level?

clear DiffList numberList stringList 
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
FileCount1          = 0;
FileCount2          = 0;
FileExtList         = {'.dcm'};
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
      TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1);
      for iScan=1:length(TempList2)
          TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans',TempList2{iScan},'DICOM'), '^.*$',0,0);
          FileCount1    = FileCount1+length(TempList3);
          for iOption=1:length(TempList3)
              [Path File Ext]   = fileparts(TempList3{iOption});
              
              if ~max(strcmp(Ext,FileExtList))
                  FileExtList{next,1}   = Ext;
              end
              FileCount2   = FileCount2+1;
          end
      end
end

% So *.dcm only
%% 
% So directory structure is fullfile(ROOT, List{1}, List{1}, 'scans','scannumber','DICOM','^\.dcm$');

%% dicom of each series for data, build list
clear TotalList
TotalList(1,1: 6)       = {'BLINDID'        'Manufacturer' 'SeriesDescription'     'ManufacturerModelName' 'MRAcquisitionType' 'SliceThickness' };
TotalList(1,7:12)       = {'RepetitionTime' 'EchoTime'     'MagneticFieldStrength' 'ProtocolName'          'SoftwareVersion'   'AcquisitionMatrix'};
DeleteList              = {''};

tic
for iList=1:length(Dlist)
    
    TempList            = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
    ScanNRlist          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1);
    for iNR=1:length(ScanNRlist)
        dcmList             = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR},'DICOM'), '^.*\.dcm$','FPList');
        
        if  isempty(dcmList) % in previous run directories not deleted
            rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR},'DICOM') );
            rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR}) );
        else


            tDCM                = dicominfo( dcmList{1} );

            if  strcmp(tDCM.SeriesDescription,'nonimage') || strcmp(tDCM.SeriesDescription,'mpr') || strcmp(tDCM.SeriesDescription,'GENFI_fieldmap') % if empty image or reconstruction or fieldmap
                % Delete empty image, mpr, or fieldmap and keep track of what was deleted
                for iDCM=1:length(dcmList)
                    delete( dcmList{iDCM} );
                end
                rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR},'DICOM') );
                rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR}) );
                DeleteList{end+1,1}   = dcmList{1};

            else
                % Save dicom-header info
                next                = size(TotalList,1)+1;
                TotalList{next,1}   = Dlist{iList};
                for iField=2:12
                    if  isfield(tDCM, TotalList{1,iField} ) 
                        TotalList{next,iField}   = eval(['tDCM.' TotalList{1,iField}]);
                    end
                end


    %             % Make sure other dicoms within the same directory don't have other values
    %             for iDCM=2:length(dcmList)
    %                 tDCM            = dicominfo( dcmList{iDCM} );
    %                 
    %                 clear tValues
    %                 for iField=2:12 % Get fields
    %                     if  isfield(tDCM, TotalList{1,iField} ) 
    %                         tValues{1,iField-1}   = eval(['tDCM.' TotalList{1,iField}]);
    %                     end
    %                 end
    %                 
    %                 for iValue=1:length(tValues)
    %                     if      ischar( tValues{iValue} )
    %                             if  ~strcmp(TotalList(next,1+iValue),tValues{iValue})  % test for identical string
    %                                 error(['Dicom headers "' TotalList{1,1+iValue} '" not equal for scan "' TotalList{next,3} '" of subject "' TotalList{next,1} '"']);
    %                             end
    %                     else    if  ~max(TotalList{next,1+iValue}==tValues{iValue}) % test for identical number
    %                                 error(['Dicom headers "' TotalList{1,1+iValue} '" not equal for scan "' TotalList{next,3} '" of subject "' TotalList{next,1} '"']);
    %                             end
    %                     end
    %                 end
    %             end

            end
        end
    end
end
toc

% So all dicoms have same header info, are all valid

%% Check similarity scans & protocols
for iSub=2:size(TotalList,1)
    if  ~strcmp( TotalList(iSub,3), TotalList(iSub,10))
        error('No similarity scan & protocol!');
    end
end

%% Get unique combinations
clear GElist PHlist SIlist
Vendors     = unique(TotalList(2:end,2));
Scans       = unique(TotalList(2:end,3));
Systems     = unique(TotalList(2:end,4));
Readouts    = unique(TotalList(2:end,5));
Protocols   = unique(TotalList(2:end,10));
Softwares   = unique(TotalList(2:end,11));

GElist      = {''};
PHlist      = {''};
SIlist      = {''};

for iSub=2:size(TotalList,1)
    if      strcmp(TotalList{iSub,2},Vendors{1})
        GElist{end+1,1}     = TotalList{iSub,4};
        GElist{end  ,2}     = TotalList{iSub,3};
        GElist{end  ,3}     = TotalList{iSub,11};
    elseif  strcmp(TotalList{iSub,2},Vendors{2})
        PHlist{end+1,1}     = TotalList{iSub,4};
        PHlist{end  ,2}     = TotalList{iSub,3};    
        PHlist{end  ,3}     = TotalList{iSub,11};            
    elseif  strcmp(TotalList{iSub,2},Vendors{3})
        SIlist{end+1,1}     = TotalList{iSub,4};
        SIlist{end  ,2}     = TotalList{iSub,3};
        SIlist{end  ,3}     = TotalList{iSub,11};
    end
end

ScannersGE  = unique(GElist(2:end,1));
ScannersPH  = unique(PHlist(2:end,1));
ScannersSI  = unique(SIlist(2:end,1));

% GE

clear HDXTlist MR750list
    = {''};
MR750list   = {''};
for iSub=1:size(GElist,1)
    if      strcmp(GElist{iSub,1},ScannersGE{1})
            MR750list{end+1,1}     = GElist{iSub,2};
            MR750list{end  ,2}     = GElist{iSub,3};
    elseif  strcmp(GElist{iSub,1},ScannersGE{2})
            HDXTlist{end+1,1}    = GElist{iSub,2};
            HDXTlist{end  ,2}    = GElist{iSub,3};            
    end
end



% PH

unique(PHlist(2:end,3))

% SI
clear Aeralist Triolist Avantolist Allegralist
Aeralist        = {''};
Triolist        = {''};
Avantolist      = {''};
Allegralist     = {''};

for iSub=1:size(SIlist,1)
    if      strcmp(SIlist{iSub,1},ScannersSI{1})
            Aeralist{end+1,1}     = SIlist{iSub,2};
            Aeralist{end  ,2}     = SIlist{iSub,3};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{2})
            Allegralist{end+1,1}  = SIlist{iSub,2};
            Allegralist{end  ,2}  = SIlist{iSub,3};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{3})
            Avantolist{end+1,1}   = SIlist{iSub,2};
            Avantolist{end  ,2}   = SIlist{iSub,3};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{4})
            Triolist{end+1,1}     = SIlist{iSub,2};
            Triolist{end  ,2}     = SIlist{iSub,3};
    end
end

% Check 2D/3D

TwoDlist    = {''};
ThreeDlist  = {''};

for iSub=2:size(TotalList,1)
    if  ~isempty(strfind( TotalList{iSub,3}, 'asl')) || ~isempty(strfind( TotalList{iSub,3}, 'ASL'))
        % This is an ASL scan
        if      strcmp( TotalList{iSub,5}, '2D' )
                TwoDlist{end+1,1}    = TotalList{iSub,2};
                TwoDlist{end  ,2}    = TotalList{iSub,4};
                TwoDlist{end  ,3}    = TotalList{iSub,3};
        elseif  strcmp( TotalList{iSub,5}, '3D' )
                ThreeDlist{end+1,1}  = TotalList{iSub,2};
                ThreeDlist{end  ,2}  = TotalList{iSub,4};
                ThreeDlist{end  ,3}  = TotalList{iSub,3};
        else    error('Wrong readout code');
        end
    end
end
           

% GE  HDxt 2 software releases (HD15 & % HD16, but no ASL)

% GE MR750 DV22 (single software) 3D ASL
% GENFI_asl, GENFI_t1, GENFI_t2, asl_cbf, calibration (M0), t1_secondary,
% 3D ASL

% Philips Achieva, 2D ASL, software versions:
% '3.2.1'
% '3.2.1\3.2.1.1'
% '3.2.3\3.2.3.0'

% Siemens Aera software syngo MR D11 (1.5 T, no ASL),
% Triotrim software syngo MR B17 3D ASL
% Avanto software syngo MR B17 (1.5T no ASL)
% Allegra software syngo MR 2004A 4VA25, 2D ASL

%% Compare with XLS
% Check genes

for iSub=2:size(rawData,1)
    % 1) Identify genename
    if      ~isempty(strfind(rawData{iSub,2},'C9'))
            CMP     = 'C9orf72';
    elseif  ~isempty(strfind(rawData{iSub,2},'GRN'))
            CMP     = 'GRN';
    elseif  ~isempty(strfind(rawData{iSub,2},'MAPT'))
            CMP     = 'MAPT';
    end
    % 2) Check genename
    if      ~strcmp(rawData{iSub,3},CMP)
            error('Gene not coded right');
    end
end

% Check subjects
SUBJECTNOTFOUND     = {''};
for iRaw=2:size(rawData,1)
    % 1) Find subject in rawData
    clear Subject
    for iSub=2:size(TotalList,1)
        if  ~isempty(strfind(rawData{iRaw,2}, TotalList{iSub,1} ))
            Subject     = rawData{iRaw,2};
        end
    end
    
    if ~exist('Subject','var')
        SUBJECTNOTFOUND{end+1,1}    = rawData{iRaw,2}; 
    end
end
% SubjectsNotFound = {'MAPT018' 'C9ORF020' 'GRN116' 'GRN104' 'GRN105' 'MAPT016'}
% Is correct.

% Check other stuff
ScannerInequality   = {''};
for iSub=2:size(TotalList,1)
    % 1) Find subject in rawData
    clear Subject
    for iRaw=2:size(rawData,1)
        if  ~isempty(strfind(rawData{iRaw,2}, TotalList{iSub,1} ))
            Subject     = rawData{iRaw,2};
            rawI        = iRaw;
        end
    end
    
    if ~exist('Subject','var')
        error('Subject not found');
    end
    
    % 2) Check manufacturer
    Manufacturer1   = rawData{rawI,14};
    Manufacturer2   = TotalList{iSub,2};
    
    if      strcmp(Manufacturer2,'GE MEDICAL SYSTEMS')
        if  isempty(strfind(Manufacturer1,'GE'))
            error('Vendor incompliance');
        end             
    elseif  strcmp(Manufacturer2,'Philips Medical Systems')
        if  isempty(strfind(Manufacturer1,'Philips'))
            error('Vendor incompliance');
        end        
    elseif  strcmp(Manufacturer2,'SIEMENS')
        if  isempty(strfind(Manufacturer1,'Siemens'))
            error('Vendor incompliance');
        end
    end

    % 3) Check scanner system
    System1         = rawData{rawI,14};
    System2         = TotalList{iSub,4};
    ScannerList     = {'Achieva'    'Aera'         'Allegra'    'Avanto'       'DISCOVERY MR750' 'Signa HDxt' 'TrioTim'};
    ScannerList2    = {'Philips 3T' 'Siemens 1.5T' 'Siemens 3T' 'Siemens 1.5T' 'GE 3T'           'GE 1.5T'    'Siemens Trio 3T'};
    
    for iScanner=1:length(ScannerList)
        if  strcmp(System2,ScannerList{iScanner})
            if ~strcmp(System1,ScannerList2{iScanner})
                ScannerInequality{end+1,1}  = Subject;
                ScannerInequality{end  ,2}  = System1;
                ScannerInequality{end  ,3}  = System2;                
            end
        end
    end    
end
% {Subject 'GRN115' was according to dicom header 'Siemens Trio 3T' but says 'Avanto' in xls file}

% Check subjects without T1 & ASL, remove them 
% Check subjects without T1 but with ASL, check other image quality

SubjectList     = unique(TotalList(2:end,1));
NoASLlist       = {''};
ASLnotFound     = {''};
NoT1list        = {''};
T1notFound      = {''};
SeriesList      = unique(TotalList(2:end,3));

for iSub=1:length(SubjectList)
    clear ASL T1
    for iSearch=2:size(TotalList,1)
        if  strcmp(TotalList{iSearch,1}, SubjectList{iSub})
            % This is the subject
            % Check whether ASL/T1 scans exist
            if  ~isempty(strfind( TotalList{iSearch,3}, 'asl'))
                % This is an ASL-scan
                ASL     = TotalList{iSearch,3};
            end
            if  ~isempty(strfind( TotalList{iSearch,3}, 't1'))
                % This is an ASL-scan
                T1     = TotalList{iSearch,3};
            end            
            
            
        end
    end
    
    if ~exist('ASL','var')
        NoASLlist{end+1,1}  = SubjectList{iSub};
        
        % Check with xls-file
        for iRaw=1:length(rawData)
            if  strcmp( rawData{iRaw,2}, SubjectList{iSub})
                % Found subject
                if  rawData{iRaw,19}~=0
                    ASLnotFound{end+1,1}    = SubjectList{iSub};
                end
            end
        end        
    end
    
    if ~exist('T1','var')
        NoT1list{end+1,1}  = SubjectList{iSub};
        
        % Check with xls-file
        for iRaw=1:length(rawData)
            if  strcmp( rawData{iRaw,2}, SubjectList{iSub})
                % Found subject
                if  rawData{iRaw,15}~=0
                    T1notFound{end+1,1}    = SubjectList{iSub};
                end
            end
        end        
    end    
    
end
    
% Only from MAPT017 T1 is missing, but has ASL and good quality T2, which
% can be used for spatial transformation
    
%% Create new raw folder structure to import in pipeline, MovingFiles
% So directory structure is 
% fullfile(ROOT, List{1}, List{1}, 'scans','scannumber','DICOM','^\.dcm$');
% Get 
% GENFI_DATAFREEZE1\SpecificVendorName\BLINDID\ScanName



ScannerList(:,1)     = {'PH Achieva';'SI Aera'  ;'SI Allegra';'SI Avanto';'GE MR750'       ;'GE HDxt'   ;'SI Trio'};
ScannerList(:,2)     = {'Achieva'   ;'Aera'     ;'Allegra'   ;'Avanto'   ;'DISCOVERY MR750';'Signa HDxt';'TrioTim'};

% Change only m0
SeriesList(:,1)      = {'GENFI_asl';'GENFI_asl_19slices';'GENFI_19slices_m0'    ;'GENFI_asl_3x3x7mm_controltag_pair';'GENFI_asl_3x3x7mm_diff';'GENFI_asl_3x3x7mm_perfwt';'GENFI_asl_control';'GENFI_asl_diff';'GENFI_m0'    ;'GENFI_m0_ti1000'    ;'GENFI_m0_ti2000'    ;'GENFI_m0_ti5000'    ;'GENFI_asl_tag';'GENFI_t1';'GENFI_t1_1.25mm_iso_1.5T';'GENFI_t1_1mm';'GENFI_t1_1mm_1.5T';'GENFI_t1_axial';'GENFI_t2';'asl_cbf';'asl_perf_wt';'m0_calibration';'dual_pd_t2_axial';'flair_2d_axial';'t1_1.25mm_iso';'t1_1mm_axial';'t1_1mm_sagittal';'t1_2d_axial';'t1_secondary';'t2_2d_axial';'t2_2d_epi_wholebrain'};
SeriesList(:,2)      = {'GENFI_asl';'GENFI_asl_19slices';'GENFI_asl_19slices_m0';'GENFI_asl_3x3x7mm_controltag_pair';'GENFI_asl_3x3x7mm_diff';'GENFI_asl_3x3x7mm_perfwt';'GENFI_asl_control';'GENFI_asl_diff';'GENFI_asl_m0';'GENFI_asl_m0_ti1000';'GENFI_asl_m0_ti2000';'GENFI_asl_m0_ti5000';'GENFI_asl_tag';'GENFI_t1';'GENFI_t1_1.25mm_iso_1.5T';'GENFI_t1_1mm';'GENFI_t1_1mm_1.5T';'GENFI_t1_axial';'GENFI_t2';'asl_cbf';'asl_perf_wt';'calibration'   ;'dual_pd_t2_axial';'flair_2d_axial';'t1_1.25mm_iso';'t1_1mm_axial';'t1_1mm_sagittal';'t1_2d_axial';'t1_secondary';'t2_2d_axial';'t2_2d_epi_wholebrain'};

ROOTnew              = 'C:\Backup\ASL\GENFI\GENFI_DF1_new';
for iS=1:size(ScannerList,1)
    xASL_adm_CreateDir( fullfile( ROOTnew, ScannerList{iS,1}) );
end

PROCESSED       = {''};
SKIPPED         = {''};
tic
for iList=1:length(Dlist)
    clear TempList ScanNRlist
    TempList            = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);
    
        if length(TempList)>0
        ScanNRlist          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1);
        for iNR=1:length(ScanNRlist)
            clear ScanDir dcmList tDCM ProcessReady iScan iSeries SeriesDir
            ScanDir             = fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans',ScanNRlist{iNR});
            dcmList             = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR},'DICOM'), '^.*\.dcm$','FPList');

            if  length(dcmList)<1
                SKIPPED{end+1,1}    = ScanDir;
            else

                tDCM                = dicominfo( dcmList{1} );

                ProcessReady        = 0;
                % Determine scanner
                for iScan=1:size(ScannerList,1)
                    if  strcmp( tDCM.ManufacturerModelName,ScannerList{iScan,2} ) % if found vendor system
                        SubjectDir  = fullfile( ROOTnew, ScannerList{iScan,1}, Dlist{iList} ); 
                        xASL_adm_CreateDir( SubjectDir ); % create subjectdir

                        % Determine series
                        for iSeries=1:size(SeriesList,1)
                            if  strcmp( tDCM.SeriesDescription,SeriesList{iSeries,2} ) % if found series
                                SeriesDir   = fullfile( ROOTnew, ScannerList{iScan,1}, Dlist{iList}, SeriesList{iSeries,1} );
                                xASL_adm_CreateDir( SeriesDir ); % create seriesdir

                                for iDCM=1:length(dcmList) % move dicom files
                                    clear P F E NewFile
                                    [P F E]     = fileparts(dcmList{iDCM});
                                    NewFile     = fullfile( SeriesDir, [F E]);
                                    if  exist(dcmList{iDCM},'file') && ~exist(NewFile)
                                        xASL_Move( dcmList{iDCM}, NewFile );
                                    end
                                end

                                clear CopiedFileList
                                CopiedFileList  = xASL_adm_GetFileList( SeriesDir, '^.*\.dcm$','FPList');
                                rmdir( fullfile( ScanDir, 'DICOM') );
                                rmdir( ScanDir );

                                % check successful moving
                                if      length(CopiedFileList)==length(dcmList)
                                        PROCESSED{end+1,1}      = SeriesDir;
                                        ProcessReady            = 1;
                                end
                            end
                        end
                    end
                end
                if  ProcessReady~=1
                    SKIPPED{end+1,1}        = ScanDir;
                end
            end
        end
        % Remove empty directories
        ScanNRlist          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans'), '^.*$',1,1,0,[0 Inf]);
        if  ~length(ScanNRlist)
            rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans') );
            rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{1} ) );
        end
        Temp2list           = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,0,[0 Inf]);
        if  ~length(Temp2list)
            rmdir( fullfile(ROOT, Dlist{iList,1}) );
        end    
    end
end

toc
    
% Check whether new vendor structure fits with xls (just quick double check with xls viewing, not programming)


% Compare between sites later

% Create unique SeriesDescription list, that can be simplified
% DirectoryNameList. e.g.:
% different names->T2. keep T2, remove if T1 is good quality.
% Keep actual SeriesDescriptionName in .mat
% Siemens ASL tag, control, diff -> convert to ASL_1 ASL_2 ASL_3, assemble later
% Siemens M0_ti1000 2000 5000, compare quality, if 5000 OK then use 5000

% -> do Dice coefficient T1 c1 segmentation (continuous, no cutoff)
% integral (sum) in MNI c1 >0.5. Same for all vendors, and check whether mean & spread
% differ. Than same for EPI & PWI. Check first between sites, then between
% vendors. 
% Check these results before T1 DARTEL, then probably can do T1 DARTEL with
% whole population together.
% Then EPI DARTEL check too few subjects per site, do per vendor or perhaps
% all together if 
