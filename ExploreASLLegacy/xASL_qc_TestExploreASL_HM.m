function [ResultsTable] = xASL_qc_TestExploreASL_HM(RunMethod, bTestSPM, bOverwrite, bCompiled) 
%xASL_qc_TestExploreASL_HM Run ExploreASL QC for test datasets
% Note: addpath('../CustomScripts/ExploreASLLegacy/');

if nargin<1 || isempty(RunMethod)
    RunMethod = 1;
end
if nargin<2 || isempty(bTestSPM)
    bTestSPM = 1;
end
if nargin<3 || isempty(bOverwrite)
    bOverwrite = 1;
end
if nargin<4 || isempty(bCompiled)
    bCompiled = 0;
end

if ismac
    TestDirOrig = '/Users/henk/ExploreASL/TestDataSets';
    TestDirDest = '/Users/henk/ExploreASL/ASL/TestCasesProcessed';
    MatlabPath = [];
elseif ispc
    TestDirOrig = 'S:\gifmi\Projects\ExploreASL\ExploreASL_TestCases\ExploreASL_TestCases';
    TestDirDest = 'S:\gifmi\Projects\ExploreASL\ExploreASL_TestCases\ProcessedCases';
    MatlabPath = [];
else
    % linux
     TestDirOrig = '/scratch/hjmutsaerts/TestDataSets';
     TestDirDest = '/scratch/hjmutsaerts/ExploreASL_TestCasesProcessed';
     MatlabPath = 'bash /opt/aumc-apps/matlab/R2021b/bin/matlab';
end

if bCompiled
    RunMethod = 3; % serial compilation testing
    RunTimePath = '/usr/local/MATLAB/MATLAB_Runtime/v96';
    
    % get latest compilation to test
    CurrentDir = pwd;
    CompiledRoot = '/home/henk/CompiledxASL';
    cd(CompiledRoot);
    CompiledList = dir('xASL*');
    
    bGotPath = 0;
    for iDir=length(CompiledList):-1:1
        if CompiledList(iDir).isdir && ~bGotPath
            MatlabPath = fullfile(CompiledRoot, CompiledList(iDir).name);
            cd(MatlabPath);
            FileSh = dir('*.sh');
            MatlabPath = fullfile(MatlabPath, FileSh(end).name);
            bGotPath = 1;
        end
    end
    cd(CurrentDir);
    
    [ResultsTable] = xASL_qc_TestExploreASL(TestDirOrig, TestDirDest, RunMethod, 0, MatlabPath, [], [], bOverwrite, [], RunTimePath, 0);
else
    [ResultsTable] = xASL_qc_TestExploreASL(TestDirOrig, TestDirDest, RunMethod, bTestSPM, MatlabPath, [], [], bOverwrite, [], [], 0);
end


end
