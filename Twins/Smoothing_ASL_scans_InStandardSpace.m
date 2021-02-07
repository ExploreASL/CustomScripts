% tPET    = 'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_R1_SingleSite.nii';
% tASL    = 'C:\Backup\ASL\TwinExample\twins_ASL\dartel\Templates\Template_mean_CBF_SingleSite.nii';
%
% tPET    = xASL_io_Nifti2Im(tPET);
% tASL    = xASL_io_Nifti2Im(tASL);
%
% dip_image([imrotate(tPET,90) dip_array(smooth(imrotate(tASL,90)./(0.4*max(tASL(:))),[3 3 0]))])

%NB: it will only smooth the CBF maps that are included (i.e. also have R1
%images)

for iS=1:x.nSubjects
    xASL_TrackProgress(iS,x.nSubjects);
    ASLfile     = fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_1.nii']);
    ASLfile_s   = fullfile(x.D.PopDir,['qCBF_untreated_' x.SUBJECTS{iS} '_ASL_1.nii']);

    ASLim       = single(xASL_io_Nifti2Im(ASLfile));
    %ASLim       = dip_array(smooth(ASLim,[2 2 0]));
	ASLim       = xASL_im_ndnanfilter(ASLim,'gauss',[2 2 0]*2.335,0);
    xASL_io_SaveNifti(ASLfile, ASLfile_s, ASLim);
end

% smoothing was done with 2x2x0 mm SD (so ~4.5 mm in plane FWHM)
