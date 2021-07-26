function [json, newCaseRoot, iSessionsNum, studyPar] = xASL_adni_CopyAndModifySession(dataset, userConfig, dateLists, studyPar, names, adniCases, adniDirectoryResults)
%xASL_adni_CopyAndModifySession Main script for copying and modifying individual sessions
%
% INPUT:        n/a
%
% OUTPUT:       n/a
%
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION:  Main script for copying and modifying individual sessions.
%
%               Written by M. Stritt, 2021.
%
% EXAMPLE:      n/a
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% Copyright 2015-2021 ExploreASL

    % Unpack variables
    iSessionsNum = dataset.iSessionsNum;
    iSessions = dataset.iSessions;
    iCase = dataset.iCase;
    currentDir = dataset.currentDir;  
        
    % Get this session
    thisSessions = ['session_' num2str(iSessionsNum)];
    iSessionsNum = iSessionsNum+1;
    dateLists.dateList_ASL{iSessions,1} = [thisSessions '_' dateLists.dateList_ASL{iSessions,2}];

    % Determine new case directory
    newCase = fullfile(adniDirectoryResults,adniCases{iCase,1},'sourcedata','sub-001',dateLists.dateList_ASL{iSessions,1});
    newCaseRoot = fullfile(adniDirectoryResults,adniCases{iCase,1});

    % Copy ASL session to new directory
    xASL_Copy(fullfile(currentDir,names.ASL_name,dateLists.dateList_ASL{iSessions,2}),fullfile(newCase,'ASL'),1);

    % Get Dicoms
    dcmPaths = xASL_adm_GetFileList(fullfile(newCase,'ASL'),'^.+\.dcm$','FPListRec');
    if ~isempty(dcmPaths)
        headerDCM = xASL_io_DcmtkRead(dcmPaths{1});

        % Determine manufacturer from DICOM
        if ~isempty(regexpi(headerDCM.Manufacturer,'Siemens'))
            manufacturer = 'Siemens';
        elseif ~isempty(regexpi(headerDCM.Manufacturer,'Philips'))
            manufacturer = 'Philips';
        elseif ~isempty(regexpi(headerDCM.Manufacturer,'GE'))
            manufacturer = 'GE';
        else
            manufacturer = '';
        end

        switch manufacturer
            case 'Siemens'
                [json,studyPar] = xASL_adni_GetJsonSiemens(headerDCM, userConfig.ADNI_VERSION, adniCases, iCase, studyPar, dcmPaths);
            case 'Philips'
                [json,studyPar] = xASL_adni_GetJsonPhilips(headerDCM, userConfig.ADNI_VERSION, adniCases, iCase, studyPar);
            case 'GE'
                [json,studyPar] = xASL_adni_GetJsonGE(headerDCM, userConfig.ADNI_VERSION, adniCases, iCase, studyPar);
            otherwise
                warning('Unknown manufacturer...');
        end

        % Write JSON file
        spm_jsonwrite(fullfile(newCaseRoot,['dataPar-' thisSessions '.json']),json);

    end

    % Check if there are other modalities for this session
    for iSessions_MPRAGE = 1:numel(dateLists.dateList_MPRAGE)
        if strcmp(dateLists.dateList_MPRAGE{iSessions_MPRAGE,1},dateLists.dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,names.MPRAGE_name,dateLists.dateList_MPRAGE{iSessions_MPRAGE,1}),fullfile(newCase,'T1w'));
        end
    end
    for iSessions_FLAIR = 1:numel(dateLists.dateList_FLAIR)
        if strcmp(dateLists.dateList_FLAIR{iSessions_FLAIR,1},dateLists.dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,names.FLAIR_name,dateLists.dateList_FLAIR{iSessions_FLAIR,1}),fullfile(newCase,'FLAIR'));
        end
    end
    for iSessions_CALIBRATION = 1:numel(dateLists.dateList_CALIBRATION)
        if strcmp(dateLists.dateList_CALIBRATION{iSessions_CALIBRATION,1},dateLists.dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,names.CALIBRATION_name,dateLists.dateList_CALIBRATION{iSessions_CALIBRATION,1}),fullfile(newCase,'CALIBRATION'));
        end
    end
    for iSessions_M0 = 1:numel(dateLists.dateList_M0)
        if strcmp(dateLists.dateList_M0{iSessions_M0,1},dateLists.dateList_ASL{iSessions,2})
            % Copy MPRAGE session to new directory
            xASL_Copy(fullfile(currentDir,names.M0_name,dateLists.dateList_M0{iSessions_M0,1}),fullfile(newCase,'M0'));
        end
    end


end


