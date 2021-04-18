function cerchio = circle(lum)

    xmax = 51*2;
    ymax = 100*2;

    x = 1:xmax;
    y = 1:ymax;

    colore = [0.8500 0.3250 0.0980];

    cerchio = ones(size(y,2),size(x,2),3);
    canvas = ones(size(y,2),size(x,2));

    cx = xmax/2; % circle center
    cy = ymax/2; % circle center
    r = (xmax-15)/2; % radius 

    mask =((x-cx).^2 + (y'-cy).^2) < r^2  ; % Creating a mask

    % lum = 0;        % luminosità percentuale

    bianco = 100-lum;
    

    for i = 1:3
        canvas(mask) = (lum* colore(i) + bianco)/(100);
        cerchio(:,:,i) = canvas;

    end

%     figure    
%     image(cerchio)

end

