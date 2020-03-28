function [ Tform, angle ] = PointBasedRegistration(fPath,I1, I2, OPTION_DETECTOR, PLOT )

for i=1:numel(imd_f.Files)
 ImagesReg{i}=readimage(imd_f,i);
ImagesReg{i} =rgb2gray( ImagesReg{i});
end

I1=ImagesReg{2};
I2=ImagesReg{3};

%Convertir a double
% convert to double, easier implementation
if (strcmp(class(I1), 'uint8'))
    I1 = im2double(I1);
end
if (strcmp(class(I2), 'uint8'))
    I2 = im2double(I2);
end

    switch OPTION_DETECTOR
        case 1
            points1 = detectHarrisFeatures(I1);
            points2 = detectHarrisFeatures(I2);
            fName= [fPath ,'HarrisFeatures', '.jpg'];
        case 2
            points1 = detectSURFFeatures(I1, 'MetricThreshold', 50);
            points2 = detectSURFFeatures(I2, 'MetricThreshold', 50);
            fName= [fPath ,'SURFFeatures', '.jpg'];
        case 3
            points1 = detectBRISKFeatures(I1);
            points2 = detectBRISKFeatures(I2);
            fName= [fPath ,'BRISKFeatures', '.jpg'];
        case 4
            points1 = detectFASTFeatures(I1);
            points2 = detectFASTFeatures(I2);
            fName= [fPath ,'FASTFeatures', '.jpg'];
        case 5
            points1 = detectMinEigenFeatures(I1);
            points2 = detectMinEigenFeatures(I2);
            fName= [fPath ,'MinEigenFeatures', '.jpg'];
    end
%             case 6
%                 features1 = extractHOGFeatures(I1);
%                 features2 = extractHOGFeatures{I2};
%             case 7
%                 features1 = extractLBPFeatures(I1);
%                 features2 = extractLBPFeatures(I1);
        
    [features1,valid_points1] = extractFeatures(I1,points1);
    [features2,valid_points2] = extractFeatures(I2,points2);
    [indexPairs,matchmetric] = matchFeatures(features1,features2, 'MatchThreshold', 60, 'unique', true);
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);

    if PLOT==true
      showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');
    end

    Tform = estimateGeometricTransform(matchedPoints2,matchedPoints1,'similarity');
    angle = dcm2angle(Tform.T);
 
end

