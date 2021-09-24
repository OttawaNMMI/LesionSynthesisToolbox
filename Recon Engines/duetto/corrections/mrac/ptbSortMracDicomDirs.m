% Sort a series DICOM directories with similar names (dirType) in specified 
% location (dirLoc) according to sliceLocations of DICOM files in the 
% directories.  
% 
% INPUTS:
%   dirLoc: the directory containing the DICOM directories with similar
%       names *dirType* . 
%   dirType: keyword contained in DICOM directory name. Supported
%       keywords are 'WATER', 'FAT', 'InPhase', 'TOFNAC', and 'pseudoCT'.      
% OUTPUT:
%   sortedDir: list of structs containing directory information that is
%       sorted descending from patient head to feet. 
%       In addition, it also contains the sorted fileList and 
%       sliceLocations of each directory 
% SYNTAX:
%   lavaStruct = ptbSortMracDicomDirs('MRAC', 'WATER');
