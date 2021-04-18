function [data_sample,I, flag]=ListenSample(sample,f_ADC,data,I,log)

%out of a long list of samples i shall read everytime 256 samples to
%compute the spectrum

flag = 0;
data_sample = 0;

if(length(data) - I <sample)
    fprintf(log,'WARNING: Audio finito\n');
    flag = 1;
    return
end

    t=tic;
    
    data_sample=data(1*I:sample+I-1); 
    
    t=toc(t);
    
   pause(1/f_ADC*sample-t); %simula la frequenza di campionamento

end
