function guilt=ConfrontMap_diff(MapMatrix,N_map,firma,deltaF)
%soglia sulla colpevolezza, se il suono che percepisco non è sufficientemente rumoroso, non può essere lui la cuasa di disturbo, elimina rumore bianco di lieve entità
% threshold_guilt=1e-3; %elix
threshold_guilt=1e-5; %4tracks
nn=0;
guilt=0; %ognuno è innocente fino a prova contraria

evidences=fopen('evidences','a+');

for peak=1:N_map %prendo la mappa del mio nodo, e mi centro su un picco ad una data frequenza
    
    %individuo nella matrice tutte le frequenze identiche,eventualmente la
    %condizione si può allentare e cercare tutte le frequenze simili                                         
    mask_peak=(MapMatrix==MapMatrix(peak,2,firma)| MapMatrix==(MapMatrix(peak,2,firma)+deltaF) | MapMatrix==(MapMatrix(peak,2,firma)-deltaF) ); 
    mask_peak(:,1,:)=mask_peak(:,2,:); %now the mask takes into account also the amplitudes and not only the frequencies
    mask_peak(:,:,firma)=0;
    mask_peak(:,2,:)=0; %per fare uscire direttamente il vettore
    MapMatrix_peak=MapMatrix(mask_peak);
    
    
    local_amp=MapMatrix(peak,1,firma);
    
    %fprintf(evidences, 'nodo: %d \n local_amp: %f maxMM: %f \n\n', firma, local_amp,max(MapMatrix_peak(:,1,:)));
    
    %fprintf(evidences,'mask_peak:\n');
    
    %fprintf(evidences,'%d', mask_peak);
    
    
    if (max(MapMatrix_peak(:,1,:))<local_amp) & (abs(local_amp-max(MapMatrix_peak(:,1,:)))>=threshold_guilt)%se, considerando tutti i nodi che risentono di quella frequenza, il mio è il picco maggiore, appost
        
        dist=sum(sum(mask_peak,'all')); 
        
        guilt=guilt+dist;  % volendo si puo imporre una soglia tipo molto minore per evitare di segnalare rumore comune
    
        fprintf(evidences,' Node:%d\n guilt assigned for the frequency: %f \n amplitude of the peak: %f\n',firma,MapMatrix(peak,2,firma),local_amp);
        fprintf(evidences, 'other amplitudes of such peak:%f\n\n\n', MapMatrix(mask_peak));
        fprintf('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n\n');
       
    end
end

    
    
   % for nn=1:N_nodes %cerco in tutte le altre mappe
        
       % if MapMatrix(peak,2,firma)==MapMatrix(peak,2,nn) && MapMatrix(peak,1,firma)>MapMatrix(peak,1,nn) %se la frequenza è la stessa e il picco è più alto
           % guilt=guilt+1; %aumenta di uno per ogni stanza che risente di quel picco e per ogni picco
            %break; %non ha piu senso, per questo nodo, cercare questa frequenza
       % end
        
      %  if MapMatrix(peak,2,firma)<MapMatrix(peak,2,nn)
       %     break; % non ha piu senso cercare in questo nodo,la mia frequenza è più bassa
       % end 
    %end

end


