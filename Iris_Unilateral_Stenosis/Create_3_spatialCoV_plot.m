for ii=1:8

    tNII(:,:,:,ii)    = xASL_io_Nifti2Im(['C:\Backup\ASL\Unilateral_Stenosis\analysis\dartel\qCBF_untreated_012_ASL_' num2str(ii) '.nii']);
end

tNII    = xASL_stat_MeanNan(tNII,4);
tN      = xASL_im_rotate(tNII,90);

%dip_image(tN)

tN=tN(:,:,62);

tN_calc_ROI     = tN>0;
MeanV           = xASL_stat_MeanNan(tN(tN_calc_ROI));
tN              = tN.*40 ./ MeanV;

L    = tN(:,1:60);
R    = tN(:,62:121);

R   = fliplr(R);


MaskIM  = xASL_io_Nifti2Im('C:\ExploreASL\Maps\VascularTerritories\VascTerritoriesOriginalTatu\r_vasc_mid_R.nii');

MaskIM  = xASL_im_rotate(MaskIM(:,:,62),90);
MaskIM  = MaskIM(:,1:60,1);
%
%
% PieceL  = L(87:145,1:40);
% PieceR  = R(87:145,1:40);



PieceL  = L.*MaskIM;
PieceR  = R.*MaskIM;


MaxV            = 200;
MinV            = 0;
SmoothKernel    = [1 1 1];



IM2D            = PieceL;
IM2D            = xASL_im_rotate(IM2D,90);
% IM2D            = dip_array(mirror(IM2D,'y-axis'));
%IM2D            = fliplr(IM2D);
IM2D            = IM2D(:,end:-1:1);
IM2D(IM2D<MinV) = MinV;
IM2D(IM2D>MaxV) = MaxV;

IM2D_calc_ROI   = IM2D>0;

MeanV           = mean(IM2D(IM2D_calc_ROI));
StdV            = std(IM2D(IM2D_calc_ROI));
SpatCoV         = StdV/MeanV;

IM2D            = xASL_im_ndnanfilter(IM2D,'rect',SmoothKernel);
[X Y]           = meshgrid([-(size(IM2D,2)-1)/2:(size(IM2D,2)-1)/2],[-(size(IM2D,1)-1)/2:(size(IM2D,1)-1)/2]);
Z               = IM2D+eps; % add very small number to avoid top clipping

figure(1)
jet_1024        = jet(1024);
%     jet_1024(1,:)   = 0;

colormap(jet_1024)
surf(X,Y,Z,'EdgeColor','none');
shading interp
camlight left
lighting phong
axis([-20 20, -40 40, MinV MaxV])
xlabel('Anterior-posterior')
ylabel('Left-right')
zlabel('CBF (mL/100g/min)');
title(['Mean = ' num2str(MeanV,3) ' mL/100g/min, spatial CoV = ' num2str(SpatCoV*100,3)])





IM2D            = PieceR;
IM2D            = xASL_im_rotate(IM2D,90);
% IM2D            = dip_array(mirror(IM2D,'y-axis'));
%IM2D            = fliplr(IM2D);
IM2D            = IM2D(:,end:-1:1);

IM2D(IM2D<MinV) = MinV;
IM2D(IM2D>MaxV) = MaxV;

IM2D_calc_ROI   = IM2D>0;
MeanV           = mean(IM2D(IM2D_calc_ROI));
StdV            = std(IM2D(IM2D_calc_ROI));
SpatCoV         = StdV/MeanV;

IM2D            = xASL_im_ndnanfilter(IM2D,'rect',SmoothKernel);
[X Y]           = meshgrid([-(size(IM2D,2)-1)/2:(size(IM2D,2)-1)/2],[-(size(IM2D,1)-1)/2:(size(IM2D,1)-1)/2]);
Z               = IM2D+eps; % add very small number to avoid top clipping

figure(2)
jet_1024        = jet(1024);
%     jet_1024(1,:)   = 0;

colormap(jet_1024)
surf(X,Y,Z,'EdgeColor','none');
shading interp
camlight left
lighting phong
axis([-20 20, -40 40, MinV MaxV])
xlabel('Anterior-posterior')
ylabel('Left-right')
zlabel('CBF (mL/100g/min)');
title(['Mean = ' num2str(MeanV,3) ' mL/100g/min, spatial CoV = ' num2str(SpatCoV*100,3)])
