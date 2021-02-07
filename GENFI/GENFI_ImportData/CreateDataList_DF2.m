ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2';
% [data, text, rawData]   =   xlsread(fullfile(ROOT, 'GENFI_DF2_MASTER_25Apr2016.xlsx'),1);
% save(fullfile(ROOT,'rawData.mat'),'rawData');
% [data, text, rawDataFollowUp]   =   xlsread(fullfile(ROOT, 'GENFI_DF2_MASTER_25Apr2016.xlsx'),2);
% save(fullfile(ROOT,'rawDataFollowUp.mat'),'rawDataFollowUp');

load(fullfile(ROOT,'rawData.mat'));

Dlist       = xASL_adm_GetFsList(fullfile(ROOT,'analysis'), '^.*(C9ORF|GRN|MAPT).*_\d$',1);
Next        = 1; 

% VarName     = {'age' 'CarrierYesNo' 'GeneticStatus' 'Yrs_AAO' 'sex' 'MutationStatus' 'MutationStatus7' 'Family' 'Education' 'Handedness' 'Sequence'}; %
% 
% clear x.P.SubjectID
% 
% for iV=1:length(VarName)
%     eval(['clear ' VarName{iV}]);
% end
%  
% for iF=2:size(rawData,1)
%     clear x.P.SubjectID2Find SkipSub NextN x.P.SubjectID
%     x.P.SubjectID2Find             = rawData{iF,2};
%     SkipSub                     = 1;
%     
%     % find subject
%     NextN                       = 1;
%     for iS=1:length(Dlist)
%         if  ~isempty(strfind(Dlist{iS},x.P.SubjectID2Find))
%             x.P.SubjectID{NextN}   = Dlist{iS};
%             SkipSub             = 0;            
%             NextN               = NextN+1;
%         end
%     end
%     
%     if  exist('x.P.SubjectID','var')
% 
%         for iS=1:length(x.P.SubjectID)
% 
%             if ~SkipSub
%                 age{Next,1}                 = x.P.SubjectID{iS};
%                 CarrierYesNo{Next,1}        = x.P.SubjectID{iS};
%                 GeneticStatus{Next,1}       = x.P.SubjectID{iS};
%                 Yrs_AAO{Next,1}             = x.P.SubjectID{iS};
%                 sex{Next,1}                 = x.P.SubjectID{iS};
%                 MutationStatus{Next,1}      = x.P.SubjectID{iS};
%                 Family{Next,1}              = x.P.SubjectID{iS};
%                 MutationStatus7{Next,1}     = x.P.SubjectID{iS};
%                 Education{Next,1}           = x.P.SubjectID{iS};
%                 Handedness{Next,1}          = x.P.SubjectID{iS};
%                 Sequence{Next,1}            = x.P.SubjectID{iS};
% 
%                 Yrs_AAO{Next,2}             = rawData{iF,15};
%                 age{Next,2}                 = rawData{iF, 8};
%                 sex{Next,2}                 = rawData{iF, 9};        
%                 GeneticStatus{Next,2}       = rawData{iF, 6};
%                 Family{Next,2}              = rawData{iF, 5};
%                 Education{Next,2}           = rawData{iF,11};
%                 Handedness{Next,2}          = rawData{iF,10};
%                 
% 
%     %             % Temporally append scan time points 2 & 3 for site
%     %             
%     %             % TP1
%     %             Site{Next,1}                = [x.P.SubjectID{iS}(1:end-1) '1'];
%     %             Site{Next,2}                = rawData{iF, 1};
%     %             % TP2
%     %             Next                        = Next+1;
%     %             Site{Next,1}                = [x.P.SubjectID{iS}(1:end-1) '2'];
%     %             Site{Next,2}                = rawData{iF, 1};
%     %             % TP3
%     %             Next                        = Next+1;
%     %             Site{Next,1}                = [x.P.SubjectID{iS}(1:end-1) '3'];
%     %             Site{Next,2}                = rawData{iF, 1};
% 
%                 if      rawData{iF,6}==0
%                         % Non-carrier
%                         CarrierYesNo{Next ,2}   = 0;
%                         MutationStatus{Next,2}  = 1;
% 
% 
%                 else    % Carrier
%                         CarrierYesNo{Next ,2}   = 1;
% 
%                         if      strcmp(rawData{iF,4},'C9orf72')
%                                 MutationStatus{Next,2}      = 2;
%                         elseif  strcmp(rawData{iF,4},'GRN')
%                                 MutationStatus{Next,2}      = 3;
%                         elseif  strcmp(rawData{iF,4},'MAPT')
%                                 MutationStatus{Next,2}      = 4;
%                         else    error('Unknown MutationType');
%                         end                
%                 end
% 
%                 if      GeneticStatus{Next,2}==0
%                         if  MutationStatus{Next,2}~=1
%                             error('GeneticStatus & MutationStatus are incompatible');
%                         end
%                         MutationStatus7{Next,2} = 1;
%                 elseif  GeneticStatus{Next,2}==1 && MutationStatus{Next,2}==2
%                         MutationStatus7{Next,2} = 2;
%                 elseif  GeneticStatus{Next,2}==1 && MutationStatus{Next,2}==3                    
%                         MutationStatus7{Next,2} = 3;            
%                 elseif  GeneticStatus{Next,2}==1 && MutationStatus{Next,2}==4
%                         MutationStatus7{Next,2} = 4;
%                 elseif  GeneticStatus{Next,2}==2 && MutationStatus{Next,2}==2
%                         MutationStatus7{Next,2} = 5;
%                 elseif  GeneticStatus{Next,2}==2 && MutationStatus{Next,2}==3                    
%                         MutationStatus7{Next,2} = 6;
%                 elseif  GeneticStatus{Next,2}==2 && MutationStatus{Next,2}==4                    
%                         MutationStatus7{Next,2} = 7;
%                 else    error('No value found for MutationStatus7');
%                 end
% 
%                 if      ~isempty(findstr(x.P.SubjectID{iS},'SI'))
%                         Sequence{Next,2}          = '3D GRASE';
%                 elseif  ~isempty(findstr(x.P.SubjectID{iS},'GE'))
%                         Sequence{Next,2}          = '3D spiral';
%                 elseif  ~isempty(findstr(x.P.SubjectID{iS},'Achieva_noBsup'))
%                         Sequence{Next,2}          = '2D EPI noBsup';
%                 elseif  ~isempty(findstr(x.P.SubjectID{iS},'Achieva_Bsup'))
%                         Sequence{Next,2}          = '2D EPI Bsup';
%                 else    error(['No valid sequence found for # ' num2str(iD) ' subject ' x.P.SubjectID{iS}]);
%                 end
%                 
%                 
%                 Next                        = Next+1;
%             end
%         end
%     end 
% end
%     
% for iV=1:length(VarName)
%     save( fullfile(ROOT, [VarName{iV} '.mat']), VarName{iV} );
% end    
%     
% %% Yrs_AAO_bracket
% 
% Yrs_bracket                     = floor(Yrs_AAO/10);
% Yrs_bracket(Yrs_bracket>=0)     = 0;
% Yrs_bracket(Yrs_bracket<=-3)    = -3;


