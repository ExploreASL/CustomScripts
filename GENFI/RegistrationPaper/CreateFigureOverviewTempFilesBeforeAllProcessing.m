%% Create skull stripping maps for total dataset, first GENFI paper
clear
x.piet    = 1;
x = vis_settings( x );

MAIN_ROOT   = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor\M0_T1_BETMASK';

ROOT{1}     = fullfile(MAIN_ROOT, 'GE');
ROOT{2}     = fullfile(MAIN_ROOT, 'PHBsup');
ROOT{3}     = fullfile(MAIN_ROOT, 'PHnonBsup');
ROOT{4}     = fullfile(MAIN_ROOT, 'SI');

vName       = {'GE' 'PhBsup' 'PHnonBsup' 'SI'};
% Subject     = {'GRN029' 'GRN006' 'C9ORF007' 'C9ORF019'};
for iV=1:4
    Subject{iV}     = xASL_adm_GetFsList( ROOT{iV}, '^(C9ORF|GRN|MAPT)\d{3}$', 1 );
end
    
ODIR        = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\Inter-vendor_analysis\CheckBeforeProcessing';

%% Prepare PWI
for iV=1:4
    for iSub=1:12
        clear matlabbatch NewM0File tnii

        %% 4) Resulting skull-stripped PWI map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'mean_PWI_Clipped.nii');    
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);    
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;        
        
        IM{1}{iV}{iSub} = tnii;
        clear tnii       

        %% 5) Resulting skull-stripped M0 map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'temp_M0.nii');
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;
        
        IM{2}{iV}{iSub} = tnii;    
        clear tnii
        
        %% 5) Resulting skull-stripped M0 map
        tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'temp_mean_control.nii');
        
        if  ~exist(tnii)
            tnii            = fullfile( ROOT{iV}, Subject{iV}{iSub}, 'ASL_1', 'temp_M0.nii');
            NOT_EXIST(iV,iSub)  = 1;
        end
            
            
        tnii            = xASL_nifti( tnii );
        tnii            = tnii.dat(:,:,:,:);
        % Normalize
        tnii                = ( tnii./max(tnii(:)) ).*100;
        
        IM{3}{iV}{iSub} = tnii;    
        clear tnii        
    end
end
    % Here shown in original space, to illustrate the
    % algorithm in native space. Only the sagittal slices have been stretched
    % to fit the Figure.
    


%% Show them

% Remove NaNs


clear IM2
x.S.SagSlices                 = [64 40 34 64];
iV=4;
for iIM=1:3
    for iSub=1:12
        IM2{iIM}(:,:,iSub)     = FlipOrientation2_isotropic( IM{iIM}{iV}{iSub}(x.S.SagSlices(iV),:,:) );
        IM2{iIM}(isnan(IM2{iIM}))   = 0;
    end
end


for iIM=1:3
    figure(iIM);imshow(singlesequencesort(IM2{iIM},4),[],'InitialMagnification',200);
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
