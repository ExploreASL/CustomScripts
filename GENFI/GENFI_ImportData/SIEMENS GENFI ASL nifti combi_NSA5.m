%% GENFI ASL nifti combination

clear
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\GENFI_DF12\analysis';
dList   = xASL_adm_GetFsList( ROOT, '^.*$', 1);

ParmsList   = {'RepetitionTime' 'EchoTime' 'NumberOfTemporalPositions' 'RescaleSlopeOriginal' 'MRScaleSlope' 'RescaleIntercept'};

for iDir=1:length(dList)

    clear ASLdir newASLdir Parms1 Parms2 Parms3 ParmsNew CheckParms controlNii tagNii diffNii NewIm NewName diffName

    ASLdir{iN}      = fullfile( ROOT, dList{iDir}, ['ASL_' num2str(iN)]);
    Parms1          = fullfile( ASLdir{1}, 'ASL4D_parms.mat');
    Parms1          = load(Parms1);

    % Load Nifti
    nii1            = fullfile( ASLdir{iN}, 'ASL4D.nii');
    nii1            = xASL_nifti(nii1);

    for iN=2:10
        % Change dirname
        ASLdir{iN}  = fullfile( ROOT, dList{iDir}, ['ASL_' num2str(iN)]);

        % Load parms
        Parms{iN}   = fullfile( ASLdir{iN}, 'ASL4D_parms.mat');
        Parms{iN}   = load(Parms{iN});

        % Load Nifti
        nii{iN}     = fullfile( ASLdir{iN}, 'ASL4D.nii');
        nii{iN}     = xASL_nifti(nii{iN});

        % CheckParms
        for iParms=1:length(ParmsList)
            CheckParms(iParms,1)  = eval(['Parms1.parms.' ParmsList{iParms} '~=Parms{iN}.parms.' ParmsList{iParms}]);
        end

        if  max(CheckParms(:))>0
            error('Not same dicom header info for control/tag/diff niftis');
        end

        % Check data format niftis
        if ~strcmp(nii{iN}.dat.dtype,'INT16-LE')
            error('Data format niftis');
        elseif  nii{iN}.dat.scl_slope~=1
            error('Data format niftis');
        elseif  nii{iN}.dat.scl_inter~=0
            error('Data format niftis');
        elseif  ~min(nii{iN}.dat.dim==[128 128 30])
            error('Data format niftis');
        elseif ~min(min(nii{iN}.mat==nii1.mat))
            error('Unequal matrix orientation');
        end

        if  ~min(size(nii{iN}.dat)==[128 128 30])
            error('size image');
        end

        if  length(size(nii{iN}.dat))~=3
            error('Not 3D');
        end
    end

    %% Combine nifti images

    for iN=1:10
        % Change dirname
        ASLdir{iN}  = fullfile( ROOT, dList{iDir}, ['ASL_' num2str(iN)]);

        % Load Nifti
        nii{iN}         = fullfile( ASLdir{iN}, 'ASL4D.nii');
        nii{iN}         = xASL_nifti(nii{iN});
        IM(:,:,:,iN)    = nii{iN}.dat(:,:,:);
    end

    xASL_io_SaveNifti( fullfile( ASLdir{1}, 'ASL4D.nii'), fullfile( ASLdir{1}, 'ASL4D.nii'), IM, size(IM,4) );


end