load(fullfile(ROOT,'rawDataFollowUP.mat'));
Next        = 1;
VarName     = {'Interval'};

clear x.P.SubjectID

for iV=1:length(VarName)
    eval(['clear ' VarName{iV}]);
end
 
clear LongitudinalInterval

for iF=2:size(rawDataFollowUp,1)
    clear x.P.SubjectID2Find SkipSub NextN x.P.SubjectID
    x.P.SubjectID2Find             = rawDataFollowUp{iF,2};
    SkipSub                     = 1;
    
    % find subject
    NextN                       = 1;
    for iS=1:length(Dlist)
        if  ~isempty(strfind(Dlist{iS},x.P.SubjectID2Find))
            x.P.SubjectID{NextN}   = Dlist{iS};
            SkipSub             = 0;            
            NextN               = NextN+1;
        end
    end
    
    if  exist('x.P.SubjectID','var')

        for iS=1 %:length(x.P.SubjectID)

            if ~SkipSub
                LongitudinalInterval{Next,1}                 = x.P.SubjectID{iS};
                LongitudinalInterval{Next,2}                 = rawDataFollowUp{iF,6};
                Next        = Next+1;
            end
        end
    end
end

LongitudinalInterval    = sortrows(LongitudinalInterval,1);

%% Impute missing intervals
MissingSubjects         = {'PH_Achieva_Bsup_GRN020_1' 'SI_Trio_NSA5_C9ORF037_2' 'SI_Trio_NSA5_C9ORF044_2' 'SI_Trio_NSA5_C9ORF049_2' 'SI_Trio_NSA5_GRN079_2' 'SI_Trio_NSA5_MAPT007_2' 'SI_Trio_NSA5_MAPT026_2'};
medianInterval          = 1.006;
for iM=1:length(MissingSubjects)
    LongitudinalInterval{end+1,1}   = MissingSubjects{iM};
    LongitudinalInterval{end  ,2}   = medianInterval;
end

