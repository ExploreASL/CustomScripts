ExploreASL_master('',0);

StatsDir    = 'C:\Backup\ASL\Sleep_2018_pilot\ResultsPilotStudy\Final results used';

TissueType  = {'median_qCBF_untreated_Clusters_Sleep_2018_Test 1w ws-ANOVA LongitudinalTimePoint_n=40'};
RegExp      = ['^' TissueType{1} '.*PVC0\.tsv$'];
XLSpath     = xASL_adm_GetFileList(StatsDir,RegExp);

[A B]       = xASL_csv2tsv(XLSpath{1});
ClusterData = [3 6 9 12];

for iCl=1:length(ClusterData)
    Lines4Cell  = B(3:end,ClusterData(iCl));
    for iL=1:length(Lines4Cell)
        Lines4(iL)  = str2num(Lines4Cell{iL});
    end

    % reshape into 4 time points 
    clear Lines1
    for iL=1:10
        Lines1(iL,1:4)    = Lines4(iL*4-3:iL*4);
    end

    Lines2  = Lines1';

    figure(iCl);plot(Lines2)
    title(['Cluster ' num2str(iCl)]);
    xlabel('TimePoints (1:4)');
    ylabel('CBF (mL/100g/min)');
    xticks([1 2 3 4]);
    hold on

    meanLine    = mean(Lines2,2);
    STDline     = std(Lines2,[],2);

    plot(meanLine,'k-');
    hold on
    plot(meanLine+1.96*STDline,'k--');
    hold on
    plot(meanLine-1.96*STDline,'k--');
end
