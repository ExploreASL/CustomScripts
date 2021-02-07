function xASL_stat_SpaghettiPlot( x )
%xASL_stat_SpaghettiPlot Plot spaghetti plot
% HJMM Mutsaerts, ExploreASL 2016

    %% Administration
    x.S.OUTPUTDIR                         =  fullfile(x.SpaghettiDir, x.S.output_ID);
    x.S.OUTPUTDIR_INDIVIDUAL              =  fullfile(x.S.OUTPUTDIR, 'Individual');
    x.S.OUTPUTDIR_2_SAMPLE{1}             =  fullfile(x.S.OUTPUTDIR, '2_sample_individual');
    x.S.OUTPUTDIR_2_SAMPLE{2}             =  fullfile(x.S.OUTPUTDIR, '2_sample_mean');

    xASL_adm_CreateDir(x.S.OUTPUTDIR);
    xASL_adm_CreateDir(x.S.OUTPUTDIR_INDIVIDUAL);
    xASL_adm_CreateDir(x.S.OUTPUTDIR_2_SAMPLE{1});
    xASL_adm_CreateDir(x.S.OUTPUTDIR_2_SAMPLE{2});

    % input datasets = timepoints on x-axis (show as much as there are, fuse them)

    % 1) show single line for each row independent, different color for each input dataset
    % 2) show mean line for each input dataset independent, different colors

    plotColorOptions        = {'k'      'g'     'y'         'r'     'c'     'm'         'b'};
    plotColorNames          = {'black'  'green' 'yellow'    'red'   'cyan'  'magenta'   'blue'};

    %% 0) Restructure 2 sample datasets (e.g. cohorts) into subjects, 1 sample set (e.g. sessions), ROIs

    % iSet2 = 2 sample dataset (e.g. cohorts)
    % iSet1 = 1 sample dataset (e.g. sessions)
    % iMeas = individual measurements (e.g. ROI)
    % iSubject  = subjects

    for iSet2               = 1:length( x.S.DATASETS_RESTR)
        for iSet1           = 1:length( x.S.DATASETS_RESTR{iSet2} )
            for iMeas       = 1:size( x.S.DATASETS_RESTR{iSet2}{iSet1},2)
                for iSubject= 1:size( x.S.DATASETS_RESTR{iSet2}{iSet1},1)
                    spaghetti_data{iSet2}( iSubject, iSet1, iMeas)  = x.S.DATASETS_RESTR{iSet2}{iSet1}(iSubject,iMeas);
                end
            end
        end
    end

    %% 1) Plot all individual lines within individual 2 sample datasets (color = individual)
    for iSet2               = 1:length( spaghetti_data )
        nSubjects           = size( spaghetti_data{iSet2},1);
        nSessions           = size( spaghetti_data{iSet2},2);
        printTitle2         = ['Spaghetti plot ' x.S.NAME_SAMPLE_2 ' ' x.S.OPTIONS_SAMPLE_2{iSet2} ', n=' num2str(nSubjects)];

        for iMeas           = 1:size( spaghetti_data{iSet2},3)
            printTitle     = [printTitle2 ', ' x.S.Measurements{iMeas} ' ' x.S.output_ID];

            fig = figure('Visible','off');
            hold all; % hold all automatically chooses new colors each time plot is called

            for iSubject    = 1:nSubjects % plot all subjects with different colors
                plot(1:nSessions, spaghetti_data{iSet2}(iSubject,:,iMeas) );
            end
 
            h   = title( printTitle, 'interpreter','none'  );

            print_xlabel        = x.S.NAME_SAMPLE_1;
            for iLabel          = 1:nSessions
                print_xlabel    = [print_xlabel ' ' x.S.OPTIONS_SAMPLE_1{iLabel} ' (' num2str(iLabel) ')'];
            end

            xlabel( print_xlabel );
            ylabel([x.S.output_ID ' (' x.S.unit ')']);
            set(gca,'XTick', 1:1:nSessions);

            SaveFile           = fullfile(x.S.OUTPUTDIR_INDIVIDUAL,[printTitle '.jpg']);
            saveas(fig,SaveFile,'jpg');
            SaveFile           = fullfile(x.S.OUTPUTDIR_INDIVIDUAL,[printTitle '.eps']);
            saveas(fig,SaveFile,'epsc');            
            
            clear SaveFile print_xlabel printTitle
            close all
        end
        clear nSubjects nSessions printTitle2
    end



    %% 2) Plot all individual lines for 2 sample datasets & mean lines (color = 2 sample datasets) 

    for iMeas                   = 1:size( spaghetti_data{1},3) % 1 figure per measurement (e.g. ROI)
    
        printTitle             = [x.S.Measurements{iMeas} ' ' x.S.output_ID ' ' x.S.NAME_SAMPLE_2];
        nSessions               = size( spaghetti_data{1},2);

        for iSet2               = 1:length( spaghetti_data )
            nSubjects           = size( spaghetti_data{iSet2},1);
            printTitle         = [printTitle ' ' x.S.OPTIONS_SAMPLE_2{iSet2} ' (' plotColorNames{iSet2} ', n=' num2str(nSubjects) ')'];
            if iSet2~=length( spaghetti_data )
                printTitle     = [printTitle ' vs. '];
            end
        end

        % individual lines
        figInd = figure('Visible','off');
        hold on;
        for iSet2               = 1:length( spaghetti_data )
            nSubjects           = size( spaghetti_data{iSet2},1);
            for iSubject    = 1:nSubjects % plot all subjects with colors of current iSet2
                plot(1:nSessions, spaghetti_data{iSet2}(iSubject,:,iMeas), plotColorOptions{iSet2} );
            end
        end

        % mean lines
        figMean = figure('Visible','off'); 
        hold on;
        for iSet2               = 1:length( spaghetti_data )
            % Get mean
            meanSubject         = xASL_stat_MeanNan( spaghetti_data{iSet2}(:,:,iMeas),1);
            SDSubject           = xASL_stat_StdNan(  spaghetti_data{iSet2}(:,:,iMeas),1,1);
            
            % plot mean & SD
            plot(1:nSessions, meanSubject,              plotColorOptions{iSet2} );
            plot(1:nSessions, meanSubject + SDSubject, [plotColorOptions{iSet2} '--'] );
            plot(1:nSessions, meanSubject - SDSubject, [plotColorOptions{iSet2} '--'] );            
            clear meanSubject SDSubject
        end

        figNames    = {'figInd' 'figMean'};

        for iFig=1:2
            figure( eval(figNames{iFig}) );
            h   = title( printTitle,'interpreter','none'  );

            print_xlabel        = x.S.NAME_SAMPLE_1;
            for iLabel          = 1:nSessions
                print_xlabel    = [print_xlabel ' ' x.S.OPTIONS_SAMPLE_1{iLabel} ' (' num2str(iLabel) ')'];
            end

            xlabel( print_xlabel );
            ylabel([x.S.output_ID ' (' x.S.unit ')']);
            set(gca,'XTick', 1:1:nSessions);

            SaveFile           = fullfile(x.S.OUTPUTDIR_2_SAMPLE{iFig},[printTitle '.jpg']);
            saveas( eval(figNames{iFig}) ,SaveFile,'jpg');
            SaveFile           = fullfile(x.S.OUTPUTDIR_2_SAMPLE{iFig},[printTitle '.eps']);
            saveas( eval(figNames{iFig}) ,SaveFile,'epsc');            
        end

        clear SaveFile print_xlabel printTitle fig
        close all
    end

end
 
