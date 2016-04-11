function varargout = Utilities(varargin)
% GUI for Utilities, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Version 1.1.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
% UTILITIES MATLAB code for Utilities.fig
%      UTILITIES, by itself, creates a new UTILITIES or raises the existing
%      singleton*.
%
%      H = UTILITIES returns the handle to a new UTILITIES or the handle to
%      the existing singleton*.
%
%      UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UTILITIES.M with the given input arguments.
%
%      UTILITIES('Property','Value',...) creates a new UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Utilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Utilities

% Last Modified by GUIDE v2.5 19-May-2012 16:09:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @Utilities_OutputFcn, ...
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


% --- Executes just before Utilities is made visible.
function Utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Utilities (see VARARGIN)

% Choose default command line output for Utilities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Utilities wait for user response (see UIRESUME)
% uiwait(handles.UtilitiesFigure);


% --- Outputs from this function are returned to the command line.
function varargout = Utilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PANDA_TBSSButton.
function PANDA_TBSSButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_TBSSButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_TBSS;


% --- Executes on button press in PANDA_BedpostxButton.
function PANDA_BedpostxButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_BedpostxButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Bedpostx;


% --- Executes on button press in PANDA_FiberTrackingButton.
function PANDA_FiberTrackingButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_FiberTrackingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Tracking;


% --- Executes on button press in PANDA_NetworkNodeButton.
function PANDA_NetworkNodeButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_NetworkNodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_BrainParcellation;


% --- Executes on button press in PANDA_ImageFormatConvertButton.
function PANDA_ImageFormatConvertButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ImageFormatConvertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ImageConverter;


% --- Executes on button press in PANDA_DICOMSorterButton.
function PANDA_DICOMSorterButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_DICOMSorterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_DICOMSorter;


% --- Executes on button press in CopyFilesButton.
function CopyFilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to CopyFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_FileCopyer;
