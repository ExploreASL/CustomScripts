%% Introduction
%   Script is written by Rick van Tuijl & Henk-Jan Mutsaerts

%   Firstly  ->  ground thruth has been made by using pWM and pGM image from Sub-001.
%            the ground thruth image has been named by pseudoCBF.
%            Reslice/Resample the images of pWM and pGM to ASL format(3x3x7)
%   Secondly -> Averages of the GM and WM are calculated by using a threshold of 0.7 voor GM and 0.3 for WM.
%            By using this and multiplying with the intensity gives us the means for GM and WM.
%   Thirdly  -> Smoothing
%   Fourthly -> Native deformations is used for interpolating the images from
%            native space to standard space

%% c1T1     c1T1_ASL_space      RCT1_sub_001

c1T1                = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\c1T1.nii');
c1T1_ASL_space      = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\c1T1_ASLspace.nii');
RCT1_sub_001        = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\dartel\rc1T1_Sub-001.nii');

%% Create pseudo CBF

refIM      = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\ASL4D.nii';
srcIM      = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\c1T1.nii';
NewName1   = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\c1T1_ASLspace.nii';
Reslice_Init( refIM, srcIM, [], [], NewName1, 4 );

    srcIM       = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\c2T1.nii';
    NewName2  	= 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\c2T1_ASLspace.nii';
    Reslice_Init( refIM, srcIM, [], [], NewName2, 4 );

pGM     = nifti2IM(NewName1);
pWM     = nifti2IM(NewName2);

pseudoCBF   = pGM.*60+pWM.*20;
pseudoName  = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\PseudoCBF_ASLspace.nii';

save_nii_spm(NewName1,pseudoName,pseudoCBF);

%% Get average GM CBF

GMmask      = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\c1T1_ASLspace.nii');
PseudoCBF   = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\PseudoCBF_ASLspace.nii');

        GMmask      = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\wc1T1_ASLspace.nii');
        PseudoCBF   = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\wPseudoCBF_ASLspace.nii');

GMmask      = GMmask>0.7;

dip_image([GMmask.*60 PseudoCBF])

mean(mean(mean(PseudoCBF(GMmask))))

%% Main making pGM and CBF image and compare the ratio after transforming etc. 

refIM   = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\temp_mean_PWI.nii';
srcIM   = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\c1T1.nii';
NewName = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\c1T1.nii';
 
Reslice_Init( refIM, srcIM, [], [], NewName, 4 )

pGM  = nifti2IM(NewName)+1;
CBF  = nifti2IM(NewName)+1;

save_nii_spm(NewName,'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\pGM.nii',pGM,[],0); 
save_nii_spm(NewName,'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF.nii',CBF,[],0);

ValueNativeSpace = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF./pGM)));
dip_image (pGM)
dip_image (CBF)

%% ROI multiply

GMmask      = pGM>1.25;
GMmask2     = zeros(size(GMmask));

dip_image (GMmask2(:,:,7))
GMmask2(20:40,20:40,6:14) = 1;
GMmask3     = GMmask & GMmask2;

dip_image([GMmask(:,:,7) GMmask2(:,:,7) GMmask3(:,:,7)])
 
CBF(20:40,20:40,6:14)     = CBF(20:40,20:40,6:14).*1.5;

mean(mean(mean(GMmask(CBF))))
save_nii_spm(NewName,'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF_Mult.nii',CBF,[],0);

CBF_Mult  = nifti2IM('C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF_Mult.nii');
ValueNSMultiplication = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Mult./pGM)));

%% Noise
IMnoise = randn(80,80,17);
dip_image(IMnoise)

CBF_Noise     = CBF.*(1+IMnoise);
dip_image(CBF_Noise)
dip_image([CBF GMmask3])

figure()
[X , N] = hist(pGM(GMmask3));
plot(N,X);
hold on 
[X , N] = hist(CBF(GMmask3));
plot(N,X);
hold off

