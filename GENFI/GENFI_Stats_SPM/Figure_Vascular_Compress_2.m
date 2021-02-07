InValues    = [1:1:1000];
Thresh      = 187.1295.*0.5526;
OutValues   = InValues;
OutValues(OutValues>Thresh) = (OutValues(OutValues>Thresh)-Thresh).^0.675+Thresh;


figure(7);plot([1:1:200],[1:1:200],'r',InValues,OutValues,'b')
axis([0 200 0 200]);
xlabel('GM CBF before vascular signal compression (mL/100g/min)');
ylabel('GM CBF after  vascular signal compression (mL/100g/min)');

SaveFile   = fullfile( 'C:\Users\amcuser\Desktop\Figure', '6_Graph.eps');
print(gcf,'-depsc',SaveFile);