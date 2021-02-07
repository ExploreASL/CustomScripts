%% Admin
% Which slices to show
x.S.TraSlices     = 53;
x.S.CorSlices     = 68;
x.S.SagSlices     = 68;
x.S.ConcatSliceDims = 0;

% Color scheme
jet_256         = jet(256);
jet_256(1,:)    = 0;

load('C:\Backup\ASL\GENFI\GENFI_DF2\QC3_SpatialCoV&visualQC.mat');
PopDir2  = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel';

QualityBins{1}    = QualityGood2;
QualityBins{2}    = QualityAcceptable2;
QualityBins{3}    = QualityBad2;
QualityBins{4}    = QualityUnusable2;

%% Run it

Count   = [0 0 0 0];
for iV=1:4
    for iS=1:length(QualityBins{iV})
        if  iV<3
            CBFfile     = fullfile(x.D.PopDir, ['qCBF_' QualityBins{iV}{iS,1} '_ASL_1.nii']);
        else
            CBFfile     = fullfile(PopDir2, ['qCBF_' QualityBins{iV}{iS,1} '_ASL_1.nii']);
        end
        
        if  exist(CBFfile)
            clear tIM
            tIM             = xASL_nifti(CBFfile);
            IM{iV}(:,:,:,iS)= tIM.dat(:,:,:);
            Count(iV)   = Count(iV)+1;
        end
    end
end

% Normalize scans
for iV=1:4
    for iS=1:length(QualityBins{iV})
        clear nMean Ratio
        nMean               = IM{iV}(:,:,:,iS);
        nMean               = nMean(:);
        nMean               = mean(nMean(isfinite(nMean) & nMean~=0));        
        Ratio               = 60/nMean;
        
        IM{iV}(:,:,:,iS)    = IM{iV}(:,:,:,iS).*Ratio;
    end
end

for iV=1:3
    MeanIM(:,:,:,iV)  = xASL_stat_MeanNan(IM{iV},4);
end
for iV=4 % little bit less influence of the Skyra scans
    MeanIM(:,:,:,iV)  = xASL_stat_MeanNan(IM{iV}(:,:,:,[1 14:end]),4);
end
for iV=1:4
    Seq(:,:,iV) = TransformDataViewDimension( MeanIM(:,:,:,iV), x );
end

for ii=1:4 % 4 = sequence probabilistic quality maps
    figure(ii);
    imshow(Seq(:,:,ii),[0 150],'colormap',jet_256)
end

