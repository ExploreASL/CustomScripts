IM1     = [0.5:0.5:50];
IM2     = ones(1,100).*50;
% blue fuzzy Tanimoto
% red  fuzzy Dice
figure(1);plot(IM1,IM1./IM2,'b',IM1,IM1./((IM1+IM2)./2) ,'r',IM1,(IM1+IM2)./100-0.25 ,'g')
xlabel('CBF value image1 (mL/100g/min)');
ylabel('Coefficient');