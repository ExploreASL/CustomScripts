%% Hotelling's t-test

R1      = -0.199; % Pearson correlation coefficient (r) between GM CBF (PV corrected) & age
R2      = -0.282; % Pearson correlation coefficient (r) between GM CBF (PV corrected) & years to AAO
R3      =  0.891; % Pearson correlation coefficient (r) between age & years to AAO

DoF     = 144-3; % Degrees of Freedom = number of subjects minus 3 estimated correlation coefficients

t       = (R1-R2) * (  ( (DoF) * (1 + R3) )^0.5 / (2 * (1-R1^2-R2^2-R3^2 + (2*R1*R2*R3) ) )^0.5   ); % calculates Hotelling's t-value, t=2.2162

p       = 1-tcdf(t,144-3); % calculates p-value from t-distribution, p=0.0141