%% motiondir

MotionDir   = 'C:\Backup\ASL\Sleep2\analysis\dartel\MOTION_ASL';
FList       = xASL_adm_GetFileList(MotionDir,'^motion_correction.*\.mat$');

clear Mot
for iL=1:length(FList)
    clear median_NDV
    load(FList{iL});
    Mot(iL,1)   = median_NDV{1,2};
end
    
size(Mot)

size(x.S.SetsID)

median(Mot(1:3:117,1) )
xASL_stat_MadNan(Mot(1:3:117,1) )

median(Mot(2:3:117,1) )
xASL_stat_MadNan(Mot(2:3:117,1) )

TP3Mot      = Mot(3:3:117,1);
TP3Mot      = TP3Mot([[1:24] [26:39]] );

ContrMotTP3 = TP3Mot(x.S.SetsID(1:3:end,2)==1);
DeprMotTP3  = TP3Mot(x.S.SetsID(1:3:end,2)==2);

median(ContrMotTP3 )
xASL_stat_MadNan( ContrMotTP3 )
median(DeprMotTP3 )
xASL_stat_MadNan( DeprMotTP3 )

TP2Mot      = Mot(2:3:117,1);
TP2Mot      = TP2Mot([[1:24] [26:39]] );

ContrMotTP2 = TP2Mot(x.S.SetsID(1:3:end,2)==1);
DeprMotTP2  = TP2Mot(x.S.SetsID(1:3:end,2)==2);

median(ContrMotTP2 )
xASL_stat_MadNan( ContrMotTP2 )
median(DeprMotTP2 )
xASL_stat_MadNan( DeprMotTP2 )

TP1Mot      = Mot(1:3:117,1);
TP1Mot      = TP1Mot([[1:24] [26:39]] );

ContrMotTP1 = TP1Mot(x.S.SetsID(1:3:end,2)==1);
DeprMotTP1  = TP1Mot(x.S.SetsID(1:3:end,2)==2);

median(ContrMotTP1 )
xASL_stat_MadNan( ContrMotTP1 )
median(DeprMotTP1 )
xASL_stat_MadNan( DeprMotTP1 )

signtest(ContrMotTP3,ContrMotTP1)
signtest(ContrMotTP3,ContrMotTP2)

signtest(DeprMotTP3,DeprMotTP1)
signtest(DeprMotTP3,DeprMotTP2)

signtest(TP2Mot,TP1Mot)

% remove n 25

size(TP3Mot)

%% Hematocrit
%% TP1

clear hematocritN
for iN=1:114
    hematocritN(iN,1)   = hematocrit{iN,3};
end

HctTP1  = hematocritN(1:3:end);

mean(HctTP1)
std(HctTP1)
    
for iH=1:size(HctTP1,1)
    T1(iH,1) = calc_blood_t1(HctTP1(iH)/100, 0.97, 3)*1000;
end

mean(T1)
std(T1)

ContrTP1    = HctTP1(x.S.SetsID(1:3:end,2)==1)
DeprTP1     = HctTP1(x.S.SetsID(1:3:end,2)==2)

mean(ContrTP1)
std(ContrTP1)

mean(DeprTP1)
std(DeprTP1)

clear T1
for iH=1:size(ContrTP1,1)
    T1(iH,1) = calc_blood_t1(ContrTP1(iH)/100, 0.97, 3)*1000;
end

clear T1
for iH=1:size(DeprTP1,1)
    T1(iH,1) = calc_blood_t1(DeprTP1(iH)/100, 0.97, 3)*1000;
end

mean(T1)
std(T1)


%% TP2

HctTP2  = hematocritN(2:3:end);

mean(HctTP2)
std(HctTP2)
    
for iH=1:size(HctTP2,1)
    T1(iH,1) = calc_blood_t1(HctTP2(iH)/100, 0.97, 3)*1000;
end

mean(T1)
std(T1)


ContrTP2    = HctTP2(x.S.SetsID(1:3:end,2)==1)
DeprTP2     = HctTP2(x.S.SetsID(1:3:end,2)==2)

mean(ContrTP2)
std(ContrTP2)

mean(DeprTP2)
std(DeprTP2)

clear T1
for iH=1:size(ContrTP2,1)
    T1(iH,1) = calc_blood_t1(ContrTP2(iH)/100, 0.97, 3)*1000;
end

clear T1
for iH=1:size(DeprTP2,1)
    T1(iH,1) = calc_blood_t1(DeprTP2(iH)/100, 0.97, 3)*1000;
end

%% TP3

HctTP3      = hematocritN(3:3:end);

ContrTP3    = HctTP3(x.S.SetsID(1:3:end,2)==1)
DeprTP3     = HctTP3(x.S.SetsID(1:3:end,2)==2)

mean(HctTP3)
std(HctTP3)

mean(ContrTP3)
std(ContrTP3)

mean(DeprTP3)
std(DeprTP3)

clear T1
for iH=1:size(HctTP3,1)
    T1(iH,1) = calc_blood_t1(HctTP3(iH)/100, 0.97, 3)*1000;
end

clear T1
for iH=1:size(ContrTP3,1)
    T1(iH,1) = calc_blood_t1(ContrTP3(iH)/100, 0.97, 3)*1000;
end

clear T1
for iH=1:size(DeprTP3,1)
    T1(iH,1) = calc_blood_t1(DeprTP3(iH)/100, 0.97, 3)*1000;
end

mean(T1)
std(T1)
