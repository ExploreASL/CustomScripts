%% Initialization (only run once)

% Remove google_tokens.mat (if exists)
% Initialize this by RunOnce.m (check README.pdf)

%% Load spreadsheet
% Now define the Google Sheet
SpreadsheetID = '1EOW_k3lgJfCqcub_-_vqXbRVeToerw74UzvS-L5YSCA';
% SheetID = 
% PositionIndices = 
% DataD = 

% status = mat2sheets(SpreadsheetID, SheetID, PositionIndices, DataD); %
% to move data from Matlab 2 GoogleSheets

CSV = GetGoogleSpreadsheet(SpreadsheetID);