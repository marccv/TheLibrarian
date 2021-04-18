function mappa = broadcastV3(data, tmax, firma, num_nodi, log_handle, inbox_s, outbox_s)

% 
% 
% mappa = BROADCASTV2(data, tmax, firma, num_nodi, log_handle, inbox_s, outbox_s)
%
% -> nuova versione che non facendo uso di writematrix e readmatrix è molto
%    più veloce e può andare in real time
% 
% CONDIVIDE I DATI CON TUTTI I NODI
% 
% mappa        matrice 3D con ultima dimensione che copre i vari nodi
% 
% data         matrice di double da condividere
% tmax         non ancora contemplato
% firma        numero del nodo che la chiama
% num_nodi     numero totale di nodi nella rete
% log_handle   file handle del log già aperto nella funzione nodo.m
% inbox_s      stringa con il nome del file in entrata
% outbox_s     stringa con il nome del file in uscita




    fprintf(log_handle, 'BroadcastV2 ha inizio... ');

    
    % puliamo l'autbox per iniziare
    outbox = fopen(outbox_s,'w');
    fclose(outbox);

    speed = (25e3); % velocità in bit al secondo
    maxit = 1000;
    
    
    % dimensioni delle matrici da condividere, chiaramente devono essere
    % uguali tra tutti i nodi
    [n,m] = size(data);
    
    % output della funzione, una matrice 3D con ultimo indice il numero del
    % nodo che ha prodotto la matrice 2D
    mappa = zeros(n, m, num_nodi);
    
    % inserisco nella matrice i dati del mio nodo
    mappa(:,:,firma) = data;
    
    
    % con questo protocollo ad andello servono sempre questo numero di
    % passaggi e per cui questo numero di slot
    n_slot = 2*num_nodi -2;
    
    % n_pack è il numero di matrici che vengono scambiate all'i-esimo slot,
    n_pack = [1:(num_nodi -1), (num_nodi -1):-1:1];
    

    % dimensione del pacchetto (bit) che contiene il numero massimo di matrici
    % che è il numero di nodi meno 1. Come se fossero numeri di arduino in
    % 10 bit
    size_max = (num_nodi -1) * m*n*10;
    
    
    % tempo per ciascuno slot calcolato con ridondanza sul tempo di
    % trasmissione del paccheto maggiore con dimensione size_max
    t_slot = 1 * size_max /speed;
%     fprintf(log_handle,'il tempo di ciascuno slot è: %f\n', t_slot);
    
    % sembra % Sembra funzionare anche in tempo reale, nella realtà ci vorrebbe una
    % ulteriore ridondanda come moltiplicando per 1.3 e considerando che
    % possono esserci dei pacchetti persi e gestire bene gli errori che
    % possono verificarsi
    
    % ridondanza del 30perc sul tempo dello slot in cui si mandano il
    % maggior numero di pacchetti
    
    
    % serve per dire a fscanf come leggere i numeri, la lunghezza della
    % stringa si adata in base alla matrice da condividere
    format = [];
    
    for j = 1:m
        format = [format, '%f,'];
    end
    
    
    
    
    
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
            
            
%             fprintf(log_handle, 'Sono il nodo %d ed è il mio turno di mandare, i = %d\n', firma, i);
             
            % questi valori di j si trovano a mano vedendo i pattern ce si
            % creano con questa condivisione ad anello: un nodo sa sempre
            % che matrici vengono trasmesse nello slot i-esimo.
            
            k = 0;
            outbox = fopen(outbox_s,'w');
            
            for j = max(1,(i- num_nodi +2)):min(i,num_nodi)
                
                for s = 1:n
                    % scrivo riga per riga la matrice da condividere
                    
                    fprintf(outbox, [format,'\n'], mappa(s,:,j));
                    
                end
                k = k+1;
            end
            

            % DEBUGGING
%             fprintf(log_handle, 'Sono il nodo %d ho mandato %d matrci\n', firma,k);
            
        end
        
        if (mod(i+1,num_nodi) == mod(firma,num_nodi))
            
            % è il mio turno di ricevere: sono il nodo che viene subito
            % dopo nella catena rispetto al nodo che sta mandando
            
            % DEBUGGING
%             fprintf(log_handle, 'Sono il nodo %d ed è il mio turno di ricevere, i = %d\n', firma, i);
            
            % tempo per permettere al nodo trasmittente di finire
            pause(t_slot/2)


            % numero di servizio per verificare che siano lette tutte le
            % matrici che sono state mandate
            a = 0;
            k = 0;
            while (a< n * n_pack(i) && k < maxit)
                inbox = fopen(inbox_s,'r');
                packet = fscanf(inbox, format, [m,Inf]);    % legge il file
                                         % di testo secondo il formato
                                         % specificato nella stringa format
                                         % e crea una matrice di m righe
                                         % (non è ammesso farla già di m
                                         % colonne, per questo poi facciamo
                                         % la trasposta)
                fclose(inbox);
                [~,a] = size(packet);
                k = k + 1;
            end
            
            packet = packet';
            
            k = 0;
            % numero di servizio per leggere matrice per matrice i dati in
            % ingresso
            
            for j = max(1,(i- num_nodi +2)):min(i,num_nodi)
                % stessi j di sopra, sono quelli che il nodo ricevente
                % trova nello slot i
                  
                fprintf('line 172 \n size of the  packet: %d-%d \n indexes %d:%d \n\n',a,size(packet,2),(1+n*k),n*(k+1));
                  
                mappa(:,:,j) = packet((1+n*k):(n*(k+1)),:);
       
                k = k+1;
                % DEBUGGING
%                 fprintf(log_handle, 'Sono il nodo %d ho ricevuto %d matrici\n', firma, k);
            end
            
            % pulisce la inbox
            inbox = fopen(inbox_s,'w');
            fclose(inbox);
            
            
        end
        
        
        % aspetto che lo slot finisca prima di passare a quello successivo
        k = 0;
        while(toc(slot) < i*t_slot)
            pause(1e-3);
            k = k+1;
        end
        
        % DEBUGGING
%         fprintf(log_handle, 'Sono il nodo %d ed è finito lo slot %d aspettando %d ms\n', firma, i, k);
        
    end
    
    fprintf(log_handle, 'BroadcastV2 ha fine\n');
    
    
    


end