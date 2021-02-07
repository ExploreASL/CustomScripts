%% Correlation mean control/M0 with CBF
%  Effect background suppression on label

BrainMask   = 'C:\ExploreASL\Maps\ICBM152NL2009\brainmask.nii';
BrainMask   = xASL_nifti(BrainMask);
BrainMask   = BrainMask.dat(:,:,:);


FileType    = {'M0' 'mean_control' 'qCBF_untreated'};

for iS=1:x.nSubjects
    for iF=1:3
        clear FileName tIM
        FileName            = fullfile(x.D.PopDir, [FileType{iF} '_' x.SUBJECTS{iS} '_ASL_1.nii']);
        FileList{iS,iF}     = FileName;
        tIM                 = xASL_nifti(FileName);
        tIM                 = tIM.dat(:,:,:);
        
        IM{iF}(iS,1)        = xASL_stat_MeanNan(tIM(logical(BrainMask)));
    end
end

M0Ratio     = IM{1}./IM{2};

figure(1);plot(M0Ratio,IM{3}, '.')
xlabel('M0/Control');
ylabel('CBF');
axIs([1.2 1.5 20 60])

List        = IM{3}<60;

[coef, pval] = corr(M0Ratio(List), IM{3}(List))

piet=M0Ratio(List);

piet=IM{3}(List);

dip_image([tIM BrainMask])
