TP1_crushed = CBF(Session==1 & TimePoint==1);
TP1_ncrushed = CBF(Session==2 & TimePoint==1);
TP2_crushed = CBF(Session==1 & TimePoint==2);
TP2_ncrushed = CBF(Session==2 & TimePoint==2);

[N_TP1_c, X_TP1_c]      = hist(TP1_crushed);
[N_TP1_nc, X_TP1_nc]    = hist(TP1_ncrushed);
[N_TP2_c, X_TP2_c]      = hist(TP2_crushed);
[N_TP2_nc, X_TP2_nc]    = hist(TP2_ncrushed);

figure(1);
hold on;

subplot(2,2,1);
plot(X_TP1_c, N_TP1_c/sum(N_TP1_c)*100);
xlabel('CBF crushed baseline (mL/100g/min)');
ylabel('Probability (%)');

subplot(2,2,2);
plot(X_TP1_nc, N_TP1_nc/sum(N_TP1_nc)*100);
xlabel('CBF non-crushed baseline (mL/100g/min)');
ylabel('Probability (%)');


subplot(2,2,3);
plot(X_TP2_c, N_TP2_c/sum(N_TP2_c)*100);
xlabel('CBF crushed follow-up (mL/100g/min)');
ylabel('Probability (%)');

subplot(2,2,4);
plot(X_TP2_nc, N_TP2_nc/sum(N_TP2_nc)*100);
xlabel('CBF non-crushed follow-up (mL/100g/min)');
ylabel('Probability (%)');

TP1_crushed = SliceReadoutMat(Session==1 & TimePoint==1);
TP1_ncrushed = SliceReadoutMat(Session==2 & TimePoint==1);
TP2_crushed = SliceReadoutMat(Session==1 & TimePoint==2);
TP2_ncrushed = SliceReadoutMat(Session==2 & TimePoint==2);

unique(TP1_crushed)
unique(TP1_ncrushed)
unique(TP2_crushed)
unique(TP2_ncrushed)
