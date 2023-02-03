% Calculate EMBARC ASL parameters


%% SliceTiming


% UT
minTR = 4193;
PLD = 1525;
labdur = 1650;
nSlices = 29;

SliceReadoutTime = (minTR - PLD - labdur) / (nSlices-1);

SliceTiming = 0;
SliceTiming(2:nSlices) = [1:nSlices-1].*SliceReadoutTime;
SliceTiming = round(SliceTiming./1000, 5);


%% Obtain ASLContext
% Through control-label order, as there are no M0 volumes, only MG has 2
% dummy volumes (unknown for the other sequences)

% UM (Philips)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_UM/temp/UM0090_1/ASL_1/ASL4D.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end

% UT (Philips)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_TX/temp/TX0071_1/ASL_1/ASL4D.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end

% MG (Siemens)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_MG/temp/MG0039_1/ASL_1/ASL4D.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end

% CU (GE)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_CU/sourcedata/CU0027/ses-1/ASL/CU0027CUMR1R1/E7403_P20480_1.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end


%% GE SliceTiming
SliceTiming = 0;
SliceTiming(2:29) = 53.884.*[1:1:28];
SliceTiming = round(SliceTiming./1000,5);

%% CU
%% Convert GE CU ASL to BIDS:

dirDataset = '/scratch/hjmutsaerts/EMBARC/Example_CU';
dirSource = fullfile(dirDataset, 'sourcedata');
dirRaw = fullfile(dirDataset, 'rawdata');

xASL_adm_CreateDir(dirRaw);

subjectList = xASL_adm_GetFileList(dirSource, '^CU\d{4}$', 'List',[],1);

fprintf('Converting AFNI-exported ASL data to BIDS for CU:   ');
for iSubject=1:numel(subjectList)
    xASL_TrackProgress(iSubject, numel(subjectList));
    
    % 1. Prefix subject folder to sub-
    dirSourceSubject = fullfile(dirSource, subjectList{iSubject});
    dirRawSubject = fullfile(dirRaw, ['sub-' subjectList{iSubject}]);

    % xASL_adm_CreateDir(dirRawSubject);
    
    sessionList = xASL_adm_GetFileList(dirSourceSubject, '^ses-\d$', 'List',[],1);
    for iSession=1:numel(sessionList)
        % 2. Create ses-1 & ses-2
        dirSourceSession = fullfile(dirSourceSubject, sessionList{iSession});
        dirRawSession = fullfile(dirRawSubject, sessionList{iSession});
        
        % xASL_adm_CreateDir(dirRawSession);
        
        % 3. Create perf
        dirSourcePerf = fullfile(dirSourceSession, 'ASL');
        dirRawPerf = fullfile(dirRawSession, 'perf');
        
        if exist(dirSourcePerf, 'dir')
            perfList = xASL_adm_GetFileList(dirSourcePerf, '.*', 'List', [], 1);
            if numel(perfList)~=1
                warning(['More or less than 1 source perf folders for ' subjectList{iSubject} '_' sessionList{iSession}]);
            else
                dirSourcePerf = fullfile(dirSourcePerf, perfList{1});
            
                niftiList = xASL_adm_GetFileList(dirSourcePerf, '.*\.nii$', 'FPList');
                if numel(niftiList)~=1
                    warning(['More or less than 1 ASL NIfTIs for ' subjectList{iSubject} '_' sessionList{iSession}]);
                else
                    % Create BIDS perfusion folder
                    xASL_adm_CreateDir(dirRawPerf);
                    
                    % 4. Move the ASL NIfTI & rename perf nii -> sub- ses- asl.nii
                    fileSourcePerf = niftiList{1};
                    fileRawPerf = fullfile(dirRawPerf, ['sub-' subjectList{iSubject} '_' sessionList{iSession} '_asl.nii']);
                    xASL_Move(fileSourcePerf, fileRawPerf);
                    
                    % Remove the source perfusion folder
                    xASL_adm_DeleteFileList(fullfile(dirSourceSession, 'ASL'), '.*', 1);
                    xASL_delete(fullfile(dirSourceSession, 'ASL'));
                    
                    % 5. Copy *asl.json & *aslcontext.tsv
                    fileRawPerfJSON = fullfile(dirRawPerf, ['sub-' subjectList{iSubject} '_' sessionList{iSession} '_asl.json']);
                    fileRawPerfTSV = fullfile(dirRawPerf, ['sub-' subjectList{iSubject} '_' sessionList{iSession} '_aslcontext.tsv']);
                    
                    fileSourcePerfJSON = '/scratch/hjmutsaerts/EMBARC/CustomFiles/CU_asl.json';
                    fileSourcePerfTSV = '/scratch/hjmutsaerts/EMBARC/CustomFiles/CU_aslcontext.tsv';
                    
                    xASL_Copy(fileSourcePerfJSON, fileRawPerfJSON);
                    xASL_Copy(fileSourcePerfTSV, fileRawPerfTSV);
                end
            end
        end
    end
end

% 6. Run ExploreASL import (dcm2nii will then only be run for the T1w, rest
% for both)







%% MG
%% Remove dummy scans Siemens MG, first 2 volumes (MG & 4 subjects CU)
% after import, we should add to *asl.json:
% "DummyScanPositionInASL4D":[1,2],

derivativesDir = '/scratch/hjmutsaerts/EMBARC/Example_MG/derivatives/ExploreASL';
fileList = xASL_adm_GetFileList(derivativesDir, '.*ASL4D\.json$', 'FPListRec');

fprintf('Adding DummyScanPositionInASL4D to MG Siemens ASL4D.json:   ');
for iJSON=1:numel(fileList)
    xASL_TrackProgress(iJSON, numel(fileList));
    JSON = xASL_io_ReadJson(fileList{iJSON});
    JSON.DummyScanPositionInASL4D = [1 2];
    xASL_io_WriteJson(fileList{iJSON}, JSON);
end
fprintf('\n');

derivativesDir = '/scratch/hjmutsaerts/EMBARC/Example_CU_Siemens/derivatives/ExploreASL';
fileList = xASL_adm_GetFileList(derivativesDir, '.*ASL4D\.json$', 'FPListRec');

fprintf('Adding DummyScanPositionInASL4D to CU Siemens ASL4D.json:   ');
for iJSON=1:numel(fileList)
    xASL_TrackProgress(iJSON, numel(fileList));
    JSON = xASL_io_ReadJson(fileList{iJSON});
    JSON.DummyScanPositionInASL4D = [1 2];
    xASL_io_WriteJson(fileList{iJSON}, JSON);
end
fprintf('\n');



%% UM
%% Add SliceReadoutTime to UM
% after import, we should add to *asl.json
% "SliceReadoutTime":"ShortestTR"

derivativesDir = '/scratch/hjmutsaerts/EMBARC/Example_UM/derivatives/ExploreASL';
fileList = xASL_adm_GetFileList(derivativesDir, '.*ASL4D\.json$', 'FPListRec');

fprintf('Adding SliceReadoutTime to UM Philips ASL4D.json:   ');
for iJSON=1:numel(fileList)
    xASL_TrackProgress(iJSON, numel(fileList));
    JSON = xASL_io_ReadJson(fileList{iJSON});
    JSON.SliceReadoutTime = 'ShortestTR';
    xASL_io_WriteJson(fileList{iJSON}, JSON);
end
fprintf('\n');


