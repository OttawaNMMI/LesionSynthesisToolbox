% This function reads an v8 PET raw data file (RDF) header and
% singles/deadtime data, but not segment data, unless seg4 (norm). All header 
% definitions are taken from rdfExternal.h. Note that this is NOT a
% comprehensive read of the RDF...additional pieces may be added over
% time as our needs evolve. 
%
% USAGE: rdf = readRDF8('filename');
% with the RDF filename. The output will be a structure with the following fields
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
%	unitIntegDeadTime: deadtime data (float)
%	singles:	singles data (unsigned int). Not in proper singles format
%			see readsingles.pro 
