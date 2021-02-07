clear X N Motion
iMotSet     = 11;
iCohortSet  =  5;
Motion=x.S.SetsID(:,iMotSet);
[X(:,1),N(:,1)]=hist(Motion);
Cohort=x.S.SetsID(:,iCohortSet);
[X(:,2),N(:,2)]=hist(Motion(Cohort==1));
[X(:,3),N(:,3)]=hist(Motion(Cohort==2));
[X(:,4),N(:,4)]=hist(Motion(Cohort==3));
figure(1);plot(N(:,2),X(:,2),'r',N(:,3),X(:,3),'g',N(:,4),X(:,4),'b')
title(['Motion for ' x.S.SetsOptions{iCohortSet}{1} ' (red) & ' x.S.SetsOptions{iCohortSet}{2} ' (green) & ' x.S.SetsOptions{iCohortSet}{3} ' (blue)']);
axis([0 0.5 0 15]);
ylabel('nParticipants');
xlabel('Mean head motion over total ASL scan (mm)');

MedianMotion    = median(Motion);
MadMotion       = mad(Motion);
Threshold1      = MedianMotion+1*MadMotion;
Threshold2      = MedianMotion+2*MadMotion;

MediocreList    = Motion>Threshold1 & Motion<Threshold2;
PoorList        = Motion>Threshold2;

for iS=1:x.nSubjects
    FinalQC{iS,1}    = x.SUBJECTS{iS};
    if      PoorList(iS)==1
            FinalQC{iS,2} = '3Poor';
    elseif  MediocreList(iS)==1
            FinalQC{iS,2} = '2Mediocre';
    else
            FinalQC{iS,2} = '1Good';
    end
end

% Motion results corrected visually:
% 142 from mediocre to poor
% 235 from poor to mediocre
% 244 from mediocre to poor

for iS=1:x.nSubjects
    if      contains(FinalQC{iS,2},'3Poor')
            PoorList(iS)    =1;
            MediocreList(iS)=0;
    elseif  contains(FinalQC{iS,2},'2Mediocre')
            MediocreList(iS)=1;
            PoorList(iS)    =0;
    else
            PoorList(iS)    = 0;
            MediocreList(iS)= 0;
    end
end

ExclAll1         = sum(MediocreList) / numel(Motion);
ExclUsers1       = sum(MediocreList & Cohort==1) / sum(Cohort==1);
ExclPrevious1    = sum(MediocreList & Cohort==2) / sum(Cohort==2);
ExclNonUsers1    = sum(MediocreList & Cohort==3) / sum(Cohort==3);

ExclAll2         = sum(PoorList) / numel(Motion);
ExclUsers2       = sum(PoorList & Cohort==1) / sum(Cohort==1);
ExclPrevious2    = sum(PoorList & Cohort==2) / sum(Cohort==2);
ExclNonUsers2    = sum(PoorList & Cohort==3) / sum(Cohort==3);

%% Create FinalQC_GoodBad (dichotomous inclusion parameter)
FinalQC_InclExcl = FinalQC;
for iL=1:length(FinalQC)
    if      strcmp(FinalQC{iL,2},'1Good') || strcmp(FinalQC{iL,2},'2Mediocre')
            FinalQC_InclExcl{iL,2}  = 1;
    elseif  strcmp(FinalQC{iL,2},'3Poor')
            FinalQC_InclExcl{iL,2}  = 0;
    else
            error('Unknown');
    end
end

save('C:\Backup\ASL\BoleStudien\Bolestudie\FinalQC_InclExcl.mat','FinalQC_InclExcl');
save('C:\Backup\ASL\BoleStudien\Bolestudie\FinalQC.mat','FinalQC');

 
%% Check correlation visual QC & head motion QC
% for iQ=1:length(QualityControl)
%     if      contains(QualityControl{iQ,2},'Good')
%             QCn(iQ,1)   = 1;
%     elseif  contains(QualityControl{iQ,2},'Mediocre')
%             QCn(iQ,1)   = 2;
%     elseif  contains(QualityControl{iQ,2},'Poor')
%             QCn(iQ,1)   = 3;
%     else
%             error('Wrong term');
%     end
%     
%     if      contains(VisualQC_Inge_HJ{iQ,2},'Good')
%             QCn(iQ,2)   = 1;
%     elseif  contains(VisualQC_Inge_HJ{iQ,2},'Average')
%             QCn(iQ,2)   = 2;
%     elseif  contains(VisualQC_Inge_HJ{iQ,2},'Poor')
%             QCn(iQ,2)   = 3;
%     else
%             error('Wrong term');
%     end    
% end    
%     
% [RHO,PVAL] = corr(QCn(:,1),QCn(:,2));