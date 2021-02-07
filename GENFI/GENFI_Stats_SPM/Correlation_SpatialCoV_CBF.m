for iP=2 %:size(piet,2)
    figure(iP);plot(reallog(piet(:,1)),piet(:,iP),'b.');
    title('Correlation CBF paracingulate spatial CoV GENFI');
    xlabel('spatial CoV (logarithmic transformed)');
    ylabel('CBF (mL/100g/min');
    
    [coef(iP), pval(iP)] = corr(piet(:,1),piet(:,iP));
end