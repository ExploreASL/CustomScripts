%% Hct input Sleep study multiple sessions

for iSubject=1:40
    for iSession=1:3
        Hematocrit{ ((iSubject-1)*3)+iSession ,1}   = [num2str(hctTemp(iSubject,1)) '_ASL_' num2str(iSession)];
        Hematocrit{ ((iSubject-1)*3)+iSession ,2}   = hctTemp(iSubject,iSession+1);
    end
end