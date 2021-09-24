% FILENAME: readNonTOFfromRDFv7
%
% PURPOSE: Read a non-TOF sinogram from an RDF of any format (TOF/nonTOF,
%          compressed/uncompressed) and of any RDF version.
%
% INPUTS:
%   fname      - file name
%   segment    - data segment number (optional; default is segment 2)
%   numWorkers - number of parpool workers (optional; default is 0)
%
% OUTPUT:
%    data       - non-TOF sinogram organized as (r, theta, phi),
%                 known as (u, v, phi). phi is the projection angle.
%
% Copyright (c) 2019 General Electric Company. All rights reserved.
