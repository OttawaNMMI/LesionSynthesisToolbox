function Simple3DVolViewer(vol,loc) 

s = size(vol); 

if exist('loc') 
    disp('es')
end


if MIPs
	imgx = reshape(max(vol,[],1),[s(2),s(3)])';
	imgy = reshape(max(vol,[],2),[s(1),s(3)]);
	imgz = reshape(max(vol,[],3),[s(1),s(2)]);
else
	imgx = reshape(vol(x,:,:),[s(2),s(3)])';
	imgy = reshape(vol(:,y,:),[s(1),s(3)]);
	imgz = reshape(vol(:,:,z),[s(1),s(2)]);
end





end 