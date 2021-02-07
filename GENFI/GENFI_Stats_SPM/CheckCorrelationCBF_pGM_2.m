%% Correlate pGM & CBF

% Which slices to show
x.S.TraSlices     = 53;
x.S.CorSlices     = 68;
x.S.SagSlices     = 68;
x.S.ConcatSliceDims = 0;

% Colors
jet_256     = jet(256);
jet_256(1,:)= 0;

%% Load data
clear imPGM imCBF

PGM_DIR     = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\PV_pGM\permute_LongitudinalTimePoint\SPMdir';
CBF_DIR     = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\SPMdir';

Flist_pGM   = xASL_adm_GetFileList(PGM_DIR,'^Set1subject\d{5}\.(nii|nii\.gz)$');
Flist_CBF   = xASL_adm_GetFileList(CBF_DIR,'^Set1subject\d{5}\.(nii|nii\.gz)$');

for iF=1:length(Flist_pGM)
    clear tIM
    tIM                 = xASL_nifti(Flist_pGM{iF});
    imPGM(:,:,:,iF)     = tIM.dat(:,:,:);
    
    clear tIM
    tIM                 = xASL_nifti(Flist_CBF{iF});
    imCBF(:,:,:,iF)     = tIM.dat(:,:,:);
end


clear r p rlo rup
for iX=1:121
    for iY=1:145
        for iZ=1:121
            clear r p rlo rup
            [r,p,rlo,rup]       = corrcoef( squeeze(imPGM(iX,iY,iZ,:)) , squeeze(imCBF(iX,iY,iZ,:)), 'rows','complete' );
            rCoeff(iX,iY,iZ)    = r(1,2);
            pValue(iX,iY,iZ)    = p(1,2);
            rloCI(iX,iY,iZ)     = rlo(1,2);
            rupCI(iX,iY,iZ)     = rup(1,2);
        end
    end
end

pThreshold                      = 0.001/12; % rough FWE correction assuming 1000 resels

SignificanceMask                = pValue<pThreshold;

%% Visualize
SignificantCorr                                     = rCoeff;
SignificantCorr(SignificanceMask==0 & rCoeff>0)     = 0.01;


Seq(:,:,1) = TransformDataViewDimension( SignificantCorr);

figure(1); imshow(Seq(:,:,1),[0 0.5],'colormap',jet_256)


