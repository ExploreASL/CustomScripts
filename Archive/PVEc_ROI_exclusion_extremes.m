piet=gwcbf{iAI}*gwpv{iAI}'-CBF{iAI}';
[X N]   = hist(piet);
figure(1);plot(N,X)


% For GM
GMmask  = GMmap>0.7 & TempCurrentMask & isfinite(temp);

[X N]   = hist(temp(GMmask));
figure(1);plot(N,X)
median(temp(GMmask))
xASL_stat_MadNan(temp(GMmask))
LoThrGM   = median(temp(GMmask))- 1.96.*xASL_stat_MadNan(temp(GMmask));
HiThrGM   = median(temp(GMmask))+ 1.96.*xASL_stat_MadNan(temp(GMmask));

% Same for WM
WMmask  = WMmap>0.7 & TempCurrentMask & isfinite(temp);

[X N]   = hist(temp(WMmask));
figure(1);plot(N,X)
median(temp(WMmask))
xASL_stat_MadNan(temp(WMmask))
LoThrWM   = median(temp(WMmask))- 1.96.*xASL_stat_MadNan(temp(WMmask));
HiThrWM   = median(temp(WMmask))+ 1.96.*xASL_stat_MadNan(temp(WMmask));

% % Same for CSF
% CSFmask  = CSFmap>0.05 & TempCurrentMask & isfinite(temp);
% 
% [X N]   = hist(temp(CSFmask));
% figure(1);plot(N,X)
% median(temp(CSFmask))
% xASL_stat_MadNan(temp(CSFmask))
% LoThrCSF   = median(temp(CSFmask))- 1.96.*xASL_stat_MadNan(temp(CSFmask));
% HiThrCSF   = median(temp(CSFmask))+ 1.96.*xASL_stat_MadNan(temp(CSFmask));

LowestThr = min([LoThrGM LoThrWM]);
HighestThr= max([HiThrGM HiThrWM]);

NewMask     = TempCurrentMask & isfinite(temp) & temp>LowestThr & temp<HighestThr;

% Redo PVEc
clear CBF gwpv
CBF{iAI}                        = temp(  NewMask );
gwpv{iAI}(:,1)                  = GMmap( NewMask );
gwpv{iAI}(:,2)                  = WMmap( NewMask );
gwcbf{iAI}                      = (CBF{iAI}')*pinv(gwpv{iAI}');
