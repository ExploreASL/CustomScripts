%% Study ASL MAPT031

PerfName    = 'D:\GENFI_check\GENFI_DF1\analysis\MAPT033\perf\ASL4D.nii';
PerfNii     = xASL_nifti( PerfName );
PerfIm      = -PerfNii.dat(:,:,:);

dip_image(PerfIm)

%%

DiffName    = 'D:\GENFI_check\GENFI_DF1\analysis\MAPT033\diff\ASL4D.nii';
DiffNii     = xASL_nifti( DiffName );
DiffIm      = DiffNii.dat(:,:,:,:);

AvDiffIm1   = -mean(DiffIm,4);


DiffIm(:,:,1:2:end-1) - DiffIm(:,:,2:2:end);


dip_image(AvDiffIm1)

% Use Pairs -> how to put in pipeline?

%% 

IndName    = 'D:\GENFI_check\GENFI_DF1\analysis\MAPT033\tag\ASL4D.nii';
IndNii     = xASL_nifti( IndName );
IndIm      = IndNii.dat(:,:,:,:);

Frame1      = IndIm(:,:,1:17);
Frame2      = IndIm(:,:,17+        1            :   17+(19*22)); % 18-435
Frame3      = IndIm(:,:,17+(19*22)+1            :   17+(19*22)+(18*17)); % 436-615
Frame4      = IndIm(:,:,17+(19*22)+(18*17)+1    :   end); % 742

Frame1      = singlesequencesort( xASL_im_rotate( Frame1,90) , 17);
Frame2      = singlesequencesort( xASL_im_rotate( Frame2,90) , 19);
Frame3      = singlesequencesort( xASL_im_rotate( Frame3,90) , 18);
Frame4      = singlesequencesort( xASL_im_rotate( Frame4,90) , 18); % 1 slice only

for iFrame=1:4
    EightFrames{iFrame}  = singlesequencesort( xASL_im_rotate(IndIm(:,:,17+((iFrame-1)*19*8)+1:17+(iFrame*19*8)),90) , 19);
end

dip_image( Frame3 )

% Frame 1
NewIm(:,:,:,1)  = IndIm(:,:,1:17);

% Frame 2
for iIm=1:22
    NewIm(:,:,:,1+iIm)  = IndIm(:,:,17+ ((iIm-1)*19)+3 : 17+ (iIm*19) );
end

% Frame 3
for iIm=1:17
    NewIm(:,:,:,1+22+iIm)  = IndIm(:,:,17+ ((22-1)*19)+19+((iIm-1)*18)+2 : 17+ ((22-1)*19)+19+(iIm*18) );
end

PerfImNew   = mean( NewIm(:,:,:,1:2:end-1) - NewIm(:,:,:,2:2:end) ,4);

dip_image(PerfImNew)

size(PerfImNew)



