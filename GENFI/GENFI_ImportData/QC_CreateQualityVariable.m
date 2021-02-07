%% Create quality variable
clear Quality
load('C:\Backup\ASL\GENFI\GENFI_DF2\QC3_SpatialCoV&visualQC.mat');

Quality     = QualityGood2;

for iQ=1:length(Quality)
    Quality{iQ,2}   = 1;
end

Quality(end+1:end+length(QualityAcceptable2),1)    = QualityAcceptable2;

for iQ=1:length(QualityAcceptable2)
    Quality{length(QualityGood2)+iQ,2}   = 2;
end