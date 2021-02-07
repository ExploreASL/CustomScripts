%% Hardy Merge ASL_1 & ASL_2
x.D.ROOT    = 'C:\Backup\ASL\Hardy\analysis';

Dlist   = xASL_adm_GetFsList(x.D.ROOT,'^HD\d{3}_1$',1);

for iS=1:length(Dlist)
    xASL_TrackProgress(iS,x.nSubjects);

    x.SUBJECTS{iS} = Dlist{iS};

    clear SubjectDir ASL1dir ASL2dir ASLtempD
    clear ASL4D_1 ASL4D_2 ASL4D_3
    clear ASLnii1 ASLnii2 ASLnii3
    clear ASLim mat_1 mat_2 mat_3 Mat1 Mat2 Mat3 mat
    clear parms1 parms3 M0_1 M0_2 M0_3 M0nii1 M0nii2 M0nii3 M0im

    SubjectDir  = fullfile(x.D.ROOT, x.SUBJECTS{iS});

    ASL1dir     = fullfile(SubjectDir,'ASL_1_OLD');
    ASL2dir     = fullfile(SubjectDir,'ASL_2_OLD');


    if  isdir(fullfile(SubjectDir,'ASL_1')) && ~isdir(ASL1dir)
        xASL_Rename( fullfile(SubjectDir,'ASL_1'), 'ASL_1_OLD');
    end

    if  isdir(fullfile(SubjectDir,'ASL_2')) && ~isdir(ASL2dir)
        xASL_Rename( fullfile(SubjectDir,'ASL_2'), 'ASL_2_OLD');
    end

    ASLtempD    = fullfile(SubjectDir,'ASL_1');

    xASL_adm_CreateDir(ASLtempD);

    % Merge NIfTI

    ASL4D_1     = fullfile(ASL1dir,'ASL4D.nii');
    ASL4D_2     = fullfile(ASL2dir,'ASL4D.nii');
    ASL4D_3     = fullfile(ASLtempD,'ASL4D.nii');

    if  exist(ASL4D_1,'file') && ~exist(ASL4D_3,'file')

        ASLnii1     = xASL_io_ReadNifti(ASL4D_1);
        ASLnii3     = ASLnii1;
        ASLim       = ASLnii1.dat(:,:,:,:);

        if  exist(ASL4D_2,'file')
            ASLnii2     = xASL_io_ReadNifti(ASL4D_2);
            ASLim(:,:,:,end+1:end+size(ASLnii2.dat,4))  = ASLnii2.dat(:,:,:,:);
        end

        xASL_io_SaveNifti(ASL4D_1, ASL4D_3, ASLim);
    end

    % Merge MoCo registration

    mat_1     = fullfile(ASL1dir,'ASL4D.mat');
    mat_2     = fullfile(ASL2dir,'ASL4D.mat');
    mat_3     = fullfile(ASLtempD,'ASL4D.mat');

    if  exist(mat_1,'file')

        Mat1    = load(mat_1);
        Mat3    = Mat1.mat;

            if  exist(mat_2,'file')
                Mat2    = load(mat_2);
                Mat3(:,:,end+1:end+size(Mat2.mat,3))    = Mat2.mat;
            end

        mat     = Mat3;
        save(mat_3,'mat')
    end

    % Copy parms.mat

    parms1     = fullfile(ASL1dir,'ASL4D_parms.mat');
    parms3     = fullfile(ASLtempD,'ASL4D_parms.mat');

    if  exist(parms1,'file') && ~exist(parms3,'file')
        xASL_Copy(parms1,parms3);
    end

    parms1     = fullfile(ASL1dir,'M0_parms.mat');
    parms3     = fullfile(ASLtempD,'M0_parms.mat');

    if  exist(parms1,'file') && ~exist(parms3,'file')
        xASL_Copy(parms1,parms3);
    end


    % Merge M0
    M0_1     = fullfile( ASL1dir,'M0.nii');
    M0_2     = fullfile( ASL2dir,'M0.nii');
    M0_3     = fullfile(ASLtempD,'M0.nii');

    if  exist(M0_1,'file') && ~exist(M0_3,'file')

        M0nii1     = xASL_io_ReadNifti(M0_1);
        M0nii3     = M0nii1;
        M0im       = M0nii1.dat(:,:,:,:);

        if  exist(M0_2,'file')
            M0nii2     = xASL_io_ReadNifti(M0_2);
            M0im(:,:,:,end+1:end+size(M0nii2.dat,4))  = M0nii2.dat(:,:,:,:);
        end

        xASL_io_SaveNifti(M0_1, M0_3, M0im);
    end

end
