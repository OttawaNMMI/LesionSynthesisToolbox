% 	Read data from "VP" file format, return as 3D array
%   This  function is the MATLAB version of Chuck Stearns' readvp.pro
%
%  Syntax:
%       data = readvp(inputFilename)
%       data = readvp(inputFilename, sinoFlag)
%  Inputs:
%       inputFilename   -   Name of volPET filename
%       sinoFlag        -   if sinoFlag==1, the last two variables are
%                           exchanged
%  Outputs:
%       data    -   3D array
