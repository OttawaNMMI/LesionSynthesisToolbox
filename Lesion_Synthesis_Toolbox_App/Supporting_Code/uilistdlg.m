function [selectedOption, tf] = uilistdlg(messageString, titleString, items, varargin)
%UILISTDLG Shows a list dialog inside a given uifigure.
%   UILISTDLG(f, message, title) shows a modal confirm dialog inside
%   the given uifigure with the given message and title.
%   By default, a question icon will be used and OK/Cancel buttons are
%   displayed.
%   f is the uifigure that was created using the uifigure function.
%   Message is a character vector or a cell array of character vectors.
%   Title is a character vector.
%
%   UILISTDLG(f, message, title, 'Options', {'Yes','No','Cancel'})
%   specifies the text of the options to display in the confirm dialog.
%   The default is {'Ok', 'Cancel'}.
%   Options can be a cell array containing 1 to 4 options.
%
%   UILISTDLG(f, message, title, 'Icon', IconSpec) specifies which
%   icon to display in the confirm dialog. IconSpec can be one of the
%   following: 'error', 'warning', 'info', 'success', 'question', 'none',
%   a file path to the icon file or an MxNx3 cdata matrix.
%   The default is 'question'.
%   Icon file types supported are SVG, PNG, JPEG and GIF.
%
%   UILISTDLG(f, message, title, 'CloseFcn', func) specifies the
%   callback function that will executed when the confirm dialog is closed
%   by the user. The user response is provided in the eventdata of the
%   callback.
%
%   UILISTDLG(f, message, title, 'Options', {'a','b','c'}, ...
%             'DefaultOption', 'b', 'CancelOption', 'a')
%   DefaultOption specifies which entry in the options cell array is the
%   default focused option in the dialog.
%   CancelOption specifies which entry in the options cell array maps to
%   the cancel actions in the dialog.
%   The default are the first and last options respectively.
%   The value can be the text in cell array or the index.
%    
%   selectedOption = UILISTDLG(...) blocks MATLAB and waits until user
%   makes a selection on the confirmation dialog. The return argument is
%   the option selected by the user.
%
%   Example
%      % Assuming f is a figure created using the uifigure function.
%      uiconfirm(f, 'Do you want to quit MATLAB?', 'Quit?', ...
%                   'Options', {'Yes','No','Cancel'}, ...
%                   'CloseFcn', @(o,e) handleDialog(o,e));
%
%   See also UIFIGURE, UIALERT, UICONFIRM

%   Copyright 2021 Ran Klein, The Ottawa Hospital

narginchk(3,13);
nargoutchk(1,2);

messageString = convertStringsToChars(messageString);
titleString = convertStringsToChars(titleString);

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

messageString = matlab.ui.internal.dialog.DialogHelper.validateMessageText(messageString);

titleString = matlab.ui.internal.dialog.DialogHelper.validateTitle(titleString);

% Default Parameter Values:
params = struct('CloseFcn', '');
params.Multiselect = 'off';
params.Options = items;
params.InitialValue = [];

i=1;
while i<length(varargin)
	params.(varargin{i}) = varargin{i+1};
	i = i+2;
end

% optLen = length(items);
% params.InitialValue = validateOptions(params, 'InitialValue', 1, optLen);

app.fig = uifigure('WindowStyle','modal','Name',titleString,'CloseRequestFcn',{@Done});
pos = app.fig.Position;
app.message = uilabel(app.fig,'Text',messageString,'Position',[pos(3)*0.1 pos(4)*0.9 pos(3)*0.8 pos(4)*0.1]);
app.listbox = uilistbox(app.fig,'Items',items,'Multiselect',params.Multiselect,'Position',[pos(3)*0.1 pos(4)*0.25 pos(3)*0.8 pos(4)*0.65],'Value',params.InitialValue);
app.okButton = uibutton(app.fig,'Text','OK','Position',[pos(3)*0.6 pos(4)*0.1 pos(3)*0.3 pos(4)*0.1],'ButtonPushedFcn',{@Done});
app.cancelButton = uibutton(app.fig,'Text','Cancel','Position',[pos(3)*0.2 pos(4)*0.1 pos(3)*0.3 pos(4)*0.1],'ButtonPushedFcn',{@Done});
app.Value = [];
app.fig.UserData = app;
app.fig.Visible = 'on';
drawnow;

% If user requested output then we block and wait for the end-user
% response to the dialog.
waitfor(app.fig, 'Visible','off');

selectedOption = app.fig.UserData.Value;
delete(app.fig);

tf = ~isempty(selectedOption);

end

function out = validateOptions(params, type, default, optLen)
% DefaulOption and CancelOption can be a string or a number which matches
% the options cell array.
val = params.(type);
options = params.Options;

if isempty(val)
    out = default;
    return;
end

if isnumeric(val) && isscalar(val)
    [valid, idx] = ismember(val, 1:optLen);
    if ~valid
        throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidDefaultOption', type)));
    end
    out = idx;
    return;
end

if ischar(val)
    [valid, idx] = ismember(val, options);
    if ~valid
        throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidDefaultOption', type)));
    end
    out = idx;
    return;
end

% no match
throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidDefaultOption', type)));
end


function Done(src, event, x)
if strcmpi(src.Type,'figure')
	fig = src;
else
	fig = src.Parent;
end
if isequal(src, fig.UserData.okButton)
	fig.UserData.Value = fig.UserData.listbox.Value;
end
fig.Visible = 'off';
end
