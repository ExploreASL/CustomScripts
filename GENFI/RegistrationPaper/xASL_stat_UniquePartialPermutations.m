function [ NoDoubles ] = xASL_stat_UniquePartialPermutations( INPUTVECTOR )
%UniquePartialPermutations Create partial permutations
% & remove the doubles


    % Create all partial permutations
    % A=[1:1:12]
    r=2;

     c = nchoosek(INPUTVECTOR,r)';
     ncr = size(c,2);
     p = perms([1:r]);
     pr = size(p,1);
     p = reshape(p',1,[]);
     a = zeros(ncr*pr,r);
     for k = 1:ncr
       a((k-1)*pr+1:k*pr,:) = reshape(c(p,k),r,[])';
     end

    % Select the first one
    NoDoubles     = a(1,:);

    for iD=2:size(a,1)
        FOUND   = 0;
        for iF=1:size(NoDoubles,1)
            if  min(fliplr(a(iD,:))==NoDoubles(iF,:))
                FOUND   = 1;
            end
        end
        if ~FOUND % Add to NoDoubles
            NoDoubles(end+1,:)  = a(iD,:);
        end
    end

    NoDoubles   = fliplr(NoDoubles);
    
end

