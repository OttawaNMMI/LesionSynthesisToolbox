function [shape] = MakeEllipse(img,x,y,r1,r2,val)

imageSizeX = size(img,1);
imageSizeY = size(img,2);

[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the ellipse in the image.
centerX = x;
centerY = y;
radiusX = r1;
radiusY = r2;

ellipsePixels = (rowsInImage - centerY).^2 ./ radiusY^2 ...
    + (columnsInImage - centerX).^2 ./ radiusX^2 <= 1;
% ellipsePixels is a 2D "logical" array.
% Now, display it.

shape = ellipsePixels*val; 

end 