save( fullfile(ROOT, 'LongitudinalInterval.mat'), 'LongitudinalInterval' );

%% From baseline age & interval create age at second time point

ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2';
load(fullfile(ROOT, 'age.mat'));
load(fullfile(ROOT, 'LongitudinalInterval.mat'));

age                     = sortrows(age,1);
LongitudinalInterval    = sortrows(LongitudinalInterval,1);

for iA=1:size(age,1)
    if  strcmp(age{iA,1}(1:end-2),age{iA+1,1}(1:end-2)) && age{iA,2}==age{iA+1,2}
        % if there are multiple time points from the same subject
        % and age was the same
        
        for iL=1:size(LongitudinalInterval,1)
            if  strcmp(age{iA,1},LongitudinalInterval{iL,1})
                if      LongitudinalInterval{iL,2}~=9999
                        age{iA+1,2}     = age{iA+1,2}+LongitudinalInterval{iL,2};
                else    age{iA+1,2}     = 9999;
                end                
            end
        end
    end
end
        
save(fullfile(ROOT, 'age.mat'),'age');
save(fullfile(ROOT, 'LongitudinalInterval.mat'),'LongitudinalInterval');
        
%% From baseline age & interval create age at second time point for Yrs_AAO

ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2';
load(fullfile(ROOT, 'Yrs_AAO.mat'));
load(fullfile(ROOT, 'LongitudinalInterval.mat'));

Yrs_AAO                 = sortrows(Yrs_AAO,1);
LongitudinalInterval    = sortrows(LongitudinalInterval,1);

for iA=1:size(Yrs_AAO,1)
    if  strcmp(Yrs_AAO{iA,1}(1:end-2),Yrs_AAO{iA+1,1}(1:end-2)) && Yrs_AAO{iA,2}==Yrs_AAO{iA+1,2}
        % if there are multiple time points from the same subject
        % and age was the same
        
        for iL=1:size(LongitudinalInterval,1)
            if  strcmp(Yrs_AAO{iA,1},LongitudinalInterval{iL,1})
                if      LongitudinalInterval{iL,2}~=9999
                        Yrs_AAO{iA+1,2}     = Yrs_AAO{iA+1,2}+LongitudinalInterval{iL,2};
                else    Yrs_AAO{iA+1,2}     = 9999;
                end
            end
        end
    end
end
        
save(fullfile(ROOT, 'Yrs_AAO.mat'),'Yrs_AAO');


%% Impute missing age
Yrs_AAO     = sortrows(Yrs_AAO,1);
MissingSubjects         = {'PH_Achieva_Bsup_GRN020_1' 'SI_Trio_NSA5_C9ORF037_2' 'SI_Trio_NSA5_C9ORF044_2' 'SI_Trio_NSA5_C9ORF049_2' 'SI_Trio_NSA5_GRN079_2' 'SI_Trio_NSA5_MAPT007_2' 'SI_Trio_NSA5_MAPT026_2'};
for iM=1:length(MissingSubjects)
    for iA=1:length(Yrs_AAO)
        if  strcmp( MissingSubjects{iM}, age{iA,1})
            Yrs_AAO{iA+1,2}     = Yrs_AAO{iA,2}+1.1006;
        end
    end
end

save(fullfile(ROOT, 'Age.mat'),'age');        

%% Redo site, checking imputing follow-up points from baseline if needed

ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2';
load(fullfile(ROOT,'rawData.mat'));
load(fullfile(ROOT,'rawDataFollowUP.mat'));

