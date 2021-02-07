%% Figure VBA mask

%% Admin
% Which slices to show
x.S.TraSlices     = 53;
x.S.CorSlices     = 68;
x.S.SagSlices     = 68;
x.S.ConcatSliceDims = 0;

% Colors
jet_256     = jet(256);
jet_256(1,:)= 0;


%% 1) M0 image
Seq(:,:,1) = TransformDataViewDimension( ImIn, x);

figure(1); imshow(Seq(:,:,1),[])

%% 2) Masked M0 image
Seq(:,:,3) = TransformDataViewDimension( ImOut, x);

figure(2); imshow(Seq(:,:,3),[])

%% 3) Masked M0 image
Seq(:,:,3) = TransformDataViewDimension( ImOut, x);

figure(3); imshow(Seq(:,:,3),[])

%% 4) Resultant CBF image
IM      = xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\qCBF_untreated_PH_Achieva_Bsup_C9ORF027_1_ASL_1_NEWprocessing.nii')
IM      = IM.dat(:,:,:);

BiasIM  = xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\Biasfield_Multipl_Site_3.nii');
BiasIM  = BiasIM.dat(:,:,:);

IM      = IM.*BiasIM;

Seq(:,:,4) = TransformDataViewDimension( IM, x);

figure(4); imshow(Seq(:,:,4),[0 150],'colormap',jet_256)





%% 5) Conventional M0 smoothing
IM  = xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\PH_Achieva_Bsup_C9ORF027_1\ASL_1\srrrM0.nii');
IM  = IM.dat(:,:,:);

Seq(:,:,5) = TransformDataViewDimension( IM, x);

figure(5); imshow(Seq(:,:,5),[])


%% 6) CBF image with conventional M0 image
IM      = xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\qCBF_untreated_PH_Achieva_Bsup_C9ORF027_1_ASL_1.nii')
IM      = IM.dat(:,:,:);

BiasIM  = xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\Biasfield_Multipl_Site_3.nii');
BiasIM  = BiasIM.dat(:,:,:);

IM      = IM.*BiasIM;

Seq(:,:,6) = TransformDataViewDimension( IM, x);

figure(6); imshow(Seq(:,:,6),[0 150],'colormap',jet_256)



%% 7) Difference old & new CBF image
Seq(:,:,7) = Seq(:,:,6)-Seq(:,:,4);
figure(7); imshow(Seq(:,:,7),[-10 10],'colormap',jet_256)

%% 1) Create 4 sequence SNR images

clear TempName IM IMtotal pGMfile pGMim NetIM VBAmask Seq

TempName{1} = fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel', 'Templates_GE', 'Template_mean_CBF.nii');
TempName{2} = fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel', 'Templates_Philips_Bsup', 'Template_mean_SNR.nii');
TempName{3} = fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel', 'Templates_Philips_noBsup', 'Template_mean_SNR.nii');
TempName{4} = fullfile('C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel', 'Templates_Siemens', 'Site YD (n=65)', 'Template_mean_SNR.nii');

for ii=1:4 % 1-4 = sequence probabilistic quality maps
    clear IM
    IM                  = xASL_nifti(TempName{ii});
    IM                  = IM.dat(:,:,:);
    IM                  = ClipVesselImage( IM,0.99,0,1);
    IM                  = IM./max(IM(:));
    IMtotal(:,:,:,ii)   = IM;
end
   
% 5 = pGM>0.2 mask
pGMfile         = fullfile(x.D.TemplateDir,'rc1T1_smooth.nii');
pGMim           = xASL_nifti(pGMfile);
IMtotal(:,:,:,5)= pGMim.dat(:,:,:)>0.2;
clear pGMim pGMfile

% 6 = total study probabilistic quality map
IMtotal(:,:,:,6)= IMtotal(:,:,:,1).*IMtotal(:,:,:,2).*IMtotal(:,:,:,3).*IMtotal(:,:,:,4).*IMtotal(:,:,:,5);
IMtotal(:,:,:,6)= IMtotal(:,:,:,6)./max(max(max(IMtotal(:,:,:,6))));
% 7 = VBA mask
IMtotal(:,:,:,7)= IMtotal(:,:,:,6)>0.05;

for iS=1:7
    Seq(:,:,iS) = TransformDataViewDimension( IMtotal(:,:,:,iS), x );
end

for ii=1:4 % 4 = sequence probabilistic quality maps
    figure(ii);
    imshow(Seq(:,:,ii),[0 1],'colormap',jet_256)
end

figure(5); % 5 = pGM>0.2 mask
imshow(Seq(:,:,5),[])

figure(6); % 6 = total study probabilistic quality map
imshow(Seq(:,:,6),[0 1],'colormap',jet_256)

figure(7); % 7 = VBA mask
imshow(Seq(:,:,7),[])