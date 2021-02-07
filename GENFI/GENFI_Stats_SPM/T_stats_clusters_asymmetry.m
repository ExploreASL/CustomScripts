%% Checking asymmetry in mean and peak p-stats for GENFI VBA regions

ClusterIM                   = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\Clusters_GENFI_check.nii';
ClusterIM                   = xASL_nifti(ClusterIM);
ClusterIM                   = ClusterIM.dat(:,:,:);
uncClusterIM                = ClusterIM;
%NewMask                     = dip_array(mirror(ClusterIM,'y-axis'));
NewMask                     = ClusterIM(:,end:-1:1,:);
ClusterIM(ClusterIM==0)     = NewMask(ClusterIM==0);
ClusterIM(ClusterIM==4)     = 3;
ClusterIM(ClusterIM==6)     = 5;

LeftMask                    = ClusterIM;
RightMask                   = ClusterIM;
LeftMask( 1: 60,:,:,:)      = 0; % exclude the right part from mask
RightMask(61:end,:,:,:)     = 0; % exclude the  left part from mask


SPMim       = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\SPMdir\spmT_0001.nii';
SPMim       = xASL_nifti(SPMim);
SPMim       = SPMim.dat(:,:,:);



for iC=1:6
    
    SPMl              = SPMim(LeftMask  ==iC);
    SPMr              = SPMim(RightMask ==iC);

    if  sum(SPMl)~=0
        tStatMean(iC,1)   = mean(SPMl);
        tStatMax(iC,1)    = max(SPMl);
    end
    
    if  sum(SPMr)~=0
        tStatMean(iC,2)   = mean(SPMr);
        tStatMax(iC,2)    = max(SPMr);
    end
    
    tStatMean(iC,3)       = mean(SPMim(uncClusterIM==iC));
    tStatMax(iC,3)        = max (SPMim(uncClusterIM==iC));
end    

