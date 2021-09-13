function [sourceStructure,studyPar] = xASL_adni_BasicJsons()
%xASL_adni_BasicJsons Basic settings for ADNI data
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Basic settings for ADNI data.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      [sourceStructure,studyPar] = xASL_adni_BasicJsons();
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Define sourceStructure template

    % token 1: (.+), token 2: (session_\\d{1}), token 3: (ASL|T1w|M0|T2|FLAIR)
    sourceStructure.folderHierarchy = {'^sub-(.+)$','^(session_\d{1}).+$','^(ASL|T1w|M0|T2|FLAIR)$', '^(S|I).+$'};
    % subject: token 1, visit: token 2, session: none, scan: token 3
    sourceStructure.tokenOrdering = [1,2,0,3];
    % visit/session/scan aliases
    sourceStructure.tokenVisitAliases = {'session_1','1','session_2','2','session_3','3','session_4','4','session_5','5','session_6','6','session_7','7'};
    sourceStructure.tokenSessionAliases = {'', ''};
    sourceStructure.tokenScanAliases = {'^ASL$','ASL4D','^T1w$','T1w','^M0$','M0','^T2$','T2w','^FLAIR$','FLAIR'};
    % Match directories
    sourceStructure.bMatchDirectories = true;

    % Define studyPar template
    studyPar.Authors = 'ADNI';
    studyPar.DatasetType = 'raw';
    studyPar.License = 'http://adni.loni.usc.edu/terms-of-use/';
    studyPar.Authors = {'Alzheimers Disease Neuroimaging Initiative'};
    studyPar.Acknowledgements = 'http://adni.loni.usc.edu/data-samples/access-data/groups-acknowledgements-journal-format/';
    studyPar.HowToAcknowledge = 'ADNI website: http://adni.loni.usc.edu/';
    studyPar.Funding = {'Alzheimers Disease Neuroimaging Initiative'};
    studyPar.ReferencesAndLinks = {'http://adni.loni.usc.edu/'};
    studyPar.DatasetDOI = 'http://adni.loni.usc.edu/';
    studyPar.VascularCrushing = false;
    studyPar.LabelingType = 'PASL';
    % studyPar.PASLType = 'PICORE';
    studyPar.BackgroundSuppression = false;
    studyPar.M0 = false;
    studyPar.ASLContext = 'm0scan,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label';


end


