function RenderVol(img,trans,c)
fig = findobj('tag','RenderVol');

if isempty(fig)
    fig = figure('Numbertitle','off',...
        'Name','Render 3D Volume',...
        'Tag','RenderVol',...
        'KeyPressFcn',@RenderVolKeyPressFcn);
end


img = flip(img,1); 
img = flip(img,2); 
img = permute(img,[2 3 1]);



fv = isosurface(img,0.02);
p1 = patch(fv,'facecolor',c,'edgecolor','none');
isonormals(img,p1)
set(p1,'FaceAlpha',trans)
%Set the view settings and lightings
view(-45, 0) %Set view
daspect([1,1,1]) %Set aspect ratios
axis tight
%camlight
%camlight(-80,-10)
%lighting gouraud
axis off
hold on 

end

function RenderVolKeyPressFcn(hObject,e,p) 

[az,el] = view; 

switch e.Key
    
    case 'rightarrow' 
        view(az-1,el)     
        
    case 'leftarrow'
        view(az+1,el) 
        
    case 'uparrow'
        view(az,el+1)
        
    case 'downarrow'
        view(az,el-1)
end 

[az,el] = view; 
disp(['AZ: ' num2str(az) '    EL: ' num2str(el)])

end 