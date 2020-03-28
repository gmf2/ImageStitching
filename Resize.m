function [ResizeImage,ImagsResize]= Resize(imd_f,fPathResize,Factor)

for i=1:numel(imd_f.Files)
   ImagsResize{i}=readimage(imd_f,i);
   ImagsResize{i}=imresize(ImagsResize{i},Factor); 
   disp(size(ImagsResize{i},1)<size(ImagsResize{i},2))
   if size(ImagsResize{i},1)<size(ImagsResize{i},2)
        ImagsResize{i}=imrotate(ImagsResize{i},-90);
   end
end    
%Mkdir subfolder
mkdir(fPathResize)
 
for z=1:numel(ImagsResize)
    fNameImResize= [fPathResize ,'ImResize_', num2str(z), '.jpg'];
    imwrite(ImagsResize{z}, fNameImResize);
end

ResizeImage=imageDatastore(fPathResize);
ResizeImage.Files = sort_nat(ResizeImage.Files,'ascend');

