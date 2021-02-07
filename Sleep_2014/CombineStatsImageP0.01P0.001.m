    %% Combine data from lenient & strict thresholds
    % First threshold was more lenient
    
    % First replace NaNs by zeros
    for iCon=1:length(DiffViewMeanCombi)
        DiffViewMeanCombi{iCon}(isnan(DiffViewMeanCombi{iCon}))     = 0;
        H_ttestContrastCombi{iCon}(isnan(H_ttestContrastCombi{iCon}))   = 0;
        H_ttestContrastCombi{iCon}  = logical(H_ttestContrastCombi{iCon});
    end
    
    DiffViewMean                            = DiffViewMeanCombi{1};
    DiffViewMean(DiffViewMeanCombi{1}==0)   = DiffViewMeanCombi{2}(DiffViewMeanCombi{1}==0);

    
%     % Combine contrasts
%     H_ttestContrastCombined     = H_ttestContrastCombi{1} | H_ttestContrastCombi{2};
%     
%     % Reduce intensity of first contrast, keep second the same
%     DiffViewMeanCombi{1}        = 0.5.*DiffViewMeanCombi{1};
%     DiffViewMeanCombi{2}        = 1  .*DiffViewMeanCombi{2};
%     %%%%%%%%%%%%%%%%%%%%% ->>>>>> THIS NEEDS TO BE DONE AFTER CONVERTING THE CONTRASTS TO COLOR
%     
% 
%     % Combine contrasts
%     DiffViewMeanCombined        = DiffViewMeanCombi{2};
%     ReplaceMask                 = H_ttestContrastCombi{1} & ~ H_ttestContrastCombi{2};
%     DiffViewMeanCombined(ReplaceMask)   = H_ttestContrastCombi{1}(ReplaceMask);
    
    xASL_spm_GLMsaveMatlab_StatsFigures(x, DiffViewMean, H_ttestContrastCombi{2},H_ttestContrastCombi{1});