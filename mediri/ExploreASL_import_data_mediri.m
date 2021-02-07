%% Modified Dicom Import Tool

% Last modification:    m.stritt, 29/11/2018

function ExploreASL_import_data_mediri(rootPath)
%% Initialize Explore ASL
symbols = InitializeExploreASL_mediri(rootPath);

%% Initialize Structure
mypath      = symbols.MYPATH;

% Select Root Folder
%raw_root = uigetdir([],'Select Root Folder');  % raw_root   	= 'C:\Users\Michael\Desktop\example_asl\';
raw_root = symbols.import_rootFolder;
analysis_root = raw_root;                       % analysis_root	= 'C:\Users\Michael\Desktop\example_asl\';
% Select Study Folder
studyID = symbols.import_studyID;

% Create Folders
raw_root = char(fullfile(raw_root,studyID));    % raw_root = fullfile(raw_root,studyID,'raw');
analysis_root = fullfile(analysis_root,studyID);% analysis_root = fullfile(analysis_root,studyID,'analysis');
xASL_adm_CreateDir(analysis_root);

% Study Defaults
bMatchDirectories   = false;
bVerbose            = true;
bOverwrite          = false;
folderHierarchy     = {};
tokenOrdering       = [];
tokenSessionAliases = [];
tokenScanAliases    = [];
sessionNames        = {};
nMaxSessions        = 0;
bUseSessionIndexing = false;
dcm2nii_version     = '20130606';
dcmExtFilter        = '^(.*\.dcm|.*\.img|.*\.IMA|[^.]+)$';

%% Initialize dicom dictionary by appending private philips stuff to a temporary copy
olddict = dicomdict('get');
dicomdict('set', fullfile(mypath,'External','xASL_DICOMLibrary.txt'));

