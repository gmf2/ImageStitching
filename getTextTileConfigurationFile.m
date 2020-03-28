function [strText] = getTextTileConfigurationFile(mLocations, ImagesNames )

[nRows, nCols, ~] = size(mLocations);

nImages =nRows*nCols;

strText = cell(nImages+4,1);
strText{1} = '# Define the number of dimensions we are working on';
strText{2} = 'dim = 2';
strText{4} = '# Define the image coordinates';

nc = 5;
nCounter = 1;
for i=1:nRows
    for j=1:nCols
        coordIni = mLocations(i,j,:);
        strImagName = ImagesNames{i,j};
        strText{nc} = [strImagName, '; ; (', num2str(coordIni(1),'%3.2f'), ', ', num2str(coordIni(2),'%3.2f'), ')';];
        nc = nc+1;
        nCounter = nCounter+1;
    end
end
strText = strText(1:nc-1);


end

