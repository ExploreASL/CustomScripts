function [json,studyPar] = xASL_adni_GetJsonGE(dataset, headerDCM, ADNI_VERSION, adniCases, iCase, studyPar)
%xASL_adni_GetJsonGE Minor helper function
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Minor helper function.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      json = xASL_adni_GetJsonGE(headerDCM, ADNI_VERSION, adniCases, iCase);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Relevant documents
    % http://adni.loni.usc.edu/wp-content/uploads/2010/05/ADNI3_Basic_GE_Widebore_2025x.pdf
    % http://adni.loni.usc.edu/wp-content/uploads/2010/05/ADNI3_Basic_GE_25x.pdf

    % Tested with 027_S_5079

    % Create x struct
    json.x = struct;
    json.x.dataset.name = adniCases{iCase,1};
    % json.x.Q.M0 = 'separate_scan'; % The M0 scan is included in the ASL sequence, but should be separated by the import workflow. We automatically set this using the studyPar though.
    % json.x.Q.LabelingType = 'PCASL';
    json.x.settings.Quality = 1;
    % json.x.Vendor = 'GE'; % This is added to the studyPar.json now
    % Fallback values
    json.x.Q.Initial_PLD = 2025;
    json.x.Q.LabelingDuration = 700;
    % I think there's a little mix-up here between PLD and Labeling Duration
    if isfield(headerDCM,'GELabelingDuration')
        if isnumeric(headerDCM.GELabelingDuration)
            json.x.Q.LabelingDuration = headerDCM.GELabelingDuration;
        end
    end
    % We use PCASL on default anyway, but it should also be in the series description
    if isfield(headerDCM,'SeriesDescription')
        if ischar(headerDCM.SeriesDescription)
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PCASL'))
                json.x.Q.LabelingType = 'PCASL';
            end
        end
    end
    
    % The ADNI GE scanners only use 3D spiral
    json.x.Q.Sequence = '3D_spiral';
    
    if regexpi(json.x.Q.Sequence,'2D')
        json.x.Q.readoutDim = '2D';
    else
        json.x.Q.readoutDim = '3D';
    end
    
    %% Fix study par
    [studyPar,json] = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar);
    
    % GE should have Background suppression
    studyPar.BackgroundSuppression = true;
    studyPar.LabelingDuration = 1.45;
    studyPar.BackgroundSuppressionNumberPulses = 4;
    studyPar.BackgroundSuppressionPulseTime = {1.465, 2.1, 2.6, 2.88};
    

end

