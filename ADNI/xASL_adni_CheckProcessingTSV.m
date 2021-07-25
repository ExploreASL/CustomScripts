function processDataset = xASL_adni_CheckProcessingTSV(adniCase,tsvPath)
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
    
    % Default: process this ADNI dataset
    processDataset = true;
    
    % Search for current case
    if ~isempty(find(strcmpi(tsvFile(:,1),adniCase)))
        rowIndex = find(strcmpi(tsvFile(:,1),adniCase));
        % Check if processing was 100% successful
        if strcmp(tsvFile{rowIndex,2},'ERROR')
            % There was a bug in the current dataset, process it again
            processDataset = true;
        else
            % The current dataset was already processed without any problems, do not process it again
            processDataset = false;
        end
    end


end



