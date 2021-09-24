% Write 3D array into "VP" file format
% Syntax:
%       status = writevp(outputFilename,data[, acqParams, scanner[, writeAsFloat]])
%  Inputs:
%       outputFilename  -   Name of volPET filename
%       data            -   3D array to be written into volPET format
%                           Note: pass 2D sinograms as permute(sino,[1,3,2])
%       writeAsFloat    -   (optional, default: false)
%                           If set to true, the data will be written as floats
%  Outputs:
%       status    -   non-zero if write is successful else 0
