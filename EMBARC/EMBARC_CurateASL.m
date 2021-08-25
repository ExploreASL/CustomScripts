% Move T1w to separate T1w folder
OriDir = '/home/hjmutsaerts/lood_storage/divi/Projects/ExploreASL/EMBARC/ASL';
DestDir = '/home/hjmutsaerts/lood_storage/divi/Projects/ExploreASL/EMBARC/T1w';

FileList = xASL_adm_GetFileList(OriDir, '.*MRI\.tgz');

for iFile=1:numel(FileList)
    xASL_TrackProgress(iFile, numel(FileList));
    [~, Ffile, Fext] = fileparts(FileList{iFile});
    NewPath = fullfile(DestDir, [Ffile Fext]);
    xASL_Move(FileList{iFile}, NewPath);
end

% Curate subject/visit/scantype
DestDir = '/scratch/hjmutsaerts/EMBARC/sourcedata';
OriDir = '/home/hjmutsaerts/lood_storage/divi/Projects/ExploreASL/EMBARC';
FileList = xASL_adm_GetFileList(OriDir, '.*(ASL|MRI)\.tgz', 'FPListRec');
xASL_adm_CreateDir(DestDir);

for iFile=1:numel(FileList)
    xASL_TrackProgress(iFile, numel(FileList));
    [~, Ffile, Fext] = fileparts(FileList{iFile});
    % SubjectID
    [Index1, Index2] = regexp(Ffile, '(CU|MG|TX|UM)\d{4}');
    if isempty(Index1) || isempty(Index2)
        warning(['No subjectID found for ' Ffile]);
    else
        SubjectID = Ffile(Index1:Index2);
        FullID = SubjectID;
        
        % Create subject folder
        SubjectDir = fullfile(DestDir, SubjectID);
        xASL_adm_CreateDir(SubjectDir);
        
        % SessionID
        [Index1, Index2] = regexp(Ffile, 'MR\d');
        if isempty(Index1) || isempty(Index2)
            warning(['No sessionID found for ' FullID]);
        else
            SessionID = Ffile(Index1:Index2);
            SessionNumber = xASL_str2num(SessionID(3));
            if ~isnumeric(SessionNumber)
                warning(['No session number found for ' FullID]);
            else
                SessionID = ['ses-' xASL_num2str(SessionNumber)];
                FullID = [FullID '_' SessionID];
                
                % Create session folder
                SessionDir = fullfile(SubjectDir, SessionID);
                xASL_adm_CreateDir(SessionDir);                
                
                % ScanType
                [Index1, Index2] = regexp(Ffile, '(ASL|MRI)');
                if isempty(Index1) || isempty(Index2)
                    warning(['No scantype found for ' FullID]);
                else
                    % Create scantype folder
                    ScanType = Ffile(Index1:Index2);
                    if strcmp(ScanType, 'ASL')
                        ScantypeDir = fullfile(SessionDir, 'ASL');
                        
                    elseif strcmp(ScanType, 'MRI')
                        ScantypeDir = fullfile(SessionDir, 'T1w');
                    else
                        warning(['Unknown scantype found for ' FullID]);
                    end
                    
                    FullID = [FullID '_' ScanType];
                    xASL_adm_CreateDir(ScantypeDir);
                    
                    % Extract data in folder
                    Output = gunzip(FileList{iFile}, ScantypeDir);
                    if numel(Output)~=1
                        warning(['Not 1 element could be unzipped from ' FullID]);
                    else
                        
                        TarBal = Output{1};
                        if ~exist(TarBal, 'file')
                            warning(['Tarbal missing for ' FullID]);
                        else
                            [Result1, Result2] = system(['tar -C ' ScantypeDir ' -xvf ' TarBal], '-echo');
                            if Result1~=0
                                warning(['Something went wrong unpacking tarbal for ' FullID]);
                            else
                                xASL_delete(TarBal);
                            end
                        end
                    end
                end% scantype
            end % if ~isnumeric(SessionNumber)
        end
    end % subjecttype
end
            
    


