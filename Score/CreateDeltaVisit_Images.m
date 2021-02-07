%% Create deltaVisit images

%% First check if there are multiple visits
% Find LongitudinalTimePoint variable

clear meanDiff DiffIM Flist LTP_set Subj_set UniqueSubjects UniqueVisits
clear ImTypes iM iU DefineNames iV SubjID FP rFP IM

LTP_set         = find(strcmp(x.S.SetsName,'LongitudinalTimePoint'));
Subj_set        = find(strcmp(x.S.SetsName,'SubjectNList'));

UniqueSubjects  = unique(x.S.SetsID(:,Subj_set));
UniqueVisits    = unique(x.S.SetsID(:,LTP_set)); % according to BIDS, we should
% call these "visits" rather than TimePoints

ImTypes     = {'c1T1' 'c2T1' 'T1'};

if ~(length(UniqueVisits)>1)
    % skip code
else % there are multiple visits, run this code
    for iM=1:length(ImTypes)
        %% Create the diff images in standard space
        for iU=1:length(UniqueSubjects)
            if  sum(x.S.SetsID(:,Subj_set) == UniqueSubjects(iU))>1
                clear IM FP SubjID rFP DiffIM FileNativeS FileStandardS
                % for each subject with multiple visits
                DefineNames     = find(x.S.SetsID(:,Subj_set)==UniqueSubjects(iU));
                for iV=1:length(DefineNames)
                    SubjID{iV}  = x.SUBJECTS{DefineNames(iV)};
                    FP{iV}      = fullfile(x.D.ROOT,SubjID{iV},[ImTypes{iM} '.nii']); % FP = FilePath
                    rFP{iV}     = fullfile(x.D.ROOT,SubjID{iV},['r' ImTypes{iM} '.nii']); % rFP = resampled FilePath
                end

                % Assuming 2 visits only!!!!!!! to be adapted later, by
                % doing mean difference from visit 1 or something like this
                if  (exist(FP{1},'file') || exist([FP{1} '.gz'],'file')) && (exist(FP{2},'file') || exist([FP{2} '.gz'],'file'))
                    for iV=1:2
                        xASL_io_ReadNifti(FP{iV}); % make sure to unzip
                        xASL_spm_reslice( x.D.ResliceRef, FP{iV},[],[], x.Quality, [ImTypes{iM} ' 2 MNI'], rFP{iV}, 1);
                        IM(:,:,:,iV)    = xASL_io_Nifti2Im(rFP{iV});
                        IM(:,:,:,iV)    = xASL_im_ndnanfilter(IM(:,:,:,iV),'gauss',[1.885 1.885 1.885]); % smooth a bit
                        delete(rFP{iV});
                    end

                    if  size(IM,4)==2
                        DiffIM          = (IM(:,:,:,1) - IM(:,:,:,2))./IM(:,:,:,1);
                        DiffIM          = xASL_im_ndnanfilter(DiffIM,'gauss',[1.885 1.885 1.885]); % smooth a bit more
                        FileNativeS     = fullfile(x.D.ROOT,SubjID{1},['LongDiff_' ImTypes{iM} '.nii']);
                        FileStandardS   = fullfile(x.D.PopDir,['LongDiff_' ImTypes{iM} '_' SubjID{1} '_.nii']);
                        xASL_io_SaveNifti(x.D.ResliceRef,FileNativeS,DiffIM);
                        xASL_spm_deformations(x,SubjID{1},FileNativeS,FileStandardS,1);
                        delete(FileNativeS);
                    end
                end
            end
        end

        %% Process standard space files
        Flist   = xASL_adm_GetFileList(x.D.PopDir,['^LongDiff_' ImTypes{iM} '.*\.nii']);
        clear DiffIM
        for iL=1:length(Flist)
            DiffIM{iM}(:,:,:,iL)    = xASL_io_Nifti2Im(Flist{iL});
        end

        meanDiff{iM}        = xASL_stat_MeanNan(DiffIM{iM},4);
    end
end

for iM=1:3
    meanDiff{iM}            = meanDiff{iM}.*x.skull;
    figure(iM);imshow(imrotate(meanDiff{iM}(:,:,53),90),[-0.1 0.1],'Colormap',jet,'border','tight');
end

dip_image(x.WBmask)
