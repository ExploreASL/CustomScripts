%% Admin/ Load Data

if ispc
    x=ExploreASL_Initialize('F:\Archive_ASL\Unilateral_Stenosis\analysis\DATA_PAR_BFC_asymmetry_Analysis.m');
else
    x=ExploreASL_Initialize('/Volumes/iboysoft_ntfs_disk4s2_/Archive_ASL/Unilateral_Stenosis/analysis/DATA_PAR_BFC_asymmetry_Analysis.m');
end

InclData = ones(size(x.S.SetsID,1),1);
InclData(2:2:end) = 0; % only fingertapping off
InclData(1:6) = 0; % exclude first 3, these have background suppression artifact
                             % in the lowest slices
x.SUBJECTS = x.SUBJECTS(4:end);
x.nSubjects = length(x.SUBJECTS);
InclData = logical(InclData);

iAge = find(cellfun(@(x) strcmp(x,'Age'), x.S.SetsName));
iSex = find(cellfun(@(x) strcmp(x,'Sex'), x.S.SetsName));
iOccSide = find(cellfun(@(x) strcmp(x,'OcclusionSide'), x.S.SetsName));
iStenosisGrade_L = find(cellfun(@(x) strcmp(x,'LeftStenosisGrade'), x.S.SetsName));
iStenosisGrade_R = find(cellfun(@(x) strcmp(x,'RightStenosisGrade'), x.S.SetsName));
iCBF_L = find(cellfun(@(x) strcmp(x,'Left_ICA_CBF'), x.S.SetsName));
iCBF_R = find(cellfun(@(x) strcmp(x,'Right_ICA_CBF'), x.S.SetsName));
iCoV_L = find(cellfun(@(x) strcmp(x,'Left_ICA_CoV'), x.S.SetsName));
iCoV_R = find(cellfun(@(x) strcmp(x,'Right_ICA_CoV'), x.S.SetsName));
iCBF_Up_L = find(cellfun(@(x) strcmp(x,'UpperSlices_Left_ICA_CBF'), x.S.SetsName));
iCBF_Low_L = find(cellfun(@(x) strcmp(x,'LowerSlices_Left_ICA_CBF'), x.S.SetsName));
iCBF_Up_R = find(cellfun(@(x) strcmp(x,'UpperSlices_Right_ICA_CBF'), x.S.SetsName));
iCBF_Low_R = find(cellfun(@(x) strcmp(x,'LowerSlices_Right_ICA_CBF'), x.S.SetsName));
iCoV_Up_L = find(cellfun(@(x) strcmp(x,'UpperSlices_Left_ICA_CoV'), x.S.SetsName));
iCoV_Low_L = find(cellfun(@(x) strcmp(x,'LowerSlices_Left_ICA_CoV'), x.S.SetsName));
iCoV_Up_R = find(cellfun(@(x) strcmp(x,'UpperSlices_Right_ICA_CoV'), x.S.SetsName));
iCoV_Low_R = find(cellfun(@(x) strcmp(x,'LowerSlices_Right_ICA_CoV'), x.S.SetsName));

Age = x.S.SetsID(InclData, iAge);
Sex = x.S.SetsID(InclData,iSex);
OccSide = x.S.SetsID(InclData,iOccSide);

%% Prepare CBF & CoV
CBFfactor = 100/60; % 1.67, scale to 60 first

% script loops over CBF (1) & spatial CoV (2)
Left_ICA{1} = x.S.SetsID(InclData,iCBF_L) ./ CBFfactor;
RightICA{1} = x.S.SetsID(InclData,iCBF_R) ./ CBFfactor;
Left_ICA{2} = x.S.SetsID(InclData,iCoV_L).*100; %  left ICA spatial CoV (%)
RightICA{2} = x.S.SetsID(InclData,iCoV_R).*100; % right ICA spatial CoV (%)

