clear all, clc, close all

% sample=256; %numero di campioni su cui poi andrò a fare la trasformata di fourier
% f_adc= 16000; %frequenza di campionamento, la massima frequenza letta è la metà (cfr Shannon)

% cas = sort(abs(10*rand(1,4)));
% cas = cas + [0:0.5:1.5]; % aggiungo 0.5 a cascata per evitare che siano 
                         % proprio sovrapposti e che si creino dei problemi

cas = [1, 1.5, 2, 2.5];

tempi = {cas(1), cas(2), cas(3), cas(4)};
% disp(tempi)

%           log,       inbox,       outbox
file = {'log1.txt', 'da4a1.txt', 'da1a2.txt';...
        'log2.txt', 'da1a2.txt', 'da2a3.txt';...
        'log3.txt', 'da2a3.txt', 'da3a4.txt';...
        'log4.txt', 'da3a4.txt', 'da4a1.txt'};
    
    
%% dati microfoni

four_tracks    % script che contiene tutto quello che serve per importare e sincronizzare le tracce audio
% tracceElix


% da cambiare nel caso si usi 4tracks o elix:
%threshold_au;
%soglia_amp;
%threshold_guilt


microfoni = data;
%%
clc
fopen('maps1','w+');
fopen('maps2','w+');
fopen('maps3','w+');
fopen('maps4','w+');
fopen('evidences','w+');
format long

%%
parfor i = 1:4
    
    [sourceT{i}, alarm_storia{i}] = nodoMarco4(tempi{i}, file{i,1}, file{i,2}, file{i,3}, microfoni{i}, f_adc);
    
end

%%
sourceT = sourceT{1};

%%
% figure
% 
% plot(time_adc, data_al_adc, time_adc, data_bs_adc)
% hold on
% plot(sourceT(:,1), sourceT(:,2), 'LineWidth', 2)
% ylim([-1 1.1])
% xticks(0:15)
% grid on
% segno = {'o','*','+','x'};
% for i = 1:4
%     
%     plot(alarm_storia{i}(:,1), alarm_storia{i}(:,2), segno{i}, 'LineWidth', 2)
% end
% legend('stanza alta', 'stanza bassa', 'Source tracing attivato', 'led1', 'led2', 'led3', 'led4', 'Location', 'southeast');



