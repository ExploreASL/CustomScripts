%% OASIS data
%Function based on xASL_imp_NII2BIDS_Subject.m

clear all
clc

%Initiating ExploreASL because we'll use some of its functions for sorting the data
ExploreASL_Master('',0);

Odir='/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/OASIS/test_rawdata';

ScannersList = xASL_adm_GetFileList(Odir, '^Siemens_', 'FPList',[0 Inf], true);

for iSc=1:length(ScannersList)
    
    Rdir = fullfile(ScannersList{iSc});
    
    SubjList = xASL_adm_GetFileList(Rdir, '^sub-OAS', 'FPList',[0 Inf], true);
    
    for iSub=1:length(SubjList)
        

        JsonsAnatList = xASL_adm_GetFileList(SubjList{iSub}, '(T1.json)|(FLAIR.json) ', 'FPListRec',[0 Inf], false);  
        JsonsASLList = xASL_adm_GetFileList(SubjList{iSub}, '(asl.json)', 'FPListRec',[0 Inf], false);  
        
        NiftiASLList = xASL_adm_GetFileList(SubjList{iSub}, '(asl.nii) ', 'FPListRec',[0 Inf], false);
        
        % == For OASIS, removing the first volume of the Niftis ==%
         for iN=1:length(NiftiASLList)
            
             ASLIm=xASL_io_Nifti2Im(NiftiASLList{iN});
             
             if size(ASLIm,4)~=104
                 ASLIm(:,:,:,1)=[]; %deletes the first volume, so we can have 104 instead of 105 ovluems (first is dummy scan)
                 xASL_io_SaveNifti(NiftiASLList{iN},NiftiASLList{iN},ASLIm)
             end
         end
        
         %StudyPar
         studyParPath = fullfile(Rdir,'studyPar.json');
         studyPar = xASL_io_ReadJson(studyParPath);
         
         %== Anatomical (T1,FLAIR) Jsons ==%
         for iJ=1:length(JsonsAnatList)
            
            % Load and correct Anat JSONs 
            jsonAnat = xASL_io_ReadJson(JsonsAnatList{iJ});
            jsonAnat = xASL_bids_BIDSifyAnatJSON(jsonAnat,studyPar);
            jsonAnat = xASL_bids_VendorFieldCheck(jsonAnat);
            jsonAnatCheck = xASL_bids_JsonCheck(jsonAnat,'');
            
            % Save the JSON
            xASL_io_WriteJson(JsonsAnatList{iJ} ,jsonAnatCheck);
         end
        
        % == ASL jsons == %
        for iA=1:length(JsonsASLList)
            [dir, ASLfile] = fileparts(JsonsASLList{iA});
            ASLOutPath = ASLfile(1:end-4); %removing the _asl part
            bidsPar = xASL_bids_Config();

            jsonASL = xASL_io_ReadJson(JsonsASLList{iA});
            headerASL = xASL_io_ReadNifti(fullfile(dir, [ASLfile '.nii'])); %path for the .nii corresponding to .json
            
            
            %BIDSify ASL
            jsonLocal = xASL_bids_BIDSifyASLJSON(jsonASL, studyPar, headerASL);

            jsonLocal = xASL_bids_BIDSifyASLNII(jsonLocal, bidsPar,fullfile(dir, [ASLfile '.nii']), fullfile(dir, ASLOutPath));
            jsonLocal = xASL_bids_VendorFieldCheck(jsonLocal);
            jsonASLCheck = xASL_bids_JsonCheck(jsonLocal,'ASL');
            jsonFinalName= fullfile(dir,[ASLfile '.json']);
            
            %Save Json
            xASL_io_WriteJson(jsonFinalName,jsonASLCheck);
        end
    end
end