function refreshLSTProcessingServiceIndicatorStatus(hObject, event)
obj = get(hObject,'UserData');
if isvalid(obj)
	if strcmpi(LSTProcessingService('status'),'Running')
		set(obj,'Color','Green');
	else
		set(obj,'Color','Red');
	end
else % The timer to check for status is running, but the indicator does not exist anymore. No point running this time any longer.
	stop(hObject);
	delete(hObject);
end
end