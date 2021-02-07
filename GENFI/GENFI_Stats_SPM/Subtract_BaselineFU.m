%% GENFI subtract follow-up & baseline scans

x.D.PopDir   = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis\dartel';
Flist               = xASL_adm_GetFileList( x.D.PopDir, '^qCBF_.*_2_ASL_1\.(nii|nii\.gz)$');

%
% PS: 1 TPs 3 that could be subtracted with TP2

%% Create list for TP2-TP1
for iF=1:length(Flist)
    clear Path file ext TP2 TP1 LongSub_CBFname LongSub_CBFim
    clear TP2im TP1im

    [Path file ext]    = fileparts(Flist{iF});

    TP2             = Flist{iF};
    TP1             = [Flist{iF}(1:end-11) '1_ASL_1.nii'];
    LongSub_CBFname = fullfile( x.D.PopDir, ['LongSub_CBF_' file(6:end-7) 'ASL_1.nii']);

    if  exist(TP1,'file')
        % subtract
        TP2im           = xASL_nifti(TP2);
        TP1im           = xASL_nifti(TP1);
        TP2im           = TP2im.dat(:,:,:);
        TP1im           = TP1im.dat(:,:,:);
        LongSub_CBFim   = TP2im-TP1im;

        xASL_io_SaveNifti(TP2,LongSub_CBFname,LongSub_CBFim);
    else fprintf('%s\n',['File ' TP1 ' didnt exist']);
        Flist(iF:end-1)     = Flist(iF+1:end,:);
        Flist               = Flist(1:end-1,:);
    end
end

LongitudinalList    = Flist;
clear Flist iF

%% Create list for TP3-TP2
Flist              = xASL_adm_GetFileList( x.D.PopDir, '^qCBF_.*_3_ASL_1\.(nii|nii\.gz)$');
for iF=1:length(Flist)
    clear Path file ext TP3 TP2 TP1 LongSub_CBFname LongSub_CBFim
    clear TP3im TP2im TP1im

    [Path file ext] = fileparts(Flist{iF});

    TP3             = Flist{iF};
    TP2             = [Flist{iF}(1:end-11) '2_ASL_1.nii'];
    TP1             = [Flist{iF}(1:end-11) '1_ASL_1.nii'];
    LongSub_CBFname = fullfile( x.D.PopDir, ['LongSub_CBF_' file(6:end-7) 'ASL_1.nii']);

    if  exist(TP1,'file')
        fprintf('%s\n',['File ' TP1 ' did exist']);
        Flist(iF:end-1)     = Flist(iF+1:end,:);
        Flist               = Flist(1:end-1,:);

    elseif exist(TP2,'file')
        % subtract
        TP3im           = xASL_nifti(TP3);
        TP2im           = xASL_nifti(TP2);
        TP3im           = TP3im.dat(:,:,:);
        TP2im           = TP2im.dat(:,:,:);
        LongSub_CBFim   = TP3im-TP2im;

        xASL_io_SaveNifti(TP3,LongSub_CBFname,LongSub_CBFim);
    else
        fprintf('%s\n',['File ' TP2 ' & ' TP1 ' didnt exist']);
        Flist(iF:end-1)     = Flist(iF+1:end,:);
        Flist               = Flist(1:end-1,:);
    end
end


%% Save resultant longitudinal list
LongitudinalList(length(LongitudinalList)+1:length(LongitudinalList)+length(Flist),:)     = Flist;
for iF=1:length(LongitudinalList)
    clear path file ext
    [path file ext]     = fileparts(LongitudinalList{iF,1});
    if      str2num(file(end-6))==2
            NewList{iF,1}       = [file(6:end-7) '1'];
    elseif  str2num(file(end-6))==3
            NewList{iF,1}       = [file(6:end-7) '2'];
    else    error('Unknown TP');
    end
end

clear LongitudinalList
LongitudinalList    = NewList;
clear NewList
x.D.ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF2\analysis';
save( fullfile( x.D.ROOT, 'LongitudinalList.mat'), 'LongitudinalList');
