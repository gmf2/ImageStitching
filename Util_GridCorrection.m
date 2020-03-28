function  Util_GridCorrection(fPathAnalysis,FileName,OPT_WRITE_RESULT)
% Carga el resultado de Util_GridMatching.m

% 1) Util_GridDetection_setX.m
% 2) Util_GridMatching.m
% 3) Util_GridCorrection.m

% clearvars
% close all
% 
% OPTION_MAIN=3;
% switch OPTION_MAIN
%     case 3
%         pathMain = 'F:\Experiments_MalariaSpot\Muestra_v3\';IND_GRID=1;
%     case 5
%         pathMain = 'F:\Experiments_MalariaSpot\Muestra_v5\';IND_GRID=5;
% end
% 
% fPathVignneting = [pathMain, 'Grid_Vignneting\'];
% fPathAnalysis   = [pathMain, 'Grid_analysis\'];
% 
load([fPathAnalysis , FileName],'CoordIdeal','CoordReal', 'IDorig', 'centerXY','scaleX','scaleY', 'areaCrop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imGrid = readimage(imd_f,1);  %% el cálculo de GridDetectin_v2.m se hizo para la imagen 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hfig = cell(3,1);

numMarkers = size(CoordReal,1);
hfig{1}=figure(1);imshow(imGrid,[]); hold on;
scatter(CoordReal(:,1), CoordReal(:,2),'r','.'); 
scatter(CoordIdeal(:,1),CoordIdeal(:,2),'b','.'); 
scatter(CoordReal(IDorig,1),CoordReal(IDorig,2),'r','o'); 
scatter(centerXY(1),centerXY(2),'m','+'); 
for i=1:numMarkers
    plot([CoordReal(i,1),CoordIdeal(i,1)],[CoordReal(i,2),CoordIdeal(i,2)], 'color', 'r');
end

h=msgbox('Continuar', 'modal');
waitfor(h);

[nRowsY, nColsX, NumChannels] = size(imGrid);


%% Coordenadas del punto de referencia
centerX = CoordReal(IDorig,1);
centerY = CoordReal(IDorig,2);

%% Parámetros a optimizar (como máximo según el modelo
% tres parámetros radiales, dos tangenciales, el centro respecto al centro de la imagen, y el ángulo de rotación
%params0 = [0.88, 0.08, 0.006,    0.005, 0,0,0,0]; 
params0 = [0.63, 0.03, -0.00118,-0.010,-0.001,0,0,0];

%% parámetros de la cámara
%centerX   = nColsX/2;
%centerY   = nRowsY/2;
Fdistance  = nColsX;
paramsCamera = [centerX,centerY, nColsX,nRowsY,Fdistance];

MODEL_DISTORTION = 1;
  
fun = @(params)ErrorLensDistortionModel(CoordIdeal(:,1),CoordIdeal(:,2),CoordReal(:,1),CoordReal(:,2),params, paramsCamera, 'model', MODEL_DISTORTION);
        
options = optimoptions(@lsqnonlin, 'MaxIterations', 10000, 'MaxFunctionEvaluations', 10000);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramsOpt = lsqnonlin(fun,params0, [],[],options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%% convert back to image coordinates. These are now distorted.
[Xdistorted,Ydistorted] = lensDistortionModel(CoordIdeal(:,1),CoordIdeal(:,2),paramsOpt, paramsCamera, 'model', MODEL_DISTORTION);

% if MODEL_DISTORTION == 1 % NO DISTORSIONA EL GIRO, PERO CAMBIA LAS COORDENADAS IDEALES
%     paramsRot = paramsOpt; % distorsiona solo el angulo
%     paramsRot(1:7)=0;
%     [CoordIdeal(:,1),CoordIdeal(:,2)] = lensDistortionModel(CoordIdeal(:,1),CoordIdeal(:,2),paramsRot, paramsCamera,'model', MODEL_DISTORTION);
%     paramsOpt(8) = 0;
% end

error = ErrorLensDistortionModel(CoordIdeal(:,1),CoordIdeal(:,2),CoordReal(:,1),CoordReal(:,2),paramsOpt, paramsCamera, 'model', MODEL_DISTORTION);
disp(sqrt(error/numMarkers));

%% meshgrid for pixel locations
[j,i] = meshgrid(1:nColsX, 1:nRowsY);
[u,v] = lensDistortionModel( j,i,paramsOpt,paramsCamera, 'model', MODEL_DISTORTION);
        
        
%% Undistort image:
% a good programmer always preallocates
imFixed = zeros(size(imGrid));
%% This is the undistortion step
for ThisChannel = 1:NumChannels
    imFixed(:,:,ThisChannel) = interp2(double(imGrid(:,:,ThisChannel)), u, v);
end
imFixed = uint8(imFixed);
hfig{2}=figure(2);imshow(imFixed,[]); hold on;
scatter(CoordIdeal(:,1), CoordIdeal(:,2),'r','+');
scatter(CoordIdeal(IDorig,1),CoordIdeal(IDorig,2),'b','o'); 


%% plot distorted ideal points
hfig{3}=figure(3); imshow(imGrid,[]); hold on;
scatter(CoordReal(:,1), CoordReal(:,2),'b','o');
scatter(CoordReal(IDorig,1), CoordReal(IDorig,2),'m','o');
scatter(Xdistorted,Ydistorted, 'r','+'); 

disp(sqrt(error/numMarkers));

% OPT_WRITE_RESULT=false;
if OPT_WRITE_RESULT == true

    strfileName1   = ['DistortionModelAllData_', num2str(MODEL_DISTORTION)];

    imageSize = size(imGrid);
    save([fPathAnalysis, strfileName1, '.mat'], 'u','v', 'paramsOpt', 'paramsCamera', 'MODEL_DISTORTION', ...
        'CoordIdeal','CoordReal', 'IDorig', 'centerXY','scaleX','scaleY', 'areaCrop', 'imageSize'); % save to load and correct in the main script
    
    strfileName2   = ['DistortionModel_', num2str(MODEL_DISTORTION)];

    save([fPathAnalysis, strfileName2, '.mat'], 'paramsOpt', 'paramsCamera', 'MODEL_DISTORTION', ...
        'centerXY', 'areaCrop', 'imageSize'); % save to load and correct in the main script
    
    imwrite(imFixed,[fPathAnalysis, 'GridUndistorted_' strfileName1, '.jpg']); 
    
    for i=1:3
        [imfig,Map]=frame2im(getframe(hfig{i}));
        imwrite(imfig,[fPathAnalysis, 'Figure_', num2str(i), '.jpg'])
    end

end

% sizeImage = size(Fixed(:,:,1));
% imGridIdeal=zeros(sizeImage, 'uint8');
% 
% cols = (-20:20).*scaleX + centerXY(1);
% rows = (-20:20).*scaleY + centerXY(2);
% 
% cols(cols<=0) =[];
% rows(rows<=0) =[];
% cols(cols>sizeImage(2)) =[];
% rows(rows>sizeImage(1)) =[];
% 
% imGridIdeal(:,cols)=255;
% imGridIdeal(rows,:)=255;
% 
% imGridIdeal = imdilate(imGridIdeal, ones(3,3));
% imshow(imGridIdeal,[]);
% 
% imGridIdeal = repmat(imGridIdeal,1,1,3);
% imGridIdeal(:,:,[2,3])=0;
% 
% imwrite(imGridIdeal, [fPathGridImages,'GridIdeal.png']); 





