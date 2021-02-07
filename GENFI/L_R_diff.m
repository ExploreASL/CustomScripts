%% Check L-R differences brain
% First brain template

NIIname     = 'C:\ASL_pipeline_HJ\Maps\rgrey.nii';
NII         = xASL_nifti(NIIname);

IM          = NII.dat(:,:,:);

% dip_image(IM)
% size(IM,2)
%
% IM(61:end,:,:)    = 0;

LeftBrain           = IM;
RightBrain          = IM;

for iI=1:60
    LeftBrain(121-iI+1,:,:)     = IM(iI,:,:);
    RightBrain(iI,:,:)          = IM(121-iI+1,:,:);
end

dip_image([xASL_im_rotate(LeftBrain,90) xASL_im_rotate(RightBrain,90) xASL_im_rotate((LeftBrain-RightBrain),90)])

sum(LeftBrain(:))
sum(RightBrain(:))

%% Nearly no difference, so try finding the effect of negative determinants:

% First create artificial L & R

CheckName   = 'C:\Backup\ASL\GENFI\CheckLeftRight\DARTEL_c1T1_C9ORF047_ORI_2.nii';
CheckNII    = xASL_nifti(CheckName);

CheckNII.mat(2,2)   = -1.5;
CheckNII.mat0(2,2)   = -1.5;

xASL_io_SaveNifti( CheckName, CheckName, IM );

IM          = CheckNII.dat(:,:,:);

IM(80:100,60:80,40:60)   = 2;

xASL_io_SaveNifti( CheckName, CheckName, IM );

dip_image(IM)


%% Template

CheckName   = 'C:\ASL_pipeline_HJ\Maps\rgrey.nii';
CheckNII    = xASL_nifti(CheckName);

%% Matrix check

FileName    = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GENFI\T1.nii';
NII         = xASL_nifti(FileName);
NII.mat - NII.mat0


NII.hdr



%%%%%%%%%

%% Get matrices for total GENFI T1s
clear
ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis';
% FList   = xASL_adm_GetFileList( ROOT, '^T1\.(nii|nii\.gz)$','FPListRec');
FList   = xASL_adm_GetFileList( ROOT, '^ASL4D\.(nii|nii\.gz)$','FPListRec');

for iF=1:length(FList)
    tNII            = xASL_nifti(FList{iF});
    matrix1(:,:,iF) = spm_imatrix(tNII.mat);
    matrix2(:,:,iF) = spm_imatrix(tNII.mat0);
    TempReg         = tNII.mat/tNII.mat0;
    RegCheck(:,:,iF)= spm_imatrix(TempReg);
    det2(iF,1)      = det(tNII.mat0(1:3,1:3));
    detReg(iF,1)    = det(TempReg(1:3,1:3));
end

InitialImportT1     = squeeze(matrix2)';
InitialImportASL    = squeeze(matrix2)';
RegCheckT1          = squeeze(RegCheck)';



matrixDiff      = matrix1-matrix2;

mean_matrix1    = round(mean(matrix1,3).*100)./100;
std_matrix1     = round(std(matrix1,[],3).*100)./100;
LCI             = round((mean_matrix1-(1.96.*std_matrix1)).*100)./100;
HCI             = round((mean_matrix1+(1.96.*std_matrix1)).*100)./100;

mean_matrix2    = round(mean(matrix2,3).*100)./100;
std_matrix2     = round(std(matrix2,[],3).*100)./100;
LCI0            = round((mean_matrix2-(1.96.*std_matrix2).*100))./100;
HCI0            = round((mean_matrix2+(1.96.*std_matrix2).*100))./100;

mean_matrixDiff    = round(mean(matrixDiff,3).*100)./100;
std_matrixDiff     = round(std(matrixDiff,[],3).*100)./100;
LCI0            = round((mean_matrixDiff-(1.96.*std_matrixDiff)).*100)./100;
HCI0            = round((mean_matrixDiff+(1.96.*std_matrixDiff)).*100)./100;



ROOT    = 'C:\Backup\ASL\GENFI\GENFI_DF1_new\PH Achieva Bsup\analysis';
FList   = xASL_adm_GetFileList( ROOT, '^T1\.(nii|nii\.gz)$','FPListRec');

for iF=1:length(FList)
    tNII            = xASL_nifti(FList{iF});
    matrix1(:,:,iF) = spm_imatrix(tNII.mat);
    matrix2(:,:,iF) = spm_imatrix(tNII.mat0);
end

