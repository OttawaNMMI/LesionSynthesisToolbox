% UnlistMain(rx)
%
% Given an unlist 'rx' parameter struct, unlist a list file to create a set of RDF SINO files
% with corresponding DICOM header files.
%
% The following rx struct members are required and applicable to all unlist requests:
%   listFilePath    - file path of an uncompressed list file. The directory where the list
%                     file resides is assumed to contain the associated DICOM header file. 
%                     In addition, the list file directory is assumed to contain the three 
%                     cal (.img) files used during image reconstruction. The method used to
%                     extract list data from the scanner is not covered here.
%   unlistType      - 'static', 'dynamic' or 'gated'
%   tofMode         - 'tof' or 'nontof'
%   startMsecVec    - a matrix of start msec values that are zero relative to the first timestamp
%                     in the list file. 
%   endMsecVec      - a matrix of end msec values that are zero relative to the first timestamp
%                     in the list file.
%                     Notes: regarding both startMsecVec and endMsecVec:
%                     a) For static, always one row and one column (one element).
%                     b) For dynamic, each row specifies a frame with one time interval
%                     c) For gated ('percent', 'sppb', or 'time' binning), one row vector with one column per trigger.
%                     d) For gated (bypass binning), one row per gated frame.
%                     e) both must always contain the same number of rows and columns.
%                     f) For all unlist types, each row specifies one frame and each column specifies 
%                        a time interval.
%
% The following rx struct members are optional and applicable to all unlist requests:
%   bytesPerCellMax - max bytes per histogram cell must be 1 or 2 (default is 2).
%   forceVqcAdjust  - enable table z position VQC offset adjustment in DICOM header files (default is false).
%   maxTableLocDiff - used to find the DICOM header file corresponding to the list file (default is 2.0mm)
%   resultsFileName - filename that contains text results for all SINO and DICOM files (default is no results)
%   unlistDirPath   - unlist to the given existing directory (default is a new directory named with a timestamp).
%                     Specify unlistDirPath for the 2nd and subsequent beds when multi-bed unlisting.
%
% The following rx struct members are only applicable when the unlistType is 'gated'
%   gatedBinMode    - 'percent', 'sppb', 'time', or 'bypass'
%                     'percent' each bin is a percent (ratio) of the trigger intervals.
%                     'sppb'    single phase percent binning.
%                     'time'    each bin is a fixed time interval in msecs of the trigger intervals.
%                     'bypass'  each startMsecVec/endMsecVec row vector specifies a gated bin
%                               and implies that no trigger boundary checking or trigger rejection is done.
%   gatedBinVec     - If gatedBinMode is 'time', a vector of fixed msec values.
%                     If gatedBinMode is 'percent', a vector of percent values.
%                     If gatedBinMode is 'sppb': the vector contains two elements as described below.
%                                                gatedBinVec(1) is the single phase offset percent value.
%                                                gatedBinVec(2) is the single phase width value.
%                     If gatedBinMode is 'bypass', this vector is not used.
%   gatedFrameMsecs       - time interval between first and last trigger (optional)
%                           if omitted, the value is derived from endMsecVec(end) - startMsecVec(1)
%   gatedTrigRejMinMsecs  - trigger rejection minimum trigger interval msecs (optional)
%   gatedTrigRejMaxMsecs  - trigger rejection maximum trigger interval msecs (optional)
%   gatedWaitForFirstTrig - 'cardiac' or 'respiratory' (optional)
%                           'cardiac' implies wait for first cardiac trigger in the list file after startMsecVec(1)
%                           'respiratory implies wait for first respiratory trigger in the list file after startMsecVec(1)
%                           if omitted, the unlister does not wait for any trigger in the list file
%
% All output files are created in a new sub-directory of the form
% "<listDirPath>/unlist-<yyyy-mm-dd_hhmmss>/raw" with the intent that
% image reconstruction may be run when the current directory is the unlist directory.
% 1) A SINO<nnnn> file is created for each frame where nnnn is a zero relative frame number.
% 2) A 'i100000.RPDC.<frame number>' DICOM header file is created corresponding to each
%    SINO<nnnn> file.
% 3) Symbolic links are created in the raw directory that point to the cal (.img) files
%    located in listDirPath.
% 4) If the listDirPath contains a 'MRAC' directory, a MRAC softlink is created in the unlist directory.
% 
% Copyright (c) 2020 General Electric Company. All rights reserved.
