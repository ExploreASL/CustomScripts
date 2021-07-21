function json = xASL_adni_GetJsonGE(headerDCM, ADNI_VERSION, adniCases, iCase)
%xASL_adni_GetJsonGE Minor helper function
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Minor helper function.
%
% EXAMPLE:      json = xASL_adni_GetJsonGE(headerDCM, ADNI_VERSION, adniCases, iCase);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Tested with 027_S_5079

    % Create x struct
    json.x = struct;
    json.x.name = adniCases{iCase,1};
    % json.x.M0 = 'UseControlAsM0'; % 027_S_5079 should have M0 within the ASL sequence
    json.x.Q.LabelingType = 'PCASL';
    json.x.Quality = 1;
    json.x.Vendor = 'GE';
    if isfield(headerDCM,'GELabelingDuration')
        if isnumeric(headerDCM.GELabelingDuration)
            json.x.Q.Initial_PLD = headerDCM.GELabelingDuration; % I think there's a little mix-up here :)
        end
    end
    if isfield(headerDCM,'SeriesDescription')
        if ischar(headerDCM.SeriesDescription)
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PCASL'))
                json.x.Q.LabelingType = 'PCASL';
            end
        end
    end
    json.x.Q.LabelingDuration = 700;


end

