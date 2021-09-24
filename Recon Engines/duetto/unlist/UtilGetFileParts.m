% [ dirPath, fileName ] = UtilGetFileParts(filePath)
%
% Given an absolute or relative file path, return a directory path and file name.
% Similar to fileparts() except that the current directory is assumed if only a filename is given.
% Also, dirPath is always an absolute directory path.
%
