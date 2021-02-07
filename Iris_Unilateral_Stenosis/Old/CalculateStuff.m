%% Better to use the L-ICA or R-ICA data, and store them

ACA=0; % Insert AI data here from 
MCA=0;
PCA=0;
ACA   = ACA([2:2:end],:);
MCA   = MCA([2:2:end],:);
PCA   = PCA([2:2:end],:);

AntCirc     = (ACA+MCA)./2;
PosCirc     = PCA;

[X N]       = hist(abs(AntCirc));
figure(1);
plot(N,X)
xlabel('Lateralization (%)');
ylabel('Patients (n)');
title('Lateralization histogram');

[X N]       = hist(abs(PosCirc));
figure(1);
plot(N,X)
xlabel('Lateralization (%)');
ylabel('Patients (n)');
title('Lateralization histogram');

[p, h, stats] = signtest(abs(AntCirc));

[coef, pval] = corr(AntCirc, PosCirc)

clear LateralizedCBF
for iA=1:length(AntCirc)
    clear TempIm
    TempIm                              = abs(squeeze(ASL_untreated.Data.data(iA,:,:,:)));
    for ii=1:4
        TempIm                          = xASL_im_ndnanfilter(TempIm,'gauss',[1.885 1.885 1.885],1);
    end
    
    if  AntCirc(iA,1)<0
        LateralizedCBF(iA,:,:,:)        = TempIm;
    else
        
        for iX=1:size(TempIm,1)
            LateralizedCBF(iA,iX,:,:)   = TempIm(size(TempIm,1)-iX+1,:,:);
        end
    end
end
        

% Same without lateralizing
MeanCBF                     = squeeze(xASL_stat_MeanNan(ASL_untreated.Data.data,1));
DATA_OUT2                    = TransformDataViewDimension( MeanCBF );

% LateralizedCBF
% LateralizedCBF(LateralizedCBF<0)    = 0;
% LateralizedCBF                      = LateralizedCBF./2;
% LateralizedCBF(LateralizedCBF>150)  = 150;
MeanLateralizedCBF                  = squeeze(xASL_stat_MeanNan(LateralizedCBF,1));
DATA_OUT                            = TransformDataViewDimension( MeanLateralizedCBF );

% Subtraction
clear SubtractLR
Dim1    = size(MeanLateralizedCBF,1);
for iX=1:Dim1/2
    SubtractLR(iX,:,:)            = MeanLateralizedCBF(iX,:,:) - MeanLateralizedCBF(Dim1-iX+1,:,:);
end

dip_image([DATA_OUT])
dip_image([SubtractLR])
dip_image([DATA_OUT-DATA_OUT2])
