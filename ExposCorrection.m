function [ImagsExposCorrect, imd_Expos] = ExposCorrection(imds_Expos,Params,Measure,fPathExpos,factor,ImagsCorrected)

m=(1)/( Measure.Max.ExposureTime-Measure.Min.ExposureTime);

for i=1:numel(imds_Expos.Files)
%     ImagsExpos{i}=readimage(imds_Expos,i);
    ImagsExpos{i}=ImagsCorrected{i};
    %Exposure Time of image
    ExposureTime=Params.ExposureTime{i};
    %Intensity to be recalculated
    Y= m*ExposureTime + 0.25;
    %New Image
    ImagsExposCorrect{i}=(ImagsExpos{i}/(Y+factor));
end

%Mkdir subfolder
mkdir(fPathExpos)

%Para imagenes en buen sentido
for z=1:numel(ImagsExposCorrect)
    fNameImCorrected= [fPathExpos ,'ImExpos_', num2str(z,'%03.0f'), '.jpg'];
    imwrite(gather(ImagsExposCorrect{z}), fNameImCorrected, 'Quality', 100);
end

imd_Expos=imageDatastore(fPathExpos);
imd_Expos.Files = sort_nat(imd_Expos.Files,'ascend');



