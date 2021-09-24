% find dicomHdr.PatientPosition from RDF fields
% USAGE:
%   dicomHdr=setDicomPatientPositionFromRDF(dicomHdr, rdfHdr);
% This will ONLY set dicomHdr.PatientPosition. Other orientation-related fields are
% not set. Use setDicomOrientationFieldsFromPatientPosition for this.
%
% INPUTS:
%	dicomHdr: structure returned from dicominfo on PET data
%	rdfHdr :  structure returned by readRDF
