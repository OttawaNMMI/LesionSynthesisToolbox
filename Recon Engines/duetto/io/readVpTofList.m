%    Read the "phi list" of a TOF volpet file (orientation 4), and
%    return the file pointer to the head of the on-TOF projection data.
%
%  Inputs:
%        fid   - file descriptor for vp file
%        hdr   - file header
%
%  Output:
%        TOFlist - array of structurs with pointers and counts per angle phi
