%% Twins' DICOMDIR info extraction
% These fields have info about the dicoms, including PatientID, Study and Series (has the name of the MRI sequence)
% 
clear all
clc
%%% 

DicomDir=dicominfo('/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/Twins/Twins_sub1/DICOMDIR');

% List of items (studies, patients, sessions etc.)
Items=DicomDir.DirectoryRecordSequence; %11694 items

% Fieldnames
ItemsList= fieldnames(DicomDir.DirectoryRecordSequence);

% Iterate over all items and get a patient list
for iElement = 1:numel(ItemsList)

    % Get current item
    currentItem = Items.(ItemsList{It});

    % Get the patients
    if strcmp(currentItem.DirectoryRecordType,'PATIENT')
        patients.(currentItem.PatientID) = currentItem;
    end

end

% Now that we have the patient list, we want all the scans corresonding to each patient

%i=1;
%for It=1:length(ItemsList)
%    
%    DicomInfo = Items.(ItemsList{It});
%    FieldType=DicomInfo.DirectoryRecordType;
%    
%    if strcmp(FieldType,'SERIES')
%        MRIsequenceName=DicomInfo.SeriesDescription;
%        if strcmp(MRIsequenceName,'ASL 2025')
%            
%        end
%        
%%         FieldTypes{i}=MRIsequenceName; %creates a list with all of the MRI sequences available
%%         i=i+1;
%        
%    end
%end


