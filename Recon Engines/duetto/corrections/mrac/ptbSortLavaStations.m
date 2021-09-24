% FILE NAME: ptbSortLavaStations.m
%
% PURPOSE: Match the TOFNAC frames (bed positions) to the MRAC LAVA frames.
%
% INPUTS:
%    lavaTofnac: structure containing unsorted TOFNAC directory information
%    lavaMrac:   structure containing directory information of MRAC
%                series that are sorted according to the bed station number
%                (obtained from ptbSortLavaDirs.m)
%
% OUTPUT:
%    lavaOut: structure containing sorted TOFNAC directory information
%
% Copyright 2019 General Electric Company.  All rights reserved.
