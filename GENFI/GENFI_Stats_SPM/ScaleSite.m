FileName                = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\VBA-ROI_GENFI_check_PVEC2.csv';

[data, text, rawData]   = xlsread(FileName,1);
Site=data(:,10);
UniqueSite              = unique(Site);

DataColumns             = data(:,15:19);
MeanData                = mean(DataColumns,2);

for iS=1:length(UniqueSite)
    MeanSite(iS,1)          = mean(MeanData(Site==iS));
    DataColumns(Site==iS,:) = DataColumns(Site==iS,:) ./ MeanSite(iS,1) .* 60;
end

[X N]   = hist(DataColumns);
figure(1);plot(X,N)

