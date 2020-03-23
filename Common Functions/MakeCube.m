function [img] =  MakeCube(img,x,y,r,zstart,zend,val)

img(x:x+r,y:y+r,zstart:zend) = val; 

end 