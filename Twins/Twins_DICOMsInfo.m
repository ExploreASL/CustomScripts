%% Twins' DICOMDIR info extraction
% These fields have info about the dicoms, including PatientID, Study and Series (has the name of the MRI sequence)
% 
clear all
clc
%%% 

DicomDir=dicominfo('/home/bestevespadrela/lood_storage/divi/Projects/ExploreASL/Twins/Twins_sub1/DICOMDIR');
Items=DicomDir.DirectoryRecordSequence; %11694 items
ItemsList= fieldnames(DicomDir.DirectoryRecordSequence);

i=1;
for It=1:length(ItemsList)
    
    DicomInfo = Items.(ItemsList{It});
    FieldType=DicomInfo.DirectoryRecordType;
    
    if strcmp(FieldType,'SERIES')
        MRIsequenceName=DicomInfo.SeriesDescription;
        if strcmp(MRIsequenceName,'ASL 2025')
            
        end
        
%         FieldTypes{i}=MRIsequenceName; %creates a list with all of the MRI sequences available
%         i=i+1;
        
    end
end


