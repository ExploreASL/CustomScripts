%% Load spreadsheet
SpreadsheetID = '1EOW_k3lgJfCqcub_-_vqXbRVeToerw74UzvS-L5YSCA';
CSV = GetGoogleSpreadsheet(SpreadsheetID);

%% Define the part we need for this study
RealRows = cellfun(@(x) ~isempty(x), CSV(:,1));
RealRowsIndex = find(RealRows);
% these are the non-empty rows
FirstRow = 1+find(cellfun(@(x) ~isempty(regexp(lower(x), lower('ABOVE THE AGE OF 30'))), CSV(:,1)));
% this is where the >30 ages begin
LastRow = RealRowsIndex(end)-2;
% assuming the last 2 rows are for counting the total sum
RealRows([3:FirstRow-1 LastRow+1:end]) = 0;
RealRows(1:2) = 1; % keep the Table headers

RealColumns = cellfun(@(x) ~isempty(x), CSV(2,:));
% these are the non-empty columns

%% Recompile the CSV
CSV = CSV(RealRows, RealColumns);

IsControlsColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), 'controls')), CSV(2,:)));
% this is the column containing 1==HC, 0==patients
DataAccessColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*external.*internal.*public')), CSV(2,:)));
% this column is 0==External possibly, 1==internal, 2==public, 3==External AccessGranted, 4==Future study/recruitment ongoing
SampleSizeColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*sample.*size.*')), CSV(2,:)));

MeanAgeColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*mean.*age.*')), CSV(2,:)));
NicknameColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*study.*nickname.*')), CSV(2,:)));
LocationColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*location.*')), CSV(2,:)));
SdevAgeColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*sd.*age.*')), CSV(2,:)));
SexColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*sex.*')), CSV(2,:)));
VendorColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*vendor.*')), CSV(2,:)));
AcquisitionDimColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*acquisition.*dim.*')), CSV(2,:)));
LabelingTypeColumn = find(cellfun(@(x) ~isempty(regexp(lower(x), '.*labeling.*type.*')), CSV(2,:)));

% Let's select data that we have already have access to: either internal,
% public, or external access granted
RealRows1 = cellfun(@(x) ~isempty(x), CSV(:,DataAccessColumn));
RealRows2 = cellfun(@(x) ~isempty(x), CSV(:,IsControlsColumn));
RealRows3 = cellfun(@(x) ~isempty(x), CSV(:,SampleSizeColumn));
RealRows4 = cellfun(@(x) ~isempty(x), CSV(:,MeanAgeColumn));

CSV = CSV(RealRows1 & RealRows2 & RealRows3 & RealRows4, :);
clear RealRows RealRows1 RealRows2 RealRows3 RealRows4 RealColumns

%% Get the descriptive statistics

AccessCategoriesN = [0 1 2 3 4]; % define data access categories
AccessCategoriesStr = {'ExternalMaybe' 'Internal' 'Public open' 'ExternalAccessGranted' 'Future datasets/still recruiting'};

