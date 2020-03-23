


function ViewVol(vol) 

fig = figure('tag','ViewVolFigure',...
    'name','ViewVol',...
    'color','white',...
    'numbertitle','off',...
    'MenuBar','None',...
    'KeyPressFcn',@btnpress); 



sqr = ceil(sqrt(size(vol,3))); 

clim(1) = min(reshape(vol,[],1)); 
clim(2) = max(reshape(vol,[],1)); 

for i = 1:size(vol,3) 
    ah = subplot(sqr,sqr,i);    
    ih = imagesc(vol(:,:,i));  
    title(['Slice: ' num2str(i)]) 
    axis off 
    axis square 
    colormap(jet)
    set(ah,'clim',clim)
    set(ih,'tag',num2str(i))
    set(ih,'ButtonDownFcn',@btnpress)
end 


setappdata(fig,'vol',vol); 
setappdata(fig,'clim',clim);

end 



function btnpress(hObject,eventID,btnID)

fig = findobj('tag','ViewVolFigure'); 
fig2 = findobj('tag','VVZoomFigure'); 
ah = findobj('tag','VVZoomedAxes'); 
ih = findobj('tag','VVZoomedImg'); 

clim = getappdata(fig,'clim'); 


if isempty(fig2) 
    fig2 = figure('tag','VVZoomFigure',...
    'name','Zoomed Slice',...
    'color','white',...
    'numbertitle','off',...
    'MenuBar','None'); 
    
    ah = axes; 
    ih = imagesc(hObject.CData); 
    axis off 
    axis square 
    colormap(jet) 
    colorbar 
    title(['Slice: ' hObject.Tag])
    set(ah,'tag','VVZoomedAxes'); 
    set(ih,'tag','VVZoomedImg'); 
    %set(ah,'clim',clim)

else 
    set(ih,'cdata',hObject.CData) 
    title(['Slice: ' hObject.Tag])
    set(ah,'clim',clim)
    %figure(fig2) % Bring Figure to Front After Click
end 


end 