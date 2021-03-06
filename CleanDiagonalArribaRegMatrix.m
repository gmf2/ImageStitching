function [  arrShiftsDiagArribaCorr ] = CleanDiagonalArribaRegMatrix(arrShiftsDiagArriba, ExpectedShiftY,ExpectedShiftX)

arrShiftsDiagArribaCorr=arrShiftsDiagArriba;
[rowX,colX] =find(arrShiftsDiagArriba(:,:,1) < (ExpectedShiftX/2) & arrShiftsDiagArriba(:,:,1) >= 0);
[rowY,colY] =find(arrShiftsDiagArriba(:,:,2) < (ExpectedShiftY/2) & arrShiftsDiagArriba(:,:,2) >= 0);

disp('[rowY,colY] mayores en X ')
disp([rowY,colY])
disp('[rowX,colX] mayores en Y')
disp([rowX,colX])

for i=1:numel(rowX)
    if colX(i) > 1
        arrShiftsDiagArribaCorr(rowX(i),colX(i),1) = ExpectedShiftX;
%       arrShiftsDiagAbajo(rowX(i),colX(i),2) = 0;
    end
end

for i=1:numel(rowY)
    if colY(i) > 1
        arrShiftsDiagArribaCorr(rowY(i),colY(i),2) = ExpectedShiftY;
%       arrShiftsDiagAbajo(rowX(i),colX(i),2) = 0;
    end
end
% 
% [rowX2,colX2] =find(abs(arrShiftsDiagArriba(:,:,1)) > maxExpectedShiftX);
% [rowY2,colY2] =find(abs(arrShiftsDiagArriba(:,:,2)) > maxExpectedShiftY);
% 
% for i=1:numel(rowX2)
%     if colX2(i) > 1
%         arrShiftsDiagArribaCorr(rowX2(i),colX2(i),1) = ExpectedShiftX;
% %         arrShiftsDiagAbajo(rowY2(i),colY2(i),2) = 0;
%     end
% end
% 
% for i=1:numel(rowY2)
%     if colY2(i) > 1
%         arrShiftsDiagArribaCorr(rowY2(i),colY2(i),2) = ExpectedShiftY;
% %         arrShiftsDiagAbajo(rowX2(i),colX2(i),2) = 0;
%     end
% end


end

