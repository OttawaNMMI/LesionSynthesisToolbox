% GEh5DisplaySinoChecksum(outFile, inFile)
%   This function reads all of the segment data and PDD in the RDF file 
%   specified by 'inFile' and prints out slice counts and checksums.
%   
%   This output should match the output of 'rdfTell -c -T1' on the product.
%
%    Input(s):
%       outFile  - fprintf() output file path or fid
%       inFile   - string path and name for the HDF5-based RDF file
%
%    Output(s):
%       none
%
% Copyright (c) 2013-2015 General Electric Company. All rights reserved.
% This code is only made available outside the General Electric Company
% pursuant to a signed agreement between the Company and the institution to
% which the code is made available.  This code and all derivative works
% thereof are subject to the non-disclosure terms of that agreement.
%
% History:
%    April 2013 created - Dan Schlifske
%    June 2015 updated to include total counts for a Segment - Dan Schlifske
%    Sept 2015 added singles and deadtime checksums - Dan Schlifske
%
