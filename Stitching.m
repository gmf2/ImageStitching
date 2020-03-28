function I = Stitching(img_directory,img_common_name,BLEND,FileName,Rows,Columns,ImagMatrix,fPathStitching,FinalName)

%BLEND = 'overlay';
%BLEND = 'average';
%img_common_name='Imcorr_';
%img_directory='C:\Users\Gabriel\Documents\TFG\03. Resultados\TestReg_vf\Rename\';
disp([img_directory FileName])
FIJI_translations = importdata([img_directory FileName]);

% remove any entries without the common name

indx= strfind(FIJI_translations,img_common_name);

FIJI_translations = FIJI_translations(~cellfun(@isempty, indx));

% init data
nb_rows_in_cell_array = numel(FIJI_translations);
file_name_array = {};
x_coords = [];
y_coords = [];

% load global image positions from the registered translations files
for i = 1:nb_rows_in_cell_array
  cur_string = FIJI_translations{i};
  if isempty(cur_string),continue, end
  if strcmp(cur_string(1:length(img_common_name)),img_common_name)
    k = strfind(cur_string, ';');
    file_name_array = vertcat(file_name_array, {cur_string(1:k(1)-1)});
    k1 = strfind(cur_string, '(');
    k2 = strfind(cur_string, ',');
    k3 = strfind(cur_string, ')');
    x_coords = vertcat(x_coords, str2double(cur_string(k1(1)+1:k2(1)-1)));
    y_coords = vertcat(y_coords, str2double(cur_string(k2(1)+1:k3(1)-1)));
  end
end

% get individual image size
info = imfinfo([img_directory file_name_array{1}],'jpg');
nb_rows = info.Height;
nb_cols = info.Width;

% convert image coordinates into pixel coordinates
x_coords = round(x_coords);
y_coords = round(y_coords);

% translate coordinages into quadrant 4
x_coords = x_coords - min(x_coords) + 1;
y_coords = y_coords - min(y_coords) + 1;

% determine the size of the output image
nb_stitched_cols = max(x_coords) - min(x_coords) + nb_cols + 2;
nb_stitched_rows = max(y_coords) - min(y_coords) + nb_rows + 2;
nb_dim=3;
switch BLEND
  case 'overlay'
    I = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
    for i = 1:numel(file_name_array)
      frame = im2double(imread([img_directory file_name_array{i}]));
      
      left = x_coords(i);
      top = y_coords(i);
      bottom = top + nb_rows -1;
      right = left + nb_cols -1;
      
      I(top:bottom, left:right,1:nb_dim) = frame;
    end
  case 'average'
    I = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
    COUNTS = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
    for i = 1:numel(file_name_array)
      frame = im2double(imread([img_directory file_name_array{i}]));
      
      left = x_coords(i);
      top = y_coords(i);
      bottom = top + nb_rows - 1;
      right = left + nb_cols - 1;
      
      I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;
      COUNTS(top:bottom, left:right,1:nb_dim) = COUNTS(top:bottom, left:right,1:nb_dim) + 1;
      %figure(1)
      %imshow(I)
      %figure(2)
      %imshow(COUNTS)
    end
    I = (I./COUNTS);
    case 'Multiblending'
    I = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
    COUNTS = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
    Count=1;
%     COUNTS = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
%     for i = 1:numel(file_name_array) 
        for r=1:Rows
            for q=1:(Columns)
                    disp('r')
                    disp(r)
                    disp('q')
                    disp(q)
                    disp('Count')
                    disp(Count)
                   if mod(r,2)== 1
                       if r==1 && q==1
                          %Image
                          frame = im2double(imread([img_directory file_name_array{Count}]));
                          %Params
                          left = x_coords(Count);
                          top = y_coords(Count);
                          bottom = top + nb_rows - 1;
                          right = left + nb_cols - 1;
                          %Stitching
                          I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame; 
%                           COUNTS(top:bottom, left:right,1:nb_dim) = COUNTS(top:bottom, left:right,1:nb_dim) + 1;
                        elseif r~=1&& q==1
                          %Image
                          frame = im2double(imread([img_directory file_name_array{Count}]));
                          %ParamsPrev
                          left_prev = x_coords(Count-1);
                          top_prev = y_coords(Count-1);
                          bottom_prev = top_prev + nb_rows - 1;
                          right_prev = left_prev + nb_cols - 1;
                          %Params
                          left = x_coords(Count);
                          top = y_coords(Count);
                          bottom = top + nb_rows - 1;
                          right = left + nb_cols - 1;
                          %Stitching
                          I(top:bottom, left:right,1:nb_dim) = pyrBlend(I(top:bottom, left:right,1:nb_dim),frame,right_prev,right,left_prev,left,bottom,bottom_prev,top,top_prev,'down');
%                           COUNTS(top:bottom, left:right,1:nb_dim) = 1;
%                         I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;                       
                       else
                          %Image
                          frame = im2double(imread([img_directory file_name_array{Count}]));
                          %ParamsPrev
                          left_prev = x_coords(Count-1);
                          top_prev = y_coords(Count-1);
                          bottom_prev = top_prev + nb_rows - 1;
                          right_prev = left_prev + nb_cols - 1;
                          %Params
                          left = x_coords(Count);
                          top = y_coords(Count);
                          bottom = top + nb_rows - 1;
                          right = left + nb_cols - 1;
                          %Stitching Revisar
                          I(top:bottom, left:right,1:nb_dim) = pyrBlend(I(top:bottom, left:right,1:nb_dim),frame,right_prev,right,left_prev,left,bottom,bottom_prev,top,top_prev,'leftRight');
