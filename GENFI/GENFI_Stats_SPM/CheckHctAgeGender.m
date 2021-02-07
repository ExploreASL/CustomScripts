%% Check relation hematocrit age/gender

%% Admin

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

%% Check relation hematocrit age/gender

% Enter age in years, and for gender: 0=female, 1=male

sex     = 0;
for ageI=1:100
    age(ageI)         = ageI;
    Hct(ageI,1)       = estimate_hct(ageI, sex);
end
sex     = 1;
for ageI=1:100
    age(ageI)         = ageI;
    Hct(ageI,2)       = estimate_hct(ageI, sex);
end

figure(1);plot(age,Hct(:,1),'b',age,Hct(:,2),'r')
xlabel('Age (yrs)');
ylabel('Hct (% L/L)')
title('Blue=female, red=male');
