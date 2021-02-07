%% Here we check which subjects we added for the second analysis, in which we include
%  all subjects, rather than only the current users & controls (i.e. also previous users)

ListN=1;
for iL=1:length(New.MeanMotion)
    Inclusion{iL,1}=New.MeanMotion{iL,1};
    FoundN=0;
    for iK=1:length(Old.MeanMotion)
        if  strcmp(Old.MeanMotion{iK,1},Inclusion{iL,1})
            FoundN=1;
        end
    end
    if  FoundN     
        Inclusion{iL,2}='BothAnalyses';
    else
        Inclusion{iL,2}='SecondOnlyAnalysis';
        List2{ListN,1}=Inclusion{iL,1};
        ListN=ListN+1;
    end
end
            
save('Inclusion.mat','Inclusion');
save('List2.mat','List2');