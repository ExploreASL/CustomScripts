%% Check correlation stats ASL & pGM

StatsASLname    = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\p0.001_baseline\spmT_0001.nii';
StatspGMname    = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\PV_pGM\p0.001_baseline\spmT_0001_pGM.nii';

ASLim           = xASL_nifti(StatsASLname);
pGMim           = xASL_nifti(StatspGMname);

ASLim           = ASLim.dat(:,:,:);
pGMim           = pGMim.dat(:,:,:);

Mask            = ASLim>0 & pGMim>0;

ASLn            = ASLim(Mask);
pGMn            = pGMim(Mask);

[coef, pval]    = corr(ASLn, pGMn)

% r = 0.35, p-value = 0. but this can still be that methods are sensitive
% in similar regions, or have pathology in similar regions

figure(1);plot(ASLn,pGMn,'.')
xlabel('ASL voxel-wise t-stats');
ylabel('pGM voxel-wise t-stats');
title('Similarity ASL & pGM voxel-wise stats, r=0.35, p<0.001');



