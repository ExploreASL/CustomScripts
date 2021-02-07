
%% CreateList subjects DF1 & DF2 based on directory

clear DataFreeze FollowUp ErrorList

ROOT_MAIN = 'C:\GENFI_DF2';

ROOT{1}   = fullfile( ROOT_MAIN, 'GENFI_DF1');
ROOT{2}   = fullfile( ROOT_MAIN, 'GENFI_DF2');

% 1) in DF1
FList     = xASL_adm_GetFsList(ROOT{1},'^(C9ORF|GRN|MAPT)\d{3}$',1);
for iF=1:length(FList)
    DataFreeze{iF,1}    = FList{iF};
    DataFreeze{iF,2}    = 1;
end

% 2) in DF2 -> either f/u or error
FList       = xASL_adm_GetFsList(ROOT{2},'^(C9ORF|GRN|MAPT)\d{3}$',1);
fuI         = 1;
elI         = 1;
for iF=1:length(FList)
    ExistAlready = 0;
    for iF2=1:length(DataFreeze)
        if  strcmp(DataFreeze{iF2,1},FList{iF})
            ExistAlready = 1;
        end
    end

    if ~ExistAlready
        DataFreeze{end+1,1}     = FList{iF};
        DataFreeze{end  ,2}     = 2;
    else
        FList3                  = xASL_adm_GetFsList( fullfile( ROOT{2}, FList{iF} ), ['^' FList{iF} '-\d{2}-MR\d{2}'],1 );
        if  ~isempty(strfind(FList3,'02'))
            FollowUp{fuI,1}     = FList{iF};
            fuI                 = fuI+1;
        else

            ErrorList{elI,1}    = FList{iF};
            elI                 = elI+1;
        end
    end

end

SaveFile    = fullfile( ROOT_MAIN, 'DataFreeze.mat');
save( SaveFile, 'DataFreeze');


%% Read & save excel file
[data, text, rawData]   = xlsread( 'C:/Backup/ASL/GENFI/GENFI_DF2_MASTER_16Feb2016_HJM.xlsx','MAIN_DATA');
rawData                 = rawData(1:366,:);
SaveFile                = fullfile( ROOT_MAIN, 'rawData.mat');
save( SaveFile, 'rawData');
load( SaveFile);

%% Check folderNames DF1 & DF2

ROOT_MAIN = 'C:\GENFI_DF2';

ROOT{1}   = fullfile( ROOT_MAIN, 'GENFI_DF1');
ROOT{2}   = fullfile( ROOT_MAIN, 'GENFI_DF2');
clear FList
for ii=1:2
    FList{ii}  = xASL_adm_GetFsList(ROOT{ii},'^(C9ORF|GRN|MAPT)\d{3}$',1);
end

MissingList     = '';
NoASLlist       = '';
% Iterate across subjects
for iC=2:size(TotalList,1)
    Found   = 0;

    % Search in DF 1 dir or DF 2 dir
    if      TotalList{iC,3}==0

            for iF=1:length(FList{1})
                if  strcmp( TotalList{iC,2}, FList{1}{iF} )
                    Found   = 1;
                end
            end

    elseif  TotalList{iC,3}==1

            for iF=1:length(FList{2})
                if strcmp( TotalList{iC,2}, FList{2}{iF} )
                    Found   = 1;
                end
            end
    end

    if ~Found
        if  ~TotalList{iC,21}
            NoASLlist{end+1,1}      = iC;
            NoASLlist{end,  1}      = TotalList{iC,2};
        else
            MissingList{end+1,1}    = iC;
            MissingList{end,  2}    = TotalList{iC,2};
        end
    end

end

%% Downloaded missing items
% GRN111 is only number that is in between other numbers (for the
% ASL-containing subjects), that is DF2 instead of DF1

% Now checked directories with excel file, and DF1 or DF2 has been saved
% in "DataFreeze.mat", so speed up by putting both DFs in single directory



%% 2) Checking first directory structure: first sublevel
ROOT    = 'C:\GENFI_DF2\GENFI_DF12';

clear DiffList
Dlist       = xASL_adm_GetFsList(ROOT,'^(C9ORF|GRN|MAPT)\d{3}$',1)';

next=1;
for ii=1:5
    Count{ii}   = 0;
end

for  iList=1:length(Dlist)
     DiffList{iList,1}  = Dlist{iList};
    % First sublevel includes directories session 1, 2, 3, any other
    % directories?

      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,0,[],[0 Inf]);
      TempList          = TempList(3:end);

      for iT=1:length(TempList)
          Found     = 0;
          for iNum=1:5
              if ~isempty(strfind(TempList{iT},['-0' num2str(iNum) '-']))
                  DiffList{iList,1+iNum}  = TempList{iT};
                  Found         = 1;
                  Count{iNum}     = Count{iNum}+1;
              end
          end

          if ~Found
              DiffList{iList,7}     = length( TempList{iT} );
          end
      end
end

for  iList=1:length(Dlist)
    % First sublevel includes 0 files?
      TempList              = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',0,0,[],[0 Inf]);
      if  length(TempList)~=0
        DiffList{iList,8}    = length(TempList);
      end
end

% MAPT016 doesn't have a first session?
% There are no files
% NB: at analysis of baseline data, there were a handful subjects with
% baseline & follow-up, which I considered a rescan and used the best
% datapoint

%% 3) Checking 2nd sublevel
% Contains only a single directory, named "scans"

for  iList=1:length(Dlist)

    % Second sublevel only includes 1 directory?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

      for iT=1:length(TempList)
          TempList2     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}), '^.*$',1,0,[],[0 Inf]); % folders

          Found     = 0;

          for ii=3:length(TempList2) % is there a single 'scans' folder, and no other?
              if  strcmp(TempList2{ii},'scans')
                  Found     = 1;
              else
                  DiffList{iList,9+ii}  = TempList2{ii};
              end
          end
          if ~Found
              DiffList{iList,9}     = 'No scans folder';
          end

          TempList2     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}), '^.*$',0,0,[],[0 Inf]); % files
          DiffList{iList,13}    = length(TempList2);
      end