mean_matrix1    = round(mean(matrix1,3).*100)./100;
std_matrix1     = round(std(matrix1,[],3).*100)./100;
LCI             = round(mean_matrix1-(1.96.*std_matrix1).*100)./100;
HCI             = round(mean_matrix1+(1.96.*std_matrix1).*100)./100;

%% translate matrix to parameters
% fname   = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GENFI\T1.nii';
% nii     = xASL_nifti(fname);
% nii.hdr.srow_x
% nii.hdr.srow_y
% nii.hdr.srow_z
% nii.mat
% nii.mat0
%
% imat    = spm_imatrix(nii.mat0);
% transl  = imat( 1: 3);
% rot     = imat( 4: 6);
% scalef  = imat( 7: 9);
% shear   = imat(10:12);



%% Test
% 8 very little 		C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis\GRN037\T1.nii
% 15 -> large x 		C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis\GRN078\T1.nii
% 4 -> large z rot 	C:\Backup\ASL\GENFI\GENFI_DF1_new\GE MR750\analysis\GRN018\T1.nii

% fname   = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GRN037\T1.nii';
% nii     = xASL_nifti(fname);
% nii.mat==nii.mat0
% nii.mat==[nii.hdr.srow_x;nii.hdr.srow_y;nii.hdr.srow_z;[0 0 0 1]]
% matPrev     = nii.mat0;
% matPrev     = spm_imatrix(matPrev);
%
%
% Diffmat     = matPrev-spm_imatrix(nii.mat)
clear
fname           = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GRN037\rT1.nii';
nii             = xASL_nifti(fname);
nii.mat         ==nii.mat0



temp    = nii.mat0
t2  = spm_imatrix(temp)
t2(7)=1.5;
t3=     spm_matrix(t2)
t3(1,3)     = -0.00001;
t4      = spm_imatrix(t3);
t4(4)=pi;
spm_matrix(t4)
t4(6)=0.5*pi;




% Pmat1    = spm_imatrix(nii.mat);
Pmat2    = spm_imatrix(nii.mat)
Pmat3    = spm_imatrix(nii.mat0)
Pmat3(4) =pi;
Pmat3(6) =pi;

spm_matrix(Pmat3)

tempMat     = nii.mat0;
t2mat       = spm_imatrix(tempMat);
t2mat(7)    = -t2mat(7);
TempMat2    = spm_matrix(t2mat)
det(TempMat2)

t3  = spm_imatrix(TempMat2)
t3(4)=pi;
t3(5)=pi;
t3(6)=pi;
det(spm_matrix(t3))



Pmat2(4)=pi;
det(spm_matrix(Pmat3))
det(nii.mat0)
Pmat1    = spm_imatrix(nii.mat);

Pmat3   = spm_imatrix(nii.mat0)

tempmat     = nii.mat0
tempmat(1,4)=-tempmat(1,4);

spm_imatrix(tempmat)

% Pmat(7) = -Pmat(7);
% Pmat(1) = -110;
% Pmat(2) = 80;
% Pmat(3) = -200;
% Pmat(6) = 0.25*pi;
% Pmat(7) = 0.25*pi;
% Pmat(8) = 0.25*pi;
% mat     = spm_matrix(Pmat)
%

%% Test2
fnamePre   = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GRN078\T1.nii';
fnamePost  = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GRN078\T1_2.nii';

niiPRE      = xASL_nifti(fnamePre);
niiPost     = xASL_nifti(fnamePost);

det(niiPRE.mat(1:3,1:3))
det(niiPost.mat(1:3,1:3))
det(niiPRE.mat0(1:3,1:3))
det(niiPost.mat0(1:3,1:3))

det(niiPRE.mat/niiPRE.mat0)
spm_imatrix(niiPost.mat/niiPRE.mat)
spm_imatrix(niiPRE.mat/niiPost.mat)

mat0

t2 = niiPRE.mat
t2(2,1)     = -t2(2,1)

spm_imatrix((niiPRE.mat/t2))


%% Test3
fnamePre   = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GRN078\rgrey.nii';
fnamePost  = 'C:\Backup\ASL\GENFI\TestMatrix\GENFI_T1MatrixTrial\analysis\GRN078\rgrey_2.nii';

niiPRE      = xASL_nifti(fnamePre);
niiPost     = xASL_nifti(fnamePost);

niiPRE.mat
niiPost.mat

Pmat    = spm_imatrix(niiPost.mat/niiPRE.mat)
Pmat(10) = 2;
niiPRE.mat*spm_matrix(Pmat)

Pmat = spm_imatrix(niiPRE.mat)
Pmat(10)=2;
