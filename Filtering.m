function FT=Filtering(FT,freq,noiseFT)

%first i try to eliminate the background noise
FT=FT-noiseFT;

%FT(1:5)=0;

%w1=2*pi*20.598997;
%w2=2*pi*107.65265;
%w3=2*pi*737.86223;
%w4=2*pi*12194217;

%A weighting
%ci sarà di sicuro qualche errore, riconsiderare la possibilità di lavorare
%con un bel,sano, semplice, ciclo for
R=(12200^(2)*freq.^(4))./((freq.^2+20.6^2).*sqrt((freq.^2+107.7^2).*(freq.^2+737.9^2)).*(freq.^2+12200^2));
A=2+20*log(R'); 

A=10.^(A/20);

%R= (-2)*(w4^2)*(freq.^4)./((freq+w1).^2.*(freq+w2).*(freq+w3).*(freq+w4).^2);
%A=20*log(R');

%figure
  %semilogx(freq,A)
  %title('Aweighting');
  
 FT=FT.*A;
 
 mask=FT<0;
FT(mask)=0; %metto a 0 tutti quelli minori di zero


end