% %% Do the same for lower half
% Left_ICA{1} = x.S.SetsID(InclData,iCBF_Low_L) ./ CBFfactor;
% RightICA{1} = x.S.SetsID(InclData,iCBF_Low_R) ./ CBFfactor;
% Left_ICA{2} = x.S.SetsID(InclData,iCoV_Low_L).*100; %  left ICA spatial CoV (%)
% RightICA{2} = x.S.SetsID(InclData,iCoV_Low_R).*100; % right ICA spatial CoV (%)
% 
% %% Do the same for upper half
% Left_ICA{1} = x.S.SetsID(InclData,iCBF_Up_L) ./ CBFfactor;
% RightICA{1} = x.S.SetsID(InclData,iCBF_Up_R) ./ CBFfactor;
% Left_ICA{2} = x.S.SetsID(InclData,iCoV_Up_L).*100; %  left ICA spatial CoV (%)
% RightICA{2} = x.S.SetsID(InclData,iCoV_Up_R).*100; % right ICA spatial CoV (%)

%% StenosisGrade
StenosisGradeLeft = x.S.SetsID(InclData,iStenosisGrade_L);
StenosisGradeRight = x.S.SetsID(InclData,iStenosisGrade_R);

[h,pval] = xASL_stat_ttest(StenosisGradeLeft, StenosisGradeRight); % signtest


for iSubject=1:length(StenosisGradeLeft)
    StenosisGradeLeft(iSubject,1) = str2num(x.S.SetsOptions{iStenosisGrade_L}{StenosisGradeLeft(iSubject,1)});
    StenosisGradeRight(iSubject,1) = str2num(x.S.SetsOptions{iStenosisGrade_R}{StenosisGradeRight(iSubject,1)});
end

clear StenosisGradeOcc

% Flip StenosisGrade for occlusion side
for iSubject=1:length(OccSide)
    if  OccSide(iSubject)==1
        StenosisGradeOcc(iSubject,1) = StenosisGradeLeft(iSubject,1);
        StenosisGradeOcc(iSubject,2) = StenosisGradeRight(iSubject,1);
    else
        StenosisGradeOcc(iSubject,1) = StenosisGradeRight(iSubject,1);
        StenosisGradeOcc(iSubject,2) = StenosisGradeLeft(iSubject,1);        
    end
end  


NameData = {'CBF' 'spatial CoV'};
xLabelPrint = {'Cerebral blood flow (mL/100g/min)' 'Spatial CoV (%)'};
axisN = {[40 120 0 25] [40 160 0 25]};

for iPar=1:2
    clear X1 N1 X2 N2
    
    %% Flip ICA for occlusion side
    for iSubject=1:length(OccSide)
        if  OccSide(iSubject)==1
            ICA_occ{iPar}(iSubject,1) = Left_ICA{iPar}(iSubject,1);
            ICA_occ{iPar}(iSubject,2) = RightICA{iPar}(iSubject,1);
        else
            ICA_occ{iPar}(iSubject,1) = RightICA{iPar}(iSubject,1);
            ICA_occ{iPar}(iSubject,2) = Left_ICA{iPar}(iSubject,1);        
        end
    end    

    % calculate average bilateral
    Av_ICA{iPar}                              = (Left_ICA{iPar} + RightICA{iPar} )./2;    
    % calculate AI left-right (without signflipping)
    AI_ICA_LR{iPar}                           = (Left_ICA{iPar}-RightICA{iPar})./(0.5.*(Left_ICA{iPar}+RightICA{iPar}));
    AI_ICA_occ{iPar}                          = AI_ICA_LR{iPar};
    % signflip AI for occlusion side
    AI_ICA_occ{iPar}(OccSide==2)              = -AI_ICA_occ{iPar}(OccSide==2);


    % correlation average spatial CoV with asymmetry
    [coef_AI_av(iPar), pval_AI_av(iPar)]        = corr(AI_ICA_occ{iPar},Av_ICA{iPar}, 'type','Spearman')
%     [coef_AI_av(iPar), pval_AI_av(iPar)]        = corr(AI_ICA_occ{iPar},Av_ICA{iPar}) % 'type','Spearman'
    % ttest left-right
    [h_LR(iPar),pval_LR(iPar)]                  = signtest( AI_ICA_LR{iPar} ) % 
