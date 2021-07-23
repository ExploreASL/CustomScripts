function isThisSeries = getSeries(item,typeOfSeries)
%getSeries The idea of this function is to get the series corresponding to each patient
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  The idea of this function is to get the series corresponding to each patient.
%
%               Written by M. Stritt & B. Padrela, 2021.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Default
    isThisSeries = false;

    % Get record type
    recordType = item.DirectoryRecordType;
    
    % Check if the current element is a series
    if ~isempty(regexpi(recordType,'SERIES'))
        
        % Get the sequence name
        MRIsequenceName=item.SeriesDescription;

        % Check if the series has the corresponding type
        if ~isempty(regexpi(MRIsequenceName,typeOfSeries))
            isThisSeries = true;
        end
        
    end

end