%% put bulk of the script in a catch because we have to restore the dicom dictionary
fid_summary = -1;
try
    % Get information from symbols struct
    folderHierarchy = symbols.import_Parameters.folderHierarchy;
    tokenOrdering = symbols.import_Parameters.tokenOrdering;
    tokenScanAliases = symbols.import_Parameters.tokenScanAliases;
    tokenSessionAliases = symbols.import_Parameters.tokenSessionAliases;
    bMatchDirectories = symbols.import_Parameters.bMatchDirectories;

    %% change dcmnii_version for PARREC if needed
    if  ~isempty(findstr(char(folderHierarchy(end)),'PAR'))
        dcm2nii_version = '20101105';
    end

    %% redirect output to a log file
    diary_filepath = fullfile(analysis_root, ['import_log_' studyID '_' datestr(now,'yyyymmdd_HHMMSS') '.txt']);
    diary(diary_filepath);

    %%
    if bMatchDirectories
        strLookFor = 'Directories';
    else
        strLookFor = 'Files';
    end

    %% Start with determining the subjects, sessions and scans by listing or typing.

    % Recursively scan the directory tree using regular exspressions at
    % each directory level. Use ()-brackets to extract tokens
    % that will be used to identify subjects, sessions and scans. In the
    % loop below it is possible to translate the tokens
    % to more convenient strings before using them in destination paths.
    [matches, tokens] = xASL_adm_FindByRegExp(raw_root, folderHierarchy, 'StripRoot', true, 'Match', strLookFor);
    if isempty(matches)
        error('Error: no matching files');
    else
        fprintf('\nMatching files:\n');
        disp(matches);
        fprintf('#=%g\n',length(matches));
    end

    % Copy the columns into named vectors. This construction allows for
    % arbitrary directory hierarchies. Make sure to select the columns that
    % correspond to the folder ordering defined using the regular expressions above.
    % cell vector with extracted subject IDs (for all sessions and scans):
    vSubjectIDs = tokens(:,tokenOrdering(1));
    if tokenOrdering(2)==0
        % a zero means: no sessions applicable
        bUseSessions = false;
        vSessionIDs = cellfun(@(x) '1', vSubjectIDs, 'UniformOutput', false);
        tokenSessionAliases = { '^1$', 'ASL_1' };
    elseif tokenOrdering(2)<0
        bUseSessions = true;
        % ignore the actual session name (i.e. date); use index to get name from token aliasses:
        bUseSessionIndexing = true;
        % cell vector with extracted session IDs (for all subjects and scans):
        vSessionIDs = tokens(:,-tokenOrdering(2));
    else
        bUseSessions = true;
        % cell vector with extracted session IDs (for all subjects and scans):
        vSessionIDs = tokens(:,tokenOrdering(2));
    end
    % cell vector with extracted scan IDs (for all subjects and sessions):
    vScanIDs    = tokens(:,tokenOrdering(3));

    % convert the vectors to unique (and sorted) sets
    subjectIDs  = sort(unique(vSubjectIDs));
    nSubjectIDs = length(subjectIDs);

    if bUseSessionIndexing
        sessionIDs  = {}; % check session tokens for each subject (i.e. a scan date)
        nSessionIDs = nMaxSessions;
    else
        sessionIDs  = sort(unique(vSessionIDs));
        nSessionIDs = length(sessionIDs);
    end

    scanIDs    = sort(unique(vScanIDs));
    nScanIDs   = length(scanIDs);

    % optionaly we can have human readble session names; by default they
    % are the same as the original tokens in the path.
    if isempty(sessionNames)
        if isempty(sessionIDs)
            sessionNames = cell(nSessionIDs,1);
            for kk=1:nSessionIDs
                sessionNames{kk}=sprintf('ASL_%g',kk);
            end
        else
            sessionNames = sessionIDs;
        end
    end
    scanNames = scanIDs;

    % sanity check for missing elements
    if nSubjectIDs==0
        error('No subjects')
    end
    if nSessionIDs==0
        error('No sessions')
    end
    if nScanIDs==0
        error('No scans')
    end

    % preallocate space for (global) counts
    converted_scans = zeros(nSubjectIDs,nSessionIDs,nScanIDs,'uint8');  % keep a count of all individual scans
    skipped_scans = zeros(nSubjectIDs,nSessionIDs,nScanIDs,'uint8');    % keep a count of all individual scans
    missing_scans = zeros(nSubjectIDs,nSessionIDs,nScanIDs,'uint8');    % keep a count of all individual scans

    %% define a cell array for storing info for parameter summary file
    xASL_adm_CreateDir(analysis_root);
    summary_lines = cell(nSubjectIDs,nSessionIDs,nScanIDs);

    %% import subject by subject, session by session, scan by scan
    separatorline = repmat(char('+'),1,80);
    for iSubjectID=1:nSubjectIDs
        % display subject ID
        subjectID = subjectIDs{iSubjectID};
        fprintf('%s\nstarting import of Subject=%s\n',separatorline,subjectID);

        % check if we use predefined sessions IDs, or arbitrary scan dates (or another random session naming)
        if bUseSessionIndexing
            sessionIDs = vSessionIDs(strcmp(vSubjectIDs,subjectID));
            nSessionIDs = length(sessionIDs);
        end

        % loop through all sessions
        for iSessionID=1:nSessionIDs
            sessionID = sessionIDs{iSessionID};

            % convert session ID to a suitable name
            if size(tokenSessionAliases,2)==2
                iAlias = find(~cellfun(@isempty,regexp(sessionID,tokenSessionAliases(:,1),'once')));
                if ~isempty(iAlias)
                    sessionNames{iSessionID} = tokenSessionAliases{iAlias,2};
                end
            end
            session_name = sessionNames{iSessionID};

            for iScanID=1:nScanIDs
                scanID = scanIDs{iScanID};
                summary_line = [];
                first_match = [];

                % convert scan ID to a suitable name and set scan-specific parameters
                if size(tokenScanAliases,2)==2
                    iAlias = find(~cellfun(@isempty,regexp(scanID,tokenScanAliases(:,1),'once')));
                    if ~isempty(iAlias)
                        scanNames{iScanID} = tokenScanAliases{iAlias,2};
                    end
                end
                scan_name = scanNames{iScanID};

                % minimalistic feedback of where we are
                fprintf('>>> Subject=%s, session=%s, scan=%s\n',subjectID,session_name,scan_name);

                %
                switch scan_name
                    case { 'ASL4D', 'M0' }
                        bOneScanIsEnough = ~bUseSessions;
                        bPutInSessionFolder = true;
                    case { 'T1', 'WMH_SEGM', 'FLAIR' }
                        bOneScanIsEnough = true;
                        bPutInSessionFolder = false;
                    otherwise
                        bOneScanIsEnough = ~bUseSessions;
                        bPutInSessionFolder = true;
                end

                % now pick the matching one from the folder list
                iMatch = find(strcmp(vSubjectIDs,subjectID) & strcmp(vScanIDs,scanID) & strcmp(vSessionIDs,sessionID)); % only get the matching session
                if isempty(iMatch)
                    % only report as missing if we need a scan for each session (i.e. ASL)
                    if ~bOneScanIsEnough || sum(converted_scans(iSubjectID,:,iScanID))==0
                        fprintf(2,'Missing scan: %s, %s, %s\n',subjectID,session_name,scan_name);
                        missing_scans(iSubjectID,iSessionID,iScanID) = 1;
                    end
                else
                    % determnine input and output paths
                    bSkipThisOne = false;
                    branch = matches{iMatch};
                    scanpath = fullfile(raw_root,branch);
                    if bPutInSessionFolder
                        destdir = fullfile(analysis_root,subjectID,session_name);
                    else
                        % put in subject folder instead of session folder
                        destdir = fullfile(analysis_root,subjectID);
                    end
                    if bOneScanIsEnough && sum(converted_scans(iSubjectID,:,iScanID))~=0
                        % one (T1) scan is enough, so skip this one if there was already a scan converted of this type (i.e. T1)
                        fprintf('Skipping scan: %s, %s, %s\n',subjectID,session_name,scan_name);
                        bSkipThisOne = true;
                        destdir = []; % just in case
                    end

                    % start the conversion if this scan should not be skipped
                    if bSkipThisOne
                        summary_line = sprintf(',"skipped",,,,,,,,');
                        skipped_scans(iSubjectID,iSessionID,iScanID) = 1;
                    else
                        nii_files = {};
                        xASL_adm_CreateDir(destdir);

                        % check if we have a nii(gz) file, or something that needs to be converted (parrec/dicom)
                        if ~isdir(scanpath) && ~isempty(regexpi(scanpath,'(\.nii|\.nii\.gz)$'))
                            % check if output exists
                            first_match = fullfile(destdir, [scan_name '.nii']);
                            if bOverwrite || ~exist(first_match,'file')
                                [fpath, fname, fext] = fileparts(scanpath);
                                destfile = fullfile(destdir, [fname fext]); % will be renamed later
                                xASL_Copy(scanpath, destfile, bOverwrite)
                                % gunzip if required
