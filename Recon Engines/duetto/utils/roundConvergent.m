% roundConvergent
%   This tool is created to compute convergent rounding without the use of
%   the fixed-point toolbox.
%   Convergent rounding rounds halves to the nearest even integer.
%
% Input:
%   scalar or matrix numbers
%
% Output:
%   convergent rounded answer
%
% Example:
%   
% >> x = -1.5:0.25:1.5            
% 
% x =
% 
%   Columns 1 through 7
% 
%    -1.5000   -1.2500   -1.0000   -0.7500   -0.5000   -0.2500         0
% 
%   Columns 8 through 13
% 
%     0.2500    0.5000    0.7500    1.0000    1.2500    1.5000
% 
% >> roundedX = roundConvergent(x)
% 
% roundedX =
% 
%     -2    -1    -1    -1     0     0     0     0     0     1     1     1     2
%
%
