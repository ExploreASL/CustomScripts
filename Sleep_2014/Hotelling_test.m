for ii=1:38
    CBF1(ii,:)    = CBF(ii*3-2,:);
    CBF2(ii,:)    = CBF(ii*3-1,:);
    CBF3(ii,:)    = CBF(ii*3-0,:);
end

% for GM
CBF_Sleep{1}       = CBF1(CBF1(:,11)==1,:);
CBF_Sleep{2}       = CBF2(CBF1(:,11)==1,:);
CBF_Sleep{3}       = CBF3(CBF1(:,11)==1,:);

for ROI=1:9
    [R1 P] = CORR(CBF_Sleep{2}(:,ROI),CBF_Sleep{3}(:,ROI)) % Pearson TP1-2
    [R2 P] = CORR(CBF_Sleep{1}(:,ROI),CBF_Sleep{3}(:,ROI)) % Pearson TP2-3
    [R3 P] = CORR(CBF_Sleep{1}(:,ROI),CBF_Sleep{2}(:,ROI)) % Pearson TP1-3

    DoF     = 19-3; % Degrees of Freedom = number of subjects minus 3 estimated correlation coefficients

    t       = (R1-R2) * (  ( (DoF) * (1 + R3) )^0.5 / (2 * (1-R1^2-R2^2-R3^2 + (2*R1*R2*R3) ) )^0.5   ); % calculates Hotelling's t-value, t=2.2162

    p_value(ROI,1)       = 1-tcdf(t,DoF); % calculates p-value from t-distribution, p=0.0141
end

% [R3 P] = CORR([1:10]',[1:10]'.*2)