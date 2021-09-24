% [pddOut] = ListPddGetOneInterval(listFilePath, startMsec, endMsec, listInfo)
%
% Get list file Periodic Detector Data (PDD) corresponding to one start/end time interval.
% 
% Assumptions:
% - list file always contains one second samples
%
% Inputs:
% - listFilePath - string
% - startMsec    - interval starting msec relative to list data time markers
% - endMsec      - interval ending msec relative to list data time markers
% - listInfo     - output of ListPddGetHeaderInfo(listFilePath)
%
% Output notes:
% - One PDD sample struct is returned that represents the given start/end msec time interval.
% - A start/end weighted sum is computed for all counters (e.g. singles) 
% - A start/end time weighted average is computed for all ratios (e.g. blockBusyRatio).
% - Ref: ListPddGetOneSample.m for details of the PDD sample struct. 
%
% Diagram of time interval with list file start/end time markers and start/end PDD samples:
%    startPddMsec                            endPddMsec
% ---^---*--------------^--------------------^-----------*------------
%        startMsec           <prompt data>               endMsec   
%    | start PDD sample |    <PDD data>      | end PDD sample   |
%
