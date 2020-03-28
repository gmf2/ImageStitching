function [  arrShiftsHor ] = CleanHorizontalRegMatrix(arrShiftsHor, ExpectedShiftX, maxExpectedShiftY)


[row,col] =find(arrShiftsHor(:,:,1) < (ExpectedShiftX/2) );
for i=1:numel(row)
    if col(i) > 1
        arrShiftsHor(row(i),col(i),1) = ExpectedShiftX;
        arrShiftsHor(row(i),col(i),2) = 0;
    end
end

[row,col] =find(abs(arrShiftsHor(:,:,2)) > maxExpectedShiftY);
for i=1:numel(row)
    if col(i) > 1
        arrShiftsHor(row(i),col(i),1) = ExpectedShiftX;
        arrShiftsHor(row(i),col(i),2) = 0;
    end
end
% 
% [rowX2,colX2] =find(arrShiftsHor(:,:,1) <= (ExpectedShiftX/4));
% for i=1:numel(rowX2)
%     if colX2(i) > 1
%         arrShiftsHor(rowX2(i),colX2(i),1) = 0;
%         arrShiftsHor(rowX2(i),colX2(i),2) = 0;
%     end
% end
end

