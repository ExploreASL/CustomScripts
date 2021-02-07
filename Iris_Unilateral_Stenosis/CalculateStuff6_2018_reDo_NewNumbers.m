
% %% Save LeftRight data
% TICA_L_spatialCoV       = 0;
% TICA_R_spatialCoV       = 0;
% TinsulaL_spatialCoV     = 0;
% TinsulaR_spatialCoV     = 0;
% 
% TICA_L_CBF       = 0;
% TICA_R_CBF       = 0;
% TinsulaL_CBF     = 0;
% TinsulaR_CBF     = 0;
% 
% WM_CBF_L            = 0;
% WM_CBF_R          = 0;
% ICA_3_R           = 0;
% ICA_3_L           = 0;
% ICA_1_L           = 0;
% ICA_1_R           = 0;
% SubjectsExcel   = {''};
% for ii=1:length(SubjectsExcel)
%     SubjectsExcel{ii,1}     = ['0' num2str(SubjectsExcel{ii,1})];
% end
% for ii=1:length(SubjectsExcel)
%     SubjectsExcel{ii,2}     = ['ASL_' num2str(SubjectsExcel{ii,2})];
% end
% 
% 
% insulaR_CBF  = insulaR_spatialCoV;
% for ii=1:62
%     insulaR_CBF{ii,3}     = TinsulaR_CBF(ii,1);
% end
%     
% save('C:\Backup\ASL\Iris_unilateral_sclerosis\analysis\insulaR_CBF.mat','insulaR_CBF');
% check
% for ii=1:62
%     if TinsulaL_spatialCoV(ii,1)~=insulaL_spatialCoV{ii,3};
%         error('piet');
%     end
% end

%% Admin/ Load Data

clear InclData Age Sex OccSide TICA_L_spatialCoV TICA_R_spatialCoV
clear ICA_occ_SpatialCoV
clear coef_AI_av pval_AI_av h_LR pval_LR h_occ pval_occ
clear ICA_occ Av_ICA AI_ICA_LR AI_ICA_occ Left_ICA RightICA TableN

InclData                = ones(length(symbols.SETSID),1);
InclData(2:2:end)       = 0; % only fingertapping off
InclData(1:6)           = 0; % exclude first 3, these have background suppression artifact
                             % in the lowest slices
symbols.SUBJECTS        = symbols.SUBJECTS(4:end);
symbols.nSubjects       = length(symbols.SUBJECTS);
InclData                = logical(InclData);


iAge                    = 5;
iSex                    = 17;
iOccSide                = 13;
iCBF_L                  = 10;
iCBF_R                  = 15;
iCoV_L                  = 11;
iCoV_R                  = 16;
iStenosisGrade_L        = 9;
iStenosisGrade_R        = 14;

Age                     = symbols.SETSID(InclData, 5);
Sex                     = symbols.SETSID(InclData,17);
OccSide                 = symbols.SETSID(InclData,13);

% Current Mean CBF = 100, scale to 60 first

CBFfactor               = 100/60; % 1.67

% script loops over CBF (1) & spatial CoV (2)
Left_ICA{1}             = symbols.SETSID(InclData,iCBF_L) ./ CBFfactor;
RightICA{1}             = symbols.SETSID(InclData,iCBF_R) ./ CBFfactor;
Left_ICA{2}             = symbols.SETSID(InclData,iCoV_L).*100; %  left ICA spatial CoV (%)
RightICA{2}             = symbols.SETSID(InclData,iCoV_R).*100; % right ICA spatial CoV (%)

%% StenosisGrade
StenosisGradeLeft       = symbols.SETSID(InclData,iStenosisGrade_L);
StenosisGradeRight      = symbols.SETSID(InclData,iStenosisGrade_R);

[h,pval]                = ttestExploreASL( StenosisGradeLeft, StenosisGradeRight );

for iS=1:length(StenosisGradeLeft)
    StenosisGradeLeft(iS,1)     = str2num(symbols.SETSOPTIONS{iStenosisGrade_L}{StenosisGradeLeft(iS,1)});
    StenosisGradeRight(iS,1)    = str2num(symbols.SETSOPTIONS{iStenosisGrade_R}{StenosisGradeRight(iS,1)});
end

clear StenosisGradeOcc

% Flip StenosisGrade for occlusion side
for iS=1:length(OccSide)
    if  OccSide(iS)==1
        StenosisGradeOcc(iS,1)   = StenosisGradeLeft(iS,1);
        StenosisGradeOcc(iS,2)   = StenosisGradeRight(iS,1);
    else
        StenosisGradeOcc(iS,1)   = StenosisGradeRight(iS,1);
        StenosisGradeOcc(iS,2)   = StenosisGradeLeft(iS,1);        
    end
end  


NameData                = {'CBF' 'spatial CoV'};
xLabelPrint             = {'Cerebral blood flow (mL/100g/min)' 'Spatial CoV (%)'};
axisN                   = {[40 120 0 25] [40 160 0 25]};

