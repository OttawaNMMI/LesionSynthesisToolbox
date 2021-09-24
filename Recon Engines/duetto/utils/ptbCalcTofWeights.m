% Calculate Gaussian TOF kernel lookup table for each wtStep. This function
% support 4 versions.
%   version 0 : no truncation 
%   version 1: truncated at 3 sigma
%   version 2: truncated at approximately 3 sigma, keep a constant number
%              of non-zero TOF bins 
%   version 3: packed version 2, return packed tofWeights and tofSkips  
% History: 
%   2017-06-01: Created by Hua Qian 
