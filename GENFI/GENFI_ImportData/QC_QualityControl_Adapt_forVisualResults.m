%%      1) QC based on spatial CoV
clear SortedCoV CBF_spatial_CoV QualityGood QualityAcceptable QualityBad NextN
FName                   = 'C:\Backup\ASL\GENFI\GENFI_DF2\CBF_spatial_CoV_FULLDATASET n=406.mat';
load(FName);

NextN                   = [1 1 1 1];

for iS=1:length(CBF_spatial_CoV)
    
    if      CBF_spatial_CoV{iS,2}<0.6 % good
            QualityGood{NextN(1),1}             = CBF_spatial_CoV{iS,1};
            NextN       = NextN + [1 0 0 0];

    elseif  CBF_spatial_CoV{iS,2}>0.6 & CBF_spatial_CoV{iS,2}<0.8 % acceptable
            QualityAcceptable{NextN(2),1}       = CBF_spatial_CoV{iS,1};
            NextN       = NextN + [0 1 0 0];
        
    elseif  CBF_spatial_CoV{iS,2}>0.8 % bad
            QualityBad{NextN(3),1}              = CBF_spatial_CoV{iS,1};
            NextN       = NextN + [0 0 1 0];
    end
    
end

%%      1) Predefined unusable
UnusableDir{1}  = 'C:\Backup\ASL\GENFI\GENFI_DF2\Excluded\Unusable_1';
UnusableDir{2}  = 'C:\Backup\ASL\GENFI\GENFI_DF2\Excluded\Unusable_2';

QualityUnusable     = xASL_adm_GetFsList(UnusableDir{1},'^.*(C9ORF|MAPT|GRN)\d{3}_\d$',1)';
Dlist               = xASL_adm_GetFsList(UnusableDir{2},'^.*(C9ORF|MAPT|GRN)\d{3}_\d$',1)';
for iD=1:length(Dlist)
    QualityUnusable(end+1,1)    = Dlist(iD,1);
end
    
% Save this
save( 'C:\Backup\ASL\GENFI\GENFI_DF2\QC1_SpatialCoV_only.mat', 'QualityGood1','QualityAcceptable1','QualityBad1','QualityUnusable1');

%%      2&3)    QC visually adapted

Good2Acceptable         = {'C9ORF045_1' 'C9ORF057_1' 'C9ORF067_1' 'GRN132_1' 'C9ORF013_1' 'C9ORF053_2' 'C9ORF078_1' 'C9ORF087_1' 'GRN167_1' 'C9ORF047_1' 'GRN016_1' 'GRN078_2' 'GRN004_2' 'GRN038_2' 'MAPT027_2' 'C9ORF013_2' 'MAPT037_1' 'GRN090_1' 'GRN169_1' 'GRN161_1'};
Good2Bad                = {'GRN114_1' 'C9ORF120_1' 'C9ORF120_2'};
Acceptable2Bad          = {'C9ORF023_1' 'GRN009_2'};

Acceptable2Good         = {'GRN074_2' 'MAPT014_2' 'MAPT037_2'};
Bad2Acceptable          = {'C9ORF054_1' 'C9ORF054_2' 'C9ORF110_2' 'C9ORF049_2' 'C9ORF046_1'};
Unusable2Bad            = {'GRN119_1' 'C9ORF088_2'};


%%      Create new categories

QualityGood2            = QualityGood1;
QualityAcceptable2      = QualityAcceptable1;
QualityBad2             = QualityBad1;
QualityUnusable2        = QualityUnusable1;

OldCateg                = {'Good'            'Good'     'Acceptable'     'Acceptable'       'Bad'            'Unusable'};
NewCateg                = {'Acceptable'      'Bad'      'Bad'            'Good'             'Acceptable'     'Bad'};
Categ                   = {'Good2Acceptable' 'Good2Bad' 'Acceptable2Bad' 'Acceptable2Good'  'Bad2Acceptable' 'Unusable2Bad'};


%%  1) Good2Acceptable
for iS=1:length(Good2Acceptable)
    clear Sub List1 List2 iL1 iL2
    Sub             = Good2Acceptable{iS}; % subject that we want to move between categories

    % find subject in first category. check that it is present only once
    List1           = '';
    for iL1=1:length(QualityGood2)
        if  findstr(QualityGood2{iL1},Sub)
            List1{end+1,1}    = iL1;
            List1{end  ,2}    = QualityGood2{iL1};
        end
    end
    if  size(List1,1)>1
        error('Subject name present multiple times');
    end

    % make sure subject was not present in second category
    List2           = '';
    for iL2=1:length(QualityAcceptable2)
        if  findstr(QualityAcceptable2{iL2},Sub)
            List2{end+1,1}    = iL2;
            List2{end  ,2}    = QualityAcceptable2{iL2};
        end
    end
    if  size(List2,1)>0
        error('Subject name present in destination category');
    end    

    % Add subject to new category
    QualityAcceptable2{end+1}       = QualityGood2{List1{1,1}};
    % Remove subject from old category
    QualityGood2(List1{1}:end-1,1)  = QualityGood2(List1{1}+1:end,1);
    QualityGood2                    = QualityGood2(1:end-1,1);
