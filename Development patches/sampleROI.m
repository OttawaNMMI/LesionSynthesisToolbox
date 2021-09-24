function [intensity, map] = sampleROI(imgData, ROI)
map = makeMap(imgData.hdr, ROI);
intensity = mean(imgData.vol(map>0));
end