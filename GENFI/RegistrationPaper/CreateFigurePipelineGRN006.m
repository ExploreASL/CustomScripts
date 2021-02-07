%% Create skull stripping maps for Figure first GENFI paper
clear
x.piet    = 1;
x = vis_settings( x );

ROOT{1}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\PHBsup';

vName{1}    = {'PhBsup'};
Subject{1}  = {'GRN006'};

% ODIR        = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis\Figure_skullstrip';
slicenr     = 8;

%% Prepare PWI
for iV=1

    clear matlabbatch NewM0File tnii
    
    %% 1) Individual EPI
    tnii            = fullfile( 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\PHBsup\GRN006', 'ASL_1', 'ASL4D.nii');
    tnii            = xASL_nifti( tnii );
    tnii            = tnii.dat(:,:,:,:);
    
    IMpoint         = zeros(80,80);
    IMpoint(30,60)  = 1000;
    
    figure(1);imshow(xASL_im_rotate(tnii(:,:,8,1),90),[],'InitialMagnification',200); % single control image
    figure(1);imshow(xASL_im_rotate(tnii(:,:,8,1)+IMpoint,90),[],'InitialMagnification',200);  % signal single-voxel
    figure(1);plot(squeeze(tnii(30,60,8,:))); %  signal single-voxel plotted
    figure(1);imshow(xASL_im_rotate(mean(tnii(:,:,8,:),4),90),[],'InitialMagnification',200); % mean control image
    
    
    if  size(tnii,4)>1
        tnii            = tnii(:,:,:,[1:2:end-1]) - tnii(:,:,:,[2:2:end]);
        
        if iV==4; tnii=-tnii; end
        
        tnii            = xASL_stat_MeanNan(tnii,4);
    end
    
    figure(1);imshow(xASL_im_rotate(tnii(:,:,8),90),[],'InitialMagnification',200); % mean control image    
    
    %% EPI transformed to common space
    % Load M0
    tnii    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\PHBsup\GRN006\ASL_1\rtemp_M0.nii';
    tnii    = xASL_nifti(tnii);
    tnii    = tnii.dat(:,:,:);
%     dip_image(xASL_im_rotate(tnii,90))
%     
    figure(1);imshow(xASL_im_rotate(tnii(:,:,53),90),[-157.7422 2.0692e+003],'InitialMagnification',200); % mean control image    
    min(min(min(tnii(:,:,53))))
    % smooth M0
    tnii                  = xASL_im_ndnanfilter(tnii,'gauss',[7.536 7.536 7.536],1);
    figure(1);imshow(xASL_im_rotate(tnii(:,:,53),90),[-157.7422 2.0692e+003],'InitialMagnification',200); % mean control image    
    
    %% Load T1
    tnii    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis\GRN006\T1.nii';
    tnii    = xASL_nifti(tnii);
    tnii    = FlipOrientation_isotropic(tnii.dat(:,:,:));
    figure(1);imshow(tnii(:,:,131),[],'InitialMagnification',200); % mean control image    
    
    %% Load c1T1
    tnii    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis\GRN006\c1T1.nii';
    tnii    = xASL_nifti(tnii);
    tnii    = FlipOrientation_isotropic(tnii.dat(:,:,:));
    figure(1);imshow(tnii(:,:,131),[],'InitialMagnification',200); % mean control image    

    % WM map
    tnii    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis\GRN006\c2T1.nii';
    tnii    = xASL_nifti(tnii);
    tnii    = FlipOrientation_isotropic(tnii.dat(:,:,:));
    figure(1);imshow(tnii(:,:,131),[],'InitialMagnification',200); % mean control image    

    % DARTELed GM map
    tnii    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis\dartel\rc1T1_GRN006.nii';
    tnii    = xASL_nifti(tnii);
    tnii    = xASL_im_rotate(tnii.dat(:,:,:),90);
    figure(1);imshow(tnii(:,:,53),[],'InitialMagnification',200); % mean control image    
    
    % multiple smoothnesses for DARTEL
    IM                  = xASL_im_ndnanfilter(tnii,'gauss',[7.536 7.536 7.536],1);
    figure(1);imshow(IM(:,:,53),[],'InitialMagnification',200); % mean control image    
    
    
    %% Load FlowField

    tnii    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_MASK\PHBsup\dartel\u_rc1T1_GRN006_T1_template.nii';
    tnii    = xASL_nifti(tnii);    
    tnii    = xASL_im_rotate(tnii.dat(:,:,:),90);
    figure(1);imshow(tnii(:,:,53),[-1 1],'InitialMagnification',200); % mean control image
    
    
    dip_image(FlipOrientation_isotropic(tnii))
    skullim = FlipOrientation2_isotropic( skullim(61,:,:) );
    
    
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
