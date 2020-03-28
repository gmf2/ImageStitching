
function CostFunc = CompareOverlappingArea(flag_PCglobalORlocal, I1, I2, p)
    
    % INTERNAL PARAMETERS:
    
    if ~(flag_PCglobalORlocal==0 || flag_PCglobalORlocal==1)
        error('ERROR inside Phase Correlation Algorithm: the input "flag_PCglobalORlocal" must be 0 or 1')
    end
    
    % Minimum percentage of shift between the 2 input images (in both x and y directions)
    ShiftPercentageThreshold = 0.10; % It means 10%
    
    % Percentage of pixels analyzed.
    PercentagePixelsAnalyzed = 0.01;
    
    Dx = abs(p.x);
    Dy = abs(p.y);

    %I1 = I1 / std(I1(:)); % To normalize the image but I checked and it is not an improvment
    %I2 = I2 / std(I2(:)); % To normalize the image but I checked and it is not an improvment
    
    if(p.x>=0 && p.y>=0)
        ROI_OA2 = double(I2(1:end-Dy,1:end-Dx));
        ROI_OA1 = double(I1(1+Dy:end,1+Dx:end));
    end
    
    if(p.x<0 && p.y>=0 )
		ROI_OA2 = double(I2(1:end-Dy,1+Dx:end));
        ROI_OA1 = double(I1(1+Dy:end,1:end-Dx));
    end

    if (p.x>=0 && p.y<0 )
		ROI_OA2 = double(I2(1+Dy:end,1:end-Dx));
        ROI_OA1 = double(I1(1:end-Dy,1+Dx:end));	
    end
	
    if (p.x<0 && p.y<0 )
		ROI_OA2 = double(I2(1+Dy:end,1+Dx:end));
        ROI_OA1 = double(I1(1:end-Dy,1:end-Dx));	
    end
    
%     figure(1), imshow(ROI_OA1, [], 'Border', 'Tight')
%     figure(2), imshow(ROI_OA2, [], 'Border', 'Tight') 
    
    % Often there is a problem with wrap around: ROI_OA1 and ROI_OA2 became
    % so small that they are a line of one pixel. Furthermore, sometimes
    % those lines have a CostFunc normalized smaller of the correct shift. With
    % this control ROI of a lines are excluded.
    [height,width,ch]                   = size(I1);
    [heightROI,widthROI,chROI]          = size(ROI_OA1);
    if (heightROI*widthROI)/(height*width) >= ShiftPercentageThreshold
        
        E = abs(ROI_OA2-ROI_OA1);
        if flag_PCglobalORlocal == 0
            E = E(:);
            CostFunc = sqrt(mean(E.^2));
        elseif flag_PCglobalORlocal == 1
            
            % Analysis of image's blocks
            BlockSize = 5;
            MinNumberBlockAnalyzed = 10;
            fun = @(block_struct) mean2(block_struct.data);
            Eblock = blockproc(E, [BlockSize BlockSize], fun);
            Eblock = Eblock(1:end-1, 1:end-1, :); %To delete wrap around value
            NumberBlockAnalyzed = ceil(size(Eblock,1)*size(Eblock,2)*PercentagePixelsAnalyzed);
            if NumberBlockAnalyzed < MinNumberBlockAnalyzed
                NumberBlockAnalyzed = MinNumberBlockAnalyzed;
            end
            Esort = sort(Eblock(:)); % From lowest to highest.
            Esort = Esort(end:-1:1); % From highest to lowest.
            CostFunc = sqrt(mean(Esort(1:NumberBlockAnalyzed).^2));
            
            % Analysis of image's pixels
            %Esort = sort(E(:)); % From lowest to highest.
            %Esort = Esort(end:-1:1); % From highest to lowest.
            %NumberPixelsAnalyzed = ceil(heightROI*widthROI*PercentagePixelsAnalyzed);
            %CostFunc = sqrt(mean(Esort(1:NumberPixelsAnalyzed).^2));
        end
        
    else
        CostFunc = inf;
    end
    
end