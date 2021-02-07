function x = xASL_wrp_SpatialCovGMCovariate( x, INPUT )
%SpatialCoV_GM_covariate Sort subjects for spatial Coefficient of Variation
% % check whether 2-sample t-test stats improve by adding subjects

% From the idea that more artifacts (motion, macro-vascular artifact etc)
% simply give higher CV within GM-mask


%% Administration
SkipThis    = 0;

if      strcmp(INPUT,'ASL_untreated')
        LoadFile        = fullfile(x.D.PopDir, [INPUT '.dat']);

        if ~exist(LoadFile,'file')
            SkipThis    = 1;
            fprintf('%s\n','Skipping spatial CoV calculation because no valid memory mapping file found');
        else

            ASL_untreated   = memmapfile(LoadFile,'Format',{'single' [x.nSubjectsSessions 121 145 121] 'data'});
            VarName         = 'CBF_spatial_CoV';
            VarNameNorm     = 'CBF_spatial_CoV_norm'; % Normalized by the expected GM covariance due to structure
            PseudoName      = 'PseudoCBF_spatial_CoV';
        end
elseif  strcmp(INPUT,'ASL_HctCorrInd')
        LoadFile        = fullfile(x.D.PopDir, [INPUT '.dat']);

        if ~exist(LoadFile,'file')
            SkipThis    = 1;
            fprintf('%s\n','Skipping spatial CoV calculation because no valid memory mapping file found');
        else
            ASL_untreated   = memmapfile(LoadFile,'Format',{'single' [x.nSubjectsSessions 121 145 121] 'data'});
            VarName         = 'CBF_spatial_CoV_HCT';
            VarNameNorm     = 'CBF_spatial_CoV_norm_HCT';
            PseudoName      = 'PseudoCBF_spatial_CoV_HCT';
            warning('Make sure that these ASL images are not treated for vascular artifacts');
        end
end

