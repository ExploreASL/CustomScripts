%% Admin
jet_256         = jet(256);
jet_256(1,:)    = 0;
HeatMap         = x.hot;
HeatMap(1,:)    = 0;

%% Choose slices

if  isfield(x.S,'CorSlices')
    x.S   = rmfield(x.S,'CorSlices');
end
if  isfield(x.S,'TraSlices')
    x.S   = rmfield(x.S,'TraSlices');
end
if  isfield(x.S,'SagSlices')
    x.S   = rmfield(x.S,'SagSlices');
end

x.S.Square                    = 0;
x.S.ConcatSliceDims           = 0; % 0 = vertical, 1 = horizontal
x.S.SkullStrip                = 1;
x.S.CropIS                    = 1;
x.S.nColumns                  = 6;

x.S.TraSlices                 = [38+([1:14]-1).*round((100-30)/19)]; % 30 - 100
x.S.TraSlices                 = x.S.TraSlices(2:end-1);
x.S.TraSlices                 = x.S.TraSlices([2 4 6 7 10 11]); % second image, Transform Function needs equal amount of slices

x.S.CorSlices                 = [27+([1:14]-1).*round((130-15)/19)]; % 15 - 130
% x.S.CorSlices                 = x.S.CorSlices(3:end);
% x.S.CorSlices                 = x.S.CorSlices([2 4 5 8 9 11]);
x.S.CorSlices                 = x.S.CorSlices(9:14);

x.S.SagSlices                 = [25+([1:14]-1).*round((110-15)/19)]; % 15 - 110
x.S.SagSlices                 = x.S.SagSlices([1:5 7:9 11:14]);
x.S.SagSlices                 = x.S.SagSlices([3 5 7 8 10 11]);


% ColorShades     = {[2,3] [5,6,7] [8,9,13] [10,11,12]}; % These are bilateral merged clusters that should get similar colors
% ColorShades     = {};

%% Load data
IMname      = 'E:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\Clusters_GENFI_check.nii';
tIMname     = 'E:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\SPMdir\spmT_0001_Masked.nii';

IM          = xASL_nifti(IMname);
IM          = IM.dat(:,:,:);
IMcluster   = IM;
clear IM

% Cluster image

IM      = TransformDataViewDimension( IMcluster, x );
[NewIM] = LabelColors( IM, x); % ColorShades


% t-stat map
tIM     = xASL_nifti(tIMname);
tIM     = tIM.dat(:,:,:);
tIM     = TransformDataViewDimension( tIM, x );

% Rescale tIM
tIM(isnan(tIM))     = 0;
tIM(tIM>5)        = 5; % 5.6

tIM                 = round(rescale( tIM-min(tIM(:)),1,256,1));
% tIM                 = ind2rgb(double(tIM),jet_256);
tIM                 = ind2rgb(double(tIM),HeatMap);


% Background image
load_T1             = fullfile( x.D.PopDir, 'Templates_Siemens','Template_mean_T1.nii');
background_mask     = xASL_nifti(load_T1);
background_mask     = single( background_mask.dat(:,:,:) );
background_mask     = background_mask ./ max( background_mask(:) );

SkullIM             = 'C:\ExploreASL\Maps\ICBM152NL2009\Brainmask_smooth.nii';
SkullIM             = xASL_nifti(SkullIM);
SkullIM             = single(SkullIM.dat(:,:,:));
if x.S.SkullStrip
    SkullMask           = SkullIM.^2;
    background_mask     = background_mask.*SkullMask;
    background_mask     = background_mask + ((SkullMask>0.5)-1).*-1;
else
    background_mask     = background_mask;
end

background_mask     = TransformDataViewDimension( background_mask, x );

for ii=1:3;background_mask(:,:,ii) = background_mask(:,:,1);end


%% Insert background image into label color image
TransP1=0;
TransP  = (NewIM(:,:,1)+NewIM(:,:,2)+NewIM(:,:,3))./2;
TransP  = repmat(TransP,[1 1 3]);

IMmask              = NewIM~=0;
NewIM(IMmask)       = NewIM(IMmask)-(TransP(IMmask).*background_mask(IMmask));
NewIM(~IMmask)      = background_mask(~IMmask);
NewIM(IMmask)       = NewIM(IMmask).*3;

%% Insert background tIM
NewtIM  = tIM;
NewtIM(NewtIM~=0)     = NewtIM(NewtIM~=0)-(TransP1.*background_mask(NewtIM~=0));
NewtIM(NewtIM==0)     = background_mask(NewtIM==0);

%% Combine images
clear IM_complete
IM_complete{1}                 = [NewtIM NewIM];
% clear IM NewIM NewtIM

% Show images

% figure(1);imshow(background_mask)
% figure(1);imshow(NewIM) 
figure(2);imshow(IM_complete{1})