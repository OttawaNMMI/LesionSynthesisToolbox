function n = getLSTThreads
% TO DO: don't want this hardcoded - hint: use feature('NumCores') in GUI.
% Ref: https://undocumentedmatlab.com/articles/undocumented-feature-function/
switch 2
	case 0 %manual
		n=4;
	case 1 %number of cores avaialable
		n = feature('NumCores');
	case 2 %use resources, but leave some as spare
		n = min([floor(feature('NumCores')*.75),...
			feature('NumCores')-2]);
end