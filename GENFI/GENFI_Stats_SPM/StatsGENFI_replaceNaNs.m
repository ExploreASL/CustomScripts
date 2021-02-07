%% Stats GENFI replace NaNs

piet=x.S.CoVar(:,nGM_ICVRatio);

for iP=1:length(piet)
    if  isnan(piet(iP,1))
        piet(iP,1)  = piet(iP-1,1);
    end
end

x.S.CoVar(:,nGM_ICVRatio)     = piet;