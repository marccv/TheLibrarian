function noiseFT=findNoise(sample,f_ADC,data,N_noisesamples)
    
    noiseFT=zeros(sample/2,1);
% 
%     fprintf('Please stay silent until further notice'); %in realta non serve, è per fare scena
% 
%     noise=readtable('noiseAmp1.csv'); 
%     noise=noise.Variables;
%     noise=noise(:,2);



%     if (length(data) <(sample*N_noisesamples))
%         fprintf('errore, lasciare calibrare per più tempo\n');
%         return;
%     end

    for jj=1:N_noisesamples %ascolto il rumore un tot di volte e man mano medio

        %ascolto del rumore e computo della sua FFT
        noiseSample = data(((jj-1)*sample+1): (jj*sample));
        pause(f_ADC*sample); %simula il tempo che mi serve per campionare, in realtà il telefono non campiona cosi veloce quindi non so che senso abbia
        [k,temp]=FourierT(noiseSample,sample,f_ADC);

        %media degli spettri
        noiseFT=noiseFT+temp/N_noisesamples;


        %figure
        %plot(k,temp);
    end
        fprintf('Calibration concluded');

        %figure
        %plot(k,noiseFT);
        %title('average');
end



