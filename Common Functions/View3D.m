function [clim] = View3D(vol,MIPs,map) 

s = size(vol); 

if exist('loc') 
    x = MIPs(1); 
    y = MIPs(2); 
    z = MIPs(3);
    MIPs = 0;      
else 
    MIPs = 1; 

end 


clim = [min(vol(:)), max(vol(:))]; 

if clim(1) < 0 
    clim(1) = 0;
end 


if MIPs
	imgx = reshape(max(vol,[],1),[s(2),s(3)])';
	imgy = reshape(max(vol,[],2),[s(1),s(3)]);
	imgz = reshape(max(vol,[],3),[s(1),s(2)]);
    disp('MIPs')
else
	imgx = reshape(vol(x,:,:),[s(2),s(3)])';
	imgy = reshape(vol(:,y,:),[s(1),s(3)]);
	imgz = reshape(vol(:,:,z),[s(1),s(2)]);
end

figure; 
subplot(1,3,1) 
imagesc(imgx); 
axis equal 
axis off 
set(gca,'Color','none')
set(gca,'clim',clim)

subplot(1,3,2) 
imagesc(imgz); 
axis equal 
axis off 
set(gca,'Color','none')
set(gca,'clim',clim)


subplot(1,3,3)
imagesc(imgy); 
axis equal 
axis off 
set(gca,'Color','none')
set(gca,'clim',clim)

if exist('map') 
    colormap(map) 
    disp(map)
else 
    colormap('jet')
end

end 