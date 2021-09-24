% WriteSliceToRDFv9(sinoFile, sliceData, sliceIdx)
% 
% Write a TOF or nonTOF sinogram slice (or "view") to an RDF. This function
% assumes that the dataset does not already exist. If it does, it will return
% an error. This function will use the deflate (GZIP) filter when writing
% the slice to the RDF.
%
%
% Copyright (c) 2019 General Electric Company. All rights reserved.
%
