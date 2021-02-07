%% Get age & gender for n=12 HC RegistrationComparison

for iV=1:4
    for iN=1:12
        for iComp=2:size(TotalList,1)
            if  strcmp(TotalList{iComp,1},NAMELIST{iN,iV})
                AGE(iN,iV)      = TotalList{iComp,5};
                GENDER(iN,iV)   = TotalList{iComp,6};
                GS(iN,iV)       = TotalList{iComp,4};
            end
        end
    end
end

%% Per sequence

mean(AGE,1)
std(AGE,[],1)

sum(GENDER,1)

%% All together
mean(AGE(:))
std(AGE(:))