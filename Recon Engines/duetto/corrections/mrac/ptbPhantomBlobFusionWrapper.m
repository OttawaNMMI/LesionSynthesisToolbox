% FILE NAME: ptbPhantomBlobFusionWrapper.m
%
% This function creates the PhantomAC-based PCT directory.
%
% INPUTS:
%       dirInputNAC: TOF-NAC Dicom directory. Should be 128x128 and 89 slices.
%       pseudoCT_dir: Directory to write PCT images, such as ''pseudoCT-1'
%       phantomName: Phantom name, from Dicom header field Private_0023_102d.
%       phantomTemplateLocation: Template path, defined in MRAC params
%       blobFusionFile: Blob fusion executable file, defined in MRAC params 
%
% OUTPUT:
%       {none} -- the PCT directory is created and filled with images.
%
% Copyright (c) 2018 General Electric Company. All rights reserved.