if ~SkipThis

    % Load the pGM and pWM for CoV normalization
    LoadFile        = fullfile(x.D.PopDir, 'PV_pGM.dat');
    if  exist(LoadFile,'file')
        PV_pGM          = memmapfile(LoadFile,'Format',{'single' [x.nSubjects 121 145 121] 'data'});
    else
        for iS=1:x.nSubjects
            PV_pGM.Data.data(iS,:,:,:)  = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['PV_pGM_' x.SUBJECTS{iS} '.nii']));
        end
    end

    LoadFile        = fullfile(x.D.PopDir, 'PV_pWM.dat');
    if  exist(LoadFile,'file')
        PV_pWM          = memmapfile(LoadFile,'Format',{'single' [x.nSubjects 121 145 121] 'data'});
    else
        for iS=1:x.nSubjects
            PV_pWM.Data.data(iS,:,:,:)  = xASL_io_Nifti2Im(fullfile(x.D.PopDir,['PV_pWM_' x.SUBJECTS{iS} '.nii']));
        end
    end

    matName         = fullfile( x.D.ROOT, [VarName '.mat']);
    matNameNorm     = fullfile( x.D.ROOT, [VarNameNorm '.mat']);
    PseudoName      = fullfile( x.D.ROOT, [PseudoName '.mat']);
    xASL_adm_CreateDir(x.ExclusionDir);
    SaveGraph   = fullfile(x.ExclusionDir, ['ContributeValue' VarName '.jpg']);

    if  exist(matName,'file') && exist(matNameNorm,'file')
        %% Skip because already ran apparently

    else    %% Obtain CoV

        %% First create narrow GM mask for high sensitivity & speed

        mask        = xASL_io_Nifti2Im(x.D.ResliceRef);

        for iSlice=1:size(mask,3)
            mask(:,:,iSlice)       = mask(:,:,iSlice)> (0.5          * max(max((mask(:,:,iSlice)))));
    %         mask(:,:,iSlice)       = mask(:,:,iSlice)> (0.65          * max(max((mask(:,:,iSlice)))));
        end

        mask(:,:,1:40)      = 0; % don't let lower slices count
        mask(:,:,101:end)   = 0; % here are NaNs only
        mask                = logical(mask);

        %% Save CoV (Coefficient of Variation)
        %% & do statistical test to test outliers

        clear CVList IM

        fprintf('Acquiring spatial CoV:   ');
        for iF=1:length(x.SUBJECTS)
            xASL_TrackProgress(iF,length(x.SUBJECTS));
            for iS=1:length(x.SESSIONS)
                iSubjSess   = (iF-1)*x.nSessions+iS;
                clear tnii tmp tpseudoCBF

				FName{iSubjSess}    = [x.P.CBF_Resliced '_' x.SUBJECTS{iF} '_' x.SESSIONS{iS} '.nii'];

                tnii                = squeeze(ASL_untreated.Data.data(iSubjSess,:,:,:));
				% tnii                = xASL_io_ReadNifti( fullfile(x.D.PopDir, FName{iSubjSess}) );
				% tnii                = tnii.dat(:,:,:);

	            IM(:,:,:,iSubjSess) = tnii;

	            tpseudoCBF          = squeeze(PV_pGM.Data.data(iF,:,:,:) + 0.3*PV_pWM.Data.data(iF,:,:,:));
                tmp                 = tnii(mask);
                tpseudoCBF          = tpseudoCBF(mask);
                tcov                = xASL_stat_StdNan(tmp(:) )./xASL_stat_MeanNan(tmp(:));
                PseudoCoV           = xASL_stat_StdNan(tpseudoCBF(:) )./xASL_stat_MeanNan(tpseudoCBF(:));

                CVList(iSubjSess,1)             = tcov;
                CBF_spatial_CoV{iSubjSess,1}    = x.SUBJECTS{iF};
                CBF_spatial_CoV{iSubjSess,2}    = x.SESSIONS{iS};
                CBF_spatial_CoV{iSubjSess,3}    = CVList(iSubjSess,1);

                PseudoCBF_spatial_CoV{iSubjSess,1}    = x.SUBJECTS{iF};
                PseudoCBF_spatial_CoV{iSubjSess,2}    = x.SESSIONS{iS};
                PseudoCBF_spatial_CoV{iSubjSess,3}    = PseudoCoV;

                CBF_spatial_CoV_norm{iSubjSess,1}    = x.SUBJECTS{iF};
                CBF_spatial_CoV_norm{iSubjSess,2}    = x.SESSIONS{iS};
                CBF_spatial_CoV_norm{iSubjSess,3}    = tcov./PseudoCoV;
            end
        end

        %% Save mat-file for statistics later in pipeline

        save( matName ,     'CBF_spatial_CoV');
        save( matNameNorm , 'CBF_spatial_CoV_norm');
        save( PseudoName,   'PseudoCBF_spatial_CoV');

        %% Create p-Value Figure

        if size(CVList,2)>1

            CVList(:,2)         = [1:length(CVList)];
            CVListNew           = sortrows(CVList,1);

            for iF=1:length(CVListNew)
                clear TEMP
            %         FListSort{iF,1} = FList{CVListNew(iF,2)};
                TEMP            = IM(:,:,:,CVListNew(iF,2));
                IMsort(:,iF)    = TEMP(mask);
            end

        %     IMsort(isnan(IMsort))   =  0;
            IMsort=IMsort./xASL_stat_MeanNan(IMsort(:)).*50;

            for iF=2:size(IMsort,2)
                clear H P
                [H,P,ci,stats]      = xASL_stat_ttest(IMsort(:,1:iF),0,0.05,'both',2);
                tValue(iF,1)        = mean(stats.tstat(isfinite(stats.tstat)));
        %         pValueMedian(iF,1)        = xASL_stat_MedianNan(P);
        %         pValueMin(iF,1)        = min(P);
        %         pValueMax(iF,1)        = max(P);

            end


            fig = figure('Visible','off');
        %     axis([0 141 0 0.02])
            plot(tValue,'b')

        %     plot(pValue,'b')
            xlabel('nSubjectSessions sorted for CoV');
            ylabel('mean GM t-stat for detecting significant perfusion');
            title('ContributeValueSubjectSessions, mean voxel-wise 1-sample t-test');
            saveas(fig,SaveGraph,'jpg');
            fprintf('Saving %s\n',SaveGraph);
            close all;
            clear fig

            INDEXn  = round(0.5*length(tValue));
            maxT    = find(tValue(INDEXn:end)==max(tValue(INDEXn:end)))+INDEXn-1;



            %% Save names to be excluded
            ExclusionNames  = '';
            ExclNameMat   = fullfile(x.ExclusionDir,['ExclusionNames_' VarName '.mat']);
            for iI=maxT+1:length(CVListNew)
                ExclusionNames{length(ExclusionNames)+1,1}    = FName{CVListNew(iI,2)};
            end
            save(ExclNameMat,'ExclusionNames');
        end

    end

end
end

%    CVList(:,2)         = [1:length(CBF_spatial_CoV)];
%    CVListNew           = sortrows(CVList,1);

%    for iC=1:size(CVListNew,1)
%        Spatial_CoV_sorted{iC,1}    = CVListNew(iC,1);
%        Spatial_CoV_sorted{iC,2}    = CBF_spatial_CoV{CVListNew(iC,2),1};
%    end
%
%    0.95*size(CVListNew,1)
