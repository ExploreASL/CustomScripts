%% Check differences absolute times

Cohort = x.S.SetsID(:,12);
AcqTime= x.S.SetsID(:,4);
Session= x.S.SetsID(:,1);

for iA=1:length(AcqTime)
    AcqN(iA,1)    = xASL_adm_ConvertTime2Nr(AcqTime(iA,1).*100);
end


% Change hours into days
AcqN                = AcqN./24;
AcqN(3:3:end)       = AcqN(3:3:end)+1;

DiffAcq                 = zeros(size(AcqN));
DiffAcq(2:3:end-1,1)    = AcqN(2:3:end-1,1) - AcqN(1:3:end-2,1);
DiffAcq(3:3:end  ,1)    = AcqN(3:3:end  ,1) - AcqN(2:3:end-1,1);

DiffAcq                 = DiffAcq.*24; % change days back to hours
DiffAcq(1:3:end-2)      = DiffAcq(2:3:end-1);

DiffAcqTimeManualLogging(1:3:length(x.SUBJECTS)*3-2,1) = x.SUBJECTS';
DiffAcqTimeManualLogging(2:3:length(x.SUBJECTS)*3-1,1) = x.SUBJECTS';
DiffAcqTimeManualLogging(3:3:length(x.SUBJECTS)*3-0,1) = x.SUBJECTS';
DiffAcqTimeManualLogging(1:3:length(x.SUBJECTS)*3-2,2) = {'ASL_1'};
DiffAcqTimeManualLogging(2:3:length(x.SUBJECTS)*3-1,2) = {'ASL_2'};
DiffAcqTimeManualLogging(3:3:length(x.SUBJECTS)*3-0,2) = {'ASL_3'};

for iL=1:length(DiffAcq)
    DiffAcqTimeManualLogging{iL,3}  = DiffAcq(iL,1);
end
save('DiffAcqTimeManualLogging','DiffAcqTimeManualLogging');

% Go back to hours
AcqN(3:3:end)       = AcqN(3:3:end)-1;
AcqN                = AcqN.*24;

% Test group differences
for iTP=1:3
    % for absolute times
    Sleepers{iTP}=AcqN(Cohort==1 & Session==iTP);
    Deprived{iTP}=AcqN(Cohort==2 & Session==iTP);
    All{iTP}     = AcqN(Session==iTP);
    xASL_adm_ConvertNr2Time(nanmean(Sleepers{iTP}))
    xASL_adm_ConvertNr2Time(nanstd(Sleepers{iTP}))
    xASL_adm_ConvertNr2Time(nanmean(Deprived{iTP}))
    xASL_adm_ConvertNr2Time(nanstd(Deprived{iTP}))
    xASL_adm_ConvertNr2Time(nanmean(All{iTP}))
    xASL_adm_ConvertNr2Time(nanstd(All{iTP}))    
    [h,p,ci,stats] = ttest2(Sleepers{iTP},Deprived{iTP})
    
    
    % for time differences
    Sleepers{iTP}=DiffAcq(Cohort==1 & Session==iTP);
    Deprived{iTP}=DiffAcq(Cohort==2 & Session==iTP);
   
    xASL_adm_ConvertNr2Time(nanmean(Sleepers{iTP}))
    xASL_adm_ConvertNr2Time(nanstd(Sleepers{iTP}))
    xASL_adm_ConvertNr2Time(nanmean(Deprived{iTP}))
    xASL_adm_ConvertNr2Time(nanstd(Deprived{iTP}))
    [h,p,ci,stats] = ttest2(Sleepers{iTP},Deprived{iTP})
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iL=1:length(DiffAcqTimeManualLogging)
    piet{iL,3}      = DiffAcqTimeManualLogging(iL,1);
end

for iL=1:length(DiffAcqTimeManualLogging)/3
    piet{iL*3-2,3}  = piet{iL*3-1,3};
end

DiffAcqTimeManualLogging    = piet;
save('DiffAcqTimeManualLogging.mat','DiffAcqTimeManualLogging');