%% OASIS data
%Function based on xASL_imp_NII2BIDS_Subject.m

clear all
clc

Odir='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/test_rawdata';

ScannersList = xASL_adm_GetFileList(Odir, '^Siemens_', 'FPList',[0 Inf], true);


for iSc=1:length(ScannersList)
    
    Rdir = fullfile(ScannersList{iSc},'rawdata/');
    
    SubjList = xASL_adm_GetFileList(Rdir, '^sub-OAS', 'FPList',[0 Inf], true);
    
    for iSub=1:length(SubjList)
        
        JsonsAnatList = xASL_adm_GetFileList(SubjList{iSub}, '(T1.json)|(FLAIR.json) ', 'FPListRec',[0 Inf], false);  
        JsonsASLList = xASL_adm_GetFileList(SubjList{iSub}, '(ASL4D.json)', 'FPListRec',[0 Inf], false);  
        
        % == Anatomical Jsons ==%
         for iJ=1:length(JsonsAnatList)
            
            % Load and correct Anat JSONs 
            jsonAnat = spm_jsonread(JsonsAnatList{iJ});
            jsonAnat = xASL_bids_BIDSifyAnatJSON(jsonAnat);
            jsonAnat = xASL_bids_VendorFieldCheck(jsonAnat);
            jsonAnatCheck = xASL_bids_JsonCheck(jsonAnat,'');
            
            % Save the JSON
            spm_jsonwrite(JsonsAnatList{iJ} ,jsonAnatCheck);
         end
        
        % == ASL jsons == %
        for iA=1:length(JsonsASLList)
            [dir, ASLfile] = fileparts(JsonsASLList{iA});
            ASLOutPath = ASLfile(1:end-6); %removing the ASL4D part
            bidsPar = xASL_bids_Config();
            studyPar=fullfile(ScannersList{iSc},'studyPar.json');
            studyPar=spm_jsonread(studyPar);

            jsonASL = spm_jsonread(JsonsASLList{iA});
            headerASL = xASL_io_ReadNifti(fullfile(dir, [ASLfile '.nii'])); %path for the .nii corresponding to .json
            
            
            %BIDSify ASL
            jsonLocal = xASL_bids_BIDSifyASLJSON(jsonASL, studyPar, headerASL);

            jsonLocal = xASL_bids_BIDSifyASLNII(jsonLocal, bidsPar,fullfile(dir, [ASLfile '.nii']), fullfile(dir, ASLOutPath));
            jsonLocal = xASL_bids_VendorFieldCheck(jsonLocal);
            jsonASLCheck = xASL_bids_JsonCheck(jsonLocal,'ASL');
            jsonFinalName= fullfile(dir,ASLOutPath,'_asl.json');
            
            %Save Json
            spm_jsonwrite(jsonFinalName,jsonASLCheck);
        end
    end
end