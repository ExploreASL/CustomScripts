clear
%% Delete empty directories
NewDir      = 'C:\Backup\ASL\BioCog\BERLIN_DF1';
SubjList    = xASL_adm_GetFsList(NewDir,'^(BCU|CCC|BIC|BICON|BIM|)\d{3}_(1|2)$',1);

for ii=1:length(SubjList)
    clear DirSearch ASLsearch
    DirSearch       = fullfile(NewDir,SubjList{ii});
    ASLsearch       = fullfile(NewDir,SubjList{ii},'ASL_1');
    if  length(xASL_adm_GetFileList(DirSearch,'^.*\.(nii|mat)$','FPListRec',[0 Inf]))==0
        if  isdir(ASLsearch)
            rmdir(ASLsearch);
        end
        rmdir(DirSearch);
    end
end



%% do dcmvalues thingy
x.MYPATH  = 'c:\ExploreASL';
addpath(fullfile(x.MYPATH,'Development','dicomtools'));


for iS=1:length(SubjList)
    clear parmsFile1 parmsFile2 dcmHeader DcmH H ASLdir
    ASLdir      = fullfile(NewDir,SubjList{iS},'ASL_1');
    xASL_adm_CreateDir(ASLdir);
    
    parmsFile1  = fullfile(ASLdir,'ASL4D_parms.mat');
    parmsFile2  = fullfile(ASLdir,'M0_parms.mat');
    dcmHeader   = fullfile(NewDir,SubjList{iS},'dcmHeaders.mat');
    
    if  exist(dcmHeader,'file') && (~exist(parmsFile1) || ~exist(parmsFile2))
        
        % Check dcmHeader
        DcmH    = load(dcmHeader);
        % Which fields
        H   = fieldnames(DcmH.h);
        for iH=1:length(H)
            %% ASL part
            if  strcmp(H{iH},'ep2d_pcasl_3x3x7') || strcmp(H{iH},'ep2d_pcasl_3x3x7_M0_tra')
                
                clear ASLfields parms
                
                ASLfields   = eval(['DcmH.h.' H{iH}]);
                parms.EchoTime                  = ASLfields.EchoTime;
                parms.RepetitionTime            = ASLfields.RepetitionTime;
                if      isfield(ASLfields,'NumberOfTemporalPositions')
                        parms.NumberOfTemporalPositions = ASLfields.NumberOfTemporalPositions;
                else
                        parms.NumberOfTemporalPositions = NaN;
                end
                
                if      isfield(ASLfields,'RescaleSlope')
                        parms.RescaleSlopeOriginal  = ASLfields.RescaleSlope;
                        parms.RescaleSlope          = ASLfields.RescaleSlope;
                elseif  isfield(ASLfields,'RescaleSlopeOriginal')
                        parms.RescaleSlopeOriginal  = ASLfields.RescaleSlopeOriginal;
                        parms.RescaleSlope          = ASLfields.RescaleSlopeOriginal; 
                else    
                        parms.RescaleSlopeOriginal  = 1;
                        parms.RescaleSlope          = 1;                     
                end
                if      isfield(ASLfields,'MRScaleSlope')
                        parms.MRScaleSlope          = ASLfields.MRScaleSlope;
                else
                        parms.MRScaleSlope          = 1;
                end
                if      isfield(ASLfields,'AcquisitionTime')
                        parms.AcquisitionTime          = ASLfields.AcquisitionTime;
                else
                        parms.AcquisitionTime          = NaN;
                end
                if      isfield(ASLfields,'RescaleIntercept')
                        parms.RescaleIntercept          = ASLfields.RescaleIntercept;
                else
                        parms.RescaleIntercept          = 0;
                end     
                
                if ~strcmp(H{iH},'ep2d_pcasl_3x3x7') && ~strcmp(H{iH},'ep2d_pcasl_3x3x7_M0_tra')
                    error('Wrong name M0 or ASL');
                end
                
                if  strcmp(H{iH},'ep2d_pcasl_3x3x7_M0_tra')
                    save(parmsFile2,'parms');
                elseif strcmp(H{iH},'ep2d_pcasl_3x3x7')
                    save(parmsFile1,'parms');
                end
                
                clear parms
            end
        end
    end
end
                
 




    
