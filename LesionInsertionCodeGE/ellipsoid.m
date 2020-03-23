function imOut = ellipsoid(nx,ny,nz,cx,cy,cz,rx,ry,rz,magFactor)
% FILENAME: ellipsoid.m
%
% Generate an ellipsoidal image
%
% Input:
%   nx,ny,nz: image size
%   cx,cy,cz: center of ellipsoid
%   rx,ry,rz: radius (in voxel) in each direction, i.e., half the length of
%   the principal axes
%   magFactor: Optional. Defaul value=8. Ellipsoid generated in X
%   (magFactor) resolution and downsampled back to original resolution
%
% Output:
%   imOut: output image [nx, ny, nz]
%
% Copyright 2017 General Electric Company. All rights reserved.

% History:  Written by SA


if nargin<10
    magFactor = 8;
end

xmin = max(round(cx-rx),1); xmax = min(round(cx+rx),nx);
ymin = max(round(cy-ry),1); ymax = min(round(cy+ry),ny);
zmin = max(round(cz-rz),1); zmax = min(round(cz+rz),nz);

x = linspace(xmin-0.5+(1/magFactor/2),xmax+0.5-(1/magFactor/2),magFactor*(xmax-xmin+1));
y = linspace(ymin-0.5+(1/magFactor/2),ymax+0.5-(1/magFactor/2),magFactor*(ymax-ymin+1));
z = linspace(zmin-0.5+(1/magFactor/2),zmax+0.5-(1/magFactor/2),magFactor*(zmax-zmin+1));

if length(x)*length(y)*length(z)>1e8
    magFactor = floor((length(x)*length(y)*length(z)/1e8)^(1/3));
    x = linspace(xmin-0.5+(1/magFactor/2),xmax+0.5-(1/magFactor/2),magFactor*(xmax-xmin+1));
    y = linspace(ymin-0.5+(1/magFactor/2),ymax+0.5-(1/magFactor/2),magFactor*(ymax-ymin+1));
    z = linspace(zmin-0.5+(1/magFactor/2),zmax+0.5-(1/magFactor/2),magFactor*(zmax-zmin+1));
end

[xx,yy,zz] = ndgrid(single(x),single(y),single(z));

imHiRes = ((xx-cx)/rx).^2 + ((yy-cy)/ry).^2 + ((zz-cz)/rz).^2 <= 1;

imOut = zeros(nx,ny,nz,'single');

for ii = xmin:xmax
    for jj = ymin:ymax
        for kk = zmin:zmax
            imOut(ii,jj,kk) = sum(sum(sum(imHiRes((ii-xmin)*magFactor+1:(ii-xmin+1)*magFactor,...
                (jj-ymin)*magFactor+1:(jj-ymin+1)*magFactor,(kk-zmin)*magFactor+1:(kk-zmin+1)*magFactor))));
        end
    end
end

imOut = imOut/magFactor/magFactor/magFactor;
