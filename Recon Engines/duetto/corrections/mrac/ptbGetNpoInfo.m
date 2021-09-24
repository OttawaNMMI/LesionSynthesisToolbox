% FILENAME:
%
% PURPOSE: Obtain Coil Type, Location and Template Name from RDF DICOM header
%
% INPUTS:
%    rdfHdr:      dicom info header obtained from dicominfo.m
%    sinoHdr:     sino header obtained from readRDF.m
%    nptDir:      directory containing templates for non-patient objects
%
% OUTPUTS:
%    npoInfoCell: structure containing NPO information (Type, Location, TemplateName)
%
% Copyright 2020 General Electric Company.  All rights reserved.
