%% Try 2D histogram


%% Load images before registration
ROOT    = 'C:\Backup\ASL\GENFI\DARTELIterationsTrial\NormalIterations10Subjects';

FList   = xASL_adm_GetFileList( ROOT, '^(Atroph_|Normal_).*\.(nii|nii\.gz)$');

% workdir     ='C:\werk\Werk_OLD\Werk_OLD\Dennis voxel-wise plot\';

for iF=1:5
    NII                     = xASL_nifti(FList{iF});
    AtrophMean(:,:,:,iF)    = NII.dat(:,:,:);
end
AtrophMean  = mean(AtrophMean,4);

for iF=6:10
    NII                     = xASL_nifti(FList{iF});
    NormMean(:,:,:,iF-5)      = NII.dat(:,:,:);
end
NormMean  = mean(NormMean,4);

%% Load images after registration
ROOT    = 'C:\Backup\ASL\GENFI\DARTELIterationsTrial\NormalIterations10Subjects\Final\ThirdDARTEL\Final3\4rdDARTEL\5thDARTEL';

FList   = xASL_adm_GetFileList( ROOT, '^(wAtroph_|wNormal_).*\.(nii|nii\.gz)$');

% workdir     ='C:\werk\Werk_OLD\Werk_OLD\Dennis voxel-wise plot\';

for iF=1:5
    NII                     = xASL_nifti(FList{iF});
    AtrophMean2(:,:,:,iF)    = NII.dat(:,:,:);
end
AtrophMean2  = mean(AtrophMean2,4);

for iF=6:10
    NII                     = xASL_nifti(FList{iF});
    NormMean2(:,:,:,iF-5)      = NII.dat(:,:,:);
end
NormMean2  = mean(NormMean2,4);






dip_image([AtrophMean2.*2 NormMean2.*2 AtrophMean2+NormMean2])


FName   = fullfile( ROOT, 'normal_5.nii');
NII     = xASL_nifti(FName);
IM      = NII.dat(:,:,:);

FName   = fullfile( ROOT, 'normal_4.nii');
NII     = xASL_nifti(FName);
IM2     = NII.dat(:,:,:);

FName   = fullfile( ROOT, 'atroph_5.nii');
NII     = xASL_nifti(FName);
IM3     = NII.dat(:,:,:);

MASKim  = IM>0.2*max(IM(:));

IMn     = IM(MASKim);
IMn2    = IM2(MASKim);
IMn3    = IM3(MASKim);


NN      = size(IMn);
NN      = NN(1);

ndhist_HJM(randn(NN,1)',randn(NN,1)','bins',1);
figure(1);ndhist_HJM(IMn.^5,IMn3.^5,'bins',1); % 
figure(2);ndhist_HJM(IMn,IMn2,'bins',1); % 

MINax   = 0.5;
MAXax   = 1;

figure(1);ndhist_HJM(NormMean(MASKim),AtrophMean(MASKim),'bins',1,'axis',[MINax 1 MINax 1]);
figure(2);ndhist_HJM(NormMean2(MASKim),AtrophMean2(MASKim),'bins',1,'axis',[MINax 1 MINax 1]);

figure(1);ndhist_HJM(NormMean,AtrophMean,'bins',2,'axis',[MINax 1 MINax 1]);
figure(2);ndhist_HJM(NormMean2,AtrophMean2,'bins',2,'axis',[MINax 1 MINax 1]);

IMn3    = IMn+randn(NN,1);



X   = randn(NN,1)';
Y   = randn(NN,1)';
X   = X./max(X(:))+1;
Y   = Y./max(Y(:))+1;

% Random noise
figure(1);ndhist_HJM(X,Y,'bins',1)

% Correlation
N1  = ([1:1:NN]./NN)+0.5;
N2  = ([1:1:NN]./NN)+0.5;

% % Negative correlation
% N1  = ([1:1:NN]./NN)+0.5;
% N2  = -([1:1:NN]./NN)+0.5;

figure(2);ndhist_HJM(N1,N2,'bins',1)

% Correlation plus noise
figure(3);ndhist_HJM(X.*-N1,Y.*-N2,'bins',1)

%% Now with CBF maps
clear
ROOT    = 'C:\Backup\ASL\GENFI\DARTELIterationsTrial\Try2Dhistogram';
FName   = fullfile(ROOT, 'DARTEL_PWI_TEMPLATE.nii');
NII     = xASL_nifti( FName );
IM      = NII.dat(:,:,:);
IM(isnan(IM))   = 0;

skullName   = fullfile(ROOT, 'skullstrip.nii');
NII         = xASL_nifti(skullName);
MASKim      = NII.dat(:,:,:);
MASKim(isnan(MASKim))   = 0;
MASKim      = logical(MASKim);
% When imaging are exactly identical
IM1     = IM;
IM2     = IM;

figure(1);ndhist_HJM(IM(MASKim),IM2(MASKim),'bins',0.5);

