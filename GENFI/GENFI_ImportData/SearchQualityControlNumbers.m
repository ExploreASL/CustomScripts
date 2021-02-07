SumGood=0;
SumAccept=0;
SumBad=0;
SumUnusable=0;

for iS=1:length(x.SUBJECTS)
    Found=0;
    
    for iQ=1:length(QualityGood2)
        if  strcmp(x.SUBJECTS{iS},QualityGood2{iQ})
            Found=1;
        end
    end
    
    if  Found & x.S.SetsID(iS,1)==1 & x.S.SetsID(iS,4)<2
        SumGood     = SumGood+1;
        Found=0;        
    else
        
        for iQ=1:length(QualityAcceptable2)
            if  strcmp(x.SUBJECTS{iS},QualityAcceptable2{iQ})
                Found=1;
            end
        end 
    end
    
    if  Found & x.S.SetsID(iS,1)==1 & x.S.SetsID(iS,4)<2
        SumAccept=SumAccept+1;
        Found=0;
    else
        for iQ=1:length(QualityBad2)
            if  strcmp(x.SUBJECTS{iS},QualityBad2{iQ})
                Found=1;
            end
        end 
    end        
        
    if  Found & x.S.SetsID(iS,1)==1 & x.S.SetsID(iS,4)<2
        SumBad=SumBad+1;
        Found=0;
    else
        for iQ=1:length(QualityUnusable2)
            if  strcmp(x.SUBJECTS{iS},QualityUnusable2{iQ})
                Found=1;
            end
        end 
    end            
    
    if  Found & x.S.SetsID(iS,1)==1 & x.S.SetsID(iS,4)<2
        SumUnusable=SumUnusable+1;
        Found=0;
    end         
end
