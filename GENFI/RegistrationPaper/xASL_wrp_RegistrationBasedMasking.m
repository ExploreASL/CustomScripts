function xASL_wrp_RegistrationBasedMasking( srcPath, refPath, SmoothingSrc, SmoothingRef)
%xASL_wrp_RegistrationBasedMasking, ExploreASL SPM wrapper




		%% ------------------------------------------------------------------------------------------
		%% This is the PWI MNI-template registration-based masking, used in the GENFI registration comparison,
		%  to mask PWI or mean_control images based on the SPM-warped skullmasks
		if MaskingOption

			%% 2) Register skull-mask to mean PWI map

			xASL_im_RegisterSkullMask(Fpath,x,OutputFile);


			%% 3) Create probability map

			if  strcmp(x.readout_dim,'2D')
				GRADIENT_RATE  = 0.5;
				% mask turned out to be too big otherwise
				% for 2D, has to do with voxel-size
			else
				GRADIENT_RATE  = 0.5;
			end

			MaskName    = fullfile( path, 'wmask_ICV.nii');
			MaskName2   = fullfile( path, 'PWI_GradualMask.nii');
			MaskInit    = xASL_io_Nifti2Im(MaskName);
			MaskInit(isnan(MaskInit))   = 0;
			%MaskInit    = imdilate(MaskInit,strel('sphere',1));
			MaskInit    = xASL_im_DilateErodeFull(MaskInit,'dilate',xASL_im_DilateErodeSphere(1));
			MaskInit    = shiftdim(MaskInit,1);
			%MaskInit    = imdilate(MaskInit,strel('sphere',1));
			MaskInit    = xASL_im_DilateErodeFull(MaskInit,'dilate',xASL_im_DilateErodeSphere(1));
			MaskInit    = shiftdim(MaskInit,2);

			Iter            = 1;
			MaskCheck       = MaskInit;
			while sum(sum(sum(logical(MaskCheck)==0)))>0
				Iter        = Iter-GRADIENT_RATE;
				if  Iter<0
					Iter    = 0;
				end
				Im2         = logical(MaskCheck);
				%Im2         = imdilate(Im2,strel('sphere',1));
				Im2         = xASL_im_DilateErodeFull(Im2,'dilate',xASL_im_DilateErodeSphere(1));
				Im2         = shiftdim(Im2,1);
				%Im2         = imdilate(Im2,strel('sphere',1));
				Im2         = xASL_im_DilateErodeFull(Im2,'dilate',xASL_im_DilateErodeSphere(1));
				Im2         = shiftdim(Im2,2);
				Diff        = Im2-logical(MaskCheck);
				MaskInit    = MaskInit+(Iter.* Diff );
				MaskCheck   = MaskCheck+logical(Diff);
			end

			xASL_io_SaveNifti( MaskName, MaskName2, MaskInit );

		end


	%% ------------------------------------------------------------------------------------------
	function xASL_im_RegisterSkullMask(Fpath,x, OutputFile)

		ICVName     = fullfile( x.SPMDIR,'tpm','mask_ICV.nii'); % this is the mask it has been tested with
		GMName      = fullfile( x.D.MapsDir, 'rgrey.nii'   );

		xASL_Copy( ICVName, fullfile(Fpath, 'mask_ICV.nii') ,1);
		xASL_Copy(  GMName, fullfile(Fpath, 'rgrey.nii'   ) ,1);

		matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source       = { fullfile(Fpath, 'rgrey.nii,1'   )};
		matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc        = '';
		matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample     = { fullfile(Fpath, 'mask_ICV.nii,1')};
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = { [OutputFile ',1']};
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight   = '';
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc   = 8;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref   = 8;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype  = 'mni';
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff   = 25;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits     = 16;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg      = 1;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb       = [NaN NaN NaN
																	   NaN NaN NaN];
		matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox      = [NaN NaN NaN];
		matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp   = 0;
		matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap     = [0 0 0];
		matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix   = 'w';

		spm_jobman('run',matlabbatch);

		xASL_delete( fullfile(Fpath, 'mask_ICV.nii') );
		xASL_delete( fullfile(Fpath, 'rgrey.nii') );
		xASL_delete( fullfile(Fpath, 'rgrey_sn.mat') );
	end


end
