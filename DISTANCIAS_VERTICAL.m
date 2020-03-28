function [distancia_v,OverlapY] = DISTANCIAS_VERTICAL(ImagsCropped1,Rows,Columns)
%CARGA INICIAL
%UNION SELECCIONANDO LOS PUNTOS
%Imagen Izquierda
%o1 = imread ('Imcorr_4.jpg');
number=(floor(Rows/2));
if mod(number,2)~=0 && number~=1
    number=number-1;
end
expres=(number*Columns+(Columns-ceil(Columns/4)));
o1 =ImagsCropped1{expres};
%Imagen Derecha
%op = imread ('Imcorr_5.jpg');
op=ImagsCropped1{expres+(Columns-(expres-Columns*number))*2 +1};

%Como no unían bien los puntos lo que he hecho es usar el cp select 
%Para que elija personalmente los puntos y ver si funciona la unión

%Poner pointInput_o1 = 1 para elegir puntos
%Cuando se eligen los puntos se le da a cerrar a la GUI y se quedan
%guardados los puntos.
%Una vez guardados los puntos poner pointInput_o1 = 0 y ejecutar de nuevo 
%para guardarlos
%Elegir 4 puntos

pointInput_o1 = 1;
if(pointInput_o1 == 1)
    h=msgbox('Choose 5 points from each figure. Selection order: 1 left<->1 right','Point Selection');
    waitfor(h);
    [puntos_o1, puntos_op] = cpselect (o1, op, 'Wait', true);
    save ('points_o1.mat', 'puntos_o1', 'puntos_op');
    %save ('points_cc.mat');
    pointInput_o1 = 0;
    if (pointInput_o1 == 0)
          %puntos = load ('points_cc.mat');
          puntos = load ('points_o1.mat');
          puntos_o1 = puntos.puntos_op;
          puntos_op = puntos.puntos_o1;
          %puntos_o1 = puntos.p2;
          %puntos_op = puntos.p1;
    else
        error('Unknown input.');
    end
end



%VER CUAL PUNTO TIENE MAYOR DISTANCIA
%Menor puntos
min_vert=min(size(puntos.puntos_o1),size(puntos.puntos_op));
Results_dist = {};
for i=1:min(1)
    if puntos.puntos_o1(i,1) <= puntos.puntos_op(i,1)+10 || puntos.puntos_o1(i,1) >= puntos.puntos_op(i,1)-10
        Results_dist=(size(o1,2)- puntos.puntos_o1(i,2))+ puntos.puntos_op(i,2);
    end
end

Average_Dist_vert=mean(Results_dist);
OverlapY=Average_Dist_vert/size(op,1);
distancia_v=Average_Dist_vert;

