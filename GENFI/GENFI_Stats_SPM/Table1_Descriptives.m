%% Table 1 descriptive characteristics

TP                  = x.S.SetsID(:,1);
Cambr_Behav_Invent  = x.S.SetsID(:,3);
Education           = x.S.SetsID(:,5);
FTD_rate_score      = x.S.SetsID(:,6);
GS                  = x.S.SetsID(:,8);
Hand                = x.S.SetsID(:,9);
MMSE                = x.S.SetsID(:,10);
MutStatus7          = x.S.SetsID(:, 7);
Yrs_AAO             = x.S.SetsID(:,11);
age                 = x.S.SetsID(:,16);
sex                 = x.S.SetsID(:,17);



% Create mutation type for non-carriers
for iS=1:x.nSubjects
    GenMutation{iS,1}   = x.SUBJECTS{iS};
    if     ~isempty(findstr(x.SUBJECTS{iS},'C9ORF'))
            Mutation(iS,1)  = 1;
    elseif ~isempty(findstr(x.SUBJECTS{iS},'GRN'))
            Mutation(iS,1)  = 2;
    elseif ~isempty(findstr(x.SUBJECTS{iS},'MAPT'))
            Mutation(iS,1)  = 3;
    else error('no gene found');
    end
    GenMutation{iS,2}   = Mutation(iS,1);
end

% Create list which baseline subjects have follow-up
clear HasFU
for iS=1:x.nSubjects
    clear IsVolume VolumeList VolumeN 
    [ IsVolume VolumeList VolumeN ] = LongRegInit( x, x.SUBJECTS{iS} );
    if      length(VolumeN)>1
            HasFU(iS,1)   = 1;
    else    HasFU(iS,1)   = 0;
    end
end
        

sum(GS==1 & TP==1) % n non-carriers baseline
sum(GS==1 & TP==1)/sum(TP==1)
sum(GS==2 & TP==1) % n presymp-carriers baseline
sum(GS==2 & TP==1)/sum(TP==1)
sum(GS==3 & TP==1) % n    symp-carriers baseline
sum(GS==3 & TP==1)/sum(TP==1)

% Baseline age non-carriers
mean(age(GS==1 & age~=9999 & TP==1))
std(age(GS==1 & age~=9999 & TP==1))

% Baseline age presymp carriers
mean(age(GS==2 & age~=9999 & TP==1))
std(age(GS==2 & age~=9999 & TP==1))

% ttest age
Sample1     = age(GS==1 & age~=9999 & TP==1);
Sample2     = age(GS==2 & age~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)

% ttest age between with/without follow-up
Sample1     = age(HasFU==1 & age~=9999 & TP==1);
Sample2     = age(HasFU==0 & age~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)

% Baseline age symp carriers
mean(age(GS==3 & age~=9999 & TP==1))
std(age(GS==3 & age~=9999 & TP==1))

% Baseline sex non-carriers
sum(GS==1 & sex==2 & TP==1)
sum(GS==1 & sex==2 & TP==1)/sum(GS==1 & TP==1)
 
% Baseline sex presymp carriers
sum(GS==2 & sex==2 & TP==1)
sum(GS==2 & sex==2 & TP==1)/sum(GS==1 & TP==1)
 
% Chi-square sex
n1          = sum(GS==1 & sex==2 & TP==1);
n2          = sum(GS==2 & sex==2 & TP==1);
N1          = sum(GS==1 & TP==1);
N2          = sum(GS==2 & TP==1);

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2);


% Chi-square sex between with/without follow-up
n1          = sum(HasFU==1 & sex==2 & TP==1);
n2          = sum(HasFU==0 & sex==2 & TP==1);
N1          = sum(HasFU==1 & TP==1);
N2          = sum(HasFU==0 & TP==1);

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2);

% Baseline sex symp carriers
sum(GS==3 & sex==2 & TP==1)
sum(GS==3 & sex==2 & TP==1)/sum(GS==1 & TP==1)


% Baseline Hand non-carriers
sum(GS==1 & Hand==1 & TP==1)
sum(GS==1 & Hand==1 & TP==1)/sum(GS==1 & TP==1)
 
% Baseline Hand presymp carriers
sum(GS==2 & Hand==1 & TP==1)
sum(GS==2 & Hand==1 & TP==1)/sum(GS==2 & TP==1)
 
% Baseline Hand symp carriers
sum(GS==3 & Hand==1 & TP==1)
sum(GS==3 & Hand==1 & TP==1)/sum(GS==3 & TP==1)

% Chi-square Handedness
n1          = sum(GS==1 & Hand==1 & TP==1);
n2          = sum(GS==2 & Hand==1 & TP==1);
N1          = sum(GS==1 & TP==1);
N2          = sum(GS==2 & TP==1);

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2);

% Chi-square Handedness between with/without follow-up
n1          = sum(HasFU==1 & Hand==1 & TP==1);
n2          = sum(HasFU==0 & Hand==1 & TP==1);
N1          = sum(HasFU==1 & TP==1);
N2          = sum(HasFU==0 & TP==1);

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2);


