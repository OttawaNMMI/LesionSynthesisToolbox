% MakeAsymSphere - make a "blobby" sphere volumetric image. 
%
% Usage:
% img = MakeBlobbySphere(hdr, ROI_x,ROI_y,ROI_z,ROI_r, int, vars) - add to
% the 3D volume image with header (hdr) a noisy sphere centered as
% [ROI_x, ROI_y, ROI_z] with average radius ROI_r with vars uniform 
% randomness and intenstensity int.
%
% Note: results in discconnected section, so tried to replace with
% MakeBlobbySphere.m

% By Ran Klein, The Ottawa Hospital, 2023

function img = MakeBlobbySphere(hdr,ROI_x,ROI_y,ROI_z,ROI_r, vars, int)

if vars == 0 % for sample ROI
    img = MakeSphere(hdr, ROI_x, ROI_y, ROI_z, ROI_r, 1);
else
    % Define variables
    rad = ROI_r / hdr.pix_mm_xy;
    var = vars/10 * rad;
    radSmooth = [1 2 1;2 4 2; 1 2 1];
    radSmooth = radSmooth/sum(sum((radSmooth))); % normalize smoothing to unity integral
    pad = (length(radSmooth)-1)/2;

    % Create phi and theta vectors and meshgrid
    theta = deg2rad(linspace(0, 360-360/(24), 24)); 
    phi = deg2rad(linspace(-90, 90, 13)); 
    [phi,theta]=meshgrid(phi,theta); 

    % Create radius values
    r = rad + var*(0.5 - rand(size(theta, 1), size(phi, 2))); % create Matrix of radii values
    r = [r(:,end-pad+1:end), r, r(:,1:pad)]; % duplicate start and end for wrap around in both dimensions
    r = r';
    r = [r(:, end-pad+1:end), r, r(:, 1:pad)];
    r = r';
    r = conv2(r, radSmooth,'valid');
    r(:,1) = mean(r(:,2));
    r(:,end) = mean(r(:,end-1)); 

    % Convert to cartesian    
    [x,y,z]=sph2cart(theta,phi,r); 
    x = cat(1,x,x(1,:));
    y = cat(1,y,y(1,:));
    z = cat(1,z,z(1,:));
    z(:,1) = mean(z(:,1));
    z(:,end) = mean(z(:,end));
    x(:,1) = 0;
    x(:,end)=0;
    y(:,1) = 0;
    y(:,end) = 0;
    % Create image
    h = figure();
    sph = trisurf(boundary([x(:)+ROI_x,y(:)+ROI_y,z(:)+ROI_z]),x+ROI_x, y+ROI_y, z+ROI_z, 'facecolor', 'r','AmbientStrength',0.5);
    set(h, 'Visible', 'off');
    fv = struct('vertices', sph.Vertices, 'faces', sph.Faces);
    img = inpolyhedron(fv,1:hdr.xdim, 1:hdr.ydim, 1:hdr.nplanes);
    img = img.*int;
    
    % vol = 4/3 * pi * rad^3;
    % les_vol = sum(img1,'all');
    
    %testing 
    %disp(vol)
    %disp(les_vol)
    %figure();
    %imshow(img2(:,:,round(ROI_z)));

    
end
end

