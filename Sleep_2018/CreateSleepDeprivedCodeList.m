for iL=1:length(Randomization)
    Randomization{iL,1}     = ['Sub-59' num2str(Randomization{iL,1})];
end
for iL=1:length(Randomization)
    Randomization4{iL*4-3,1}     = [Randomization{iL,1} '_1'];
    Randomization4{iL*4-2,1}     = [Randomization{iL,1} '_2'];
    Randomization4{iL*4-1,1}     = [Randomization{iL,1} '_3'];
    Randomization4{iL*4-0,1}     = [Randomization{iL,1} '_4'];
    Randomization4{iL*4-3,2}     = Randomization{iL,2};
    Randomization4{iL*4-2,2}     = Randomization{iL,2};
    Randomization4{iL*4-1,2}     = Randomization{iL,2};
    Randomization4{iL*4-0,2}     = Randomization{iL,2};    
end
Randomization1=Randomization;
Randomization=Randomization4;
save('Randomization1.mat','Randomization1');
save('Randomization.mat','Randomization');