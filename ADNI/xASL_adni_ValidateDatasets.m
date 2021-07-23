%xASL_adni_ValidateDatasets Main script to check if all datasets of the label file exist
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Main script to check if all datasets of the label file exist.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      xASL_adni_ValidateDatasets;
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

%% Initialization
x = ExploreASL;
clc

% Get user
if isunix
    [~,username] = system('id -u -n');
    username=username(1:end-1);
else
    username = getenv('username');
end

% Determine if we run this on ADNI-2 or ADNI-3
ADNI_VERSION = 2;

% Get ADNI "original" directory
if strcmp(username,'matlab') % M. Stritt user
    if ADNI_VERSION==2
        adniDirectory = 'E:\ASPIRE\ADNI\ADNI2\original';
        adniLabelFile = 'E:\ASPIRE\ADNI\ADNI2\ADNI-2_Labels.csv';
        adniDirectoryResults = 'M:\SoftwareDevelopment\MATLAB\m.stritt\Server_xASL\adni-2';
    else
        adniDirectory = 'E:\ASPIRE\ADNI\ADNI3\original';
        adniLabelFile = 'E:\ASPIRE\ADNI\ADNI3\ADNI-3_Labels.csv';
        adniDirectoryResults = 'M:\SoftwareDevelopment\MATLAB\m.stritt\Server_xASL\adni-3';
    end
else
    adniDirectory = uigetdir([], 'Select ADNI directory...');
    [adniLabelName, adniLabelFile] = uigetfile({'*.csv';'*.tsv';}, 'Select ADNI label file...');
    adniLabelFile = fullfile(adniLabelFile,adniLabelName);
    adniDirectoryResults = uigetdir([], 'Select ADNI results directory...');
end

% Get directory list
adniCases = xASL_adm_GetFsList(adniDirectory,'^\d{3}_.+$',true);

% Check if list is not empty
if isempty(adniCases)
    error('No ADNI cases found...');
end

% Transpose list
adniCases = adniCases';

% Read label file
adniLabels = xASL_csvRead(adniLabelFile);

%% Extract subject list from label file
subjectList = cell(numel(adniLabels(:,2)),1);
for iSubject = 1:numel(adniLabels(:,2))
    subjectList{iSubject,1} = adniLabels{iSubject,2};
    subjectList{iSubject,1} = strrep(subjectList{iSubject,1},'"','');
end

% Unique case list
subjectList = unique(subjectList);

% Remove title
subjectList(find(strcmp(subjectList,'Subject'))) = [];


%% Compare local database with subjects from label file
fprintf('Compare local database with subjects from label file...\n');

if numel(subjectList)==numel(adniCases)
    fprintf('Number of cases is correct...\n');
else
    warning('Incorrect number of cases...');
end

if sum(strcmp(subjectList,adniCases))==numel(subjectList)
    fprintf('Lists are identical...\n');
else
    warning('Not identical lists...');
end




