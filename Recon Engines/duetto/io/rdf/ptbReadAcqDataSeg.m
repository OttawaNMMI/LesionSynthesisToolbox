% hdf5ReadAcqDataSeg -
%   This function reads the requested slice/correction from a segment in
%   the HDF5-based RDF file specified by 'inFile.' Note that the term 'slice'
%   has different meanings depending on the data orientations. The
%   'segment' argument should be set to one of the
%   SHARC_RDF_SCAN_DATA_TYPES enumerated types. This arg indirectly serves
%   as an index into the array of RDF Data Segments.
%
%   Note that any option input can be excluded from the input list, or it
%   can be empty in the call.
%
%    Inputs:
%       inFile   - string path and name for the HDF5-based RDF file
%       sliceIdx - which plane to take (e.g. 1 to nPhi for 3D Sinograms)
%       segment  - (optional) - Default is 2. Note, indexed by 0 (not 1)
%
%    Output:
%       slice    - matrix of uint8's or uint16's.
%                  Note: The reason that uint8's or uint16's are returned
%                  rather than singles is to save time on any required
%                  permuting after this call. The output of this function
%                  should be permuted (if needed) and then cast to the
%                  appropriate data-type by the calling function.
%
% Note: A 'slice' is a generic term used by the function prototypes to describe
%       a subset of the volume of data contained in the RDF Data
%       Segment(s). The size and shape of a 'slice' is dependent on the
%       data orientation type of the Data Segment, histogram cell size, and
%       if applicable, number of TOF bins.
%
%    If S_RDF_SINOGRAM,       a 'slice' would represent a traditional 2D
%                             sinogram, i.e. all data associated with (theta,r)
%                             for a given 'z'.
%
%    If S_3D_RDF_SINOGRAM,    a 'slice' would represent a 3D projection,
%                             i.e. all data associated with (theta,v,u) for
%                             a given 'sliceIdx'.
%
%    If S_3D_TOF_SINOGRAM,    a 'slice' would represent a TOF 3D projection,
%                             i.e. all data associated with (u,dt,theta,v)
%                             for a given 'sliceIdx'.
%
%    If S_RDF_ENERGY_SPECTRA, a 'slice' would represent all crystals energy
%                             spectra for a given module, i.e. all data
%                             associated with (blk,Z,X,ebin) for a given
%                             'm'.
%
%    If S_RDF_POSITION_SPECTRA, a 'slice' would represent a position spectra,
%                             i.e. all data associated with (Zpos,Xpos) for
%                             a given block of a given module.
%
%
% TOF Example:
%    Read the 14th Phi-angle from a TOF RDF file:
%       view = hdf5ReadAcqDataSeg(rdf_fileName,14)
%
%
% Copyright (c) 2012-2015 General Electric Company. All rights reserved.
% This code is only made available outside the General Electric Company
% pursuant to a signed agreement between the Company and the institution to
% which the code is made available.  This code and all derivative works
% thereof are subject to the non-disclosure terms of that agreement.
%
% History:
%    23Nov2012 created - Dan Schlifske
%    18Dec2012 - TDeller - Modified inputs/outputs and cleaned up the code.
%    03Jun2015 - Dan Schlifske - Removed hdr/readRDF stuff for Duetto
%
