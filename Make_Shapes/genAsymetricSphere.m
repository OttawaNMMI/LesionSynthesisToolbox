function genAsymetricSphere 

N = 100 % number of points to render the sphere
r = 10 % radius
rstd = 0.3;

r = max(0,r.*(1+rstd*randn(N,1)));
z = (2*rand(N,1)-1).*r;
phi = randn(N,1)*2*pi;
x = sqrt(r.^2-z.^2).*cos(phi);
y = sqrt(r.^2-z.^2).*sin(phi);
coord = [x, y, z]; 
    
x = x + 150; 
y = y + 225; 
z = z + 60; 

map = zeros(700,700,154); % 192x192x47 --> 700x700x154 1 mm per voxel

DT = delaunayTriangulation(x,y,z);

[CH,v] = convexHull(DT);

figure;
trisurf(CH,DT.Points(:,1),DT.Points(:,2),DT.Points(:,3), ...
'FaceColor','cyan')


[X,Y,Z] = meshgrid(1:700,1:700,1:154);   %# Create a mesh of coordinates for your volume
simplexIndex = pointLocation(DT,X(:),Y(:),Z(:));  %# Find index of simplex that
                                                  %#   each point is inside
mask = ~isnan(simplexIndex);    %# Points outside the convex hull have a
                                %#   simplex index of NaN
mask = reshape(mask,size(X));   %# Reshape the mask to 101-by-101-by-101

View4D(mask)
end 