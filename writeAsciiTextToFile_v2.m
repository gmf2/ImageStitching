function [ fileID ] = writeAsciiTextToFile_v2( fFilenameResult, textsCells )
  
    if ~iscell(textsCells)
        textsCells = {textsCells};
    end

    fileID = fopen(fFilenameResult, 'wt');
    for i=1:numel(textsCells)
        texts = textsCells{i};
        if ~iscell(texts)
            texts = {texts};
        end
        for j=1:numel(texts)
            %texts{j} = strrep(texts{j}, '%', '%%');
            fprintf(fileID, [texts{j}, '\n']);
            %fprintf(fileID, texts{j});
        end
        %fprintf(fileID, '\r\n');
    end
    fclose(fileID);


end
