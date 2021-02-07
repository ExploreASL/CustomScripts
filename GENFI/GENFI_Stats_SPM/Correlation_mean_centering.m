CBF     = 0;
age     = 0;


[coeff pval]    = corr(age,CBF);
figure(1);plot(age,CBF,'.')
title(['r= ' num2str(coeff) ' (p=' num2str(pval) ')'])
xlabel('Not centered')

mean_center_age     = age;
mean_center_age     = mean_center_age-mean(mean_center_age);

mean_center_CBF     = CBF;
mean_center_CBF     = mean_center_CBF-mean(mean_center_CBF);

[coeff pval]    = corr(mean_center_age,mean_center_CBF);
figure(2);plot(mean_center_age,mean_center_CBF,'.')
title(['r= ' num2str(coeff) ' (p=' num2str(pval) ')'])
xlabel('Centered')