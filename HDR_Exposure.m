function [Params,Measure]=HDR_Exposure(imd_f,fPath,OPEN_MEASURES)

% OPEN_MEASURES=false;
if OPEN_MEASURES ==false
for i=1:numel(imd_f.Files)
    info=imfinfo(imd_f.Files{i});
    %Params
    Params.ExposureTime{i}=info.DigitalCamera.ExposureTime;
    Params.ShutterSpeedValue{i}=info.DigitalCamera.ShutterSpeedValue;
%     Params.ExposureBiasValue{i}=info.DigitalCamera.ExposureBiasValue;
%     Params.FNumber{i}=info.DigitalCamera.FNumber;
%       Params.ISOSpeedRatings{i}=info.DigitalCamera.ISOSpeedRatings;
    Params.FocalLength{i}=info.DigitalCamera.FocalLength;   
  
end
    %Arrays
    MExposureTime = [Params.ExposureTime{:}];
    MShutterSpeedValue= [Params.ShutterSpeedValue{:}];
%     MExposureBiasValue= [Params.ExposureBiasValue{:}];
%     MFNumber= [Params.FNumber{:}];
%     MISOSpeedRatings= [Params.ISOSpeedRatings{:}];
    MFocalLength= [Params.FocalLength{:}];

    %Mean
    Measure.Mean.ExposureTime=mean(MExposureTime);
    Measure.Mean.ShutterSpeedValue=mean(MShutterSpeedValue);
%     Measure.Mean.ExposureBiasValue=mean(MExposureBiasValue);
%     Measure.Mean.FNumber=mean(MFNumber);
%     Measure.Mean.ISOSpeedRatings= mean(MISOSpeedRatings);
    Measure.Mean.FocalLength=mean(MFocalLength);

    %Max
    Measure.Max.ExposureTime=max(MExposureTime);
    Measure.Max.ShutterSpeedValue=max(MShutterSpeedValue);
%     Measure.Max.ExposureBiasValue=max(MExposureBiasValue);
%     Measure.Max.FNumber=max(MFNumber);
%     Measure.Max.ISOSpeedRatings=max(MISOSpeedRatings);
    Measure.Max.FocalLength=max(MFocalLength);
    
    %Min
    Measure.Min.ExposureTime=min(MExposureTime);
    Measure.Min.ShutterSpeedValue=min(MShutterSpeedValue);
%     Measure.Min.ExposureBiasValue=min(MExposureBiasValue);
%     Measure.Min.FNumber=min(MFNumber);
%     Measure.Min.ISOSpeedRatings=min(MISOSpeedRatings);
    Measure.Min.FocalLength=min(MFocalLength);
    
    save([fPath , 'Params.mat'], 'Params');
  else
   load([fPath , 'Params.mat'], 'Params');
end
     