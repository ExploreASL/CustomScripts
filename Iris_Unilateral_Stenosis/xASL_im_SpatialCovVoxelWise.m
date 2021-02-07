function SmoothCoV = xASL_im_SpatialCovVoxelWise( IM, Mask,KernelSize )
%SpatialCoV_voxelwise Computes the spatial Cov voxel-wise
% using a rectangular window, filtering only within the
% mask

% ExploreASL, 2017

if  ~exist('KernelSize','var')
    KernelSize  = [8 8 8];
end

if  exist('Mask','var')
    Mask        = single(logical(Mask));
    IM          = Mask.*single(IM);
end
IM(IM==0)   = NaN;


SmoothIM    = xASL_im_ndnanfilter(IM   ,'gauss',KernelSize,0);
SmoothIMSq  = xASL_im_ndnanfilter(IM.^2,'gauss',KernelSize,0);
SmoothCoV   = (SmoothIMSq-(SmoothIM.^2)).^0.5 ./ SmoothIM;
	
	
	
%% Remove artifacts
SmoothCoV(SmoothCoV<=0)     = NaN;
% Extrapolate over NaNs
SmoothCoV                   = xASL_im_ndnanfilter(SmoothCoV,'gauss',KernelSize,2);
% Some extra smoothing
SmoothCoV                   = xASL_im_ndnanfilter(SmoothCoV,'gauss',[2 2 2],0);
% Mask again
SmoothCoV                   = SmoothCoV.*Mask;


end
