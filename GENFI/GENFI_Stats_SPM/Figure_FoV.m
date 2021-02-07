%% Admin
% Which slices to show
x.S.SagSlices     = [40 53 78];
x.S.ConcatSliceDims = 0;
x.S.Square        = 0;

% Color scheme
jet_256         = jet(256);
jet_256(1,:)    = 0;

%% Create field of view probability maps

FList   = xASL_adm_GetFileList( x.D.PopDir, '^PWI_(GE|PH|SI).*_ASL_1\.(nii|nii\.gz)$');
clear IM
% Count   = [1 1 1 1];
% for iF=1:length(FList)
%     clear tIM Fpath Ffile Fext
%     tIM     = xASL_nifti(FList{iF});
%     [Fpath Ffile Fext]  = fileparts( FList{iF} );
%     if     ~isempty(findstr( Ffile ,'GE'))
%             IM(:,:,:,Count(1),1)     = 1-isnan(tIM.dat(:,:,:));
%             Count   = Count+[1 0 0 0];
%     elseif ~isempty(findstr(Ffile,'PH_Achieva_Bsup'))
%             IM(:,:,:,Count(2),2)     = 1-isnan(tIM.dat(:,:,:));
%             Count   = Count+[0 1 0 0];
%     elseif ~isempty(findstr(Ffile,'PH_Achieva_noBsup')) 
%             IM(:,:,:,Count(3),3)     = 1-isnan(tIM.dat(:,:,:));
%             Count   = Count+[0 0 1 0];
%     elseif ~isempty(findstr(Ffile,'SI_Trio')) 
%             IM(:,:,:,Count(4),4)     = 1-isnan(tIM.dat(:,:,:));
%             Count   = Count+[0 0 0 1];
%     else    error(['scan ' num2str(iF) ' doesnt work']);
%     end
% end

for iF=1:x.nSubjects
    clear tIM
    Fname       = fullfile( x.D.PopDir, ['PWI_' x.SUBJECTS{iF} '_ASL_1.nii']);
    tIM         = xASL_nifti(Fname);
    IM(:,:,:,iF)= 1-isnan(tIM.dat(:,:,:));
end

niiFile     = 'C:\Backup\ASL\GENFI\GENFI_DF2_2_Long\analysis\dartel\VBA_mask_final.nii';
mask        = xASL_nifti(niiFile);
mask        = mask.dat(:,:,:);

IMnew       = (sum(1-IM,4).*mask+mask)./374;

Seq         = TransformDataViewDimension( IMnew, x );
Seq         = Seq; 
figure(ii);
imshow(Seq,[0 0.06],'colormap',jet_256)




dip_image(IMnew(:,:,:,2))

