%   maxmat      Determine the maximum value inside a matrix 
%
%   USAGE:      m = minmat(mat); 
%
%
%               mat     searching matrix 
%               m       minimum 
%   
%
%   DEVELOPED BY: Hanif Gabrani-Juma, B.Eng


function [m] = maxmat(mat) 

m = max(reshape(mat,[],1)); 

end 