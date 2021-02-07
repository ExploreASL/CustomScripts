clear

%%Load File
fileName = 'C:\Backup\ASL\Sleep2\analysis\dartel\DARTEL_c1T1_101.nii';
IM  = xASL_nifti(fileName);
IM  = IM.dat(:,:,:);
IM  = IM(:,:,53);
IM  = IM(:,13:145-12);

Fs      = 1;
Nsamps  = size(IM,1);
t       = (1/Fs)*(1:Nsamps)          %Prepare time data for plot



for iL=1:121
    IMline  = IM(:,iL);
    
    %Do Fourier Transform
    y_fftTemp           = abs(fft(IMline));                         %Retain Magnitude
    y_fftFinal(:,iL)    = y_fftTemp(1:Nsamps/2);                    %Discard Half of Points
    f(:,iL)             = Fs*(0:Nsamps/2-1)/Nsamps;                 %Prepare freq data for plot
end

close
figure(1)
plot(f(:,1),y_fftFinal(:,1))
figure(2)
plot(mean(f,2),mean(y_fftFinal,2))




%Load File
fileName = 'C:\Backup\ASL\Sleep2\analysis\dartel\DARTEL_CBF_101_ASL_1.nii';
IM  = xASL_nifti(fileName);
IM  = IM.dat(:,:,:);
IM  = IM(:,:,53);
IM  = IM(:,13:145-12);
IM(isnan(IM))   = 0;


Fs      = 1;
Nsamps  = size(IM,1);
t       = (1/Fs)*(1:Nsamps)          %Prepare time data for plot



for iL=1:121
    IMline  = IM(:,iL);
    
    %Do Fourier Transform
    y_fftTemp           = abs(fft(IMline));                         %Retain Magnitude
    y_fftFinal(:,iL)    = y_fftTemp(1:Nsamps/2);                    %Discard Half of Points
    f(:,iL)             = Fs*(0:Nsamps/2-1)/Nsamps;                 %Prepare freq data for plot
end

figure(3)
plot(f(:,1),y_fftFinal(:,1))
figure(4)
plot(mean(f,2),mean(y_fftFinal,2))
