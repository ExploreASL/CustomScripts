function x = DATA_PAR( x )
%DATA_PAR Part of ExploreASL, loading basic study settings
% HJMM Mutsaerts 2018

% Define study
x.name               = 'MiamiGE';
x.subject_regexp     = '^RMCI_HIM_\d{3}$';


% list parameters here
x.M0 				    = 'separate_scan';  % Dennis obtained in PET-MRI study, rescale Ingenia-Intera later
x.Q.BackGrSupprPulses 	= 5;
x.readout_dim          = '3D'; % 2D or 3D
x.Quality              = 1; % 1 = normal, 0 = low for fast try-out

x.Vendor        	 	= 'GE_product';   % MR750 always had product version (WIP on MRX)
x.Q.LabelingType        	= 'CASL'; % Options: 'PASL' (pulsed Q2-TIPS) or 'CASL' (CASL/PCASL)
% NB: pulsed without Q2TIPS cannot be reliably quantified because the bolus width cannot be identified
% CASL & PCASL are both continuous ASL methods, identical quantification
x.Q.Initial_PLD         = 2025; % 
x.Q.LabelingDuration           = 1450; %?
x.Q.SliceReadoutTime  = 0; 
x.Q.NumberOfAverages 	= 3; % checked in protocol & in 1 dicom file
end