
%% Select asymptomatic carriers & non-carriers

x.S.DAT

x.S.DATASETS_RESTR        = restructure_populations( x.S.DAT, x.S.SetsID(:,6) );    % 6==GeneticStatus
x.S.CoVar_RESTR           = restructure_populations( x.S.SetsID, x.S.SetsID(:,6) ); % 6==GeneticStatus

x.S.Measurements          = {'frontal_pole_R' 'orbitofrontal_cortex_anterior_insula_L' 'paracingulate_cingulate_L' 'thalamus_caudate_accumbens_L' 'paracingulate_cingulate_R' 'frontal_pole_L' 'middle_frontal_L' 'supramarginal_parietal_R'};

for iMeas=1:8 % for 8 ROIs
    clear DataRegress RHO PVAL NumIt
    
    
    for iCase=1:2
        clear fig SaveFile
        
        DataRegress{iCase}(:,1)                     = x.S.CoVar_RESTR{iCase}(:,10);        % Yrs_AAO
        DataRegress{iCase}(:,2)                     = x.S.DATASETS_RESTR{iCase}(:,iMeas); % CBF
        DataRegress{iCase}                          = sortrows( DataRegress{iCase},1 );
        
        if      iCase==1 % non-carriers==blue
                fig=figure(iCase);plot(DataRegress{iCase}(:,1),DataRegress{iCase}(:,2),'b.');
                xlabel('Yrs_AAO');
                ylabel('CBF_mL/100g/min');
                Title2Print     = ['Yrs_AAO_vs_CBF_' x.S.Measurements{iMeas} '_non-carriers'];
                title(Title2Print);
                SaveFile                                        = fullfile(x.S.StatsDir,S.output_ID,Title2Print);
                saveas( fig ,SaveFile,'jpg');                
        elseif  iCase==2 % carriers==red
                fig=figure(iCase);plot(DataRegress{iCase}(:,1),DataRegress{iCase}(:,2),'r.');
                xlabel('Yrs_AAO');
                ylabel('CBF_mL/100g/min');
                Title2Print     = ['Yrs_AAO_vs_CBF_' x.S.Measurements{iMeas} '_carriers'];
                title(Title2Print);
                SaveFile                                        = fullfile(x.S.StatsDir,S.output_ID,Title2Print);
                saveas( fig ,SaveFile,'jpg');                
        end
    end
        
    NumIt                                       = min([size(DataRegress{1},1) size(DataRegress{2},1)]);
    
    
    for iCase=1:2    
        for iT=1:NumIt
            clear t_temp R1 R2 R3 t DoF
            [RHO(iT,iCase),PVAL(iT,iCase)]          = corr( DataRegress{iCase}(1:end-iT+1,1),DataRegress{iCase}(1:end-iT+1,2) );
            % Adjust p-value for lower sample-size to keep it comparable, assuming 2-tailed
            n=NumIt;
            t_temp = RHO(iT,iCase).*sqrt((n-2)./(1-RHO(iT,iCase).^2));
            PVAL_corr(iT,iCase)                     = 2*tcdf(-abs(t_temp),n-2);
        end
    end
    
    % Hotelling's t-test
    
%     for iT=1:NumIt
%         R1      = RHO(iT,1); % Pearson correlation coefficient (r) between Yrs_AAO & CBF for non-carriers
%         R2      = RHO(iT,2); % Pearson correlation coefficient (r) between Yrs_AAO & CBF for carriers
%         R3      = -0.5;       % Pearson correlation coefficient (r) between non-carriers & carriers
% 
%         DoF     = NumIt-3;     % Degrees of Freedom = number of subjects minus 3 estimated correlation coefficients
% 
%         t       = (R1-R2) * (  ( (DoF) * (1 + R3) )^0.5 / (2 * (1-R1^2-R2^2-R3^2 + (2*R1*R2*R3) ) )^0.5   ); % calculates Hotelling's t-value
% 
%         PVAL_Hotel(iT,iCase)     = 1-tcdf(t,NumIt-3); % calculates p-value from t-distribution
%     end
        
    
    % R
    fig=figure(3);plot(flipud(DataRegress{2}(:,1)),RHO(:,1),'b.',flipud(DataRegress{2}(:,1)),RHO(:,2),'r.');
    xlabel('Yrs_AAO');
    ylabel('rho correlation Yrs_AAO CBF');
    Title2Print     = ['Interaction_rho_' x.S.Measurements{iMeas} '_Blue==non-carriers, red-carriers'];
    title(Title2Print);
    
    SaveFile                                        = fullfile(x.S.StatsDir,S.output_ID,Title2Print);
    saveas( fig ,SaveFile,'jpg');        
    
    % P
    fig=figure(3);plot(flipud(DataRegress{2}(:,1)),PVAL(:,1),'b.',flipud(DataRegress{2}(:,1)),PVAL(:,2),'r.');
    xlabel('Yrs_AAO');
    ylabel('p-value correlation Yrs_AAO CBF');
    Title2Print     = ['Interaction_P_value_' x.S.Measurements{iMeas} '_Blue==non-carriers, red-carriers'];
    title(Title2Print);
    SaveFile                                        = fullfile(x.S.StatsDir,S.output_ID,Title2Print);
    saveas( fig ,SaveFile,'jpg');
    
    % Corrected P
    fig=figure(3);plot(flipud(DataRegress{2}(:,1)),PVAL_corr(:,1),'b.',flipud(DataRegress{2}(:,1)),PVAL_corr(:,2),'r.');
    xlabel('Yrs_AAO');
    ylabel('Corrected p-value correlation Yrs_AAO CBF');
    Title2Print     = ['Interaction_P-corr_value_' x.S.Measurements{iMeas} '_Blue==non-carriers, red-carriers'];
    title(Title2Print);
    SaveFile                                        = fullfile(x.S.StatsDir,S.output_ID,Title2Print);
    saveas( fig ,SaveFile,'jpg');    
%     
%     % Corrected P-Hotel
%     fig=figure(3);plot(flipud(DataRegress{2}(:,1)),PVAL_Hotel(:,1),'b.',flipud(DataRegress{2}(:,1)),PVAL_Hotel(:,2),'r.');
%     xlabel('Yrs_AAO');
%     ylabel('Corrected PVAL_Hotel correlation Yrs_AAO CBF');
%     Title2Print     = ['Interaction_PVAL_Hotel_value_' x.S.Measurements{iMeas} '_Blue==non-carriers, red-carriers'];
%     title(Title2Print);
%     SaveFile                                        = fullfile(x.S.StatsDir,S.output_ID,Title2Print);
%     saveas( fig ,SaveFile,'jpg');        
    
    
end
    









