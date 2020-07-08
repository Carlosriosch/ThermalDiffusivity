inst1 = visa('ni','GPIB0::9::INSTR');
fopen(inst1);
%%
ScanInterval = 5;% ? Delay (in secs) between scans.... entre cada tanda aguanto 5 segundos
numberScans = 1000;% ? mido T en cada termocupla x veces 
channelDelay = 0.2;% ? Delay (in secs) between relay closure and measurement... 
%los contactores del multiflexor tardan un poco en cerrarse.. casi 0.2 segundos.. 
%defino esto para que no halla error
scanList= '(@101,102,103,104,105,106,107)';%List of channels to scan in each scan
%%
%set the channel list to scan
str=sprintf('ROUTE:SCAN %s',scanList); %linkeo pc on robot
fprintf(inst1,str);

j=query(inst1,'ROUTE:SCAN:SIZE?');% le pido la cantidad de canales 
ncanales=str2double(j);%defino la cantidad de canales

fprintf(inst1,'FORMAT:READING:CHAN ON');%" ? Return channel number with each reading
fprintf(inst1,'FORMAT:READING:TIME ON');%"? Return time stamp with each reading
fprintf(inst1,'FORMAT:READING:TIME:TYPE REL');% tiempo relativo. Pongo el 0 en el origen de la medición.
%fprintf(inst1,'FORMAT:READING:TIME:TYPE ABS');%"? Return time stamp absolute

%%
%? Set the delay (in seconds) between relay closure and measurement
str=sprintf('ROUT:CHAN:DELAY %2.1f , %s',channelDelay,scanList);
fprintf(inst1,str);

% ? Number of scan sweeps to measure 
str=sprintf('TRIG:COUNT %d',numberScans);% el trigger suena por cada tanda de mediciones. 
%Mido una tanda de termocuplas, suena el plifs! y de nuevo vuelve a medir.
fprintf(inst1,str);
%%
%??wtf
fprintf(inst1,'TRIG:SOUR TIMER');

% Delay (in secs) between scans
str=sprintf('TRIG:TIMER %1.1f',ScanInterval);
fprintf(inst1,str);
%%

%START OF ONE SCAN LOOP

%start scan
j=query(inst1,'INIT;:SYSTEM:TIME:SCAN?'); %estas escaneando?

%wait to the end of the scan 
%pause(.5+(channelDelay+0.1)*ncanales);
pause(2); %pausa entre cada escaneo
%%

%query number of datapoints per scan
%strNdata=query(inst1,'DATA:POINTS?'); %cuantos puntos vas a escanear?
%Ndata=str2double(strNdata); %rta



%%

%strNdata=query(inst1,'DATA:POINTS?'); %cuantos puntos tenes en memoria?
%Ndata=str2double(strNdata);

% hago un array vacio para todos los datos que planeo medir
Ndata=ncanales*numberScans;%data TOTAL
DATA=nan(Ndata,1);
TIME=nan(Ndata,1);
CHAN=nan(Ndata,1);

indata=0;

while(indata<Ndata) %indata es la dara hasta ahora.. Tenes data?
    strNdata=query(inst1,'DATA:POINTS?');%SI!.. le pido los datapoints
    dataAvailable=str2double(strNdata); %me dan los datapoints
    if(dataAvailable>0)
        str=query(inst1,'DATA:REMOVE? 1');%de todos los datos que tengo, mostrame uno y mandamelo abajo de todo
        data=sscanf(str,'%f,%f,%f'); %ese dato ES una ronda de medición. Osea, cada elemento es un dato de cada termocupla.
        %data(1) contains the measurement 
        %data(2) contains the time from the scan start
        %data(3) contains the number of channel
        DATA(indata+1)=data(1);        
        TIME(indata+1)=data(2);        
        CHAN(indata+1)=data(3);             
        indata=indata+1;
        pause(0.05); % por si las moscas
    end

 
    figure(1)
    datainfo=(reshape(DATA,ncanales,length(DATA)/ncanales))' % ahora es una matriz más bonita
    timeinfo=(reshape(TIME,ncanales,length(TIME)/ncanales))'
    plot(timeinfo,datainfo)
    xlabel('time(seg)')
    ylabel('temperatura(ºC)')
    legend('Ch. 1','Ch. 2','Ch. 3','Ch. 4','Ch. 5','Ch. 6','Ch. 7','Location','best')
    
    
    posiciones = nan(length(datainfo),ncanales); %matriz de zeros de las posiciones de las termocuplas
    for i = 1:ncanales
        posiciones(i,:)=[1:ncanales];%creo la matriz de posiciones
    end
    
    figure(2)
    plot(posiciones,datainfo,'rs')
    xlabel('posiciones')
    ylabel('temperatura(ºC)')
    save('recoleccionEstacionario_bis.txt','datainfo','timeinfo','-ascii')

end

%%
gf = visa('ni','USB0::0x0699::0x0346::C034167::INSTR');
fopen(gf);
%%
datainfo=(reshape(DATA,ncanales,length(DATA)/ncanales))'; % ahora es una matriz más bonita    
timeinfo=(reshape(TIME,ncanales,length(TIME)/ncanales))';

plot(timeinfo,datainfo)
    

%%

%fprintf(inst1,'ABORT'); este comando aborta la medicion
%strNdata=query(inst1,'DATA:POINTS?') este comando cuenta los datos en el
%multiplexor
%strNdata=query(inst1,'DATA:REMOVE? 136') este comando borra la cantidad de
%datos en el multiplexor por ejemplo 136
        
            