end


%% 4) Checking 3rd sublevel
Numnext     = 1;
Strnext     = 1;
DICOMcount  = 0;

for  iList=1:length(Dlist)

    % Second sublevel only includes 1 directory?
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

      for iT=1:length(TempList)
          TempList2     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT},'scans'), '^.*$',1,0,[],[0 Inf]); % folders

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

          DiffList{iList,14}    = length(TempList2); % folders
          DiffList{iList,15}    = length( xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT},'scans'), '^.*$',0,0,[],[0 Inf]) ); % files

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


% There were no strings, all were numbers
% 1000-2301 seems to be GE, with part of 301-901 (e.g. 601)
% 301-901 majority Philips
% 2-99 Siemens
% no files


%% 5) Are there subdirectories on 4th level?
clear numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
TotalScanNumber=0;
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

      for iT=1:length(TempList)

        TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,[],[0 Inf]);

          for iScan=1:length(TempList2)
              TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans',TempList2{iScan}), '^.*$',1,0,[],[0 Inf]);

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
end

clear numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
TotalScanNumber=0;
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

      for iT=1:length(TempList)

        TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,[],[0 Inf]);

          for iScan=1:length(TempList2)
              TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans',TempList2{iScan}), '^.*$',0,0,[],[0 Inf]);

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
end

% All have DICOM directory, no files


%% Are there subdirectories on 5th level?
clear numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
TotalScanNumber=0;
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

      for iT=1:length(TempList)
        TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,[],[0 Inf]);

          for iScan=1:length(TempList2)
              TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans',TempList2{iScan},'DICOM'), '^.*$',1,0,[],[0 Inf]);

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
end

% No further subdirectories after 4th level ('DICOM')

%% What are the file extensions on the 5th level?

clear numberList stringList
Numnext     = 1;
Strnext     = 1;
DICOMcount=0;
noCount=0;
FileCount1          = 0;
FileCount2          = 0;
FileExtList         = {'.dcm'};
for  iList=1:length(Dlist)
    % Get list of possible directories 4th sublevel
      TempList          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

      for iT=1:length(TempList)
            TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,[],[0 Inf]);

          TempList2         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,[],[0 Inf]);
          for iScan=1:length(TempList2)
              TempList3     = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans',TempList2{iScan},'DICOM'), '^.*$',0,0,[],[0 Inf]);
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
end

% So *.dcm only

%% So directory structure is fullfile(ROOT, List{1}, List{1}, 'scans','scannumber','DICOM','^\.dcm$');

%% dicom of each series for data, build list
clear TotalList
TotalList(1,1: 6)       = {'BLINDID'        'Manufacturer' 'SeriesDescription'     'ManufacturerModelName' 'MRAcquisitionType' 'SliceThickness' };
TotalList(1,7:12)       = {'RepetitionTime' 'EchoTime'     'MagneticFieldStrength' 'ProtocolName'          'SoftwareVersion'   'AcquisitionMatrix'};
DeleteList              = {''};
ErrorMess               = '';

tic
for iList=1:length(Dlist)

    TempList            = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

    for iT=1:length(TempList)

        ScanNRlist      = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,[],[0 Inf]);

        for iNR=1:length(ScanNRlist)
            dcmList         = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans', ScanNRlist{iNR},'DICOM'), '^.*\.dcm$','FPList');

            if  isempty(dcmList) % in previous run directories not deleted
                DIRNAME     = fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans', ScanNRlist{iNR},'DICOM');
                if isdir( DIRNAME );rmdir( DIRNAME );end
                DIRNAME     = fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans', ScanNRlist{iNR});
                if isdir( DIRNAME );rmdir( DIRNAME );end

            else

                tDCM                = dicominfo( dcmList{1} );

                if  strcmp(tDCM.SeriesDescription,'nonimage') || strcmp(tDCM.SeriesDescription,'mpr') || strcmp(tDCM.SeriesDescription,'GENFI_fieldmap') % if empty image or reconstruction or fieldmap
                    % Delete empty image, mpr, or fieldmap and keep track of what was deleted
                    for iDCM=1:length(dcmList)
                        delete( dcmList{iDCM} );
                    end

                    DIRNAME     = fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR},'DICOM');
                    if isdir( DIRNAME );rmdir( DIRNAME );end
                    DIRNAME     = fullfile(ROOT, Dlist{iList,1}, TempList{1}, 'scans', ScanNRlist{iNR});
                    if isdir( DIRNAME );rmdir( DIRNAME );end
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


                    % Make sure other dicoms within the same directory don't have other values
                    for iDCM=2:length(dcmList)
                        tDCM            = dicominfo( dcmList{iDCM} );

                        clear tValues
                        for iField=2:12 % Get fields
                            if  isfield(tDCM, TotalList{1,iField} )
                                tValues{1,iField-1}   = eval(['tDCM.' TotalList{1,iField}]);
                            end
                        end

                        for iValue=1:length(tValues)
                            if      ischar( tValues{iValue} )
                                    if  ~strcmp(TotalList(next,1+iValue),tValues{iValue})  % test for identical string
                                        ErrorMess{end+1,1}  = ['Dicom headers "' TotalList{1,1+iValue} '" not equal for scan "' TotalList{next,3} '" of subject "' TotalList{next,1} '"'];
                                        % error(['Dicom headers "' TotalList{1,1+iValue} '" not equal for scan "' TotalList{next,3} '" of subject "' TotalList{next,1} '"']);
                                    end
                            else    if  ~max(TotalList{next,1+iValue}==tValues{iValue}) % test for identical number
                                        ErrorMess{end+1,1}  = ['Dicom headers "' TotalList{1,1+iValue} '" not equal for scan "' TotalList{next,3} '" of subject "' TotalList{next,1} '"'];
