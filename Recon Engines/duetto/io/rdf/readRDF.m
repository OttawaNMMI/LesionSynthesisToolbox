% readRDF.m
%
% A common entry point for reading RDF versions 6-9 (note
%    that the RDF7 or RDF9 read does not read segment data)
%
% USAGE: rdf = readRDF('filename', optional_arguments);
% with the RDF filename. Any optional arguments will be passed on
% to readHLRDF, readRDF7, readRDF8, or readRDF9.
% The output will be a structure with the following fields
%	sharc_rdf_header: describes offsets to all headers
% 	sharc_rdf_config: configuration info of RDF
%	sharc_rdf_sorter_data: info on rdf segment (raw) data
%	sharc_rdf_deadtime_header: deadtime header info
%	sharc_rdf_singles_header: singles header info
%	sharc_rdf_acq_param_data: data segment
%	sharc_rdf_compute_param_data: data segment
%	sharc_rdf_pet_exam_data: data segment
%	sharc_rdf_acq_stats_data: data segment
%	sharc_rdf_sys_geo_data: data segment
%       seg0:7Data: raw data from the following segment (v6 only)
%               segment0: CTAC raw 
%               segment2: Emission Prompts
%               segment3: Emission Delays
%               segment4-7: Calibration
%	unitIntegDeadTime: deadtime data (float)
%	singles:	singles data (unsigned int). Not in proper singles format
%			see readsingles.pro 
