% getLSTThreads - determine the number of threads to use for the
% reconstruction process (DUETTO).
%
% Usage: 
% n = getLSTThreads
%
% See also: LesionInsertionDUETTO_WebApp, runImageRecon_WebApp

% By Ran Klein, The Ottawa Hospital, 2022

function n = getLSTThreads

switch 2
	case 0 %manual
		n=4;
	case 1 %number of cores avaialable
		n = feature('NumCores'); % Ref: https://undocumentedmatlab.com/articles/undocumented-feature-function/
	case 2 %use resources, but leave some as spare
		n = max(4,min([floor(feature('NumCores')*.75),...
			feature('NumCores')-2]));
end