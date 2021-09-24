function range = DetBedPos(map,ROI_z) 

value = map(floor(ROI_z)); 

if value < 200 && value > 100 
    range(1) = value - 100; 
    range(2) = range(1); 
elseif value > 200 
    a = floor(value/2); 
    b = a + 1;
    c = a + b; 
    if c == value 
        range(1) = a-100; 
        range(2) = b-100; 
    else 
        error('Could not determine Bed Position') 
    end 
else 
    error('Could not determine Bed Position') 
end 
end