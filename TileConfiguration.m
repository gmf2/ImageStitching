function [strText]= TileConfiguration(Method,nrows,ncols,fPath,OverlapX,OverlapY,FileName)
% fPath = uigetdir;
%'F:\Experiments_MalariaSpot\Muestra_v2\Step4_ImagCrop\';
% fPathStich = strcat(fPath,'\Stitching\');
%mkdir(fPathStich)
% 
%  nrows = 15;
%  ncols = 15;
nimages = gather(nrows)*gather(ncols);
ImagMatrix = LUT_Stitch( 'left',gather(nrows),gather(ncols));

%Blend Validos: SURF && MINEIGEN

OPT_MAIN=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot = @(m,n,p) subtightplot (m, n, p, [0.01, 0.01], 0.01, 0.01); % para dibujar multiplots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


arrShiftsHor = zeros(nrows,ncols,2);
arrShiftsVer = zeros(nrows,ncols,2);
arrShiftsDiagArriba = zeros(nrows,ncols,2);
arrShiftsDiagAbajo = zeros(nrows,ncols,2);

arrErrorsHor   = zeros(nrows,ncols);
arrErrorsVer   = zeros(nrows,ncols);


OPT_OPENRESULT=false;

if OPT_OPENRESULT==false
    
    ImagesRGB   = cell(nimages,1);
    ImagesHSV   = cell(nimages,1);
    ImagesReg   = cell(nimages,1);
    ImagesNames = cell(nimages,1);
    disp('Reading images');
    for n=1:nimages
        ImagesNames{n} = ['Imcorr_', num2str(n, '%03.0f') '.jpg'];
        ImagesRGB{n} = imread([fPath, ImagesNames{n}]);
        ImagesHSV{n} = rgb2hsv(ImagesRGB{n});
        ImagesReg{n} = double(rgb2gray(ImagesRGB{n}));
        ImagesRegGrad{n} = imgradient(double(rgb2gray(ImagesRGB{n})),'prewitt');
   
    end
    SizeIm=size(ImagesRGB{1});
    Xsize=SizeIm(2);
    Ysize=SizeIm(1);
    
    ExpectedShiftX = Xsize*(1-OverlapX);
    ExpectedShiftY = Ysize*(1-OverlapY);
    
    % overlaps por filas
    for j=1:nrows
        disp(j);
        for i=1:ncols-1 % la última no se pone
            %if maskComputeHor(j,i) == true
                IDs = [ImagMatrix(j,i),ImagMatrix(j,i+1)];
                %disp([j,i]);
                switch Method
                    case 'Phase'
                     %% registration using ShiftByPhaseCorrelation
                     xGuess=(size(ImagesRegGrad{IDs(1)},2)-size(ImagesRegGrad{IDs(1)},2)*OverlapX);
                     yGuess=(size(ImagesRegGrad{IDs(1)},1)-size(ImagesRegGrad{IDs(1)},1)*OverlapY);
                     [xShift, yShift] = ShiftByPhaseCorrelation(0,ImagesRegGrad{IDs(1)}, ImagesRegGrad{IDs(2)}, xGuess, yGuess); % de micromos
%                      arrShiftsHor(j,i+1,:) = [xShift, yShift]; % shift local del par
                    case 'Dft'
                     [output, ~] = dftregistration(fft2(ImagesRegGrad{IDs(1)}),fft2(ImagesRegGrad{IDs(2)}),2);
                     xShift = output(4);
                     yShift = output(3);
%                      arrShiftsHor(j,i+1,:) = [xShift, yShift]; % shift local del par
                     arrErrorsHor(j,i+1)=output(1);
%                     otherwise
%                         disp('Escribe bien el metodo de registros')
                     otherwise
                        disp('Wrong method input');
                 end
%                     case 'Blend'
%                 try
%                     [Tform,angle] = PointBasedRegistration(ImagesReg{IDs(1)},ImagesReg{IDs(2)},2, false);
% 
%                 catch
%                     x=1;
%                 end
%                 if exist('Tform', 'var')
%                     %disp('Point based registration');
%                     if abs(angle) < (3*pi/180)
%                         xShift = Tform.T(3,1);
%                         yShift = Tform.T(3,2);
%                     else
%                         disp('wrong point-based registration');
%                     end
%                 end               
                arrShiftsHor(j,i+1,:) = [xShift, yShift]; % shift local del par
            %end
        end
    end
    
    %Overlap por columnas
    for j=1:nrows-1
        disp(j);
        for i=1:ncols % la última no se pone
            %if maskComputeVer(j,i) == true
                IDs = [ImagMatrix(j,i),ImagMatrix(j+1,i)];
                %disp([j,i]);
                 switch Method
                    case 'Phase'
                      %% registration using ShiftByPhaseCorrelation   
                      xGuess=(size(ImagesRegGrad{IDs(1)},2)-size(ImagesRegGrad{IDs(1)},2)*OverlapX);
                      yGuess=(size(ImagesRegGrad{IDs(1)},1)-size(ImagesRegGrad{IDs(1)},1)*OverlapY);
                      [xShift, yShift] = ShiftByPhaseCorrelation(0,ImagesRegGrad{IDs(1)}, ImagesRegGrad{IDs(2)}, xGuess, yGuess); % de micromos
                      %arrShiftsVer(j+1,i,:) = [xShift, yShift]; % shift local del par
                    case 'Dft'
                      [output, ~] = dftregistration(fft2(ImagesRegGrad{IDs(1)}),fft2(ImagesRegGrad{IDs(2)}),2);
                      xShift = output(4);
                      yShift = output(3);
                      %arrShiftsVer(j+1,i,:) = [xShift, yShift]; % shift local del par
                      arrErrorsVer(j+1,i)=output(1);
                     %case 'Blend'
                      otherwise
                        disp('Wrong method input');
                 end
%                 try
%                     [Tform,angle] = PointBasedRegistration(ImagesReg{IDs(1)},ImagesReg{IDs(2)},2, false);
%                 catch
%                     x=1;
%                 end
%                 if exist('Tform', 'var')
%                     %disp('Point based registration');
%                     if abs(angle) < (3*pi/180)
%                         xShift = Tform.T(3,1);
%                         yShift = Tform.T(3,2);
%                     else
%                         disp('wrong point-based registration');
%                     end
%                 end               
                arrShiftsVer(j+1,i,:) = [xShift, yShift]; % shift local del par
        end
    end
  
             
   % Busca valores positivos y que no sean cero (que son sospechosos)
 
    save([fPath , 'arrShifts_dftregistration.mat'], 'arrShiftsHor', 'arrShiftsVer', 'arrErrorsHor', 'arrErrorsVer', 'ImagesNames', ...
        'ExpectedShiftX', 'ExpectedShiftY');
    
else
    load([fPath , 'arrShifts_dftregistration.mat'], 'arrShiftsHor', 'arrShiftsVer', 'arrErrorsHor', 'arrErrorsVer', 'ImagesNames', ...
        'ExpectedShiftX', 'ExpectedShiftY');
%   load([fPathStich , 'arrShifts1.mat']);
%   arrShiftsHor =arrShifts1;
%   arrShiftsVer =arrShifts2;
%   clear arrShifts1 arrShifts2;
end

%% change bad results
maxExpectedShiftYhor = 50;
maxExpectedShiftXver =50;

arrShiftsHorCorr = CleanHorizontalRegMatrix(arrShiftsHor,ExpectedShiftX,maxExpectedShiftYhor);
arrShiftsVerCorr = CleanVerticalRegMatrix(arrShiftsVer, ExpectedShiftY,maxExpectedShiftXver);
% arrShiftsDiagArribaCorr = CleanDiagonalArribaRegMatrix(arrShiftsDiagArriba, ExpectedShiftY,ExpectedShiftX);
% arrShiftsDiagAbajoCorr = CleanDiagonalAbajoRegMatrix(arrShiftsDiagAbajo, ExpectedShiftY,ExpectedShiftX);


%     [row,col] =find(arrShiftsHor(:,:,1) < (ExpectedShiftX/2));
%     for i=1:numel(row)
%         if col(i) > 1
%             arrShiftsHor(row(i),col(i),1) = ExpectedShiftX;
%             arrShiftsHor(row(i),col(i),2) = 0;
%         end
%     end
%     [row,col] =find(arrShiftsVer(:,:,2) < (ExpectedShiftY/2));
%     for i=1:numel(row)
%         if row(i) > 1
%             arrShiftsVer(row(i),col(i),1) = 0;
%             arrShiftsVer(row(i),col(i),2) = ExpectedShiftY;
%         end
%     end
%  
% 

disp(round(arrShiftsHorCorr)); % (la primera columna no cuenta)
%Array Ver 1
%Good registration
[ArrayVer1OK]=find(arrShiftsVer(:,:,1)<=maxExpectedShiftXver); 
[ArrayVer1NOK]=find(arrShiftsVer(:,:,1)>maxExpectedShiftXver); 
ArrayVer1=string(arrShiftsVer(:,:,1));
%Create Array
ArrayVer1(ArrayVer1OK)='OK';
ArrayVer1(ArrayVer1NOK)='NOK';
%Array Ver 2
%Good registration
[ArrayVer2OK]=find(arrShiftsVer(:,:,2)>= (ExpectedShiftY/2)); 
[ArrayVer2NOK]=find(arrShiftsVer(:,:,2)< (ExpectedShiftY/2)); 
ArrayVer2=string(arrShiftsVer(:,:,2));
ArrayVer2(ArrayVer2OK)='OK';
ArrayVer2(ArrayVer2NOK)='NOK';
%Conjunto ArrayVer
ArrayVer(:,:,1)=string(ArrayVer1);
ArrayVer(:,:,2)=string(ArrayVer2);
%Array Hor 1
%Good registration
[ArrayHor1OK]=find(arrShiftsHor(:,:,1)>=(ExpectedShiftX/2)); 
[ArrayHor1NOK]=find(arrShiftsHor(:,:,1)<(ExpectedShiftX/2)); 
ArrayHor1=string(arrShiftsHor(:,:,1));
ArrayHor1(ArrayHor1OK)='OK';
ArrayHor1(ArrayHor1NOK)='NOK';
%Array Hor 2
%Good registration
[ArrayHor2OK]=find(arrShiftsHor(:,:,2)<=maxExpectedShiftYhor); 
[ArrayHor2NOK]=find(arrShiftsHor(:,:,2)>maxExpectedShiftYhor); 
ArrayHor2=string(arrShiftsHor(:,:,2));
%Create Array
ArrayHor2(ArrayHor2OK)='OK';
ArrayHor2(ArrayHor2NOK)='NOK';
%Conjunto ArrayHor
ArrayHor(:,:,1)=string(ArrayHor1);
ArrayHor(:,:,2)=string(ArrayHor2);
%Display Registros Malos
disp('Array Horizontal Registro Horizontal')
disp(ArrayHor(:,:,1))
disp('Array Horizontal Registro Vertical')
disp(ArrayHor(:,:,2))
disp('Array Vertical Registro Horizontal')
disp(ArrayVer(:,:,1))
disp('Array Vertical Registro Vertical')
disp(ArrayVer(:,:,2))
%Calculo Registros Malos Verticales
RegistrosMalosVer1=length(find(ArrayVer(:,:,1)=='NOK'));
RegistrosBuenosVer1=length(find(ArrayVer(:,:,1)=='OK'));
RegistrosMalosVer2=length(find(ArrayVer(:,:,2)=='NOK'));
RegistrosBuenosVer2=length(find(ArrayVer(:,:,2)=='OK'));
%Calculo Registros Malos Horizontales
RegistrosMalosHor1=length(find(ArrayHor(:,:,1)=='NOK'));
RegistrosBuenosHor1=length(find(ArrayHor(:,:,1)=='OK'));
RegistrosMalosHor2=length(find(ArrayHor(:,:,2)=='NOK'));
RegistrosBuenosHor2=length(find(ArrayHor(:,:,2)=='OK'));
%Error
disp('Error Horizontal Registro Horizontal')
ErrHor1=(RegistrosMalosHor1/(RegistrosMalosHor1+RegistrosBuenosHor1));
disp(ErrHor1)
disp('Error Horizontal Registro Vertical')
ErrHor2=(RegistrosMalosHor2/(RegistrosMalosHor2+RegistrosBuenosHor2));
disp(ErrHor2)
disp('Error Vertical Registro Horizontal')
ErrVer1=(RegistrosMalosVer1/(RegistrosMalosVer1+RegistrosBuenosVer1));
disp(ErrVer1)
disp('Error Vertical Registro Vertical')
ErrVer2=(RegistrosMalosVer2/(RegistrosMalosVer2+RegistrosBuenosVer2));
disp(ErrVer2)

disp(round(arrShiftsVerCorr)); % (la primera fila no cuenta)
% disp(round(arrShiftsDiagArribaCorr)); % (la primera fila no cuenta)
% disp(round(arrShiftsDiagAbajoCorr)); % (la primera fila no cuenta)

% columnas y filas sobre las que se calcular el stitching

%arrCols = 1:15;
%arrRows = 4:5;

arrCols = 1:ncols;
arrRows = 1:nrows;

%arrCols = 4:5;
%arrRows = 4:6;

arrShiftsH = arrShiftsHorCorr(arrRows,arrCols,:);
 arrShifstH=gpuArray(arrShiftsH);
arrShiftsV = arrShiftsVerCorr(arrRows,arrCols,:);
 arrShiftsV=gpuArray(arrShiftsV);
% arrShiftsDiagArr = arrShiftsDiagArribaCorr(arrRows,arrCols,:);
% arrShiftsDiagAb = arrShiftsDiagAbajoCorr(arrRows,arrCols,:);

[ mX,mY,vX,vY, indM]  = MultiStitchMosaic_Equation(arrShiftsH, arrShiftsV);

%mX*positionsX = vX;  incógnita a resolver por mínimos cuadrados: positionsX
%mY*positionsX = vY;

locationsX = mX\vX;
locationsY = mY\vY;

mLocations  = gpuArray.zeros(numel(arrRows),numel(arrCols),2);
mLocations(:,:,1) =reshape(locationsX(indM), numel(arrRows),numel(arrCols));
mLocations(:,:,2) =reshape(locationsY(indM), numel(arrRows),numel(arrCols));

% Ahora construye el fichero de texto para ejecutar el programa de stitch de imageJ
cellImagesNames = ImagesNames(ImagMatrix(arrRows,arrCols));
strText = getTextTileConfigurationFile(mLocations, cellImagesNames);

% nImages = numel(arrCols).*numel(arrRows);
% strText = cell(nimages+4,1);
% strText{1} = '# Define the number of dimensions we are working on';
% strText{2} = 'dim = 2';
% 
% strText{4} = '# Define the image coordinates';
% 
% nc = 5;
% for i=1:numel(arrRows)
%     for j=1:numel(arrCols)
%         coordIni = mLocations(i,j,:);
%         i_ini = arrRows(i);
%         j_ini = arrCols(j);
%        strImagName = ImagesNames{ImagMatrix(i_ini,j_ini)};
%         strText{nc} = [strImagName, '; ; (', num2str(coordIni(1),'%3.2f'), ', ', num2str(coordIni(2),'%3.2f'), ')';];
%         nc = nc+1;
%     end
% end

writeAsciiTextToFile_v2([fPath, FileName, num2str(arrRows(1)), '.txt'], strText);
     


% una vez calculados todos los sihfts: los combina!!


