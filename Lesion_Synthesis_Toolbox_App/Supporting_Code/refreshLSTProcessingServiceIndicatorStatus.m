% refreshLSTProcessingServiceIndicatorStatus - timer callback function to
% update the status indicator in LST to refelect whether the LST Processing
% Servic is running or not.

% By Rna Klein, The Ottawa Hospital, 2023

function refreshLSTProcessingServiceIndicatorStatus(hObject, event)
obj = get(hObject,'UserData');
if isvalid(obj)
	if strcmpi(LSTProcessingService('status'),'Running')
		set(obj,'Color','Green');
	else
		set(obj,'Color','Red');
	end
else % The check for status timer is still running, but the indicator does not exist anymore. No point running this time any longer.
	stop(hObject);
	delete(hObject);
end
end