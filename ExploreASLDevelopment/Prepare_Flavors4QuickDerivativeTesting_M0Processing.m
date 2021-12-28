FlavorRoot = '/home/hjmutsaerts/scratch/FlavorDatabase';

%% 0. Running xASL_qc_TestExploreASL to process all datasets

%% 1. Renaming derivativesReference to derivatives
Dlist = xASL_adm_GetFileList(FlavorRoot, '^derivativesReference$', 'FPListRec', [], 1);
for iList=1:length(Dlist)
    oldName = Dlist{iList};
    newName = fullfile(fileparts(Dlist{iList}), 'derivatives');
    xASL_Move(oldName, newName, 1);
end

%% 2. Process all flavors in parallel
MatlabPath = '/opt/amc/matlab/R2016a/bin/matlab';
PathxASL = '/scratch/hjmutsaerts/ExploreASL';

Dlist = xASL_adm_GetFileList(FlavorRoot, '^derivatives$', 'FPListRec', [], 1);

for iList=1:10 % length(Dlist)
    DatasetRoot = fileparts(Dlist{iList});
    ScreenName = ['TestxASL_' num2str(iList)];
    ScreenString = ['screen -dmS ' ScreenName ' nice -n 0 ' MatlabPath ' -nodesktop -nosplash -r '];
    RunExploreASLString = ['"cd(''' PathxASL ''');ExploreASL(''' DatasetRoot ''',0,[1 1 0],0);system([''screen -SX ' ScreenName ' kill'']);"'];
    system([ScreenString RunExploreASLString ' &']);
end

pause(300);

for iList=11:20 % length(Dlist)
    DatasetRoot = fileparts(Dlist{iList});
    ScreenName = ['TestxASL_' num2str(iList)];
    ScreenString = ['screen -dmS ' ScreenName ' nice -n 0 ' MatlabPath ' -nodesktop -nosplash -r '];
    RunExploreASLString = ['"cd(''' PathxASL ''');ExploreASL(''' DatasetRoot ''',0,[1 1 0],0);system([''screen -SX ' ScreenName ' kill'']);"'];
    system([ScreenString RunExploreASLString ' &']);
end

pause(300);

for iList=21:30 % length(Dlist)
    DatasetRoot = fileparts(Dlist{iList});
    ScreenName = ['TestxASL_' num2str(iList)];
    ScreenString = ['screen -dmS ' ScreenName ' nice -n 0 ' MatlabPath ' -nodesktop -nosplash -r '];
    RunExploreASLString = ['"cd(''' PathxASL ''');ExploreASL(''' DatasetRoot ''',0,[1 1 0],0);system([''screen -SX ' ScreenName ' kill'']);"'];
    system([ScreenString RunExploreASLString ' &']);
end

pause(300);

for iList=31:40 % length(Dlist)
    DatasetRoot = fileparts(Dlist{iList});
    ScreenName = ['TestxASL_' num2str(iList)];
    ScreenString = ['screen -dmS ' ScreenName ' nice -n 0 ' MatlabPath ' -nodesktop -nosplash -r '];
    RunExploreASLString = ['"cd(''' PathxASL ''');ExploreASL(''' DatasetRoot ''',0,[1 1 0],0);system([''screen -SX ' ScreenName ' kill'']);"'];
    system([ScreenString RunExploreASLString ' &']);
end

pause(300);

for iList=41:50 % length(Dlist)
    DatasetRoot = fileparts(Dlist{iList});
    ScreenName = ['TestxASL_' num2str(iList)];
    ScreenString = ['screen -dmS ' ScreenName ' nice -n 0 ' MatlabPath ' -nodesktop -nosplash -r '];
    RunExploreASLString = ['"cd(''' PathxASL ''');ExploreASL(''' DatasetRoot ''',0,[1 1 0],0);system([''screen -SX ' ScreenName ' kill'']);"'];
    system([ScreenString RunExploreASLString ' &']);
end

pause(300);

for iList=51:62 % length(Dlist)
    DatasetRoot = fileparts(Dlist{iList});
    ScreenName = ['TestxASL_' num2str(iList)];
    ScreenString = ['screen -dmS ' ScreenName ' nice -n 0 ' MatlabPath ' -nodesktop -nosplash -r '];
    RunExploreASLString = ['"cd(''' PathxASL ''');ExploreASL(''' DatasetRoot ''',0,[1 1 0],0);system([''screen -SX ' ScreenName ' kill'']);"'];
    system([ScreenString RunExploreASLString ' &']);
end


%% Analysis

FlavorRoot = '/home/hjmutsaerts/scratch/FlavorDatabase';
FlavorRoot = '/home/hjmutsaerts/scratch/ExploreASL_TestCasesProcessed';
M0list = xASL_adm_GetFileList(FlavorRoot, '^noSmooth_M0.*$', 'FPListRec');
Quality = 1;
Threshold = 0.70;
DirOutput = fullfile(FlavorRoot, ['Threshold_' num2str(round(Threshold*100))]);

path_BrainCentralityMap = '/scratch/hjmutsaerts/ExploreASL/External/SPMmodified/MapsAdded/brainCentralityMap.nii';

for iM0=1:numel(M0list)
    ImIn = M0list{iM0};
    [Fpath, Ffile] = xASL_fileparts(ImIn);
    Ffile = Ffile(13:end-6);
    [IndexStart, IndexEnd] = regexp(Fpath, '(derivatives/ExploreASL|Population)');
    NameOutput = Fpath(1:IndexStart-2);
    [~, NameOutput, ExtOutput] = fileparts(NameOutput);
    NameOutput = [NameOutput ExtOutput];
    
    pvGM = fullfile(Fpath, ['rc1T1_' Ffile '.nii']);
    pvWM = fullfile(Fpath, ['rc2T1_' Ffile '.nii']);
    
    if xASL_exist(pvGM, 'file') && xASL_exist(pvWM, 'file')
        xASL_im_M0ErodeSmoothExtrapolate(ImIn, DirOutput, NameOutput, pvGM, pvWM, path_BrainCentralityMap, Threshold);
    end
end