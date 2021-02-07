%% Create dummy y_T1.nii flow field for 1.5x1.5x1.5 mm

Resolution  = [1.5 1.5 1.5]

% World Coordinates:
% X = -90:90  mm LR
% Y = -126:90 mm PA
% Z = -72:108 mm IS

% Xmax    =   90;
% Xmin    = - 90;
% Ymax    =   90;
% Ymin    = -126;
% Zmax    = 108;
% Zmin    =  -72;
%
% Xdim    = Xmax-Xmin;
% Ydim    = Ymax-Ymin;
% Zdim    = Zmax-Zmin;

[X Y Z]         = ConvertVoxel2MNIcoordinates([1:121],[1:145],[1:121],[1.5 1.5 1.5]);
IM              = zeros(121,145,121,1,3);

for ii=1:121; IM(ii,:,:,1,1)  = X(ii); end
for ii=1:145; IM(:,ii,:,1,2)  = Y(ii); end
for ii=1:121; IM(:,:,ii,1,3)  = Z(ii); end

xASL_io_SaveNifti('C:\ExploreASL\Maps\rgrey.nii','C:\ExploreASL\Maps\Identity_Deformation_y_T1.nii',IM);
