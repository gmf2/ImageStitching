function [ArrayCell,Rows,Columns] =  lut(ArrayFiles,dir,Rows,Columns)
ArrayCell={};
Count=1;
%LEER IMAGENES 
numImages = numel(ArrayFiles);
ImagArray2  = {};
for i=1: numImages
    if i<10
    ImagArray2{i} = ArrayFiles{i}(end-4:end-4);
    elseif i>=10 && i<100
    ImagArray2{i} = ArrayFiles{i}(end-5:end-4);
    elseif i>=100
    ImagArray2{i} = ArrayFiles{i}(end-6:end-4);
    end
end
if isequal(dir,'left')
    for i=1:Rows
        for j=1:Columns
        if mod(i,2)== 1
        ArrayCell{i,j}=ImagArray2{Count};
        elseif mod(i,2)== 0
        ArrayCell{i,Columns+1-j}=ImagArray2{Count};
        end
        Count=Count+1;
        end
    end
elseif isequal(dir,'below')
     for i=1:Columns
        for j=1:Rows
        if mod(i,2)== 1
        ArrayCell{j,i}=ImagArray2{Count};
        elseif mod(i,2)== 0
        ArrayCell{Rows+1-j,i}=ImagArray2{Count};
        end
        Count=Count+1;
        end
    end 
else
    msgbox('Incorrect Dir')
end
    
