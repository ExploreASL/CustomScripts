


rDir = '/Users/hjmutsaerts/ExploreASL/TryOut_Masking_1543/derivatives/ExploreASL/GE_3Dspiral_T1prefilled_Cyst_M0_noFLAIR_2ndRun_LoQ_1';
aslDir = fullfile(rDir, 'ASL_1');

pGM = fullfile(rDir, 'c1T1.nii');
pWM = fullfile(rDir, 'c2T1.nii');
pCSF = fullfile(rDir, 'c3T1.nii');

pvGM = fullfile(aslDir, 'PVgm.nii');
pvWM = fullfile(aslDir, 'PVwm.nii');
pvCSF = fullfile(aslDir, 'PVcsf.nii');

pGM_im = xASL_io_Nifti2Im(pGM);
pWM_im = xASL_io_Nifti2Im(pWM);
pCSF_im = xASL_io_Nifti2Im(pCSF);

pvGM_im = xASL_io_Nifti2Im(pvGM);
pvWM_im = xASL_io_Nifti2Im(pvWM);
pvCSF_im = xASL_io_Nifti2Im(pvCSF);

sumImageHiRes = pGM_im + pWM_im + pCSF_im;

min(sumImageHiRes(:))


figure(1);imshow([pvGM_new_HIRES(:,:,140)>0.5 GMmask_HIRES05(:,:,140)],[],'InitialMagnification', 150)
figure(1);imshow([pvGM_new_HIRES(:,:,140)>0.7 GMmask_HIRES07(:,:,140)],[],'InitialMagnification', 150)

figure(2);imshow([pvGM_new(:,:,20)>0.5 GMmask_05(:,:,20)],[],'InitialMagnification', 150)
figure(2);imshow([pvGM_new(:,:,20)>0.6 GMmask_06(:,:,20)],[],'InitialMagnification', 150)


% pGM>0.5 == pGM>(pWM+pCSF)
% pGM>0.7 == pGM>1.4*(pWM+pCSF)



max(pGM_im(:))
max(pWM_im(:))
max(pCSF_im(:))

max(pvGM_im(:))
max(pvWM_im(:))
max(pvCSF_im(:))



figure(1);imshow([pvGM_new(:,:,20) pvWM_new(:,:,20) pvCSF_new(:,:,20)],[],'InitialMagnification', 150);


%% Scale sum back to 1
sumImage = pvGM_im + pvWM_im + pvCSF_im;

factorImage = 1./sumImage;

maskImage = sumImage>0.1;
factorImage(~maskImage) = 0;

pvGM_new = pvGM_im .* factorImage;
pvWM_new = pvWM_im .* factorImage;
pvCSF_new = pvCSF_im .* factorImage;

% stats
% xASL_stat_MeanNan(factorImage(maskImage))
% xASL_stat_StdNan(factorImage(maskImage))
% min(factorImage(maskImage))
% max(factorImage(maskImage))

GMmask_05 = pvGM_new>(pvWM_new+pvCSF_new);
GMmask_06 = pvGM_new>(1.2.*(pvWM_new+pvCSF_new));

% SAME FOR HIRES
%% Scale sum back to 1
sumImage_HIRES = pGM_im + pWM_im + pCSF_im;

factorImage_HIRES = 1./sumImage_HIRES;

maskImage_HIRES = sumImage_HIRES>0.1;
factorImage_HIRES(~maskImage_HIRES) = 0;

pvGM_new_HIRES = pGM_im .* factorImage_HIRES;
pvWM_new_HIRES = pWM_im .* factorImage_HIRES;
pvCSF_new_HIRES = pCSF_im .* factorImage_HIRES;

GMmask_HIRES05 = pvGM_new_HIRES>(pvWM_new_HIRES+pvCSF_new_HIRES);
GMmask_HIRES07 = pvGM_new_HIRES>(1.4.*(pvWM_new_HIRES+pvCSF_new_HIRES));


% stats _HIRES
% xASL_stat_MeanNan(factorImage_HIRES(maskImage_HIRES))
% xASL_stat_StdNan(factorImage_HIRES(maskImage_HIRES))
% min(factorImage_HIRES(maskImage_HIRES))
% max(factorImage_HIRES(maskImage_HIRES))