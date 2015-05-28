function varargout = PANDA_Probabilistic_Opt(varargin)
% GUI for Probabilistic Network Options, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited  
%--------------------------------------------------------------------------
% PANDA_PROBABILISTIC_OPT MATLAB code for PANDA_Probabilistic_Opt.fig
%      PANDA_PROBABILISTIC_OPT, by itself, creates a new PANDA_PROBABILISTIC_OPT or raises the existing
%      singleton*.
%
%      H = PANDA_PROBABILISTIC_OPT returns the handle to a new PANDA_PROBABILISTIC_OPT or the handle to
%      the existing singleton*.
%
%      PANDA_PROBABILISTIC_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_PROBABILISTIC_OPT.M with the given input arguments.
%
%      PANDA_PROBABILISTIC_OPT('Property','Value',...) creates a new PANDA_PROBABILISTIC_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Probabilistic_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Probabilistic_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Probabilistic_Opt

% Last Modified by GUIDE v2.5 28-Sep-2012 12:30:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Probabilistic_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Probabilistic_Opt_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PANDA_Probabilistic_Opt is made visible.
function PANDA_Probabilistic_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Probabilistic_Opt (see VARARGIN)

% Choose default command line output for PANDA_Probabilistic_Opt
global ProbabilisticTrackingAlone_opt;
global ProbabilisticOK;
global ProbabilisticOpt_ParametersChangeFlag;

ProbabilisticOpt_ParametersChangeFlag = 0;
% global trackingAlone_opt;
ProbabilisticOK = 0;

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% if isfield(trackingAlone_opt, 'ProbabilisticTrackingType')
%     if ~isempty(trackingAlone_opt.ProbabilisticTrackingType)
%         ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType = trackingAlone_opt.ProbabilisticTrackingType;
%     end
% end
% if isfield(trackingAlone_opt, LabelIdVector)
%     if ~isempty(trackingAlone_opt.LabelIdVector)
%         ProbabilisticTrackingAlone_opt.LabelIdVector = trackingAlone_opt.LabelIdVector;
%     end
% end
if ~isfield(ProbabilisticTrackingAlone_opt, 'ProbabilisticTrackingType')
    ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType = 'OPD';
end
if strcmp(ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType, 'OPD')
    set( handles.OPDRadio, 'Value', 1);
elseif strcmp(ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType, 'PD')
    set( handles.PDRadio, 'Value', 1);
end
if ~isfield(ProbabilisticTrackingAlone_opt, 'LabelIdVector')
    ProbabilisticTrackingAlone_opt.LabelIdVector = '';
elseif ~isempty(ProbabilisticTrackingAlone_opt.LabelIdVector)
    set( handles.LabelVectorEdit, 'String', mat2str(ProbabilisticTrackingAlone_opt.LabelIdVector));
end
%
TipStr = sprintf('Output path distribution directly.');
set(handles.OPDRadio, 'TooltipString', TipStr);
%
TipStr = sprintf(['Correct path distribution for the length of the pathways and' ...
    '\n output path distribution.']);
set(handles.PDRadio, 'TooltipString', TipStr);
%
TipStr = sprintf(['The IDs of brain regions user is interested in.' ...
    '\n Example: [1:90].']);
set(handles.LabelVectorEdit, 'TooltipString', TipStr);

% UIWAIT makes PANDA_Probabilistic_Opt wait for user response (see UIRESUME)
% uiwait(handles.ProbabilisticOptFigure);
uiwait(handles.ProbabilisticOptFigure);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Probabilistic_Opt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global ProbabilisticTrackingAlone_opt;
global ProbabilisticOK;
varargout{1} = handles.output;
varargout{2} = ProbabilisticTrackingAlone_opt;
varargout{3} = ProbabilisticOK;
delete(hObject);


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ProbabilisticTrackingAlone_opt;
global ProbabilisticOK;
global ProbabilisticOpt_ParametersChangeFlag;
if isempty(ProbabilisticTrackingAlone_opt.LabelIdVector)
    msgbox('Please input label id for probabilistic tracking !');
else
    if ProbabilisticOpt_ParametersChangeFlag
        Check_info{1} = ['probabilistic tracking type = ' ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType];
        Check_info{2} = ['label id vector of ROI = ' ProbabilisticTrackingAlone_opt.LabelIdVectorText];
        button = questdlg( Check_info, 'Please check!', 'Yes', 'No', 'No');
        if strcmp(button,'Yes')
            ProbabilisticOK = 1;
            close;
        end
    else
        ProbabilisticOK = 1;
        close;
    end
end



function LabelVectorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LabelVectorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LabelVectorEdit as text
%        str2double(get(hObject,'String')) returns contents of LabelVectorEdit as a double
global ProbabilisticTrackingAlone_opt;
global ProbabilisticOpt_ParametersChangeFlag;
LabelIdVector_Previous = ProbabilisticTrackingAlone_opt.LabelIdVector;
LabelIdVectorString = get(hObject, 'String');
try
    ProbabilisticTrackingAlone_opt.LabelIdVector = eval(LabelIdVectorString); 
    ProbabilisticTrackingAlone_opt.LabelIdVectorText = LabelIdVectorString; 
    set(hObject, 'String', mat2str(ProbabilisticTrackingAlone_opt.LabelIdVector));
catch
    ProbabilisticTrackingAlone_opt.LabelIdVector = '';
    ProbabilisticTrackingAlone_opt.LabelIdVectorText = '';
    set(hObject, 'String', '');
    msgbox('The label id you input is illegal');
end
if length(LabelIdVector_Previous) ~= length(ProbabilisticTrackingAlone_opt.LabelIdVector)
    ProbabilisticOpt_ParametersChangeFlag = 1;
elseif LabelIdVector_Previous ~= ProbabilisticTrackingAlone_opt.LabelIdVector
    ProbabilisticOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function LabelVectorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LabelVectorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes when selected object is changed in ProbabilisticTrackingType.
function ProbabilisticTrackingType_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ProbabilisticTrackingType 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global ProbabilisticTrackingAlone_opt;
global ProbabilisticOpt_ParametersChangeFlag;
ProbabilisticTrackingType_Previous = ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType;
switch get(hObject, 'tag')
    case 'OPDRadio'
        ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType = 'OPD';
    case 'PDRadio'
        ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType = 'PD';
end
if ~strcmp(ProbabilisticTrackingType_Previous, ProbabilisticTrackingAlone_opt.ProbabilisticTrackingType)
    ProbabilisticOpt_ParametersChangeFlag = 1;
end


% --- Executes when user attempts to close ProbabilisticOptFigure.
function ProbabilisticOptFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ProbabilisticOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.ProbabilisticOptFigure);


% --- Executes when ProbabilisticOptFigure is resized.
function ProbabilisticOptFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to ProbabilisticOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)   
    PositionFigure = get(handles.ProbabilisticOptFigure, 'Position');
%     if PositionFigure(4) < 200
        FontSizeTrackingOptionsUipanel = ceil(12 * PositionFigure(4) / 190);
        set( handles.ProbabilisticTrackingType, 'FontSize', FontSizeTrackingOptionsUipanel );
%     end
end


% --- Executes on button press in TrackingTypeText.
function TrackingTypeText_Callback(hObject, eventdata, handles)
% hObject    handle to TrackingTypeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LabelIDText.
function LabelIDText_Callback(hObject, eventdata, handles)
% hObject    handle to LabelIDText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
