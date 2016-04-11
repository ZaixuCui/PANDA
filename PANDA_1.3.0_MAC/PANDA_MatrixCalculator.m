function varargout = PANDA_MatrixCalculator(varargin)
% PANDA_MATRIXCALCULATOR MATLAB code for PANDA_MatrixCalculator.fig
%      PANDA_MATRIXCALCULATOR, by itself, creates a new PANDA_MATRIXCALCULATOR or raises the existing
%      singleton*.
%
%      H = PANDA_MATRIXCALCULATOR returns the handle to a new PANDA_MATRIXCALCULATOR or the handle to
%      the existing singleton*.
%
%      PANDA_MATRIXCALCULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_MATRIXCALCULATOR.M with the given input arguments.
%
%      PANDA_MATRIXCALCULATOR('Property','Value',...) creates a new PANDA_MATRIXCALCULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_MatrixCalculator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_MatrixCalculator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_MatrixCalculator

% Last Modified by GUIDE v2.5 22-Jul-2015 19:08:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_MatrixCalculator_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_MatrixCalculator_OutputFcn, ...
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


% --- Executes just before PANDA_MatrixCalculator is made visible.
function PANDA_MatrixCalculator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_MatrixCalculator (see VARARGIN)

% Choose default command line output for PANDA_MatrixCalculator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_MatrixCalculator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_MatrixCalculator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


