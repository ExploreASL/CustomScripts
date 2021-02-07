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

CBFfactor              = 2.382737619;
    
%% Calculate asymmetry    

TICA_L_spatialCoV   = x.S.SetsID(:, 9);
TICA_R_spatialCoV   = x.S.SetsID(:,11);

for iS=1:x.nSubjects
    if  x.S.SetsID(iS,14)==1
                
        ICA_occ_SpatialCoV(iS,1)   = TICA_L_spatialCoV(2*iS-1,1);
        ICA_occ_SpatialCoV(iS,2)   = TICA_R_spatialCoV(2*iS-1,1);
          
    else
        
        ICA_occ_SpatialCoV(iS,1)   = TICA_R_spatialCoV(2*iS-1,1);
        ICA_occ_SpatialCoV(iS,2)   = TICA_L_spatialCoV(2*iS-1,1);        
              
    end
end    
    
AI_CoV_ICA       = (TICA_L_spatialCoV-TICA_R_spatialCoV)./(0.5.*(TICA_L_spatialCoV+TICA_R_spatialCoV));
AI_CoV_Pred      = AI_CoV_ICA([1:2:end-1]);

AI_CoV_Pred(OccSide([1:2:end-1])==2)     = -AI_CoV_Pred(OccSide([1:2:end-1])==2);

Av_SpatCoV       = (TICA_L_spatialCoV([1:2:end-1],1) + TICA_R_spatialCoV([1:2:end-1],1) )./2;

[coef, pval] = corr(AI_CoV_Pred,Av_SpatCoV)
[coef, pval] = corr(ICA_occ_SpatialCoV(:,3),Av_SpatCoV)

OccSide     = x.S.SetsID(:,14);

% Calculations CoV

ICA_spatial_CoV_all                 = TICA_L_spatialCoV;
ICA_spatial_CoV_all(end+1:end+62)   = TICA_R_spatialCoV;

mean(ICA_spatial_CoV_all)
std(ICA_spatial_CoV_all)

(mean(AI_CoV_ICA(OccSide==2))-mean(AI_CoV_ICA(OccSide==1)))./2
(std(AI_CoV_ICA(OccSide==2))+std(AI_CoV_ICA(OccSide==1)))./2


(std(AI_CoV_ICA(OccSide==2))+std(AI_CoV_ICA(OccSide==1)))/2
AI_CoV_ICA_OccSide  = AI_CoV_ICA;
AI_CoV_ICA_OccSide(OccSide==1)  = -AI_CoV_ICA_OccSide(OccSide==1);

[h,p,ci,stats] = ttestExploreASL(AI_CoV_ICA_OccSide)




[X1 N1]   = hist(ICA_occ_CBF(:,1)./CBFfactor);
[X2 N2]   = hist(ICA_occ_CBF(:,2)./CBFfactor);
figure(1);plot(N1,X1,'r',N2,X2,'b')
title('Mean ICA CBF of occluded (blue) & stenosed side (red)');
ylabel('nPatients');
xlabel('Cerebral blood flow (mL/100g/min)');
axis([40 120 0 25]);

[X1 N1]   = hist(ICA_occ_SpatialCoV(:,1).*100);
[X2 N2]   = hist(ICA_occ_SpatialCoV(:,2).*100);
figure(2);plot(N1,X1,'r',N2,X2,'b')
title('ICA spatial CoV of occluded (blue) & stenosed side (red)');
ylabel('nPatients');
xlabel('Spatial CoV (%)');
axis([40 180 0 25]);




LeftOcc     = x.S.SetsID(:,14)==1;
RightOcc    = x.S.SetsID(:,14)==2;

piet = RightOcc & x.S.SetsID(:,9)>0;
piet = piet([1:2:end-1],1);





