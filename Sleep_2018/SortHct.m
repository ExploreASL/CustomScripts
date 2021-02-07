load('C:\Backup\ASL\Sleep_2018\analysis\Age.mat');

iL = 1;

for iH=1:length(OtherStruct)
    for iT=1:4
        Subj = [xASL_num2str(OtherStruct{iH,1}) '_' xASL_num2str(iT)];
        Hematocrit{iL,1} = Subj;
        Hematocrit{iL,2} = xASL_num2str(OtherStruct{iH,iT+1});        
        iL = iL+1;
    end
end

save('C:\Backup\ASL\Sleep_2018\analysis\Hematocrit.mat','Hematocrit');