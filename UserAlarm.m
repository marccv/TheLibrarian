function [Alarm,recidiva]=UserAlarm(guilt,recidiva,N_map,n_last_idle,firma)
%dichiarare in nodo una variabile recidiva che viene inizializzata a 0 e
%poi cambia quando si entra nel loop

%si identifica la colpevolezza in base al fatto che: nelle precedenti 3
%iterazioni sono stato individuato come colpevole, oppure, in un iterazione
%sono stato individuato come colpevole di un gran numero di picchi (guilt è
%un numero molto alto


% guilt: colpevolezza, viene diretamente dall output di ConfrontMap, se è
% diverso da 0 indica che sono stato inviduato come colpevole. è
% incrementato di uno per ogni picco di cui sono colpevole, contanto tutte
% le stanze in cui vengo additato come tale 

%recidiva: variabile che indica se sono stato indicato come volpevole nei
%cicli precedenti, nel caso io non sia colpevole torna automaticamente a 0;
%non va azzerato!

%alarm: 1 se devo segnalare all'utente, 0 altrimenti.
evidences=fopen('evidences','a+');

 if (guilt>0)
            recidiva=recidiva+max(1,floor(guilt/4));
 elseif (guilt==0) ||( n_last_idle>2 && n_last_idle<10)
            recidiva=recidiva-1;
 elseif n_last_idle>=10 && n_last_idle<30
     recidiva=recidiva-2;
 elseif n_last_idle>=30 
     recidiva=0;
 end
       
        
        if recidiva<0 %mica si puo stare zitti per un ora e poi fare casino e aspettarsi di essere in credito
            recidiva=0;
        %end
        
        elseif recidiva>9
            recidiva=9;
        end
        
        
           
        
        if guilt>=5 %|| recidiva>6 % se o sto facendo tanto casino in una mappa(il numero N_map è arbitrario) o sto facendo casino da tanto tempo
            Alarm=1;
            fprintf(evidences, ' ALARM:\n nodo %d\n guilt=%d\n recidiva=%d\n\n',firma,guilt,recidiva);
        else
            Alarm=0;
        end
end