%% GENFI ASL nifti combination

clear
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\GENFI_DF12\analysis';
dList   = xASL_adm_GetFsList( ROOT, '^.*$', 1);

ParmsList   = {'RepetitionTime' 'EchoTime' 'NumberOfTemporalPositions' 'RescaleSlopeOriginal' 'MRScaleSlope' 'RescaleIntercept'};

for iDir=1:length(dList)

    clear ASLdir newASLdir Parms1 Parms2 Parms3 ParmsNew CheckParms controlNii tagNii diffNii NewIm NewName diffName

    % Change dirname
    ASLdir          = fullfile( ROOT, dList{iDir}, 'GENFI_asl');
    if  isdir(ASLdir)
        newASLdir   = fullfile( ROOT, dList{iDir}, 'ASL_1');
        xASL_adm_CreateDir(newASLdir);

        %% Check equality parms first
        Parms1      = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'control_parms.mat');
        Parms2      = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'tag_parms.mat');
%         Parms3      = fullfile( ROOT, dList{iDir}, 'asl', 'diff_parms.mat');

        Parms1      = load(Parms1);
        Parms2      = load(Parms2);
%         Parms3      = load(Parms3);

        for iParms=1:length(ParmsList)
            CheckParms(iParms,1)  = eval(['Parms1.parms.' ParmsList{iParms} '~=Parms2.parms.' ParmsList{iParms}]);
%             CheckParms(iParms,2)  = eval(['Parms2.parms.' ParmsList{iParms} '~=Parms3.parms.' ParmsList{iParms}]);
        end

        if  max(CheckParms(:))>0
            error('Not same dicom header info for control/tag/diff niftis');
        end

        %% Combine control & tag niftis
        controlNii  = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'control.nii');
        controlNii  = xASL_nifti(controlNii);

        tagNii      = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'tag.nii');
        tagNii      = xASL_nifti(tagNii);

        % Check data format niftis
        if      ~strcmp(controlNii.dat.dtype,'INT16-LE') || ~strcmp(tagNii.dat.dtype,'INT16-LE')
            error('Data format niftis');
        elseif  controlNii.dat.scl_slope~=1 || tagNii.dat.scl_slope~=1
            error('Data format niftis');
        elseif  controlNii.dat.scl_inter~=0 || tagNii.dat.scl_inter~=0
            error('Data format niftis');
        elseif  ~min(controlNii.dat.dim==[128 128 30]) || ~min(tagNii.dat.dim==[128 128 30])
            error('Data format niftis');
        elseif ~min(min(controlNii.mat==tagNii.mat))
            error('Unequal matrix orientation');
        end

        if  ~min(size(controlNii.dat)==[128 128 30]) || ~min(size(tagNii.dat)==[128 128 30])
            error('size image');
        end

        if  length(size(controlNii.dat))~=3 || length(size(tagNii.dat))~=3
            error('Not 3D');
        end

        %% Combine control & tag image (still able to use control image for registration with M0
        NewIm(:,:,:,1)      = controlNii.dat(:,:,:);
        NewIm(:,:,:,2)      = tagNii.dat(:,:,:);

        diffName            = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'control.nii');
        NewName             = fullfile( ROOT, dList{iDir}, 'ASL_1', 'ASL4D.nii');

        xASL_io_SaveNifti( diffName, NewName, NewIm, 2, 16 );
        Parms1      = fullfile( ROOT, dList{iDir}, 'GENFI_asl'  , 'control_parms.mat');
        ParmsNew    = fullfile( ROOT, dList{iDir}, 'ASL_1', 'ASL4D_parms.mat');
        xASL_Move(Parms1, ParmsNew);

        %% Delete redundant files
        Parms2      = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'tag_parms.mat');
%         Parms3      = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'diff_parms.mat');

        controlNii  = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'control.nii');
        tagNii      = fullfile( ROOT, dList{iDir}, 'GENFI_asl', 'tag.nii');
%         diffNii     = fullfile( ROOT, dList{iDir}, 'asl', 'diff.nii');

        delete(Parms2);
%         delete(Parms3);
        delete(controlNii);
        delete(tagNii);
%         delete(diffNii);

        rmdir( ASLdir );
    end
end




% Trial save_nii_spm
% pietName    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\SI Trio\analysis\C9ORF002\asl\save_spm\piet.nii';
% NewName     = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\SI Trio\analysis\C9ORF002\asl\save_spm\Newpiet.nii';
% pietNii     = xASL_nifti(pietName);
% pietIm      = pietNii.dat(:,:,:).*250;
% xASL_io_SaveNifti( pietName, NewName, pietIm, 1, 16 );


% Trial 1
% ctrl    =xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF1_new\SI Trio\analysis\GRN040\asl\control.nii');
% tag     =xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF1_new\SI Trio\analysis\GRN040\asl\tag.nii');
%
% diff    =xASL_nifti('C:\Backup\ASL\GENFI\GENFI_DF1_new\SI Trio\analysis\GRN040\asl\diff.nii');
%
% ctrl    = ctrl.dat(:,:,:,:);
% tag     =  tag.dat(:,:,:,:);
% diff    = diff.dat(:,:,:,:);
%
% PWIdiff2 = mean(tag-ctrl,4);
% PWIdiff2 = PWIdiff2.*(PWIdiff2>0);
%
% CheckDiff   = PWIdiff-PWIdiff2;
%
% PWIdiff = mean(diff,4);
% dip_image([CheckDiff])
% dip_image([ctrl tag])
