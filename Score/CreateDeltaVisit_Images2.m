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

ImTypes     = {'c1T1' 'c2T1' 'c3T1'};

if ~(length(UniqueVisits)>1)
    % skip code
else % there are multiple visits, run this code
    %% Create the diff images in standard space
    for iU=1:length(UniqueSubjects)
        if  sum(x.S.SetsID(:,Subj_set) == UniqueSubjects(iU))>1
            clear IM FP SubjID rFP DiffIM FileNativeS FileStandardS
            % for each subject with multiple visits
            DefineNames     = find(x.S.SetsID(:,Subj_set)==UniqueSubjects(iU));
            for iV=1:length(DefineNames)
                for iM=1:3
                    SubjID{iV}  = x.SUBJECTS{DefineNames(iV)};
                    FP{iV}{iM}  = fullfile(x.D.ROOT,SubjID{iV},[ImTypes{iM} '.nii']); % FP = FilePath
                    rFP{iV}{iM} = fullfile(x.D.ROOT,SubjID{iV},['r' ImTypes{iM} '.nii']); % rFP = resampled FilePath
                end
            end

            % Assuming 2 visits only!!!!!!! to be adapted later, by
            % doing mean difference from visit 1 or something like this
            % Also: this code assumes that c2T1 exists if c1T1 exists
            if  (exist(FP{1}{1},'file') || exist([FP{1}{1} '.gz'],'file')) && (exist(FP{2}{1},'file') || exist([FP{2}{1} '.gz'],'file'))
                % First create c3T1
                for iV=1:2
                    clear IM
                    for iM=1:2
                        IM(:,:,:,iM)    = xASL_io_Nifti2Im(FP{iV}{iM}); % make sure to unzip
                    end
                    IM(:,:,:,3)         = 1-IM(:,:,:,1)-IM(:,:,:,2);
                    xASL_io_SaveNifti(FP{iV}{1},FP{iV}{3},IM(:,:,:,3));
                end
                % Then reslice all 3, to be able to compute the difference
                % in the same space
                clear IM
                for iV=1:2
                    for iM=1:3
                        xASL_spm_reslice( x.D.ResliceRef, FP{iV}{iM},[],[], x.Quality, [ImTypes{iM} ' 2 MNI'], rFP{iV}{iM}, 1);
                        IM(:,:,:,iV,iM)    = xASL_io_Nifti2Im(rFP{iV}{iM});
                        IM(:,:,:,iV,iM)    = xASL_im_ndnanfilter(IM(:,:,:,iV,iM),'gauss',[1.885 1.885 1.885]); % smooth a bit
                        delete(rFP{iV}{iM});
                    end
                end

                if  size(IM,4)==2
                    for iM=1:3
                        DivideByIM      = IM(:,:,:,1,iM);
                        DivideByIM(DivideByIM<0.05)     = 1;
                        DiffIM          = (IM(:,:,:,1,iM) - IM(:,:,:,2,iM))./DivideByIM;
                        DiffIM(DiffIM<-10)  = -10; % clip
                        DiffIM(DiffIM> 10)  =  10; % clip
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
    end

    clear DiffIM
    for iM=1:3
        %% Process standard space files
        Flist   = xASL_adm_GetFileList(x.D.PopDir,['^LongDiff_' ImTypes{iM} '.*\.nii']);
        for iL=1:length(Flist)
            DiffIM{iM}(:,:,:,iL)    = xASL_io_Nifti2Im(Flist{iL});
        end
    end
    for iM=1:3
        meanDiff{iM}        = TransformDataViewDimension(100.*-xASL_stat_MeanNan(DiffIM{iM},4).*x.skull); % percentage, flip sign
%         SDdiff{iM}          = xASL_stat_StdNan(DiffIM{iM},[],4);
%         SNR{iM}             = meanDiff{iM}./SDdiff{iM};
    end
    end

jet_256                     = jet(256);
jet_256(128-16:128+16,:)    = 0; % middle 10% values removed

MinV        = -25;
MaxV        =  25;

BrainBack   = xASL_io_Nifti2Im(fullfile(x.TemplatesStudy,'T1_bs-mean.nii'));
BrainBack   = TransformDataViewDimension(BrainBack);
BrainBack   = double(round(255.*(BrainBack./max(BrainBack(:)))));
BrainBack   = repmat(BrainBack,[1 1 3])./256;

for iM=1:3
    figure(iM);imshow(meanDiff{iM},[-25 25],'Colormap',jet_256,'border','tight');
    F = getframe(gcf);
    [X{iM}, Map]        = frame2im(F);
    X{iM}               = double(X{iM});
    MaskIM{iM}          = repmat(meanDiff{iM}>=-5 & meanDiff{iM}<=5,[1 1 3]);
    X{iM}(MaskIM{iM})   = BrainBack(MaskIM{iM});
    close
end


figure(1);imshow(X{1},[])