%                                         error(['Dicom headers "' TotalList{1,1+iValue} '" not equal for scan "' TotalList{next,3} '" of subject "' TotalList{next,1} '"']);
                                    end
                            end
                        end
                    end

                end
            end
        end
    end
end
toc

SaveFile                = fullfile( ROOT_MAIN, 'TotalList.mat');
save( SaveFile, 'TotalList');
load( SaveFile);

% So all dicoms have same header info, are all valid
% Except from the dual_PD T2_axial scans, but not going to use these

%% Check similarity scans & protocols
ErrorMess               = '';
for iSub=2:size(TotalList,1)
    if  ~strcmp( TotalList(iSub,3), TotalList(iSub,10))
        ErrorMess{end+1,1} = ['No similarity scan & protocol ' num2str(iSub)];
    end
end
% Was only one Philips scan with different naming by technician or
% physicist

%% Get unique combinations
% Vendors
clear GElist PHlist SIlist
clera NonEmptyList; next=1;
for iSub=2:size(TotalList,1);
    if ~isempty(TotalList{iSub,2});NonEmptyList(next,1)=TotalList(iSub,2);next=next+1;end
end
Vendors     = unique( NonEmptyList );

clear NonEmptyList;next=1;
for iSub=2:size(TotalList,1);
    if ~isempty(TotalList{iSub,3});NonEmptyList(next,1)=TotalList(iSub,3);next=next+1;end
end
Scans       = unique(NonEmptyList);

clear NonEmptyList;next=1;
for iSub=2:size(TotalList,1);
    if ~isempty(TotalList{iSub,4});NonEmptyList(next,1)=TotalList(iSub,4);next=next+1;end
end
Systems       = unique(NonEmptyList);

clear NonEmptyList;next=1;
for iSub=2:size(TotalList,1);
    if ~isempty(TotalList{iSub,5});NonEmptyList(next,1)=TotalList(iSub,5);next=next+1;end
end
Readouts       = unique(NonEmptyList);

clear NonEmptyList;next=1;
for iSub=2:size(TotalList,1);
    if ~isempty(TotalList{iSub,10});NonEmptyList(next,1)=TotalList(iSub,10);next=next+1;end
end
Protocols       = unique(NonEmptyList);

clear NonEmptyList;next=1;
for iSub=2:size(TotalList,1);
    if ~isempty(TotalList{iSub,11});NonEmptyList(next,1)=TotalList(iSub,11);next=next+1;end
end
Softwares       = unique(NonEmptyList);


GElist      = {''};
PHlist      = {''};
SIlist      = {''};

for iSub=2:size(TotalList,1)
    if      strcmp(TotalList{iSub,2},Vendors{1})
        GElist{end+1,4}     = TotalList{iSub,1};
        GElist{end  ,1}     = TotalList{iSub,4};
        GElist{end  ,2}     = TotalList{iSub,3};
        GElist{end  ,3}     = TotalList{iSub,11};
    elseif  strcmp(TotalList{iSub,2},Vendors{2})
        PHlist{end+1,1}     = TotalList{iSub,4};
        PHlist{end  ,4}     = TotalList{iSub,1};
        PHlist{end  ,2}     = TotalList{iSub,3};
        PHlist{end  ,3}     = TotalList{iSub,11};
    elseif  strcmp(TotalList{iSub,2},Vendors{3})
        SIlist{end+1,1}     = TotalList{iSub,4};
        SIlist{end  ,4}     = TotalList{iSub,1};
        SIlist{end  ,2}     = TotalList{iSub,3};
        SIlist{end  ,3}     = TotalList{iSub,11};
    end
end

ScannersGE  = unique(GElist(2:end,1));
ScannersPH  = unique(PHlist(2:end,1));
ScannersSI  = unique(SIlist(2:end,1));

SoftwareGE  = unique(GElist(2:end,3));
SoftwarePH  = unique(PHlist(2:end,3));
SoftwareSI  = unique(SIlist(2:end,3));

% GE

clear HDXTlist MR750list
HDXTlist    = {''};
MR750list   = {''};
for iSub=1:size(GElist,1)
    if      strcmp(GElist{iSub,1},ScannersGE{1})
            MR750list{end+1,1}     = GElist{iSub,2};
            MR750list{end  ,2}     = GElist{iSub,3};
            MR750list{end  ,3}     = GElist{iSub,4};
    elseif  strcmp(GElist{iSub,1},ScannersGE{2})
            HDXTlist{end+1,1}    = GElist{iSub,2};
            HDXTlist{end  ,2}    = GElist{iSub,3};
            HDXTlist{end  ,3}    = GElist{iSub,4};
    end
end


% PH

unique(PHlist(2:end,3))

clear AchievaList
AchievaList = {''};

for iSub=1:size(PHlist,1)
    AchievaList{end+1,1}     = PHlist{iSub,2};
    AchievaList{end  ,2}     = PHlist{iSub,3};
    AchievaList{end  ,3}     = PHlist{iSub,4};
end


% SI
clear Aeralist Triolist Avantolist Allegralist
Aeralist        = {''};
Triolist        = {''};
Avantolist      = {''};
Allegralist     = {''};
SkyraList       = {''};
TrioTimList     = {''};
Prismalist      = {''};

for iSub=1:size(SIlist,1)
    if      strcmp(SIlist{iSub,1},ScannersSI{1})
            Aeralist{end+1,1}     = SIlist{iSub,2};
            Aeralist{end  ,2}     = SIlist{iSub,3};
            Aeralist{end  ,3}     = SIlist{iSub,4};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{2})
            Allegralist{end+1,1}  = SIlist{iSub,2};
            Allegralist{end  ,2}  = SIlist{iSub,3};
            Allegralist{end  ,3}  = SIlist{iSub,4};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{3})
            Avantolist{end+1,1}   = SIlist{iSub,2};
            Avantolist{end  ,2}   = SIlist{iSub,3};
            Avantolist{end  ,3}   = SIlist{iSub,4};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{4})
            Prismalist{end+1,1}     = SIlist{iSub,2};
            Prismalist{end  ,2}     = SIlist{iSub,3};
            Prismalist{end  ,3}     = SIlist{iSub,4};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{5})
            SkyraList{end+1,1}     = SIlist{iSub,2};
            SkyraList{end  ,2}     = SIlist{iSub,3};
            SkyraList{end  ,3}     = SIlist{iSub,4};
    elseif  strcmp(SIlist{iSub,1},ScannersSI{6})
            TrioTimList{end+1,1}     = SIlist{iSub,2};
            TrioTimList{end  ,2}     = SIlist{iSub,3};
            TrioTimList{end  ,3}     = SIlist{iSub,4};
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

