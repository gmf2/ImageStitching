function [ImagMatrix] = LUT_Stitch( dir,Rows,Columns)

Count=1;

numImages   = Rows*Columns;
ImagArray  = 1:numImages;
ImagMatrix=zeros(Rows,Columns);

if isequal(dir,'left')
    for i=1:Rows
        for j=1:Columns
        if mod(i,2)== 1
        ImagMatrix(i,j)=ImagArray(Count);
        elseif mod(i,2)== 0
        ImagMatrix(i,Columns+1-j)=ImagArray(Count);
        end
        Count=Count+1;
        end
    end
elseif isequal(dir,'below')
     for i=1:Columns
        for j=1:Rows
        if mod(i,2)== 1
        ImagMatrix(j,i)=ImagArray(Count);
        elseif mod(i,2)== 0
        ImagMatrix(Rows+1-j,i)=ImagArray(Count);
        end
        Count=Count+1;
        end
    end 
else
    msgbox('Incorrect Dir')
end
    


