%% 2 first seem to be M0, 4 latter seem to be ASL (background suppressed)
x.D.ROOT    = 'C:\Backup\ASL\Divers_Bonn\analysis';
Dlist           = xASL_adm_GetFsList(x.D.ROOT, '^\d*$',1);

Perfor  = 0;

for iD=1:length(Dlist)
    List2   = xASL_adm_GetFsList( fullfile(x.D.ROOT, Dlist{iD}),'^ASL_\d$',1 );

    for iL=1:length(List2)
        clear Dir Fname M0name IM M0_im ASL_im
        Dir     = fullfile(x.D.ROOT,Dlist{iD},List2{iL});
        Fname   = fullfile(Dir,'ASL4D.nii');
        M0name  = fullfile(Dir,'M0.nii');
        Fmat    = fullfile(Dir,'ASL4D_parms.mat');
        M0mat   = fullfile(Dir,'M0_parms.mat');

        IM      = xASL_io_ReadNifti(Fname);
        IM      = IM.dat(:,:,:,:);

        if  size(IM,4)==6

            M0_im   = IM(:,:,:,1:2);
            ASL_im  = IM(:,:,:,3:6);

            xASL_io_SaveNifti( Fname, M0name, M0_im );
            xASL_io_SaveNifti( Fname, Fname, ASL_im );

            xASL_Copy(Fmat,M0mat);
            Perfor(iD,iL)   = 1;
        end
    end

end


%         number 1 was different set up
%         Fname1   = fullfile(Dir,'ASL4D_1.nii');
%         Fname2   = fullfile(Dir,'ASL4D_2.nii');
%         Fname3   = fullfile(Dir,'ASL4D_3.nii');
%
%         IM1      = xASL_io_ReadNifti(Fname1);
%         IM1      = IM1.dat(:,:,:,:);
%
%         IM2      = xASL_io_ReadNifti(Fname2);
%         IM2      = IM2.dat(:,:,:,:);
%
%         IM3      = xASL_io_ReadNifti(Fname3);
%         IM3      = IM3.dat(:,:,:,:);
%
%         IM(:,:,:,1:2)   = IM1;
%         IM(:,:,:,3:4)   = IM2;
%         IM(:,:,:,5:6)   = IM3;
%
%         xASL_io_SaveNifti( Fname1, Fname, IM );