%                           COUNTS(top:bottom, left:right,1:nb_dim) =1;
 %                           I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;                       
                       end
                       elseif mod(r,2)== 0
                       if q==1
                          %Image
                          frame = im2double(imread([img_directory file_name_array{(r*Columns)-q+1}]));
                          %Params
                          left = x_coords((r*Columns)-q+1);
                          top = y_coords((r*Columns)-q+1);
                          bottom = top + nb_rows - 1;
                          right = left + nb_cols - 1;
                          %Stitching
                          I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;                       
%                           COUNTS(top:bottom, left:right,1:nb_dim) =1;
                       else
                          %Image
                          frame = im2double(imread([img_directory file_name_array{(r*Columns)-q+1}]));
                          %ParamsPrev
                          left_prev = x_coords((r*Columns)-q+2);
                          top_prev = y_coords((r*Columns)-q+2);
                          bottom_prev = top_prev + nb_rows - 1;
                          right_prev = left_prev + nb_cols - 1;
                          %Params
                          left = x_coords((r*Columns)-q+1);
                          top = y_coords((r*Columns)-q+1);
                          bottom = top + nb_rows - 1;
                          right = left + nb_cols - 1;
                          %Stitching Revisar
                          [I(top:bottom, left:right,1:nb_dim),sizeImgo] = pyrBlend(I(top:bottom, left:right,1:nb_dim),frame,right_prev,right,left_prev,left,bottom,bottom_prev,top,top_prev,'rightLeft');
%                           COUNTS(top:bottom, left:right,1:nb_dim) =1;
%                         I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;                       
                       end                      
                   end
                   
                  Count=Count+1;
            end
             Count=Count+1;    
        end
%          I = (I./COUNTS);
%         
%         for r=1:Rows
%             for c=1:Columns
%                 frame = im2double(imread([img_directory file_name_array{i}]));
%                 
%                  if r==1 && c==1
%                 left = x_coords(i);
%                 top = y_coords(i);
%                 bottom = top + nb_rows - 1;
%                 right = left + nb_cols - 1;
% 
%                 I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;
%                 elseif r==1 && c~=1
%                    if mod(r,2)== 1
%                        IND=i-1;
%                     elseif mod(r,2)== 0
%                        IND=i-1;
%                    end
%                  %Preivous Image
%                  left_prev = x_coords(i);
%                  top_prev = y_coords(i);
%                  bottom_prev = top + nb_rows - 1;
%                  right_prev = left + nb_cols - 1;
% 
%                  %Current Image
%                  left = x_coords(i);
%                  top = y_coords(i);
%                  bottom = top + nb_rows - 1;
%                  right = left + nb_cols - 1;
%                     
%                  else
%                  %Preivous Image
%                 left_prev = x_coords(i);
%                 top_prev = y_coords(i);
%                 bottom_prev = top + nb_rows - 1;
%                 right_prev = left + nb_cols - 1;
% 
%                 %Current Image
%                 left = x_coords(i);
%                 top = y_coords(i);
%                 bottom = top + nb_rows - 1;
%                 right = left + nb_cols - 1;
% 
%                 I(top:bottom, left:right,1:nb_dim) = I(top:bottom, left:right,1:nb_dim) + frame;
%          %      COUNTS(top:bottom, left:right,1:nb_dim) = COUNTS(top:bottom, left:right,1:nb_dim) + 1;
%                 %figure(1)
%                 %imshow(I)
%                 %figure(2)
%                 %imshow(COUNTS)
%                 end
%             end
%         end
%      
%     end
%     case 'blend'
%     Count=1;
%     I = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
%     %COUNTS = zeros(nb_stitched_rows,nb_stitched_cols,nb_dim,'double');
%     for i = 1:15%numel(file_name_array)
%       frame = im2double(imread([img_directory file_name_array{i}]));
%       %Distances
%       left = x_coords(i);
%       top = y_coords(i);
%       bottom = top + nb_rows - 1;
%       right = left + nb_cols - 1;
      %Overlap
%       if i==1
%          OvX=nb_rows*OverlapX;
%          OvY=nb_cols*OverlapY;
%       else
%          OvX=(x_coords(i-1)+ nb_cols - 1)-left;
%          OvY=(y_coords(i-1)+ nb_rows - 1)-right;
%       end      
      %Parts
%       I(top:OvY+top, left:OvX+left,1:nb_dim) = I(top:OvY, left:OvX,1:nb_dim)/2 + frame(1:1);
%       
%       COUNTS(top:bottom, left:right,1:nb_dim) = COUNTS(top:bottom, left:right,1:nb_dim) + 1;
%       %figure(1)
      %imshow(I)
      %figure(2)
      %imshow(COUNTS)
%     end
%     I = (I./COUNTS);
  otherwise
    error('Unsupported Blend');
end

%Store in a new folder
%Mkdir subfolder
fPathFinal=fPathStitching;
mkdir(fPathFinal)

fNameImCorrected= [fPathFinal ,FinalName, '.jpg'];
imwrite(I, fNameImCorrected,'Quality',100.0);
   

end
 
            
 
 
