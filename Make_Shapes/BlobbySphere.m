% lesion location and radius
lx = 20; % mm
ly = 30; % mm
lz = 40; % mm
r = 10 / 2; % mm average radius

pixsize = 0.3; %mm - pixel size in x, y and z

% image dimensions in number of pixels
xdim = 192;
ydim = 192;
zdim = 300;

[y,x,z] = meshgrid(linspace(pixsize,xdim*pixsize,xdim), linspace(pixsize,ydim*pixsize,ydim), linspace(pixsize,zdim*pixsize,zdim));

mask = (( (x-lx).^2 + (y-ly).^2 + (z-lz).^2).*(1+0.2*randn(size(x))) ) < r^2;
mask( ((x-lx).^2 + (y-ly).^2 + (z-lz).^2) < (r/2)^2) = true; % make sure core is filled
mask = imfill(mask,'holes'); % fill in some holes
mask = mask & imfill(~mask, round([lx ly lz]/pixsize)); % get rid of discovvencted pixels

View4D(single(mask)) % show the magic