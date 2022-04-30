TableOld = ResultsOld.ResultsTable;
TableNew = ResultsNew.ResultsTable;

clear TableOldNum TableNewNum
TableOldNum = xASL_str2num(TableOld(2:end,2:5));
TableOldNum(:,5:10) = cellfun(@single, TableOld(2:end,6:end));

TableNewNum = xASL_str2num(TableNew(2:end,2:5));
TableNewNum(:,5:10) = cellfun(@single, TableNew(2:end,6:end));

TableDiff = ((TableNewNum - TableOldNum) ./ TableOldNum).*100

TableComparison = TableNew;
for iX=1:size(TableDiff, 1)
    for iY=1:size(TableDiff, 2)
        TableComparison{iX+1,iY+1} = TableDiff(iX,iY);
    end
end

TableComparison