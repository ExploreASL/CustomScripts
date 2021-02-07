refIM   = 'C:\Backup\ASL\xASL_example\Example_SingleSubject_Unproc\Sub-001\ASL_1\temp_mean_PWI.nii';
srcIM   = 'C:\Backup\ASL\xASL_example\Example_SingleSubject_Unproc\Sub-001\c1T1.nii.gz';
NewName = 'C:\Backup\ASL\xASL_example\Example_SingleSubject_Unproc\Sub-001\ASL_1\c1T1.nii';

Reslice_Init( refIM, srcIM, [], [], NewName, 4 )

pGM  = nifti2IM(NewName)+1;
CBF  = nifti2IM(NewName)+1;

GMmask  = pGM>1.25;
GMmask2     = zeros(size(GMmask));
GMmask2(20:40,20:40,6:14)    = 1;
GMmask3     = GMmask & GMmask2;


ValueNativeSpace = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF./pGM)))

CBF(20:40,20:40,6:14)     = CBF(20:40,20:40,6:14).*2.5;

save_nii_spm(NameIn,NameOut_pGM,pGM,[],0)
save_nii_spm(NameIn,NameOut_CBF,CBF,[],0)
nativedeformat(NameOut_pGM,
nativedeformat(NameOut_CBF,

nifti2IM(

CBF(GMmask3)     = CBF(GMmask3).*(1+IMnoise(GMmask3));



IMnoise = randn(80,80,17);

dip_image(IM)


[X N]   = hist(CBF(GMmask));
figure(1);plot(N, X)