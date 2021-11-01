% size, mean, SD
studyInfo = ...
[100, 81, 5;
 100, 38, 10;
 100, 73, 6;
 100, 78, 3;
 100, 69, 9;
 100, 71, 8;
 100, 68, 9;
 100, 60, 15;
 100, 62, 2;
 100, 57, 7;
 100, 65, 7;
 100, 72, 7;
 100, 71, 7;
 100, 68, 9;
 100, 68, 7;
 100, 71, 7;
 100, 74, 7;
 100, 60, 16;
 100, 48, 17;
 100, 65, 7;
 100, 75, 10;
 100, 68, 9;
 100, 70, 7];



ageVec = 0:10:120; % Calculate CDF for these ages

useStatsToolbox = 1;

% Initialize the table
ageDistribution = zeros(size(studyInfo,1),length(ageVec)-1);

for iStudy = 1:length(studyInfo)
	% Calculates the cumulative distribution function
	if useStatsToolbox 
		ageCdf = normcdf(ageVec, studyInfo(iStudy,2), studyInfo(iStudy,3));
	else
		ageCdf = 1/2*(1+erf(((ageVec-studyInfo(iStudy,2))/studyInfo(iStudy,3))/sqrt(2)));
	end
	
	% Subtract to calculate the distribution per age bracket instead of a cumulative distribution
	% and also multiply by study sample size
	ageDistribution(iStudy, :) = round(studyInfo(iStudy,1) * (ageCdf(2:end) - ageCdf(1:(end-1))));
	
end