ControlRows = [0 cellfun(@(x) (xASL_str2num(x)==1), CSV(2:end,IsControlsColumn))'];

AllAccessRows = [0 cellfun(@(x) (xASL_str2num(x)>0 & xASL_str2num(x)<4), CSV(2:end,DataAccessColumn))'];
AllAccessRows = AllAccessRows & ControlRows;
SumStudies = sum(AllAccessRows);
SumSubjects = xASL_stat_SumNan( cellfun(@(x) (xASL_str2num(x)), CSV(AllAccessRows, SampleSizeColumn)));

fprintf('%s\n', ['We listed a total of ' xASL_num2str(sum(AllAccessRows)) ' studies with ' xASL_num2str(SumSubjects) ' controls']);

for iAccess=1:length(AccessCategoriesN)
    AccessRows{iAccess} = [0 cellfun(@(x) (xASL_str2num(x)==AccessCategoriesN(iAccess)), CSV(2:end,DataAccessColumn))'];
    % mask for the data access rows
    AccessRows{iAccess} = AccessRows{iAccess} & ControlRows;
    % mask for controls only
    SumStudies = sum(AccessRows{iAccess});
    SumSubjects = xASL_stat_SumNan( cellfun(@(x) (xASL_str2num(x)), CSV(AccessRows{iAccess}, SampleSizeColumn)));
    fprintf('%s\n', ['We listed ' xASL_num2str(SumStudies) ' ' AccessCategoriesStr{iAccess} ' studies with ' xASL_num2str(SumSubjects) ' controls']);
end

% Study Nickname	Location	Study Index	Population Age( mean +/- SD)	Gender (Male/Female ratio) 	Sample Size	Vendor/ASL implementation	Data Access 

%% Create Table for Iris
Columns = [NicknameColumn LocationColumn SampleSizeColumn MeanAgeColumn SdevAgeColumn SexColumn VendorColumn AcquisitionDimColumn LabelingTypeColumn];
NewTable = CSV(:, Columns);
NewTable{1,10} = 'DataAccess';
for iN=2:size(NewTable,1)
    switch CSV{iN, DataAccessColumn}
        case '0'
            NewTable{iN,10} = 'ExternalPossibly';
        case '1'
            NewTable{iN,10} = 'Internal';
        case '2'
            NewTable{iN,10} = 'Public';
        case '3'
            NewTable{iN,10} = 'ExternalAccessGranted';
        case '4'
            NewTable{iN,10} = 'StillRecruiting';
        otherwise
            NewTable{iN,10} = '?';
    end
end
            
% select healthy controls only:
% without information about follow-up scans
NewTable = NewTable(logical([1 ControlRows(2:end)]),:);
    
%% Now create scatter plot from NewTable
% First remove those without DataAccess
UseRow(1) = true;
for iN=2:size(NewTable,1)
    if isempty(regexp(NewTable{iN,10}, '(ExternalPossibly|StillRecruiting|?)'))
        UseRow(iN)=true;
    else
        UseRow(iN)=false;
    end
end

NewTable = NewTable(UseRow,:);

% Now create pseudo-data
for iN=2:size(NewTable,1)
    AgeMean = xASL_str2num(NewTable{iN,4});
    AgeSD = xASL_str2num(NewTable{iN,5});
    SampleSize = round(xASL_str2num(NewTable{iN,3}));
    FemalePercentage = 1-xASL_str2num(NewTable{iN,6});
    PseudoDataAge{iN-1} = AgeMean + AgeSD* randn(SampleSize,1);
    PseudoDataSex{iN-1} = RandomizeSex(SampleSize,FemalePercentage);
end    

% Now simulate CBF
for iS=1:length(PseudoDataAge)
    CBF{iS} = 60-((PseudoDataAge{iS}-40).*0.0075.*60); % age ~ CBF
    CBF{iS} = CBF{iS} + PseudoDataSex{iS}'.*CBF{iS}.*0.13; % add 13% perfusion for females
    CBF{iS} = CBF{iS} + randn(size(CBF{iS})) .* 0.15 .* CBF{iS}; % add noise. randn on average adds 0, with SD = 1, which we multiply with 15% of bsCV CBF
end

% Plot it
close all;
figure(1);
for iS=1:length(CBF)
    % Select males
    MaleCBF = CBF{iS}(PseudoDataSex{iS}'==0);
    MaleAge = PseudoDataAge{iS}(PseudoDataSex{iS}'==0);
    FemaleCBF = CBF{iS}(PseudoDataSex{iS}'==1);
    FemaleAge = PseudoDataAge{iS}(PseudoDataSex{iS}'==1);
    
    if ~isempty(MaleCBF)
        plot(MaleAge, MaleCBF,'ro');
    end
    if ~isempty(FemaleCBF)
        plot(FemaleAge, FemaleCBF,'bo');
    end
    hold on;
end

axis([30 100 10 100])
set(findall(gcf,'-property','FontSize'),'FontSize',18);
xlabel('Age (years)','fontsize',24);
ylabel('CBF (mL/100g/min)','fontsize',24);
title('Overview ASL subjects (Red = male, blue = female)','fontsize',24);
set(gca,'box','off')

% This is using the average & SD age & sex, simulating everything else.
% Noise (15% CBF), difference male & female (13% CBF) & regression across age 
% (4.5 mL/10 years) are based on literature (but have to find the refs? cannot find them from top of my head)