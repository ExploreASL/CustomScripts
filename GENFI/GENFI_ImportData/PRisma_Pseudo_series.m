%% create pseudo-series

ROOT    = 'C:\Backup\ASL\GENFI\GENFI_Prisma\raw';
Dlist   = xASL_adm_GetFsList( ROOT, '^.*$',1);

for iD=1:length(Dlist)
    Dlist2  = sort(xASL_adm_GetFsList( fullfile( ROOT, Dlist{iD} ), '^.*-asl3d_oblique.*$',1));

    for iD2=1:length(Dlist2)
        if  iD2<10
            xASL_Rename( fullfile( ROOT, Dlist{iD}, Dlist2{iD2}), [Dlist2{iD2}(1:end-6) '_ASL_0' num2str(iD2)]);
        else
            xASL_Rename( fullfile( ROOT, Dlist{iD}, Dlist2{iD2}), [Dlist2{iD2}(1:end-7) '_ASL_' num2str(iD2)]);
        end
    end

end



ROOT    = 'C:\Backup\ASL\GENFI\GENFI_Prisma\analysis';
Dlist   = xASL_adm_GetFsList( ROOT, '^.*$',1);

for iD=1:length(Dlist)
    Dlist2  = xASL_adm_GetFsList( fullfile( ROOT, Dlist{iD}), '^ASL_\d*$',1);
    for iD2=1:length(Dlist2)
        tNII    = xASL_nifti( fullfile( ROOT, Dlist{iD}, Dlist2{iD2},'ASL4D.nii'));
        IM(:,:,:, str2num(Dlist2{iD2}(5:end)) )         = tNII.dat(:,:,:,:);
    end

    xASL_io_SaveNifti( fullfile( ROOT, Dlist{iD}, Dlist2{1},'ASL4D.nii'), fullfile( ROOT, Dlist{iD}, Dlist2{1},'ASL4D.nii'), IM);

    for iD2=2:length(Dlist2)
        delete( fullfile( ROOT, Dlist{iD}, Dlist2{iD2},'ASL4D.nii'));
        delete( fullfile( ROOT, Dlist{iD}, Dlist2{iD2},'ASL4D_parms.mat'));
        rmdir( fullfile( ROOT, Dlist{iD}, Dlist2{iD2}) );
    end

end


ROOT    = 'C:\Backup\ASL\GENFI\GENFI_Prisma\analysis';
Dlist   = xASL_adm_GetFsList( ROOT, '^.*$',1);

for iD=1:length(Dlist)
    xASL_adm_CreateDir( fullfile( ROOT, 'lock', 'T1', Dlist{iD}, 'T1_module' ) );
    xASL_Copy( fullfile('C:\Backup\ASL\GENFI\GENFI_DF2\analysis\lock\T1\GE_GRN004_2\T1_module','001_coreg_T12MNI.status'),fullfile( ROOT, 'lock', 'T1', Dlist{iD}, 'T1_module','001_coreg_T12MNI.status' ) );
    xASL_Copy( fullfile('C:\Backup\ASL\GENFI\GENFI_DF2\analysis\lock\T1\GE_GRN004_2\T1_module','002_segment_T1.status'),fullfile( ROOT, 'lock', 'T1', Dlist{iD}, 'T1_module','002_segment_T1.status' ) );
    xASL_Copy( fullfile('C:\Backup\ASL\GENFI\GENFI_DF2\analysis\lock\T1\GE_GRN004_2\T1_module','003_tissue_volume.status'),fullfile( ROOT, 'lock', 'T1', Dlist{iD}, 'T1_module','003_tissue_volume.status' ) );
end
