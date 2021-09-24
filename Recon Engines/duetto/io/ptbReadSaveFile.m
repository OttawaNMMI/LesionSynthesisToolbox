% FILE NAME: readSavefile.m
%
% DEVELOPER: Tim Deller
%
% PURPOSE:  
% This function reads an array in the SAVEFILE format. This format is
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
%       1) Filename of the array
%       2) OPTIONAL - Desired data class of the array. This is a more efficient
%          implementation than casting later, because it is incorporated
%          into the fread command.
%
% OUTPUTS:
%       1) The array
%
% POTENTIAL IMPROVEMENTS:
%  a) If arrays will be desired in a different class than they are saved, then
%     incorporating this change of data type into the fread statement will be
%     much more efficient than casting later. So, this could be an optional
%     extra argument to this function.
%  b) Add complex number support, perhaps support for both alternating between
%     complex and real, as well as outputting all reals and then all
%     imaginaries.
