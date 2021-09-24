%    Read a set of projection planes (one phi) from TOF volpet file,
%    taking advantage of prviosuly opened and read data.
%
%  Inputs:
%       fid     - file descriptor
%       index   - which plane to take (1..hdr.numPhi)
%       hdr     - volpet data header structure
%       phiList - Information list for phi data
%       permute - (optional) return data as (vTh,T,U) instead of
%                     (T,U,vTh)
%