Dlist       = xASL_adm_GetFsList(fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long','analysis'), '^.*(C9ORF|GRN|MAPT).*_\d$',1);
Next        = 1; 

clear x.P.SubjectID

clear Site
 
for iF=2:size(rawData,1)
    clear x.P.SubjectID2Find SkipSub NextN x.P.SubjectID
    x.P.SubjectID2Find             = rawData{iF,2};
    SkipSub                     = 1;
    
    % find subject
    NextN                       = 1;
    for iS=1:length(Dlist)
        if  ~isempty(strfind(Dlist{iS},x.P.SubjectID2Find))
            x.P.SubjectID{NextN}   = Dlist{iS};
            SkipSub             = 0;            
            NextN               = NextN+1;
        end
    end
    
    if  exist('x.P.SubjectID','var')

        for iS=1:length(x.P.SubjectID)

            if ~SkipSub
                

                % Assume baseline information of excel file is for baseline
                % only
                % Also assume that subject remains in the same site, unless
                % second time point data says otherwise
                % Create three time points for simplicity
                
                % TP1
                Site{Next,1}                = [x.P.SubjectID{iS}(1:end-1) '1'];
                Site{Next,2}                = rawData{iF, 1};
                
                % TP2
                Next                        = Next+1;
                Site{Next,1}                = [x.P.SubjectID{iS}(1:end-1) '2'];
                
                
                for iR=2:size(rawDataFollowUp,1)
                    if     ~isempty(findstr(x.P.SubjectID{iS}(4:end-2),rawDataFollowUp{iR,2})) % if this subject is mentioned in follow-up excel
                            Site{Next,2}        = rawDataFollowUp{iR, 1};
                    else    Site{Next,2}        = Site{Next-1,2}; % otherwise, just use same as baseline
                    end
                end
                
                % TP3 -> assume equal to TP2
                Next                        = Next+1;
                Site{Next,1}                = [x.P.SubjectID{iS}(1:end-1) '3'];
                Site{Next,2}                = Site{Next-1,2};
                
                Next                        = Next+1;
            end
        end
    end 
end


%% append Prisma
ListPrisma  = {'SI_Trio_C9ORF003_2' 'SI_Trio_C9ORF011_2' 'SI_Trio_C9ORF025_2' 'SI_Trio_C9ORF053_2' 'SI_Trio_C9ORF054_2' 'SI_Trio_C9ORF070_1' 'SI_Trio_C9ORF071_1' 'SI_Trio_C9ORF072_1' 'SI_Trio_C9ORF090_1' 'SI_Trio_C9ORF122_1'};

for iS=1:size(Site,1)
    for iL=1:length(ListPrisma)
        if  findstr(Site{iS,1},ListPrisma{iL})
            Site{iS,2}      = [Site{iS,2} '_Prisma'];
        end
    end
end        
        

Site            = sortrows(Site,2);
save( fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long','Site.mat'), 'Site' );












%% REDO AGE & Yrs_AAO

ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2';
% [data, text, rawData]   =   xlsread(fullfile(ROOT, 'GENFI_DF2_MASTER_25Apr2016.xlsx'),1);
% save(fullfile(ROOT,'rawData.mat'),'rawData');
% [data, text, rawDataFollowUp]   =   xlsread(fullfile(ROOT, 'GENFI_DF2_MASTER_25Apr2016.xlsx'),2);
% save(fullfile(ROOT,'rawDataFollowUp.mat'),'rawDataFollowUp');

load(fullfile(ROOT,'rawData.mat'));

Dlist       = xASL_adm_GetFsList('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis', '^.*(C9ORF|GRN|MAPT).*_\d$',1);
Next        = 1; 

VarName     = {'age' 'Yrs_AAO' 'MMSE' 'Cambr_Behav_Invent' 'FTD_rate_score'};
clear x.P.SubjectID

for iV=1:length(VarName)
    eval(['clear ' VarName{iV}]);
    VarFile{iV}     = fullfile(ROOT, [VarName{iV} '.mat']);
end
 
for iF=2:size(rawData,1)
    clear x.P.SubjectID2Find SkipSub NextN x.P.SubjectID
    x.P.SubjectID2Find             = rawData{iF,2};
    SkipSub                     = 1;
    
    % find subject
    NextN                       = 1;
    for iS=1:length(Dlist)
        if  ~isempty(strfind(Dlist{iS},x.P.SubjectID2Find))
            x.P.SubjectID{NextN}   = Dlist{iS};
            SkipSub             = 0;            
            NextN               = NextN+1;
        end
    end
    
    if  exist('x.P.SubjectID','var')

        for iS=1:length(x.P.SubjectID)

            if ~SkipSub
                age{Next,1}                 = x.P.SubjectID{iS};
                Yrs_AAO{Next,1}             = x.P.SubjectID{iS};
                MMSE{Next,1}                = x.P.SubjectID{iS};
                Cambr_Behav_Invent{Next,1}  = x.P.SubjectID{iS};
                FTD_rate_score{Next,1}      = x.P.SubjectID{iS};

                Yrs_AAO{Next,2}             = rawData{iF,15};
                age{Next,2}                 = rawData{iF, 8};
                MMSE{Next,2}                = rawData{iF, 176};
                Cambr_Behav_Invent{Next,2}  = rawData{iF, 171};
                FTD_rate_score{Next,2}      = rawData{iF, 173};                
                                
                Next                        = Next+1;
            end
        end
    end 
end


for iV=1:length(VarName)
    eval([VarName{iV}  ' = sortrows(' VarName{iV} ',1)']);
end

save(VarFile{3},'MMSE');
save(VarFile{4},'Cambr_Behav_Invent');
save(VarFile{5},'FTD_rate_score');
