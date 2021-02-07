%% split sleepers & deprived
CBFsleepers  = TotalGMCBF(RandomZ==2);
CBFdeprived  = TotalGMCBF(RandomZ==1);

for iL=1:length(TotalGMCBF)/4
    TPfull(iL,1:4)  = TotalGMCBF( (iL-1)*4+1:(iL)*4);
end
for iL=1:length(CBFsleepers)/4
    TPsleepers(iL,1:4)  = CBFsleepers( (iL-1)*4+1:(iL)*4);
end
for iL=1:length(CBFdeprived)/4
    TPdeprived(iL,1:4)  = CBFdeprived( (iL-1)*4+1:(iL)*4);
end

%% TimePoint 1 to 2
figure(1);plot(TPfull(:,1:2)')


%% Full average for all
figure(2)

plot(nanmean(TPfull,1),'k')

%% Full for sleepers

figure(1);plot(TPsleepers');
title('Sleepers');
figure(2);plot(TPdeprived');
title('Deprived');
figure(3);plot(median(TPsleepers,1));
title('average sleepers');
figure(4);plot(median(TPdeprived,1));
title('average deprived');
