function [ mX,mY,vX,vY, indM] = MultiStitchMosaic_Equation( arrShiftsH, arrShiftsV)

arrShiftsH(:,1,:)=nan; % (la primera columna no cuenta)
arrShiftsV(1,:,:)=nan; % (la primera fila no cuenta)

disp(arrShiftsH(:,:,1)); 
disp(' ');
disp(arrShiftsV(:,:,2));

nCols = size(arrShiftsH,2);
nRows = size(arrShiftsH,1);
nShiftsH = nRows*(nCols-1);
nShiftsV = (nRows-1)*(nCols);

%% hacemos el sistema de ecuaciones:

nElem = nCols*nRows;

indM  = gpuArray(reshape(1:(nRows*nCols), nCols, nRows)'); %array ordenados primero por columnas

lutH   = gpuArray(reshape(indM(:,2:end)', nShiftsH,1)); % a qué posiciones corresponden los vHx y vHy
lutHc  = setdiff(1:nElem, lutH); % conjunto complementario, índices que no forman parte de lutH (primera columna)

% preparamos la matriz para desplazamiento horizontal
matrixH = gpuArray(eye(nElem) + diag(repmat(-1,1,nElem-1),-1)); % matriz de ecuaciones de desplazamiento en x e y (es igual) ,
matrixH(lutHc,:)=0;         % pone a cero
matrixH(1,1) = 1;           % el primer elementos es la referencia [0,0] !!

vHx = gpuArray(reshape(arrShiftsH(:,:,1)', nElem,1)); % ordena por columna primero, y luego por fila
vHy = gpuArray(reshape(arrShiftsH(:,:,2)', nElem,1)); 

vHx(lutHc) =0;  % pone a cero
vHy(lutHc) =0;   

%para los shifts Horizontales: matrixH*Px = vHx  y matrixH*Py = vHy

lutV  = gpuArray(reshape(indM(2:end,:), nShiftsV,1));
lutVc = setdiff(1:nElem, lutV); % conjunto complementario, índices que no forman parte de lutV (primera fila)

% preparamos la matriz para desplazamiento vertical
matrixV = gpuArray(eye(nElem) + diag(repmat(-1,1,nElem-nCols),-nCols));
matrixV(lutVc,:)=0;         % pone a cero

vVx = gpuArray(reshape(arrShiftsV(:,:,1)', nElem,1)); %
vVx(lutVc) = 0;    
vVy = gpuArray(reshape(arrShiftsV(:,:,2)', nElem,1)); % 
vVy(lutVc)  =0;    

% elimina filas de ceros

matrixH(lutHc(2:end),:)=[];   
matrixV(lutVc(2:end),:)=[];   
vHx(lutHc(2:end)) = [];    
vHy(lutHc(2:end)) = [];   
vVx(lutVc(2:end)) = [];   
vVy(lutVc(2:end)) = [];    
% 
% %Eliminamos registros malos
% [rowNanHX]=find(vHx==NaN);
% vHx(rowNanHX)=[];    
% % %Eliminamos registros malos
%  [rowNanHY]=find(vHy==NaN);
%  vHy(rowNanHY)=[];    
% %Eliminamos registros malos
% [rowNanVX]=find(vVx==0);
% vVx(rowNanVX)=[];   
% %Eliminamos registros malos
% [rowNanVY]=find(vVy==0);
% vVy(rowNanVY)=[];   

% componemos las matrices totales

% matriz y vector en X
mX = [matrixH;matrixV];
vX = [vHx; vVx];
% matriz y vector en Y
mY = [matrixH;matrixV];
vY = [vHy; vVy];


mT = blkdiag(mX,mY);
vT = [vX; vY];





end
