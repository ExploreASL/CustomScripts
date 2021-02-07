x = ExploreASL_Master('',0);

clear IM_Mean IM_SD

%% Define paths to NIfTIs
% M0-T1w only
PathsAre{1} = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/ComparisonRegistration_OASIS_Biograph51010Syngo_B18P/M0_T1w/Population/Templates/CBF_bs-mean_Unmasked.nii';
PathsAre{2} = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/ComparisonRegistration_OASIS_Biograph51010Syngo_B18P/M0_T1w/Population/Templates/CBF_bs-sd_Unmasked.nii';

% force CBF-pGM
PathsAre{3} = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/ComparisonRegistration_OASIS_Biograph51010Syngo_B18P/CBF_pGM/Population/Templates/CBF_bs-mean_Unmasked.nii';
PathsAre{4} = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/ComparisonRegistration_OASIS_Biograph51010Syngo_B18P/CBF_pGM/Population/Templates/CBF_bs-sd_Unmasked.nii';

% ExploreASL default
PathsAre{5} = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/ComparisonRegistration_OASIS_Biograph51010Syngo_B18P/ExploreASL_Default/Population/Templates/CBF_bs-mean_Unmasked.nii';
PathsAre{6} = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/ComparisonRegistration_OASIS_Biograph51010Syngo_B18P/ExploreASL_Default/Population/Templates/CBF_bs-sd_Unmasked.nii';

for iNii=1:length(PathsAre)/2
    IM_Mean(:,:,:,iNii) = xASL_io_Nifti2Im(PathsAre{iNii*2-1});
    IM_SD(:,:,:,iNii) = xASL_io_Nifti2Im(PathsAre{iNii*2});
end

%% Window-leveling & visualization options
IM_Mean(IM_Mean<0) = 0;
IM_Mean(IM_Mean>50) = 50;

IM_SD(IM_SD<0) = 0;
IM_SD(IM_SD>70) = 70;

x.S.TraSlices = 49;
x.S.CorSlices = 85;
x.S.SagSlices = 61;
x.S.ConcatSliceDims = 0;
x.S.bCrop = -7;

clear ImOut_Mean ImOut_SD
for iNii=1:length(PathsAre)/2
    ImOut_Mean{iNii} = xASL_vis_CreateVisualFig(x, IM_Mean(:,:,:,iNii), [], [], [], x.S.gray, [], [], [], [], []);
    ImOut_SD{iNii} = xASL_vis_CreateVisualFig(x, IM_SD(:,:,:,iNii), [], [], [], x.S.gray, [], [], [], [], []);
end

Fig1 = [ImOut_Mean{1}, ImOut_Mean{2}, ImOut_Mean{3}];
Fig2 = [ImOut_SD{1}, ImOut_SD{2}, ImOut_SD{3}];

figure(1);imshow([ImOut_Mean{1}(:,:,1), ImOut_Mean{2}(:,:,1), ImOut_Mean{3}(:,:,1)])
figure(2);imshow([ImOut_SD{1}, ImOut_SD{2}, ImOut_SD{3}])
figure(3);imshow([Fig1, Fig2],'InitialMagnification',250)
