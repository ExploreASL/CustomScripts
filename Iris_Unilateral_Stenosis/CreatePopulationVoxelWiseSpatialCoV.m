%% Create population-based voxel-wise spatial CoV map



clear LateralizedCBF
for iA=1:x.nSubjects
    clear TempIm
    TempIm                              = squeeze(ASL_untreated.Data.data(iA,:,:,:));
    
    if  x.S.SetsID(iA,6)==1
        LateralizedCBF(iA,:,:,:)        = TempIm;
    else
        
        for iX=1:size(TempIm,1)
            LateralizedCBF(iA,iX,:,:)   = TempIm(size(TempIm,1)-iX+1,:,:);
        end
    end
end

clear CoV_group
for iA=1:size(LateralizedCBF,1)
    CoV_group(iA,:,:,:)                 = SpatialCoV_voxelwise(squeeze(LateralizedCBF(iA,:,:,:)),x.GMSliceMask,[10 10 10]);
end

CoV_template    = squeeze(xASL_stat_MeanNan(CoV_group,1));

CoV_template_IM     = TransformDataViewDimension(CoV_template);
jet_256             = jet(256);
jet_256(1,:)        = 0;

figure(1);imshow(CoV_template_IM,[0 1.2],'colormap',jet_256)



%% Create histograms

clear N_ROI X_ROI bin_nr min_nr max_nr bin_size myfilter

bin_nr      =117;
min_nr      =-40;
max_nr      =140;
bin_size    =(max_nr-min_nr)/bin_nr;
% myfilter    =fspecial('gaussian',[bin_nr,1],0.02*bin_nr);
% This is 117/ 180 = 0.65 bins per mL/100g/min, histograms shown have 120 range which would have been 78 bins

% Mean CBF histograms

SideMask            = zeros(121,145,121);
SideMask(1:61,:,:)  = 1;

LeftMask            = logical(SideMask.*~isnan(CoV_template));
RightMask           = logical(~SideMask.*~isnan(CoV_template));

for iS=1:size(LateralizedCBF,1)
    clear temp tempL tempR ExtremeL ExtremeL_low ExtremeR ExtremeR_low
    temp                                                    = squeeze(CoV_group(iS,:,:,:));
    tempL                                                   = temp(LeftMask & isfinite(temp));
    tempR                                                   = temp(RightMask & isfinite(temp));
    
    % clip extremes
    ExtremeL                                             = tempL>(median(tempL)+6*(xASL_stat_MadNan(tempL)));
    ExtremeL_low                                         = tempL<(median(tempL)-6*(xASL_stat_MadNan(tempL)));
    ExtremeR                                             = tempR<(median(tempR)-6*(xASL_stat_MadNan(tempR)));
    ExtremeR_low                                         = ExtremeR+tempR>(median(tempR)+6*(xASL_stat_MadNan(tempR)));
    
    tempL                                               = tempL(~ExtremeL & ~ExtremeL_low);
    tempR                                               = tempR(~ExtremeR & ~ExtremeR_low);
    

   
    [N_L(iS,:) X_L(iS,:)]                                   = hist(tempL); 
    [N_R(iS,:) X_R(iS,:)]                                   = hist(tempR);
%     
%     for k=1:8
%         [N_ROI{vendor}{k}(:,ii)  X_ROI{vendor}{k}(:,ii)]    =hist(temp(logical( segm_mask_total{1,k}{1,vendor}(:,:,:,ii) ) & isfinite(temp)),[min_nr:(max_nr-min_nr)/bin_nr:max_nr]);
%         N_ROI{vendor}{k}(:,ii)                              =N_ROI{vendor}{k}(:,ii)./sum(N_ROI{vendor}{k}(:,ii))./bin_size;end
end

% for k=1:8
%     N_ROI{vendor}{k}        =imfilter(mean(N_ROI{vendor}{k},2), myfilter, 'replicate');end
% end

figure(1);plot(mean(X_L,1),mean(N_L,1),'r',mean(X_R,1),mean(N_R,1),'b')
