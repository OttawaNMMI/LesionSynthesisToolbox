function err = ptbWritePifa(pifaFilename, pifa, varargin)
% FILENAME: ptbWritePifa.m
%
% PURPOSE: Writes a PIFA data-type structure into a pifa file.
%
% INPUTS:
%   pifaFilename: binary file to be written
%   pifa structure
%
% OUTPUTS: 
%   error
%
% Copyright 2020 General Electric Company.  All rights reserved.


pifa_version = 0;

if mod(length(varargin),2)~=0 || ...
        ~exist('pifaFilename','var') || ~exist('pifa','var')
    error('Incorrect number of inputs');
end
var = 1;
while var <= length(varargin)
    while varargin{var}(1) == '-'
        varargin{var} = varargin{var}(2:end);
    end
    switch(lower(varargin{var}))
        case 'ver'
            % Read from input argument.
            pifa_version = varargin{var+1};
            if ischar(pifa_version)
                pifa_version = str2double(pifa_version);
            end
            var=var+2;
        otherwise
            error('Unknown keyword: %s\n',lower(varargin{var}));
            
    end
end

% Read from PtbPifa instance
if pifa_version==0 && isprop(pifa,'pifa_version') 
    pifa_version = pifa.pifa_version;
elseif  pifa_version==0 && isfield(pifa, 'version')
    pifa_version = pifa.version;
end

%Check PtbPifa instance
if pifa_version == 0 && isprop(pifa,'chunks') 
    pifa_version = 2.0;
elseif pifa_version == 0 && isfield(pifa, 'chunks')
    pifa_version = 2.0;  
end

% The product always failed in the CTAC pifa validation.
% The reason is missing zero at the end of the frame_of_referance char array 
% (apparently in MATLAB the char: ' '  is not 0). The code below changes ' ' to 0.
for j = 1:length(pifa.frame_of_reference)
    if pifa.frame_of_reference(j) == ' '
        pifa.frame_of_reference(j) = 0;
    end
end

            
switch pifa_version
    case 1.0
        fid = fopen(pifaFilename,'wb','l');
        if (fid==-1)
            error('ptbWritePifa: error opening "%s"', pifaFilename);
        end
        fwrite(fid,pifa_version,'float');
        % 4
        fwrite(fid,pifa.cmpJobID,'int32');
        % 8
        fwrite(fid,pifa.xm,'int16');
        % 10
        fwrite(fid,pifa.ym,'int16');
        %12
        fwrite(fid,pifa.zm,'int16');
        % pad to 14
        fwrite(fid,zeros(1,1),'int16');
        % 16
        fwrite(fid,pifa.ctacDfov,'float');
        % 20
        fwrite(fid,pifa.patientEntry,'int32');
        % 24
        fwrite(fid,pifa.patientPosition,'int32');
        % 28
        fwrite(fid,pifa.tableLocation,'float');
        % 64
        fwrite(fid,pifa.frame_of_reference,'char');
        % pad to 160
        fwrite(fid,zeros(64,1),'char');
        % 160    32+64+64
        fwrite(fid,pifa.offsetToStartOfImage,'uint32');
        % 164
        fwrite(fid,pifa.data,'float');
        fclose(fid);
        err=0;
    case 2.0
        % Handle the deprecated syntax warning:
        origWarningStatus = warning('query','MATLAB:imagesci:deprecatedHDF5:deprecatedAttributeSyntax');
        warning('off', 'MATLAB:imagesci:deprecatedHDF5:deprecatedAttributeSyntax')
        
        hdf5write(pifaFilename, '/HeaderData/versionID', single(2.0));
        hdf5write(pifaFilename, '/HeaderData/cmpJobID', uint32(pifa.cmpJobID), 'WriteMode', 'append');
        hdf5write(pifaFilename, '/HeaderData/xMatrix', uint16(pifa.xm), 'WriteMode', 'append');
        hdf5write(pifaFilename, '/HeaderData/yMatrix', uint16(pifa.ym), 'WriteMode', 'append');
        hdf5write(pifaFilename, '/HeaderData/zMatrix', uint16(pifa.zm), 'WriteMode', 'append');
        hdf5write(pifaFilename, '/HeaderData/ctacDfov', single(pifa.ctacDfov), 'WriteMode', 'append');
        hdf5write(pifaFilename, '/HeaderData/patientEntry', uint32(pifa.patientEntry), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/patientPosition', uint32(pifa.patientPosition), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/tableLocation', single(pifa.tableLocation), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/frame_of_reference', char(pifa.frame_of_reference), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/head_lung_boundary', single(pifa.head_lung_boundary), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/lung_abdomen_boundary', single(pifa.lung_abdomen_boundary), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/abdomen_legs_boundary', single(pifa.abdomen_legs_boundary), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/mracAlgorithmType', char(pifa.mracAlgorithmType), 'WriteMode', 'append');
        hdf5write(pifaFilename, ...
            '/HeaderData/truncationCompleteFlag', uint16(pifa.truncationCompleteFlag), 'WriteMode', 'append');
        hdf5write(pifaFilename, '/PifaData', single(pifa.data), 'WriteMode', 'append');
        
        nChunks = length(pifa.chunks);
        hdf5write(pifaFilename, '/HeaderData/chunks/numberChunks', uint16(nChunks), 'WriteMode', 'append');
        if (nChunks>=1)
            for iChunk = 1:nChunks
                hdf5write(pifaFilename, ...
                    sprintf('/HeaderData/chunks/chunk_description%d/anatomyName', iChunk-1),...
                    char(pifa.chunks(iChunk).anatomyName), 'WriteMode', 'append');
                hdf5write(pifaFilename, ...
                    sprintf('/HeaderData/chunks/chunk_description%d/startSliceNumber', iChunk-1),...
                    uint16(pifa.chunks(iChunk).startSliceNumber), 'WriteMode', 'append');
                hdf5write(pifaFilename, ...
                    sprintf('/HeaderData/chunks/chunk_description%d/endSliceNumber', iChunk-1),...
                    uint16(pifa.chunks(iChunk).endSliceNumber), 'WriteMode', 'append');
            end
        end
        
        % Reset the deprecated syntax warning:
        warning(origWarningStatus.state, origWarningStatus.identifier)
    otherwise
        error('Unknown PIFA Version !');
end

end
