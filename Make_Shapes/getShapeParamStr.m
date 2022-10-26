% Function to create a description string of shape parameters
function params = getShapeParamStr(ROIData)
switch ROIData.shape
	case 'Sphere (homo)'
		params = [num2str(ROIData.rad) 'mm'];
    case 'Blobby sphere (homo)'
        params = [num2str(ROIData.rad) 'mm'];
	otherwise
		params = '';
end

end