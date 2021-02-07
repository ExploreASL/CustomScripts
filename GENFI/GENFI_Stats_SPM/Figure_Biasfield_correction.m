%% Create Figure Biasfield correction

%% 3) Get average CBF image after  biasfield correction

for iSite=1:nSites
    Ind_Biasfield(:,:,:,iSite)  = MeanIM(:,:,:,iSite);
end

% Store reference images
RefIM{3}                           = xASL_im_rotate(Ind_Biasfield(:,:,53,1),90);
for iSite=2:nSites
    RefIM{3}                       = [RefIM{3} xASL_im_rotate(Ind_Biasfield(:,:,53,iSite),90)];
end



%% 1) Get average CBF image before biasfield correction
clear MeanIM Ind_Biasfield 


% Import images per site
for iSite=1:nSites
    clear SiteScans nScans
    SiteScans       = find(x.S.SetsID(:,SiteSet)==AllSites(iSite));
    nScans          = length(SiteScans);

    for iScan=1:nScans
        clear iSubSess iSub iSess FileName tNII tIM
        iSubSess                = SiteScans(iScan);
        iSub                    = ceil(iSubSess/x.nSessions);
        iSess                   = iSubSess- ((iSub-1)*x.nSessions);
        FileName                = fullfile(x.D.PopDir,'BackupBeforeSiteRescale_1',['qCBF_' x.SUBJECTS{iSub} '_' x.SESSIONS{iSess} '.nii']);
        tNII                    = xASL_nifti(FileName);
        tIM                     = tNII.dat(:,:,:);
        IM(:,:,:,iScan)         = tIM;
        NameList{iScan,iSite}   = [x.SUBJECTS{iSub} '_' x.SESSIONS{iSess}];
    end

    MeanIM(:,:,:,iSite)         = xASL_stat_MeanNan(IM,4);
    clear IM
end



for iSite=1:nSites
    Ind_Biasfield(:,:,:,iSite)  = MeanIM(:,:,:,iSite);
end

% Store reference images
RefIM{1}                           = xASL_im_rotate(Ind_Biasfield(:,:,53,1),90);
for iSite=2:nSites
    RefIM{1}                       = [RefIM{1} xASL_im_rotate(Ind_Biasfield(:,:,53,iSite),90)];
end


%% 2) Get biasfields
for iSite=1:nSites
    clear SiteScans nScans
    SiteScans       = find(x.S.SetsID(:,SiteSet)==AllSites(iSite));
    nScans          = length(SiteScans);

    FieldFileName                   = fullfile(x.D.PopDir,['Biasfield_Multipl_Site_' num2str(iSite) '.nii']);
    tNII                            = xASL_nifti(FieldFileName);
    BiasFieldMultipl(:,:,:,iSite)   = tNII.dat(:,:,:);
end

% Store reference images
RefIM{2}                          = xASL_im_rotate(BiasFieldMultipl(:,:,53,1),90);
for iSite=2:nSites
    RefIM{2}                       = [RefIM{2} xASL_im_rotate(BiasFieldMultipl(:,:,53,iSite),90)];
end
    

%% Visualization
figure(1);
jet_256         = jet(256);
jet_256(1,:)    = 0;
imshow([RefIM{1};RefIM{2}.*60;RefIM{3}],[0 120],'colormap',jet_256)
imshow([RefIM{1}],[0 120],'colormap',jet_256)
imshow([RefIM{2}.*60],[0 120],'colormap',jet_256)
imshow([RefIM{3}],[0 120],'colormap',jet_256)
