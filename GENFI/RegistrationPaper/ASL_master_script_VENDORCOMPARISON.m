% function ASL_master_script_VENDORCOMPARISON(dataparfile)

%% master batch analysis ASL data 
% This script is used to run the ASL analysis pipeline over multi-subject dataset
%
% Requires the following toolboxes:  
%    wrapperlib                         (https://81.169.232.49/svn/toolbox/wrapper/ , currently delivered with the ASL toolbox ) 
%    SPM12                              (http://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
%    Matlab Image Processing Toolbox    (http://www.mathworks.nl/products/image/)
%    Matlab Statistical Toolbox         (http://www.mathworks.nl/products/image/)
%
%
% 2016-07-01, Paul Groot, Henk-Jan Mutsaerts
%
% $Rev:: 299                   $:  Revision of last commit
% $Author:: hjmutsaerts        $:  Author of last commit
% $Date:: 2016-10-16 20:01:49 #$:  Date of last commit


%% Scripting without pipeline
clear
x.MYPATH   = 'c:\ASL_pipeline_HJ';
AdditionalToolboxDir    = 'C:\ASL_pipeline_HJ_toolboxes'; % provide here ROOT directory of other toolboxes used by this pipeline, such as dip_image & SPM12
if ~isdeployed
    addpath(x.MYPATH);

    subfolders_to_add = { 'ANALYZE_module_scripts', 'ASL_module_scripts', fullfile('Development','dicomtools'), fullfile('Development','Filter_Scripts_JanCheck'), 'MASTER_scripts', 'spm_jobs','spmwrapperlib' };
    for ii=1:length(subfolders_to_add)
        addpath(fullfile(x.MYPATH,subfolders_to_add{ii}));
    end
end

addpath(fullfile(AdditionalToolboxDir,'DIP','common','dipimage'));

[x.SPMDIR, x.SPMVERSION] = xASL_adm_CheckSPM('FMRI',fullfile(AdditionalToolboxDir,'spm12') );
addpath( fullfile(AdditionalToolboxDir,'spm12','compat') );

if isempty(which('dip_initialise'))
    fprintf('%s\n','CAVE: Please install dip_image toolbox!!!');
else dip_initialise
end

% -----------------------------------------------------------------------------
%% Initialize
% -----------------------------------------------------------------------------

% Loop through whole dataset

MST_ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor';
FLIST       = xASL_adm_GetFileList( MST_ROOT, '^DATA_PAR\.m$', 'FPListRec');

for iL=1:length(FLIST)
    clear LockDir bAborted x dataparfile db_asl dryrun exc ext
    clear name optionaltokens pathstr stopaftererrors subfolders_to_add
    
    dataparfile = FLIST{iL};


% %% Manual scripting/debugging
% clc
% clear
% close all 
% 
% [name, pathstr] = uigetfile('*.m', 'Select the PARAMETER file');
% dataparfile = fullfile(pathstr, name);

    %% Load dataset parameter file

%     if nargin<1
%         [name, pathstr] = uigetfile('*.m', 'Select the PARAMETER file');
%         if pathstr==0
%             return
%         end
%         dataparfile = fullfile(pathstr, name);
%     end

    [pathstr, name, ext] = fileparts(dataparfile);
    cd(pathstr);
    x  = eval(name);
    cd(x.MYPATH);

    %% Initialization

    bAborted            = false;
    stopaftererrors     = Inf;      % set to a high number (or Inf) when running a complete batch overnight
    dryrun              = false;    % set to true to skip all real processing & just print all parameters

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
        addpath(x.MYPATH);

        subfolders_to_add = { 'ANALYZE_module_scripts', 'Manual_correction', fullfile('Manual_correction','GENFI'),fullfile('Manual_correction','GENFI','RegistrationPipelineComparison'), 'ASL_module_scripts', 'im_process', fullfile('im_process','cm_and_cb_utilities'), 'MASTER_scripts', 'spm_jobs','spmwrapperlib' };
        for ii=1:length(subfolders_to_add)
            addpath(fullfile(x.MYPATH,subfolders_to_add{ii}));
        end
    end

    %% Several quantification parameters (incl. backward compatibility)
    switch x.Quality
    case 0 % low quality for try-out
        x.InterpolationSetting    = 1;
    case 1 % normal quality
        x.InterpolationSetting    = 4;
    otherwise error('Wrong x.Quality defined!');
    end

    %% Common settings and definitions

    % parameter x data prefixes
    x.P.STRUCT     = 'T1';
    x.P.ASL4D      = 'ASL4D';
    x.P.CBF        = 'CBF';
    x.P.M0         = 'M0';
    x.P.FLAIR      = 'FLAIR';
    x.P.WMH_SEGM        = 'WMH_SEGM';

    x                  = ASL_directories( x );
    x.OVERWRITE        = true;

    x                  = VersionsPaths( x );

    % parameter x subjects & sessions
    x                  = DefineSets( x );

    %% Print settings to check
    module_check_settings( x );


    %% Remove 'lock-dir' if present from aborted previous run
    % LockDir within 2 directories (e.g. T1, FLAIR or ASL)
    [ LockDir, optionaltokens] = xASL_adm_FindByRegExp( x.D.ROOT, {'^lock$','.*','.*','.*','^(locked)$'}, 'Match','Directories');
    if  length(LockDir)>0
        for iL=1:length(LockDir)
            rmdir(LockDir{1})
        end
    end
    % LockDir within 2 directories (e.g. DARTEL)
    [ LockDir, optionaltokens] = xASL_adm_FindByRegExp( x.D.ROOT, {'^lock$','.*','.*','^(locked)$'}, 'Match','Directories');
    if  length(LockDir)>0
        for iL=1:length(LockDir)
            rmdir(LockDir{1})
        end
    end




    %% ASL module
    % 1    Spike removal
    % 2    Motion correction
    % 3    Registration to T1 and reslicing ASL
    % 4    Process separate M0, if exists
    % 5    Averaging & quantification
    % 6    Visual check

    if ~bAborted
        db_asl.sets.SUBJECT             = x.SUBJECTS;
        db_asl.sets.SESSION             = x.SESSIONS;
        db_asl.x                  = x;
        db_asl.x.SUBJECTDIR       = '<ROOT>/<SUBJECT>';
        db_asl.x.SESSIONDIR       = '<ROOT>/<SUBJECT>/<SESSION>';
        db_asl.x.LOCKDIR          = '<ROOT>/lock/ASL/<SUBJECT>';
        db_asl.x.RERUN            = false;
        db_asl.x.MUTEXID          = 'ASL_module_<SESSION>';
        db_asl.dryrun                   = dryrun; % set to true to skip the actual execution of job functions; the logfile will be created though!
        db_asl.stopaftererrors          = stopaftererrors; % just continue to next iteration after error
        db_asl.diaryfile                = '<SESSIONDIR>/ASL_module.log';
        db_asl.jobfn = @module_ASL_VENDORCOMPARISON;
        fprintf('Starting ASL module...\n');
        bAborted = LoopDB(db_asl);
    end
    
end
