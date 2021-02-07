%% Get overview Harmy CI

Flist   = xASL_adm_GetFileList('C:\Backup\ASL\Hardy\analysis','^ROI_T1.*\.(nii|nii\.gz)$','FPListRec',[0 Inf]);

for iL=1:length(Flist)
    [Fpath Ffile Fext]  = fileparts( Flist{iL});
    [Fpath Ffile Fext]  = fileparts( Fpath);
    ListList1{iL,1}     = Ffile;
end

Flist  = xASL_adm_GetFileList('C:\Backup\ASL\Hardy\Excluded','^ROI_T1.*\.(nii|nii\.gz)$','FPlistRec',[0 Inf]);

for iL=1:length(Flist)
    [Fpath Ffile Fext]  = fileparts( Flist{iL});
    [Fpath Ffile Fext]  = fileparts( Fpath);
    ListList2{iL,1}     = Ffile;
end

ListList3               = {'HD211_1' 'HD212_1' 'HD214_1' 'HD215_1' 'HD217_1'}';

length(ListList1) + length(ListList2) + length(ListList3)


%% Overview WMH
tnii    = sum(sum(sum(xASL_io_Nifti2Im('C:\Backup\ASL\Hardy\analysis\HD071_1\ROI_T1_1.nii'))));

%% Overview substudy
Dlist   = xASL_adm_GetFileList('C:\Backup\ASL\Hardy\CMI_substudy\lock\Struct','^999_ready\.status$','FPListRec');
