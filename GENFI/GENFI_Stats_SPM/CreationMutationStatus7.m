% MutationStatus7

x.S.SetsName{11}  = 'MutationStatus7';
x.S.SetsID

for iD=1:length(x.S.SetsID)
    if      x.S.SetsID(iD, 6)==1
            x.S.SetsID(iD,11)=1; % non-carriers
    elseif  x.S.SetsID(iD, 6)==2 && x.S.SetsID(iD, 7)==2
            x.S.SetsID(iD,11)=2; % pre-sympt C9ORF72
    elseif  x.S.SetsID(iD, 6)==2 && x.S.SetsID(iD, 7)==3
            x.S.SetsID(iD,11)=3; % pre-sympt GRN
    elseif  x.S.SetsID(iD, 6)==2 && x.S.SetsID(iD, 7)==4
            x.S.SetsID(iD,11)=4; % pre-sympt MAPT
    elseif  x.S.SetsID(iD, 6)==3 && x.S.SetsID(iD, 7)==2
            x.S.SetsID(iD,11)=5; % symptomatic C9ORF72
    elseif  x.S.SetsID(iD, 6)==3 && x.S.SetsID(iD, 7)==3
            x.S.SetsID(iD,11)=6; % symptomatic GRN
    elseif  x.S.SetsID(iD, 6)==3 && x.S.SetsID(iD, 7)==4
            x.S.SetsID(iD,11)=7; % symptomatic MAPT
    end
end        

clear MutationStatus7
for iD=1:length(x.S.SetsID)
    MutationStatus7{iD,1}   = x.SUBJECTS{iD};
    MutationStatus7{iD,2}   = x.S.SetsID(iD,11);
end