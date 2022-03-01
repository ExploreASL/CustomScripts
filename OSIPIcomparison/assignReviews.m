%% Initialize
numPipelines = 9;
numReviews = 2;
reviewersConflicts = zeros(numPipelines, numPipelines);
%% Record the conflicts
reviewersConflicts(1,[6,7,8]) = 1;
reviewersConflicts(2,9) = 1; % Reviewer #1 can't review pipelines #2 and #9
reviewersConflicts([3 4],3) = 1;
reviewersConflicts(6,2) = 1;
reviewersConflicts(7,[6 8]) = 1;
reviewersConflicts(8,[1 2 4 5 7 8 9]) = 1;
reviewersConflicts(9,7) = 1;
%% Create the random permutation

cont = 1;
while cont
	revPerm = zeros(numReviews, numPipelines);
	for iReview = 1:numReviews
		revPerm(iReview,:) = randperm(numPipelines);% Permute the pipeline numbers
	end
	
	% First check if no reviewers were assigned one pipeline twice
	if sum(revPerm(1,:) == revPerm(2,:)) == 0
		% Now create a matrix for assigning reviewers
		revMat = zeros(size(reviewersConflicts));
		
		for iReview = 1:numReviews
			for iReviewer = 1:numPipelines
				revMat(iReviewer,revPerm(iReview,iReviewer)) = 1;
			end
		end
		
		% Compare for possible existence of conflicting assignments
		if sum(sum(revMat.*reviewersConflicts)) == 0
			% All is good, we've assigned the reviewers correctly
			cont = 0;
		end
	end
end

%% Display the choice
revMat