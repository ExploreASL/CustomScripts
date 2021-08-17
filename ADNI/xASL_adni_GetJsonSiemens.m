function [json,studyPar] = xASL_adni_GetJsonSiemens(headerDCM, ADNI_VERSION, adniCases, iCase, studyPar, dcmPaths)
%xASL_adni_GetJsonSiemens Minor helper function
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
% EXAMPLE:      json = xASL_adni_GetJsonSiemens(headerDCM, ADNI_VERSION, adniCases, iCase);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Tested with 011_S_4105

    % Phoenix Protocol
    [xasl,parameters,parameterList,phoenixProtocol] = xASL_bids_GetPhoenixProtocol(dcmPaths{1},true);
    [xasl, json, studyPar] = xASL_adni_PhoenixFix(xasl, studyPar, ADNI_VERSION, adniCases, iCase);
    
    %% Fix study par
    [studyPar,json] = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar);

end

% Helper function
function [xasl, json, studyPar] = xASL_adni_PhoenixFix(xasl, studyPar, ADNI_VERSION, adniCases, iCase)

    if ~isfield(xasl,'SoftwareVersions')
        xasl.SoftwareVersions = 'unknown';
    end
    if ~isfield(xasl,'PulseSequenceType')
        xasl.PulseSequenceType = 'unknown';
    end

    % Add dataPar.json
    if ADNI_VERSION==2
        xasl.PLD = 1900;
    else
        xasl.PLD = 2000;
    end
    xasl.labelingDuration = 700;

    if regexpi(xasl.PulseSequenceType,'2D')
        xasl.M0inASLsequence = 1;
    else
        xasl.M0inASLsequence = 0;
    end

    % Fix slice timings
    if regexpi(xasl.SoftwareVersions,'B15')
        if regexpi(xasl.PulseSequenceType,'2D')
            studyPar.SliceTiming = {0,0.0275,0.0575,0.085,0.115,0.1425,0.1725,...
                0.2025,0.23,0.26,0.2875,0.3175,0.345,...
                0.375,0.405,0.4325,0.4625,0.49,0.52,...
                0.55,0.5775,0.6075,0.635,0.665};
        end
    else
        if regexpi(xasl.PulseSequenceType,'2D')
            if isfield(studyPar,'SliceTiming')
                studyPar = rmfield(studyPar,'SliceTiming');
            end
        end
    end

    if regexpi(xasl.PulseSequenceType,'3D')
        if isfield(studyPar,'SliceTiming')
            studyPar = rmfield(studyPar,'SliceTiming');
        end
    end

    % Create x struct
    json.x = struct;
    json.x.dataset.name = adniCases{iCase,1};
    %json.x.subject_regexp = '';
    if xasl.M0inASLsequence
        json.x.modules.asl.M0PositionInASL4D = 1;
    else
        json.x.Q.M0 = 'UseControlAsM0';
    end
    json.x.Q.LabelingType = 'PASL';
    json.x.Q.Initial_PLD = xasl.PLD;
    json.x.Q.LabelingDuration = xasl.labelingDuration;
    % json.x.Q.SliceReadoutTime = xasl.sliceReadoutTime;
    if regexpi(xasl.PulseSequenceType,'2D')
        json.x.Q.readoutDim = '2D';
    else
        json.x.Q.readoutDim = '3D';
    end
    json.x.settings.Quality = 1;
    % json.x.Vendor = 'Siemens'; % This is added to the studyPar.json now
    
    if strcmp(json.x.Q.readoutDim,'2D')
        json.x.Q.Sequence = '2D_EPI';
    else
        json.x.Q.Sequence = '3D_GRASE';
    end


end


