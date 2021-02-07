%% Old Idea to repeat DARTEL

ROOT    = 'C:\Backup\ASL\Koen_Baas_3DGRASE_repro';
DList   = xASL_adm_GetFsList(ROOT,'^.*3D SOURCE$',1);
NewDir  = 'C:\Backup\ASL\Koen_Baas_3DGRASE_repro\NewStructure'

for iS=1:length(DList)
    Dlist2  = xASL_adm_GetFsList(fullfile(ROOT, DList{iS}, 'analysis'), '^10\d$',1);

    for iD=1:length(Dlist2)
        NewDir  = fullfile(NewDir,[DList{iS} '_' Dlist2{iD}]);
        OldDir  = fullfile(ROOT,DList{iS},'analysis', Dlist2{iD});

        xASL_Copy(OldDir,NewDir);


    end
end

%% New idea to simply take existing niftis

ROOT            = 'C:\Backup\ASL\Koen_Baas_3DGRASE_repro';
TemplateDir     = 'C:\Backup\ASL\Koen_Baas_3DGRASE_repro\Templates';
OriName         = 'C:\ExploreASL\Maps\rgrey.nii';
TemplateName    = {'1600ms_PLD' '1800ms_PLD' '1800ms_PLD_hires' '2000ms_PLD'};
Modalities      = {'PWI' 'mean_control' 'SD' 'SNR'};

for iM=1:length(Modalities)

    iM

    Dlist   = xASL_adm_GetFileList(ROOT,['^' Modalities{iM} '_\d{3}_ASL_\d\.(nii|nii\.gz)$'],'FPListRec');
    NextN   = [1 1 1 1 1];
    clear IM IMm IMs IMsnr
    for iD=1:length(Dlist)
        if  (~isempty(findstr(Dlist{iD},'17')) || ~isempty(findstr(Dlist{iD},'19')) ) && str2num(Dlist{iD}(end-4))==4
            ii=5;
        else
            ii  = str2num(Dlist{iD}(end-4));
        end

        IM{ii}(:,:,:,NextN(ii))     = xASL_io_Nifti2Im(Dlist{iD});
        NextN(ii)   = NextN(ii)+1;
    end

   for ii=1:5
        IMm(:,:,:,ii)     = xASL_stat_MeanNan(IM{ii},4);
        IMs(:,:,:,ii)     = xASL_stat_StdNan(IM{ii},[],4);
    end

%     IMm     = xASL_im_rotate(IMm,90);
%     IMs     = xASL_im_rotate(IMs,90);

    IMsnr   = IMm./IMs;

    for ii=1:5
        MaxN(ii)    = max(max(max(IMm(:,:,:,ii))));
    end

    IMm(:,:,:,2)    = (IMm(:,:,:,2)+IMm(:,:,:,3))./2;
    IMm(:,:,:,3)    = IMm(:,:,:,4);
    IMm(:,:,:,4)    = IMm(:,:,:,5);

    IMs(:,:,:,2)    = (IMs(:,:,:,2)+IMs(:,:,:,3))./2;
    IMs(:,:,:,3)    = IMs(:,:,:,4);
    IMs(:,:,:,4)    = IMs(:,:,:,5);

    IMsnr(:,:,:,2)    = (IMsnr(:,:,:,2)+IMsnr(:,:,:,3))./2;
    IMsnr(:,:,:,3)    = IMsnr(:,:,:,4);
    IMsnr(:,:,:,4)    = IMsnr(:,:,:,5);

    for ii=1:4
        xASL_io_SaveNifti(OriName,fullfile(TemplateDir,['Template_mean_' Modalities{iM} '_Philips_3DGRASE_' TemplateName{ii} '.nii']),IMm(:,:,:,ii) );
        xASL_io_SaveNifti(OriName,fullfile(TemplateDir,['Template_SD_' Modalities{iM} '_Philips_3DGRASE_' TemplateName{ii} '.nii']),IMs(:,:,:,ii) );
        xASL_io_SaveNifti(OriName,fullfile(TemplateDir,['Template_SNR_' Modalities{iM} '_Philips_3DGRASE_' TemplateName{ii} '.nii']),IMsnr(:,:,:,ii) );
    end

end
