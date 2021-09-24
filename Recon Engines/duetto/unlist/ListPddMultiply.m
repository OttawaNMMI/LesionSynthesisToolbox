% [pddProd] = ListPddMultiply(pddIn, sampleRatio, specialRatio)
%
% return the product of a PDD struct times a ratio
%
% A special case exists where a time interval only spans a single one second sample (ref: ListPddGetOneInterval.m).
% In this special case, "specialRatio" will have a value of 1.0 so that ratios values (e.g. blockBusyRatio)
% are effectively excluded from the multiply operation.
%
