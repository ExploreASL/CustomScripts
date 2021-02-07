ASLsimulateFile     = fullfile( x.D.PopDir, 'ASL_simulate.dat');

if ~exist(ASLsimulateFile,'file')
    

    %% Simulate Ground-Truth data to evaluate statistical algorithm

    % Create IM with single voxel only

    IM                  = zeros(x.nSubjects,121,145,121);

    NoiseSim            = randn(x.nSubjects,1);
    SimValues           = 60.*exp(NoiseSim/5);

    [N X]               = hist(SimValues);figure(1);plot(X,N)

    % IM(IM==0)           = NaN; happens in script already

    % Clone SimValues for carriers CBF decrease with Yrs_AAO
    Yrs_AAO             = x.S.SetsID(:,15);
    CarriersSim         = SimValues-Yrs_AAO;
    [N X]               = hist(CarriersSim);figure(2);plot(X,N)

    IsCarrier           = x.S.SetsID(:,4)==1;

    AllSimData              = SimValues;
    AllSimData(IsCarrier)   = CarriersSim(IsCarrier);

    %% Reduce CBF with Yrs_AAO in presymptomatic carriers only

    figure(3);plot(Yrs_AAO(IsCarrier),AllSimData(IsCarrier), '.') % correlation for carriers
    figure(4);plot(Yrs_AAO(~IsCarrier),AllSimData(~IsCarrier), '.') % correlation for non-carriers

    IM(:,60,100,70)      = AllSimData; % [60 100 70] lies in middle of anterior cingulate


    %% Store as a memory mapped file
    fileID              =  fopen(ASLsimulateFile,'w');
    fwrite(fileID, IM, 'single');
    fclose(fileID); 


    %% This is not yet accounting for relatedness within subject or family

    % Load ASL data & check
    % min(min(min(min(ASL.Data.data  == single(IM)))))
    
    %% Simulate family relatedness
    Family              = x.S.SetsID(:,7);
    Uf                  = unique(Family);
    AdditionPerFamily   = randn(80,1)./1.5;   
    
    for iS=1:size(x.S.DAT,1)
        IndexFam                    = find(Uf==Family(iS));
        x.S.DAT(iS,60,100,70)         = x.S.DAT(iS,60,100,70)+AdditionPerFamily(IndexFam,1);
    end
    
    
    
    
    
    
    
    
    
    
    
    %% Simulate subject relatedness
    TimePoint           = x.S.SetsID(:,1);
    for iS=1:length(SubjectFactor)
        Subject(iS,1)   = SubjectFactor{iS,2};
    end
    
    Us                  = unique(Subject);
    
    for iS=1:length(Us)
        clear IndexSubj
        % Give each subject the same random value around 60
        IndexSubj       = find(Subject==iS);
        IM(IndexSubj,1) = 60.*exp(randn/5);
        
        % decrease CBF for TimePoints 2 & 3
        if  length(IndexSubj)>1
            clear InterScanTime
            for iL=1:length(LongitudinalInterval)
                if  strcmp(x.SUBJECTS{IndexSubj(1)}(1:end-1),LongitudinalInterval{iL,1}(1:end-1))
                    if  LongitudinalInterval{iL,2}==9999
                        InterScanTime       = 1.3;
                    else    InterScanTime   = LongitudinalInterval{iL,2};
                    end
                end
            end            
            
            TimeCBFdiff         = (randn-0.09)*InterScanTime*IM(IndexSubj(1),1)/10;
            TimeCBFdiff         = [1 TimeCBFdiff TimeCBFdiff*2];
            
            IM(IndexSubj,1)     = IM(IndexSubj,1)+TimeCBFdiff(1:length(IndexSubj))';
        end
    end
    
    % Clone values for carriers, let CBF decrease with Yrs_AAO
    Yrs_AAO                 = x.S.SetsID(:,15);
    CarriersSim             = IM-Yrs_AAO;
