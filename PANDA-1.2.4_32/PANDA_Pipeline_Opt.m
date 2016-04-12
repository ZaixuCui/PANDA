function varargout = PANDA_Pipeline_Opt(varargin)
% GUI for Setting Pipeline Options (part of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_PIPELINE_OPT MATLAB code for PANDA_Pipeline_Opt.fig
%      PANDA_PIPELINE_OPT, by itself, creates a new PANDA_PIPELINE_OPT or raises the existing
%      singleton*.
%
%      H = PANDA_PIPELINE_OPT returns the handle to a new PANDA_PIPELINE_OPT or the handle to
%      the existing singleton*.
%
%      PANDA_PIPELINE_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_PIPELINE_OPT.M with the given input arguments.
%
%      PANDA_PIPELINE_OPT('Property','Value',...) creates a new PANDA_PIPELINE_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Pipeline_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Pipeline_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Pipeline_Opt

% Last Modified by GUIDE v2.5 20-Oct-2012 15:45:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Pipeline_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Pipeline_Opt_OutputFcn, ...
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


% --- Executes just before PANDA_Pipeline_Opt is made visible.
function PANDA_Pipeline_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Pipeline_Opt (see VARARGIN)

% Choose default command line output for PANDA_Pipeline_Opt
global pipeline_opt;
global LockFlag;
global DestinationPath_Edit;
global PipelineModeTagPrevious;
global FlagVerboseTagPrevious;
global PipelineOpt_ParametersChangeFlag;

PipelineOpt_ParametersChangeFlag = 0;

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_Pipeline_Opt wait for user response (see UIRESUME)
% uiwait(handles.PipelineOptFigure);
% Set the initial value of pipeline mode
if ~isfield(pipeline_opt,'mode')
    pipeline_opt.mode = 'batch';
    set( handles.batchRadio, 'Value', 1 );
    PipelineModeTagPrevious = 'batch';
elseif strcmp( pipeline_opt.mode,'batch' )
    set( handles.batchRadio, 'Value', 1 );
    PipelineModeTagPrevious = 'batch';
else
    set( handles.qsubRadio, 'Value', 1 );
    PipelineModeTagPrevious = 'qsub';
end
% Set the initial value of flag verbose
pipeline_opt.flag_verbose = 0;

% Set the initial value of max_queued
if ~isfield(pipeline_opt,'max_queued')
    if ismac
        try
            [a,QuantityOfCpu] = system('sysctl -n machdep.cpu.core_count');
        catch
            QuantityOfCpu = '';
        end
    elseif isunix
        try
            [a,QuantityOfCpu] = system('cat /proc/cpuinfo | grep processor | wc -l');
        catch
            QuantityOfCpu = '';
        end
    end
    if ~isempty(QuantityOfCpu)
        pipeline_opt.max_queued = str2num(QuantityOfCpu);
    else
        pipeline_opt.max_queued = 2;
    end
end
set(handles.MaxQueuedEdit, 'string', num2str(pipeline_opt.max_queued));
% Set the initial value of qsub_options
if strcmp( pipeline_opt.mode,'qsub' )
    set( handles.QsubOptionsEdit, 'Enable', 'on' );
    if ~isfield(pipeline_opt,'qsub_options')
        pipeline_opt.qsub_options = '-q all.q';
    end
    set( handles.QsubOptionsEdit, 'string', pipeline_opt.qsub_options );
else
    set( handles.QsubOptionsEdit, 'Enable', 'off' );
    set( handles.QsubOptionsEdit, 'string', '' );
end

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if exist( LockFilePath, 'file' )
    set( handles.MaxQueuedEdit, 'Enable', 'off' );
    set( handles.QsubOptionsEdit, 'Enable', 'off' );
    % LockFlag is used to set radio group unable
    LockFlag = 1;
else
    LockFlag = 0;
end

%
TipStr = sprintf('If PANDA runs in a single computer, please select ''batch''.');
set(handles.batchRadio, 'TooltipString', TipStr);
%
TipStr = sprintf(['If PANDA runs in a distributed environment such as SGE,' ...
    '\n please select ''qsub''.']);
set(handles.qsubRadio, 'TooltipString', TipStr);
%
TipStr = sprintf('Set the quantity of maximum jobs running in parallel.');
set(handles.MaxQueuedEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('Set the options of qsub, such as ''-q all.q'', ''-q all.q -p 8''.');
set(handles.QsubOptionsEdit, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Pipeline_Opt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function batchRadio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batchRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function qsubRadio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qsubRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function PipelineModeUipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PipelineModeUipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in PipelineModeUipanel.
function PipelineModeUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PipelineModeUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global pipeline_opt;
global PipelineModeTagPrevious;
global LockFlag;
global PipelineOpt_ParametersChangeFlag;
if LockFlag == 0
    if ~strcmp(PipelineModeTagPrevious, get( hObject, 'Tag'))
        PipelineOpt_ParametersChangeFlag = 1;
    end
    switch get( hObject, 'Tag')
        case 'batchRadio'
            pipeline_opt.mode = 'batch';    
            PipelineModeTagPrevious = 'batch';
            % Make QsubOptionsEdit edit text unavailable
            set( handles.QsubOptionsEdit, 'Enable', 'off' );
            set( handles.QsubOptionsEdit, 'string', '');
            pipeline_opt.qsub_options = '';
            if ismac
                try
                    [a,QuantityOfCpu] = system('sysctl -n machdep.cpu.core_count');
                catch
                    QuantityOfCpu = '';
                end
            elseif isunix
                try
                    [a,QuantityOfCpu] = system('cat /proc/cpuinfo | grep processor | wc -l');
                catch
                    QuantityOfCpu = '';
                end
            end
            if ~isempty(QuantityOfCpu)
                pipeline_opt.max_queued = str2num(QuantityOfCpu);
                set( handles.MaxQueuedEdit, 'string', num2str(pipeline_opt.max_queued) );
            else
                pipeline_opt.max_queued = 2;
            end
        case 'qsubRadio'
            pipeline_opt.mode = 'qsub';
            PipelineModeTagPrevious = 'qsub';
            % Make QsubOptionsEdit edit text available
            set( handles.QsubOptionsEdit, 'Enable', 'on' );
            if ~isfield(pipeline_opt,'qsub_options') 
                pipeline_opt.qsub_options = '-q all.q';
            end
            if isempty(pipeline_opt.qsub_options)
                pipeline_opt.qsub_options = '-q all.q';
            end
            set( handles.QsubOptionsEdit, 'string', pipeline_opt.qsub_options );
            set( handles.MaxQueuedEdit, 'string', '40' );
            pipeline_opt.max_queued = 40;
    end
else
    switch PipelineModeTagPrevious
        case 'batch'
            set( handles.batchRadio, 'Value', 1 );
        case 'qsub'
            set( handles.qsubRadio, 'Value', 1 );
    end
end


function MaxQueuedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxQueuedEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxQueuedEdit as a double
global pipeline_opt;
global PipelineOpt_ParametersChangeFlag;
MaxQueuedPrevious = pipeline_opt.max_queued;
MaxQueuedString = get( hObject, 'string');
pipeline_opt.max_queued = str2num(MaxQueuedString);
if MaxQueuedPrevious ~= pipeline_opt.max_queued
    PipelineOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function MaxQueuedEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on key press with focus on MaxQueuedEdit and none of its controls.
function MaxQueuedEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


function QsubOptionsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to QsubOptionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QsubOptionsEdit as text
%        str2double(get(hObject,'String')) returns contents of QsubOptionsEdit as a double
global pipeline_opt;
global PipelineOpt_ParametersChangeFlag;
QsubOptionsPrevious = pipeline_opt.qsub_options;
QsubOptionsString = get( hObject, 'string');
pipeline_opt.qsub_options = QsubOptionsString;
if ~strcmp(QsubOptionsPrevious, pipeline_opt.qsub_options)
    PipelineOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function QsubOptionsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QsubOptionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal( get(hObject,'BackgroundColor' ), get( 0,'defaultUicontrolBackgroundColor') )
set( hObject,'BackgroundColor','white' );
%end



% --- Executes on key press with focus on QsubOptionsEdit and none of its controls.
function QsubOptionsEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to QsubOptionsEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% handles    structure with handles and user data (see GUIDATA)
MaxQueued_Text = get( handles.MaxQueuedEdit, 'string' );
if isempty(MaxQueued_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the max queued !');
end

% --- Executes on button press in OkButton.
function OkButton_Callback(hObject, eventdata, handles)
% hObject    handle to OkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Excute 'close' command, it will call PipelineOptFigure_CloseRequestFcn function 
global pipeline_opt;
global LockFlag;
global PipelineOpt_ParametersChangeFlag;

if LockFlag == 0
    if isempty(pipeline_opt.max_queued)
        msgbox('Please input the max queued !');
    elseif strcmp(pipeline_opt.mode,'qsub') & isempty(pipeline_opt.qsub_options)
        msgbox('Please input the qsub options !');
    else
        if PipelineOpt_ParametersChangeFlag
            Check_info{1} = [' pipeline mode = ' pipeline_opt.mode];
            Check_info{2} = [' max queued = ' num2str(pipeline_opt.max_queued)];
            if strcmp(pipeline_opt.mode,'qsub')
                Check_info{3} = [' qsub options = ' pipeline_opt.qsub_options];
            end
            button = questdlg( Check_info, 'Please check!', 'Yes', 'No', 'No');
            if strcmp(button,'Yes')
                close;
            end
        else
            close;
        end
    end
else
    close;
end 


% --- Executes when user attempts to close PipelineOptFigure.
function PipelineOptFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PipelineOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
 delete(hObject);


% --- Executes during object creation, after setting all properties.
function OkButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over OkButton.
function OkButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to OkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function CancelButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when PipelineOptFigure is resized.
function PipelineOptFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PipelineOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)   
    PositionFigure = get(handles.PipelineOptFigure, 'Position');
    FontSizePipelineModeUipanel = ceil(10 * PositionFigure(4) / 172);
    set( handles.PipelineModeUipanel, 'FontSize', FontSizePipelineModeUipanel );
end


% --- Executes on button press in MaxQueuedText.
function MaxQueuedText_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in QsubOptionsText.
function QsubOptionsText_Callback(hObject, eventdata, handles)
% hObject    handle to QsubOptionsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
