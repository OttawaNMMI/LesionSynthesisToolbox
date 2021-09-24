% [pddOut] = ListPddGetTopLevel(listFilePath, startMsecVec, endMsecVec)
%
% Get list file Periodic Detector Data (PDD) one second sample data and return a single PDD sample 
% that represents the given list of time intervals.
%
% Three level heirarchy overview:
% L1 - ListPddGetTopLevel()     input a list of time intervals specified by two vectors of start/end msec 
%                               output one PDD sample that represents the given list of time intervals
%
% L2 - ListPddGetOneInterval()  input one time interval specified by a start/end msec
%                               output one PDD sample that represents the given time interval
%
% L3 - ListPddGetOneSample()    input specifies one PDD sample to retrieve from the list file
%                               output one PDD sample directly from list file
%
% Input assumptions:
% - startMsecVec and endMsecVec are vectors with the same number of elements
% - time intervals are zero relative so zero corresponds to the first time marker in the list file
% - time intervals are positive so startMsecVec(i) > endMsecVec(i)
% - time intervals do not overlap so startMsecVec(i) >= endMsec(i-1)
%
% Output notes:
% - One PDD sample struct is returned that represents the given list of start/end msec time intervals.
% - For each time interval, a start/end weighted sum is computed for all counters (e.g. singles) 
% - For each time interval, a start/end time weighted average is computed for all ratios (e.g. blockBusyRatio).
% - For all time intervals, a sum is computed for all counters (e.g. singles).
% - For all time intervals, a time weighted average is computed for ratios (e.g. blockBusyRatio).
% - Ref: ListPddGetOneSample.m for details of the PDD sample struct. 
%
% Diagram of list file first/last time markers with first/last PDD samples:
%    firstPddMsec                            lastPddMsec
% ---^---*--------------^--------------------^-----------*
%        firstTmMsec         <prompt data>               lastTmMsec   
%    | PDD sample1      |    <PDD data>      | PDD sample<last> |
%
% Other notes and assumptions:
% - We assume one second sample data.
% - Since we multiply integer counter data (e.g. singles) by fractional float values and later
%   may sum over several time intervals, we store all numerical data in floating point format.
% - if time interval is outside PDD sample data range, then throw exception
% - throw MException on error paths (not a vector, overlap, negative time interval,...)
% 
% Questions:
% - How is RDFCompleteFlag used?
% - How is areEvtTimeStampsKnown used?
% - What is listType 3?
% - numAssocListFiles (number of beds?)
% - whichAssocLFile (bed number?)
%
