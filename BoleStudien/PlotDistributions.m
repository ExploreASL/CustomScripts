SpatialCoV      = x.S.SetsID(:,13);
LifeTimeDose    = x.S.SetsID(:,11);
Motion          = x.S.SetsID(:,12);
Cohorts         = x.S.SetsID(:,5);
YearsUsage      = x.S.SetsID(:,17);

% [P{1} N{1}]=hist(SpatialCoV);
% [P{2} N{2}]=hist(SpatialCoV(Cohorts==2));
% [P{3} N{3}]=hist(SpatialCoV(Cohorts==1));

[P{1} N{1}]=hist(reallog(SpatialCoV));
[P{2} N{2}]=hist(reallog(SpatialCoV(Cohorts==2)));
[P{3} N{3}]=hist(reallog(SpatialCoV(Cohorts==1)));

figure(1);plot(N{1},P{1},'k',N{2},P{2},'b',N{3},P{3},'r')
xlabel('Spatial CoV (%)');
ylabel('nParticipants');
title('Spatial CoV for users (red) & non-users (blue)');

% 

[P{1} N{1}]=hist(LifeTimeDose);
[P{2} N{2}]=hist(LifeTimeDose(Cohorts==2));
[P{3} N{3}]=hist(LifeTimeDose(Cohorts==1));

[P{1} N{1}]=hist(reallog(1+LifeTimeDose));
[P{2} N{2}]=hist(reallog(1+LifeTimeDose(Cohorts==2)));
[P{3} N{3}]=hist(reallog(1+LifeTimeDose(Cohorts==1)));

figure(1);plot(N{1},P{1},'k',N{2},P{2},'b',N{3},P{3},'r')
xlabel('Spatial CoV (%)');
ylabel('nParticipants');
title('Spatial CoV for users (red) & non-users (blue)');

figure(1);plot(LifeTimeDose(Cohorts==2),SpatialCoV(Cohorts==2),'b.',LifeTimeDose(Cohorts==1),SpatialCoV(Cohorts==1),'r.')
axis([0 1*10^6 0.3 1])
xlabel('LifeTimeDose');
ylabel('Spatial CoV');
title('For users (red) & non-users (blue)');


figure(1);plot(YearsUsage(Cohorts==2),SpatialCoV(Cohorts==2),'b.',YearsUsage(Cohorts==1),SpatialCoV(Cohorts==1),'r.')
% axis([0 1*10^6 0.3 1])
xlabel('YearsUsage');
ylabel('Spatial CoV');
title('For users (red) & non-users (blue)');
