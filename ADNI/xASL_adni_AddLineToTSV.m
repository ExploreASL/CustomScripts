function xASL_adni_AddLineToTSV(adniCase,tsvPath,loggingExists)
%xASL_adni_AddLineToTSV Add line to tsv file of processed ADNI datasets
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Add line to tsv file of processed ADNI datasets.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      xASL_adni_AddLineToTSV(adniCases{iCase,1},userConfig.ADNI_PROCESSED,loggingExists);
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL


    % Check if TSV file exists
    if ~xASL_exist(tsvPath,'file')
        tsvFile{1,1} = 'ADNI_Case';
        tsvFile{1,2} = 'Logging';
    else
        tsvFile = xASL_tsvRead(tsvPath);
    end
    
    % Get existing number of rows
    existingRows = size(tsvFile,1);
    
    % Add case and logging info
    tsvFile{existingRows+1,1} = adniCase;
    if loggingExists
        tsvFile{existingRows+1,2} = 'ERROR';
    else
        tsvFile{existingRows+1,2} = 'OK';
    end

    % Write TSV file
	xASL_tsvWrite(tsvFile,tsvPath,1);


end



