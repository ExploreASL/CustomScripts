function x = DATA_PAR( x )
%DATA_PAR Part of ExploreASL, loading basic study settings
% HJMM Mutsaerts 2018

% Define study
x.name               = 'DIPG';
x.subject_regexp     = '^\d{6}_\d$';

x.Segment_SPM12 = true;
x.Quality              = true; % 1 = normal, 0 = low for fast try-out
x.DELETETEMP 			= true;

end
