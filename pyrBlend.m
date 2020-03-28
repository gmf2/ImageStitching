function [imgo,sizeImgo] = pyrBlend(imga,imgb,right_prev,right,left_prev,left,bottom,bottom_prev,top,top_prev,type)
 
% close all
% clear
% imga = im2double(imread('C:\Users\Gabriel\Documents\Universidad\TFG\02. Codigos\image_pyramid\apple1.jpg'));
% imgb = im2double(imread('C:\Users\Gabriel\Documents\Universidad\TFG\02. Codigos\image_pyramid\orange1.jpg')); % size(imga) = size(imgb)
imga = imresize(imga,[size(imgb,1) size(imgb,2)]);
[M N ~] = size(imga);

% v = 230;
level = 5;
limga = genPyr(imga,'lap',level); % the Laplacian pyramid
limgb = genPyr(imgb,'lap',level);
maska = zeros(size(imga));

switch type
    case 'leftRight'
        if top_prev>top
           begin=abs(top_prev-top)+(abs(bottom-top_prev)/2);
           finish=bottom;
        elseif top_prev<top
            begin=1;
            finish=(abs(bottom_prev-top)/2);
        else
            begin=1;
            finish=(abs(bottom_prev-top)/2);
        end
%         maska(begin:finish,1:((right_prev-left)/2),:) = 1;
        maska(:,1:(abs(right_prev-left)/2),:) = 1;
        maskb = 1-maska;
    case 'rightLeft'
        if top_prev>top
           begin=abs(top_prev-top)+(abs(bottom-top_prev)/2);
           finish=bottom;
        elseif top_prev<top
            begin=1;
            finish=(abs(bottom_prev-top)/2);
        else
            begin=1;
            finish=(abs(bottom_prev-top)/2);
        end
%       maska(begin:finish,((left_prev-left)+(right-left_prev)/2):end,:) = 1;
        maska(:,(abs(left_prev-left)+abs(right-left_prev)/2):end,:) = 1;
        maskb = 1-maska;
    case 'down'
        maska(1:(abs(bottom_prev-top)/2),:,:) = 1;
        maskb = 1-maska;
    otherwise
        disp('Enter the correct type')
        return
end

blurh = fspecial('gauss',30,15); % feather the border
maska = imfilter(maska,blurh,'replicate');
maskb = imfilter(maskb,blurh,'replicate');

limgo = cell(1,level); % the blended pyramid
for p = 1:level
	[Mp Np ~ ] = size(limga{p});
	maskap = imresize(maska,[Mp Np]);
	maskbp = imresize(maskb,[Mp Np]);
	limgo{p} = limga{p}.*maskap + limgb{p}.*maskbp;
end
imgo = pyrReconstruct(limgo);
sizeImgo=size(imgo);

imgo = imresize(imgo,[size(imgb,1) size(imgb,2)]);

% figure(2),imshow(imgo) % blend by pyramid
% imgo1 = maska.*imga+maskb.*imgb;
% figure(3),imshow(imgo1) % blend by feathering