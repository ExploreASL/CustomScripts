%% Check best quality map cutoff

NamesMaps   = {'QualityProbMap_GM_Bipolar' 'QualityProbMap_GM_PreDivaBaseline' 'Templates_Quality_GM_GENFI_all_sequences' 'QualityProbMap_GM_2DEPI_Bsup_GENFI' 'QualityProbMap_GM_2DEPI_noBsup_GENFI' 'QualityProbMap_GM_Siemens_3DGRASE_GENFI' 'QualityProbMap_GM_GE_GENFI'};
ROOT        = 'C:\ASL_pipeline_HJ\Maps\PopulationQualityMaps';

for iM=1:length(NamesMaps)
    clear tempIM
    tempIM          = xASL_nifti( fullfile(ROOT, [NamesMaps{iM} '.nii'] ) );
    tIM(:,:,:,iM)   = tempIM.dat(:,:,:);
end

dip_image(tIM)

%% Normalize to max first
for iM=1:length(NamesMaps)
    clear tempIM
    tempIM          = tIM(:,:,:,iM);
    tIM(:,:,:,iM)   = tIM(:,:,:,iM) ./ max(tempIM(:));
end

%% Create sorted intensities
clear SortInt
for iM=1:length(NamesMaps)
    clear tempIM
    tempIM          = tIM(:,:,:,iM);
    SortInt{iM}     = sort(tempIM(tempIM~=0 & isfinite(tempIM)));
end

Threshold           = 0.60;
for iM=1:length(NamesMaps)
    ThresholdIND    = SortInt{iM}(round(Threshold.*length(SortInt{iM})))
    maskIM(:,:,:,iM)    = tIM(:,:,:,iM) > ThresholdIND;
end

SliceN=50;

dip_image([tIM(:,:,SliceN,1) tIM(:,:,SliceN,2) tIM(:,:,SliceN,3) tIM(:,:,SliceN,4) tIM(:,:,SliceN,5) tIM(:,:,SliceN,6) tIM(:,:,SliceN,7)])
dip_image([maskIM(:,:,SliceN,1) maskIM(:,:,SliceN,2) maskIM(:,:,SliceN,3) maskIM(:,:,SliceN,4) maskIM(:,:,SliceN,5) maskIM(:,:,SliceN,6) maskIM(:,:,SliceN,7)])