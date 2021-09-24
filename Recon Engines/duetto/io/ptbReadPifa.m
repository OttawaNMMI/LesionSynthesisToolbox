function pifa = ptbReadPifa(pifaFilename, varargin)
% FILENAME: ptbReadPifa.m
%
% PURPOSE: Reads pifa from provided filename location and returns a pifa
% structure
%
% INPUTS:
%    pifaFilename: PIFA file to be read, either binary (v1) or HDF5 (v2)
%    'dataOnly':   optional, to invoke return only PIFA data (not structure)
% OUTPUT:
%    structure containing PIFA header and pifa floating point data
%
% Examples:
%   pifaStruct = ptbReadPifa('ctac.pifa');
%   pifaData   = ptbReadPifa('ctac.pifa','dataOnly');
%
% Copyright 2019 General Electric Company.  All rights reserved.


if ~exist(pifaFilename, 'file')
   error('ptbReadPifa: File does not exist %s', pifaFilename);
end


%% Determine if the file is HDF5 format
% I would like to directly use the H5F.is_hdf5 function, but unfortunately that
% function doesn't seem to work when the path includes a "tilde" for home
% diretories.
% This works:
%     H5F.is_hdf5('/home/de022328/PIFA.h5')
% This doesn't:
%     H5F.is_hdf5('~de022328/PIFA.h5')
% So, one way around it is to wrap with strtrim(ls('~de022328/PIFA.h5')):
% (Any other suggestions?!?)
isHDF = H5F.is_hdf5(strtrim(ls(pifaFilename)));

%% For HDF5, call appropriate PIFA reader
if (isHDF > 0)
    pifa = ptbReadPifaHdf5(pifaFilename, varargin{:});
    return
elseif (isHDF < 0)
    error('ptbReadPifa: Could not determine PIFA file format %s', pifaFilename)
end

%% Below for PIFAv1 (pre-HDF5) only

% Define pifa as an instance of PtbPifa;
pifa = PtbPifa;
pifa.pifa_version = ptbReadRaw(pifaFilename,[1,1],'float','l',0);
pifa.cmpJobID     = ptbReadRaw(pifaFilename,[1,1],'int32','l',4);
pifa.xm = ptbReadRaw(pifaFilename,[1,1],'int16','l',8);
pifa.ym = ptbReadRaw(pifaFilename,[1,1],'int16','l',10);
pifa.zm = ptbReadRaw(pifaFilename,[1,1],'int16','l',12);
pifa.xm = double(pifa.xm);
pifa.ym = double(pifa.ym);
pifa.zm = double(pifa.zm);

pifa.ctacDfov        = ptbReadRaw(pifaFilename,[1,1],'float','l',16);
pifa.patientEntry    = ptbReadRaw(pifaFilename,[1,1],'int32','l',20);
pifa.patientPosition = ptbReadRaw(pifaFilename,[1,1],'int32','l',24);
pifa.tableLocation   = ptbReadRaw(pifaFilename,[1,1],'float','l',28);
nx = pifa.xm;
ny = pifa.ym;
nz = pifa.zm;

fid = fopen(pifaFilename,'rb','l');
if (fid == -1)
    fprintf('Error opening file %s. Exiting\n', pifaFilename);
    fclose(fid);
    return;
end
fseek(fid,32,'bof');
pifa.frame_of_reference = fscanf(fid,'%c',64);

pifa.offsetToStartOfImage = ptbReadRaw(pifaFilename,[1,1],'uint32','l',32+64+64);
fclose(fid);

pifa.data = ptbReadRaw(pifaFilename,[nx,ny,nz], ...
    'float','l',double(pifa.offsetToStartOfImage));

if ~isempty(varargin) && strcmpi(varargin{1}, 'dataOnly')
    pifa = pifa.data;
end
