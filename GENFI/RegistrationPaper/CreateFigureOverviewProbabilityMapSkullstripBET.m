%% Create skull stripping maps for total dataset, first GENFI paper
clear
x.piet    = 1;
x = vis_settings( x );

ROOT{1}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_PWIMASK\GE';
ROOT{2}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_PWIMASK\PHBsup';
ROOT{3}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_PWIMASK\PHnonBsup';
ROOT{4}     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\PWI_pGM_PWIMASK\SI';

vName       = {'GE' 'PhBsup' 'PHnonBsup' 'SI'};
% Subject     = {'GRN029' 'GRN006' 'C9ORF007' 'C9ORF019'};
for iV=1:4
    Subject{iV}     = xASL_adm_GetFsList( ROOT{iV}, '^(C9ORF|GRN|MAPT)\d{3}$', 1 );
end
    
ODIR        = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis\Figure_skullstrip';

%% Prepare PWI
for iV=1:4
    for iSub=1:12
        clear matlabbatch NewM0File tnii

        %% 1) PWI map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'ASL4D.nii');
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);

        if  size(tnii,4)>1
            tnii            = tnii(:,:,:,[1:2:end-1]) - tnii(:,:,:,[2:2:end]);

            if iV==4; tnii=-tnii; end

            tnii            = xASL_stat_MeanNan(tnii,4);
        end

        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;
        
        IM{1}{iV}{iSub}       = tnii;

        %% 2) Clip >0.6 non-zero sorted intensities
        SortedInt                   = sort(tnii(tnii~=0 & ~isnan(tnii) ));
        INTsearch                   = SortedInt(round(0.6*length(SortedInt))); % lot of voxels are noise, more than half
        tnii(tnii<INTsearch)        = 0;
        INTsearch                   = SortedInt(round(0.999*length(SortedInt))); % lot of voxels are noise, more than half
        tnii(tnii>INTsearch)        = INTsearch;
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;        
        
        IM{2}{iV}{iSub}       = tnii;
        clear tnii INTsearch SortedInt

        %% 3) Skull probability map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'PWI_GradualMask.nii');    
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);    
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;        
        
        IM{3}{iV}{iSub}       = tnii;    
        clear tnii   

        %% 4) Resulting skull-stripped PWI map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'mean_PWI_Clipped.nii');    
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);    
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;        
        
        IM{4}{iV}{iSub} = tnii;
        clear tnii       

        %% 5) Resulting skull-stripped M0 map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'temp_M0.nii');
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;
        
        IM{5}{iV}{iSub} = tnii;    
        clear tnii
    end
end
    % Here shown in original space, to illustrate the
    % algorithm in native space. Only the sagittal slices have been stretched
    % to fit the Figure.
    


%% Same for BET
BET_ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\BET_trial\BET_trial_results\BETter BET\BET_robust';
for iV=1:4
    for iSub=1:12

        clear tnii
        tnii            = fullfile( BET_ROOT, [vName{iV} '_' Subject{iV}{iSub} '_M0.nii_bet3.nii'] );
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:);
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;        
        
        IM{6}{iV}{iSub} = tnii;
    
%     % BETted PWI
%     IM{7}{iV}   = IM{1}{iV} .* single(logical(tnii));
    end
end

%% Average them
for iIM=1:6
    for iV=1:4
        for iSub=1:12
            TotalIM{iIM}{iV}(:,:,:,iSub)   = IM{iIM}{iV}{iSub};
        end
    end
end
for iIM=1:6
    for iV=1:4
        if      iIM==6
                TotalIM_av{iIM}{iV}         = xASL_stat_MeanNan(single(logical(TotalIM{iIM}{iV})),4);
            
        else    TotalIM_av{iIM}{iV}         = xASL_stat_MeanNan(TotalIM{iIM}{iV},4);
        end
    end
end
        
dip_image(TotalIM_av{3}{4})
dip_image(TotalIM_av{6}{2})


%% Show them

clear IM2
x.S.SagSlices                 = [64 40 34 64];

for iIM=[3 6]
    for iV=1:4
        IM2{iIM}{iV}     = FlipOrientation2_isotropic( TotalIM_av{iIM}{iV}(x.S.SagSlices(iV),:,:) );
    end
end

jet_256     = jet(256);
jet_256(1,:)= 0;

for iIM=[3 6]
    for iV=1:4
        figure(((iV-1)*2)+iIM);imshow(singlesequencesort(IM2{iIM}{iV},4),[],'InitialMagnification',200,'Colormap',jet_256);
    end
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
