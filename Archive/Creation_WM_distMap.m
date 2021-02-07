%% Creation WM distance map


    WMmap   = fullfile(x.D.TemplateDir,'rc2T1.nii');
    GMmap   = fullfile(x.D.TemplateDir,'rc1T1.nii');

    GMim    = xASL_io_ReadNifti(GMmap);
    WMim    = xASL_io_ReadNifti(WMmap);

    GMim    = GMim.dat(:,:,:);
    WMim    = WMim.dat(:,:,:);

    WMmask  = WMim>0.1;
    iIt     = -1;
    WMdist  = zeros(size(WMmask));

    while   sum(WMmask(:))>0
            % Replaced by chessboard distance - 4-neighbors rather than
            % 8-neighbors - simply because I want to use SPM erosion with a
            % cross rather than ones(3,3,3)
            tempMapAx = dilate_erode_full(WMmask,'erode',[0 1 0; 1 1 1; 0 1 0]);
            tempMapSag = dilate_erode_full(WMmask,'erode',cat(3,[0;1;0],[1;1;1],[0;1;0]));
            tempMap = (tempMapAx+tempMapSag)>0;
            WMdist(logical(WMmask-tempMap))      = iIt;
            WMmask                      = tempMap;
            iIt                         = iIt-1
    end

    WMdist(WMdist~=0)       = WMdist(WMdist~=0)     - min(WMdist(:));

    % It does not make sense to calculate this for the whole image, but rather
    % for a sum of GM+WM (you can also include CSF, but I did not have it)
    WMGMmask = (WMim+GMim)>0.1;
    WMGMInvmask = 1-WMGMmask;
    RemainMask = WMGMmask - (WMdist~=0);


    iIt     = max(WMdist(:))+1;
    lastSize = sum(RemainMask(:))+1;
    % Will not go to complete zero because there are GM regions that are not
    % neighboring WM, so that the algorithm will never go there...
    while   sum(RemainMask(:))<lastSize
            lastSize = sum(RemainMask(:));
            % We add the background because we want erosion comming only from
            % within from WM and not from the outerboundary of GM with CSF or
            % air
            RemainMaskFull = RemainMask+WMGMInvmask;

            tempMapAx = dilate_erode_full(RemainMaskFull,'erode',[0 1 0; 1 1 1; 0 1 0]);
            tempMapSag = dilate_erode_full(RemainMaskFull,'erode',cat(3,[0;1;0],[1;1;1],[0;1;0]));
            tempMap = (tempMapAx+tempMapSag)>0;
            EdgeMask = logical((RemainMaskFull-tempMap).*WMGMmask);
            WMdist(EdgeMask)     = iIt;
            RemainMask = RemainMask - EdgeMask;
            iIt                                 = iIt+1;
            sum(RemainMask(:));
    end

    SaveFile        = fullfile(x.D.MapsDir,'WM_DistanceMap.nii');
    xASL_io_SaveNifti(WMmap, SaveFile, WMdist);
