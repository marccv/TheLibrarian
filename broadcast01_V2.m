function mappa = broadcast01_V2(data, tmax,firma, num_nodi,log_handle, inbox_s, outbox_s,delta)

% 
% 
% mappa = BROADCAST01(data, tmax,firma, num_nodi,log_handle, inbox_s, outbox_s, delta)
% 
% CONDIVIDE UN SINGOLO UNSIGNED INTEGER CON TUTTI I NODI
% 
% mappa        vettore con il valore del nodo firma all'indice firma (fir-
%              ma è un numero da 1 al numero di nodi).
% 
% data         numero intero unsigned da condividere
% tmax         non ancora contemplato
% firma        numero del nodo che la chiama
% num_nodi     numero totale di nodi nella rete
% log_handle   file handle del log già aperto nella funzione nodoMarco.m
% inbox_s      stringa con il nome del file in entrata
% outbox_s     stringa con il nome del file in uscita
% delta        differenza di tempo per sincronizzazione (serve solo per il
%              debugging)




    fprintf(log_handle, 'Broadcast01 ha inizio... ');

    
    
    % puliamo l'autbox per iniziare
    outbox = fopen(outbox_s,'w');
    fclose(outbox);

    speed = (25e3); % velocità in bit al secondo
    
    maxit = 1000;

    
    % output della funzione, vettore con il valore del nodo firma all'indice firma (fir-
    % ma è un numero da 1 al numero di nodi).
    mappa = zeros(num_nodi,1);
    
    % inserisco nel vettore i dati del mio nodo
    mappa(firma) = data;
    
    
    % con questo protocollo ad andello servono sempre questo numero di
    % passaggi e per cui questo numero di slot
    n_slot = 2*num_nodi -2;
    
    % n_pack è il numero di numeri che vengono scambiate all'i-esimo slot
    n_pack = [1:(num_nodi -1), (num_nodi -1):-1:1];
    

    % dimensione del pacchetto (bit) che contiene il numero massimo di matrici
    % che è il numero di nodi meno 1. Come se fossero numeri di arduino in
    % 10 bit
    size_max = (num_nodi -1) *10;
    
    
    % tempo per ciascuno slot calcolato con ridondanza sul tempo di
    % trasmissione del paccheto maggiore con dimensione size_max
    t_slot = 1 * size_max /speed;
%     fprintf(log_handle,'il tempo di ciascuno slot è: %f\n', t_slot);
    
    % Sembra funzionare anche in tempo reale, nella realtà ci vorrebbe una
    % ulteriore ridondanda come moltiplicando per 1.3 e considerando che
    % possono esserci dei pacchetti persi e gestire bene gli errori che
    % possono verificarsi
    
    % ridondanza del 30perc sul tempo dello slot in cui si mandano il
    % maggior numero di pacchetti
    
    
    % iniziano i vari slot temporali che se va tutto bene sono sincroni tra
    % tutti i nodi
    
    
    %inizia il tempo del broadcast
    slot = tic;
    
    for i = 1:n_slot
        
        if (mod(i,num_nodi) == mod(firma,num_nodi))
            
            % è il mio turno di mandare
            % siccome quando si va ad anello quando il numero di slot
            % supera il numero di nodi si rincomincia da capo. Il secondo
            % mod server per gestire la firma 4 (num_modi), resto che è
            % impossibile ottenere
            
            %DEBUGGING
%             fprintf(log_handle, 'Sono il nodo %d ed è il mio turno di mandare, i = %d\n', firma, i);
%             fprintf(log_handle, 'ciao sono il nodo %d - tempo: %f\n', firma, toc + delta);           
            
            % questi valori di j (riga 100) si trovano a mano vedendo i pattern che si
            % creano con questa condivisione ad anello: un nodo sa sempre
            % che matrici vengono trasmesse nello slot i-esimo.
            
            k = 0;
            outbox = fopen(outbox_s,'w');
            
            for j = max(1,(i- num_nodi +2)):min(i,num_nodi)

                % scrivo i numeri che devo mandare
                fprintf(outbox, '%d\n', mappa(j));
                
                k = k+1;
                
            end
            fclose(outbox);
            
            %DEBUGGING
%             fprintf(log_handle, 'Sono il nodo %d ho mandato %d matrci\n', firma,k);
            
        end
        
        if (mod(i+1,num_nodi) == mod(firma,num_nodi))
            
            % è il mio turno di ricevere: sono il nodo che viene subito
            % dopo nella catena rispetto al nodo che sta mandando
            
            %DEBUGGING
%             fprintf(log_handle, ['Sono il nodo %d ed è il mio turno di ricevere dal file ',inbox_s, ' i = %d\n'], firma, i);
%             fprintf(log_handle, 'ciao sono il nodo %d - tempo: %f\n', firma, toc + delta);
            
            % tempo per permettere al nodo trasmittente di finire
            pause(t_slot/2)

            
            
            a = 0;  % numero di servizio per verificare che si leggano tutti
                    % i dati che sono stati trasmessi
            k = 0;
            while (a < n_pack(i) && k < maxit)   % n_pack era il numero di interi scambiati
                                    % nello slot i-esimo
                inbox = fopen(inbox_s,'r');
                packet = fscanf(inbox, '%u');
                fclose(inbox);
                a = length(packet);
                
                k = k +1;
            end
            
            % DEBUGGING
%             fprintf(log_handle, 'Sono il nodo %d ho ricevuto %d \n', firma, packet(1));
            
            % metto al posto giusto i numeri appena ricevuti, vedi riga 100
            
            fprintf('line 148\n size of the packet: %d\n size of n_pack(i): %d \n size of the attributed map:%d:%d\n',a,n_pack(i), max(1,(i- num_nodi +2)),min(i,num_nodi));
            fprintf('iterazione:%d \n\n',i);
            
            
            mappa(max(1,(i- num_nodi +2)):min(i,num_nodi)) = packet;
            
            
            % pulisce la inbox
            inbox = fopen(inbox_s,'w');
            fclose(inbox);
            clear packet
            
            
        end
        
        
        % aspetto che lo slot finisca prima di passare a quello successivo
        k = 0;
        while(toc(slot) < i*t_slot)
            pause(1e-3);
            k = k+1;
        end
        
%         fprintf(log_handle, 'Sono il nodo %d ed è finito lo slot %d aspettando %d ms\n', firma, i, k);
        
    end
    
    fprintf(log_handle, 'Broadcast01 ha fine\n');
    
    
    


end