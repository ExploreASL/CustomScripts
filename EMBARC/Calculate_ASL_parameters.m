% Calculate EMBARC ASL parameters







%% SliceTiming



% UT
minTR = 4193;
PLD = 1525;
labdur = 1650;
nSlices = 29;

SliceReadoutTime = (minTR - PLD - labdur) / (nSlices-1);

SliceTiming = 0;
SliceTiming(2:nSlices) = [1:nSlices-1].*SliceReadoutTime;
SliceTiming = round(SliceTiming./1000, 5);