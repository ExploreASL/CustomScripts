function xASL_init_Memcheck( MBs_required )
%memcheck_ASL When this function is inserted in an iteration, e.g. a forloop,
% it will halt the current process when only 1 Gb free physical memory
% is left. This prevents disk swapping or crashes related to memory issues.

    if nargin<1
        MBs_required = 1024;
    end

    if ispc
        [~, sys]        = memory;
        memfree_mb      = round((sys.PhysicalMemory.Available/1024^2)/100)*100;

    elseif isunix
        [~,sys] = unix('free | grep Mem');
        stats = str2double(regexp(sys, '[0-9]*', 'match'));
    %   memsize = stats(1)/1e3;
        memfree_mb = (stats(3)+stats(end))/1e3;
    else
        memfree_mb = MBs_required; % ignore
    end

    if  memfree_mb < MBs_required
        fprintf('Physical memory left: ');
        fprintf('%d', memfree_mb);
        error('Maximum memory limit reached');
    end

end