for iD=1:2
    clear X1 N1 X2 N2
    
    %% Flip ICA for occlusion side
    for iS=1:length(OccSide)
        if  OccSide(iS)==1
            ICA_occ{iD}(iS,1)   = Left_ICA{iD}(iS,1);
            ICA_occ{iD}(iS,2)   = RightICA{iD}(iS,1);
        else
            ICA_occ{iD}(iS,1)   = RightICA{iD}(iS,1);
            ICA_occ{iD}(iS,2)   = Left_ICA{iD}(iS,1);        
        end
    end    

    % calculate average bilateral
    Av_ICA{iD}                              = (Left_ICA{iD} + RightICA{iD} )./2;    
    % calculate AI left-right (without signflipping)
    AI_ICA_LR{iD}                           = (Left_ICA{iD}-RightICA{iD})./(0.5.*(Left_ICA{iD}+RightICA{iD}));
    AI_ICA_occ{iD}                          = AI_ICA_LR{iD};
    % signflip AI for occlusion side
    AI_ICA_occ{iD}(OccSide==2)              = -AI_ICA_occ{iD}(OccSide==2);


    % correlation average spatial CoV with asymmetry
    [coef_AI_av(iD), pval_AI_av(iD)]        = corr(AI_ICA_occ{iD},Av_ICA{iD});
    % ttest left-right
    [h_LR(iD),pval_LR(iD)]                  = ttestExploreASL( AI_ICA_LR{iD} );
    % ttest occluded-non-occluded
    [h_occ(iD),pval_occ(iD)]                = ttestExploreASL(AI_ICA_occ{iD})
    % correlation stenosis of unoccluded side with asymmetry
    [coef_AI_st(iD), pval_AI_st(iD)]        = corr(AI_ICA_LR{iD},StenosisGradeOcc(:,2))
    


    [X1 N1]   = hist(ICA_occ{iD}(:,1));
    [X2 N2]   = hist(ICA_occ{iD}(:,2));
    figure(iD);plot(N1,X1,'r',N2,X2,'b')
    

end
% axis(axisN{iD});
[X1 N1]   = hist(abs(AI_ICA_occ{1}));
[X2 N2]   = hist(abs(AI_ICA_occ{2}));
figure(3);plot(N1,X1,'b',N2,X2,'r')
title(['Asymmetry indices of CBF (blue) & spatial CoV (red)']);
ylabel('nPatients');
xlabel('Asymmetry index (delta/mean)');

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
[h,pval]                  = ttestExploreASL( ICA_occ{1}(:,1), ICA_occ{1}(:,2) );
[h,pval]                  = ttestExploreASL( ICA_occ{2}(:,1), ICA_occ{2}(:,2) );

% Test correlation stenosis unoccluded side with AI
[h,pval]                  = ttestExploreASL( StenosisGradeOcc(:,2), AI_ICA_occ{1} );
[h,pval]                  = ttestExploreASL( StenosisGradeOcc(:,2), AI_ICA_occ{2} );

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


%% ------------------------------------------------------------------
%% Do MIP

for iS=1:symbols.nSubjects
    CountCode(iS,symbols.nSubjects);
    % Load data
    FilePath        = fullfile(symbols.DARTELDIR,['qCBF_untreated_' symbols.SUBJECTS{iS} '_ASL_2.nii']);

    % Flip for occlusion side
    if  OccSide(iS,1)==2
        IM(:,:,:,iS)    = flipud(xASL_im_ndnanfilter(nifti2IM(FilePath),'gauss',[1.885 1.885 1.885]));
    else
        IM(:,:,:,iS)    = xASL_im_ndnanfilter(nifti2IM(FilePath),'gauss',[1.885 1.885 1.885]);
    end
end

% CBF
MeanCBF                     = xASL_stat_MeanNan(IM,4)./1.67;
MeanCBF(MeanCBF>100)        = 100;
% MeanCBF(MeanCBF< 30)        =  30;
WB_CBF_nii                 = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\WB_CBF.nii';
save_nii_spm(symbols.RESLICEREF,WB_CBF_nii,MeanCBF.*GMmask,32,0);


clear WBMask WB_sCoV WB_MeanCoV GM_sCoV
% WB sCoV
WBMask     = nifti2IM('C:\ExploreASL\Maps\WBmaskASLnarrow.nii');

fprintf('%s','Computing kernel-wise spatial CoV...  ');
for iS=1:symbols.nSubjects
    CountCode(iS,symbols.nSubjects);
    WB_sCoV(:,:,:,iS)  = SpatialCoV_voxelwise( IM(:,:,:,iS), WBMask,[6 6 6]);
end

WB_sCoV_nii                 = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\WB_sCoV.nii';

WB_sCoV4Av                  = WB_sCoV;
WB_sCoV4Av(WB_sCoV4Av>5)    = 5;
WB_MeanCoV                  = xASL_stat_MeanNan(WB_sCoV4Av,4);

WB_MeanCoV(WB_MeanCoV>0.9)  = 0.9;

GMmask                      = nifti2IM(symbols.RESLICEREF)>0.1;

save_nii_spm(symbols.RESLICEREF,WB_sCoV_nii,WB_MeanCoV.*GMmask,32,0);

% Save stripped T1
WMmask                      = nifti2IM('C:\ExploreASL\Maps\Templates\rc2T1_ASL_res.nii')>0.1;
T1mask                      = WMmask | GMmask;

T1file                      = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\Templates\Template_mean_T1.nii';
T1fileStripped              = 'C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\Templates\Template_mean_T1_Stripped.nii';

save_nii_spm(T1file,T1fileStripped,nifti2IM(T1file).*T1mask,[],0);

% transversal slices 42,48,56,64,72,80,88,96
% cor slices 46,56,66,76,86,96,106,116
% CBF window 0-100
% CoV window 0.2-1

MaxIM   = max(IM,[],4);

dip_image([MeanIM MaxIM])