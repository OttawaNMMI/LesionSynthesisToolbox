function pushMessage(pushbulletH)
if ~isempty(pushbulletH.ApiKey)
	try
		pushbulletH.pushNote([],'Lesion simulation completed',['Finished processing ' lesionParamsFile]);
	catch
		% Do nothing
	end
end