%% Plot Overview DataStructure Family Subject
% Used para-cingulate CBF (strongest effect cluster)

Yrs_AAO     = x.S.SetsID(:,11);

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

Family  = x.S.SetsID(:,7);

U   = unique(SubjectList);
Uf  = unique(Family);

%% Show SUBJECT
figure(1);
for iS=1:length(U)
    % get index first scan in multi-scan matrix
    IndexSubj   = min(find(SubjectList==iS));
    
    if      x.S.SetsID(IndexSubj,12)<2 % non-carrier
            plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'g.-');
    elseif  x.S.SetsID(IndexSubj,12)<5 % presympt carriers
            plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'r.-');
    elseif  x.S.SetsID(IndexSubj,12)<8 % sympt carriers
%             plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'r.:');        
    else    error('wrong Carrier')
    end
    hold on
end

xlabel('Years to age of expected onset of symptoms');
ylabel('CBF bilateral (para-)cingulate gyrus (mL/100g/min)');
title('Overview within-subject relatedness (connecting lines) for all scans (n=374) for pre-symptomatic carriers (red) & non-carriers (green)');


%% FAMILY
% Get many colors:
load(fullfile(x.MYPATH,'im_process','LabelColors.mat'));

% 
% colorspec = {[0.9 0.9 0.9]; [0.8 0.8 0.8]; [0.6 0.6 0.6]; ...
%   [0.4 0.4 0.4]; [0.2 0.2 0.2]};
% figure(1); cla;
% hold on
% for i = 1:5
%   plot(x,y(:, i), 'Color', colorspec{i})
% end

figure(2);
for iS=1:length(U)
    % get index first scan in multi-scan matrix
    IndexSubj   = min(find(SubjectList==iS));
    IndexFam    = find(Family(IndexSubj)==Uf);
    
    if      x.S.SetsID(IndexSubj,12)<2 % non-carrier
            plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'v-','Color',LabelClr(IndexFam,:));
    elseif  x.S.SetsID(IndexSubj,12)<5 % presympt carriers            
            plot(Yrs_AAO(SubjectList==iS),CBF(SubjectList==iS),'^-','Color',LabelClr(IndexFam,:));
    end
            
    hold on
end

xlabel('Years to age of expected onset of symptoms');
ylabel('CBF bilateral (para-)cingulate gyrus (mL/100g/min)');
title('Overview within-subject relatedness (connecting lines) & family relatedness (colors) for all scans (n=374) for pre-symptomatic carriers (up-arrow) & non-carriers (down-arrow)');

%% Calculate mean time point difference
clear TimePointCBF
for iS=1:x.nSubjects
    clear IsVolume VolumeList VolumeN IndicesAre IndexSubj
    [ IsVolume VolumeList VolumeN ] = LongRegInit( x, x.SUBJECTS{iS} );
    IndexSubj   = SubjectList(iS,1);
    TimePointCBF(IndexSubj,IsVolume)    = CBF(iS,1);
    for iL=1:length(LongitudinalInterval)
        if  strcmp(x.SUBJECTS{iS},LongitudinalInterval{iL,1})
            TimePointCBF(IndexSubj,4)  = LongitudinalInterval{iL,2};
        end
    end
end
        
clear TP2CBF
IndexN  = 1;
for iS=1:252
    if  sum(TimePointCBF(iS,1:2)==0)==0
        TP2CBF(IndexN,1:3)  = TimePointCBF(iS,[1 2 4]);
        if  TP2CBF(IndexN,3)==9999
            TP2CBF(IndexN,3)=1.3;
        end
        IndexN  = IndexN+1;        
    end
end


MeanDiff        = TP2CBF(:,1)-TP2CBF(:,2);
MeanCBF         = mean(TP2CBF(:)); % 74.8
MeanMdiff       = mean(MeanDiff); % -0.68
SDdiff          = std(MeanDiff); % 14.1

