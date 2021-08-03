function [json,studyPar] = xASL_adni_GetJsonGE(headerDCM, ADNI_VERSION, adniCases, iCase, studyPar)
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
    json.x.name = adniCases{iCase,1};
    % The M0 scan is included in the ASL sequence, but should be separated by the import workflow
    json.x.M0 = 'separate_scan';
    json.x.Q.LabelingType = 'PCASL';
    json.x.Quality = 1;
    json.x.Vendor = 'GE';
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
    json.x.Sequence = '3D_spiral';
    
    if regexpi(json.x.Sequence,'2D')
        json.x.readout_dim = '2D';
    else
        json.x.readout_dim = '3D';
    end
    
    %% Fix study par
    studyPar = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar);
    

end

