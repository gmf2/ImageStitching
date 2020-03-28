function [Coords] = Util_GridDetection_set3(cropArea,NameWatershed,fPathAnalysis,Factor)
% clearvars
% close all
% 
% fPathImages     = 'F:\Experiments_MalariaSpot\Muestra_v3\Grid_Resize\';
% fPathVignneting = 'F:\Experiments_MalariaSpot\Muestra_v3\Grid_Vignneting\';
% fPathAnalysis   = 'F:\Experiments_MalariaSpot\Muestra_v3\Grid_Analysis\';
mkdir(fPathAnalysis);

areaCrop = cropArea; clear cropArea;

h=msgbox('Choose the grid image', 'modal');
waitfor(h);
[file,fPath]=uigetfile( '*.jpg;*.png');
fPathGrid= fullfile(fPath);
imd_f=imageDatastore(fPathGrid);
imd_f.Files=sort_nat(imd_f.Files,'ascend');

[imd_f]= Resize_GPU(imd_f,fPathGrid,Factor);  
fPathImageResize=strcat([fPath,'ImResize_1.jpg']);
im_orig = imread(fPathImageResize);

im = rgb2gray(im_orig);
im = double(im)./255;
imshow(im,[]);

% filtrado
imgf = medfilt2(im, [4,4]);
imgf = imgaussfilt(imgf,5);
imshow(imgf,[]);

%% transformación wathersed
% OPT_CALCULATE_WATERSHED=false;
if (exist(strcat(fPathAnalysis,NameWatershed),'file')==0)
    imneg = max(imgf(:))-imgf;
    imw = watershed(imneg,8);
    imwz = (imw ~= 0).*255;
    imwrite(imwz, [fPathAnalysis,NameWatershed]);
 else
    imwz = imread([fPathAnalysis,NameWatershed]);
end

%% visualiza resultado
figure(2);imshow(im,[]); hold on;
imwC = zeros([size(imwz),3]);
imwM = imdilate(imwz==0, ones(3,3));
imwC(:,:,1)=imwM ;
h2= imshow(imwC,[]);
set(h2, 'AlphadataMapping', 'scaled', 'Alphadata', imwM);

imlabels =  bwlabel(imwz,8);
%% analiza propiedades de las watersheds
imBorder = zeros(size(imlabels));
imBorder([1,end],:)=1;
imBorder(:,[1,end])=1;
pixelidxlistBorder = find(imBorder);

St  = regionprops(imlabels, imgf, 'Area', 'centroid', 'Eccentricity','Extent','WeightedCentroid','Extrema','PixelIdxList');
regionIsBorder = false(numel(St),1);
for i=1:numel(St)
    if numel(intersect(pixelidxlistBorder, St(i).PixelIdxList)) > 0
        regionIsBorder(i)=true;
    end
end

% elimina regiones del borde
St(regionIsBorder)=[]; 
% quita area pequeña
Areas =[St.Area];
findSmall = find(Areas < 10);
St(findSmall) = [];

%% centroides
nLabels = numel(St);
Eccentricity  = [St.Eccentricity];
Centroids  = reshape([St.Centroid],2,nLabels )';
wCentroids = reshape([St.WeightedCentroid],2,nLabels )';

CoordReal = wCentroids; % elegimos entre centroids y wCentroids, a ver cual da mejor ajuste

figure(2); imshow(im,[]); hold on;
scatter(CoordReal(:,1),CoordReal(:,2),'r', '.');

%% A partir de aquí abría que sustituir por "GridDetection_Automatic.m"


nPoints = size(CoordReal,1);
%% Ordenamos los centroides por X,Y:

save([fPathAnalysis , 'CoordReal.mat'],'CoordReal', 'im', 'im_orig', 'areaCrop');

% A partir de aquí continua en Util_GridMatching

Coords=load([fPathAnalysis , 'CoordReal.mat']);








    




