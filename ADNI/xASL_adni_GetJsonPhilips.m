function [json,studyPar] = xASL_adni_GetJsonPhilips(headerDCM, ADNI_VERSION, adniCases, iCase, studyPar)
%xASL_adni_GetJsonPhilips Minor helper function
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
% EXAMPLE:      json = xASL_adni_GetJsonPhilips(headerDCM, ADNI_VERSION, adniCases, iCase);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Relevant documents
    % http://adni.loni.usc.edu/wp-content/uploads/2010/05/ADNI3_Basic_Philips_R3.pdf      -> 2D EPI, PASL
    % http://adni.loni.usc.edu/wp-content/uploads/2017/09/ADNI-3-Basic-Philips-R5.pdf     -> 2D EPI, PASL
    % http://adni.loni.usc.edu/wp-content/uploads/2021/02/ADNI3_Philips_Adv_R56.pdf       -> 3D GRASE, PCASL

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
                json.x.Q.Initial_PLD = 2000;
                % I could not find this in the documents, but I'll assume they used the same labeling duration which was used for the 3D aquisitions
                json.x.Q.LabelingDuration = 1800;
                json.x.Sequence = '2D_EPI';
                json.x.Q.BackgroundSuppressionNumberPulses = 0;
            end
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PCASL'))
                json.x.Q.LabelingType = 'PCASL';
                json.x.Q.Initial_PLD = 2000;
                json.x.Q.LabelingDuration = 1800;
                json.x.Sequence = '3D_GRASE';
                % I could not find this in the documents, but I'll assume they did not use background suppression in 3D either
                json.x.Q.BackgroundSuppressionNumberPulses = 0;
            end
        end
    end
    
    if regexpi(json.x.Sequence,'2D')
        json.x.readout_dim = '2D';
    else
        json.x.readout_dim = '3D';
    end
    
    %% Fix study par
    studyPar = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar);


end
