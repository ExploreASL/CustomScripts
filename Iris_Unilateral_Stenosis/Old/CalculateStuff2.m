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

for iS=1:x.nSubjects
    if  x.S.SetsID(iS,6)==1
        ICA_occ_CBF(iS,1)   = TICA_L_CBF(2*iS-1,1);
        ICA_occ_CBF(iS,2)   = TICA_R_CBF(2*iS-1,1);
        
        ins_occ_CBF(iS,1)   = TinsulaL_CBF(2*iS-1,1);
        ins_occ_CBF(iS,2)   = TinsulaR_CBF(2*iS-1,1);
        
        ICA_occ_SpatialCoV(iS,1)   = TICA_L_spatialCoV(2*iS-1,1);
        ICA_occ_SpatialCoV(iS,2)   = TICA_R_spatialCoV(2*iS-1,1);
        
        ins_occ_SpatialCoV(iS,1)   = TinsulaL_spatialCoV(2*iS-1,1);
        ins_occ_SpatialCoV(iS,2)   = TinsulaR_spatialCoV(2*iS-1,1);        
    else
        ICA_occ_CBF(iS,1)   = TICA_R_CBF(2*iS-1,1);
        ICA_occ_CBF(iS,2)   = TICA_L_CBF(2*iS-1,1);        
        
        ins_occ_CBF(iS,1)   = TinsulaR_CBF(2*iS-1,1);
        ins_occ_CBF(iS,2)   = TinsulaL_CBF(2*iS-1,1);     
        
        ICA_occ_SpatialCoV(iS,1)   = TICA_R_spatialCoV(2*iS-1,1);
        ICA_occ_SpatialCoV(iS,2)   = TICA_L_spatialCoV(2*iS-1,1);        
        
        ins_occ_SpatialCoV(iS,1)   = TinsulaR_spatialCoV(2*iS-1,1);
        ins_occ_SpatialCoV(iS,2)   = TinsulaL_spatialCoV(2*iS-1,1);         
    end
end    
    
AI_CBF_ICA  = (TICA_L_CBF-TICA_R_CBF)./(0.5.*(TICA_L_CBF+TICA_R_CBF));
AI_CBF_ins  = (TinsulaL_CBF-TinsulaR_CBF)./(0.5.*(TinsulaL_CBF+TinsulaR_CBF));
AI_CoV_ICA  = (TICA_L_spatialCoV-TICA_R_spatialCoV)./(0.5.*(TICA_L_spatialCoV+TICA_R_spatialCoV));
AI_CoV_ins  = (TinsulaL_spatialCoV-TinsulaR_spatialCoV)./(0.5.*(TinsulaL_spatialCoV+TinsulaR_spatialCoV));

OccSide     = x.S.SetsID(:,6);

% Calculations CoV

ICA_spatial_CoV_all                 = TICA_L_spatialCoV;
ICA_spatial_CoV_all(end+1:end+62)   = TICA_R_spatialCoV;

mean(ICA_spatial_CoV_all)
std(ICA_spatial_CoV_all)


(mean(AI_CoV_ICA(OccSide==2))-mean(AI_CoV_ICA(OccSide==1)))/2
(std(AI_CoV_ICA(OccSide==2))+std(AI_CoV_ICA(OccSide==1)))/2

% Calculations CBF 

ICA_CBF_all                 = TICA_L_CBF./CBFfactor;
ICA_CBF_all(end+1:end+62)   = TICA_R_CBF./CBFfactor;

mean(ICA_CBF_all)
std(ICA_CBF_all)

(mean(AI_CBF_ICA(OccSide==2))-mean(AI_CBF_ICA(OccSide==1)))/2
(std(AI_CoV_ICA(OccSide==2))+std(AI_CoV_ICA(OccSide==1)))/2

AI_CBF_ICA_OccSide  = AI_CBF_ICA;
AI_CBF_ICA_OccSide(OccSide==1)  = -AI_CBF_ICA_OccSide(OccSide==1);

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

[X1 N1]   = hist(ins_occ_CBF(:,1)./CBFfactor);
[X2 N2]   = hist(ins_occ_CBF(:,2)./CBFfactor);
figure(3);plot(N1,X1,'r',N2,X2,'b')
title('Mean insular CBF of occluded (blue) & stenosed side (red)');
ylabel('nPatients');
xlabel('Cerebral blood flow (mL/100g/min)');
axis([40 120 0 25]);

[X1 N1]   = hist(ins_occ_SpatialCoV(:,1).*100);
[X2 N2]   = hist(ins_occ_SpatialCoV(:,2).*100);
figure(4);plot(N1,X1,'r',N2,X2,'b')
title('Insular spatial CoV of occluded (blue) & stenosed side (red)');
ylabel('nPatients');
xlabel('Spatial CoV (%)');
axis([40 180 0 25]);

% Calculate Stenosis Asymmetry

StenosisAI  = (x.S.SetsID(:,5)-x.S.SetsID(:,7)) ./ (0.5.*(x.S.SetsID(:,5)+x.S.SetsID(:,7)));
[X N]   = hist(StenosisAI);
figure(1);plot(N,X)

[coef, pval] = corr(StenosisAI, x.S.SetsID(:,3))

figure(1);plot(StenosisAI, x.S.SetsID(:,3),'.')
xlabel('Stenosis asymmetry');
ylabel('Spatial CoV asymmetry');

figure(1);plot(x.S.SetsID(:,6),StenosisAI,'.')
title('Variability stenosis asymmetry')
xlabel('Occlusion left (1) or right (2)');
ylabel('Stenosis lateralization')

figure(1);plot(x.S.SetsID(:,6),x.S.SetsID(:,3),'.')
title('Variability stenosis asymmetry')
xlabel('Occlusion left (1) or right (2)');
ylabel('Spatial CoV AI')



x.S.SetsName

sum(x.S.SetsID(:,6)==1 & x.S.SetsID(:,3)<0)
sum(x.S.SetsID(:,6)==2)

x.S.SetsID(:,6) % 1= left, 2=right
x.S.SetsID(:,5)

LeftOcc     = x.S.SetsID(:,6)==1;
RightOcc    = x.S.SetsID(:,6)==2;

L_StenosisGrade     = x.S.SetsID(:,5);
R_StenosisGrade     = x.S.SetsID(:,7);

std(L_StenosisGrade(RightOcc))
std(R_StenosisGrade(LeftOcc))

piet = RightOcc & x.S.SetsID(:,3)>0;
piet = piet([1:2:end-1],1);





