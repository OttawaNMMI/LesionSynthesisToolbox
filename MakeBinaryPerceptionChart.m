function [output] = MakeBinaryPerceptionChart(fData)

%load('C:\ProgramData\MathWorks\webapps\R2019a\Perception Studies\JMI Perception\Results\Analysis\Trial 2\doctor_results_2019_Dec_11_12_22_10.mat')

load(fData) 

int = [1.5:.25:6];
s = [2,4,6,8,10,12,14]; 

output = nan(size(s,2),size(int,2)); 

for i = 1:length(s) 
	
	for j = 1:length(int)
		
		[val] = findLesionPro(s(i), int(j), data, 3);
		output(i,j) = val;
		
	end 
end 

end 