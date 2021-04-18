function [sourceT,alarm_storia] = nodoMarco4(t0, log_s, inbox_s, outbox_s, microfono, f_adc)
    

    
    %inizializzazione simulazioine
    
    log = fopen(log_s, 'w');
    fprintf(log,['ciao ho aperto il file ', log_s,  '\n']);
    fprintf(log,'Ho %d campioni da microfono in totale\n', length(microfono));
    % si aprono i 4 file di communicazione così sono puliti
    outbox = fopen(outbox_s,'w');
    fclose(outbox);
    
    pause(0.2);
    
    % ---------------------
    %  INIZIO SIMULAZIONE
    % ---------------------
    
    
    fprintf(log,['inizia la simulazione ', log_s(4), '\n']);
    %log_s(4) va a pescare il numero corretto nel nome del file del log
    
    
    % aspetto ad accendere
    pause(t0)
    
    tic     % inizia il conteggio del tempo nel nodo, così toc funziona come millis() di arduio
    
    fprintf(log,['sono il nodo ', log_s(4), ' e mi sono acceso\n']);
    % ---------------------
    %   sincronizzazione
    % ---------------------
    
    % voglio cercare anche di condividere quanti nodi ci sono nel network,
    % mi serve dopo nel broadcast
    
    if (dir(inbox_s).bytes == 0) %se nessuno mi ha comunicato di essersi acceso
        
        % sono il primo nodo, inizio a mandare
        fprintf(log,'sono il primo nodo, mando il mio tempo\n');
        
        delta = 0; % serve per il loop di funzionamento così è uguale per tutti i nodi
        firma = 1; % sono il primo nodo
        
        while(dir(inbox_s).bytes == 0)
            
            
            outbox = fopen(outbox_s,'w');
            fprintf(outbox, '%f,%d', toc, firma);
            fclose(outbox);
            
            % perchè l'altro nodo abbia modo di leggere non possiamo
            % mandare e cancellare il pacchetto in continuazione dobbiamo
            % aspettare un attimo

            pause(1e-3) % precisione che otterremo nella sincronizzazione
        
        end
        
        % a questo punto ho iniziato a ricevere, smetto di mandare e
        % aspetto di non ricevere più nulla
        
        fprintf(log,'sono il primo nodo e ho ricevuto qualcosa\n');
        
        inbox = fopen(inbox_s,'r');
        packet = fscanf(inbox, '%f,%d');
        fclose(inbox);
        inbox = fopen(inbox_s, 'w');
        fclose(inbox);
        
        num_nodi = packet(2);
        errore = toc - packet(1);
        clear packet;
        
        fprintf(log, 'sono il primo nodo e in totale ci sono %d nodi con errore di sinc max %f\n', num_nodi, errore);
        
        % mando un pacchetto vouto per segnalare il passaggio di stato
        outbox = fopen(outbox_s,'w');
        fclose(outbox);
        
        while(dir(inbox_s).bytes ~=0 || dir(inbox_s).bytes ~=0) %raddoppio
            %la condizione per evitare il caso il cui vedo che è zero proprio 
            %nel momento il cui quello che manda sta aprendo il pacchetto e
            %per cui è vuoto anche se è ancora nella fase di invio
            pause(1e-2)
        end
        
        fprintf(log,'sono il primo nodo e sto per mandare oraX e numero tot di nodi\n');        
        pause(1)
        % comunico che iniziamo tra tot secondi all' ora X e il numero di
        % nodi
        
        pausaX = 0.2;
        oraX = toc + pausaX;
        
        
        outbox = fopen(outbox_s,'w');
        fprintf(outbox, '%f,%d', oraX, num_nodi);
        fclose(outbox);
        
        fprintf(log,'sono il primo nodo e ho detto che l oraX è %f\n', oraX);
        
        while(toc + delta < oraX)
            pause(1e-3)
        end
        
        
    else
        
        % non sono il primo nodo, calcolo delta e inizio a mandare il tempo
        % ormai già sincronizzato al resto della catena
        
        inbox = fopen(inbox_s,'r');
        packet = fscanf(inbox, '%f,%d');
        fclose(inbox);
        inbox = fopen(inbox_s, 'w');
        fclose(inbox);
