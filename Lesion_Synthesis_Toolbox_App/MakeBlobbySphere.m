function img = MakeBlobbySphere(hdr,ROI_x,ROI_y,ROI_z,ROI_r, int, vars)
%BLOBBYSPHERE Summary of this function goes here


%   Detailed explanation goes here


if vars == 0 % for sample ROI
    img = MakeSphere(hdr, ROI_x, ROI_y, ROI_z, ROI_r, 1);
else
    % Define variables
    rad = ROI_r / hdr.pix_mm_xy;
    tSpacing = 360/(24*vars);
    pSpacing = 181/(12*vars);
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
    img1 = inpolyhedron(fv,1:hdr.xdim, 1:hdr.ydim, 1:hdr.nplanes);
    img2 = img1.*int;
    
    vol = 4/3 * pi * rad^3;
    les_vol = sum(img2,'all');
    
    %testing 
    %disp(vol)
    %disp(les_vol)
    %figure();
    %imshow(img2(:,:,round(ROI_z)));
 
    
    if les_vol < (vol/1.5) || les_vol > (vol*1.5)
        img = MakeBlobbySphere(hdr,ROI_x,ROI_y,ROI_z,ROI_r, int,vars);
    else
        img = img2;
    end
end
end