[pval1 conv]=corr(IM(MASKim),IM2(MASKim))


TotalIM(:,:,:,1)= IM1;
TotalIM(:,:,:,2)= IM2;

TC              = min(TotalIM,[],4)./max(TotalIM,[],4);
TC              = xASL_stat_MeanNan(TC(:)).*100;

% When shifting IM2 a lot (poor reg)
clear IM1 IM2 TotalIM TC
IM1                 = IM;
IM2                 = IM;
IM2             = zeros(size(IM,1),size(IM,2),size(IM,3));
IM2(1:81,:,:)   = IM(41:121,:,:);
IM2(82:121,:,:)   = IM(1:40,:,:);

TC = xASL_stat_TanimotoCoeff( IM1, IM2, MASKim, 2);

dip_image([xASL_im_rotate(IM.*MASKim,90) xASL_im_rotate(IM2.*MASKim,90) xASL_im_rotate((IM-IM2).*MASKim,90)])

figure(1);ndhist_HJM(IM(MASKim),IM2(MASKim),'bins',0.5);



% When shifting IM2 just a little
clear IM1 IM2 TotalIM TC
IM1                 = IM;
IM2                 = IM;
IM2                 = zeros(size(IM,1),size(IM,2),size(IM,3));
IM2(1:116,:,:)      = IM(6:121,:,:);
IM2(117:121,:,:)    = IM(1:5,:,:);

TC = xASL_stat_TanimotoCoeff( IM1, IM2, MASKim, 2);


% Smooth both
FWHM                    = 64; % mm smoothing kernel (3D)
FwHm2SD                 = (2*(2*reallog(2))^0.5);
FWHM                    = FWHM/1.5; % to divide by voxel-size for number of voxels
SD                      = round(FWHM/FwHm2SD);

IM1                  = xASL_im_ndnanfilter(IM1,'gauss',[SD SD SD]./1.06,1);
IM2                  = xASL_im_ndnanfilter(IM2,'gauss',[SD SD SD]./1.06,1);


% Adding noise
NOISEim1        = (randn(121,145,121)+1).*10;
NOISEim2        = (randn(121,145,121)+1).*10;

IM1             = IM+NOISEim1;
IM2             = IM+NOISEim2;

dip_image([xASL_im_rotate(IM1.*MASKim,90) xASL_im_rotate(IM2.*MASKim,90) xASL_im_rotate((IM1-IM2).*MASKim,90)])

figure(1);ndhist_HJM(IM1(MASKim),IM2(MASKim),'bins',0.5);
[pval1 conv]=corr(IM1(MASKim),IM2(MASKim))

TC = xASL_stat_TanimotoCoeff( IM1, IM2, MASKim, 2);

% Multiplying noise
NOISEim1        = randn(121,145,121)./10+1;
NOISEim2        = randn(121,145,121)./10+1;

IM1             = IM.*NOISEim1;
IM2             = IM.*NOISEim2;

dip_image([xASL_im_rotate(IM1.*MASKim,90) xASL_im_rotate(IM2.*MASKim,90) xASL_im_rotate((IM1-IM2).*MASKim,90)])

figure(2);ndhist_HJM(IM1(MASKim),IM2(MASKim),'bins',1);

[pval1 conv]=corr(IM1(MASKim),IM2(MASKim))

TC = xASL_stat_TanimotoCoeff( IM1, IM2, MASKim, 2);

% Addition & multiplication of noise
NOISEim1        = randn(121,145,121)./5+1;
NOISEim2        = randn(121,145,121)./5+1;

IM1             = IM.*NOISEim1;
IM2             = IM.*NOISEim2;

NOISEim1        = (randn(121,145,121)+1).*10;
NOISEim2        = (randn(121,145,121)+1).*10;

IM1             = IM1+NOISEim1;
IM2             = IM2+NOISEim2;

% Smooth both

FWHM                    = 10; % mm smoothing kernel (3D)
FwHm2SD                 = (2*(2*reallog(2))^0.5);
FWHM                    = FWHM/1.5; % to divide by voxel-size for number of voxels
SD                      = round(FWHM/FwHm2SD);

IM1                  = xASL_im_ndnanfilter(IM1,'gauss',[SD SD SD]./1.06,1);
IM2                  = xASL_im_ndnanfilter(IM2,'gauss',[SD SD SD]./1.06,1);


dip_image([xASL_im_rotate(IM1.*MASKim,90) xASL_im_rotate(IM2.*MASKim,90) xASL_im_rotate((IM1-IM2).*MASKim,90)])
figure(2);ndhist_HJM(IM1(MASKim),IM2(MASKim),'bins',0.5);
[pval1 conv]=corr(IM1(MASKim),IM2(MASKim))

TC = xASL_stat_TanimotoCoeff( IM1, IM2, MASKim, 2);



%% Check DARTEL improvement
clear

