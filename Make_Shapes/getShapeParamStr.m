% getShapeParamStr - Create a description string of a shape's parameters.
% usage:
% paramStr = getShapeParamStr(ROIData) - retirns a string with the relevant
% parameters of the shape described in ROIData structure.

% By Ran Klein, The Ottawa Hospital, 2023

function paramStr = getShapeParamStr(ROIData)
switch ROIData.shape
	case 'Sphere (homo)'
		paramStr = [num2str(ROIData.rad) 'mm'];
    case 'Blobby sphere (homo)'
        paramStr = [num2str(ROIData.rad) 'mm'];
	otherwise
		paramStr = '';
end

end