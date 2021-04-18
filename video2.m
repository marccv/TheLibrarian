 close all, clc, %clear
% load('Alarm_story_4tracks_completo.mat')
%%

led1 = alarm_storia{1};
led1(led1(:,1) == 0,:) =[]; 

led2 = alarm_storia{2};
led2(led2(:,1) == 0,:) =[]; 

led3 = alarm_storia{3};
led3(led3(:,1) == 0,:) =[];

led4 = alarm_storia{4};
led4(led4(:,1) == 0,:) =[]; 


%%

importfile('4_tracce/controllo.m4a');
data_ctrl = data; 

clear data;

importfile('4_tracce/babbo.m4a');
data_babbo = data(:,1);

clear data;

importfile('4_tracce/andrea.m4a');
data_andrea = data;

clear data;

importfile('4_tracce/marco.m4a');
data_marco = data;

clear data;
fs = 48000;

% Sincronizzo tagliando dei segmenti all'inizio

data_ctrl = data_ctrl(849674:end);
data_andrea = data_andrea(10998:end);
data_marco = data_marco(15788:end);

data = {data_ctrl;data_babbo;data_andrea;data_marco};

% rendo tutti i vettori della stessa lunghezza tagliando alla fine

l1 = length(data{1});
l2 = length(data{2});
l3 = length(data{3});
l4 = length(data{4});

stop = min([l1 l2 l3 l4]);
% stop = floor(min([l1 l2 l3 l4])/3);
clear l1 l2 l3 l4

data_ctrl = data_ctrl(1:stop);
data_babbo = data_babbo(1:stop);
data_andrea = data_andrea(1:stop);
data_marco = data_marco(1:stop);

 % per analisi piu mirata

data_start=6100000;
data_end=9630260;
stop=data_end-data_start;



data_ctrl = data_ctrl(data_start:data_end);
data_babbo = data_babbo(data_start:data_end);
data_andrea = data_andrea(data_start:data_end);
data_marco = data_marco(data_start:data_end);


% Riduco la frequenza di campionamento

% fattore = 3;
fattore = 6;

data_ctrl = data_ctrl(1:fattore:end);
data_babbo = data_babbo(1:fattore:end);
data_andrea = data_andrea(1:fattore:end);
data_marco = data_marco(1:fattore:end);

data = {data_ctrl;data_babbo;data_andrea;data_marco};


f_adc = fs/fattore;
T_adc = 1/f_adc;



time_adc = 0:T_adc:(stop/fattore - 1) *T_adc;

%%


range = 2;
v = -range:0.5:range;


f = figure;
set(f, 'color', [1 1 1]);
set(f, 'Position', [200 150 1500 700])

fps = 10;
durata = time_adc(end);
numFrame = floor(fps*durata);

centro = 2*f_adc;

step = (1/fps) *f_adc;
estremi = range *f_adc;

tempi_plot = linspace(-range, range, 2*estremi);

% led = rand(1,4) > 0.5;
% circle;  % script che crea un cerchio nella variabile cerchio

lum = zeros(4,1);
guilt = zeros(4,1);
recidiva = zeros(4,1);


dec1 = 0.3;
dec2 = 10;

%%