%% Compare with XLS
% Check genes

ErrorMess   = '';

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
    if      ~strcmp(rawData{iSub,4},CMP)
            ErrorMess{end+1,1}  = ['Gene not coded right subject ' num2str(iSub)];
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

    if ~exist('Subject','var') && rawData{iRaw,21}
        SUBJECTNOTFOUND{end+1,1}    = rawData{iRaw,2};
    end
end

% Only subjects that were not found, were those without ASL


% Check other stuff
ErrorMess           = {''};
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
    Manufacturer1   = rawData{rawI,16};
    Manufacturer2   = TotalList{iSub,2};

    if      strcmp(Manufacturer2,'GE MEDICAL SYSTEMS')
        if  isempty(strfind(Manufacturer1,'GE'))
            ErrorMess{end+1,1}  = ['Vendor incompliance GE ' num2str(iSub)];
        end
    elseif  strcmp(Manufacturer2,'Philips Medical Systems')
        if  isempty(strfind(Manufacturer1,'Philips'))
            ErrorMess{end+1,1}  = ['Vendor incompliance Philips ' num2str(iSub)];
        end
    elseif  strcmp(Manufacturer2,'SIEMENS')
        if  isempty(strfind(Manufacturer1,'Siemens'))
            ErrorMess{end+1,1}  = ['Vendor incompliance Siemens ' num2str(iSub)];
        end
    end

    % 3) Check scanner system
    System1         = rawData{rawI,16};
    System2         = TotalList{iSub,4};
    ScannerList     = {'Achieva'    'Aera'         'Allegra'    'Avanto'       'DISCOVERY MR750' 'Signa HDxt' 'TrioTim'           'Prisma_fit'      'Skyra'};
    ScannerList2    = {'Philips 3T' 'Siemens 1.5T' 'Siemens 3T' 'Siemens 1.5T' 'GE 3T'           'GE 1.5T'    'Siemens Trio 3T'   'Siemens Trio 3T' 'Siemens Skyra 3T'};
    % Prisma has the same here as TrioTim, because Prisma is for the
    % follow-up only

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
SeriesListOLD   = unique(TotalList(2:end,3));

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
                if  rawData{iRaw,21}~=0
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

% Only from Philips MAPT017 T1 is missing, but has ASL and good quality T2, which
% can be used for spatial transformation

%% Create new raw folder structure to import in pipeline, MovingFiles
ROOTnew             = 'C:\GENFI_DF2\GENFI_DF12';
ROOT                = ROOTnew;

Dlist               = xASL_adm_GetFsList(ROOT,'^(C9ORF|GRN|MAPT)\d{3}$',1)';

clear ScannerList
ScannerList(:,1)     = {'PH Achieva';'SI Aera'  ;'SI Allegra';'SI Avanto';'GE MR750'       ;'GE HDxt'   ;'SI Trio';'SI Prisma' ;'SI Skyra'};
ScannerList(:,2)     = {'Achieva'   ;'Aera'     ;'Allegra'   ;'Avanto'   ;'DISCOVERY MR750';'Signa HDxt';'TrioTim';'Prisma_fit';'Skyra'};
ScannerList(:,3)     = {'PH'        ;'SI'       ;'SI'        ;'SI'       ;'GE'             ;'GE'        ;'SI'     ;'SI'        ;'SI'};

% Change only seriesnames for M0 scans
clear SeriesList
SeriesList(:,1)      = {'GENFI_asl';'GENFI_asl_19slices';'GENFI_19slices_m0'    ;'GENFI_asl_3x3x7mm_controltag_pair';'GENFI_asl_3x3x7mm_diff';'GENFI_asl_3x3x7mm_perfwt';'GENFI_asl_control';'GENFI_asl_diff';'GENFI_m0'    ;'GENFI_m0_ti1000'    ;'GENFI_m0_ti2000'    ;'GENFI_m0_ti5000'    ;'GENFI_asl_tag';'GENFI_t1';'GENFI_t1_1.25mm_iso_1.5T';'GENFI_t1_1mm';'GENFI_t1_1mm_1.5T';'GENFI_t1_axial';'GENFI_t2';'asl_cbf';'asl_diff';'asl_perf_wt';'asl_tag';'m0_calibration';'dual_pd_t2_axial';'t1_1.25mm_iso';'t1_1mm_axial';'t1_1mm_sagittal';'t1_2d_axial';'t1_secondary';'t2_2d_axial';'t2_2d_epi_wholebrain';'flair_2d_axial'};
SeriesList(:,2)      = {'GENFI_asl';'GENFI_asl_19slices';'GENFI_asl_19slices_m0';'GENFI_asl_3x3x7mm_controltag_pair';'GENFI_asl_3x3x7mm_diff';'GENFI_asl_3x3x7mm_perfwt';'GENFI_asl_control';'GENFI_asl_diff';'GENFI_asl_m0';'GENFI_asl_m0_ti1000';'GENFI_asl_m0_ti2000';'GENFI_asl_m0_ti5000';'GENFI_asl_tag';'GENFI_t1';'GENFI_t1_1.25mm_iso_1.5T';'GENFI_t1_1mm';'GENFI_t1_1mm_1.5T';'GENFI_t1_axial';'GENFI_t2';'asl_cbf';'asl_diff';'asl_perf_wt';'asl_tag';'calibration'   ;'dual_pd_t2_axial';'t1_1.25mm_iso';'t1_1mm_axial';'t1_1mm_sagittal';'t1_2d_axial';'t1_secondary';'t2_2d_axial';'t2_2d_epi_wholebrain';'flair_2d_axial'};

