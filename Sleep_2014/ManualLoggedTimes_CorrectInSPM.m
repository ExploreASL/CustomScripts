            if      IsTP1_TP2 % timing should already be fixed
            elseif  IsTP2_TP3 % Fix timing TP2-TP3 comparison
                    x.S.SetsID(1:3:end-2,iSet)  = 0;
                    x.S.SetsID(2:3:end-1,iSet)  = x.S.SetsID(3:3:end-0,iSet);
                    % Same for CoVars
                    x.S.CoVar{1}(:,iSet)        = x.S.CoVar{2}(iSet);
            elseif  IsTP1_TP3 % Fix timing TP1-TP3 comparison
                    x.S.SetsID(3:3:end  ,iSet)  = x.S.SetsID(2:3:end-1,iSet) + x.S.SetsID(3:3:end,iSet);
                    x.S.SetsID(1:3:end-2,iSet)  = x.S.SetsID(3:3:end,iSet);
                    x.S.SetsID(2:3:end-1,iSet)  = 0;
                    % Same for CoVars
                    x.S.CoVar{1}(:,iSet)        = x.S.CoVar{1}(:,iSet) + x.S.CoVar{2}(:,iSet);
                    x.S.CoVar{2}(:,iSet)        = x.S.CoVar{1}(:,iSet);
            else
                    error('Not sessions that I expected');
            end