function [val] = findLesionChar(dia, cont, data)

if isempty(data)
	load('C:\Users\hjuma\OneDrive - The Ottawa Hospital\Papers in Progress\MIPs Special Edition 2019\JMI Paper Data 4 Ran\Analysis\Trial 1\doctor_results_2019.mat')
end
count = 1; 

temp = []; 

diameters = data(:,[1]); 

for i = 1:length(diameters)
	if diameters(i) == dia 
		temp = [temp; data(i,:)]; 
	end 	
end 

ratio = temp(:,[2]); 

for i = 1:length(ratio) 
	if ratio(i) == cont
		val = temp(i,[4 5]); 
	end 	
end 

end 