% Baseline Education non-carriers
mean(Education(GS==1 & TP==1))
 std(Education(GS==1 & TP==1))
 
% Baseline Education presymp carriers
mean(Education(GS==2 & TP==1))
 std(Education(GS==2 & TP==1))
 
% ttest Education
Sample1     = Education(GS==1 & Education~=9999 & TP==1);
Sample2     = Education(GS==2 & Education~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2) 

% ttest Education between with/without follow-up
Sample1     = Education(HasFU==1 & Education~=9999 & TP==1);
Sample2     = Education(HasFU==0 & Education~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)

% Baseline Education symp carriers
mean(Education(GS==3 & TP==1))
 std(Education(GS==3 & TP==1))

  
% Baseline Yrs_AAO non-carriers
sum(GS==1 & Yrs_AAO<-20 & TP==1)
sum(GS==1 & Yrs_AAO<-20 & TP==1)/sum(GS==1 & TP==1)

sum(GS==1 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1)
sum(GS==1 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1)/sum(GS==1 & TP==1)

sum(GS==1 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1)
sum(GS==1 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1)/sum(GS==1 & TP==1)
 
sum(GS==1 & Yrs_AAO>=0 & TP==1)
sum(GS==1 & Yrs_AAO>=0 & TP==1)/sum(GS==1 & TP==1)

mean(Yrs_AAO(GS==1 & TP==1))
 std(Yrs_AAO(GS==1 & TP==1))

% Chi-square Yrs_AAO brackets
n1          = sum(GS==1 & Yrs_AAO<-20 & TP==1);
n2          = sum(GS==2 & Yrs_AAO<-20 & TP==1);

n1          = sum(GS==1 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1);
n2          = sum(GS==2 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1);

n1          = sum(GS==1 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1);
n2          = sum(GS==2 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1);

n1          = sum(GS==1 & Yrs_AAO>=0 & TP==1);
n2          = sum(GS==2 & Yrs_AAO>=0 & TP==1);

N1          = sum(GS==1 & TP==1);
N2          = sum(GS==2 & TP==1);

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2); 
 
 
 
% ttest Yrs_AAO
Sample1     = Yrs_AAO(GS==1 & Yrs_AAO~=9999 & TP==1);
Sample2     = Yrs_AAO(GS==2 & Yrs_AAO~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)  
 
% ttest Yrs_AAO between with/without follow-up
Sample1     = Yrs_AAO(HasFU==1 & Yrs_AAO~=9999 & TP==1);
Sample2     = Yrs_AAO(HasFU==0 & Yrs_AAO~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2) 


% Baseline Yrs_AAO presympt-carriers
sum(GS==2 & Yrs_AAO<-20 & TP==1)
sum(GS==2 & Yrs_AAO<-20 & TP==1)/sum(GS==2 & TP==1)
 
sum(GS==2 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1)
sum(GS==2 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1)/sum(GS==2 & TP==1)
 
sum(GS==2 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1)
sum(GS==2 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1)/sum(GS==2 & TP==1)
 
sum(GS==2 & Yrs_AAO>=0 & TP==1)
sum(GS==2 & Yrs_AAO>=0 & TP==1)/sum(GS==2 & TP==1)
 
mean(Yrs_AAO(GS==2 & TP==1))
 std(Yrs_AAO(GS==2 & TP==1))


% Baseline Yrs_AAO sympt-carriers
sum(GS==3 & Yrs_AAO<-20 & TP==1)
sum(GS==3 & Yrs_AAO<-20 & TP==1)/sum(GS==3 & TP==1)
 
sum(GS==3 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1)
sum(GS==3 & Yrs_AAO>=-20 & Yrs_AAO<-10 & TP==1)/sum(GS==3 & TP==1)
 
sum(GS==3 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1)
sum(GS==3 & Yrs_AAO>=-10 & Yrs_AAO<0 & TP==1)/sum(GS==3 & TP==1)
 
sum(GS==3 & Yrs_AAO>=0 & TP==1)
sum(GS==3 & Yrs_AAO>=0 & TP==1)/sum(GS==3 & TP==1)
 
mean(Yrs_AAO(GS==3 & TP==1))
 std(Yrs_AAO(GS==3 & TP==1))

% Baseline mutation non-carriers
sum(GS==1 & Mutation==1 & TP==1)
sum(GS==1 & Mutation==1 & TP==1)/sum(GS==1 & TP==1)

sum(GS==1 & Mutation==2 & TP==1)
sum(GS==1 & Mutation==2 & TP==1)/sum(GS==1 & TP==1)

sum(GS==1 & Mutation==3 & TP==1)
sum(GS==1 & Mutation==3 & TP==1)/sum(GS==1 & TP==1)

