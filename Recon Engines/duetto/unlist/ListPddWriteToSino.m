% ListPddWriteToSino(listFilePath, startMsecVec, endMsecVec, sinoFilePath, coinEventsInSino)
%
% Get list file Periodic Detector Data (PDD) one second sample data and write a single PDD sample 
% to the given "sinoFilePath".
%
% Inputs:
%   listFilePath - input list file path (e.g. LIST<nnnn>.BLF)
%   startMsecVec - vector of start intervals
%   endMsecVec   - vector of end intervals
%   sinoFilePath - output sinogram file path
%   coinEventsInSino - number of COIN events in sinogram
%
% Input assumptions:
% - startMsecVec and endMsecVec are vectors with the same number of elements
% - time intervals are positive so startMsecVec(i) > endMsecVec(i)
% - time intervals do not overlap so startMsecVec(i) >= endMsec(i-1)
%
% PDD sample notes:
% - For each time interval, a start/end weighted sum is computed for all counters (e.g. singles) 
% - For each time interval, a start/end time weighted average is computed for all ratios (e.g. blockBusyRatio).
% - For all time intervals, a sum is computed (e.g. singles).
% - For all time intervals, a time weighted average is computed for ratios (e.g. blockBusyRatio).
% - Ref: ListPddGetOneSample.m for details of the PDD sample struct. 
%
% Diagram of list file first/last time markers with first/last PDD samples:
%    firstPddMsec                            lastPddMsec
% ---^---*--------------^--------------------^-----------*
%        firstTmMsec         <prompt data>               lastTmMsec   
%    | PDD sample1      |    <PDD data>      | PDD sample<last> |
%
