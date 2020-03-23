%   MakeCircle          - Draw filled circle in 2D Matrix 
%   
%   [img]   =   MakeCircle(img,circX,circY,circR) 
%
%           img     


function [img] =  MakeCircle(img,circX,circY,circR,val)


imageSizeX = size(img,1);
imageSizeY = size(img,2); 

[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

circlePixels = (rowsInImage - circY).^2 ...
    + (columnsInImage - circX).^2 <= circR.^2;

img = img + circlePixels.*val; 

%figure; imagesc(img); colorbar

end 





% % Create a logical image of a circle with specified
% % diameter, center, and image size.
% % First create the image.
% imageSizeX = 640;
% imageSizeY = 480;
% % Next create the circle in the image.
% ;
% % circlePixels is a 2D "logical" array.
% % Now, display it.
% image(circlePixels) ;
% colormap([0 0 0; 1 1 1]);
% title('Binary image of a circle');