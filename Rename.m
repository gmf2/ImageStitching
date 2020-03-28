function [Rename,fPathRename,Imags]=Rename(ImagsCropped1,fPathRename)

%Store in a new folder
%Mkdir subfolder
mkdir(fPathRename)

PixelImag(1:3)=0;

for x=1:numel(ImagsCropped1)
    Imags{x}=ImagsCropped1{x};
end

for i=1:numel(Imags)
%      for d=1:3
%         for h=1:size(Imags{i},1)
%             for p=1:size(Imags{i},2)
%                 if Imags{i}(h,p,d)>60
%                     PixelImag=Imags{i}(h,p,d);
%                 else
%                     Imags{i}(h,p,:)=PixelImag(:);
%                 end
%             end
%         end
%     end
%     
    if i < 10
        fNameImCorrected= [fPathRename ,'Imcorr_00', num2str(i), '.jpg'];
        imwrite(Imags{i}, fNameImCorrected,'Quality',100.0);
    elseif i < 100
        fNameImCorrected= [fPathRename ,'Imcorr_0', num2str(i), '.jpg'];
        imwrite(Imags{i}, fNameImCorrected,'Quality',100.0);
    else
        fNameImCorrected= [fPathRename ,'Imcorr_', num2str(i), '.jpg'];
        imwrite(Imags{i}, fNameImCorrected,'Quality',100.0);
    end
end

Rename=imageDatastore(fPathRename);
Rename.Files = sort_nat(Rename.Files,'ascend');