% Baseline mutation presymp-carriers
sum(GS==2 & Mutation==1 & TP==1)
sum(GS==2 & Mutation==1 & TP==1)/sum(GS==2 & TP==1)

sum(GS==2 & Mutation==2 & TP==1)
sum(GS==2 & Mutation==2 & TP==1)/sum(GS==2 & TP==1)

sum(GS==2 & Mutation==3 & TP==1)
sum(GS==2 & Mutation==3 & TP==1)/sum(GS==2 & TP==1)

% Baseline mutation symp-carriers
sum(GS==3 & Mutation==1 & TP==1)
sum(GS==3 & Mutation==1 & TP==1)/sum(GS==3 & TP==1)

sum(GS==3 & Mutation==2 & TP==1)
sum(GS==3 & Mutation==2 & TP==1)/sum(GS==3 & TP==1)

sum(GS==3 & Mutation==3 & TP==1)
sum(GS==3 & Mutation==3 & TP==1)/sum(GS==3 & TP==1)


% Baseline MMSE non-carriers
xASL_stat_MeanNan(MMSE(GS==1 & TP==1))
 xASL_stat_StdNan(MMSE(GS==1 & TP==1))

% Baseline MMSE presympt-carriers
xASL_stat_MeanNan(MMSE(GS==2 & TP==1))
 xASL_stat_StdNan(MMSE(GS==2 & TP==1))
 
 % Baseline MMSE sympt-carriers
xASL_stat_MeanNan(MMSE(GS==3 & TP==1))
 xASL_stat_StdNan(MMSE(GS==3 & TP==1))
 
 % ttest MMSE
Sample1     = MMSE(GS==1 & MMSE~=9999 & TP==1);
Sample2     = MMSE(GS==2 & MMSE~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)  
 
% ttest MMSE between with/without follow-up
Sample1     = MMSE(HasFU==1 & MMSE~=9999 & TP==1);
Sample2     = MMSE(HasFU==0 & MMSE~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)  


 % Baseline CBI non-carriers
xASL_stat_MeanNan(Cambr_Behav_Invent(GS==1 & TP==1))
 xASL_stat_StdNan(Cambr_Behav_Invent(GS==1 & TP==1))

% Baseline CBI presympt-carriers
xASL_stat_MeanNan(Cambr_Behav_Invent(GS==2 & TP==1))
 xASL_stat_StdNan(Cambr_Behav_Invent(GS==2 & TP==1))
 
 % Baseline CBI sympt-carriers
xASL_stat_MeanNan(Cambr_Behav_Invent(GS==3 & TP==1))
 xASL_stat_StdNan(Cambr_Behav_Invent(GS==3 & TP==1))
 
 
 % ttest CBI
Sample1     = Cambr_Behav_Invent(GS==1 & Cambr_Behav_Invent~=9999 & TP==1);
Sample2     = Cambr_Behav_Invent(GS==2 & Cambr_Behav_Invent~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)  

% ttest CBI between with/without follow-up
Sample1     = Cambr_Behav_Invent(HasFU==1 & Cambr_Behav_Invent~=9999 & TP==1);
Sample2     = Cambr_Behav_Invent(HasFU==0 & Cambr_Behav_Invent~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)  


  % Baseline FTD-rs non-carriers
xASL_stat_MeanNan(FTD_rate_score(GS==1 & TP==1))
 xASL_stat_StdNan(FTD_rate_score(GS==1 & TP==1))

% Baseline FTD-rs presympt-carriers
xASL_stat_MeanNan(FTD_rate_score(GS==2 & TP==1))
 xASL_stat_StdNan(FTD_rate_score(GS==2 & TP==1))
 
 % Baseline FTD-rs sympt-carriers
xASL_stat_MeanNan(FTD_rate_score(GS==3 & TP==1))
 xASL_stat_StdNan(FTD_rate_score(GS==3 & TP==1))
 
 % ttest FTD-rs
Sample1     = FTD_rate_score(GS==1 & FTD_rate_score~=9999 & TP==1);
Sample2     = FTD_rate_score(GS==2 & FTD_rate_score~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2) 

% ttest FTD-rs between with/without follow-up
Sample1     = FTD_rate_score(HasFU==1 & FTD_rate_score~=9999 & TP==1);
Sample2     = FTD_rate_score(HasFU==0 & FTD_rate_score~=9999 & TP==1);
[H P CI STATS]   = ttestExploreASL2(Sample1,Sample2)   
 
 
% Chi-square mutation type 
n1          = sum(GS==1 & Mutation==3 & TP==1);
n2          = sum(GS==2 & Mutation==3 & TP==1);

N1          = sum(GS==1 & TP==1);
N2          = sum(GS==2 & TP==1);

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2)


% Chi-square nFollowUp scans (TP 2)
n1          = 55;
n2          = 43;

N1          = 113;
N2          = 107;

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2);

% Chi-square nFollowUp scans (TP 3)
n1          = 3;
n2          = 4;

N1          = 113;
N2          = 107;

x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2);