for index = 1:numFrame
    clf
    
    time = centro/f_adc;
    
    t = tiledlayout(6,8);
    title(t, ['Time = ', num2str(time,'%.4f'), ' s'], 'FontSize' , 17);
    
    
    % LED 1
    led1_ax = nexttile([3 1]);
    A = ones(1,1,3);
    
    mask = led1(:,1) < time;
    
    passati = led1(mask,:);
    
    if size(passati, 1) >0
        
        guilt(1) = passati(end,3);
        recidiva(1) = passati(end,4);
        
    end
        
    if size(passati,1)> 0 && passati(end,2)
        lum(1) = 100;
        % devo cancellare quell'ultimo uno che ho già acceso
        passati(end,2) = 0;
        led1(mask,:) = passati;
    end
    
    if(lum(1) > 99)
        
        A = circle(lum(1));
        lum(1) = lum(1) - dec1;
        
    elseif (lum(1) > 0)
        A = circle(lum(1));
        lum(1) = lum(1) - dec2;
    end
    image(A)

    set(gca,'visible','off')
    annotation('textbox',...
    [0.0793333333333322 0.584285714285714 0.0626666666666662 0.33],...
    'String',{['Guilt = ', num2str(guilt(1))], ['Recidiva = ', num2str(recidiva(1))],...
    '','','','','','','','','','     LED 1'},...
    'LineStyle','none',...
    'FontSize',15,...
    'FitBoxToText','off');

    
    
    
    
    % STANZA 1
    nodo1 = nexttile([3 3]);
    plot(tempi_plot, data{1}((centro-estremi+1):(centro+estremi)) )
    title('stanza 1', 'FontSize', 13)
    xticks(v)
    xlabel('Relative time (s)')
    ylim([-1 1]);
    grid on
    xline(0, 'LineWidth', 1.5, 'Color', '#EDB120');

    % STANZA 2
    nodo2 = nexttile([3 3]);
    plot(tempi_plot, data{2}((centro-estremi+1):(centro+estremi)))
    title('stanza 2', 'FontSize', 13)
    xticks(v)
    xlabel('Relative time (s)')
    ylim([-1 1]);
    grid on
    xline(0, 'LineWidth', 1.5, 'Color', '#EDB120');

    % LED 2
    led2_ax =nexttile([3 1]);
    A = ones(1,1,3);
    
    mask = led2(:,1) < time;
    
    passati = led2(mask,:);
    
    if size(passati, 1) >0
        
        guilt(2) = passati(end,3);
        recidiva(2) = passati(end,4);
        
    end
        
    if size(passati,1)> 0 && passati(end,2)
        lum(2) = 100;
        % devo cancellare quell'ultimo uno che ho già acceso
        passati(end,2) = 0;
        led2(mask,:) = passati;
    end
    
    if(lum(2) > 99)
        
        A = circle(lum(2));
        lum(2) = lum(2) - dec1;
        
    elseif (lum(2) > 0)
        A = circle(lum(2));
        lum(2) = lum(2) - dec2;
    end
    image(A)
    
    set(gca,'visible','off')
    annotation('textbox',...
    [0.859333333333333 0.584285714285714 0.0626666666666662 0.33],...
    'String',{['Guilt = ', num2str(guilt(2))], ['Recidiva = ', num2str(recidiva(2))],...
    '','','','','','','','','','     LED 2'},...
    'LineStyle','none',...
    'FontSize',15,...
    'FitBoxToText','off');
    

    % LED 3
    led3_ax = nexttile([3 1]);
    A = ones(1,1,3);
    
    mask = led3(:,1) < time;
    
    passati = led3(mask,:);
    
    if size(passati, 1) >0
        
        guilt(3) = passati(end,3);
        recidiva(3) = passati(end,4);
        
    end

        
    if size(passati,1)> 0 && passati(end,2)
        lum(3) = 100;
        % devo cancellare quell'ultimo uno che ho già acceso
        passati(end,2) = 0;
        led3(mask,:) = passati;
    end
    
    if(lum(3) > 99)
        
        A = circle(lum(3));
        lum(3) = lum(3) - dec1;
        
    elseif (lum(3) > 0)
        A = circle(lum(3));
        lum(3) = lum(3) - dec2;
    end
    image(A)
    
    set(gca,'visible','off')
    annotation('textbox',...
    [0.0793333333333322 0.135714285714286 0.0626666666666662 0.33],...
    'String',{['Guilt = ', num2str(guilt(3))], ['Recidiva = ', num2str(recidiva(3))],...
    '','','','','','','','','','     LED 3'},...
    'LineStyle','none',...
    'FontSize',15,...
    'FitBoxToText','off');
    
    
    % STANZA 3
    nodo3 = nexttile([3 3]);
    plot(tempi_plot, data{3}((centro-estremi+1):(centro+estremi)))
    title('stanza 3', 'FontSize', 13)
    xticks(v)
    xlabel('Relative time (s)')
    ylim([-1 1]);
    grid on
    xline(0, 'LineWidth', 1.5, 'Color', '#EDB120');

    % STANZA 4
    nodo4 = nexttile([3 3]);
    plot(tempi_plot, data{4}((centro-estremi+1):(centro+estremi)))
    title('stanza 4', 'FontSize', 13)
    xticks(v)
    xlabel('Relative time (s)')
    ylim([-1 1]);
    grid on
    xline(0, 'LineWidth', 1.5, 'Color', '#EDB120');

    % LED 4
    led4_ax = nexttile([3 1]);
    A = ones(1,1,3);
    
    mask = led4(:,1) < time;
    
    passati = led4(mask,:);
    
    if size(passati, 1) >0
        
        guilt(4) = passati(end,3);
        recidiva(4) = passati(end,4);
        
    end
        
    if size(passati,1)> 0 && passati(end,2)
        lum(4) = 100;
        % devo cancellare quell'ultimo uno che ho già acceso
        passati(end,2) = 0;
        led4(mask,:) = passati;
    end
    
    if(lum(4) > 99)
        
        A = circle(lum(1));
        lum(4) = lum(4) - dec1;
        
    elseif (lum(4) > 0)
        A = circle(lum(4));
        lum(4) = lum(4) - dec2;
    end
    image(A)
    
    set(gca,'visible','off')
    annotation('textbox',...
    [0.859333333333333 0.135714285714286 0.0626666666666662 0.33],...
    'String',{['Guilt = ', num2str(guilt(4))], ['Recidiva = ', num2str(recidiva(4))],...
    '','','','','','','','','','     LED 4'},...
    'LineStyle','none',...
    'FontSize',15,...
    'FitBoxToText','off');

    centro = centro + step;
%     pause(1/fps)

    movieVector(index) = getframe(f);%, [220 170 1480 680]);
    fprintf('frame: %d\n', index);
    
end

%%


film = VideoWriter('librarian4traks_parte2',  'MPEG-4');
film.FrameRate = fps;

open(film);
writeVideo(film, movieVector)
close(film);


