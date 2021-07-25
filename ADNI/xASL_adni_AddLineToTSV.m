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



	tsvFile = xASL_tsvRead(tsvPath);





	xASL_tsvWrite(tsvFile,tsvPath);


end



