AcqTimeManualLogging    = AcqTimeManualLogging(2:end,:);

for iL=1:length(AcqTimeManualLogging)
    AcqNew{iL*3-2,1}    = AcqTimeManualLogging{iL,1};
    AcqNew{iL*3-1,1}    = AcqTimeManualLogging{iL,1};
    AcqNew{iL*3-0,1}    = AcqTimeManualLogging{iL,1};
    
    AcqNew{iL*3-2,2}    = 'ASL_1';
    AcqNew{iL*3-1,2}    = 'ASL_2';
    AcqNew{iL*3-0,2}    = 'ASL_3';
    
    AcqNew{iL*3-2,3}    = AcqTimeManualLogging{iL,2};
    AcqNew{iL*3-1,3}    = AcqTimeManualLogging{iL,3};
    AcqNew{iL*3-0,3}    = AcqTimeManualLogging{iL,4};
end

AcqTimeManualLogging    = AcqNew;