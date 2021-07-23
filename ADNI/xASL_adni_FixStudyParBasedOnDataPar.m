function studyPar = xASL_adni_FixStudyParBasedOnDataPar(json, studyPar)
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

    if isfield(json.x.Q,'LabelingType')
        studyPar.LabelingType = json.x.Q.LabelingType;
    end
    
    if strcmpi(json.x.Vendor,'GE')
        studyPar.ASLContext = 'm0scan,deltam';
    end
    
    if strcmpi(json.x.Vendor,'Philips')
        studyPar.ASLContext = 'deltam';
        studyPar.SliceTiming = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40];
    end
    
    if strcmpi(json.x.Vendor,'Siemens')
        if strcmp(json.x.readout_dim,'2D')
            studyPar.ASLContext = 'm0scan,control,label';
        else
            studyPar.ASLContext = 'control,label';
        end
    end
    
    % [ms] -> [s]
    studyPar.PostLabelingDelay = json.x.Q.Initial_PLD/1000;
    studyPar.LabelingDuration = json.x.Q.LabelingDuration/1000;

end


