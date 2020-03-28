function [  arrShiftsDiagAbajoCorr ] = CleanDiagonalAbajoRegMatrix(arrShiftsDiagAbajo, ExpectedShiftY,ExpectedShiftX)

arrShiftsDiagAbajoCorr=arrShiftsDiagAbajo;
[rowX,colX] =find(arrShiftsDiagAbajo(:,:,1) < (ExpectedShiftX/2) & arrShiftsDiagAbajo(:,:,1)>=0 );
[rowY,colY] =find(arrShiftsDiagAbajo(:,:,2) < (ExpectedShiftY/2) & arrShiftsDiagAbajo(:,:,2) >=0);

for i=1:numel(rowX)
    if colX(i) > 1
        arrShiftsDiagAbajoCorr(rowX(i),colX(i),1) = ExpectedShiftX;
%       arrShiftsDiagAbajo(rowX(i),colX(i),2) = 0;
    end
end

for i=1:numel(rowY)
    if colY(i) > 1
        arrShiftsDiagAbajoCorr(rowY(i),colY(i),2) = ExpectedShiftY;
%       arrShiftsDiagAbajo(rowX(i),colX(i),2) = 0;
    end
end
% 
% [rowX2,colX2] =find(abs(arrShiftsDiagAbajo(:,:,1)) > maxExpectedShiftX);
% [rowY2,colY2] =find(abs(arrShiftsDiagAbajo(:,:,2)) > maxExpectedShiftY);
% 
% for i=1:numel(rowX2)
%     if colX2(i) > 1
%         arrShiftsDiagAbajo(rowX2(i),colX2(i),1) = ExpectedShiftX;
% %         arrShiftsDiagAbajo(rowY2(i),colY2(i),2) = 0;
%     end
% end
% 
% for i=1:numel(rowY2)
%     if colY2(i) > 1
%         arrShiftsDiagAbajo(rowX2(i),colX2(i),2) = ExpectedShiftY;
% %         arrShiftsDiagAbajo(rowX2(i),colX2(i),2) = 0;
%     end
% end


end

