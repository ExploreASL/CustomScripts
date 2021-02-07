DIR         = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\ExamplePVEC';

ORInii      = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\StatsMaps\CBF_clustP01\permute_LongitudinalTimePoint\Clusters_check_PVEC_ratio.nii';
SaveROI     = fullfile(DIR, ['ROI_' num2str(iSubject) '.nii']);
SaveGM      = fullfile(DIR, ['pGM_' num2str(iSubject) '.nii']);
SaveWM      = fullfile(DIR, ['pWM_' num2str(iSubject) '.nii']);
SaveCBF     = fullfile(DIR, ['CBF_' num2str(iSubject) '.nii']);


xASL_io_SaveNifti(ORInii,SaveROI,CurrentMask{1});
xASL_io_SaveNifti(ORInii,SaveGM,GMmap);
xASL_io_SaveNifti(ORInii,SaveWM,WMmap);
xASL_io_SaveNifti(ORInii,SaveCBF,squeeze(ASL.Data.data(SUBJECT_SESSION,:,:,:)));





% Create histogram
[X N]   = hist(CBF{iAI});
figure(1);plot(N,X)

GMmasktemp      = TempCurrentMask & isfinite(temp) &  GMmap>0.5;
WMmasktemp      = TempCurrentMask & isfinite(temp) &  WMmap>0.5;
CSFmasktemp     = TempCurrentMask & isfinite(temp) & CSFmap>0.5;
CBFgm           = temp(GMmasktemp);
CBFwm           = temp(WMmasktemp);
CBFcsf          = temp(CSFmasktemp);

[X N]   = hist(CBFgm(:));
[X N]   = hist(CBFwm(:));
[X N]   = hist(CBFcsf(:));

figure(1);plot(N,X)


      clear TempCurrentMask
                        TempCurrentMask                 = CurrentMask{iAI};
                        CSFmap                          = 1-GMmap-WMmap;
                        TempCurrentMask(CSFmap>0.35)    = 0;
                        clear gwpv
                        % Calculate the PVEc CBF
                        CBF{iAI}                        = temp(  TempCurrentMask & isfinite(temp) );
                        gwpv{iAI}(:,1)                  = GMmap( TempCurrentMask & isfinite(temp) );
                        gwpv{iAI}(:,2)                  = WMmap( TempCurrentMask & isfinite(temp) );
                        gwcbf{iAI}                      = (CBF{iAI}')*pinv(gwpv{iAI}');
