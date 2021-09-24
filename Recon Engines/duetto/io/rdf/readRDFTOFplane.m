%    Read and decompress a set of projection planes (one phi) from a
%    v7 RDF TOF file, taking advantage of prviosuly opened and read data.
%
%  Inputs:
%       fid      - file descriptor
%       phi      - which plane to take (1..hdr.numPhi)
%       hdr      - RDF data header structure
%       CVTtable - Information list for phi data
%       permute  - (optional) return data as (vTh,T,U) instead of
%                     (T,U,vTh)