end
    
%%  2) Good2Bad
for iS=1:length(Good2Bad)
    clear Sub List1 List2 iL1 iL2
    Sub             = Good2Bad{iS}; % subject that we want to move between categories
 
    % find subject in first category. check that it is present only once
    List1           = '';
    for iL1=1:length(QualityGood2)
        if  findstr(QualityGood2{iL1},Sub)
            List1{end+1,1}    = iL1;
            List1{end  ,2}    = QualityGood2{iL1};
        end
    end
    if  size(List1,1)>1
        error('Subject name present multiple times');
    end
 
    % make sure subject was not present in second category
    List2           = '';
    for iL2=1:length(QualityBad2)
        if  findstr(QualityBad2{iL2},Sub)
            List2{end+1,1}    = iL2;
            List2{end  ,2}    = QualityBad2{iL2};
        end
    end
    if  size(List2,1)>0
        error('Subject name present in destination category');
    end    
 
    % Add subject to new category
    QualityBad2{end+1}       = QualityGood2{List1{1,1}};
    % Remove subject from old category
    QualityGood2(List1{1}:end-1,1)  = QualityGood2(List1{1}+1:end,1);
    QualityGood2                    = QualityGood2(1:end-1,1);
end


%%  3) Acceptable2Bad
for iS=1:length(Acceptable2Bad)
    clear Sub List1 List2 iL1 iL2
    Sub             = Acceptable2Bad{iS}; % subject that we want to move between categories
 
    % find subject in first category. check that it is present only once
    List1           = '';
    for iL1=1:length(QualityAcceptable2)
        if  findstr(QualityAcceptable2{iL1},Sub)
            List1{end+1,1}    = iL1;
            List1{end  ,2}    = QualityAcceptable2{iL1};
        end
    end
    if  size(List1,1)>1
        error('Subject name present multiple times');
    end
 
    % make sure subject was not present in second category
    List2           = '';
    for iL2=1:length(QualityBad2)
        if  findstr(QualityBad2{iL2},Sub)
            List2{end+1,1}    = iL2;
            List2{end  ,2}    = QualityBad2{iL2};
        end
    end
    if  size(List2,1)>0
        error('Subject name present in destination category');
    end    
 
    % Add subject to new category
    QualityBad2{end+1}                      = QualityAcceptable2{List1{1,1}};
    % Remove subject from old category
    QualityAcceptable2(List1{1}:end-1,1)    = QualityAcceptable2(List1{1}+1:end,1);
    QualityAcceptable2                      = QualityAcceptable2(1:end-1,1);
end


%%  4) Acceptable2Good
for iS=1:length(Acceptable2Good)
    clear Sub List1 List2 iL1 iL2
    Sub             = Acceptable2Good{iS}; % subject that we want to move between categories
 
    % find subject in first category. check that it is present only once
    List1           = '';
    for iL1=1:length(QualityAcceptable2)
        if  findstr(QualityAcceptable2{iL1},Sub)
            List1{end+1,1}    = iL1;
            List1{end  ,2}    = QualityAcceptable2{iL1};
        end
    end
    if  size(List1,1)>1
        error('Subject name present multiple times');
    end
 
    % make sure subject was not present in second category
    List2           = '';
    for iL2=1:length(QualityGood2)
        if  findstr(QualityGood2{iL2},Sub)
            List2{end+1,1}    = iL2;
            List2{end  ,2}    = QualityGood2{iL2};
        end
    end
    if  size(List2,1)>0
        error('Subject name present in destination category');
    end    
 
    % Add subject to new category
    QualityGood2{end+1}                     = QualityAcceptable2{List1{1,1}};
    % Remove subject from old category
    QualityAcceptable2(List1{1}:end-1,1)    = QualityAcceptable2(List1{1}+1:end,1);
    QualityAcceptable2                      = QualityAcceptable2(1:end-1,1);
end


