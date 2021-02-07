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

OccSide                             = x.S.SetsID([1:2:end-1],14);

TICA_L_spatialCoV                   = x.S.SetsID(:, 9);
TICA_R_spatialCoV                   = x.S.SetsID(:,11);

ICA_diff_SpatialCoV                 = TICA_L_spatialCoV([1:2:end-1],1)-TICA_R_spatialCoV([1:2:end-1],1);
ICA_flip_SpatialCoV                 = ICA_diff_SpatialCoV;

AI_CoV_ICA                          = (TICA_L_spatialCoV-TICA_R_spatialCoV)./(0.5.*(TICA_L_spatialCoV+TICA_R_spatialCoV));
AI_CoV_ICA                          = AI_CoV_ICA([1:2:end-1]);

ICA_flip_SpatialCoV(OccSide==2)     = -ICA_flip_SpatialCoV(OccSide==2);
AI_CoV_ICA(OccSide==2)              = -AI_CoV_ICA(OccSide==2); % flip all occluded to same side

mean(ICA_diff_SpatialCoV)
std(ICA_diff_SpatialCoV)

mean(ICA_flip_SpatialCoV)
std(ICA_flip_SpatialCoV)


mean(AI_CoV_ICA)
std(AI_CoV_ICA)




Av_SpatCoV                          = (TICA_L_spatialCoV([1:2:end-1],1) + TICA_R_spatialCoV([1:2:end-1],1) )./2;

[coef, pval]                        = corr(AI_CoV_Pred,Av_SpatCoV)
[coef, pval]                        = corr(ICA_occ_SpatialCoV(:,3),Av_SpatCoV)
