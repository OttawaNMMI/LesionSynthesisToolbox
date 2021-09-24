% FILE NAME: writeSavefile.m
%
% DEVELOPER: Tim Deller
%
% PURPOSE:  
% This function writes an array in the SAVEFILE format. This format is
% specified as follows:
%
%   Header of N+3 values in the int32 format, where N is the number of
%   dimensions in the input array.
%
%   1st int32 header value - Number of dimensions in the array
%   Next N int32 header values - Dimension lengths of the array
%   Next int32 header value - Total number of elements in the array (for check)
%   Next int32 header value - Class identifier:
%          uint8  = 1
%          int16 = 2
%          int32 = 3
%          single = 4
%          double = 5
%
% INPUTS:
%       1) Array to write to disk
%       2) Filename to write to
%       3) OPTIONAL - desired class to write to. Default is the class
%               of the input array.
% 
% POTENTIAL IMPROVEMENTS:
%  a) Add complex number support, perhaps support for both alternating between
%     complex and real, as well as outputting all reals and then all
%     imaginaries.
