N = 100 % number of points to render the sphere
r = 1 % radius
rstd = 0.3;
if 0
	Ncount = 0;
	coord = zeros(N,3);
	a = 4*pi*r^2/N;
	d = sqrt(a);
	Mtheta = round(pi/d);
	dtheta = pi/Mtheta;
	dphi = a/dtheta;
	thetaShift = 0;
	for m = 1:Mtheta
		theta = pi*(m-0.5)/Mtheta;
		Mphi = round(2*pi*sin(theta)/dphi);
		n = 1:Mphi;
		phi = 2*pi*(n-0.5)/Mphi;
		coord(Ncount+(1:Mphi),:) = [(theta+thetaShift)*ones(Mphi,1), phi', r*(1+rstdrandn(Mphi,1))];
		Ncount = Ncount+Mphi;
		thetaShift = theta(1)/2;
	end
	coord = coord(1:Ncount,:); % remove any points that were no populuted
	disp(Ncount);
	[x,y,z] = sph2cart(coord(:,1), coord(:,2), coord(:,3))
else
	r = max(0,r.*(1+rstd*randn(N,1)));
	z = (2*rand(N,1)-1).*r;
	phi = randn(N,1)*2*pi;
	x = sqrt(r.^2-z.^2).*cos(phi);
	y = sqrt(r.^2-z.^2).*sin(phi);
	coord = [x, y, z];
end

fig = figure(1); clf(fig)
% sphere(36);
% drawnow;
% sh = get(gca,'children');
% set(sh,'FaceAlpha',0.5);
% hold on
h=plot3(x,y,z,'ob');
set(h,'MarkerFaceColor','k')
axis('equal')
hold on

K=delaunay(x,y,z); 
% mh = trimesh(K,x,y,z);
h = trisurf(K,x,y,z,0.7*ones(length(x),1));
% view(0,75)
shading interp
% lightangle(-45,30)
lh = [camlight(30,10);...
	 camlight(-30,10)];
h.FaceLighting = 'gouraud';
% h.AmbientStrength = 0.3;
% h.DiffuseStrength = 0.8;
% h.SpecularStrength = 0.9;
% h.SpecularExponent = 25;
% h.BackFaceLighting = 'unlit';