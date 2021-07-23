function isThisSeries = getSeries(item,typeOfSeries)
% The idea of this function is to get the series corresponding to each patient
%
% patients.(PATIENT_ID).series = item

    % Default
    isThisSeries = false;

    % Get record type
    recordType = item.DirectoryRecordType;
    
    % Check if the current element is a series
    if ~isempty(regexpi(FieldType,'SERIES'))
        
        % Get the sequence name
        MRIsequenceName=item.SeriesDescription;

        % Check if the series has the corresponding type
        if ~isempty(regexpi(MRIsequenceName,typeOfSeries))
            isThisSeries = true;
        end
        
    end

end