% for ii=1:31
%     if ~strcmp(SeriesListOLD{ii,1},SeriesList{ii,2})
%         error('not the same');
%     end
% end


for iS=1:size(ScannerList,1)
    xASL_adm_CreateDir( fullfile( ROOTnew, ScannerList{iS,1}) );
end

PROCESSED       = {''};
SKIPPED         = {''};
tic


for iList=1:length(Dlist)
    clear TempList ScanNRlist
    TempList            = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1);

    for iT=1:length(TempList)

        ScanNRlist          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1);

        % Get SessionNumber
                SessionN=1;
        while   isempty(strfind(TempList{iT},['-0' num2str(SessionN) '-']))
                SessionN=SessionN+1;
        end

        for iNR=1:length(ScanNRlist)
            clear ScanDir dcmList tDCM ProcessReady iScan iSeries SeriesDir
            ScanDir             = fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans',ScanNRlist{iNR});
            dcmList             = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans', ScanNRlist{iNR},'DICOM'), '^.*\.dcm$','FPList');

            if  length(dcmList)<1
                SKIPPED{end+1,1}    = ScanDir;
            else

                tDCM                = dicominfo( dcmList{1} );

                ProcessReady        = 0;
                % Determine scanner
                for iScan=1:size(ScannerList,1)
                    MRIsystemFound  = 0;
                    if      isfield(tDCM,'ManufacturerModelName')
                            if  strcmp( tDCM.ManufacturerModelName,ScannerList{iScan,2} ) % if found vendor system
                                MRIsystemFound  = 1;
                            end
                    elseif  (strcmp(tDCM.SequenceName,'tgse3d1_2256t0') || strcmp(tDCM.SequenceName,'*tfl3d1_16ns') || strcmp(tDCM.SequenceName,'*spcR_282ns') ) && strcmp(ScannerList{iScan,2},'Skyra')   % if found vendor system
                            MRIsystemFound  = 1;
                    end

                    if  MRIsystemFound

                        SubjectDir  = fullfile( ROOTnew, ScannerList{iScan,1}, Dlist{iList},['Session_' num2str(SessionN)] );
                        xASL_adm_CreateDir( SubjectDir ); % create subjectdir

                        % Determine series
                        for iSeries=1:size(SeriesList,1)
                            if  strcmp( tDCM.SeriesDescription,SeriesList{iSeries,2} ) % if found series

                                SeriesDir   = fullfile( ROOTnew, ScannerList{iScan,1}, Dlist{iList}, ['Session_' num2str(SessionN)], SeriesList{iSeries,1} );

                                % if this scan already existed, put it in a
                                % new folder
                                N=2;
                                while   isdir(SeriesDir)
                                        SeriesDir   = fullfile( ROOTnew, ScannerList{iScan,1}, Dlist{iList}, ['Session_' num2str(SessionN)], [SeriesList{iSeries,1} '_' num2str(N)] );
                                        N=N+1;
                                end

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
        ScanNRlist          = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans'), '^.*$',1,1,0,[0 Inf]);
        if  ~length(ScanNRlist)
            rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{iT}, 'scans') );
            rmdir( fullfile(ROOT, Dlist{iList,1}, TempList{iT} ) );
        end
    end

    Temp2list           = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,0,[0 Inf]);
    if  ~length(Temp2list)
        rmdir( fullfile(ROOT, Dlist{iList,1}) );
    end

end

toc

%% Rename folders, include ScannerName
ROOT    = 'C:\GENFI_DF2\GENFI_DF12\GE MR750';
FList   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    xASL_Rename( fullfile( ROOT, FList{iF} ), ['GE_' FList{iF}] );
end

ROOT    = 'C:\GENFI_DF2\GENFI_DF12\SI Allegra';
FList   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    xASL_Rename( fullfile( ROOT, FList{iF} ), ['SI_Allegra_' FList{iF}] );
end

% Move directories to one level up


ROOT    = 'C:\GENFI_DF2\GENFI_DF12\SI Prisma';
FList   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    xASL_Rename( fullfile( ROOT, FList{iF} ), ['SI_Prisma_' FList{iF}] );
end


ROOT    = 'C:\GENFI_DF2\GENFI_DF12\SI Skyra';
FList   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    xASL_Rename( fullfile( ROOT, FList{iF} ), ['SI_Skyra_' FList{iF}] );
end

ROOT    = 'C:\GENFI_DF2\GENFI_DF12\SI Trio';
FList   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    xASL_Rename( fullfile( ROOT, FList{iF} ), ['SI_Trio_' FList{iF}] );
end

