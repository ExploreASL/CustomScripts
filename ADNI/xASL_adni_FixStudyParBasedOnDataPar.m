function [studyPar,json] = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar)
%xASL_adni_FixStudyParBasedOnDataPar Minor helper function
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
% EXAMPLE:      studyPar = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Previously we used json.x.Vendor instead of studyPar.Manufacturer

    if isfield(json.x.Q,'LabelingType')
        studyPar.ArterialSpinLabelingType = json.x.Q.LabelingType;
        studyPar.LabelingType = json.x.Q.LabelingType;
        json.x.Q = rmfield(json.x.Q,'LabelingType');
    end
    
    if strcmpi(studyPar.Manufacturer,'GE')
        studyPar.ASLContext = 'm0scan,deltam';
        studyPar.M0 = true;
    end
    
    if strcmpi(studyPar.Manufacturer,'Siemens')
        if strcmp(json.x.Q.readoutDim,'2D')
            studyPar.ASLContext = 'm0scan,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label';
        else
            studyPar.ASLContext = 'control,label';
        end
    end
    
    % [ms] -> [s]
    studyPar.PostLabelingDelay = json.x.Q.Initial_PLD/1000;
    % studyPar.LabelingDuration = json.x.Q.LabelingDuration/1000;
    % We only need those parameters in the studyPar I think
    json.x.Q = rmfield(json.x.Q,'Initial_PLD');
    json.x.Q = rmfield(json.x.Q,'LabelingDuration');
    
    

end


