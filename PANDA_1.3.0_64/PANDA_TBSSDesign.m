function varargout = PANDA_TBSSDesign(varargin)
% GUI for guide of design matrix construction in FSL (an independent component of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_TBSSDESIGN MATLAB code for PANDA_TBSSDesign.fig
%      PANDA_TBSSDESIGN, by itself, creates a new PANDA_TBSSDESIGN or raises the existing
%      singleton*.
%
%      H = PANDA_TBSSDESIGN returns the handle to a new PANDA_TBSSDESIGN or the handle to
%      the existing singleton*.
%
%      PANDA_TBSSDESIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_TBSSDESIGN.M with the given input arguments.
%
%      PANDA_TBSSDESIGN('Property','Value',...) creates a new PANDA_TBSSDESIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_TBSSDesign_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_TBSSDesign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_TBSSDesign

% Last Modified by GUIDE v2.5 15-Jun-2015 02:52:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_TBSSDesign_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_TBSSDesign_OutputFcn, ...
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


% --- Executes just before PANDA_TBSSDesign is made visible.
function PANDA_TBSSDesign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_TBSSDesign (see VARARGIN)

% Choose default command line output for PANDA_TBSSDesign
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_TBSSDesign wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_TBSSDesign_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