%debugging
fprintf('size packet: %d\n\n',size(packet()));

        delta = packet(1) - toc;
        firma = packet(2) +1;
        clear packet
        
        fprintf(log,'sono il nodo %d la mia differenza di tempo è %f\n',firma, delta);
        
        pause(0.2)
        
        while (dir(inbox_s).bytes ~= 0 || dir(inbox_s).bytes ~= 0) %raddoppio
            %la condizione per evitare il caso il cui vedo che è zero proprio 
            %nel momento il cui quello che manda sta aprendo il pacchetto e
            %per cui è vuoto anche se è ancora nella fase di invio
            
            
            outbox = fopen(outbox_s,'w');
            fprintf(outbox, '%f,%d', toc + delta,firma);
            fclose(outbox);
            
            % perchè l'altro nodo abbia modo di leggere non possiamo
            % mandare e cancellare il pacchetto in continuazione dobbiamo
            % aspettare un attimo
            
            pause(1e-2) % precisione che otterremo nella sincronizzazione
            
            
        end
        
        
        % ho smesso di ricevere > smetto di mandare, aspetto l'oraX in
        % arrivo e la inoltro
        
        % mando un pacchetto vouto per segnalare il passaggio di stato
        outbox = fopen(outbox_s,'w');
        fclose(outbox);
        
        fprintf(log,'sono il nodo %d aspetto dati su oraX e numero totale di nodi\n', firma);
        
        while(dir(inbox_s).bytes == 0)
            pause(1e-2)
        end
        
        inbox = fopen(inbox_s,'r');
        packet = fscanf(inbox, '%f,%d');
        fclose(inbox);
        inbox = fopen(inbox_s, 'w');
        fclose(inbox);
        
        oraX = packet(1);
        num_nodi = packet(2);
        
        outbox = fopen(outbox_s,'w');
        fprintf(outbox, '%f,%d', oraX, num_nodi);
        fclose(outbox);
        
        % aspetto l'oraX per iniziare
        fprintf(log,'sono il nodo %d di %d e aspetto oraX: %f\n',firma, num_nodi, oraX);
        
        while(toc + delta < oraX)
            pause(1e-3)
        end
        
    end
    
    % ----------------
    % BACKGROUND NOISE
    % ----------------
    
    t_findnoise = 1;
    N_noisesamples = 50;
    sample = 256;   
    noiseFT = zeros(sample/2,1);
    
    fprintf(log,'\nInizio ricerca background noise... ');
    
    for i = 1:N_noisesamples
        
        [noiseSample,~, flag] = ListenSample(sample,f_adc,microfono,ceil(f_adc*(toc + delta - oraX)),log);
        if (flag)
            return;
        end
        
        [~,temp,~] = FourierT(noiseSample,sample,f_adc);

        %media degli spettri
       % fprintf('noiseFT size: %d--\n tempsize: %d\n\n',length( noiseFT),length(temp));
        
        noiseFT = noiseFT + temp/N_noisesamples;
        
    end
      
    k = 0;
    while (toc+delta < oraX +t_findnoise)
        pause(1e-3)
        k = k+1;
    end
    fprintf(log,'fine ricerca aspettando %d ms\n', k);
        
    
    
    % ----------------
    %      loop
    % ----------------
    
    t_idle = 0.04;     % tempo per la sezione idle
    t_st = 0.3;       % tempo per la sezione Source Tracing
    
%    soglia_amp = 0.013;%elix % soglia sulle intesità sonore
   soglia_amp=0.13; %4tracks % soglia sulle intesità sonore
