function [x y z f] = extractedLesionCOM

datadir = 'C:\Users\hjuma\Desktop\eTAS Aug 21 Lesion Params'; 
files = listfiles('.mat',datadir); 

disp('**********-----------**********')

for i = 1:length(files) 
    disp([datadir filesep files{i}])
    load([datadir filesep files{i}])
    map = lesion{1}.map; 
    map(map>0) = 1; 
    fmap = imfill(map,'holes'); 
    
    stats = regionprops3(fmap,'centroid'); 
    
    x(i) = round(stats.Centroid(1)); 
    y(i) = round(stats.Centroid(2)); 
    z(i) = round(stats.Centroid(3)); 
    f{i} = [datadir filesep files{i}]; 
    
    disp(['CENTROID X: ' num2str(x(i))]); 
    disp(['CENTROID Y: ' num2str(y(i))]); 
    disp(['CENTROID Z: ' num2str(z(i))]); 
    disp('**********-----------**********')
end 




end 