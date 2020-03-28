
%Main
%STRINGS FOLDER
%Selected folder
fPath=uigetdir;
FlagScale=true;
fPathAdjust=strcat(fPath,'\ImageAdjust\');
fPathRename=strcat(fPath,'\ImageRename\');
fPathCrop1=strcat(fPath,'\ImagCrop1\');
fPathCrop2=strcat(fPath,'\ImagCrop2\');
fPathDistors=strcat(fPath,'\ImagCorrectDistorsion\');
fPathCorrect=strcat(fPath,'\ImagCorrected\');
fPathResize=strcat(fPath,'\ImagResize\');
fPathExpos=strcat(fPath,'\ImagCorrectExpos\');
fPathStitching =strcat(fPath,'\ImagStitching\');
%%%%%FUNCTIONS%%%%%
prompt = {'Correction Distorsion Needed: (YES/NO)','4 images with not object to correct vignetting:','Correction Exposition Needed: (YES/NO)','Scale Factor'};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        FlagDistorsion=lower(strrep(answer{1},' ',''));
        IND=str2num(answer{2});
        FlagExposition=lower(strrep(answer{3},' ',''));
        ScaleFactor=str2num(strrep(answer{4},' ',''));
%Type Functions
typeDistorsion=1;
tic;  
%Read images
[imd_f,ImagsInitial]=ReadImagGPU(fPath);
;Time.TimeReadImag=toc;
%Selected datastore
imd_Resize=imd_f;
imds_Corrected=imd_f;
imd_Expos=imd_f;
imd_Distorted=imd_f;
imd_Cropped1=imd_f;
tic;
%Determine number of Rows and Columns
[Rows, Columns] =Rows_Columns_GPU(imd_f);
;Time.TimeRows_Columns=toc;
%Create look up table
%Rows=15 y Columns=15
tic;
[lut,Rows,Columns]=lutArray(imd_f.Files,'left',Rows,Columns);
ImagMatrix = LUT_Stitch_GPU('left',Rows,Columns);
;Time.TimeLut=toc;
%Resize Imags
if isequal(ScaleFactor,1)
    FlagScale=false;
    imd_Resize=imd_f;
    ImagsResize=ImagsInitial;
end

if exist(strcat(fPath,'\ImagResize\'),'dir')==0 && FlagScale~=false
    tic;
    [imd_Resize,ImagsResize]= Resize_GPU(imd_f,fPathResize,ScaleFactor);
    ;Time.TimeResize=toc;
elseif FlagScale~=false
    tic;
    [imd_Resize,ImagsResize]=ReadImagGPU(fPathResize);
    ;Time.TimeResize=toc;
end

%Correct Vignneting
if exist(strcat(fPath,'\ImagCorrected\'),'dir')==0
%     %IND CELULA
%     IND=[1,2,30,180];
%     %IND ABEJA
%     IND=[89,90,99,100];
%     %IND BICHO
%     IND=[5,6,26,36];
    %Correct Image
    tic;
    [imds_Corrected,ImagsCorrected,im_correction_col, cropArea]=CorrectVignnetingColor_GPU(imd_Resize, fPathCorrect,IND,'VignetingCorrection_rgb.mat',ImagsResize);
    ;Time.TimeCorrectionVignetting=toc;
else
    [imds_Corrected,ImagsCorrected]=ReadImagGPU(fPathCorrect);
end
%Correct Exposition
if (exist(strcat(fPath,'\ImagCorrectExpos\'),'dir')==0) && (isequal(FlagExposition,'yes'))
    tic;
    %Measures Exposure Time
    [Params,Measure]=HDR_Exposure(imd_f,fPath,false);
    %Correct Exposition
    [ImagsExposCorrect, imd_Expos] = ExposCorrection(imds_Corrected,Params,Measure,fPathExpos,-1.1,ImagsCorrected);
    ;Time.TimeCorrectionExposition=toc;
elseif (isequal(FlagExposition,'yes'))
     tic;
    [imd_Expos,ImagsExposCorrect]=ReadImagGPU(fPathExpos);
    ;Time.TimeCorrectionExposition=toc;
end
%Correct Distorsion
if (exist(strcat(fPath,'\ImagCorrectDistorsion\'),'dir')==0) && (isequal(FlagDistorsion,'yes'))
    %CropArea
     CorrectionFeatures= load([fPathCorrect, 'VignetingCorrection_rgb.mat']);
     cropArea=CorrectionFeatures.cropArea;
     %Exposition 
    if ~isequal(FlagExposition,'yes')
       imd_Expos=imds_Corrected;
       ImagsExposCorrect=ImagsCorrected;
    end
   tic;
    switch typeDistorsion
         case 1
         %Type 1
         [imd_Distorted,ImagsDistorted]=CorrectDeformation(ImagsExposCorrect,-0.3,fPathDistors);
         case 2
         %Type2         
         %Detect Markers Grid
         [markers,fPathGrid,IDorig]=Test_GridDetection(0.15,'Wathersed.jpg',true);
         %Correct Grid
         [imGridIdeal]=Test_GridCorrection_UsingAutomaticMarkers(fPath,fPathGrid,Factor,TYPE_DISTORTION);
        case 3
         %Step 1: Util_GridCorrection
         [Coords] = Util_GridDetection_set3(cropArea,'GridWathersed.png',fPathDistors);
         %Step 2: Util_GridMatching
         [CoordsGridMatching] = Util_GridMatching(Coords,fPathDistors,'markers_centroids_auto2.mat',true);
         %Step 3: Util_GridCorrection
         Util_GridCorrection(fPathAnalysis,FileName,true)         
    end
    ;Time.TimeCorrectDistorsion=toc;
elseif (isequal(FlagDistorsion,'yes'))
     tic;
    [imd_Distorted,ImagsDistorted]=ReadImagGPU(fPathDistors);
    ;Time.TimeCorrectionExposition=toc;
end   
%Crop Image
if exist(strcat(fPath,'\ImagCrop1\'),'dir')==0
    if ~isequal(FlagExposition,'yes') && ~isequal(FlagDistorsion,'yes') 
        imd_Distorted=imds_Corrected;
        for i=1:numel(ImagsCorrected)
        ImagsDistorted{i}=gather(ImagsCorrected{i});
        end
    elseif ~isequal(FlagDistorsion,'yes') 
        imd_Distorted=imd_Expos;
        for i=1:numel(ImagsCorrected)
         ImagsDistorted{i}=gather(ImagsExposCorrect{i});
        end
    end
    %Type 1: Crop1
    tic;
    [imd_Cropped1,SizeRect,ImagsCropped1]=CropRectangleInscribed('Black',ImagsDistorted,fPathCrop1);
    ;Time.TimeCrop=toc;
    %Type 2: Crop2 
    %[imd_Cropped2,SizeRect2,ImagsCropped2]=CropRectangleInscribed('White',imd_Distorted,fPathCrop2);
else
        [imd_Cropped1,ImagsCropped1]=ReadImagGPU(fPathCrop1);
end
    %Overlaps
    %Distance overlap Horizontally
    [distancia,OverlapX]=DISTANCIAS_HORIZONTAL(ImagsCropped1,Rows,Columns);
    %Distance overlap Vertically
    [distancia_v,OverlapY]=DISTANCIAS_VERTICAL(ImagsCropped1,Rows,Columns);

if exist(strcat(fPath,'\ImageRename\'),'dir')==0
    %Rename Images
    
    [RenameImd,fPathRename,ImagsRename]=Rename(ImagsCropped1,fPathRename);
    tic;
    %REGISTER
    %Type 1
    %[ArrayShiftH,ArrayDistH,arrErrorsHor] = Register(1,imd_f,Rows,Columns,OverlapX,OverlapY);
    %Type 2
    [strText]=TileConfiguration('Dft',Rows,Columns,fPathRename,OverlapX,OverlapY,'TileConfiguration_TotalAbeja2_');
    ;Time.TimeRegister=toc;
end
if exist(strcat(fPath,'\ImagStitching\'),'dir')==0
    %STICHING  
    tic;
    I=Stitching(fPathRename,'Imcorr_','average','TileConfiguration_TotalAbeja2_1.txt',Rows,Columns,ImagMatrix,fPathStitching,'Final_Result_average'); 
    ;Time.TimeStitching=toc;
else disp('Stitching done')
end


