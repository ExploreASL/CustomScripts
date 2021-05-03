Folder = '/Users/henk/surfdrive/HolidayPics/CICERO_Nolan/analysis/Population';

GroupA = {'4V_ICA-L_C3T-S002_1'; '4V_ICA-L_C3T-S003_1';...
    '4V_ICA-L_C3T-S04_1'; '4V_ICA-L_C3T-S005_1'};

GroupB = {'4V_ICA-L_C3T-S006_1'; '4V_ICA-L_C3T-S007_1';...
    '4V_ICA-L_C3T-S008_1'; '4V_ICA-L_C3T-S009_1'};

% OPEN THESE GROUPS AND COPY PASTE


for iGroupA=1:numel(GroupA)
    GroupA{iGroupA} = fullfile(Folder, [GroupA{iGroupA} '.nii']);
end

for iGroupB=1:numel(GroupB)
    GroupB{iGroupB} = fullfile(Folder, [GroupB{iGroupB} '.nii']);
end

DiceCoeff = xASL_stat_PairwiseDice(GroupA, GroupB);

% Let's say this gives the output:
ans =

    0.8319
    0.6874
    0.6233
    0.7252
    0.7125
    0.7432
    0.7589
    0.7513
    0.8552
    0.6713
    0.5760
    0.7082
    
% and we regard 80% as perfect overlap (==same regions), so we allow 20%
% variability.

% then the H0 would be max(0.8-DiceCoeff, 0)
% with one-sample t-test

max(0.8-DiceCoeff, 0)

ans =

         0
    0.1126
    0.1767
    0.0748
    0.0875
    0.0568
    0.0411
    0.0487
         0
    0.1287
    0.2240
    0.0918