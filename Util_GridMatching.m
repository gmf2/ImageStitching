function [CoordsGridMatching] = Util_GridMatching(Coords,fPathAnalysis,FileName,OPT_ADJUST_CENTER)
% 1) Util_GridDetection
% 2) Util_GridMatching
% 3) Util_GridCorrection

%% ¡Detecta el grid pero sin conocer previamente el número de filas y columnas!
%  Determina el número de filas y columnas para asociar automáticamente a unas coordenadas ideales.

% Partimos de las coordenadas reales, y fijamos la ideales asociadas (que es grid ideal detectado)

% clearvars
%close all

% OPTION_MAIN=3;
% switch OPTION_MAIN
%     case 2
%         fPathAnalysis = 'F:\Experiments_MalariaSpot\Muestra_v2\StepAux_Undistortion\';
%          OPT_ADJUST_CENTER=true;
%     case 3
%         fPathAnalysis = 'F:\Experiments_MalariaSpot\Muestra_v3\Grid_analysis\';
%         OPT_ADJUST_CENTER=true;
%     case 5
%         fPathAnalysis = 'F:\Experiments_MalariaSpot\Muestra_v5\Grid_analysis\';
%         OPT_ADJUST_CENTER=false;
% end
% 
% load([fPathAnalysis , 'CoordReal.mat'],'CoordReal', 'im', 'im_orig', 'areaCrop');

CoordReal=Coords.CoordReal;
im=Coords.im;
im_orig=Coords.im_orig;
areaCrop=Coords.areaCrop;

%[CoordIdeal, CoordRealNew, arrPositions, nonValid] = GridMatching_old(CoordReal, 'plot' , false);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
[CoordIdeal, CoordRealNew, StOut] = GridMatching(CoordReal, 'plot' , false, 'adjust_center', OPT_ADJUST_CENTER);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

numMarkers = size(CoordIdeal,1);
hfig{1}=figure(1); 
imshow(im,[]); hold on;
scatter(CoordReal(:,1), CoordReal(:,2),'g','.'); 
scatter(CoordRealNew(:,1), CoordRealNew(:,2),'r','.'); 
scatter(CoordIdeal(:,1),CoordIdeal(:,2),'b','.'); 
scatter(StOut.centerXY(1),StOut.centerXY(2),'m', 'o');
for i=1:numMarkers
    plot([CoordRealNew(i,1),CoordIdeal(i,1)],[CoordRealNew(i,2),CoordIdeal(i,2)], 'color', 'r');
end

CoordReal = CoordRealNew;
IDorig   = StOut.IDorig;
centerXY = StOut.centerXY;
scaleX   = StOut.scaleX;
scaleY   = StOut.scaleY;

save([fPathAnalysis ,FileName],'CoordIdeal','CoordReal', 'IDorig', 'im', 'centerXY','scaleX','scaleY', 'areaCrop');
CoordsGridMatching=load([fPathAnalysis ,FileName]);




% function [CoordRealT, arrIdeals), IDsNeighborPoints(CoordRealT, pointActual, arrIdeals)
% 
% 
% 
% end





