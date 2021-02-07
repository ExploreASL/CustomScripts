%% Create skull stripping maps for Figure first GENFI paper
clear
x.piet    = 1;
x = vis_settings( x );

ROOT{1}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\GE';
ROOT{2}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\PHBsup';
ROOT{3}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\PHnonBsup';
ROOT{4}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\SI';

vName       = {'GE' 'PhBsup' 'PHnonBsup' 'SI'};
% Subject     = {'GRN029' 'GRN006' 'C9ORF007' 'C9ORF019'};
Subject     = {'GRN018' 'GRN006' 'C9ORF007' 'C9ORF019'};

ODIR        = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis\Figure_skullstrip';

%% Prepare PWI
for iV=1:4

    clear matlabbatch NewM0File tnii
    
    %% 1) PWI map
    tnii            = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'ASL4D.nii');
    tnii            = xASL_nifti( tnii );
    tnii            = tnii.dat(:,:,:,:);
    
    if  size(tnii,4)>1
        tnii            = tnii(:,:,:,[1:2:end-1]) - tnii(:,:,:,[2:2:end]);
        
        if iV==4; tnii=-tnii; end
        
        tnii            = xASL_stat_MeanNan(tnii,4);
    end
    
    IM{1}{iV}       = tnii;
    
    %% 2) Clip >0.6 non-zero sorted intensities
    SortedInt                   = sort(tnii(tnii~=0 & ~isnan(tnii) ));
    INTsearch                   = SortedInt(round(0.6*length(SortedInt))); % lot of voxels are noise, more than half
    tnii(tnii<INTsearch)        = 0;
    INTsearch                   = SortedInt(round(0.999*length(SortedInt))); % lot of voxels are noise, more than half
    tnii(tnii>INTsearch)        = INTsearch;
    IM{2}{iV}       = tnii;
    clear tnii INTsearch SortedInt
    
    %% 3) Skull probability map
    tnii            = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'PWI_GradualMask.nii');    
    tnii            = xASL_nifti( tnii );
    tnii            = tnii.dat(:,:,:,:);    
    IM{3}{iV}       = tnii;    
    clear tnii   
    
    %% 4) Resulting skull-stripped PWI map
    tnii            = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'mean_PWI_Clipped.nii');    
    tnii            = xASL_nifti( tnii );
    tnii            = tnii.dat(:,:,:,:);    
    IM{4}{iV}       = tnii;
    clear tnii       
    
    %% 5) Resulting skull-stripped M0 map
    tnii            = fullfile( ROOT{iV}, Subject{iV}, 'ASL_1', 'temp_M0.nii');
    tnii            = xASL_nifti( tnii );
    tnii            = tnii.dat(:,:,:,:);
    IM{5}{iV}       = tnii;    
    clear tnii           
end
    % Here shown in original space, to illustrate the
    % algorithm in native space. Only the sagittal slices have been stretched
    % to fit the Figure.
    


%% Same for BET
BET_ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\BET_trial\BET_trial_results\BETter BET\BET_robust';
for iV=1:4
    clear tnii
    tnii        = fullfile( BET_ROOT, [vName{iV} '_' Subject{iV} '_M0.nii_bet3.nii'] );
    tnii        = xASL_nifti( tnii );
    tnii        = tnii.dat(:,:,:);
    IM{6}{iV}   = tnii;
    
%     % BETted PWI
%     IM{7}{iV}   = IM{1}{iV} .* single(logical(tnii));
end

%% Show them

x.S.SagSlices                 = [64 40 34 64]; % 
iV=4;
for iIM=1:6
    IM2{iIM}     = FlipOrientation2_isotropic( IM{iIM}{iV}(x.S.SagSlices(iV),:,:) );
    
end


for iIM=1:6
    figure(iIM);imshow(IM2{iIM},[],'InitialMagnification',200);
end

close all


%% Show the MNI ones
GMim    = 'C:\ASL_pipeline_HJ\Maps\rgrey.nii';
GMim    = xASL_nifti(GMim);
GMim    = GMim.dat(:,:,:);
GMim    = FlipOrientation2_isotropic( GMim(61,:,:) );
dip_image(GMim)

skullim = 'C:\ASL_pipeline_HJ\Maps\mask_ICV.nii';
skullim = xASL_nifti(skullim);
skullim = skullim.dat(:,:,:);
skullim = FlipOrientation2_isotropic( skullim(61,:,:) );
dip_image(skullim)

%% Same for BE_robust
