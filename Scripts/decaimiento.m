T = load('recoleccionEstacionario.txt');
T = T(7,:);

realposic=[4.1 8.6 13.4 17.1 22 29.2 36.4]/100;%en metros
posiciones = nan(length(T),length(realposic)); %matriz de nans de las posiciones de las termocuplas
    for j = 1:length(T)
        posiciones(j,:)=[realposic];%creo la matriz de posiciones 
        %ft(j)=fit(posiciones(j,:)',T(j,:)','exp1');
        %plot(ft(j),posiciones(j,:)',T(j,:)')
        %plot(posiciones(j,:),T(j,:),'.')
        %xlabel('Posición(m)')
        %ylabel('Temperatura(ºC)')
        %hold on
    end

    p100 = posiciones(7,:)
    ft=fit(p100',T','exp1')
    plot(ft,p100,T')
