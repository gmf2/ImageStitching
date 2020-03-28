function [imd_f,Imags]= ReadImag(fPath)
imd_f=imageDatastore(fPath);
imd_f.Files=sort_nat(imd_f.Files,'ascend');

for i=1:numel(imd_f.Files)
   Imags{i}=readimage(imd_f,i);  
end
