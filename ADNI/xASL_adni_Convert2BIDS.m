%xASL_adni_Convert2BIDS Script to convert the cases in source structure to ASL-BIDS using ExploreASL
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Script to convert the cases in source structure to ASL-BIDS using ExploreASL.
%
% EXAMPLE:      xASL_adni_Convert2BIDS;
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