%         [h_LR(iPar),pval_LR(iPar)]                  = xASL_stat_ttest( AI_ICA_LR{iPar} ) % signtest
    % ttest occluded-non-occluded
    [h_occ(iPar),pval_occ(iPar)]                = signtest(AI_ICA_occ{iPar}) % 
%         [h_occ(iPar),pval_occ(iPar)]                = xASL_stat_ttest(AI_ICA_occ{iPar}) % signtest
    % correlation stenosis of unoccluded side with asymmetry
    [coef_AI_st(iPar), pval_AI_st(iPar)]        = corr(AI_ICA_LR{iPar},StenosisGradeOcc(:,2), 'type','Spearman')
%         [coef_AI_st(iPar), pval_AI_st(iPar)]        = corr(AI_ICA_LR{iPar},StenosisGradeOcc(:,2))


    [X1 N1] = hist(ICA_occ{iPar}(:,1));
    [X2 N2] = hist(ICA_occ{iPar}(:,2));
    figure(iPar);plot(N1,X1,'r',N2,X2,'b')
    ylabel('nPatients');
    if iPar==1
        title('CBF for stenosed (blue) vs occluded (red) side');
        xlabel('CBF (mL/100g/min)');
    else
        title('sCoV for stenosed (blue) vs occluded (red) side');
        xlabel('Spatial CoV (%)');
    end
end
% axis(axisN{iD});
[X1 N1]   = hist(abs(AI_ICA_occ{1}));
[X2 N2]   = hist(abs(AI_ICA_occ{2}));
figure(3);plot(N1,X1,'b',N2,X2,'r')
title('Asymmetry indices of CBF (blue) & spatial CoV (red)');
ylabel('nPatients');
xlabel('Asymmetry index (delta/mean)');

%% Get histograms for Stenosis grades (distribution over population)
[X1 N1] = hist(StenosisGradeLeft);
[X2 N2] = hist(StenosisGradeRight);
figure(5);plot(N1,X1,'b',N2,X2,'r')
title('Stenosis grade left (blue) & right (red)');
ylabel('nPatients');
xlabel('Stenosis grade (%)');

[X1 N1] = hist(StenosisGradeOcc(:,1));
[X2 N2] = hist(StenosisGradeOcc(:,2));
figure(5);plot(N1,X1,'b',N2,X2,'r')
title('Stenosis grade occluded side (blue) & unoccluded side (red)');
ylabel('nPatients');
xlabel('Stenosis grade (%)');

%% Correlate stenosis AI (non-absolute) with CBF & sCoV AI (non-absolute)
StenosisAI = (StenosisGradeLeft-StenosisGradeRight)./(0.5.*(StenosisGradeLeft+StenosisGradeRight));
CBFAI = (Left_ICA{1}-RightICA{1})./(0.5.*(Left_ICA{1}+RightICA{1}));
sCoVAI = (Left_ICA{2}-RightICA{2})./(0.5.*(Left_ICA{2}+RightICA{2}));

figure(6);plot(StenosisAI,CBFAI,'b.'); % ,StenosisAI,sCoVAI,'r.'
title('Correlation Stenosis AI with CBF (blue)'); %  & spatial CoV (red)
ylabel('CBF AI (Left-Right)');
xlabel('Stenosis AI (Left-Right)');
[coef, pval] = corr(StenosisAI,CBFAI) % 'type','Spearman'

figure(7);plot(StenosisAI,sCoVAI,'r.');
title('Correlation Stenosis AI with sCoV (red)');
ylabel('sCoV AI (Left-Right)');
xlabel('Stenosis AI (Left-Right)');
[coef, pval] = corr(StenosisAI,sCoVAI) % 'type','Spearman'

%% Explanation Table below: we did Left - Right. So for left-sided occlusion, we hypothesize AI_CBF < 0
%% Meaning that CBF is lower at the occluded side
%% Also, for the same left-sided occlusion, we hypothesize that AI_spatial_CoV > 0, meaning that spatial CoV
%% is higher at the occluded side

