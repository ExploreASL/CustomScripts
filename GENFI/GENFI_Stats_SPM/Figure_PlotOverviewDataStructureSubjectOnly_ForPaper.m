%% Plot Overview DataStructure Family Subject
% Used para-cingulate CBF (strongest effect cluster)

% Change indices
Yrs_AAO_index       = 11;
SubjectIndex        = 10;
MutStatusIndex      =  7;
LongTPindex         =  1;

%%

% CBF             = 0;
% cbfFile             = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\p0.001_baseline\CBF_bilat_cingulate.mat';
% save( cbfFile ,'CBF');
load( cbfFile);

Yrs_AAO         = x.S.SetsID(:,Yrs_AAO_index);

%% Create random factor Subject
IndexN              = 1;
SubjectList         = zeros(x.nSubjects,1);
for iS=1:x.nSubjects
    clear IsVolume VolumeList VolumeN IndicesAre
    [ IsVolume VolumeList VolumeN ] = LongRegInit( x, x.SUBJECTS{iS} );
    IndicesAre                  = find(VolumeList(:,2)~=0);
    if  sum(SubjectList(IndicesAre,1))==0 % skips processed subjects
        SubjectList(IndicesAre,1)   = IndexN;
        IndexN                      = IndexN+1;
    end
end

U   = unique(SubjectList);

%% Show SUBJECT
figure(1);
for iS=1:length(U)
    % get index first scan in multi-scan matrix
    IndexSubj   = min(find(SubjectList==iS));
    
    if      x.S.SetsID(IndexSubj,MutStatusIndex)<2 % non-carrier
            plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'g.-');
    elseif  x.S.SetsID(IndexSubj,MutStatusIndex)<5 % presympt carriers
            plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'r.-');
    elseif  x.S.SetsID(IndexSubj,MutStatusIndex)<8 % sympt carriers
%             plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'r.:');        
    else    error('wrong Carrier')
    end
    hold on
end

% sum(x.S.SetsID(:,LongTPindex)==2 & x.S.SetsID(:,MutStatusIndex)==1) % non-carriers
% sum(x.S.SetsID(:,LongTPindex)==3 & x.S.SetsID(:,MutStatusIndex)>1 & x.S.SetsID(:,MutStatusIndex)<5) % presympt
% sum(x.S.SetsID(:,LongTPindex)==3 & x.S.SetsID(:,MutStatusIndex)>4 & x.S.SetsID(:,MutStatusIndex)<8) % sympt

nScanNonCarr        = 113+55+3;
nScanPresympt       = 107+43+4;

xlabel('Years to age of expected onset of symptoms');
ylabel('CBF bilateral (para-)cingulate gyrus (mL/100g/min)');
title( ['Overview within-subject relatedness (connecting lines) of all scans for pre-symptomatic carriers (red, n=' num2str(nScanPresympt) ') and non-carriers (green, ' num2str(nScanNonCarr) ')']);

MinX    = -45;
MaxX    = 30;
MinY    = 40;
MaxY    = 190;

axis([MinX MaxX MinY MaxY]);

hold on;

% Contrast green & red is high, try darker green, thicken lines

% Create regression lines
Beta_preSymp        = -0.93;
Beta_nonCarr        = -0.06;
InterCept_PreSymp   = 120;
InterCept_nonCarr   = 125;

plot([MinX MaxX],Beta_preSymp.*[MinX MaxX]+InterCept_PreSymp,'r-');
plot([MinX MaxX],Beta_nonCarr.*[MinX MaxX]+InterCept_nonCarr,'g-');

% % Check regression intercept
% Yrs_NC  = Yrs_AAO(x.S.SetsID(:,MutStatusIndex)==1);
% CBF_NC  = CBF(x.S.SetsID(:,MutStatusIndex)==1);
% Yrs_PS  = Yrs_AAO(x.S.SetsID(:,MutStatusIndex)>1 & x.S.SetsID(:,MutStatusIndex)<5);
% CBF_PS  = CBF(x.S.SetsID(:,MutStatusIndex)>1 & x.S.SetsID(:,MutStatusIndex)<5);
% 
% 
% [B,BINT,R,RINT,STATS] = regress(Yrs_NC,CBF_NC);
% [B,BINT,R,RINT,STATS] = regress(Yrs_PS,CBF_PS);
% % this doesn't give a significant interaction effect, probably because
% % age & sex variability is not taken out. Wait for Saira to send the
% % intercept
