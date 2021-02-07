%% Figure VBA mask

%% Admin
% Which slices to show
clear S
x.S.TraSlices     = [48 62 69];
x.S.ConcatSliceDims = 0;
x.S.Square        = 0; 

% Colors
jet_256     = jet(256);
jet_256(1,:)= 0;

BiasFieldIM     = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\Biasfield_Multipl_Site_3.nii';
BiasFieldIM     = xASL_nifti(BiasFieldIM);
BiasFieldIM     = BiasFieldIM.dat(:,:,:);

clear Seq
%% 1) Before correction
Seq(:,:,1) = TransformDataViewDimension( PWI.*ScaleImage, x);

figure(1); imshow(Seq(:,:,1),[0 150],'Colormap',jet_256)

%% 2) Negative clusters mask
GMmask                  = fullfile( x.D.MapsDir, 'rgrey.nii');
GMmask                  = xASL_nifti(GMmask);
GMmask                  = GMmask.dat(:,:,:)>0.2;

NegativeMask=PWI<ClipThr;
Seq(:,:,2) = TransformDataViewDimension( NegativeMask.*GMmask, x);

figure(2); imshow(Seq(:,:,2),[])

%% 3) Flipped negative regions, resulting CBF image
Seq(:,:,3) = TransformDataViewDimension( TreatedPWI_1.*ScaleImage, x);

figure(3); imshow(Seq(:,:,3),[0 150])

%% 4) Show compression masks
Seq(:,:,4) = TransformDataViewDimension( ClipMask.*GMmask, x);

figure(4); imshow(Seq(:,:,4),[])


%% 5) Show after compression
Seq(:,:,5) = TransformDataViewDimension( TreatedPWI, x);

figure(5); imshow(Seq(:,:,5),[0 150])

%% 6) Get In-Out Compression Grap
InValues    = TreatedPWI_1.*ScaleImage;
OutValues   = TreatedPWI;
MaskToUse   = GMmask & isfinite(InValues) & isfinite(OutValues);
BiasFmean   = xASL_stat_MeanNan(BiasFieldIM(MaskToUse));
InValues    = InValues(MaskToUse).*BiasFmean;
OutValues   = OutValues(MaskToUse).*BiasFmean;

save(fullfile('C:\Users\amcuser\Desktop\Figure', 'data.mat'),'InValues','OutValues')

figure(7);plot(InValues,OutValues,'b.',[1:1:200],[1:1:200],'r')
axis([0 200 0 200]);
xlabel('GM CBF before vascular signal compression (mL/100g/min)');
ylabel('GM CBF after  vascular signal compression (mL/100g/min)');

SaveFile   = fullfile( 'C:\Users\amcuser\Desktop\Figure', '6_Graph.eps');
print(gcf,'-depsc',SaveFile);
