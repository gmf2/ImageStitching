function [imds_Corrected,ImagsCorrected,im_correction_col, cropArea] =  CorrectVignnetingColor(imds, fPathCorrect, IND,NameCorrection,ImagsResize)

%parametros:
param.maxVariance   = 20;
param.minGraylevel = 100;

%IND son los identificadores de imagen que se usan para corrección

params.NofIimages = numel(IND); % pueden ser 4, dos al principio y al final, o solo dos al principio

%Number of images
numImagesCorr = numel(IND);

% Read first image
Imags     = cell(numImagesCorr,1);


for i=1:numImagesCorr 
    Imags{i} = readimage(imds, IND(i));
end

numImages = numel(imds.Files);
numImags=numel(ImagsResize);
sizeImage   = size(Imags{1});
imagsGray   = zeros(sizeImage(1),sizeImage(2), numImages);
imagsCol    = zeros(sizeImage(1),sizeImage(2), 3, numImages);

for i=1: numImagesCorr
    imagsGray(:,:,i) = rgb2gray(Imags{i});
    imagsCol(:,:,:,i) =  Imags{i};
end

maxValues = max(imagsGray,[],3);
%figure; imshow(imagsGray(:,:,1),[]);
%Bueno imshow
% figure; imshow(maxValues,[]);
mask = maxValues > param.minGraylevel;
mask = imdilate(mask, ones(7,7));
mask = imerode(mask,  ones(7,7));

%% encuentra la región mayor
imlabel = bwlabeln(mask, 8);
regs    = regionprops(imlabel, 'BoundingBox', 'Area');
areas   = cell2mat({regs(:).Area});
[~, p]  = max(areas);
mask    = imlabel == p;
mask    = imfill(mask, 'holes');

%% muestra el resultado
%Bueno imshow
% figure; imshow(maxValues,[]);
% title('Región mayor')
% hold on; 
% contour(mask, 'r');

%% reduce el tamaño
[row, col] = ind2sub(size(mask), find(mask));
mins = min([row,col]);
maxs = max([row,col]);
cropArea = [mins(2), mins(1), maxs(2)-mins(2), maxs(1)-mins(1)];
%mask = mask(mins(1):maxs(1), mins(2):maxs(2));
mask = imcrop(mask, cropArea);
sizeImROI = size(mask);

% recorta
imagsGray = imagsGray(mins(1):maxs(1), mins(2):maxs(2),:);
imagsCol  =  imagsCol(mins(1):maxs(1), mins(2):maxs(2),:,:);

% poco eficiente pero lo hacemos: multiplicamos por la máscara
% for i=1: numImages
%     imagsGray(:,:,i) = imagsGray(:,:,i).*mask;
% end

% Ahora vemos que elementos, dentro de la máscara, son distintos, par a par

arr_pairs = nchoosek(1:numImagesCorr ,2);
nPairs = size(arr_pairs,1);

maskC      = false(sizeImROI(1),sizeImROI(2), nPairs);
imags_mean = zeros(sizeImROI(1),sizeImROI(2), nPairs);
for i=1:nPairs
    %disp(i);
    pairs = arr_pairs(i,:);
    imag_variance = var(imagsGray(:,:,pairs),1,3);
    maskCtemp     = (imag_variance < param.maxVariance) & mask;
    im_mean = mean(imagsGray(:,:,pairs),3);
    im_mean(maskCtemp==0)=NaN;
    imags_mean(:,:,i)=im_mean;
    maskC(:,:,i)=maskCtemp;
end

% media por canales de color
imagsCol_mean = zeros(sizeImROI(1),sizeImROI(2), 3, nPairs);
for i=1:nPairs
    %disp(i);
    pairs = arr_pairs(i,:);
    for ch=1:3
        im_mean_ch = mean(imagsCol(:,:,ch,pairs),4);
        im_mean_ch(maskC(:,:,i)==0)=NaN;
        imagsCol_mean(:,:,ch,i)=im_mean_ch;
    end
end

im_correction = mean(imags_mean, 3, 'omitnan');
% posibles agujeros:
im_nocorrect  = zeros(size(im_correction));
im_nocorrect(isnan(im_correction))=1;
im_holes = imclearborder(im_nocorrect);

% pone a uno en la zona de no corrección
im_correction(isnan(im_correction))=1;

% en la zona de agujeros, pone la primera imagen:
im_meanT = mean(imagsGray(:,:,IND),3);
im_correction(im_holes==1)= im_meanT(im_holes==1);
%Bueno imshow
%figure;imshow(im_correction,[])
%title('Mascara para corregir')


im_correction_col = mean(imagsCol_mean, 4, 'omitnan');
im_correction_col(isnan(im_correction_col))=1;

% posibles agujeros
im_meanC = mean(imagsCol(:,:,:,IND),4);
for ch=1:3
    im_channel = im_correction_col(:,:,ch);
    immean_ch  = im_meanC(:,:,ch);
    im_channel(im_holes==1) = immean_ch(im_holes==1);
    im_correction_col(:,:,ch) = im_channel;
end


% imshow(im_correction_col./255,[])


%% Ahora corrige en cada nivel de color!!

%Read first image
Imags2 = cell(numImags,1);
for i=1:numel(ImagsResize)
    Imags2{i} = gpuArray(ImagsResize{i});
end
ImagsCorrected = cell(numImags,1);
for i=1:numel(imds.Files)
    %disp(i);
    ImagROI = Imags2{i}(mins(1):maxs(1), mins(2):maxs(2),:);
    ImagCorr = ImagROI;
    for ch=1:3
        ImagCorr(:,:,ch) = PerformVignettingCorrectionChannel(ImagROI(:,:,ch), im_correction_col(:,:,ch));
        ImagCorr(:,:,ch) = ImagCorr(:,:,ch).*uint8(mask);
    end
    ImagsCorrected{i}=ImagCorr;
end

%for i=1:numImages
 %   figure(i);
  %  subplot 121, imshow(Imags2{i},[]), title('Imagen Sin corregir');
 %   subplot 122, imshow(ImagsCorrected{i},[]), title('Imagen Corregida');
%end

%Mkdir subfolder
mkdir(fPathCorrect)

%Para imagenes en buen sentido
for z=1:numel(ImagsCorrected)
%     ImagsCorrectedGather=gather(ImagsCorrected);
    fNameImCorrected= [fPathCorrect ,'Imcorr_', num2str(z,'%03.0f'), '.jpg'];
    imwrite(gather(ImagsCorrected{z}), fNameImCorrected, 'Quality', 100);
end

imds_Corrected=imageDatastore(fPathCorrect);
imds_Corrected.Files = sort_nat(imds_Corrected.Files,'ascend');

%imshow(max(maskC,[],3),[]);

save([fPathCorrect, NameCorrection], 'im_correction',  'cropArea');


end

function O = PerformVignettingCorrectionChannel(Ip, Bg)
%
Bg=gpuArray(Bg);
% Check the inout parameters
    szBg = size(Bg);
    szIp = size(Ip);
        
    if(szBg(1) ~= szIp(1))
        error('Image rows mismatch');
    end

    if(szBg(2) ~= szIp(2))
        error('Image columns mismatch');
    end
    
    O = uint8(zeros(szIp));
    
    if(numel(szBg) == 3)
        Bg = rgb2gray(Bg);
    end
    
    % Computing Scale Matrix
    BgMax = max(max(Bg)); 
    BgMaxMat = BgMax * uint8(ones(size(Bg)));
    scaleMat = double(double(BgMaxMat)./double(Bg));
    
    % Generating output image
    O = uint8(double(Ip) .* scaleMat);
  
    
end
