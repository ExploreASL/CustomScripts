function GetTIVMoreRobustly(ROOT)


%% Get TIV more robustly for poor segmentations/poor quality scans

if nargin<1 || isempty(ROOT)
    ROOT = 'C:\BackupWork\ASL\DIPG';
end

x = ExploreASL_Master('',0);
Dlist = xASL_adm_GetFileList(ROOT, '^\d{6}_\d$', 'FPList', [0 Inf], true);

SavePath = fullfile(ROOT, 'TIV_forItalianLadies.csv');
fclose all
xASL_delete(SavePath);
FID = fopen(SavePath,'wt');
fprintf(FID, 'Subject, TIV (mL)\n');

for iD=1:length(Dlist)
    [~, Subj] = fileparts(Dlist{iD});

    fprintf(FID, [Subj ',']);
    Path_T1 = fullfile(Dlist{iD}, 'T1.nii');
    Path_rT1 = fullfile(Dlist{iD}, 'rT1.nii');
    Path_yT1 = fullfile(Dlist{iD}, 'y_T1.nii');
    Path_maskT1 = fullfile(Dlist{iD}, 'mask_rT1.nii');
    cd(Dlist{iD});

    if xASL_exist(Path_yT1, 'file')
        % First expand the image
        NII = xASL_io_ReadNifti(Path_T1);
        xASL_im_Upsample(Path_T1, Path_rT1, NII.hdr.pixdim(2:4), 0, [100 100 100]);

        % Then skullstrip
        xASL_im_SkullStrip(Path_rT1, fullfile(x.D.TemplateDir, 'brainmask_SPM.nii'));

        NII = xASL_io_ReadNifti(Path_maskT1);
        Mask = NII.dat(:,:,:)>0;

        fprintf(FID, [xASL_num2str(xASL_stat_SumNan(Mask(:)) .* prod(NII.hdr.pixdim(2:4)) / 1000) '\n']);
    end
end

fclose(FID);


end
