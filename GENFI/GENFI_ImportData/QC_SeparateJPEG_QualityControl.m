%% Admin




%% 
clear SortedCoV CBF_spatial_CoV
FName                   = 'C:\Backup\ASL\GENFI\GENFI_DF2\CBF_spatial_CoV_FULLDATASET.mat';
load(FName);

ODIR                    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel\ASL_CHECK\QC';
QualyDir                = {'1_Good' '2_Acceptable' '3_Bad'};


for iS=1:size(CBF_spatial_CoV,1)
    SortedCoV(iS,1)     = CBF_spatial_CoV{iS,2};
    SortedCoV(iS,2)     = iS;
end

SortedCoV               = sortrows(SortedCoV,1);

%      < 0.6 == good quality
% >0.6 < 0.8 == mediocre
% > 0.8      == bad quality

for iS=1:length(SortedCoV)
    clear Name DDIR Q OFILE DFILE
    Name        = CBF_spatial_CoV{SortedCoV(iS,2)};
    
    if      SortedCoV(iS,1)<0.6
            Q   = 1;
    elseif  SortedCoV(iS,1)>0.6 & SortedCoV(iS,1)<0.8
            Q   = 2;
    elseif  SortedCoV(iS,1)>0.8
            Q   = 3;
    end
    
    if      str2num(Name(end))>1
            BFU         = '2'; % Baseline Followup
    else    BFU         = '1';
    end
    
    DDIR        = fullfile( ODIR, [QualyDir{Q} '_' BFU]);
    OFILE       = fullfile( ODIR, ['PWI_' Name '_ASL_1.jpg']);
    DFILE       = fullfile( DDIR, ['PWI_' Name '_ASL_1.jpg']);
    
    if ~exist(DFILE,'file') && exist(OFILE,'file')
        xASL_Move(OFILE,DFILE);
    end
end
        
