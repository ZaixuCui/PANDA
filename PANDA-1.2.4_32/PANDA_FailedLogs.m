function varargout = PANDA_FailedLogs(varargin)
% GUI for displaying the logs of failed jobs (part of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_FAILEDLOGS MATLAB code for PANDA_FailedLogs.fig
%      PANDA_FAILEDLOGS, by itself, creates a new PANDA_FAILEDLOGS or raises the existing
%      singleton*.
%
%      H = PANDA_FAILEDLOGS returns the handle to a new PANDA_FAILEDLOGS or the handle to
%      the existing singleton*.
%
%      PANDA_FAILEDLOGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_FAILEDLOGS.M with the given input arguments.
%
%      PANDA_FAILEDLOGS('Property','Value',...) creates a new PANDA_FAILEDLOGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_FailedLogs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_FailedLogs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_FailedLogs

% Last Modified by GUIDE v2.5 20-Nov-2012 11:19:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_FailedLogs_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_FailedLogs_OutputFcn, ...
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


% --- Executes just before PANDA_FailedLogs is made visible.
function PANDA_FailedLogs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_FailedLogs (see VARARGIN)

% Choose default command line output for PANDA_FailedLogs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_FailedLogs wait for user response (see UIRESUME)
% uiwait(handles.FailedLogsFigure);
global PANDALogs;
global LogsPath;

PANDALogs = varargin{1};
FailedJobNames = varargin{2};
LogsPath = varargin{3};
FailedJobNames = reshape(FailedJobNames, length(FailedJobNames), 1);
set(handles.FailedJobsTable, 'data', FailedJobNames);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_FailedLogs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


% --- Executes when FailedLogsFigure is resized.
function FailedLogsFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to FailedLogsFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.FailedLogsFigure, 'Position');
    ResizeFailedJobsTable(handles);
end

function ResizeFailedJobsTable(handles)
FailedJobs = get(handles.FailedJobsTable, 'data');
PositionFigure = get(handles.FailedLogsFigure, 'Position');
WidthCell{1} = PositionFigure(3);
WidthCell{2} = 0;
if ~isempty(FailedJobs)
    for i = 1:length(FailedJobs)
        tmp{i} = length(FailedJobs{i}) * 8;
        tmp{i} = tmp{i} * PositionFigure(4) / 264;
    end
    NewWidth = max(cell2mat(tmp));
    if NewWidth > WidthCell{1}
        WidthCell{1} =  NewWidth;
    end
end
set(handles.FailedJobsTable, 'ColumnWidth', WidthCell);


% --- Executes when selected cell(s) is changed in FailedJobsTable.
function FailedJobsTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to FailedJobsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global PANDALogs;
global LogsPath;
FailedJobNames = get(hObject, 'data');
if ~isempty(eventdata.Indices)
    SelectFailedJobNum = eventdata.Indices(1);
    ErrorMessageFolder = [LogsPath filesep 'FailedLogs'];
    if ~exist(ErrorMessageFolder)
        mkdir(ErrorMessageFolder);
    end
    ErrorMessageFile = [ErrorMessageFolder filesep FailedJobNames{SelectFailedJobNum} '.loginfo'];
    if ~exist(ErrorMessageFile)
        fid = fopen(ErrorMessageFile, 'w');
        FailedJobMessage = PANDALogs.(FailedJobNames{SelectFailedJobNum});
        StarLocation = find(FailedJobMessage == '*');
        FailedJobMessage(1: StarLocation - 1) = '';
        fprintf(fid, '%s\n\n', '***************************************************************************');
        fprintf(fid, '%s\n\n', ['                     JobName: ' FailedJobNames{SelectFailedJobNum} '                        ']);
        fprintf(fid, '%s\n\n', '                      Status:   failed                                    ');
        fprintf(fid, '%s\n\n', '***************************************************************************');
        fprintf(fid, '%s\n\n\n', FailedJobMessage);
        fclose(fid);
    end
    edit (ErrorMessageFile);
    set(handles.FailedJobsTable, 'data', '');
    set(handles.FailedJobsTable, 'data', FailedJobNames);
end


% --------------------------------------------------------------------
function FailedJobsTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FailedJobsTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close FailedLogsFigure.
function FailedLogsFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to FailedLogsFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global LogsPath;
ErrorMessageFolder = [LogsPath filesep 'FailedLogs'];
system(['rm -rf ' ErrorMessageFolder]);
delete(hObject);