ROOT    = 'C:\GENFI_DF2\GENFI_DF12\PH Achieva';
FList   = xASL_adm_GetFsList( ROOT, '^(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    xASL_Rename( fullfile( ROOT, FList{iF} ), ['PH_Achieva_' FList{iF}] );
end


%% Move sessions to suffix of dirName: ScannerNameSubjectNameSessionN

ROOT    = 'C:\GENFI_DF2\GENFI_DF12';
FList   = xASL_adm_GetFsList( ROOT, '^.*_(C9ORF|GRN|MAPT)\d{3}$',1);

for iF=1:length(FList)
    clear FList2
    FList2  = xASL_adm_GetFsList( fullfile(ROOT, FList{iF}), '^Session_\d$',1);
    for iF2=1:length(FList2)
        clear NewDir FList3
        NewDir  = fullfile(ROOT, [FList{iF} '_' FList2{iF2}(9:end)] );
        xASL_adm_CreateDir(NewDir);
        FList3  = xASL_adm_GetFsList( fullfile(ROOT, FList{iF}, FList2{iF2}), '^.*$',1);
        for iF3=1:length(FList3)
            xASL_Move( fullfile(ROOT, FList{iF}, FList2{iF2}, FList3{iF3}) , fullfile( NewDir, FList3{iF3}) );
        end
        rmdir( fullfile(ROOT, FList{iF}, FList2{iF2} ) );
    end
    rmdir( fullfile(ROOT, FList{iF} ) );
end

%% For Philips, add Bsup or noBsup

ROOT    = 'C:\GENFI_DF2\GENFI_DF12';
FList   = xASL_adm_GetFsList( ROOT, '^PH_Achieva_(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iF=1:length(FList)
    if  isempty( xASL_adm_GetFsList( fullfile(ROOT, FList{iF}), '^GENFI_asl_3x3x7mm_.*$',1) )
        xASL_Rename( fullfile( ROOT, FList{iF} ) , ['PH_Achieva_noBsup_' FList{iF}(12:end)] );
    else
        xASL_Rename( fullfile( ROOT, FList{iF} ) ,    ['PH_Achieva_Bsup_' FList{iF}(12:end)] );
    end
end











%% Build DicomList for each series for data, to check data similarity within vendor/sequences
clear TotalList
TotalList(1,1: 6)       = {'BLINDID'        'Manufacturer' 'SeriesDescription'     'ManufacturerModelName' 'MRAcquisitionType' 'SliceThickness' };
TotalList(1,7:12)       = {'RepetitionTime' 'EchoTime'     'MagneticFieldStrength' 'ProtocolName'          'SoftwareVersion'   'AcquisitionMatrix'};
DeleteList              = {''};
ErrorMess               = '';

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12';
Dlist                   = xASL_adm_GetFsList( ROOT, '^.*_(C9ORF|GRN|MAPT)\d{3}_\d$',1);


for iList=1:length(Dlist)

    TempList            = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iList,1}), '^.*$',1,1,[],[0 Inf]);

    for iT=1:length(TempList)

        dcmList         = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iList,1}, TempList{iT} ), '^.*\.dcm$','FPList');
        tDCM            = dicominfo( dcmList{1} );

        % Save dicom-header info
        next                = size(TotalList,1)+1;
        TotalList{next,1}   = Dlist{iList};
        for iField=2:12
            if  isfield(tDCM, TotalList{1,iField} )
                TotalList{next,iField}   = eval(['tDCM.' TotalList{1,iField}]);
            end
        end
        TotalList{next,13}   = length(dcmList);
    end
end

%
% SaveFile                = fullfile( ROOT_MAIN, 'TotalList.mat');
% save( SaveFile, 'TotalList');
% load( SaveFile);
%

%% Modify some: remove GE m0_calibration & split ASL into PWI & M0

%% Split GE ASL into PWI & M0

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12';
Dlist                   = xASL_adm_GetFsList( ROOT, '^GE_(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iD=1:length(Dlist)
    clear Dlist2
    Dlist2              = xASL_adm_GetFsList( fullfile( ROOT, Dlist{iD}), '^GENFI_asl.*$',1);

    for iD2=1:length(Dlist2) % if there are multiple ASL scans
        clear ASL_dir M0_dir dcmList

        ASL_dir     = fullfile( ROOT, Dlist{iD}, Dlist2{iD2});
        if  isdir( ASL_dir )
            dcmList         = xASL_adm_GetFileList( ASL_dir , '^.*\.dcm$','FPList');
            if  length(dcmList)==72
    %             error('piet');

                M0_dir      = fullfile( ROOT, Dlist{iD}, ['GENFI_m0' Dlist2{iD2}(10:end)]);
                xASL_adm_CreateDir(M0_dir);

%                 for iDcm=[1:30  34 45 56    67    71    72] % ASL scans
                for iDcm=[31:33 35:44 46:55 57:66 68:70]    % M0  scans
                    % Because of non-leading zero, this sorting is different
                    % for numbers 5-9
                    clear path file ext
                    [path file ext]     = fileparts( dcmList{iDcm} );
                    xASL_Move( dcmList{iDcm}, fullfile(M0_dir, [file ext]) );
                end
            end
        end
    end
end

%% Rename Siemens_Trio_NSA5

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12\raw';
Dlist                   = xASL_adm_GetFsList( ROOT, '^SI_Trio_(C9ORF|GRN|MAPT)\d{3}_\d$',1);
CheckTable              = '';
for iD=1:length(Dlist)
    Dlist2              = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}), '^.*$',1);
    for iD2=1:length(Dlist2)
        if  strcmp(Dlist2{iD2},'GENFI_asl_tag_6')
            clear dcmList tDCM
            dcmList         = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iD}, Dlist2{iD2}), '^.*\.dcm$','FPList');
            tDCM            = dicominfo( dcmList{1} );
            CheckTable{end+1,1}= tDCM.RepetitionTime;
            CheckTable{end,2}= Dlist2{iD2+1};
            CheckTable{end,3}= Dlist2{iD2+2};
            CheckTable{end,4}= Dlist2{iD2+3};
        end
    end
end
% all are TI=2250 & none of them have a m0_ti2000 folder

% Rename directory into m0
for iD=1:length(Dlist)
    Dlist2              = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}), '^.*$',1);
    for iD2=1:length(Dlist2)
        if  strcmp(Dlist2{iD2},'GENFI_asl_tag_6')
            clear OldDir NewDir

            OldDir      = fullfile(ROOT, Dlist{iD}, Dlist2{iD2});
            NewDir      = fullfile(ROOT, Dlist{iD}, 'GENFI_m0_ti2000');

            xASL_Move( OldDir, NewDir);
        end
    end
end

