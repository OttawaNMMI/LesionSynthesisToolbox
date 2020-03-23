function shape = MakeSquare(img,x,y,r,val) 

shape = zeros(size(img)); 

shape(x:x+r,y:y+r) = val; 
end 