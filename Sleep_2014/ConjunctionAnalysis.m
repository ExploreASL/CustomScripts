Rdir        = 'C:\Backup\ASL\SleepStudy\analysis2\Population\StatsMaps\ASL\ConjunctionAnalysis';

% p0.01;



NameList     = {'Session_2 vs. Session_1' 'Session_3 vs. Session_2 within cohort 1'};  % 'Session_3 vs. Session_2 within cohort 2'
pFileN       = {'spmTclusterP0.001P0.05_session ' 'spmTclusterP0.001P0.05_session '};
pValue       = {'P0.001'}; % 'P0.01'
ConjNr       = 2.^((1:length(NameList))-1);

for pV=1:length(pValue)
    clear IM
    for iN=1:length(NameList)
        clear tIM
        FullPath            = fullfile(Rdir, [pFileN{pV} NameList{iN} '.nii']);
        tIM                 = xASL_io_Nifti2Im(FullPath);
        tIM(isnan(tIM))     = 0;
        tIM                 = single(logical(tIM));
        IM(:,:,:,iN)        = tIM.*ConjNr(iN);
    end

    ConjIM{pV}              = sum(IM,4);

    SavePath{pV}            = fullfile(Rdir, ['ConjunctionAnalysis_' pValue{pV}]);
    xASL_io_SaveNifti( FullPath, SavePath{pV}, ConjIM{pV},[],0);
end

%% Figure used in Sleep Paper
x.S.CorSlices   = [];
x.S.SagSlices   = [];
x.S.TraSlices   = 34:4:34+15*4;
[ x ]           = xASL_init_PopulationSettings( x );

for pV=1:length(pValue)
    LabelIM{pV}         = xASL_vis_TransformData2View( ConjIM{pV}, x);
    LabelIM_Clr{pV}     = xASL_im_ProjectLabelsOverData(x.background_view_clr(:,:,1), LabelIM{pV}, x, 1, 2);
    figure(pV);imshow(LabelIM_Clr{pV},'border','tight','InitialMagnification',200)
end
