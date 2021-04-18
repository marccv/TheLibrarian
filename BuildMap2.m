function Map=BuildMap2(freq,FT,sample,N_map,threshold_au,firma)
Map=zeros(N_map,2);
n=0;%ci impedisce di avere problemi el caso avessimo riempito tutto il vettore da inviare, trascuriamo alte frequenze

FT_ord=[FT,freq',(1:(sample/2))']; %con la 3 colonna mi salvo gli indici in modo da poter trovare un collegamento tra la FT e la FT_ord

FT_ord=sortrows(FT_ord,1,'descend');

for ii=1:sample/2
%     if FT_ord(ii)>threshold_au && (FT(FT_ord(ii,3)))>FT(min(FT_ord(ii,3)+1,sample/2)) && (FT(FT_ord(ii,3)))>max(1,FT(FT_ord(ii,3)-1))
    if FT_ord(ii)>threshold_au && (FT(FT_ord(ii,3)))>(FT(FT_ord(ii,3)+1)) && (FT(FT_ord(ii,3)))>(FT(FT_ord(ii,3)-1))
        Map(n+1,1)=FT_ord(ii,1);
        Map(n+1,2)=FT_ord(ii,2);
        n=n+1;
        
        if(n>=N_map)
            break;
        end
        
    end
end

switch firma
    case 1
        maps=fopen('maps1','a+');
    case 2 
        maps=fopen('maps2','a+');
    case 3 
        maps=fopen('maps3','a+');
    case 4
        maps=fopen('maps4','a+');
    otherwise 
        fprintf('NO FIRMA FOUND\n\n');
end

        
        
fprintf(maps,'sono entrato in source tracing, costruisco mappa\n');
fprintf(maps,'nodo %d: \n ',firma);
fprintf(maps,'mappa: Freq/Amp\n');
fprintf(maps, '%f ',Map(:,2));
fprintf(maps,'\n');
fprintf(maps,'%f ',Map(:,1));
fprintf(maps,'\n\n');

end

    
        