%     figure(2);plot(Yrs_AAO,CarriersSim,'.')
    
    % Apply this CBF decrease with Yrs_AAO only for carriers
    IsCarrier               = x.S.SetsID(:,4)==1;
    IM(IsCarrier)           = CarriersSim(IsCarrier);
    
    figure(3);plot(Yrs_AAO( IsCarrier),IM( IsCarrier), '.') % correlation for carriers
    figure(4);plot(Yrs_AAO(~IsCarrier),IM(~IsCarrier), '.')     
    
    % Simulate family relatedness
    Family              = x.S.SetsID(:,7);
    Uf                  = unique(Family);
    AdditionPerFamily   = randn(80,1)./1.5;   
    
    for iS=1:size(IM,1)
        IndexFam                    = find(Uf==Family(iS));
        IM(iS,1)                    = IM(iS,1)+AdditionPerFamily(IndexFam,1);
    end    
        
    
    
        
%     piet=(randn(1000,1)-0.09)*InterScanTime*IM(IndexSubj(1),1)/10;
%     [N X]   = hist(piet);
%     figure(1);plot(X,N)
    
        
        if  TimePoint(iS,1)==2 || TimePoint(iS,1)==3
            
            clear InterScanTime
            for iL=1:length(LongitudinalInterval)
                if  strcmp(x.SUBJECTS{iS}(1:end-1),LongitudinalInterval{iL,1}(1:end-1))
                    if  LongitudinalInterval{iL,2}==9999
                        InterScanTime       = 1.3;
                    else    InterScanTime   = LongitudinalInterval{iL,2};
                    end
                end
            end
            
            Subtr(iS) = (randn-0.9)*InterScanTime*S.DAT(iS,60,100,70)/10;
            
            if      TimePoint(iS,1)==2
                    x.S.DAT(iS,60,100,70)         = x.S.DAT(iS,60,100,70) - Subtr(iS);
            elseif  TimePoint(iS,1)==3
                    x.S.DAT(iS,60,100,70)         = x.S.DAT(iS,60,100,70) - (2*Subtr(iS));
            else    error('wrong timepoint');
            end
        end
    end    
    
    
    
    
end
ASL         = memmapfile(ASLsimulateFile,'Format',{'single' [x.nSubjects 121 145 121] 'data'},'Writable',true);
ASL         = memmapfile(ASLsimulateFile,'Format',{'single' [x.nSubjects 121 145 121] 'data'});
  













%% Start stats, run with & without extra scans

x.S.KISS                      = 0; 
x.LabEffNorm          = 0;
% KISS=keep it stupid simple, this skips the 1-sample t-tests,
% the ANOVAs & the covariates

x.S.PrintSPMOutput            = 1;
x.S.MultiComparisonCorrType   = 'cluster'; % OPTIONS uncorrected, FWE voxel-wise, cluster
x.S.uncorrThresh              = 0.05; % FWE threshold (clustersize in case of cluster correction)
x.S.clusterPthr               = 0.001; % cluster primary threshold

x.S.ConcatSliceDims           = 1; % 0 = vertical, 1 = horizontal
%     x.S.TraSlices                 = [30:20:90];
%     x.S.CorSlices                 = [30:20:90]; % 20+([1:25]-1).*round((97-20)/24);
%     x.S.SagSlices                 = [30:20:90];

x.S.output_ID                 = 'Simulation';
%     x.S.output_ID                 = 'CBF_clustP01_PVEc';
%     x.S.output_ID                 = 'CBF_clustP01_excludingTP3';    
%     x.S.output_ID                 = 'CBF_AI';    
x.S.TraSlices                 = [30+([1:20]-1).*round((100-30)/19)]; % 30 - 100
% MNI_coord                 = -72 + (([30+([1:20]-1).*round((100-30)/19)]-1).*1.5)'
x.S.CorSlices                 = [15+([1:20]-1).*round((130-15)/19)]; % 15 - 130
x.S.SagSlices                 = [15+([1:20]-1).*round((110-15)/19)]; % 15 - 110

ANALYZE_ASL_MAPS_statistics_SPM( x, ASL);

%% Check smoothing on single voxel
% [N X]=hist(squeeze(x.S.DAT(:,60,100,70)));
% figure(1);plot(X,N)
% klaas=squeeze(x.S.DAT(:,60,100,70));
% piet =squeeze(x.S.DAT(:,60,100,70));
% sjaak=klaas-piet; % conclusion, this part makes rounding errors that are negligible small
% mean(sjaak)==0
