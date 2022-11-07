% str = mynum2str(data, sigfig, maxdec) - converts a number to a string
%
% mynum2str examples (sigfig=3 and maxdec=2)
% 123456.0 --> 123000
% 123.4560 --> 123
% 12.34560 --> 12.3
% 1.234560 --> 1.23
% 0.1234560 --> 0.12

% By Ran Klein 2012???
% Modified:
% 2013-12-31  RK  Added NA result for empty data.
% 2020-04-06  RK  Added support for array of numbers.

function result = mynum2str(data, sigfig, maxdec)
if isempty(data)
	result = 'NA';
	return
end

if nargin<2
	sigfig = 3; % number of significant figures to display (before and after .)
end
if nargin<3
	maxdec = 2; % maximum of decimals (after the .)
end

for di = 1:length(data)
	if isfinite(data(di))
		if isempty(sigfig)
			sigfig = floor(log10(abs(data(di))))+ 1 + maxdec;
		end
		e = max(-sigfig+1,floor(log10(abs(data(di)))));
		prec = max(-maxdec,e-sigfig+1); % precision
		p = round(data(di)/10^(prec))*10^(prec);
		str = num2str(p);
		i = find(str=='.');
		% number of figures after the decimal
		if isempty(i)
			i = length(str)+1;
			na = 0;
		else
			na = length(str)-i;
		end
		% number of figures befor the decimal
		t = str(1:i-1);
		if strcmpi(t,'0')
			nb = 0; % a preceding zero doesn't count
		else
			nb = sum(t>='0' & t<='9');
		end
		
		% number of trailing zeros to add
		n = min(sigfig-(na+nb),...
			maxdec - na);
		if n>0
			if i>length(str)
				str = [str '.'];
			end
			str = [str '0'*ones(1,n)];
		end
	else
		str = 'Inf';
	end
	
	if length(data)>1
		maxlen = sigfig+(maxdec>0);
		str = [repmat(' ',1,maxlen-length(str)) str];
	end
	if di == 1
		result = str;
	else
		result = [result '   ' str];
	end
end