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

InclData                = ones(length(symbols.SETSID),1);
InclData(2:2:end)       = 0; % only fingertapping off
InclData(25*2-1)        = 0; % has no data
InclData                = logical(InclData);

Age                     = symbols.SETSID(InclData, 5);
Sex                     = symbols.SETSID(InclData,17);
OccSide                 = symbols.SETSID(InclData,15);

CBFfactor               = 2.382737619;

% script loops over CBF (1) & spatial CoV (2)
Left_ICA{1}             = symbols.SETSID(InclData, 9);
RightICA{1}             = symbols.SETSID(InclData,11);
Left_ICA{2}             = symbols.SETSID(InclData,10).*100; %  left ICA spatial CoV (%)
RightICA{2}             = symbols.SETSID(InclData,12).*100; % right ICA spatial CoV (%)



%% Calculate asymmetry    


% Swap ICA for occlusion side, for t-test
for iS=1:length(OccSide)
    if  OccSide(iS)==1
        ICA_occ_SpatialCoV(iS,1)   = TICA_L_spatialCoV(iS,1);
        ICA_occ_SpatialCoV(iS,2)   = TICA_R_spatialCoV(iS,1);
    else
        ICA_occ_SpatialCoV(iS,1)   = TICA_R_spatialCoV(iS,1);
        ICA_occ_SpatialCoV(iS,2)   = TICA_L_spatialCoV(iS,1);        
    end
end    
    

% calculate AI for unswapped spatial CoV
AI_CoV_ICA                              = (TICA_L_spatialCoV-TICA_R_spatialCoV)./(0.5.*(TICA_L_spatialCoV+TICA_R_spatialCoV));
% signflip AI for occlusion side
AI_CoV_ICA(OccSide==2)                  = -AI_CoV_ICA(OccSide==2);
% calculate average spatial CoV
Av_SpatCoV                              = (TICA_L_spatialCoV + TICA_R_spatialCoV )./2;

[coef, pval]                            = corr(AI_CoV_Pred,Av_SpatCoV) % correlation average spatial CoV with asymmetry
[h,p,ci,stats]                          = ttestExploreASL(AI_CoV_ICA)



[X1 N1]   = hist(ICA_occ_CBF(:,1)./CBFfactor);
[X2 N2]   = hist(ICA_occ_CBF(:,2)./CBFfactor);
figure(1);plot(N1,X1,'r',N2,X2,'b')
title('Mean ICA CBF of occluded (red) & stenosed side (blue)');
ylabel('nPatients');
xlabel('Cerebral blood flow (mL/100g/min)');
axis([40 120 0 25]);

[X1 N1]   = hist(ICA_occ_SpatialCoV(:,1));
[X2 N2]   = hist(ICA_occ_SpatialCoV(:,2));
figure(2);plot(N1,X1,'r',N2,X2,'b')
title('ICA spatial CoV of occluded (blue) & stenosed side (red)');
ylabel('nPatients');
xlabel('Spatial CoV (%)');
axis([40 160 0 25]);




LeftOcc     = symbols.SETSID(:,14)==1;
RightOcc    = symbols.SETSID(:,14)==2;

piet = RightOcc & symbols.SETSID(:,9)>0;
piet = piet([1:2:end-1],1);





