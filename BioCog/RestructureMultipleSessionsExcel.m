%% Read excel CBF data with multiple sessions & restructure into 
%  multiple sessions horizontally instead of vertically

clear NewXLS

 [data, text, rawData]   =   xlsread(fullfile('C:\Backup\ASL\BioCog\analysis\dartel\STATS\CBF_HOcort_PVEC0', 'CBF_HOcort_PVEC0.csv'),1);
 
 NewXLS(1,1:2:size(rawData,2)*2-1)  = rawData(1,:);
 NewXLS(1,2:2:size(rawData,2)*2-0)  = rawData(1,:);
 rawData                = rawData(2:end,:);
 for iL=1:size(rawData,1)/2
     NewXLS(1+iL,1:2:size(rawData,2)*2-1)     = rawData(iL*2-1,:);
     NewXLS(1+iL,2:2:size(rawData,2)*2-0)     = rawData(iL*2-0,:);
 end