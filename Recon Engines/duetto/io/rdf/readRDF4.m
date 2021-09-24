% FILE NAME: readRDF4.m
%
% This script program reads a PET raw data file (RDF) including 
% headers and segment data. All header definitions are taken
% from sharcDiskExternal.h supplied in the 'include' directory
% of the rdfLib. 
%
% USAGE: The program requires the user to initialize an 'inputFilename'	
% with the RFD filename. The following are created from this program:
%	sharc_rdf_header: describes offsets to all headers
% 	sharc_rdf_config: configuration info of RDF
%	sharc_rdf_sorter_data: info on rdf segment (raw) data
%	sharc_rdf_deadtime_header: deadtime header info
%	sharc_rdf_singles_header
%	sharc_rdf_acq_param_data
%	sharc_rdf_compute_param_data
%	sharc_rdf_pet_exam_data
%	sharc_rdf_acq_stats_data
%	sharc_rdf_sys_geo_data
%	seg0:7Data: raw data from the following segment
%		segment0: CTAC raw 
%		segment2: Emission Prompts
%		segment3: Emission Delays
%		segment4:7: Calibration
%
%	unitIntegDeadTime: deadtime data (float)
%	singles:	singles data (unsigned int). Not in proper singles format
%			see readsingles.pro 
%
% DISCLAIMER: This program was written to support research needs and
% is not validated product code. Therefore, all permuations of options
% and error conditions have NOT been rigorously tested. This program
% is available on an "as is" basis.
%
