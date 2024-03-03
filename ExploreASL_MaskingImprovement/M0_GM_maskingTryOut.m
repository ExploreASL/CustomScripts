popDir = '/Users/hjmutsaerts/ExploreASL/TryOut_Masking_1543/derivatives/ExploreASL/Population';
lowResListGM = xASL_adm_GetFileList(popDir, '^PV_pGM_.*','FPListRec',[],0);
lowResListWM = xASL_adm_GetFileList(popDir, '^PV_pWM_.*','FPListRec',[],0);
lowResListCSF = xASL_adm_GetFileList(popDir, '^PV_pCSF_.*','FPListRec',[],0);
lowResListGM = lowResListGM(2:4);
lowResListWM = lowResListWM(2:4);
lowResListCSF = lowResListCSF(2:4);

higResListGM = xASL_adm_GetFileList(popDir, '^rc1T1_.*','FPListRec',[],0);
higResListWM = xASL_adm_GetFileList(popDir, '^rc2T1_.*','FPListRec',[],0);
higResListCSF = xASL_adm_GetFileList(popDir, '^rc3T1_.*','FPListRec',[],0);
higResListGM = higResListGM([2 3 5]);
higResListWM = higResListWM([2 3 5]);
higResListCSF = higResListCSF([2 3 5]);

M0list = xASL_adm_GetFileList(popDir, '^noSmooth_M0.*','FPListRec',[],0);
M0list = M0list([1 2 4]);

for iList=1:3
    ImIn{iList} = xASL_io_Nifti2Im(M0list{iList});
    ImLowResGM{iList} = xASL_io_Nifti2Im(lowResListGM{iList});
    ImLowResWM{iList} = xASL_io_Nifti2Im(lowResListWM{iList});
    ImLowResCSF{iList} = xASL_io_Nifti2Im(lowResListCSF{iList});

    ImHigResGM{iList} = xASL_io_Nifti2Im(higResListGM{iList});
    ImHigResWM{iList} = xASL_io_Nifti2Im(higResListWM{iList});
    ImHigResCSF{iList} = xASL_io_Nifti2Im(higResListCSF{iList});

    maskHigRes{iList} = ImHigResGM{iList}>0.7;
    maskLowRes{iList} = ImLowResGM{iList}>0.6*max(ImLowResGM{iList}(:));
    maskLowRes{iList} = ImLowResGM{iList}>(1.2.*(ImLowResWM{iList}+ImLowResCSF{iList}));

    MaskHig{iList} = maskHigRes{iList} & isfinite(ImIn{iList});
    MaskLow{iList} = maskLowRes{iList} & isfinite(ImIn{iList});
    
    M0_HigRes(iList) = median( ImIn{iList}(MaskHig{iList}) );
    M0_LowhRes(iList) = median( ImIn{iList}(MaskLow{iList}) );
end

M0_HigRes
M0_LowhRes
averageDiff = mean(M0_HigRes(iList) - M0_LowhRes(iList))

figure(1);imshow([ImIn{1}(:,:,53)./100 ImIn{2}(:,:,53)./1000 ImIn{3}(:,:,53).*100],[],'InitialMagnification',200)