function [ arrShiftsVer ] = CleanVerticalRegMatrix( arrShiftsVer, ExpectedShiftY, maxExpectedShiftXver )

[row,col] =find(arrShiftsVer(:,:,2) < (ExpectedShiftY/2) );
for i=1:numel(row)
    if row(i) > 1
        arrShiftsVer(row(i),col(i),1) = 0;
        arrShiftsVer(row(i),col(i),2) = ExpectedShiftY;
    end
end

[row,col] =find(abs(arrShiftsVer(:,:,1)) > maxExpectedShiftXver);
for i=1:numel(row)
    if row(i) > 1
        arrShiftsVer(row(i),col(i),1) = 0;
        arrShiftsVer(row(i),col(i),2) = ExpectedShiftY;
    end
end
% 
% [row,col] =find(arrShiftsVer(:,:,2) <= (ExpectedShiftY/4) );
% for i=1:numel(row)
%     if row(i) > 1
%         arrShiftsVer(row(i),col(i),1) = 0;
%         arrShiftsVer(row(i),col(i),2) = 0;
%     end
% end



end

