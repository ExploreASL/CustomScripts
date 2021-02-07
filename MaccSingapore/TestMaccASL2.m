

% 1st volume is an M0 scan
% 2nd volume is a dummy volume
% 3-end is label control

% scans were apparently repeated twice





%% Xingfeng's scan with Bsup:
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD552/20200724_094511ep2dpcaslbsve11es036a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD552/20200724_094511ep2dpcaslbsve11es037a001.nii.gz';

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD552/ASL_1';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,3:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-2) = IM2(:,:,:,3:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);

%% Xingfeng's scan without Bsup:
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD552/20200724_094511ep2dpcaslnobsve11es040a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD552/20200724_094511ep2dpcaslnobsve11es041a001.nii.gz';

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD552/ASL_2';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,3:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-2) = IM2(:,:,:,3:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);






















%% Xingfeng's scan with Bsup:
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD590/20200722_110132ep2dpcaslbsve11es040a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD590/20200722_110132ep2dpcaslbsve11es041a001.nii.gz';

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD590/ASL_1';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,3:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-2) = IM2(:,:,:,3:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);

%% Xingfeng's scan without Bsup:
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD590/20200722_110132ep2dpcaslnobsve11es044a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD590/20200722_110132ep2dpcaslnobsve11es045a001.nii.gz';

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD590/ASL_2';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,3:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-2) = IM2(:,:,:,3:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);

%% Original scan on new scanner
% Has no background suppression, and no dummy scan
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD590/20200722_110132ep2dpCASLRF82nr47gap560s036a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC 2/HD590/20200722_110132ep2dpCASLRF82nr47gap560s037a001.nii.gz';

IM1=xASL_io_Nifti2Im(Path1);
IM2=xASL_io_Nifti2Im(Path2);

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD590/ASL_3';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,2:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-1) = IM2(:,:,:,2:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);














%% Xingfeng's scan with Bsup:
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC/HD679/20200727_095422ep2dpcaslbsve11es041a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC/HD679/20200727_095422ep2dpcaslbsve11es042a001.nii.gz';

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD679/ASL_1';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,3:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-2) = IM2(:,:,:,3:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);

%% Xingfeng's scan without Bsup:
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC/HD679/20200727_095422ep2dpcaslnobsve11es045a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC/HD679/20200727_095422ep2dpcaslnobsve11es046a001.nii.gz';

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD679/ASL_2';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,3:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-2) = IM2(:,:,:,3:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);

%% Original scan on new scanner
% Has no background suppression, and no dummy scan
Path1 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC/HD679/20200727_095422ep2dpCASLRF82nr47gap560s037a001.nii.gz';
Path2 = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/pCASL_MACC/HD679/20200727_095422ep2dpCASLRF82nr47gap560s038a001.nii.gz';

IM1=xASL_io_Nifti2Im(Path1);
IM2=xASL_io_Nifti2Im(Path2);

DestDir = '/Users/henk/ExploreASL/ASL/Test_MaccSingapore/analysis/HD679/ASL_3';
PathM0 = fullfile(DestDir, 'M0.nii');
PathASL4D = fullfile(DestDir, 'ASL4D.nii');

IM1 = xASL_io_Nifti2Im(Path1);
IM2 = xASL_io_Nifti2Im(Path2);

M0(:,:,:,1) = IM1(:,:,:,1);
M0(:,:,:,2) = IM2(:,:,:,1);

xASL_adm_CreateDir(DestDir);
xASL_io_SaveNifti(Path2, PathM0, M0, [], 0);

ASL4D = IM1(:,:,:,2:end);
ASL4D(:,:,:,end+1:end+size(IM2,4)-1) = IM2(:,:,:,2:end);
xASL_io_SaveNifti(Path2, PathASL4D, ASL4D, [], 0);


