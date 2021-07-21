function json = xASL_adni_GetJsonPhilips(headerDCM, ADNI_VERSION, adniCases, iCase)
%xASL_adni_GetJsonPhilips Minor helper function
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Minor helper function.
%
% EXAMPLE:      json = xASL_adni_GetJsonPhilips(headerDCM, ADNI_VERSION, adniCases, iCase);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Tested with 006_S_6681

    % Create x struct
    json.x = struct;
    json.x.name = adniCases{iCase,1};
    json.x.M0 = 'UseControlAsM0';
    json.x.Q.LabelingType = 'PASL';
    json.x.Quality = 1;
    json.x.Vendor = 'Philips';
    if isfield(headerDCM,'SeriesDescription')
        if ischar(headerDCM.SeriesDescription)
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PASL'))
                json.x.Q.LabelingType = 'PASL';
            end
        end
    end


end

