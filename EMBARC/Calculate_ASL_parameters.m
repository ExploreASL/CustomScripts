% Calculate EMBARC ASL parameters


%% SliceTiming


% UT
minTR = 4193;
PLD = 1525;
labdur = 1650;
nSlices = 29;

SliceReadoutTime = (minTR - PLD - labdur) / (nSlices-1);

SliceTiming = 0;
SliceTiming(2:nSlices) = [1:nSlices-1].*SliceReadoutTime;
SliceTiming = round(SliceTiming./1000, 5);


%% Obtain ASLContext
% Through control-label order, as there are no M0 volumes, only MG has 2
% dummy volumes (unknown for the other sequences)

% UM (Philips)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_UM/temp/UM0090_1/ASL_1/ASL4D.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end

% UT (Philips)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_TX/temp/TX0071_1/ASL_1/ASL4D.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end

% MG (Siemens)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_MG/temp/MG0039_1/ASL_1/ASL4D.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end

% CU (GE)
PathUM = '/scratch/hjmutsaerts/EMBARC/Example_CU/sourcedata/CU0027/ses-1/ASL/CU0027CUMR1R1/E7403_P20480_1.nii';
ImageUM = xASL_io_Nifti2Im(PathUM);
% Remove any involvement dummy images
ImageUM = ImageUM(:,:,:,5:end-4);

[ControlIm, LabelIm, OrderContLabl] = xASL_quant_GetControlLabelOrder(xASL_io_Nifti2Im(PathUM));

if OrderContLabl
    ASLcontext = {'label', 'control'};
else
    ASLcontext = {'control', 'label'};
end



%% Convert GE CU to BIDS:
% 1. Prefix subject folder to sub-
% 2. Create ses-1 & ses-2
% 3. Create perf
% 4. Rename perf nii -> sub- ses- asl.nii
% 5. Copy *asl.json & *aslcontext.tsv
% 6. Run ExploreASL import for T1w


%% Remove dummy scans MG, first 2 volumes (Siemens)

%% Add SliceReadoutTime to UM *asl.json
"SliceReadoutTime":"ShortestTR",


% GE SliceTiming
SliceTiming = 0;
SliceTiming(2:29) = 53.884.*[1:1:28];
SliceTiming = round(SliceTiming./1000,5);