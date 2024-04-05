function [symbols, S] = InitializeExploreASL(rootPath)
%InitializeExploreASL This initiates all administration
% required for the pipeline to function
% including loading dataset, checking stuff
% starting additional toolboxes etc.


%% Load with or without dataset
% Construct a questdlg with three options
S.Dummy 	= '';
symbols.InitChoice = 'Load dataset';

% ------------ modification - m.stritt ------------

% Get root directory
rootDir = dir(char(rootPath));

% Extract import file
for n=1:length(rootDir)
    if rootDir(n).isdir
        studyID = rootDir(n).name;
    end
end

% Get study directory
studyDir = dir(char(fullfile(rootPath,studyID)));

% Extract import file
for n=1:length(studyDir)
    if (contains(studyDir(n).name,'.m'))
        importFile = studyDir(n).name;
    end
end

% Define study path
studyPath = fullfile(rootPath, studyID);

% Define import file path
importpath = fullfile(studyPath,importFile);

% Give the information to the symbols struct
symbols.import_DataParFile = importpath;
symbols.import_rootFolder = rootPath;
symbols.import_studyID = studyID;

% Extract information from the import file
importtext = fileread(importpath);
importtext = splitlines(importtext);

% Evaluate all command manually
m=1;
for n=1:length(importtext)
    if ~isempty(importtext{n,1})
        import_info{m,1}=importtext{n,1};
        m = m+1;
    end
end
clear m n

% Write import_info to structs
for n=1:length(import_info)
    % Execute command
    if ~isempty(import_info{n,1})
        disp(import_info{n,1});
        eval(import_info{n,1});
    end
end
clear cur_name n

DataParFile = symbols.import_DataParFile;
symbols.InitChoice = symbols.InitChoice;
[symbols.ROOT,~,~] = fileparts(DataParFile);

% -------------- end of modification --------------

%% Get ExploreASL path

% Check if the current directory is the ExploreASL directory
CurrCD  = cd;
if  exist(fullfile(CurrCD,'ExploreASL_master.m'))
    MYPATH2  = CurrCD;
end

% Check whether MYPATH is correct, otherwise obtain correct folder
if ~isfield(symbols,'MYPATH')
    symbols.MYPATH  = '/DummyPath';
end

if  exist('MYPATH2','var')
    symbols.MYPATH  = MYPATH2;
end

MasterScriptPath    = fullfile(symbols.MYPATH,'ExploreASL_master.m');


if ~exist(MasterScriptPath,'file')
    %pathstr         = uigetdir(CurrCD,'Select folder where ExploreASL is installed');
    pathstr = symbols.import_asl; % Modification m.stritt
    if  sum(pathstr==0) || ~exist(fullfile(pathstr,'ExploreASL_master.m'),'file')
        return
    end
    symbols.MYPATH  = pathstr;
end

% Go to ExploreASL folder
cd(symbols.MYPATH);


%% Initialization

symbols.stopaftererrors     = Inf;      % set to a high number (or Inf) when running a complete batch overnight
symbols.dryrun              = false;    % set to true to skip all real processing & just print all parameters

if ~exist('groot','builtin')
    % before R2012b
    set(0,'DefaultTextInterpreter','none')
else
    % R2012b+
    set(groot,'DefaultTextInterpreter','none')
end

% -------------------------------------
% Define paths
% -------------------------------------
if ~isdeployed

%     %% First remove any other SPM dirs
%     PathList        = path; % get pathlist
%     IndicesN        = find(PathList==';');
%     PathCell{1,1}   = PathList(1:IndicesN(1)-1);
%     for iN=2:IndicesN-1
%         PathCell{iN,1}  = PathList(IndicesN(iN-1)+1:IndicesN(iN)-1);
%     end
%     PathCell{iN+1}      = PathList(IndicesN(end)+1:end);
%
%     for iN=1:length(PathCell)
%         if ~isempty(strfind(PathCell{iN,1},'spm')) || ~isempty(strfind(PathCell{iN,1},'SPM'))
%             % find & remove pre-defined SPM paths from memory
%             rmpath(PathCell{iN,1});
%         end
%     end
%
%     % nN=1; % visualize SPM paths
%     % for iN=1:length(PathCell)
%     %     if ~isempty(strfind(PathCell{iN},'spm'))
%     %         SPMpaths{nN,1}    = PathCell{iN};
%     %         nN=nN+1;
%     %     end
%     % end

    addpath(symbols.MYPATH);

    subfolders_to_add = {  'Modules', ...
	   		   'mex', ...
	   		   'Functions', ...
           fullfile('External','SPMmodified','xASL'),...
   			   fullfile('External','SPMmodified'), ...
           fullfile('External','SPMmodified','toolbox','cat12'), ...
           'Custom_scripts' ...
           'External' ...
			};
    for ii=1:length(subfolders_to_add)
            addpath(fullfile(symbols.MYPATH,subfolders_to_add{ii}));
    end
end


fprintf('\n%s\n','-------------------------------');
fprintf('%s\n','Initializing ExploreASL 2019...');
fprintf('%s\n\n','-------------------------------');


%% Common settings and definitions
symbols                     = ExploreASL_directories(symbols);
symbols.OVERWRITE           = true;

symbols                     = VersionsPaths(symbols);
[symbols, S]                = vis_settings(symbols); % visual settings

if ~strcmp(symbols.InitChoice,'Load dataset')
    fprintf('%s\n','--- ExploreASL initialized ---');
else

    % If previous run exists, load settings
%     symbolsMAT      = fullfile(symbols.ROOT,'xASL.mat'); % later replace this by json (doesnt allow cells)
%     if  exist(symbolsMAT,'file')
%         load(symbolsMAT);
%     else % get sets from root folder

        symbols                     = DefineSets( symbols );
%         % NB: use NaNs for missing data
%     end

    %% Remove 'lock-dir' if present from aborted previous run, for current subjects only
    % LockDir within 2 directories (e.g. T1, FLAIR or ASL)
    LOCKDIR                     = fullfile(symbols.ROOT,'lock');
    if  isdir(LOCKDIR)
        fprintf('%s\n','Searching for locked previous ExploreASL image processing');
        LockDirFound    = 0;
        [ LockDir, optionaltokens] = xASL_adm_FindByRegExp( fullfile(symbols.ROOT,'lock'), {['(ASL|Struct|LongReg_' symbols.STRUCTPREFIX ')'],symbols.subject_regexp,'.*module.*','^(locked)$'}, 'Match','Directories');
        if  length(LockDir)>0
            for iL=1:length(LockDir)
                fprintf('%s\n',[LockDir{1} ' detected, removing']);
                rmdir(LockDir{1},'s');
            end
            LockDirFound    = 1;
        end

        % LockDir within 2 directories (e.g. DARTEL)
        [LockDir, optionaltokens] = xASL_adm_FindByRegExp( fullfile(symbols.ROOT,'lock'), {['(Population|DARTEL_' symbols.STRUCTPREFIX ')'],'.*module.*','^(locked)$'}, 'Match','Directories');
        if  length(LockDir)>0
            for iL=1:length(LockDir)
                fprintf('%s\n',[LockDir{1} ' detected, removing']);
                rmdir(LockDir{1},'s');
            end
            LockDirFound = 1;
        end

        if  LockDirFound==0
            fprintf('%s\n','No locked dirs found from previous ExploreASL image processing');
        end
    end

    %% Print settings to check
    symbols                      = module_check_settings( symbols );

    %% Pause for user to check settings
    fprintf('%s\n','Please check the settings above');

end

end