% Rename directory into NSA_5
for iD=1:length(Dlist)
    Dlist2              = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}), '^.*$',1);
    for iD2=1:length(Dlist2)
        if  strcmp(Dlist2{iD2},'GENFI_asl_tag_5')

            clear OldDir NewDir

            NewDir      = fullfile(ROOT, [Dlist{iD}(1:8) 'NSA5_' Dlist{iD}(9:end)]);
            OldDir      = fullfile(ROOT, Dlist{iD});

            xASL_Move( OldDir, NewDir);
        end
    end
end

%% Concatenate SI_Trio_NSA_5 scans

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12\analysis';
Dlist                   = xASL_adm_GetFsList( ROOT, '^SI_Trio_NSA5_(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iD=2:length(Dlist)
    % Load all niftis
    clear IM parms
    for iN=1:10
        clear Fname tnii
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D.nii');
        tnii            = xASL_nifti(Fname);
        IM(:,:,:,iN)    = tnii.dat(:,:,:);
    end

    xASL_io_SaveNifti( fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), IM, 10);

    % compare TE & TR
    Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D_parms.mat');
    load(Fname);
    TRcheck     = parms.RepetitionTime;
    TEcheck     = parms.EchoTime;
    for iN=2:10
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D_parms.mat');
        load(Fname);
        if  parms.RepetitionTime~=TRcheck || parms.EchoTime~=TEcheck
            error('incompat');
        end
    end
end


%% Rename Siemens GENFI_asl_tag_2 into m0_2000

%% Rename Siemens_Trio_NSA5

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12\raw';
Dlist                   = xASL_adm_GetFsList( ROOT, '^SI_Trio_(C9ORF|GRN|MAPT)\d{3}_\d$',1);
CheckTable              = '';
for iD=1:length(Dlist)
    Dlist2              = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}), '^.*$',1);
    for iD2=1:length(Dlist2)
        if  strcmp(Dlist2{iD2},'GENFI_asl_tag_2')
            clear dcmList tDCM
            dcmList         = xASL_adm_GetFileList( fullfile(ROOT, Dlist{iD}, Dlist2{iD2}), '^.*\.dcm$','FPList');
            tDCM            = dicominfo( dcmList{1} );
            CheckTable{end+1,1}= tDCM.RepetitionTime;
            CheckTable{end,2}= Dlist2{iD2+1};
            CheckTable{end,3}= Dlist2{iD2+2};
            CheckTable{end,4}= Dlist2{iD2+3};
        end
    end
end
% all are TI=2250 & none of them have a m0_ti2000 folder

% Rename directory into m0
for iD=1:length(Dlist)
    Dlist2              = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}), '^.*$',1);
    for iD2=1:length(Dlist2)
        if  strcmp(Dlist2{iD2},'GENFI_asl_tag_2')
            clear OldDir NewDir

            OldDir      = fullfile(ROOT, Dlist{iD}, Dlist2{iD2});
            NewDir      = fullfile(ROOT, Dlist{iD}, 'GENFI_m0_ti2000');

            xASL_Move( OldDir, NewDir);
        end
    end
end


%% Concatenate SI_Trio_NSA_1 scans

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12\analysis';
Dlist                   = xASL_adm_GetFsList( ROOT, '^SI_Trio_(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iD=3:length(Dlist)
    % Load all niftis
    clear IM parms
    if isdir( fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)]) )
        for iN=1:2
            clear Fname tnii
            Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D.nii');
            tnii            = xASL_nifti(Fname);
            IM(:,:,:,iN)    = tnii.dat(:,:,:);
        end

        xASL_io_SaveNifti( fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), IM, 10);

        % compare TE & TR
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D_parms.mat');
        load(Fname);
        TRcheck     = parms.RepetitionTime;
        TEcheck     = parms.EchoTime;
        for iN=2
            Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D_parms.mat');
            load(Fname);
            if  parms.RepetitionTime~=TRcheck || parms.EchoTime~=TEcheck
                error('incompat');
            end
        end
    end
end

%% Concatenate SI_Prisma_NSA_5 scans

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12\analysis';
Dlist                   = xASL_adm_GetFsList( ROOT, '^SI_Prisma_(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iD=2:length(Dlist)
    % Load all niftis
    clear IM parms
    for iN=1:10
        clear Fname tnii
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D.nii');
        tnii            = xASL_nifti(Fname);
        IM(:,:,:,iN)    = tnii.dat(:,:,:);
    end

    xASL_io_SaveNifti( fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), IM, 10);

    % compare TE & TR
    Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D_parms.mat');
    load(Fname);
    TRcheck     = parms.RepetitionTime;
    TEcheck     = parms.EchoTime;
    for iN=2:10
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D_parms.mat');
        load(Fname);
        if  parms.RepetitionTime~=TRcheck || parms.EchoTime~=TEcheck
            error('incompat');
        end
    end
end

%% Concatenate SI_Skyra_NSA_2 scans

ROOT                    = 'C:\GENFI_DF2\GENFI_DF12\analysis';
Dlist                   = xASL_adm_GetFsList( ROOT, '^SI_Skyra_(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iD=2:length(Dlist)
    SessionList         = xASL_adm_GetFsList( fullfile(ROOT, Dlist{iD}), '^ASL_\d$',1);

    % Load all niftis
    clear IM parms
    for iN=1:length(SessionList)
        clear Fname tnii
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D.nii');
        tnii            = xASL_nifti(Fname);
        IM(:,:,:,iN)    = tnii.dat(:,:,:);
    end

    xASL_io_SaveNifti( fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D.nii'), IM, 10);

    % compare TE & TR
    Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(1)],'ASL4D_parms.mat');
    load(Fname);
    TRcheck     = parms.RepetitionTime;
    TEcheck     = parms.EchoTime;
    for iN=2
        Fname           = fullfile( ROOT, Dlist{iD}, ['ASL_' num2str(iN)],'ASL4D_parms.mat');
        load(Fname);
        if  parms.RepetitionTime~=TRcheck || parms.EchoTime~=TEcheck
            error('incompat');
        end
    end
end


%% Check discrepancy excel-list & imported datalist for baseline (_1)
load( fullfile('C:\GENFI_DF2\rawData.mat') );
XcelList        = unique(rawData(2:end,2));

