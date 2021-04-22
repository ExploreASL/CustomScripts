function outputStruct = convert2subjectValuePairs(readText)

    for iLine = 1:size(readText,1)
        
        % Find the ': '
        curIndex = strfind(readText{iLine,1},': ');
        % Check if field is not empty
        if ~isempty(readText{iLine,1}(1:curIndex-1))
            field = genvarname(readText{iLine,1}(1:curIndex-1));
        else
            field = [];
        end
        % Get value
        value = readText{iLine,1}(curIndex+2:end);
        % Store in struct
        if ~isempty(field)
            fprintf('%s: %s\n', field, value);
            outputStruct.(field) = value;
        end 
    end
end