Site            = SPM.xC(1,4).rc;
SpatialCoV      = SPM.xC(1,3).rc;
SortSite        = unique(Site);
for iS=1:length(SortSite) % Sort sites for their spatial CoV
    SortSite(iS,2)  = mean(SpatialCoV(Site==SortSite(iS)));
end
SortSite            = sortrows(SortSite,2);
iN                  = 0;
clear NewSCoV NewSite
for iS=1:length(SortSite) % Sort spatial CoV within sites
    clear temp
    temp                            = SpatialCoV(Site==SortSite(iS));
    NewSCoV(iN+1:iN+length(temp),1) = temp;
    NewSite(iN+1:iN+length(temp),1) = iS;
    iN                              = length(NewSCoV);
end
figure(1);plot(NewSite,NewSCoV,'b.');
title('Spatial CoV within Sites');
xlabel('Sites sorted by their average spatial CoV');
ylabel('Spatial CoV');