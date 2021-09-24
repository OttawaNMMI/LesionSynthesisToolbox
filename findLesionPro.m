function [val] = findLesionPro(dia, cont, data, vec)

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
		val = temp(i,[vec]); 
	end 	
end 

end 