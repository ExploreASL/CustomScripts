function xASL_wrp_VisualizeASLROIs( x, ASL, masks )
%visualize_ASL_ROIs Part of ExploreASL
% Prints mean and subject-specific ROIs

    fprintf('%s\n','Visualizing ROIs');
    tic
    % print mean GM & WM masks
    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_1_GM_WM_masks_mean_' x.PRE_POST '-DARTEL.jpg']);
    if ~exist( SaveFile ,'file') || x.OVERWRITE
        for k=1:x.nSlicesLarge
            temp_im(:,:,k)                  =xASL_vis_CropParmsApply(xASL_im_rotate( (0.5.* mean(single(masks{1}(:,:,x.slicesLarge(k),:)),4)) + mean(single(masks{2}(:,:,x.slicesLarge(k),:)),4) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
        end
        xASL_vis_Imwrite(xASL_vis_TileImages(temp_im, 4), SaveFile,x.colors_ROI{1});

        clear temp_im ii k
    end

    % print mean vascular ROI masks
    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_1_vasc_masks_mean_' x.PRE_POST '-DARTEL.jpg']);
    if ~exist( SaveFile ,'file') || x.OVERWRITE
        for j=3:5
            for k=1:x.nSlicesLarge
                temp_im{j}(:,:,k)           =xASL_vis_CropParmsApply(xASL_im_rotate( mean(single(masks{j}(:,:,x.slicesLarge(k),:)),4) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
            end
            temp_view{j}                    =ind2rgb(round( xASL_vis_TileImages(temp_im{j}, 4)  ) .*255,x.colors_ROI{j});
        end

        xASL_vis_Imwrite(temp_view{3}+temp_view{4}+temp_view{5}, SaveFile);
        clear temp_im temp_view ii j k
    end

    % print mean large MNI ROI masks
    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_large_MNI_mean_' x.PRE_POST '-DARTEL.jpg']);
    if ~exist( SaveFile ,'file') || x.OVERWRITE
        for j=1:9 % length(masks)
            for k=1:x.nSlicesLarge
                temp_im{j}(:,:,k)           = xASL_vis_CropParmsApply(xASL_im_rotate( mean(single(masks{j+5}(:,:,x.slicesLarge(k),:)),4) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
            end
            temp_view{j}                    = ind2rgb(round( xASL_vis_TileImages(temp_im{j}, 4)  ) .*255,x.colors_ROI{j});
        end
        total_view                          = zeros(size(temp_view{1},1),size(temp_view{1},2),size(temp_view{1},3));
        for j=1:9
            total_view                      = total_view + temp_view{j};
        end

        xASL_vis_Imwrite( total_view, SaveFile);
        clear temp_im temp_view ii j k total_view
    end

    % print GM & WM masks for all subjects
    clear temp_im
    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_1_GM_WM_masks_subjects_' x.PRE_POST '-DARTEL.jpg']);
     if ~exist( SaveFile ,'file') || x.OVERWRITE

        for iSubject=1:x.nSubjects
            for k=1:x.nSlices
                temp_im(:,:,iSubject*x.nSlices-(x.nSlices-k))          = xASL_vis_CropParmsApply(xASL_im_rotate( (0.5.* masks{1}(:,:,x.slices(k),iSubject)) + masks{2}(:,:,x.slices(k),iSubject) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
            end
        end
        fig = figure('Visible','off');
        imshow( xASL_vis_TileImages(temp_im, ceil(size(temp_im,3)^0.5/x.nSlices)*x.nSlices),'Colormap',x.colors_ROI{1});
        print(gcf,'-djpeg',['-r' num2str(x.DPI_im_SUBJECTS) ], SaveFile );
        close all
        clear temp_im ii k
    end

    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_2_vasc_masks_ASL_session1_subjects_' x.PRE_POST '-DARTEL.jpg']);
    if ~exist( SaveFile ,'file') || x.OVERWRITE
        % print vascular masks for all subjects over ASL (1st session)
        for j=3:5
            for ii=1:x.nSubjects
                for k=1:x.nSlices
                    temp_im{j}(:,:,(ii*4)-(4-k))    =xASL_vis_CropParmsApply(xASL_im_rotate( masks{j}(:,:,x.slices(k),ii) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
                    temp_ASL(:,:,(ii*4)-(4-k))      =xASL_vis_CropParmsApply(xASL_im_rotate( ASL(:,:,x.slices(k),1,ii)    ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
                end

            end
            temp_view{j}                            =ind2rgb(round( xASL_vis_TileImages(temp_im{j}, ceil(size(temp_im{j},3)^0.5/x.nSlices)*x.nSlices)  ) .*255,x.colors_ROI{j});
        end
        ASL_view                                    =ind2rgb(round( xASL_vis_TileImages(temp_ASL, ceil(size(temp_ASL,3)^0.5/x.nSlices)*x.nSlices)  ),x.colors_ROI{1});

        fig = figure('Visible','off');
        imshow( temp_view{3}+temp_view{4}+temp_view{5} + ASL_view );
        print(gcf,'-djpeg',['-r' num2str(x.DPI_im_SUBJECTS*2) ], SaveFile);
        close all
        clear temp_im temp_view temp_ASL temp_ASL ii j k
    end
    toc

    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_3_large_MNI_ASL_session1_subjects_' x.PRE_POST '-DARTEL.jpg']);
    if ~exist( SaveFile ,'file') || x.OVERWRITE
        % print vascular masks for all subjects over ASL (1st session)
        for j=1:9
            for ii=1:x.nSubjects
                for k=1:x.nSlices
                    temp_im{j}(:,:,(ii*4)-(4-k))    = xASL_vis_CropParmsApply(xASL_im_rotate( masks{j+5}(:,:,x.slices(k),  ii) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
                    temp_ASL(:,:,  (ii*4)-(4-k))    = xASL_vis_CropParmsApply(xASL_im_rotate(        ASL(:,:,x.slices(k),1,ii) ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
                end

            end
            temp_view{j}                            =ind2rgb(round( xASL_vis_TileImages(temp_im{j}, ceil(size(temp_im{j},3)^0.5/x.nSlices)*x.nSlices)  ) .*255,x.colors_ROI{j});
        end
        ASL_view                                    =ind2rgb(round( xASL_vis_TileImages(temp_ASL, ceil(size(temp_ASL,3)^0.5/x.nSlices)*x.nSlices)  ),x.colors_ROI{1});

        total_view                                  = zeros(size(temp_view{1},1),size(temp_view{1},2),size(temp_view{1},3));
        for j=1:9
            total_view                              = total_view + temp_view{j};
        end

        fig = figure('Visible','off');
        imshow( total_view + ASL_view );
        print(gcf,'-djpeg',['-r' num2str(x.DPI_im_SUBJECTS*2) ], SaveFile);
        close all
        clear temp_im temp_view temp_ASL temp_ASL ii j k
    end
    toc


    %% if post-DARTEL and small Harvard-Oxford atlas ROIs are desired, print extra ROI masks
if x.HO
    fprintf('%s\n','Visualizing post-DARTEL ROIs');
    tic
    % Harvard_Oxford cortical
    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_Harvard_Oxford_cortical.jpg']);

    for k=1:x.nSlicesLarge
        temp_im(:,:,k)               = xASL_vis_CropParmsApply(xASL_im_rotate( HO_cort_vis(:,:,x.slicesLarge(k))    ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
    end

    figure(1);imshow( xASL_vis_TileImages(temp_im, 4), [], 'colormap', jet256 );
    print(gcf,'-djpeg','-r200', SaveFile);
    close all
    clear temp_im k

    SaveFile               = fullfile(x.ANALYZEDIR,['ROIs_Harvard_Oxford_subcortical.jpg']);
        for k=1:x.nSlicesLarge
            temp_im(:,:,k)               = xASL_vis_CropParmsApply(xASL_im_rotate( HO_subc_vis(:,:,x.slicesLarge(k))    ,90),x.S.TransCrop(1),x.S.TransCrop(2),x.S.TransCrop(3),x.S.TransCrop(4));
        end

        % Remove GM & WM ROIs to show the subcortical ROIs only
        temp_im(temp_im==1 | temp_im==2 | temp_im==12 | temp_im==13)     =0;

        figure(1);imshow( xASL_vis_TileImages(temp_im, 4), [], 'colormap', jet256 );
        print(gcf,'-djpeg','-r200', SaveFile);
        close all
        clear temp_im k
    toc
end



end