DecreasePerc    = MeanMdiff/MeanCBF; % -0.01
DecreasePercYear= DecreasePerc./TP2CBF(:,3);


[H P]           = ttestExploreASL(TP2CBF(:,1),TP2CBF(:,2));
[N X]           = hist(DecreasePercYear.*100);
figure(1);plot(X,N)
xlabel('Delta CBF2-1 for bilateral (para-)cingulate');
ylabel('Frequency');
title('Longitudinal findings, mu=-0.68, SDdiff=14.1, p=0.68');

% Simulate noise for difference TimePoints  

[N X]           = hist(randn(100000,1)./10-0.9);
figure(2);plot(X,N)


%% Calculate variability within & between families

% 1) group CBF

Family  = x.S.SetsID(:,7);
Uf      = unique(Family);

IndicesFam  = ones(length(Uf),1);
for iS=1:x.nSubjects
    IndexFam    = find(Family(iS,1)==Uf);
    CBFfam(IndicesFam(IndexFam,1),IndexFam)  = CBF(iS);
    IndicesFam(IndexFam,1)  = IndicesFam(IndexFam,1)+1;
end
    
% sort CBF values per family
for iF=1:size(CBFfam,2)
    CBFfam(:,iF)        = sort(CBFfam(:,iF),1,'descend');
    meanCBFfam(1,iF)    = mean(nonzeros(CBFfam(:,iF)));
end
    
TotalCBFfam(1,:)                    = meanCBFfam;
TotalCBFfam(2,:)                    = 0;
TotalCBFfam(3:size(CBFfam,1)+2,:)   = CBFfam;


% for the fun of it, create a figure
jet_256     = jet(256);
jet_256(1,:)= 0;
figure(1);imshow(TotalCBFfam,[],'InitialMagnification',1000)
figure(1);imshow(TotalCBFfam,[],'colormap',jet_256,'InitialMagnification',1000)
xlabel('Individual families (n=80) ->');
ylabel('CBF bilateral (para-)cingulate (mL/100g/min) ->');
title('Overview CBF variability between & within families, first row is mean for each family, for other rows each color is a single mean CBF value per subject/scan, sorted descendingly per family (n=49 largest family)');


CoV_between  = std(meanCBFfam)/mean(meanCBFfam)*100; % 21.1 %
for iF=1:size(CBFfam,2)
    CoV_within(iF,1)     = std(nonzeros(CBFfam(:,iF)))./mean(nonzeros(CBFfam(:,iF))).*100;
end

mean_within             = mean(nonzeros(CoV_within)) % (without single subject families)
sum(CoV_within==0) %% 22/80 families are 1-subject families

Ratio   = CoV_between/mean_within; % 1.27, so bit higher between-family CBF variance than within-family, so there is family relatedness. 
% but question is whether this is statistically significant, which has to
% do with the ratio effect size vs. variance, and with sample sizes within
% & between groups. Nevertheless, let's assume there is a statistically
% significant family effect (we have already modeled without a
% statistically effect)

BetweenFamilyVarianceAdjustedForWithin  = ((meanCBFfam-mean(meanCBFfam))./mean_within) + mean(meanCBFfam); % first demean, than divide by mean_within, then add mean again

[N X]   = hist(  BetweenFamilyVarianceAdjustedForWithin  );
figure(1);plot(X,N)

% if CBF values are 75, what random values do we need to multiply each
% family with per family, to create some family relatedness
% -> so we keep the original values (as within-family variability) &
% increase the between-family variability
% we should add or subtract CBF values, to make the families more different
% & within more the same, since this in independent on initial values
% (otherwise it just amplifies original variability)

CBFsim=mean(BetweenFamilyVarianceAdjustedForWithin); % simulated values
SimNoise    = randn(1000,1)./1.5; % for 80 families
CBFsim  = SimNoise+CBFsim;

[N X]   = hist(  CBFsim  );
figure(2);plot(X,N)

% anova
