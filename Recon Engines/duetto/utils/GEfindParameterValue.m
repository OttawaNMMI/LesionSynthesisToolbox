% Find option in a cell array or structure of option-value pairs
% Usage:
%  value=GEfindParameterValue(params, 'option'[, abort_if_found]);
% INPUT
%   params: either cell-array with option-value pairs, or structure
%   option: string with the option-name
%   abort_if_found: bool (defaults to true)
%        If true, the function will call error() if 'option' is not
%        found. If false, the function will return
%        'NotFound'.
% OUTPUT
%   The value associated with the option.
%
% WARNING: when using structures, the option-matching is currently
% case-sensitive.
