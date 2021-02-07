function SaveHctCorrect_SubjectSession_SLEEP( x)
%SaveHctCorrect Corrects CBF-values for individual hematocrit or group hematocrit
%
% By HJMM Mutsaerts, ExploreASL 2016
% NB: this script assumes a single hct value for each subject (for all sessions)
% Ref: Patrick Hales, JCBFM 2015
%

    load( fullfile( x.D.ROOT, 'Mean_Hct_Session_Cohort' ) );
    HCTALL  = HCT;
    clear HCT
    x.P.CBF_Resliced  = 'DARTEL_CBF';




    %% 2    Create CBF maps corrected for individual Hct values

    for iSubject=1:x.nSubjects
        for iSession=1:x.nSessions
            WasFound        = 0;
            SubjectSessN    = (iSubject-1)*3+iSession;
            HCTvalue        = HCTALL(SubjectSessN,1);


                        %% convert to numeric if not numeric
                        if      HCTvalue>1 && HCTvalue<100 % get percentage
                                HCTvalue  = HCTvalue / 100;
                        end


                        %% Create corrected ASL maps
                        FileNameCBF         = fullfile( x.D.PopDir, [x.P.CBF_Resliced '_' x.SUBJECTS{iSubject} '_' x.SESSIONS{iSession} '.nii']);
                        FNsliceGradient     = fullfile( x.D.PopDir, ['DARTEL_slice_gradient_' x.SUBJECTS{iSubject} '_' x.SESSIONS{iSession} '.nii']);
                        FileNameCBFCorrInd  = fullfile( x.D.PopDir, [x.P.CBF_Resliced '_HctCorrInd_' x.SUBJECTS{iSubject} '_' x.SESSIONS{iSession} '.nii']);

                        tempIm              = xASL_io_ReadNifti( FileNameCBF );
                        tempIm              = tempIm.dat(:,:,:);
                        SliceGradient       = xASL_io_ReadNifti( FNsliceGradient );
                        SliceGradient       = SliceGradient.dat(:,:,:);

                        %% Create PLD gradient
                        if      isnumeric( x.Q.SliceReadoutTime )
                                PLDslicereadout     = x.Q.SliceReadoutTime;
                        end
                        SliceGradient   = x.Q.Initial_PLD + ((SliceGradient-1) .* PLDslicereadout); % effective PLD

                        T1aNew      = calc_blood_t1(HCTvalue, 0.97, 3) .* 1000; % with Y=0.97 and for B0=3T

                        lab_eff     = 0.83*0.85;

                        QntFactorOld    = exp(SliceGradient./x.Q.BloodT1) / (2.*lab_eff.*x.Q.BloodT1 .* (1- exp(-x.Q.LabelingDuration./x.Q.BloodT1)) );
                        QntFactorNew    = exp(SliceGradient./T1aNew ) / (2.*lab_eff.*T1aNew  .* (1- exp(-x.Q.LabelingDuration./T1aNew )) );

                        tempIm          = (tempIm .* QntFactorNew) ./ QntFactorOld;
                        xASL_io_SaveNifti( FileNameCBF, FileNameCBFCorrInd, tempIm );
                        clear T1aNew QntFactorOld QntFactorNew tempIm SliceGradient FileNameCBFCorrInd FNsliceGradient FileNameCBF
                        clear HCTvalue HCT HB B0 FE Y R1BL deltaT1BLOOD lab_eff SubjectSessN PLDslicereadout

                        WasFound = WasFound+1;
        end
    end

        % Notify missing hematocrit values
        if      WasFound==0
                fprintf('%s\n',[x.SUBJECTS{iSubject} ' was not found!!!']);
        elseif  WasFound>1
                fprintf('%s\n',['Duplicate hct values found for ' x.SUBJECTS{iSubject} '!!!']);
        end
        clear WasFound
    end


end
