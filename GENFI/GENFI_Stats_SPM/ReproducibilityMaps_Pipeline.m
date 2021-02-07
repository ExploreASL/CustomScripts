%% Create reproducibility maps ExploreASL on GENFI data

%% Load data
DataRoot{1}         = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel';
DataRoot{2}         = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel';

TotalMask           = xASL_nifti(fullfile( DataRoot{2}, 'GMSliceMask.nii'));
TotalMask           = TotalMask.dat(:,:,:);

for ii=1:2
    DataList{ii}    = xASL_adm_GetFileList(DataRoot{ii},'^qCBF_(GE|PH|SI).*(C9ORF|GRN|MAPT)\d{3}_(1|2|3)_ASL_1\.(nii|nii\.gz)$');
end

% Load data from new dataset (n=374) these are all scans after QC
qCBFindex           = 6;
for iS=1:length(DataList{2})
    [Path File Ext]     = fileparts(DataList{2}{iS});
    if     ~isempty(findstr(File,'GE'))
            Index           = 3;
    elseif ~isempty(findstr(File,'PH_Achieva_Bsup'))
            Index           = 16;
    elseif ~isempty(findstr(File,'PH_Achieva_noBsup'))
            Index           = 18;
    elseif ~isempty(findstr(File,'SI_Trio'))
            Index           = 8;
    end

    SubjectName{iS,1}     = File(qCBFindex+Index:end-6);
end

% Check whether "twin-names" exist
for iS=1:length(SubjectName)
    for iB=1:length(SubjectName)
        if  iB~=iS
            % give error if names are the same (i.e. double incidence in list)
            if  strcmp(SubjectName{iS,1},SubjectName{iB,1})
                error('Double names');
            end
        end
    end
end

%% Load images
for iS=1:length(SubjectName)
    for ii=1:2
        clear ProcessedNII
        ProcessedNII            = 0;
        for iB=1:length(DataList{ii})
            clear Path File Ext
            [Path File Ext]     = fileparts(DataList{ii}{iB,1});

            if  ~isempty(findstr(SubjectName{iS,1},File))
                if  ProcessedNII==1
                    error('NII already found previously, double names');
                else
                    clear tIM
                    tIM             = xASL_nifti(DataList{ii}{iB,1});
                    IM(:,:,:,iS,ii) = single(tIM.dat(:,:,:));
                    ProcessedNII    = 1;
                end
            end
        end
    end
end

%% Smooth images
for iS=1:size(IM,4)
    for ii=1:2
        IM(:,:,:,iS,ii)     = IM(:,:,:,iS,ii).*TotalMask;
        IM(:,:,:,iS,ii)     = xASL_im_ndnanfilter( IM(:,:,:,iS,ii) ,'gauss',[3.76 3.76 3.76],1);
    end
end

%% Compute reproducibility
MeanIM                      = squeeze(xASL_stat_MeanNan(xASL_stat_MeanNan(IM,4),5));
DiffIM                      = squeeze(IM(:,:,:,:,1)-IM(:,:,:,:,2));
MeanDiff                    = xASL_stat_MeanNan(DiffIM,4);
SDdiffIM                    = xASL_stat_StdNan(DiffIM,[],4);
wsCV                        = (SDdiffIM./MeanIM).*100.*TotalMask;

xASL_io_SaveNifti( fullfile( DataRoot{2}, 'GMSliceMask.nii'), fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long','ExploreASL_repro_meanIM.nii'),MeanIM);
xASL_io_SaveNifti( fullfile( DataRoot{2}, 'GMSliceMask.nii'), fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long','ExploreASL_repro_diffIM.nii'),MeanDiff);
xASL_io_SaveNifti( fullfile( DataRoot{2}, 'GMSliceMask.nii'), fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long','ExploreASL_repro_SDdiffIM.nii'),SDdiffIM);
xASL_io_SaveNifti( fullfile( DataRoot{2}, 'GMSliceMask.nii'), fullfile('C:\Backup\ASL\GENFI\GENFI_DF2_2_Long','ExploreASL_repro_wsCV.nii'),wsCV);

wsCV_view = TransformDataViewDimension( wsCV);

figure(1);imshow(wsCV_view,[0 20],'InitialMagnification',250,'colormap',jet)
