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
        studyPar.ASLContext = 'label,control';
        warning('For the Philips scans it seems that we have to define the slice timings manually, I added a dummy vector from the flavor db...');
        studyPar.SliceTiming = [0,0.0363,0.0726,0.1089,0.1452,0.1815,0.2178,0.2541,0.2904,0.3267,0.363,0.3993,0.4356,0.4719,0.5082,0.5445,0.5808];
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