load( fullfile('C:\GENFI_DF2\TotalList.mat') );
SubjList        = unique(TotalList(2:end,1));
NFoundList      = '';

for iS=1:length(XcelList)

    FoundS=0;
    for iSub=1:length(SubjList)
        if  strcmp( XcelList{iS,1}, SubjList{iSub,1} )
            FoundS=1;
        end
    end

    if  ~FoundS
        NFoundList{end+1}   = XcelList{iS,1};
    end
end

NFoundList  = NFoundList';



%% Check discrepancy imported datalist & actual folders HD for baseline (_1)
load( fullfile('C:\GENFI_DF2\TotalList.mat') );
SubjList        = unique(TotalList(2:end,1));
NFoundList      = '';

% Create folder-list of baseline
ROOT{1}         = 'C:\GENFI_DF2\GENFI_DF12\analysis';
ROOT{2}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\GE HDxt';
ROOT{3}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\SI Aera';
ROOT{4}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\SI Avanto';
ROOT{5}         = 'C:\GENFI_DF2\Exclude\T1ArtifactsNoASL';

clear FList
FList           = '';
next    = 1;

for R=1:5
    clear tList
    tList       = xASL_adm_GetFsList( ROOT{R}, '^.*(C9ORF|GRN|MAPT)\d{3}_1$',1);
    for iF=1:length(tList)
        FList{next}     = tList{iF};
        next            = next+1;
    end
end

% Create folder-list of follow-up session 2
ROOT{1}         = 'C:\GENFI_DF2\GENFI_DF12\analysis';
ROOT{2}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\GE HDxt';
ROOT{3}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\SI Aera';
ROOT{4}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\SI Avanto';
ROOT{5}         = 'C:\GENFI_DF2\Exclude\T1ArtifactsNoASL';

clear FList
FList           = '';
next    = 1;

for R=1:5
    clear tList
    tList       = xASL_adm_GetFsList( ROOT{R}, '^.*(C9ORF|GRN|MAPT)\d{3}_2$',1);
    for iF=1:length(tList)
        FList{next}     = tList{iF};
        next            = next+1;
    end
end

length(FList)

% Create folder-list of follow-up session 3
ROOT{1}         = 'C:\GENFI_DF2\GENFI_DF12\analysis';
ROOT{2}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\GE HDxt';
ROOT{3}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\SI Aera';
ROOT{4}         = 'C:\GENFI_DF2\Exclude\1.5T,noASL\SI Avanto';
ROOT{5}         = 'C:\GENFI_DF2\Exclude\T1ArtifactsNoASL';

clear FList
FList           = '';
next    = 1;
for R=1:5
    clear tList
    tList       = xASL_adm_GetFsList( ROOT{R}, '^.*(C9ORF|GRN|MAPT)\d{3}_3$',1);
    for iF=1:length(tList)
        FList{next}     = tList{iF};
        next            = next+1;
    end
end

length(FList)

%% Compare with downloadable datasets as shown on the website
[data, text, rawData]   = xlsread( 'C:\GENFI_DF2\bmacintosh_3_15_2016_21_39_55.csv','bmacintosh_3_15_2016_21_39_55');
clear XcelList XcelList1 XcelList2 XcelList3 XcelList0
next                    = [1 1 1 1];
for iS=2:length(rawData)
    if      rawData{iS,5}==3
            XcelList1{next(1)}  = rawData{iS,1};
            XcelList2{next(2)}  = rawData{iS,1};
            XcelList3{next(3)}  = rawData{iS,1};
            next                = next + [1 1 1 0];
    elseif  rawData{iS,5}==2
            XcelList1{next(1)}  = rawData{iS,1};
            XcelList2{next(2)}  = rawData{iS,1};
            next                = next + [1 1 0 0];
    elseif  rawData{iS,5}==1
            XcelList1{next(1)}  = rawData{iS,1};
            next                = next + [1 0 0 0];
    else    XcelList0{next(4)}  = rawData{iS,1};
            next                = next + [0 0 0 1];
    end
end

% 350 first sessions
% 142 second
% 18 third

%% Find missing ones in third session (using FList generated by f/u session 3 above)
NonFoundList    = '';

for iS=1:length(XcelList3)
    FoundN=0;
    for iSub=1:length(FList)
        if ~isempty(findstr(XcelList3{iS},FList{iSub}))
            FoundN=1;
        end
    end
    if ~FoundN
        NonFoundList{end+1,1}   = XcelList3{iS};
    end
end

%% Find missing ones in second session (using FList generated by f/u session 2 above)
NonFoundList    = '';

for iS=1:length(XcelList2)
    FoundN=0;
    for iSub=1:length(FList)
        if ~isempty(findstr(XcelList2{iS},FList{iSub}))
            FoundN=1;
        end
    end
    if ~FoundN
        NonFoundList{end+1,1}   = XcelList2{iS};
    end
end

%% Find missing ones in first session (using FList generated by f/u session 1 above)
NonFoundList    = '';

for iS=1:length(XcelList1)
    FoundN=0;
    for iSub=1:length(FList)
        if ~isempty(findstr(XcelList1{iS},FList{iSub}))
            FoundN=1;
        end
    end
    if ~FoundN
        NonFoundList{end+1,1}   = XcelList1{iS};
    end
end

%% Remove redundant files
ROOT    = 'C:\GENFI_DF2\GENFI_DF12\analysis';
Dlist   = xASL_adm_GetFsList(ROOT, '^.*(C9ORF|GRN|MAPT)\d{3}_\d$',1);

for iD=1:length(Dlist)

    Fname   = fullfile( ROOT, Dlist{iD}, 'ASL_1', 't1.nii');
    if  exist(Fname,'file')
        delete(Fname);
    end

    Fname   = fullfile( ROOT, Dlist{iD}, 'ASL_1', 't1_parms.mat');
    if  exist(Fname,'file')
        delete(Fname);
    end

end
