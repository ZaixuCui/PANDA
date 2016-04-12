function varargout = PANDA_AddPath(varargin)
% GUI for adding path for PANDA_Select tool, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_ADDPATH MATLAB code for PANDA_AddPath.fig
%      PANDA_ADDPATH, by itself, creates a new PANDA_ADDPATH or raises the existing
%      singleton*.
%
%      H = PANDA_ADDPATH returns the handle to a new PANDA_ADDPATH or the handle to
%      the existing singleton*.
%
%      PANDA_ADDPATH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_ADDPATH.M with the given input arguments.
%
%      PANDA_ADDPATH('Property','Value',...) creates a new PANDA_ADDPATH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_AddPath_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_AddPath_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_AddPath

% Last Modified by GUIDE v2.5 15-Jul-2013 14:00:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_AddPath_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_AddPath_OutputFcn, ...
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


% --- Executes just before PANDA_AddPath is made visible.
function PANDA_AddPath_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_AddPath (see VARARGIN)

% Choose default command line output for PANDA_AddPath
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_AddPath wait for user response (see UIRESUME)
uiwait(handles.PANDAAddPathFigure);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_AddPath_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global PathList;
varargout{1} = handles.output;
varargout{2} = PathList;
delete(hObject);


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PathList;
PathList = get(handles.PathListEditbox, 'String');
uiresume(handles.PANDAAddPathFigure);


% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PathList;
PathList = '';
uiresume(handles.PANDAAddPathFigure);


function PathListEditbox_Callback(hObject, eventdata, handles)
% hObject    handle to PathListEditbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PathListEditbox as text
%        str2double(get(hObject,'String')) returns contents of PathListEditbox as a double


% --- Executes during object creation, after setting all properties.
function PathListEditbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PathListEditbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
%end


% --- Executes when user attempts to close PANDAAddPathFigure.
function PANDAAddPathFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDAAddPathFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global PathList;
PathList = '';
uiresume(handles.PANDAAddPathFigure);
