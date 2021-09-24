function [count, m] = determineStudyDuration(fObserver) 

load(fObserver) 
count = 0; 

for i = 1:length(results)
	count = count + results{i}.time2click; % seconds
	m(i) = results{i}.time2click; 
end 


end 