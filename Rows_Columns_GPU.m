function [Rows,Columns]= Rows_Columns_GPU(imd_f)

Number=numel(imd_f.Files);
switch Number
   case 2
      Rows=gpuArray(1);
      Columns=gpuArray(1);
   case 4
       Rows=gpuArray(2);
      Columns=gpuArray(2);
    case 9
         Rows=gpuArray(3);
      Columns=gpuArray(3);
    case 16
         Rows=gpuArray(4);
      Columns=gpuArray(4);
    case 25
         Rows=gpuArray(5);
      Columns=gpuArray(5);
    case 36
         Rows=gpuArray(6);
      Columns=gpuArray(6);
    case 49
         Rows=gpuArray(7);
      Columns=gpuArray(7);
    case 56
         Rows=gpuArray(8);
      Columns=gpuArray(8);
    case 81
         Rows=gpuArray(9);
      Columns=gpuArray(9);
    case 100
         Rows=gpuArray(10);
      Columns=gpuArray(10);
    case 121
         Rows=gpuArray(11);
      Columns=gpuArray(11);
    case 144
         Rows=gpuArray(12);
      Columns=gpuArray(12);
    case 169
         Rows=gpuArray(13);
      Columns=gpuArray(13);
    case 196
         Rows=gpuArray(14);
      Columns=gpuArray(14);
    case 225
      Rows=gpuArray(15);
      Columns=gpuArray(15);
    case 256
         Rows=gpuArray(16);
      Columns=gpuArray(16);
    otherwise
        prompt = {'Enter Number of Rows:','Enter Number of Columns:'};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        Rows=gpuArray(str2num(answer{1}));
        Columns=gpuArray(str2num(answer{2}));
end