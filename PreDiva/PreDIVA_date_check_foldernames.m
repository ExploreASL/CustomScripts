%% Administration

ODIR            = 'Z:\divi\Projects\prediva\DICOM';
DDIR{1}         = 'D:\Backup\ASL_E\Pre_DIVA_repetition\Baseline';
DDIR{2}         = 'D:\Backup\ASL_E\Pre_DIVA_repetition\Retest6mnd';
DDIR{3}         = 'D:\Backup\ASL_E\Pre_DIVA_repetition\FollowUp';

LIST{1}         = {'20120629_241313' '20120627_151015' '20130116_154027' '20120711_191024' '20120711_191023' '20120627_191019' '20120629_151001' '20120704_154004'};
LIST{2}         = {'20130227_241313' '20130130_151015' '20120629_154027' '20130109_191024' '20130109_191023' '20121221_191019' '20121212_151001' '20121212_154004'};
LIST{3}         = {'20150227_241313' '20150325_151015' '20150325_154027' '20150429_191024' '20150429_191023' '20150401_191019' '20150417_151001' '20150320_154004'};

%% CHECK
% Check last 6 digits same
clear DATESLIST SUBJECTLIST
for iL=1:3
    for iD=1:length(LIST{iL})
        DATESLIST(iD,iL)   = str2num(LIST{iL}{iD}(1:8));
        SUBJECTLIST(iD,iL) = str2num(LIST{iL}{iD}(10:end));
    end
end

% Check unique subjects
length(unique(SUBJECTLIST))==size(SUBJECTLIST,1)

for iL=1:2
    for iD=1:length(LIST{iL})
        if  SUBJECTLIST(iD,iL) ~= SUBJECTLIST(iD,iL+1)
            error('');
        end
    end
end

for i2=1:size(DATESLIST,2)
    for i1=1:size(DATESLIST,1)
        year(i1,i2)     = floor(DATESLIST(i1,i2)/10000);
        month(i1,i2)    = floor((DATESLIST(i1,i2)-(year(i1,i2)*10000))/100);
        day(i1,i2)      = floor(DATESLIST(i1,i2)-(year(i1,i2)*10000)-(month(i1,i2)*100));
    end
end
    
DELTADATE(:,1)          = datenum(year(:,2),month(:,2),day(:,2))-datenum(year(:,1),month(:,1),day(:,1));
DELTADATE(:,2)          = datenum(year(:,3),month(:,3),day(:,3))-datenum(year(:,2),month(:,2),day(:,2));

DELTADATEmnths          = DELTADATE./30;
DELTADATEyrs            = DELTADATEmnths./12;
    
mean(DELTADATEyrs(:,1))
mean(DELTADATEyrs(:,2))