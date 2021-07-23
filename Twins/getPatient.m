function patients = getPatient(patients,DicomDir)

    % List of items (studies, patients, sessions etc.)
    Items=DicomDir.DirectoryRecordSequence;

    % Fieldnames
    ItemsList= fieldnames(DicomDir.DirectoryRecordSequence);

    % Iterate over all items and get a patient list
    for It = 1:numel(ItemsList)

        % Get current item
        currentItem = Items.(ItemsList{It});

        % Get the patients
        if strcmp(currentItem.DirectoryRecordType,'PATIENT')
            patients.(currentItem.PatientID) = currentItem;
        end

    end

end