[X , N]   = hist(CBF(GMmask));
figure(1);plot(N , X)

save_nii_spm(NewName,'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF_Noise.nii',CBF_Noise,[],0); 

ValueNSNoise = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Noise./pGM)));

%% Smoothing
spm_jobman 
S8CBF = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\sCBF.nii';
S6CBF = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\s6CBF.nii';
sCBF  = nifti2IM(S8CBF);

ValueNativeSpace = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF./pGM)));
ValueNSMultiplication = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Mult./pGM)));
ValueNSNoise = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Noise./pGM)));
ValueNSSmooth = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(sCBF./pGM)));

%% Deforming 

symbols.ROOT = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\';
%pGM raw
NativeDeformations(symbols,'Sub-001','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\pGM.nii','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\pGM_def.nii',4);
%CBF raw
NativeDeformations(symbols,'Sub-001','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF.nii','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\CBF_def.nii',4);
%CBF Mult
NativeDeformations(symbols,'Sub-001','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF_Mult.nii','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\CBF_Mult_def.nii',4);
%CBF Noise
NativeDeformations(symbols,'Sub-001','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\CBF_Noise.nii','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\CBF_Noise_def.nii',4);
%CBF Smoothed
NativeDeformations(symbols,'Sub-001','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\sCBF.nii','C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\sCBF_def.nii',4);

% mean(mean(mean(())))

DefpGM = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\pGM_def.nii';
DefCBF = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\CBF_def.nii';
DefCBF_Mult = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\CBF_Mult_def.nii';
DefCBF_Noise = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\CBF_Noise_def.nii';
DefCBF_Smooth = 'C:\Users\r.tuijl\Documents\Unproc2\Example_SingleSubject_Unproc\Sub-001\ASL_1\Results\sCBF_def.nii';

DefpGM = nifti2IM(DefpGM+1);
DefCBF = nifti2IM(DefCBF+1);
DefCBF_Mult = nifti2IM(DefCBF_Mult+1);
DefCBF_Noise = nifti2IM(DefCBF_Noise+1);
DefCBF_Smooth = nifti2IM(DefCBF_Smooth+1);

ScoreTable = cell(3,5);
ScoreLabels = {'CBF/pGM','CBF_Mult/pGM','CBF_Noise/pGM','CBF_Smooth/pGM'};
ScoreSpace  = {'Native space','Standard space'}';
for iLabels = 2:size(ScoreTable,2)
    ScoreTable{1,iLabels} = ScoreLabels{1,iLabels-1};
end
for jLabels = 2:size(ScoreTable,1)
    ScoreTable{jLabels,1} = ScoreSpace{jLabels-1,1};
end

ScoreTable{2,2} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF./pGM)));
ScoreTable{2,3} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Mult./pGM)));
ScoreTable{2,4} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Noise./pGM)));
ScoreTable{2,5} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(sCBF./pGM)));

% ValueDef_SS_pGM = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefpGM./DefpGM)))
ScoreTable{3,2} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF./DefpGM)));
ScoreTable{3,3} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF_Mult./DefpGM)));
ScoreTable{3,4} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF_Noise./DefpGM)));
ScoreTable{3,5} = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF_Smooth./DefpGM)));


% ValueNativeSpace = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF./pGM)))
% ValueNSMultiplication = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Mult./pGM)))
% ValueNSNoise = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(CBF_Noise./pGM)))
% ValueNSSmooth = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(sCBF./pGM)))
% 
% ValueDef_SS_pGM = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefpGM./DefpGM)))
% ValueDef_SS_CBF = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF./DefpGM)))
% ValueDef_SS_Mult = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF_Mult./DefpGM)))
% ValueDef_SS_Noise = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF_Noise./DefpGM)))
% ValueDef_SS_Smooth = xASL_stat_MeanNan(xASL_stat_MeanNan(xASL_stat_MeanNan(DefCBF_Smooth./DefpGM)))