%     threshold_au = 1e-7;  %elix    % soglia sulle frequenze per essere messe nella mappa
   threshold_au=1e-5; %4traks %soglia sulle frequenze per essere messe nella mappa

    n_top = 10;         % numero di campioni tra i quali trovo il massimo
                        % per poi fare la media tra n_max massimi
                        
    n_max = 10;         % così si ha una risoluzione di 31 ms
    
    N_map = 6;
    
    fine = length(microfono)/f_adc - 0.5 + oraX - delta;
    
    sourceT = zeros(ceil(length(microfono)/(f_adc*t_idle)), 2);
    alarm_storia = zeros(ceil(length(microfono)/(f_adc*(t_idle+t_st))),4);
    
    i = 0;
    n_cicli_st = 0;
    n_last_idle = 0;
    
    t_loop = toc + delta;
    
    recidiva = 0;
    
    while(1)
        
        if toc > fine
            return
        end
        
        i = i+1;
        n_last_idle = n_last_idle + 1;
        % ----------------
        %      IDLE
        % ----------------
        
        
        fprintf(log, '\nciao sono il nodo %d inizio ciclo IDLE - tempo: %f\n', firma, toc + delta);
        
        % ascolta per un tot di tempo e fa la media delle intensità
        
        int_media = 0;
        
        for j = 1:n_max
            
            [data_sample,~, flag]=ListenSample(n_top,f_adc,microfono,ceil(f_adc*(toc + delta - oraX)),log);
            
            if (flag)
                return;
            end
            
            int_media = int_media + max(abs(data_sample))/n_max;
            
        end
        
        fprintf(log, 'ciao sono il nodo %d - tempo: %f, ho letto %d samples con media  %f\n'...
                ,firma, (toc + delta), length(data_sample), int_media);
        
        % decide se l'intensità è sopra soglia
        
        sopra_soglia = int_media > soglia_amp;
        
        % Broadcast del risultato (broadcast01)
        
        mappa = broadcast01_V2(sopra_soglia,[],firma, num_nodi, log, inbox_s, outbox_s, delta);
        
        % Decide se andare in source tracing
        
        st = sum(mappa) > 0;     % per decidere se entrari in source tracing
        fprintf(log, 'ciao sono il nodo %d - tempo: %f, Source Tracing = %d\n', firma, toc + delta, st);
        
        sourceT(i,:) = [toc+delta - oraX, st];
        
        
        % Aspetta la fine dello slot di idle
        % questo modo di aspettare la fine è più preciso
        
        k = 0;
        while(toc + delta -t_loop < i*t_idle + n_cicli_st*t_st)
            pause(1e-3);
            k = k+1;
        end
        fprintf(log, 'ciao sono il nodo %d è finito il ciclo IDLE aspettando %d ms\n', firma, k);
        
        % ----------------
        %  SOURCE TRACING
        % ----------------
        
        if (st)
            fprintf(log, 'ciao sono il nodo %d entro in SOURCE TRACING\n', firma);
            n_cicli_st = n_cicli_st +1;

            % sampling
            
            [suono,~, flag] = ListenSample(sample,f_adc,microfono,ceil(f_adc*(toc + delta - oraX)),log);
            if (flag)
                return;
            end
            
            % FFT
            
            [freq,FT,deltaF] = FourierT(suono,sample,f_adc);

            % filtering
            
            FT = Filtering(FT,freq,noiseFT);

            % Map broadcast (broadcastV3)
            
%             picchi = randi(1024,2,6);

            picchi = BuildMap2(freq,FT,sample,N_map,threshold_au,firma);

            mappa = broadcastV3(picchi, [], firma, num_nodi, log, inbox_s, outbox_s);
            
            fprintf(log, 'Ho ricevuto un mappa di dimensioni %d %d %d\n', size(mappa));

            % comparison
            
            guilt=ConfrontMap_diff(mappa,N_map,firma,deltaF);
            fprintf(log, 'colpevolezza = %d, recidiva = %d\n', guilt, recidiva);

            % notification
            
            [alarm,recidiva] = UserAlarm2(guilt,recidiva,N_map,n_last_idle,firma);
            fprintf(log, 'ALARM = %d !!! recidiva = %d\n', alarm, recidiva);
            
            alarm_storia(n_cicli_st,:) = [toc+delta - oraX, alarm, guilt, recidiva];

            % aspetta la fine dello slot di source tracing
            k = 0;
            while(toc + delta -t_loop < i*t_idle + n_cicli_st*t_st)
                pause(1e-3);
                k = k+1;
            end
            fprintf(log, 'ciao sono il nodo %d è finito il SOURCE TRACING aspettando %d ms\n', firma, k);
            n_last_idle = 0;
            
        end
        
    end
    
    return
    
end