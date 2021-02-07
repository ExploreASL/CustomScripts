x = ExploreASL_Master('',0);

%% Visualization admin
x.S.ConcatSliceDims = 1;
x.S.bCrop = 0;
% x.S.Square = 0;

clear ROOT IM
ROOT = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/FeaturesDisabled_EPAD/Population/Templates'; % diseased elderly

Modalities = {{'T1_bs-mean' 'pGM_bs-mean' 'pWM_bs-mean'}...
            {'CBF_untreated_bs-mean'} {'CBF_untreated_bs-CoV'} {'SD_bs-mean'}};

% 1) T1 + pGM+pWM
% 2) CBF
% 3) bsCoV
% 4) tSD
% 5) tSNR
% 6) M0
% 7) SliceGradient

ColorScale = {{x.S.gray x.S.red x.S.blue} x.S.jet256 x.S.jet256 x.S.jet256...
            x.S.jet256 x.S.gray x.S.gray {x.S.gray x.S.jet256}};
Intens = {[0.75 0.2 0.2] [0.75 0.75] 1 1 1 1 1 1 [0.5 0.35]};
MaxClip = {[Inf Inf Inf] [Inf 0.7] 100 100 80 5 5000 7500000 [Inf 25]};

%% Create brainmask
BrainMask = xASL_io_Nifti2Im(fullfile(x.D.MapsSPMmodifiedDir, 'rbrainmask.nii'))>0.95;

bMasks3 = {BrainMask BrainMask BrainMask};
ZeroMasks3 = {ones(121,145,121) ones(121,145,121) ones(121,145,121)};
MasksAre = {ZeroMasks3 ZeroMasks3 bMasks3 bMasks3 bMasks3 bMasks3 ZeroMasks3 ZeroMasks3 ZeroMasks3};
EmptyWindow = {[] [] []};
MaxWindow = {EmptyWindow EmptyWindow EmptyWindow EmptyWindow EmptyWindow EmptyWindow...
            EmptyWindow EmptyWindow {[] 25}};

%% Create the Figure
SaveDir = '/Users/henk/Google Drive/XploreLab/ProjectsPending/ExploreASL manuscript/5_PotentialCoverNeuroimage/Slices';
bWhite = 0;
nNext = 1;
clear TotalIM TotalTotalIM

TraSlices = x.S.slices;
x.S.CorSlices = [];
x.S.SagSlices = [];
OversliceHorizontal = [0.5 0];
TransparencyBackground = 1;
TransparencyFactor = 0.85;


for iSlice=1:length(TraSlices)
    x.S.TraSlices = TraSlices(iSlice);
    for iScanType=1:2 % length(Modalities)
        clear IM Fpath Slice tIM
        for iLayer = 1:length(Modalities{iScanType})
            Fpath{iScanType}{iLayer} = fullfile(ROOT, [Modalities{iScanType}{iLayer} '.nii']);
            tIM{iLayer} = xASL_io_Nifti2Im(Fpath{iScanType}{iLayer});
            tIM{iLayer}(tIM{iLayer}>MaxClip{iScanType}(iLayer)) = MaxClip{iScanType}(iLayer);
        end
        BackgroundSlices{iScanType} = xASL_vis_CreateVisualFig(x, tIM, [], Intens{iScanType}, [], ColorScale{iScanType},false,bMasks3,bWhite, MaxWindow{iScanType});
        MaskSlices{iScanType} = logical(xASL_vis_CreateVisualFig(x, BrainMask, [], Intens{iScanType}, [], ColorScale{1},false,BrainMask,bWhite, MaxWindow{iScanType}));

        % First store already processed image part, at the right

        % Overslice
        if iScanType==1
            ForegroundSlices = BackgroundSlices{iScanType};
        elseif iScanType==2
            ForegroundSlices = xASL_vis_Overslice(ForegroundSlices, BackgroundSlices{iScanType}, ~MaskSlices{iScanType}, OversliceHorizontal, 1);
        else
            Indices = [1 size(ForegroundSlices,2)-size(BackgroundSlices{iScanType})];
            OldPart = ForegroundSlices(:,Indices(1):Indices(2),:);
            ForegroundSlices = ForegroundSlices(:,Indices(2)+1:end,:);

            ForegroundSlices = xASL_vis_Overslice(ForegroundSlices, BackgroundSlices{iScanType}, ~MaskSlices{iScanType}, OversliceHorizontal, 1);
            % Reconcatenate BackgroundSlices
            Indices = [size(OldPart,2)+1 size(OldPart,2)+size(ForegroundSlices,2)];
            OldPart(:, Indices(1):Indices(2),:) = ForegroundSlices;
            ForegroundSlices = OldPart;
        end
    end
end






        TransparencyBackground = TransparencyBackground.*TransparencyFactor;


        BackgroundIm = xASL_vis_Overslice(ForegroundIm, BackgroundIm, Mask, Overslice, TransparencyBackground);
    end

%                 figure(nNext);imshow(ThisIM,'InitialMagnification',250);% export as EPS CMYK
    FileName = fullfile(SaveDir, [Modalities{iScanType}{1} '_' xASL_num2str(nNext)]);
    xASL_vis_Imwrite(ThisIM, FileName);
    nNext = nNext+1;

end


%% Create the colorbars
for iBar=1:length(ColorScale)
    MaxValue = MaxClip{iBar}(end);
    if isfinite(MaxValue)
        DummyIm = repmat([0:0.01:1].*MaxValue,[101 1]);
        ColorMap = ColorScale{iBar};
        if length(ColorMap)<64
            ColorMap = ColorMap{end};
        end
        figure(iBar); imshow(DummyIm,[],'colormap',ColorMap,'InitialMagnification',400);
        colorbar;
    end
end
