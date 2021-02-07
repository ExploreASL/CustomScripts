%% Create SliceReadoutTime.mat

TEshortest  = {'151005_2' '171042_2' '171110_2' '172017_2' '172062_2' '172067_2' '172069_2' '173032_2' '173049_2' '174002_2' '174024_2' '174055_2' '231069_2' '232001_2' '232004_2' '232042_2' '234017_2'};


for ii=1:length(age)
    SliceReadoutTime{ii*2-1,1}  = age{ii,1};
    SliceReadoutTime{ii*2-0,1}  = age{ii,1};
    
    SliceReadoutTime{ii*2-1,2}  = 'ASL_1';
    SliceReadoutTime{ii*2-0,2}  = 'ASL_2';
    
    if      strcmp(age{ii,1}(end),'1')
            SliceReadoutTime{ii*2-1,3}  = 34.9;
            SliceReadoutTime{ii*2-0,3}  = 34.9;
    elseif  strcmp(age{ii,1}(end),'2')
        
            SliceReadoutTime{ii*2-1,3}  = 37.86667;
            SliceReadoutTime{ii*2-0,3}  = 37.86667;             
        
            for iT=1:length(TEshortest)
                if  strcmp(TEshortest{iT},age{ii,1})
                    SliceReadoutTime{ii*2-1,3}  = 42.6;  
                end
            end
    else    error('Unknown TimePoint');
    end
    
end

save( fullfile(x.D.ROOT,'SliceReadoutTime.mat'),'SliceReadoutTime');