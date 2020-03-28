function [CropImage,Size,Imags] = CropRectangleInscribed(Type,ImagsDistorted,fPathImCrop)

for i=1:numel(ImagsDistorted)
    Imags{i}=ImagsDistorted{i};
    if i==1
        % S stores for each pixel the size of the largest all-white square
        % with its upper-left corner at that pixel
        switch Type
            case 'Black'
        S = FindLargestSquares(Imags{i});
            case 'White'
        S = FindLargestSquaresWhite(Imags{i});
        end
        %imagesc(S); axis off

        %% Use S to find the largest Square inscribed in the circle
        %subplot(1,2,1) 
        %imshow(BW)
        [number, pos] = max(S(:));
        %disp(S(:))
        [r, c, d] = ind2sub(size(S), pos);
        %rectangle('Position',[c,r,S(r,c),S(r,c)], 'EdgeColor','r', 'LineWidth',3);

        %subplot(1,2,2) 
        Imags{i}=imcrop(Imags{i},[c,r,S(r,c),S(r,c)]);
        %imshow(ImagCrop)

    else
    [Imags{i},Size]=imcrop(Imags{i},[c,r,S(r,c),S(r,c)]);
    end
end

%Mkdir subfolder
%fPathCrop=[fPathImCrop,'\ImagCrop\'];
mkdir(fPathImCrop)
 
for z=1:numel(Imags)
    %disp(numel(Imags))
    %disp(Imags{z})
    fNameImCorrected= [fPathImCrop ,'Imcorr_', num2str(z), '.jpg'];
    %disp(fNameImCorrected)
    imwrite(Imags{z}, fNameImCorrected);
end

CropImage=imageDatastore(fPathImCrop);
CropImage.Files = sort_nat(CropImage.Files,'ascend');

