function patients = getPatient(patients,DicomDir)
%getPatient The idea of this function is to get the patient from an item list
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  The idea of this function is to get the patient from an item list.
%
%               Written by M. Stritt & B. Padrela, 2021.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % List of items (studies, patients, sessions etc.)
    Items=DicomDir.DirectoryRecordSequence;

    % Default
    lastPatient = '';

    % Fieldnames
    ItemsList= fieldnames(DicomDir.DirectoryRecordSequence);

    % Iterate over all items and get a patient list
    for It = 1:numel(ItemsList)

        % Get current item
        currentItem = Items.(ItemsList{It});

        % Get the patients
        if strcmp(currentItem.DirectoryRecordType,'PATIENT')
            patients.(currentItem.PatientID) = currentItem;
            lastPatient = currentItem.PatientID;
            fprintf('%s ...\n',lastPatient);
        end

        % Add all corresponding series elements of interest
        isASL = getSeries(currentItem,'asl');
        isFLAIR = getSeries(currentItem,'3d flair');
        isM0 = getSeries(currentItem,'m0');
        isT1W = getSeries(currentItem,'t1w');

        % Switch the modality
        if isASL
            patients.(lastPatient).asl = currentItem;
        elseif isFLAIR
            patients.(lastPatient).flair = currentItem;
        elseif isM0
            patients.(lastPatient).m0 = currentItem;
        elseif isT1W
            patients.(lastPatient).t1w = currentItem;
        end

        % Set directory
        [~, patients.(lastPatient).DicomDir] = fileparts(fileparts(DicomDir.Filename));

    end

end