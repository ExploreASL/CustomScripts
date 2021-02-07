x=ExploreASL_Master([],0);

PathASL{1} = '/Users/henk/ExploreASL/ASL/Test_DRO/analysis/Population/rT1_sub-003.nii.gz';
PathASL{2} = '/Users/henk/ExploreASL/ASL/Test_DRO/analysis/Population/qCBF_sub-003_ASL_2.nii.gz';
PathASL{3} = '/Users/henk/ExploreASL/ASL/Test_DRO/analysis/Population/qCBF_sub-003_ASL_1.nii.gz';
PathASL{4} = '/Users/henk/ExploreASL/ASL/Test_DRO/analysis/Population/SNR_sub-003_ASL_2.nii.gz';
PathASL{5} = '/Users/henk/ExploreASL/ASL/Test_DRO/analysis/Population/SNR_sub-003_ASL_1.nii.gz';


x.S.Square = 0;
x.S.ConcatSliceDims = 0;
x.S.TraSlices = x.S.slicesLarge([4 5 7 9]);

DirOut = '/Users/henk/ExploreASL/ASL/Test_DRO';
ColorMap = {x.S.gray x.S.jet256};
MaskIs = xASL_im_DilateErodeFull(x.WBmask, 'erode', xASL_im_DilateErodeSphere(5));

IM{1} = xASL_io_Nifti2Im(PathASL{1});
Figure{1} = xASL_vis_CreateVisualFig(x, IM{1}, [], [], [], x.S.gray, 0, MaskIs);

for iFig=2:3
    IM{iFig} = xASL_io_Nifti2Im(PathASL{iFig});
    IM{iFig}(IM{iFig}<0) = 0;
    IM{iFig}(IM{iFig}>150) = 150;
    
%     FigureOut = xASL_vis_TransformData2View(IM{iFig}, x);
    
    Figure{iFig} = xASL_vis_CreateVisualFig(x, IM{iFig}, [], [], [], x.S.jet256, 0, MaskIs);
end

for iFig=4:5
    IM{iFig} = xASL_io_Nifti2Im(PathASL{iFig});
    IM{iFig}(IM{iFig}<0) = 0;
    IM{iFig}(IM{iFig}>2) = 2;
    
%     FigureOut = xASL_vis_TransformData2View(IM{iFig}, x);
    
    Figure{iFig} = xASL_vis_CreateVisualFig(x, IM{iFig}, [], [], [], x.S.jet256, 0, MaskIs);
end

CompiledFig = [Figure{1}];
figure(1);imshow(CompiledFig,[],'colorbar',x.S.gray)
colorbar

%% Second iteration of this Figure for paper Bibek
x=ExploreASL_Master([],0);

PathT1 = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates/T1_bs-mean.nii';
PathASL{1} = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates/qCBF_Cohort_nci_n73_bs-mean.nii.gz';
PathASL{2} = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates/qCBF_Cohort_cind_n90_bs-mean.nii.gz';
PathASL{3} = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates/qCBF_Cohort_vcind_n67_bs-mean.nii';
PathASL{4} = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates/qCBF_Cohort_ad_n96_bs-mean.nii';
PathASL{5} = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates/qCBF_Cohort_vad_n22_bs-mean.nii';

% non-cognitive impairment
% cognitive impairment, no dementia
% vascular cognitive impairment, no dementia
% AD
% vascular dementia/ad?

DirOut = '/Users/henk/ExploreASL/ASL/Harmy/analysis_Harmy/Population/Templates';
ColorMap = {x.S.gray x.S.jet256};
MaskIs = xASL_im_DilateErodeFull(x.WBmask, 'erode', xASL_im_DilateErodeSphere(5));
CompiledFig = []; % initialize

for iFig=1:length(PathASL)
    IM{iFig} = xASL_io_Nifti2Im(PathASL{iFig});
    IM{iFig}(IM{iFig}<0) = 0;
    IM{iFig}(IM{iFig}>80) = 80;
    x.S.Square = 0;
    x.S.ConcatSliceDims = 0;
    
%     FigureOut = xASL_vis_TransformData2View(IM{iFig}, x);
    x.S.TraSlices = x.S.slicesLarge([4 5 7 9]);
    ImIn = {PathT1 IM{iFig}};
    Figure{iFig} = xASL_vis_CreateVisualFig(x, IM{iFig}, [], [], [], x.S.jet256, 0, MaskIs);
    
    CompiledFig = [CompiledFig Figure{iFig}]; % add to combined figure
end

% CompiledFig = [Figure{1} Figure{2} Figure{3} Figure{4} Figure{5}];
figure(1);imshow(CompiledFig,[])