%% Create CBF histogram on pGM

x.MYPATH   = 'c:\ASL_pipeline_HJ';
AdditionalToolboxDir    = 'C:\ASL_pipeline_HJ_toolboxes'; % provide here ROOT directory of other toolboxes used by this pipeline, such as dip_image & SPM12
if ~isdeployed
    addpath(x.MYPATH);

    subfolders_to_add = { 'ANALYZE_module_scripts', 'ASL_module_scripts', fullfile('Development','dicomtools'), fullfile('Development','Filter_Scripts_JanCheck'), 'MASTER_scripts', 'spm_jobs','spmwrapperlib' };
    for ii=1:length(subfolders_to_add)
        addpath(fullfile(x.MYPATH,subfolders_to_add{ii}));
    end
end

addpath(fullfile(AdditionalToolboxDir,'DIP','common','dipimage'));

[x.SPMDIR, x.SPMVERSION] = xASL_adm_CheckSPM('FMRI',fullfile(AdditionalToolboxDir,'spm12') );
addpath( fullfile(AdditionalToolboxDir,'spm12','compat') );

if isempty(which('dip_initialise'))
    fprintf('%s\n','CAVE: Please install dip_image toolbox!!!');
else dip_initialise
end


% Example image:

pGM     = 'C:\Backup\ASL\Sleep2\analysis\dartel\DARTEL_c1T1_101.nii';
CBF     = 'C:\Backup\ASL\Sleep2\analysis\dartel\DARTEL_CBF_101_ASL_1.nii';

pGM     = xASL_nifti(pGM);
CBF     = xASL_nifti(CBF);

pGM     = pGM.dat(:,:,:);
CBF     = CBF.dat(:,:,:);

[X N]   = hist(nonzeros(pGM(MASK)));
figure(1);plot(N,X)

[X N]   = hist(nonzeros(CBF(MASK)));
figure(2);plot(N,X)

% Get numbers within mask
MASK    = logical(pGM);
pGMn    = pGM(MASK);
CBFn    = CBF(MASK);

if  max(size(pGMn)~=size(CBFn))>0
    error('not same size');
end


clear BinN BinSize X Y MASKn

BinN        = 25;
BinSize     = 1/BinN;
X           = [0:BinSize:1];

for iBin=1:BinN
    MASKn       = pGMn>X(iBin) & pGMn<X(iBin+1);
    Y(iBin)     = mean(CBFn(MASKn & isfinite(CBFn)));
end

X   = X(2:end);

figure(3);plot(X,Y)

