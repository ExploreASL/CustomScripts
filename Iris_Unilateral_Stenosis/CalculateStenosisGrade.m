for iF=1:62
    if  x.S.SetsID(iF,10)==1
        StenosisGrade(iF,1)     = x.S.SetsID(iF,9);
        StenosisGrade(iF,2)     = x.S.SetsID(iF,11);
    else
        StenosisGrade(iF,1)     = x.S.SetsID(iF,11);
        StenosisGrade(iF,2)     = x.S.SetsID(iF, 9);        
    end
end

mean(StenosisGrade(:,1))
std(StenosisGrade(:,1))

mean(StenosisGrade(:,2))
std(StenosisGrade(:,2))
