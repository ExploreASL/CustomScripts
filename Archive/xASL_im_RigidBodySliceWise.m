function xASL_im_RigidBodySliceWise( InPathRef,InPathSrc, InPathOthers)
%RigidBody_SliceWise Registers rigid_body with SPM, very inefficient but does the job
% NB all images need to be in the same space, otherwise this will fail
% this works only for multi-slice 2D EPI

    [RootDir FfileSrc Fext]    = xASL_fileparts(InPathSrc);
    [RootDir FfileRef Fext]    = xASL_fileparts(InPathRef);

    SrcIm    = xASL_io_Nifti2Im(InPathSrc);
    RefIm    = xASL_io_Nifti2Im(InPathRef);
%     DiffIm   = (SrcIm-RefIm).^2;


    for iO=1:length(InPathOthers)
        [RootDir FfileOthers{iO} Fext]      = xASL_fileparts(InPathOthers{iO});
        OthersIm{iO}                        = xASL_io_Nifti2Im(InPathOthers{iO});
    end

    Dim3    = size(SrcIm,3);

%     for iL=1:Dim3 % suggestion to only register when RMS is high
%         % Get relative RMS value for this slice
%         relWeight(iL,1) = xASL_stat_SumNan(xASL_stat_SumNan(SrcIm(:,:,iL)));
%         relRMS(iL,1)    = xASL_stat_SumNan(xASL_stat_SumNan(DiffIm(:,:,iL).^0.5 ./ SrcIm(:,:,iL))) .*100;
%     end
%     relWeight   = relWeight./mean(relWeight);

	fprintf('%s','Registering slice ');

    for iL=1:Dim3
			fprintf('%s',num2str(iL));
        % if  relWeight(iL)>0.3 % skip top or bottom slices

            % determine paths
            tempSrcIm   = fullfile(RootDir, [FfileSrc num2str(iL) '.nii']);
            tempRefIm   = fullfile(RootDir, [FfileRef num2str(iL) '.nii']);
            % write slice to disk
            xASL_io_SaveNifti(InPathSrc,tempSrcIm,repmat(SrcIm(:,:,iL),[1 1 Dim3]));
            xASL_io_SaveNifti(InPathRef,tempRefIm,repmat(RefIm(:,:,iL),[1 1 Dim3]));

            % do same for others
            clear tempOthersIm
            for iO=1:length(InPathOthers)
                tempOthersIm{iO,1}   = fullfile(RootDir, [FfileOthers{iO} num2str(iL) '.nii']);
                xASL_io_SaveNifti(InPathOthers{iO},tempOthersIm{iO},repmat(OthersIm{iO}(:,:,iL),[1 1 Dim3]));
            end

            xASL_spm_coreg(   tempRefIm, tempSrcIm, tempOthersIm, [], [3] );
            xASL_spm_reslice( tempRefIm, tempSrcIm, [], [], [], tempSrcIm, 1 );
            for iO=1:length(InPathOthers)
                xASL_spm_reslice( tempRefIm, tempOthersIm{iO}, [], [], [], tempOthersIm{iO}, 1 );
                xASL_spm_reslice( tempRefIm, tempOthersIm{iO}, [], [], [], tempOthersIm{iO}, 1 );
            end

            % Construct new image
            tempIM              = xASL_io_Nifti2Im(tempSrcIm);
            NewSrcIm(:,:,iL)    = tempIM(:,:,iL);

            delete(tempSrcIm);
            delete(tempRefIm);

            for iO=1:length(InPathOthers)
                tempIM                  = xASL_io_Nifti2Im(tempOthersIm{iO});
                NewOthersIm{iO}(:,:,iL) = tempIM(:,:,iL);
                delete(tempOthersIm{iO});
            end
%        end

    end

    xASL_io_SaveNifti(InPathSrc,fullfile(RootDir,['w' FfileSrc '.nii']),NewSrcIm);
    for iO=1:length(InPathOthers)
        xASL_io_SaveNifti(InPathOthers{iO},fullfile(RootDir,['w' FfileOthers{iO} '.nii']),NewOthersIm{iO});
    end
end
