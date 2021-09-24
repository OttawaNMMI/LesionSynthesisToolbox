% [ startMsec, endMsec ] = UnlistValidStartEnd(rx)
%
% Refer to 'help UnlistMain' for a description of the rx struct.
%
% Input assumptions:
% - startMsecVec and endMsecVec are vectors with the same number of elements
% - time intervals are zero relative so zero corresponds to the first time marker in the list file
% - time intervals are positive or zero so startMsecVec(i) >= endMsecVec(i)
% - time intervals do not overlap so startMsecVec(i) >= endMsec(i-1)
%
% Copyright (c) 2019 General Electric Company. All rights reserved.
