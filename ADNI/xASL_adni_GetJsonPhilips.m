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
    json.x.dataset.name = adniCases{iCase,1};
    json.x.Q.M0 = 3.7394*10^6; % We have to use a fixed number, because we only have deltam and no M0 scan
    json.x.Q.LabelingType = 'PASL';
    json.x.settings.Quality = 1;
    % json.x.Vendor = 'Philips'; % This is added to the studyPar.json now
    
    if isfield(headerDCM,'SeriesDescription')
        if ischar(headerDCM.SeriesDescription)
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PASL'))
                json.x.Q.LabelingType = 'PASL';
                json.x.Q.Initial_PLD = 2000;
                % I could not find this in the documents, but I'll assume they used the same labeling duration which was used for the 3D aquisitions
                json.x.Q.LabelingDuration = 1800;
                json.x.Q.Sequence = '2D_EPI';
                json.x.Q.BackgroundSuppressionNumberPulses = 0;
            end
            if ~isempty(regexpi(headerDCM.SeriesDescription,'PCASL'))
                json.x.Q.LabelingType = 'PCASL';
                json.x.Q.Initial_PLD = 2000;
                json.x.Q.LabelingDuration = 1800;
                json.x.Q.Sequence = '3D_GRASE';
                % I could not find this in the documents, but I'll assume they did not use background suppression in 3D either
                json.x.Q.BackgroundSuppressionNumberPulses = 0;
            end
        end
    end
    
    if regexpi(json.x.Q.Sequence,'2D')
        json.x.Q.readoutDim = '2D';
    else
        json.x.Q.readoutDim = '3D';
    end
    
    if isfield(headerDCM,'SoftwareVersions')
        if strcmp(json.x.Q.readoutDim,'2D')
            % R3 & R5 have different slice timing vectors
            softwareVersion = headerDCM.SoftwareVersions;
            softwareVersion = str2num(softwareVersion(1));
            % I assume 40 acquisitions here
            switch softwareVersion
                case 3
                    studyPar.SliceTiming = (3238-2000)/40; % Min TR 3238, PLD 2000
                case 5
                    studyPar.SliceTiming = (3679-2000)/40; % Min TR 3679, PLD 2000
                otherwise
                    studyPar.SliceTiming = (3238-2000)/40; % We assume the older version here
            end
        end
    end
    
    %% Fix study par
    [studyPar,json] = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar);


end

