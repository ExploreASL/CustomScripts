%% OASIS data
%Function based on xASL_imp_NII2BIDS_Subject.m

Odir='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/test_rawdata';

ScannersList = xASL_adm_GetFileList(Odir, '^(.)*', 'FPList',[0 Inf], true);

for iSc=1:length(ScannersList)
    
    SubjList = xASL_adm_GetFileList(ScannersList{iSc}, '^sub-OAS', 'FPList',[0 Inf], true);
    
    for iSub=1:length(SubjList)
        
        JsonsList = xASL_adm_GetFileList(SubjList{iSub}, '(T1.json)$|(FLAIR.json)$ ', 'FPList',[0 Inf], false);  
        
        for iJ=1:length(JsonsList)
            
            % Load the JSON
            jsonAnat = spm_jsonread(JsonsList{iJ});
            
            % If RepetitionTimePreparation is equal to RepetitionTime, then remove RepetitionTimePreparation
            if isfield(jsonAnat,'RepetitionTime') && isfield(jsonAnat,'RepetitionTimePreparation') &&...
                    isnear(jsonAnat.RepetitionTime,jsonAnat.RepetitionTimePreparation)
                jsonAnat = rmfield(jsonAnat,'RepetitionTimePreparation');
            end
            
            % Save the JSON
            jsonAnat = xASL_bids_VendorFieldCheck(jsonAnat);
            jsonAnat = xASL_bids_JsonCheck(jsonAnat,'');
            spm_jsonwrite(JsonsList{iJ} ,jsonAnat);
        end
    end
end