%% Create Table 1
TableN{1}(1,:) = [mean(Left_ICA{1})      std(Left_ICA{1})        mean(Left_ICA{2})         std(Left_ICA{2})];
TableN{1}(2,:) = [mean(RightICA{1})      std(RightICA{1})        mean(RightICA{2})         std(RightICA{2})];
TableN{1}(3,:) = [mean(Av_ICA{1})        std(Av_ICA{1})          mean(Av_ICA{2})           std(Av_ICA{2})];
TableN{1}(4,:) = [mean(ICA_occ{1}(:,1))  std(ICA_occ{1}(:,1))    mean(ICA_occ{2}(:,1))     std(ICA_occ{2}(:,1))];
TableN{1}(5,:) = [mean(ICA_occ{1}(:,2))  std(ICA_occ{1}(:,2))    mean(ICA_occ{2}(:,2))     std(ICA_occ{2}(:,2))];
TableN{1}(6,:) = [mean(AI_ICA_LR{1})     std(AI_ICA_LR{1})       mean(AI_ICA_LR{2})        std(AI_ICA_LR{2})].*100;
TableN{1}(7,:) = [mean(AI_ICA_occ{1})    std(AI_ICA_occ{1})      mean(AI_ICA_occ{2})       std(AI_ICA_occ{2})].*100;

TableN{1}      = round(TableN{1},1);

%% Test correlations
% [h,pval]                  = xASL_stat_ttest(ICA_occ{1}(:,1), ICA_occ{1}(:,2));
% [h,pval]                  = xASL_stat_ttest(ICA_occ{2}(:,1), ICA_occ{2}(:,2));

[h,pval]                  = signtest(ICA_occ{1}(:,1), ICA_occ{1}(:,2));
[h,pval]                  = signtest(ICA_occ{2}(:,1), ICA_occ{2}(:,2));

% Test correlation stenosis unoccluded side with AI
% [h,pval]                  = xASL_stat_ttest(StenosisGradeOcc(:,2), AI_ICA_occ{1});
% [h,pval]                  = xASL_stat_ttest(StenosisGradeOcc(:,2), AI_ICA_occ{2});
[h,pval]                  = signtest(StenosisGradeOcc(:,2), AI_ICA_occ{1});
[h,pval]                  = signtest(StenosisGradeOcc(:,2), AI_ICA_occ{2});

%% Create Table 2
TableN{2}(1,:)  = [sum(AI_ICA_LR{1}<0 & OccSide==1)   sum(AI_ICA_LR{1}<0 & OccSide==2)   sum(AI_ICA_LR{1}<0)]
TableN{2}(2,:)  = [sum(AI_ICA_LR{1}>0 & OccSide==1)   sum(AI_ICA_LR{1}>0 & OccSide==2)   sum(AI_ICA_LR{1}>0)]
TableN{2}(3,:)  = [sum(                 OccSide==1)   sum(                 OccSide==2)   sum(OccSide==1 | OccSide==2)]
TableN{2}(4,1:2)= [TableN{2}(1,1) + TableN{2}(2,2)    TableN{2}(3,3)];
TableN{2}(4,3)  = (TableN{2}(4,1) / TableN{2}(4,2))*100;

TableN{2}(5,:)  = [sum(AI_ICA_LR{2}>0 & OccSide==1)   sum(AI_ICA_LR{2}>0 & OccSide==2)   sum(AI_ICA_LR{2}>0)]
TableN{2}(6,:)  = [sum(AI_ICA_LR{2}<0 & OccSide==1)   sum(AI_ICA_LR{2}<0 & OccSide==2)   sum(AI_ICA_LR{2}<0)]
TableN{2}(7,:)  = [sum(                 OccSide==1)   sum(                 OccSide==2)   sum(OccSide==1 | OccSide==2)]
TableN{2}(8,1:2)= [TableN{2}(5,1) + TableN{2}(6,2)    TableN{2}(7,3)];
TableN{2}(8,3)  = (TableN{2}(8,1) / TableN{2}(8,2))*100;

