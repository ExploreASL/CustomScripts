function [ Cor_M0 ] = ProcessM0(x)
%%Function to process M0 scans in the same way as the Philips scanner
%Author: Koen Baas
%Date: 19-june-2017

% 	1. The data is averaged
% 	2. The data is then corrected for TR
% 	3. The data is then masked to filter out all the points that are below a threshold
% 	4. The data is smoothened with a Gaussian kernel


%% Load data and set parameters
%Load M0-data
cd('C:\Users\310276869\Desktop\M0_test')          % @HJ, deze directory moet telkens naar het juiste Subject en Session
raw_M0 = xASL_io_ReadNifti('M0.nii');
ASL_parms = load('ASL4D_parms.mat');

%Set parameters
if x.Q.BloodT1 == 1650
    T1_tissue = 1100;                          % As implemented in Philips scanner
elseif x.Q.BloodT1 == 1350
    T1_tissue = 920;                           % As implemented in Philips scanner
end

if  strcmp(x.Q.Initial_PLD,'individual')
    qnt_init_PLD    = ASL_parms.qnt_init_PLD;
else
    qnt_init_PLD    = x.Q.Initial_PLD;
end

Voxel_size    = 3.75;                           % @HJ, dit moet automatisch maar ik wist niet waar de voxel-size kan worden achterhaald
Filter_size   = 6.5;                            % 6.5  is Philips default
Lower_cutoff  = 0.20;                           % 0.20 is Philips default
Upper_cutoff  = 0.60;                           % 0.85 is Philips default


%% 1. Average M0_data
Avg_M0 = (raw_M0.dat(:,:,:,1)+raw_M0.dat(:,:,:,2))/2;

%% 2. Correct data for TR
if strcmp(x.readout_dim,'2D')
    for i = 1:size(raw_M0.dat,3)
        Cor_M0(:,:,i) = (Avg_M0(:,:,i))/((1-exp(-(x.Q.LabelingDuration+qnt_init_PLD+x.Q.SliceReadoutTime*(i-1))/T1_tissue)));
    end
else
        Cor_M0(:,:,:) = (Avg_M0(:,:,:))/((1-exp(-(x.Q.LabelingDuration+qnt_init_PLD+x.Q.SliceReadoutTime))/T1_tissue));
end

%% 3. Mask data below threshold
Data_array = reshape(Cor_M0,[size((Cor_M0(:)),1),1]);
Data_array = sort(Data_array);

Data_array(Data_array<Lower_cutoff*max(Data_array))    = [];
Data_array(Data_array>Upper_cutoff*max(Data_array))    = [];


for i = 1:length(Data_array)-1
    Diff_array(i) = Data_array(i+1)-Data_array(i);
end

max_diff = max(Diff_array);
placemax = find(Diff_array == max_diff);

Threshold = (Data_array(placemax)+Data_array(placemax+1))/2;

Cor_M0(Cor_M0<Threshold(1))=0;


%% 4. Smooth M0 with Gaussian kernel
sigma = Filter_size/Voxel_size;

Cor_M0 = imgaussfilt(Cor_M0,sigma);                     %@HJ, waardes van 0 worden nog niet genegeerd door het gaussian filter.

% imagesc(Cor_M0(:,:,7))

%% Save processed M0-scan
xASL_io_SaveNifti('M0.nii','M0_processed.nii',Cor_M0);
