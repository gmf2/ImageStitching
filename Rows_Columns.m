function [Rows,Columns]= Rows_Columns(imd_f)

Number=numel(imd_f.Files);
switch Number
   case 2
      Rows=1;
      Columns=1;
   case 4
       Rows=2;
      Columns=2;
    case 9
         Rows=3;
      Columns=3;
    case 16
         Rows=4;
      Columns=4;
    case 25
         Rows=5;
      Columns=5;
    case 36
         Rows=6;
      Columns=6;
    case 49
         Rows=7;
      Columns=7;
    case 56
         Rows=8;
      Columns=8;
    case 81
         Rows=9;
      Columns=9;
    case 100
         Rows=10;
      Columns=10;
    case 121
         Rows=11;
      Columns=11;
    case 144
         Rows=12;
      Columns=12;
    case 169
         Rows=13;
      Columns=13;
    case 196
         Rows=14;
      Columns=14;
    case 225
      Rows=15;
      Columns=15;
    case 256
         Rows=16;
      Columns=16;
    otherwise
        prompt = {'Enter Number of Rows:','Enter Number of Columns:'};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        Rows=str2num(answer{1});
        Columns=str2num(answer{2});
end