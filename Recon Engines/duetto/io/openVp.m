%   Open a "VP" file format, read headers, leaves FP at head of data
%
%  Inputs:
%       inputFilename   -   Name of volPET filename
%
%  Outputs:
%       fid       - file pointer to opened file, pointing to first projection data
%       hdr       - header structure
%       thetaHdr  - array of theta header items
%       scales    - array of scale factors (may be floats or double)
%    See the volpet file description for an explanation of these items.
