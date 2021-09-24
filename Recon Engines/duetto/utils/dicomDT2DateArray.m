% Convert a dicom DT string to date vector
% USAGE:
%   date=dicomDT2DateArray(s);
% INPUTS:
%   s: string in format YYYYMMDDHHMMSS.ff
%      with ff a fractional second (containing up to 6 digits)
%      see ftp://medical.nema.org/medical/dicom/final/cp714_ft.doc
% OUTPUT:
%  date: date vector [Y,MO,D,H,MI,S] suitable for datenum etc
%
% WARNING: timezone specification of DICOM DT will lead to errors 
% (matlab seems to ignore timezones anyway).
%
% DEVELOPER: Kris Thielemans
