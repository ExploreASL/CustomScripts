
analysis = 'C:\Backup\ASL\BoleStudien\Bolestudie\'; % path to analysis folder
subjects = dir(analysis);
Cohort = 'C:\Backup\ASL\BoleStudien\Bolestudie\cohort.mat'; % path to list of cohort
load(Cohort);

for i=3:length(subjects) % For each user
    parms_path = fullfile(analysis, subjects(i).name, 'ASL_1\ASL4D_parms.mat');
    if exist(parms_path)
        load(parms_path);

        for ii=1:length(Cohort) %Match user with line in Cohort list
            if strcmp(mat2str(cell2mat(Cohort(ii,1))), subjects(i).name)
                if strcmp(cell2mat(Cohort(ii,2)),'non-using')
                    parms.hematocrit = 0.42;
                    disp('Non-using');
                elseif strcmp(cell2mat(Cohort(ii,2)),'CurrentUser')
                    disp('Current-user');
                    parms.hematocrit = 0.5;
                end   
            end
        end

        save(parms_path, 'parms')
        clear parms;
    else 
        continue;
    end
    
end
