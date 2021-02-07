% Calculate diff Hct
clear
for iL=1:length(hematocrit)
    MotionN(iL,1)  = hematocrit{iL,3};
end

DiffMotionN                = zeros(size(MotionN));
DiffMotionN(2:3:end-1)     = MotionN(2:3:end-1) - MotionN(1:3:end);
DiffMotionN(3:3:end  )     = MotionN(3:3:end  ) - MotionN(2:3:end-1);

DiffMotion             = hematocrit;
for iL=1:length(hematocrit)
    DiffMotion{iL,3}   = DiffMotionN(iL,1);
end


% Calculate Diff motion
clear
Motion=MeanMotion;
for iL=1:length(Motion)
    MotionN(iL,1)  = Motion{iL,3};
end

DiffMotionN                = zeros(size(MotionN));
DiffMotionN(2:3:end-1)     = MotionN(2:3:end-1) - MotionN(1:3:end);
DiffMotionN(3:3:end  )     = MotionN(3:3:end  ) - MotionN(2:3:end-1);

DiffMotion             = Motion;
for iL=1:length(Motion)
    DiffMotion{iL,3}   = DiffMotionN(iL,1);
end