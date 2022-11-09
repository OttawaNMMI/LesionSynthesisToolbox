function refreshLSTProcessingServiceIndicatorStatus(hObject, event)
obj = get(hObject,'UserData');
if strcmpi(LSTProcessingService('status'),'Running')
	set(obj,'Color','Green');
else
	set(obj,'Color','Red');
end
end