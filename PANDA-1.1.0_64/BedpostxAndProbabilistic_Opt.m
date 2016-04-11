function varargout = BedpostxAndProbabilistic_Opt(varargin)
% GUI for BedpostxAndProbabilistic_Opt (part of software PANDA), by Zaixu Cui  
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Version 1.1.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
% BEDPOSTXANDPROBABILISTIC_OPT MATLAB code for BedpostxAndProbabilistic_Opt.fig
%      BEDPOSTXANDPROBABILISTIC_OPT, by itself, creates a new BEDPOSTXANDPROBABILISTIC_OPT or raises the existing
%      singleton*.
%
%      H = BEDPOSTXANDPROBABILISTIC_OPT returns the handle to a new BEDPOSTXANDPROBABILISTIC_OPT or the handle to
%      the existing singleton*.
%
%      BEDPOSTXANDPROBABILISTIC_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEDPOSTXANDPROBABILISTIC_OPT.M with the given input arguments.
%
%      BEDPOSTXANDPROBABILISTIC_OPT('Property','Value',...) creates a new BEDPOSTXANDPROBABILISTIC_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BedpostxAndProbabilistic_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BedpostxAndProbabilistic_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BedpostxAndProbabilistic_Opt

% Last Modified by GUIDE v2.5 03-May-2012 12:49:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BedpostxAndProbabilistic_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @BedpostxAndProbabilistic_Opt_OutputFcn, ...
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


% --- Executes just before BedpostxAndProbabilistic_Opt is made visible.
function BedpostxAndProbabilistic_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BedpostxAndProbabilistic_Opt (see VARARGIN)

% Choose default command line output for BedpostxAndProbabilistic_Opt
global Bedpostx_opt;
global ProbabilisticTracking_opt;
global BedpostxAndProbabilisticOK;
BedpostxAndProbabilisticOK = 0;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if ~isfield(Bedpostx_opt, 'Fibers')
    Bedpostx_opt.Fibers = 2;
end
set( handles.FibersEdit, 'String', num2str(Bedpostx_opt.Fibers));
if ~isfield(Bedpostx_opt, 'Weight')
    Bedpostx_opt.Weight = 1;
end
set( handles.WeightEdit, 'String', num2str(Bedpostx_opt.Weight));
if ~isfield(Bedpostx_opt, 'Burnin')
    Bedpostx_opt.Burnin = 1000;
end
set( handles.BurninEdit, 'String', num2str(Bedpostx_opt.Burnin));

if ~isfield(ProbabilisticTracking_opt, 'ProbabilisticTrackingType')
    ProbabilisticTracking_opt.ProbabilisticTrackingType = 'OPD';
end
if strcmp(ProbabilisticTracking_opt.ProbabilisticTrackingType, 'OPD')
    set( handles.OPDRadio, 'Value', 1);
elseif strcmp(ProbabilisticTracking_opt.ProbabilisticTrackingType, 'PD')
    set( handles.PDRadio, 'Value', 1);
end
if ~isfield(ProbabilisticTracking_opt, 'LabelIdVector')
    ProbabilisticTracking_opt.LabelIdVector = '';
elseif ~isempty(ProbabilisticTracking_opt.LabelIdVector)
    set( handles.LabelVectorEdit, 'String', mat2str(ProbabilisticTracking_opt.LabelIdVector));
end
% UIWAIT makes BedpostxAndProbabilistic_Opt wait for user response (see UIRESUME)
% uiwait(handles.BedpostxAndProbabilisticOptFigure);
uiwait(handles.BedpostxAndProbabilisticOptFigure);


% --- Outputs from this function are returned to the command line.
function varargout = BedpostxAndProbabilistic_Opt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global Bedpostx_opt;
global ProbabilisticTracking_opt;
global BedpostxAndProbabilisticOK;
varargout{1} = handles.output;
varargout{2} = Bedpostx_opt;
varargout{3} = ProbabilisticTracking_opt;
varargout{4} = BedpostxAndProbabilisticOK;
delete(hObject);



function FibersEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FibersEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FibersEdit as text
%        str2double(get(hObject,'String')) returns contents of FibersEdit as a double
global Bedpostx_opt;
Bedpostx_opt.Fibers = str2num(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function FibersEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FibersEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


function WeightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WeightEdit as text
%        str2double(get(hObject,'String')) returns contents of WeightEdit as a double
global Bedpostx_opt;
Bedpostx_opt.Weight = str2num(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function WeightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end



function BurninEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BurninEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BurninEdit as text
%        str2double(get(hObject,'String')) returns contents of BurninEdit as a double
global Bedpostx_opt;
Bedpostx_opt.Burnin = str2num(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function BurninEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BurninEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


function LabelVectorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LabelVectorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LabelVectorEdit as text
%        str2double(get(hObject,'String')) returns contents of LabelVectorEdit as a double
global ProbabilisticTracking_opt;
LabelIdVectorString = get(hObject, 'String');
try
    ProbabilisticTracking_opt.LabelIdVector = eval(LabelIdVectorString); 
    ProbabilisticTracking_opt.LabelIdVectorText = LabelIdVectorString; 
catch
    ProbabilisticTracking_opt.LabelIdVector = '';
    ProbabilisticTracking_opt.LabelIdVectorText = '';
    set(hObject, 'String', '');
    msgbox('The label id you input is illegal');
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
global ProbabilisticTracking_opt;
switch get(hObject, 'tag')
    case 'OPDRadio'
        ProbabilisticTracking_opt.ProbabilisticTrackingType = 'OPD';
    case 'PDRadio'
        ProbabilisticTracking_opt.ProbabilisticTrackingType = 'PD';
end
    


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BedpostxAndProbabilisticOK;
global Bedpostx_opt;
global ProbabilisticTracking_opt;
if isempty(Bedpostx_opt.Fibers)
    msgbox('Please input the number of fibers per voxel !');
elseif isempty(Bedpostx_opt.Weight)
    msgbox('Please input ARD weight, more weight means less secondary fibers per voxel !');
elseif isempty(Bedpostx_opt.Burnin)
    msgbox('Please input burnin period !');
elseif isempty(ProbabilisticTracking_opt.LabelIdVector)
    msgbox('Please input label id for probabilistic tracking !');
else
    BedpostxAndProbabilisticOK = 1;
    close;
end


% --- Executes when user attempts to close BedpostxAndProbabilisticOptFigure.
function BedpostxAndProbabilisticOptFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to BedpostxAndProbabilisticOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.BedpostxAndProbabilisticOptFigure);


% --- Executes during object creation, after setting all properties.
function ProbabilisticTrackingType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProbabilisticTrackingType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when BedpostxAndProbabilisticOptFigure is resized.
function BedpostxAndProbabilisticOptFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to BedpostxAndProbabilisticOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)   
    PositionFigure = get(handles.BedpostxAndProbabilisticOptFigure, 'Position');
    FontSizeTrackingTypeUipanel = ceil(12 * PositionFigure(4) / 200);
    set( handles.ProbabilisticTrackingType, 'FontSize', FontSizeTrackingTypeUipanel );
end


% --- Executes on button press in LabelIDText.
function LabelIDText_Callback(hObject, eventdata, handles)
% hObject    handle to LabelIDText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in BurninText.
function BurninText_Callback(hObject, eventdata, handles)
% hObject    handle to BurninText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in WeightText.
function WeightText_Callback(hObject, eventdata, handles)
% hObject    handle to WeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FibersText.
function FibersText_Callback(hObject, eventdata, handles)
% hObject    handle to FibersText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
