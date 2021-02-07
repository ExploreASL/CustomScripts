%% Admin
% With = with stenosis
% Without = without stenosis

x = ExploreASL_Master('',0);

x.S.TraSlices       = x.S.slices;
x.S.Square          = 0;
x.S.ConcatSliceDims = 0;

%% Define paths
TemplateDir = '/Users/henk/ExploreASL/ASL/PreDivaFigure/Templates';
PopDir = '/Users/henk/ExploreASL/ASL/PreDivaFigure/analysis/Population';

Path{1} = fullfile(PopDir,'qCBF_171060_1_ASL_1.nii'); % TP1 example subject
Path{2} = fullfile(PopDir,'qCBF_171060_2_ASL_1.nii'); % TP2 example subject
Path{3} = fullfile(TemplateDir,'Template_CBF_TP1.nii'); % TP1 template
Path{4} = fullfile(TemplateDir,'Template_CBF_TP2.nii'); % TP2 template

%% Create Figures
for iP=1:4
    IM{iP} = xASL_io_Nifti2Im(Path{iP});
    IM{iP} = IM{iP}.*x.skull;
    IM{iP} = xASL_vis_TransformData2View(IM{iP}, x);
end

M01 = 3.7394*10^6;
M02 = 2.1412*10^5;
M0Factor = M01/M02

figure(1);imshow([IM{1} IM{2}.*M0Factor],[0 125],'InitialMagnification',250,'border','tight');
figure(2);imshow([IM{3} IM{4}],[0 125],'Colormap',x.S.jet256,'InitialMagnification',250,'border','tight');
