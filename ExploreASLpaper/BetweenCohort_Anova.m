x = ExploreASL_Master('',0);

%% Compare between-cohort ANOVA test
EPAD = 0;
EPAD=EPAD(isfinite(EPAD));

% New pipeline

ROOT{1}     = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/analysis_NOVICE/Population/Stats'; % diseased kids
ROOT{2}     = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/analysis_Sleep/Population/Stats'; % healthy adults
ROOT{3}     = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/analysis_EPAD/Population/Stats'; % diseased elderly

ROOT{4}     = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/FeaturesDisabled_NOVICE/Population/Stats'; % diseased kids
ROOT{5}     = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/FeaturesDisabled_Sleep/Population/Stats'; % healthy adults
ROOT{6}     = '/Users/henk/ExploreASL/ASL/ExploreASL_Manuscript/FeaturesDisabled_EPAD/Population/Stats'; % diseased elderly

for iCohort=1:6
    if ~exist(ROOT{iCohort},'dir')
        warning('Dir doesnt exist');
    end
    ExcelPath = xASL_adm_GetFileList(ROOT{iCohort}, '^mean_qCBF.*_TotalGM.*_PVC2\.tsv$','FPList');
    if length(ExcelPath)~=1
        warning('Invalid filelist');
    else
        [~, TempCell] = xASL_adm_csv2tsv(ExcelPath{1}, 0, 0);
        DataIs = TempCell(3:end,end-2);
        clear DataNumeric;
        for iData=1:length(DataIs)
            if strcmp(DataIs{iData},'n/a')
                DataNumeric(iData) = NaN;
            else
                DataNumeric(iData) = xASL_str2num(DataIs{iData});
            end
        end
        DataNumeric = DataNumeric(isfinite(DataNumeric) & DataNumeric~=0)';
    end
    CohortData{iCohort} = DataNumeric;
end