%                                if strcmpi(fext,'.gz')
%                                    gunzip(destfile);
%                                    delete(destfile);
%                                    destfile = fullfile(destdir, fname); % fname includes .nii
%                                end
				destfile = xASL_adm_UnzipNifti(destfile);
                                % rename to our requirements (T1, ASL4D, ...)
                                xASL_Move(destfile, first_match, bOverwrite, bVerbose);
                            end
                            nii_files{1} = first_match;
                        else
                            % start the conversion. Note that the dicom filter is only in effect when a directory is specified as input.
                            % 								if  strcmp(dcmwildcard, '*.')
                            % 									dcmExtFilter = '^[^.]+$';  % assume that we should match filename without extension
                            % 								else
                            % 									dcmExtFilter = ['^' regexptranslate('wildcard', dcmwildcard) '$'];
                            % 								end
                            try
                                [nii_files, first_match] = dcm2nii(scanpath, destdir, scan_name, 'DicomFilter', dcmExtFilter, 'Verbose', bVerbose, 'Overwrite', bOverwrite, 'Version', dcm2nii_version);
                            catch
                                disp([scanpath ' crashed, dcm2nii skipping, but still trying to get the parms only']);
                                first_match     = xASL_adm_GetFileList(scanpath, ['.*' dcmExtFilter],'FPList',[0 Inf]);
                                if  ~isempty(first_match); first_match     = first_match{1}; end
                            end
                        end

                        % check the number of created nifiti files in case of ASL: label and control should be merged as one 4D
                        if length(nii_files)==2 && strcmp(scan_name,'ASL4D')
                            nii_files = merge_2_ASL_nii_files(nii_files, scan_name);
                        elseif length(nii_files)==0
                            warning(['Skipping because of absent files']);
                        elseif length(nii_files)~=1
                            warning('Incorrect number of nifti files for %s: %d', scan_name, length(nii_files));
                            % Changed this error in a warning to continue the import script
                            tNII            = nii_files{1};
                            nii_files{1}    = tNII;
                        else
                            tNII            = nii_files{1};
                            nii_files{1}    = tNII;
                        end

                        % Extract relevant parameters from nifti header and append to summary file
                        summary_line = AppendNiftiParameters(nii_files);
                        converted_scans(iSubjectID,iSessionID,iScanID) = 1;
                    end

                    % extract relevant parameters from dicom header
                    if ~isempty(first_match)
                        [fpath, fname, fext] = fileparts(first_match);
                        if  strcmpi(fext,'.PAR')
                            parms = xASL_adm_Par2Parms(first_match, fullfile(destdir, [scan_name '_parms.mat']), bOverwrite);
                        elseif strcmpi(fext,'.nii')
                            parms = [];
                        elseif bMatchDirectories
                            [Fpath Ffile Fext]  = fileparts(first_match);
                            parms = dicom2parms_mediri(Fpath, fullfile(destdir, [scan_name '_parms.mat']), bOverwrite, dcmExtFilter);
                            clear Fpath Ffile Fext
                        else
                            [parms,~] = xASL_adm_Dicom2parms(first_match, fullfile(destdir, [scan_name '_parms.mat']), dcmExtFilter,0,[]);
                        end
                    end

                    % correct nifti rescale slope if parms.RescaleSlopeOriginal =~1
                    % but nii.dat.scl_slope==1 (this can happen in case of
                    % hidden scale slopes in private Philips header,
                    % that is delt with by dicom2parms but not by
                    % dcm2nii

                    if  length(nii_files)>0
                        summary_line = [summary_line AppendParmsParameters(parms)]; %#ok<AGROW>
                    end

                end

                %% store the summary info so it can be sorted and printed below
                summary_lines{iSubjectID,iSessionID,iScanID} = summary_line;
            end % scansIDs
        end % sessionIDs
    end % subjectIDs

    % create summary file
    summary_filepath = fullfile(analysis_root, 'import_summary.csv');
    fid_summary = fopen(summary_filepath,'wt');
    fprintf(fid_summary,'subject,session,scan,filename,dx,dy,dz,dt,nx,ny,nz,nt,TR,TE,nt,RescaleSlope,RescaleSlopeOriginal,MRScaleSlope,RescaleIntercept,ScanTime\n');
    for iScanID=1:nScanIDs
        for iSubjectID=1:nSubjectIDs
            for iSessionID=1:nSessionIDs
                if converted_scans(iSubjectID,iSessionID,iScanID) || skipped_scans(iSubjectID,iSessionID,iScanID) || missing_scans(iSubjectID,iSessionID,iScanID)
                    fprintf(fid_summary,'"%s","%s","%s"%s\n',subjectIDs{iSubjectID},sessionNames{iSessionID},scanNames{iScanID},summary_lines{iSubjectID,iSessionID,iScanID});
                    % @Paul, deleted comma before last %s because summary_lines appended comma before each term already
                else
                    % just ignore scans type that were not required (i.e. only required in one session)
                end
            end
        end
    end
    fprintf(fid_summary,'\n');

    % report totals
    % header first
    fprintf(fid_summary,'\n');
    fprintf(fid_summary,'"Subject"');
    fprintf(fid_summary,',"%s-#converted"',sessionNames{:});
    fprintf(fid_summary,',"%s-missing"',sessionNames{:});
    fprintf(fid_summary,',"%s-skipped"',sessionNames{:});
    fprintf(fid_summary,'\n');
    % then subjects row-by-row
    for iSubjectID=1:nSubjectIDs
        fprintf(fid_summary,'"%s"', subjectIDs{iSubjectID});
        fprintf(fid_summary,',%d',sum(converted_scans(iSubjectID,:,:)));
        %        fprintf(fid_summary,',%d',sum(missing_scans(iSubjectID,:,:)));

        for iSessionID=1:nSessionIDs
            fprintf(fid_summary,',"');
            fprintf(fid_summary,'%s ',scanNames{logical(missing_scans(iSubjectID,iSessionID,:))});
            fprintf(fid_summary,'"');
        end

        %       fprintf(fid_summary,',%d',sum(skipped_scans(iSubjectID,:,:)));
        for iSessionID=1:nSessionIDs
            fprintf(fid_summary,',"');
            fprintf(fid_summary,'%s ',scanNames{logical(skipped_scans(iSubjectID,iSessionID,:))});
            fprintf(fid_summary,'"');
        end

        fprintf(fid_summary,'\n');
    end

    % and a grand total of missing and skipped
    nMissing = sum(missing_scans(:));
    if nMissing>0
        fprintf(2,'Number of missing scans: %d\n',nMissing);
    end
    nSkipped = sum(skipped_scans(:));
    if nSkipped>0
        fprintf(2,'Number of skipped scans: %d\n',nSkipped);
    end

    fclose(fid_summary); % TODO: sort file by scan type?
catch ME
    if fid_summary~=-1
        fclose(fid_summary);
    end
    dicomdict('factory');
    diary('off');
    rethrow(ME);
end

% open summary file in excel
fprintf('Created summary file: %s\n',summary_filepath);
%choice = questdlg('Would you like to open the summary file?', 'Open summary?', 'Yes','No thank you','No thank you');
choice = 'No';
if strcmp(choice,'Yes')
    if ispc()
        winopen(summary_filepath);
    else
        open(summary_filepath); % this will start the import dialog, which also gives a good view on the data
    end
end

%% Cleanup
dicomdict('factory');
diary('off');
end

%% Additional Functions
function s = AppendNiftiParameters(nii_files)
s = [];

if ischar(nii_files)
    nii_files = {nii_files};
end

for iNii=1:length(nii_files)
    [dummy, f, x] = fileparts(nii_files{iNii});
    s = sprintf(',"%s"', [f x]);

    tempnii = niftiXASL(nii_files{iNii});
    s = [s sprintf(',%g', tempnii.hdr.pixdim(2:5) )];
    s = [s sprintf(',%g', tempnii.hdr.dim(2:5) )];
end
end

function s = AppendParmsParameters(parms)
s = [];
if ~isempty(parms)
    fnames = fieldnames(parms);
    for ii=1:length(fnames)
        fname = fnames{ii};
        s = [s sprintf(',%g', parms.(fname))];
    end
end
end

function nii_files = merge_2_ASL_nii_files(nii_files, basename)
% merge_2_ASL_nii_files
% CAVE: deletes original files

if length(nii_files)==2
    % get the names of the two potential output files
    name_x1 = nii_files{1};
    name_x2 = nii_files{2};
    [outpath, dummy, ext] = fileparts(name_x1);
    newfilepath = fullfile(outpath, [basename ext]);

    if  exist(name_x1, 'file') && exist(name_x2, 'file')

        %load data
        temp_x1                         = niftiXASL(name_x1);
        temp_x2                         = niftiXASL(name_x2);

        if  max(size(temp_x1.dat(:,:,:))~=size(temp_x2.dat(:,:,:)))
            warning('Files differ in dimensions, importing skipped');
        else
            if  size(temp_x1.dat(:,:,:,:),4)~=size(temp_x2.dat(:,:,:,:),4)
                disp('Files had different size 4th dimension, check this!!!');
            end

            dim     = size(temp_x1.dat);
            dim(4)  = dim(4)*2;
            D = zeros(dim);

            for ii=1:size(temp_x1.dat,4)
                D(:,:,:,(ii*2)-1) = temp_x1.dat(:,:,:,ii);
                if  ii<=size(temp_x2.dat,4)
                    D(:,:,:,(ii*2)-0) = temp_x2.dat(:,:,:,ii);
                end
            end

            save_nii_spm( name_x1, newfilepath, D);

            delete(name_x1, name_x2);
            nii_files = {newfilepath};
        end
    end
end

end