%%  5) Bad2Acceptable
for iS=1:length(Bad2Acceptable)
    clear Sub List1 List2 iL1 iL2
    Sub             = Bad2Acceptable{iS}; % subject that we want to move between categories
 
    % find subject in first category. check that it is present only once
    List1           = '';
    for iL1=1:length(QualityBad2)
        if  findstr(QualityBad2{iL1},Sub)
            List1{end+1,1}    = iL1;
            List1{end  ,2}    = QualityBad2{iL1};
        end
    end
    if  size(List1,1)>1
        error('Subject name present multiple times');
    end
 
    % make sure subject was not present in second category
    List2           = '';
    for iL2=1:length(QualityAcceptable2)
        if  findstr(QualityAcceptable2{iL2},Sub)
            List2{end+1,1}    = iL2;
            List2{end  ,2}    = QualityAcceptable2{iL2};
        end
    end
    if  size(List2,1)>0
        error('Subject name present in destination category');
    end    
 
    % Add subject to new category
    QualityAcceptable2{end+1}                     = QualityBad2{List1{1,1}};
    % Remove subject from old category
    QualityBad2(List1{1}:end-1,1)    = QualityBad2(List1{1}+1:end,1);
    QualityBad2                      = QualityBad2(1:end-1,1);
end

%%  5) Unusable2Bad
for iS=1:length(Unusable2Bad)
    clear Sub List1 List2 iL1 iL2
    Sub             = Unusable2Bad{iS}; % subject that we want to move between categories
 
    % find subject in first category. check that it is present only once
    List1           = '';
    for iL1=1:length(QualityUnusable2)
        if  findstr(QualityUnusable2{iL1},Sub)
            List1{end+1,1}    = iL1;
            List1{end  ,2}    = QualityUnusable2{iL1};
        end
    end
    if  size(List1,1)>1
        error('Subject name present multiple times');
    end
 
    % make sure subject was not present in second category
    List2           = '';
    for iL2=1:length(QualityBad2)
        if  findstr(QualityBad2{iL2},Sub)
            List2{end+1,1}    = iL2;
            List2{end  ,2}    = QualityBad2{iL2};
        end
    end
    if  size(List2,1)>0
        error('Subject name present in destination category');
    end    
 
    % Add subject to new category
    QualityBad2{end+1}                    = QualityUnusable2{List1{1,1}};
    % Remove subject from old category
    QualityUnusable2(List1{1}:end-1,1)    = QualityUnusable2(List1{1}+1:end,1);
    QualityUnusable2                      = QualityUnusable2(1:end-1,1);
end


% Save this
save( 'C:\Backup\ASL\GENFI\GENFI_DF2\QC3_SpatialCoV&visualQC.mat', 'QualityGood2','QualityAcceptable2','QualityBad2','QualityUnusable2');

%%      Repair
% SI_Trio_MAPT036_1 accidentally ended up in both bad & unusable, should be
% in unusable only

Index   = [];

for iS=1:length(QualityBad2)
    if  strcmp(QualityBad2{iS},'SI_Trio_MAPT036_1')
        Index(end+1)        = iS;
    end
end

if  ~isempty(Index)
    QualityBad2(Index:end-1,1)    = QualityBad2(Index+1:end,1);
    QualityBad2                   = QualityBad2(1:end-1,1);     
end     

% GE_C9ORF120_2 ended up in both bad & unusable, should be
% in unusable only. It started in good because of moving from unusable to
% good for spatial CoV only, but not on HD

Index   = [];

for iS=1:length(QualityBad2)
    if  strcmp(QualityBad2{iS},'GE_C9ORF120_2')
        Index(end+1)        = iS;
    end
end

if  ~isempty(Index)
    QualityBad2(Index:end-1,1)    = QualityBad2(Index+1:end,1);
    QualityBad2                   = QualityBad2(1:end-1,1);     
end     

% Same for C9ORF088_1 Acceptable & C9ORF088_2 "good2"

Index   = [];

for iS=1:length(QualityAcceptable2)
    if  strcmp(QualityAcceptable2{iS},'GE_C9ORF088_1')
        Index(end+1)        = iS;
    end
end

if  ~isempty(Index)
    QualityAcceptable2(Index:end-1,1)    = QualityAcceptable2(Index+1:end,1);
    QualityAcceptable2                   = QualityAcceptable2(1:end-1,1);     
end     


Index   = [];

for iS=1:length(QualityGood2)
    if  strcmp(QualityGood2{iS},'GE_C9ORF088_2')
        Index(end+1)        = iS;
    end
end

if  ~isempty(Index)
    QualityGood2(Index:end-1,1)    = QualityGood2(Index+1:end,1);
    QualityGood2                   = QualityGood2(1:end-1,1);     
end    

%%      Count

length(QualityGood1) + length(QualityAcceptable1) + length(QualityBad1) + length(QualityUnusable1)

length(QualityGood2) + length(QualityAcceptable2) + length(QualityBad2) + length(QualityUnusable2)

% 

% ExcludeLowerThan10PerSite



DlistM  = xASL_adm_GetFsList('C:\Backup\ASL\GENFI\GENFI_DF2\analysis','^(GE|PH_Achieva|SI_Trio|SI_Skyra|SI_Prisma|SI_Allegra).*_(c9ORF|GRN|MAPT)\d{3}_\d$',1)';
