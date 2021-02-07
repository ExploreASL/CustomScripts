%% Move qCBF images into QC categories, ASL CHECK

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK';
Flist   = xASL_adm_GetFileList(ROOT, '^qCBF_(GE|PH|SI).*_ASL_1\.jpg$');

Dir_Good        = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK\QC_3_final\1_Good';
Dir_Acceptable  = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK\QC_3_final\2_Acceptable';
Dir_Bad         = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK\QC_3_final\3_Bad';
Dir_Unusable    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK\QC_3_final\4_Unusable';
Dir_Less10      = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK\QC_3_final\LessThan10Subjects';

for iFile=1:length(Flist)
    [path file ext]     = fileparts(Flist{iFile});
    
    Name    = file(6:end-6);
    
    % Check in categories
    clear Category2Move
    for iC=1:length(x.exclusion)
        if  ~isempty(findstr(x.exclusion{iC},Name))
            Category2Move   = iC;
        end
    end
    if     ~exist('Category2Move','var')
            xASL_Move( Flist{iFile}, fullfile(Dir_Good,[file ext]),1);
    elseif  strcmp(x.exclusionReason{Category2Move},'AcceptableQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Acceptable,[file ext]),1);
    elseif  strcmp(x.exclusionReason{Category2Move},'BadQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Bad,[file ext]),1);            
    elseif  strcmp(x.exclusionReason{Category2Move},'UnusableQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Unusable,[file ext]),1);
    elseif  ~isempty(findstr(x.exclusionReason{Category2Move},'LessThan10Subjects'))
            xASL_Move( Flist{iFile}, fullfile(Dir_Less10,[file ext]));            
    end
end


%% Move qCBF images into QC categories, T1_ASLREG

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\T1_ASLREG';
Flist   = xASL_adm_GetFileList(ROOT, '^PWI_(GE|PH|SI).*_ASL_1_reg\.jpg$');

Dir_Good        = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\T1_ASLREG\QC_3_final\1_Good';
Dir_Acceptable  = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\T1_ASLREG\QC_3_final\2_Acceptable';
Dir_Bad         = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\T1_ASLREG\QC_3_final\3_Bad';
Dir_Unusable    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\T1_ASLREG\QC_3_final\4_Unusable';
Dir_Less10      = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\T1_ASLREG\QC_3_final\LessThan10Subjects';

for iFile=1:length(Flist)
    [path file ext]     = fileparts(Flist{iFile});
    
    Name    = file(5:end-10);
    
    % Check in categories
    clear Category2Move
    for iC=1:length(x.exclusion)
        if  ~isempty(findstr(x.exclusion{iC},Name))
            Category2Move   = iC;
        end
    end
    if     ~exist('Category2Move','var')
            xASL_Move( Flist{iFile}, fullfile(Dir_Good,[file ext]),1);
    elseif  strcmp(x.exclusionReason{Category2Move},'AcceptableQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Acceptable,[file ext]),1);
    elseif  strcmp(x.exclusionReason{Category2Move},'BadQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Bad,[file ext]),1);            
    elseif  strcmp(x.exclusionReason{Category2Move},'UnusableQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Unusable,[file ext]),1);
    elseif  ~isempty(findstr(x.exclusionReason{Category2Move},'LessThan10Subjects'))
            xASL_Move( Flist{iFile}, fullfile(Dir_Less10,[file ext]));            
    end
end


%% Move qCBF images into QC categories, M0_REG_ASL

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\M0_REG_ASL';
Flist   = xASL_adm_GetFileList(ROOT, '^(mean_control|M0)_(GE|PH|SI).*_ASL_1_reg\.jpg$');

Dir_Good        = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\M0_REG_ASL\QC_3_final\1_Good';
Dir_Acceptable  = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\M0_REG_ASL\QC_3_final\2_Acceptable';
Dir_Bad         = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\M0_REG_ASL\QC_3_final\3_Bad';
Dir_Unusable    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\M0_REG_ASL\QC_3_final\4_Unusable';
Dir_Less10      = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\M0_REG_ASL\QC_3_final\LessThan10Subjects';

for iFile=1:length(Flist)
    [path file ext]     = fileparts(Flist{iFile});
    if ~isempty(findstr(file,'M0'))
        Name    = file(4:end-10);
    else
        Name    = file(14:end-10);
    end
    
    
    % Check in categories
    clear Category2Move
    for iC=1:length(x.exclusion)
        if  ~isempty(findstr(x.exclusion{iC},Name))
            Category2Move   = iC;
        end
    end
    if     ~exist('Category2Move','var')
            xASL_Move( Flist{iFile}, fullfile(Dir_Good,[file ext]),1);
    elseif  strcmp(x.exclusionReason{Category2Move},'AcceptableQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Acceptable,[file ext]),1);
    elseif  strcmp(x.exclusionReason{Category2Move},'BadQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Bad,[file ext]),1);            
    elseif  strcmp(x.exclusionReason{Category2Move},'UnusableQuality')
            xASL_Move( Flist{iFile}, fullfile(Dir_Unusable,[file ext]),1);
    elseif  ~isempty(findstr(x.exclusionReason{Category2Move},'LessThan10Subjects'))
            xASL_Move( Flist{iFile}, fullfile(Dir_Less10,[file ext]));            
    end
end
