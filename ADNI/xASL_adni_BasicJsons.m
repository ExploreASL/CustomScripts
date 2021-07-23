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
    sourceStructure.folderHierarchy = {'^sub-(.+)$','^(session_\d{1}).+$','^(ASL|T1w|M0|T2|FLAIR)$', 'S.+$'};
    % subject: token 1, visit: token 2, session: none, scan: token 3
    sourceStructure.tokenOrdering = [1,2,0,3];
    % visit/session/scan aliases
    sourceStructure.tokenVisitAliases = {'session_1','_1','session_2','_2','session_3','_3','session_4','_4','session_5','_5','session_6','_6','session_7','_7'};
    sourceStructure.tokenSessionAliases = {'', ''};
    sourceStructure.tokenScanAliases = {'^ASL$','ASL4D','^T1w$','T1w','^M0$','M0','^T2$','T2w','^FLAIR$','FLAIR'};
    % Match directories
    sourceStructure.bMatchDirectories = true;

    % Define studyPar template
    studyPar.Authors = 'ADNI';
    studyPar.DatasetType = 'raw';
    studyPar.License = 'RandomText';
    studyPar.Authors = {'RandomText'};
    studyPar.Acknowledgements = 'RandomText';
    studyPar.HowToAcknowledge = 'Please cite this paper: https://www.ncbi.nlm.nih.gov/pubmed/001012092119281';
    studyPar.Funding = {'RandomText'};
    studyPar.EthicsApprovals = {'RandomText'};
    studyPar.ReferencesAndLinks = {'RandomText'};
    studyPar.DatasetDOI = 'RandomText';
    studyPar.VascularCrushing = false;
    studyPar.LabelingType = 'PASL';
    studyPar.PASLType = 'PICORE';
    studyPar.BackgroundSuppression = false;
    studyPar.M0 = false;
    studyPar.LabelingLocationDescription = 'Fixed, 9 cm below ACPC';
    studyPar.ASLContext = 'm0scan,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label,control,label';


end


