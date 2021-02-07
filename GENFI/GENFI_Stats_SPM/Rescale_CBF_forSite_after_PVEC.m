CBF=0;
Site=0;

clear MeanCBF SiteList SiteMean CBFscaled

% Create mean for each site
MeanCBF     = mean(CBF,2);
SiteList    = unique(Site);
for iS=1:length(SiteList)
    SiteMean(iS,1)=mean(CBF(Site==SiteList(iS)));
end
SiteMean(:,2)   = 60./SiteMean(:,1);

for iA=1:size(CBF,1)
    CBFscaled(iA,:)     = CBF(iA,:) .* SiteMean(Site(iA),2);
end