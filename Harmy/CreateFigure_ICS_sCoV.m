%% Admin
% With = with stenosis
% Without = without stenosis

x = ExploreASL_Master('',0);

x.S.TraSlices       = x.S.slices;
x.S.Square          = 0;
x.S.ConcatSliceDims = 0;

%% Define paths
TemplateDir = 'C:\BackupWork\ASL\Harmy\analysis_Harmy\Population\Templates';
PopDir = 'C:\BackupWork\ASL\Harmy\analysis_Harmy\Population';

Path{1} = fullfile(PopDir,'qCBF_untreated_HD340_1_ASL_1.nii'); % SubWithoutPath
Path{2} = fullfile(PopDir,'qCBF_untreated_HD373_1_ASL_1.nii'); % SubWithPath
Path{3} = fullfile(TemplateDir,'CBF_untreated_StenosisYesNo_No_bs-mean.nii'); % PopWithoutPath
Path{4} = fullfile(TemplateDir,'CBF_untreated_StenosisYesNo_Yes_bs-mean.nii'); % PopWithPath

%% Create Figures
for iP=1:4
    IM{iP} = xASL_io_Nifti2Im(Path{iP});
    IM{iP} = xASL_vis_TransformData2View(IM{iP}, x);
end

figure(1);imshow([IM{1} IM{2}],[0 125],'InitialMagnification',200,'border','tight');
figure(2);imshow([IM{3} IM{4}],[0 75],'Colormap',x.S.jet256,'InitialMagnification',200,'border','tight');
