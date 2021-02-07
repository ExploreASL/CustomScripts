ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel';
ROOT_PVEc   = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\PVEc_VBA\';

Vendors     = {'GE' 'PH_Achieva_Bsup' 'PH_Achieva_noBsup' 'SI_Trio'};
TissueType  = {'GM' 'WM'};

for PV=1:4
    for TT=1:2
        for iV=1:4
            if  PV==2 && TT==2
                % skip, this one is not tissue-specific
            else

                if  PV==2 % no PVEc
                    Flist      = xASL_adm_GetFileList(ROOT, ['^qCBF_' Vendors{iV} '_(C9ORF|GRN|MAPT)\d{3}_(1|2)_ASL_1\.(nii|nii\.gz)$']);
                    SaveName    = ['qCBF_' Vendors{iV}];
                elseif  PV==3 % different Bspline kernel
                    Flist   = xASL_adm_GetFileList(ROOT, ['^qCBF_' TissueType{TT} '_PVEC_' Vendors{iV} '_(C9ORF|GRN|MAPT)\d{3}_(1|2)_ASL_1_21\.(nii|nii\.gz)$']);
                    SaveName    = ['qCBF_PVEc_21_' TissueType{TT} '_' Vendors{iV}];
                elseif PV==4
                    Flist   = xASL_adm_GetFileList(ROOT, ['^PV_p' TissueType{TT} '_' Vendors{iV} '_(C9ORF|GRN|MAPT)\d{3}_(1|2)\.(nii|nii\.gz)$']);
                    SaveName    = ['p' TissueType{TT} '_' Vendors{iV}];
                else % PVEc
                    Flist   = xASL_adm_GetFileList(ROOT, ['^qCBF_' TissueType{TT} '_PVEC_' Vendors{iV} '_(C9ORF|GRN|MAPT)\d{3}_(1|2)_ASL_1\.(nii|nii\.gz)$']);
                    SaveName    = ['qCBF_PVEc_14_' TissueType{TT} '_' Vendors{iV}];
                end

                for iF=1:length(Flist)
                    clear tIM
                    tIM                 = xASL_nifti(Flist{iF});
                    IM{iV}(:,:,:,iF,PV) = tIM.dat(:,:,:);
                end

                IMmean(:,:,:,iV,TT,PV)  = xASL_stat_MeanNan(IM{iV}(:,:,:,:,PV),4);
                 IMstd(:,:,:,iV,TT,PV)  =  xASL_stat_StdNan(IM{iV}(:,:,:,:,PV),[],4);

                 xASL_io_SaveNifti( Flist{1}, fullfile(ROOT_PVEc, [SaveName '_mean.nii']), IMmean(:,:,:,iV,TT,PV));
                 xASL_io_SaveNifti( Flist{1}, fullfile(ROOT_PVEc, [SaveName '_std.nii']), IMstd(:,:,:,iV,TT,PV));

                 %% Show mean

                IMmeanTile(:,:,iV,TT,PV)= TransformDataViewDimension( IMmean(:,:,:,iV,TT,PV) );
                fig = figure('Visible','off');

                if      TT==1
                        imshow(IMmeanTile(:,:,iV,TT,PV),[0 200],'colormap',jet); % GM
                else    imshow(IMmeanTile(:,:,iV,TT,PV),[0  60],'colormap',jet); % WM
                end

                colorbar;
                print(gcf,'-djpeg','-r300', fullfile(ROOT_PVEc,[SaveName '_mean.jpg']));

                %% Show STD
                IMmeanTile(:,:,iV,TT,PV)= TransformDataViewDimension( IMstd(:,:,:,iV,TT,PV) );
                fig = figure('Visible','off');

                if      TT==1
                        imshow(IMmeanTile(:,:,iV,TT,PV),[0 100],'colormap',jet); % GM
                else    imshow(IMmeanTile(:,:,iV,TT,PV),[0  30],'colormap',jet); % WM
                end

                colorbar;
                print(gcf,'-djpeg','-r300', fullfile(ROOT_PVEc,[SaveName '_std.jpg']));

                clear Flist IM SaveName
            end
        end
    end
end

%% Resolution estimation

ROOT        = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel';
ROOT_PVEc   = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\ResolutionEstimation\';

Vendors     = {'GE'        'PH_Achieva_Bsup' 'PH_Achieva_noBsup' 'SI_Trio'};
Sequence    = {'3D spiral' '2D EPI Bsup'     '2D EPI noBsup'     '3D GRASE'};
NextN       = [1 1 1 1];

for iS=1:x.nSubjects
    clear LoadFile
    LoadFile    = fullfile(ROOT_PVEc,[x.SUBJECTS{iS} '.mat']);
    if  ~exist(LoadFile,'file')
        % Skip
    else
        LoadFile    = load(LoadFile);

        for iV=1:length(Vendors)
            if  ~isempty(findstr(x.SUBJECTS{iS},Vendors{iV}))
                ResFWHM{iV}(NextN(iV),:)  = LoadFile.optimFWHM;
                CBFratio{iV}(NextN(iV),:) = LoadFile.optimRatio;
                NextN(iV)   = NextN(iV)+1;
            end
        end
    end
end



for iV=1:4
    clear MeanVendor stdVendor N X
    MeanVendor  = mean(ResFWHM{iV},1);
    stdVendor   = std(ResFWHM{iV},1);
    [N X]   = hist(ResFWHM{iV},25);
    fig = figure('Visible','off');plot(X,N);
    xlabel('FWHM (mm) for X (green) Y (blue) Z (red)');
    title([Sequence{iV} ', mean ' num2str(MeanVendor(1)) 'x' num2str(MeanVendor(2)) 'x' num2str(MeanVendor(3)) ', SD ' num2str(stdVendor(1)) 'x' num2str(stdVendor(2)) 'x' num2str(stdVendor(3))]);
    ylabel('Frequency');

    saveFile    = fullfile(ROOT_PVEc, [Sequence{iV} '.jpg']);

    print(gcf,'-djpeg','-r150', saveFile);
end

for iV=1:4
    clear MeanVendor stdVendor N X
    MeanVendor  = mean(CBFratio{iV},1);
    stdVendor   = std(CBFratio{iV},1);
    [N X]   = hist(CBFratio{iV},25);
    fig = figure('Visible','off');plot(X,N);
    xlabel('Ratio for X');
    title([Sequence{iV} ', mean ' num2str(MeanVendor(1)) ', SD ' num2str(stdVendor(1))]);
    ylabel('Frequency');

    saveFile    = fullfile(ROOT_PVEc, [Sequence{iV} '_CBFratio.jpg']);

    print(gcf,'-djpeg','-r150', saveFile);
end
