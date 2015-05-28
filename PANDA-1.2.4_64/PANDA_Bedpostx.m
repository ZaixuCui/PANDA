function varargout = PANDA_Bedpostx(varargin)
% GUI for Bedpostx (an independent component of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_BEDPOSTX MATLAB code for PANDA_Bedpostx.fig
%      PANDA_BEDPOSTX, by itself, creates a new PANDA_BEDPOSTX or raises the existing
%      singleton*.
%
%      H = PANDA_BEDPOSTX returns the handle to a new PANDA_BEDPOSTX or the handle to
%      the existing singleton*.
%
%      PANDA_BEDPOSTX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_BEDPOSTX.M with the given input arguments.
%
%      PANDA_BEDPOSTX('Property','Value',...) creates a new PANDA_BEDPOSTX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Bedpostx_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Bedpostx_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Bedpostx

% Last Modified by GUIDE v2.5 01-Oct-2012 13:45:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Bedpostx_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Bedpostx_OutputFcn, ...
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


% --- Executes just before PANDA_Bedpostx is made visible.
function PANDA_Bedpostx_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Bedpostx (see VARARGIN)

% Choose default command line output for PANDA_Bedpostx
global BedpostxAlone_opt;
global NativePathCellBedpostx;
global BedpostxPipeline_opt;
global PANDAPath;

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

% UIWAIT makes PANDA_Bedpostx wait for user response (see UIRESUME)
% uiwait(handles.PANDABedpostxFigure);
NativePathCellBedpostx = '';
% Pipeline options
BedpostxPipeline_opt.flag_verbose = 0;
BedpostxPipeline_opt.flag_pause = 0;
set( handles.batchRadio, 'Value', 1);
BedpostxPipeline_opt.mode = 'background';
set( handles.QsubOptionsEdit, 'String', '');
set( handles.QsubOptionsEdit, 'Enable', 'off');
BedpostxPipeline_opt.qsub_options = '';
% Set the initial value of max_queued
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
    BedpostxPipeline_opt.max_queued = str2num(QuantityOfCpu);
else
    BedpostxPipeline_opt.max_queued = 2;
end
set(handles.MaxQueuedEdit, 'string', num2str(BedpostxPipeline_opt.max_queued));
BedpostxPipeline_opt.path_logs = [pwd filesep 'Bedpostx_logs'];
set(handles.LogPathEdit, 'String', pwd);
%
if ~isfield(BedpostxAlone_opt, 'Fibers')
    BedpostxAlone_opt.Fibers = 2;
end
set( handles.FibersEdit, 'String', num2str(BedpostxAlone_opt.Fibers));
if ~isfield(BedpostxAlone_opt, 'Weight')
    BedpostxAlone_opt.Weight = 1;
end
set( handles.WeightEdit, 'String', num2str(BedpostxAlone_opt.Weight));
if ~isfield(BedpostxAlone_opt, 'Burnin')
    BedpostxAlone_opt.Burnin = 1000;
end
set( handles.BurninEdit, 'String', num2str(BedpostxAlone_opt.Burnin));
% Set the Status Table to default
JobStatusCell = cell(4,4);
set( handles.JobStatusTable, 'data', JobStatusCell );
% Set icon
SetIcon(handles);
%
TipStr = sprintf(['Full path of a folder containing four files as listed:' ...
    '\n    (1) A 4D image named data.nii.gz containing diffusion-weighted' ... 
    '\n        volumes and volumes without diffusion weighting.' ...
    '\n    (2) A 3D binary brain mask volume named nodif_brain_mask.nii.gz.' ...
    '\n    (3) A text file named bvecs containing gradient directions for' ...
    '\n        diffusion weighted volumes.' ...
    '\n    (4) A text file named bvals containing b-values applied for' ...
    '\n        each volume acquisition.']);
set(handles.AddNativeFolderButton, 'TooltipString', TipStr);
%
TipStr = sprintf('Number of fibers per voxel.');
set(handles.FibersEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('ARD weight, more weight means less secondary fibers per voxel.');
set(handles.WeightEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('Burnin period.');
set(handles.BurninEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('If PANDA runs in a single computer, please select ''background''.');
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
%
TipStr = sprintf('The path of the folder storing logs of jobs.');
set(handles.LogPathEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['Please report bugs or requests to:' ...
    '\n ' ...
    '\n Zaixu Cui: zaixucui@gmail.com' ...
    '\n Suyu Zhong: suyu.zhong@gmail.com' ...
    '\n Gaolang Gong (PI): gaolang.gong@gmail.com' ...
    '\n ' ...
    '\n National Laboratory of Cognitive Neuroscience and Learning' ...
    '\n Bejing Normal University' ...
    '\n Beijing, P.R.China, 100875']);
set(handles.HelpButton, 'TooltipString', TipStr);
set(handles.Image1, 'TooltipString', TipStr);
set(handles.Image2, 'TooltipString', TipStr);
%
TipStr = sprintf(['The logs of the failed jobs.' ...
    '\n 1. If some jobs'' are already in the GUI, the logs for current failed jobs will' ...
    '\n    display.' ...
    '\n 2. If the GUI is empty, please select the .PANDA configuration file of the jobs' ...
    '\n    you want to display the logs']);
set(handles.LogsButton, 'TooltipString', TipStr);
%
TipStr = sprintf('Clear the current GUI, and set input & output for another job.');
set(handles.ClearButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Terminate all the running jobs associated with the current input.' ...
    '\n Because all the jobs run in background, user can only terminate' ...
    '\n jobs by clicking this button.']);
set(handles.TerminateButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Load .PANDA_Bedpostx file to display the information in' ...
    '\n the GUI.']);
set(handles.LoadButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['After clicking the button, the information in the GUI' ...
    '\n will be saved in a .PANDA_Bedpostx file under ''Log_Path''.']);
set(handles.RUNButton, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Bedpostx_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function FibersEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FibersEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FibersEdit as text
%        str2double(get(hObject,'String')) returns contents of FibersEdit as a double
global BedpostxAlone_opt;
BedpostxAlone_opt.Fibers = str2num(get(hObject, 'String'));


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
global BedpostxAlone_opt;
BedpostxAlone_opt.Weight = str2num(get(hObject, 'String'));


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
global BedpostxAlone_opt;
BedpostxAlone_opt.Burnin = str2num(get(hObject, 'String'));


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


% --- Executes on button press in AddNativeFolderButton.
function AddNativeFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddNativeFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NativePathCellBedpostx;
NativePathCell_Button = get(hObject, 'UserData');
[a, NativePathCell, Done] = PANDA_Select('dir', NativePathCell_Button);
if Done == 1
    set(hObject, 'UserData', NativePathCell);
    if ~isempty(NativePathCell)
        NativePathCellBedpostx = NativePathCell;
        set(handles.NativeFolderTable, 'data', NativePathCellBedpostx);
    %     set(handles.NativeFolderListbox, 'Value', 1);
    %     set(handles.NativeFolderListbox, 'String', NativePathCellBedpostx);
    end
end

% --- Executes on button press in RUNButton.
function RUNButton_Callback(hObject, eventdata, handles)
% hObject    handle to RUNButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NativePathCellBedpostx;
global BedpostxAlone_opt;
global BedpostxPipeline_opt;
global LockExistBedpostx;
global LockDisappearBedpostx;
global JobStatusMonitorTimerBedpostx;
global BedpostxStopFlag;
global PANDAPath;
    
LockFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE.lock'];
if exist(LockFilePath, 'file') | strcmp(get(handles.AddNativeFolderButton, 'Enable'), 'off')
    StringPrint{1} = ['A lock file ' LockFilePath ' has been found on the pipeline !'];
    StringPrint{2} = 'If you want to run this new pipeline, ';
    StringPrint{3} = ['please delete the lock file ' LockFilePath ' first !'];
    msgbox(StringPrint);
else
    BedpostxInputFinish = 0;
    if isempty(NativePathCellBedpostx)
        msgbox('Please input subject folder which contain bvals, bvecs, data, nodif_brain_mask !');
    elseif isempty(BedpostxAlone_opt.Fibers)
        msgbox('Please input the number of fibers per voxel !');
    elseif isempty(BedpostxAlone_opt.Weight)
        msgbox('Please input ARD weight, more weight means less secondary fibers per voxel !')
    elseif isempty(BedpostxAlone_opt.Burnin)
        magbox('Please input burnin period !')
    elseif isempty(BedpostxPipeline_opt.max_queued)
        magbox('Please input the max queued of the pipeline !')
    elseif isempty(BedpostxPipeline_opt.path_logs)
        msgbox('Please input the path of log files !');
    elseif strcmp(BedpostxPipeline_opt.mode, 'qsub')
        if isempty(BedpostxPipeline_opt.qsub_options)
            msgbox('Please input the qsub options !');
        else
            BedpostxInputFinish = 1;
        end
    else
        BedpostxInputFinish = 1;
    end
    LogPathPermissionDenied = 0;
    try
        if ~exist(BedpostxPipeline_opt.path_logs, 'dir')
            mkdir(BedpostxPipeline_opt.path_logs);
        end
        x = 1;
        save([BedpostxPipeline_opt.path_logs filesep 'permission_tag'], 'x');
    catch
        LogPathPermissionDenied = 1;
        msgbox('Please change log path, perssion denied !');
    end
    if BedpostxInputFinish & ~LogPathPermissionDenied
        info{1} = 'Are you sure to Run ?';
        button = questdlg( info ,'Sure to Run ?','Yes','No','Yes' );
        if strcmp(button, 'Yes')
            % Save the configuration
            DateNow = datevec(datenum(now));
            DateNowString = [num2str(DateNow(1)) '_' num2str(DateNow(2), '%02d') '_' num2str(DateNow(3), '%02d') '_' num2str(DateNow(4), '%02d') '_' num2str(DateNow(5), '%02d')];
            ParameterSaveFilePath = [BedpostxPipeline_opt.path_logs  filesep DateNowString '.PANDA_Bedpostx'];
            
            cmdString = [ 'save ' ParameterSaveFilePath ' NativePathCellBedpostx' ' BedpostxAlone_opt' ' BedpostxPipeline_opt' ' PANDAPath'];
            eval(cmdString);
            if exist( ParameterSaveFilePath, 'file' )
                clc;
                disp( 'The variable is saved!' );
                disp( [ 'The full path is ' ParameterSaveFilePath ] );
                disp( 'The jobs will start running !' );
            else
                msgbox( 'Sorry, something has happened , the variables has not been saved!' );
            end
            % Excute the pipeline
            if ~exist(BedpostxPipeline_opt.path_logs)
                mkdir(BedpostxPipeline_opt.path_logs);
            end
            command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat'');'...
                'addpath(genpath(PANDAPath)); pipeline=g_Bedpostx_pipeline( NativePathCellBedpostx, BedpostxAlone_opt, BedpostxPipeline_opt );exit"'...
                ' >"' BedpostxPipeline_opt.path_logs filesep 'Bedpostx_pipeline.loginfo" 2>&1'];
            BedpostxPipelineShLocation = [BedpostxPipeline_opt.path_logs filesep 'Bedpostx_pipeline.sh'];
            fid = fopen(BedpostxPipelineShLocation, 'w');
            fprintf(fid, '%s', command);
            fclose(fid);
%             instr_batch = ['at -f "' BedpostxPipelineShLocation '" now'];
%             system(instr_batch);
            system(['. ' BedpostxPipelineShLocation ' &']);
            % Set edit box and button unable
%             set(handles.NativeFolderListbox, 'Enable', 'off');
%             set(handles.DeleteNativeFolderButton, 'Enable', 'off');
            set(handles.AddNativeFolderButton, 'Enable', 'off');
            set(handles.FibersEdit, 'Enable', 'off');
            set(handles.WeightEdit, 'Enable', 'off');
            set(handles.BurninEdit, 'Enable', 'off');
            set(handles.batchRadio, 'Enable', 'off');
            set(handles.qsubRadio, 'Enable', 'off');
            set(handles.MaxQueuedEdit, 'Enable', 'off');
            set(handles.QsubOptionsEdit, 'Enable', 'off');
            set(handles.LogPathEdit, 'Enable', 'off');
            set(handles.LogPathButton, 'Enable', 'off');
            % Set the initial value in the monitor table
            StatusFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE_status.mat'];
            % The initial status should be 'dcm2nii_dwi wait ...' for each job
            JobsStatus = cell(length(NativePathCellBedpostx), 4);
            for i = 1:length(NativePathCellBedpostx)
                JobsStatus{i, 1} = 'wait';
                JobsStatus{i, 2} = 'wait';
                JobsStatus{i, 3} = 'wait';
                JobsStatus{i, 4} = 'wait';
            end
            set( handles.JobStatusTable, 'data', JobsStatus);
            LockExistBedpostx = 0;
            LockDisappearBedpostx = 0;
            % Start monitor function
            BedpostxStopFlag = '';
            JobStatusMonitorTimerBedpostx = timer( 'TimerFcn', {@JobStatusMonitorBedpostx, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimerBedpostx);
%             end
        else
            return;
        end
    end
end


% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BedpostxAlone_opt;
global NativePathCellBedpostx;
global LockExistBedpostx;
global LockDisappearBedpostx;
global JobStatusMonitorTimerBedpostx;
global BedpostxPipeline_opt;

button = questdlg('Are you sure to Clear ?','Sure to Clear ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop Monitor
        if ~isempty(JobStatusMonitorTimerBedpostx)
            stop(JobStatusMonitorTimerBedpostx);
            clear global JobStatusMonitorTimerBedpostx;
        end
    
        clear global LockExistBedpostx;
        clear global LockDisappearBedpostx;

        BedpostxAlone_opt.Fibers = 2;
        set( handles.FibersEdit, 'Enable', 'on');
        set( handles.FibersEdit, 'String', num2str(BedpostxAlone_opt.Fibers));
        BedpostxAlone_opt.Weight = 1;
        set( handles.WeightEdit, 'Enable', 'on');
        set( handles.WeightEdit, 'String', num2str(BedpostxAlone_opt.Weight));
        BedpostxAlone_opt.Burnin = 1000;
        set( handles.BurninEdit, 'Enable', 'on');
        set( handles.BurninEdit, 'String', num2str(BedpostxAlone_opt.Burnin));
        NativePathCellBedpostx = '';
%         set(handles.NativeFolderListbox, 'Enable', 'on');
%         set(handles.NativeFolderListbox, 'Value', 1);
%         set(handles.NativeFolderListbox, 'String', '');
%         set(handles.DeleteNativeFolderButton, 'Enable', 'on');
        set(handles.AddNativeFolderButton, 'Enable', 'on');

        set(handles.batchRadio, 'Enable', 'on');
        set(handles.qsubRadio, 'Enable', 'on');
        set(handles.MaxQueuedEdit, 'Enable', 'on');
        if strcmp(BedpostxPipeline_opt.mode,'qsub')
            set(handles.QsubOptionsEdit, 'Enable', 'on');
        end
        set(handles.LogPathEdit, 'Enable', 'on');
        set(handles.LogPathButton, 'Enable', 'on');
        % Set back to default
        % Pipeline options
        BedpostxPipeline_opt.flag_verbose = 0;
        BedpostxPipeline_opt.flag_pause = 0;
        set( handles.batchRadio, 'Value', 1);
        BedpostxPipeline_opt.mode = 'background';
        set( handles.QsubOptionsEdit, 'String', '');
        set( handles.QsubOptionsEdit, 'Enable', 'off');
        BedpostxPipeline_opt.qsub_options = '';
        % Set the initial value of max_queued
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
            BedpostxPipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            BedpostxPipeline_opt.max_queued = 2;
        end
        set(handles.MaxQueuedEdit, 'string', num2str(BedpostxPipeline_opt.max_queued));
        BedpostxPipeline_opt.path_logs = [pwd filesep 'Bedpostx_logs'];
        set(handles.LogPathEdit, 'String', pwd);
        % Set the Status Table to default
        JobStatusCell = cell(4,4);
        set( handles.JobStatusTable, 'data', JobStatusCell );
    case 'No'
        return;
end  


% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Help;


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Image1.
function Image1_Callback(hObject, eventdata, handles)
% hObject    handle to Image1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Help;


% --- Executes on button press in Image2.
function Image2_Callback(hObject, eventdata, handles)
% hObject    handle to Image2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Help;


% --- Executes when user attempts to close PANDABedpostxFigure.
function PANDABedpostxFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDABedpostxFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global NativePathCellBedpostx;
global BedpostxAlone_opt;
global BedpostxPipeline_opt;
global JobStatusMonitorTimerBedpostx;

button = questdlg('Are you sure to quit ?','Sure to Quit ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop Monitor
        if ~isempty(JobStatusMonitorTimerBedpostx)
            stop(JobStatusMonitorTimerBedpostx);
            clear global JobStatusMonitorTimerBedpostx;
        end
    
        clear global NativePathCellBedpostx;
        clear global BedpostxAlone_opt;
        clear global BedpostxPipeline_opt;
        delete(hObject);
    case 'No'
        return;
end


% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


function MaxQueuedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxQueuedEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxQueuedEdit as a double
global BedpostxPipeline_opt;
BedpostxPipeline_opt.max_queued = str2num(get(hObject, 'String'));


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


function QsubOptionsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to QsubOptionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QsubOptionsEdit as text
%        str2double(get(hObject,'String')) returns contents of QsubOptionsEdit as a double
global BedpostxPipeline_opt;
BedpostxPipeline_opt.qsub_options = get(hObject, 'String');


% --- Executes during object creation, after setting all properties.
function QsubOptionsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QsubOptionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


function LogPathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LogPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LogPathEdit as text
%        str2double(get(hObject,'String')) returns contents of LogPathEdit as a double
global BedpostxPipeline_opt;
LogPath = get(hObject, 'String');
if ~exist(LogPath, 'dir')
    try
        mkdir(LogPath);
    catch
        msgbox('The path you input is illegal !');
    end
end
BedpostxPipeline_opt.path_logs = [LogPath filesep 'Bedpostx_logs'];


% --- Executes during object creation, after setting all properties.
function LogPathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LogPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in LogPathButton.
function LogPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BedpostxPipeline_opt;
LogPath = uigetdir;
if LogPath
    BedpostxPipeline_opt.path_logs = [LogPath filesep 'Bedpostx_logs'];
    set( handles.LogPathEdit, 'String', LogPath);
end


% --- Executes when selected object is changed in PipelineOptionsUipanel.
function PipelineOptionsUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PipelineOptionsUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global BedpostxPipeline_opt;
switch get(hObject, 'tag')
    case 'batchRadio'
        BedpostxPipeline_opt.mode = 'background';
        set( handles.QsubOptionsEdit, 'String', '');
        set( handles.QsubOptionsEdit, 'Enable', 'off');
        % Set the initial value of max_queued
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
            BedpostxPipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            BedpostxPipeline_opt.max_queued = 2;
        end
        set(handles.MaxQueuedEdit, 'string', num2str(BedpostxPipeline_opt.max_queued));
    case 'qsubRadio'
        BedpostxPipeline_opt.mode = 'qsub';
        BedpostxPipeline_opt.qsub_options = '-q all.q';
        set( handles.QsubOptionsEdit, 'Enable', 'on');
        set( handles.QsubOptionsEdit, 'String', '-q all.q');
        BedpostxPipeline_opt.max_queued = 40;
        set(handles.MaxQueuedEdit, 'string', num2str(BedpostxPipeline_opt.max_queued));
end


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NativePathCellBedpostx;
global BedpostxAlone_opt;
global BedpostxPipeline_opt;
global LockExistBedpostx;
global LockDisappearBedpostx;
global JobStatusMonitorTimerBedpostx;
global BedpostxStopFlag;

if strcmp(get(handles.AddNativeFolderButton, 'Enable'), 'off')
    msgbox('Please clear first !');
else
    NativePathCellBedpostx = '';
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_Bedpostx','Bedpostx-files (*.PANDA_Bedpostx)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        if ~isempty(BedpostxPipeline_opt.path_logs)
            LockFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE.lock'];
        end
        cmdString = ['load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
%         set( handles.NativeFolderListbox, 'Value', 1 );
%         set( handles.NativeFolderListbox, 'String', NativePathCellBedpostx );
        if strcmp(BedpostxPipeline_opt.mode,'background')
            set( handles.batchRadio, 'Value', 1 );
        else
            set( handles.qsubRadio, 'Value', 1 );
            set( handles.QsubOptionsEdit, 'Enable', 'on');
            set( handles.QsubOptionsEdit, 'string', BedpostxPipeline_opt.qsub_options);
        end
        set( handles.MaxQueuedEdit, 'string', num2str(BedpostxPipeline_opt.max_queued) );
        [LogParent, y, z] = fileparts(BedpostxPipeline_opt.path_logs);
        set( handles.LogPathEdit, 'string', LogParent );
        % Display advanced options
        set( handles.FibersEdit, 'string', num2str(BedpostxAlone_opt.Fibers) );
        set( handles.WeightEdit, 'string', num2str(BedpostxAlone_opt.Weight) );
        set( handles.BurninEdit, 'string', num2str(BedpostxAlone_opt.Burnin) );
        % Display job status in the Job Status Table
        LockFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE.lock'];
        if exist(LockFilePath, 'file')
            LockExistBedpostx = 1;
            LockDisappearBedpostx = 0;
            BedpostxStopFlag = ''; 
            JobStatusMonitorTimerBedpostx = timer( 'TimerFcn', {@JobStatusMonitorBedpostx, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimerBedpostx);
            % Set edit box and button unable
%             set(handles.NativeFolderListbox, 'Enable', 'off');
%             set(handles.DeleteNativeFolderButton, 'Enable', 'off');
            set(handles.AddNativeFolderButton, 'Enable', 'off');
            set(handles.FibersEdit, 'Enable', 'off');
            set(handles.WeightEdit, 'Enable', 'off');
            set(handles.BurninEdit, 'Enable', 'off');
            set(handles.batchRadio, 'Enable', 'off');
            set(handles.qsubRadio, 'Enable', 'off');
            set(handles.MaxQueuedEdit, 'Enable', 'off');
            set(handles.QsubOptionsEdit, 'Enable', 'off');
            set(handles.LogPathEdit, 'Enable', 'off');
            set(handles.LogPathButton, 'Enable', 'off');
        else
            BedpostxStopFlag = '(Stopped)'; 
            JobStatusMonitorBedpostx(hObject, eventdata, handles);
        end
    end
end


% --- Monitor Function
function JobStatusMonitorBedpostx(hObject, eventdata, handles)
global NativePathCellBedpostx;
global BedpostxAlone_opt;
global BedpostxPipeline_opt;
global LockExistBedpostx;
global LockDisappearBedpostx;
global JobStatusMonitorTimerBedpostx;
global BedpostxStopFlag;

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE.lock'];
if ~LockExistBedpostx & exist( LockFilePath, 'file' )
    LockExistBedpostx = 1;
end
if LockExistBedpostx & ~exist( LockFilePath, 'file' )
    LockDisappearBedpostx = 1;
end
ErrorFilePath = [BedpostxPipeline_opt.path_logs filesep 'Bedpostx_pipeline.error'];
if LockDisappearBedpostx == 1 | exist(ErrorFilePath, 'file') 
    % Set edit box enable
%     set(handles.NativeFolderListbox, 'Enable', 'on');
%     set(handles.DeleteNativeFolderButton, 'Enable', 'on');
    set(handles.AddNativeFolderButton, 'Enable', 'on');
    set(handles.FibersEdit, 'Enable', 'on');
    set(handles.WeightEdit, 'Enable', 'on');
    set(handles.BurninEdit, 'Enable', 'on');
    set(handles.batchRadio, 'Enable', 'on');
    set(handles.qsubRadio, 'Enable', 'on');
    set(handles.MaxQueuedEdit, 'Enable', 'on');
    if strcmp(BedpostxPipeline_opt.mode,'qsub')
        set(handles.QsubOptionsEdit, 'Enable', 'on');
    end
    set(handles.LogPathEdit, 'Enable', 'on');
    set(handles.LogPathButton, 'Enable', 'on');
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerBedpostx)
        stop(JobStatusMonitorTimerBedpostx);
        clear global JobStatusMonitorTimerBedpostx;
    end
    %
    if exist(ErrorFilePath, 'file')
        Info{1} = 'Something is wrong !';
        Info{2} = ['Please look up ' BedpostxPipeline_opt.path_logs filesep ...
                   'Bedpostx_pipeline.loginfo for more information !'];
        msgbox(Info);
        BedpostxStopFlag = '(Stopped)';
        delete(ErrorFilePath);
    end
end
        
StatusFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE_status_backup.mat'];
if exist( StatusFilePath, 'file' )
    warning('off');
    try    
        cmdString = ['load ' StatusFilePath];
        eval(cmdString);
        SubjectQuantity = length(NativePathCellBedpostx);
        JobQuantity = 12;
        SubjectIDArrayString = cell(SubjectQuantity, 1);
        StatusArray = cell(SubjectQuantity, 1);
        JobNameArray = cell(SubjectQuantity, 1);
        JobLeftArray = cell(SubjectQuantity, 1);
        for i = 1:SubjectQuantity 
        % Calculate job status of the ith subject 
            RunningJobName = '';
            WaitJobName = '';
            SubmittedJobName = '';
            FailedJobName = '';
            JobLeft = 0;
            StatusArray{i} = 'none';
            SubjectIDArrayString{i} = num2str(i,'%05.0f');
            JobName = { ['BedpostX_preproc_' SubjectIDArrayString{i}] };
            for j = 1:10
                JobName = [JobName {['BedpostX_' SubjectIDArrayString{i} '_' num2str(j, '%02d')]}];
            end
            JobName = [JobName {['BedpostX_postproc_' SubjectIDArrayString{i}]}];
            for j = 1:JobQuantity
                % Check the status of all jobs of the ith subject and  acquire
                % the status of the subject
                % The subject has three situations:
                %     1. 'failed': which job 
                %     2. 'running': which job
                %     3. 'submitted': which job
                %     4. 'wait': which job
                %     5. 'finished'
                VariableName = JobName{j};
                if strcmp(eval(VariableName), 'running')
                    JobLeft = JobLeft + 1;
                    if isempty(RunningJobName)
                        RunningJobName = JobName{j};
                    end
                elseif strcmp(eval(VariableName), 'submitted')
                    JobLeft = JobLeft + 1;
                    if isempty(SubmittedJobName)
                        SubmittedJobName = JobName{j};
                    end
                elseif strcmp(eval(VariableName), 'none')
                    JobLeft = JobLeft + 1;
                    if isempty(WaitJobName)
                        WaitJobName = JobName{j};
                    end
                elseif strcmp(eval(VariableName), 'failed')
                    JobLeft = JobLeft + 1;
                    if isempty(FailedJobName)
                        FailedJobName = JobName{j};
                    end
                end
            end  
            if isempty(RunningJobName) & isempty(SubmittedJobName) ...
                & isempty(WaitJobName) & isempty(FailedJobName)
                StatusArray{i} = ['finished'];
                JobNameArray{i} = '';
                JobLeftArray{i} = '0';
            elseif ~isempty(RunningJobName)
                StatusArray{i} = ['running' BedpostxStopFlag];
                JobNameArray{i} = RunningJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(SubmittedJobName)
                StatusArray{i} = ['submitted' BedpostxStopFlag];
                JobNameArray{i} = SubmittedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(FailedJobName)
                StatusArray{i} = ['failed' BedpostxStopFlag];
                JobNameArray{i} = FailedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(WaitJobName)
                StatusArray{i} = ['wait' BedpostxStopFlag];
                JobNameArray{i} = WaitJobName;
                JobLeftArray{i} = num2str(JobLeft);
            end
        end
        % Combine SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray
        % into a table
        SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray]; 
        set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
        % 
        JobsFinishFilePath = [BedpostxPipeline_opt.path_logs filesep 'jobs.finish'];
        if exist(JobsFinishFilePath, 'file')
            % Set edit box enable
%             set(handles.NativeFolderListbox, 'Enable', 'on');
%             set(handles.DeleteNativeFolderButton, 'Enable', 'on');
            set(handles.AddNativeFolderButton, 'Enable', 'on');
            set(handles.FibersEdit, 'Enable', 'on');
            set(handles.WeightEdit, 'Enable', 'on');
            set(handles.BurninEdit, 'Enable', 'on');
            set(handles.batchRadio, 'Enable', 'on');
            set(handles.qsubRadio, 'Enable', 'on');
            set(handles.MaxQueuedEdit, 'Enable', 'on');
            if strcmp(BedpostxPipeline_opt.mode,'qsub')
                set(handles.QsubOptionsEdit, 'Enable', 'on');
            end
            set(handles.LogPathEdit, 'Enable', 'on');
            set(handles.LogPathButton, 'Enable', 'on');
            % Stop Monitor
            if ~isempty(JobStatusMonitorTimerBedpostx)
                stop(JobStatusMonitorTimerBedpostx);
                clear global JobStatusMonitorTimerBedpostx;
            end
            % 
            msgbox('All jobs have been successfully completed.');
            delete(JobsFinishFilePath);
        end
    catch
        none = 0;
    end
    warning('on');
end


% --- Executes on button press in TerminateButton.
function TerminateButton_Callback(hObject, eventdata, handles)
% hObject    handle to TerminateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BedpostxStopFlag;
global BedpostxPipeline_opt;
global LockDisappearBedpostx;
global JobStatusMonitorTimerBedpostx;

LockFilePath = [BedpostxPipeline_opt.path_logs filesep 'PIPE.lock'];
if isempty(BedpostxPipeline_opt.path_logs) || ~exist(LockFilePath, 'file')
    msgbox('No job is running !');
else
    button = questdlg('Are you sure to terminal this job ?','Sure to terminal ?','Yes','No','Yes');
    switch button
        case 'Yes'   
            % Stop the monitor
            if ~isempty(JobStatusMonitorTimerBedpostx)
                stop(JobStatusMonitorTimerBedpostx);
                clear global JobStatusMonitorTimerBedpostx;
            end
            
            cmdString = ['rm -rf ' LockFilePath];
            system(cmdString);
            msgbox('The job is terminated sucessfully!');
            % Set edit box enable, Stop Monitor, Update job status table
            BedpostxStopFlag = '(Stopped)';
            while exist(LockFilePath, 'file')
            end
            LockDisappearBedpostx = 1;
            JobStatusMonitorBedpostx(hObject, eventdata, handles);
        case 'No'
            return;
    end
end


% Set Icon
function SetIcon(handles)
image_data(:,:,1)=[254  254  254  254  254  254  254  254  255  235  251  255  236  255  242  255  255  255  234  255  255  242  255  242  255  253  251  253  255  255  251  246  255  249  250  253  248  251  255  251  243  245  255  255  241
  254  254  254  254  254  254  254  254  241  255  255  238  255  249  236  247  245  241  255  246  239  255  255  255  253  253  253  253  253  254  255  255  251  253  255  255  255  255  251  251  255  248  244  250  253
  254  254  254  254  254  254  254  254  255  255  236  254  255  226  195  180  172  215  255  255  252  253  254  235  248  254  255  255  254  250  249  251  250  255  241  199  159  136  166  228  248  253  245  250  255
  253  253  253  253  253  253  253  253  255  248  249  255  159  123   94   78   24   40  174  237  254  251  190  208  188  181  171  164  169  186  209  226  255  254  156   40   27   68   88   95  174  238  255  250  255
  253  253  253  253  253  253  253  253  245  246  255  194  114  142  113   81   54    2    8  183  231  142  170  202  227  233  240  242  231  206  177  156  196  127   25    0   38   75  101  143  116  190  255  247  250
  252  252  252  252  252  252  252  252  255  251  238   96  124   91   22    0   11    0   15   85  174  244  255  247  252  246  241  241  244  246  243  239  207  104   11    0    6    0    0   73  108  135  233  248  255
  251  251  251  251  251  251  251  251  242  245  237   89  119   16    0    3    0    5   65  201  253  222  233  235  237  238  239  241  241  239  235  232  239  214  131   30    0   17   18    0   91   90  229  250  255
  251  251  251  251  251  251  251  251  251  253  208   70   54    0   15    0    0   77  208  232  225  247  234  241  236  239  240  238  233  231  234  237  222  247  222  118   15    0    4    5   53   63  239  245  245
  247  245  252  242  252  252  228  252  211  190  247   62    4    2    8    0   39  165  229  215  234  236  226  239  229  252  219  235  235  226  255  236  228  214  220  222   85    6    2    0   35   48  231  255  246
  252  252  216  222  228  241  252  208  119  252  222   79   38   51    0    5  103  206  231  238  240  255  253  248  255  229  254  233  252  241  240  223  228  248  219  200  175   45    0   43   12  125  255  255  244
  240  237  213  198  134  165  245  148  207  199  134  226  126   14    0   44  190  195  226  242  137   39   50   63  154  234  250  255  141   21    0   16  120  223  239  190  215   94    0   43  113  236  254  250  251
  252  252  236  239  249  193  149  177  198  185  222  193  135  123   79  115  185  196  226  116   22   56  129   84    3  175  236  152   22   78  114   74    0   86  197  213  203  146  111  129  238  255  231  249  255
  244  212  178  138  147  199  175   95  215  194  160  191  238  234  239  157  180  213  156    9   35  207  184  108   36   41  252   98   10   77  152  180   50    0   93  231  200  161  194  255  255  255  238  255  255
  236  225  202  233  232  179  166  159  169  209  220  218  202  229  234  168  198  194   38    5   77  158    0    0   57   81  255  145   73    0    0   89  129    8    8  186  206  162  193  255  249  236  250  255  240
  241  240  251  233  175  160  187  203  140  223  166  176  197  159  152  129  184  162    0    0   46  102   50  115  255  244  244  255  255  135   47  123   60    4    0  128  208  171  205  252  255  250  250  244  247
  251  251  238  143  182  219  145  219  175  123  193  175  153  182  191  151  208  127    9    0    5   47  199  255  165  134  169   88  152  255  213   66    1    2    4  124  206  153  219  249  248  255  252  253  255
  249  247  213  215  223  158  167  142  251  142  171  241  203  193  199  135  170  206   45    0    5   80  252  206    0   44  136   53    7  184  248  114    5    7   67  185  203  156  198  255  251  242  255  255  248
  243  251  244  233  153  196  143  217  218  216  148  202  177  148  163  162  164  186  211  170  119  157  214  223  122    2   12   21   99  251  220  175  121  177  215  205  184  139  255  243  255  247  250  253  255
  251  233  251  191  170  212  175  228  194  184  187  168  248  232  165  125  150  168  188  221  235  186  172  244  255  213  121  192  239  233  207  181  233  248  195  184  161  185  244  255  253  255  245  249  255
  251  236  247  174  239  212  231  190  181  171  251  182  210  251  251  234  141  183  173  184  206  168  162  209  232  245  216  255  247  224  167  195  229  187  188  175  125  255  251  235  228  255  255  252  255
  237  252  240  230  249  235  238  192  165  211  225  244  168  221  252  252  216  125  157  190  178  183  166  162  213  163  108  182  196  199  172  188  199  167  178  155  215  220  131  145  179  235  255  255  248
  244  252  249  247  241  252  219  212  174  240  241  205  107   88  114  205  255  177  138  174  185  188  195  156  138  124   66  154  160  164  217  193  191  193  154  174  189   78   16   97  128  173  247  255  243
  252  235  252  235  250  252  217  230  202  221  217  127  148  101   30   32  141  255  208  148  142  161  206  167  185  188  233  209  164  188  176  177  166  158  175  163    0    0   89  101  102  102  214  254  244
  246  248  249  252  245  244  224  252  222  252  156   81  101  117  107   28    0   73  172  161  142  156  151  183  173  174  167  173  176  177  185  152  159   85   79    7   12   25   86  123   97   56  186  252  246
  253  253  253  253  253  253  253  253  250  250  104   56   98  131   88   30   41   13    8   58  159  114  136  152  152  149  153  162  156  142  139  146  137  122   24   27   49   13   62  114   85   57  137  255  253
  253  253  253  253  253  253  253  253  254  235  130   30   73  127   88   40   50   44   45  123  197  186  173  160  149  153  157  155  153  159  175  191  200  204  122   42   41   14   63   88   69   37  182  241  255
  254  254  254  254  254  254  254  254  243  254  159   32   45   83  101   20   75   80   90  186  203  219  207  211  203  212  217  214  212  214  216  213  197  183  158   95   97   38   40   48    9   87  252  245  245
  254  254  254  254  254  254  254  254  255  242  237   78    3   31   27   58   66   63   98  196  186  201  204  223  216  206  197  196  202  208  211  211  205  219  195   67   22   27   23    8   62  197  255  255  230
  254  254  254  254  254  254  254  254  252  255  253  234  110   12   11   47   39   55  137  212  212  219  223  214  234  226  227  234  233  223  220  226  205  212  202  124   45   68   61   82  228  255  237  255  249
  254  254  254  254  254  254  254  254  246  230  255  255  228  189   75   55   40   95  211  236  229  235  255  243  241  248  255  255  254  242  240  246  255  245  250  219   77   64  126  255  255  245  255  236  255
  254  254  254  254  254  254  254  254  255  255  226  236  255  255  234  152   89   68   85   46   35   84  170  232  252  255  252  241  247  255  250  227  162  148  146  149  135  219  255  250  237  240  255  242  253
  254  254  254  254  254  254  254  254  247  255  255  249  255  238  255  254   61   14   49  101  118  100   63   71  228  249  254  248  255  240  147   40   48   44   52   45   59  165  255  252  254  255  234  255  250
  255  255  255  255  255  255  255  255  250  255  255  249  242  255  243   72   27  141  201  212  210  206  175   89   46  230  247  252  242  108   24  129  175  201  189  193  127    0  108  255  239  252  252  255  251
  255  255  255  255  255  255  255  255  255  255  253  253  253  252  149   12  111  166  174  165  159  165  167  124   41  107  255  249  159   21   97  144  150  164  183  170  178  121   45  151  253  255  250  253  253
  255  255  255  255  255  255  255  255  255  250  253  255  255  245   68   16  120  133  122  116  115  119  131  120   97   37  201  245   63   40  123  111  127  124  127  146  147  155   73   43  241  255  249  251  255
  255  255  255  255  255  255  255  255  253  250  255  253  255  240   30   69   75   82   85   91   93   91   93   89  109   49  151  223   10   71   86   97   97  100   91  103   83  109  102   24  200  252  252  252  255
  255  255  255  255  255  255  255  255  255  255  255  251  249  235   12   67   64   71   79   75   74   79   78   78   83   42  151  165   29   68   72   76   66   85   98   60   83   90   59   40  175  248  255  250  255
  255  255  255  255  255  255  255  255  255  252  248  255  253  246   32   29   50   53   66   56   56   68   62   65   63   37  172  171   36   53   67   48   60   65   63   57   79   55   64   21  193  253  255  249  251
  255  255  255  255  255  255  255  255  253  250  244  254  242  251   87   19   31   19   35   34   38   46   30   39   38   59  204  224   21   18   37   45   47   41   23   53   37   23   81   41  226  251  252  255  252
  255  255  255  255  255  255  255  255  251  255  246  245  213  235  128   30   46   11   15   14   20   23    5   24   57   59  176  204   62   29   23   10   12   20   40   20   14   49   27  114  245  241  241  255  255
  255  255  255  255  255  255  255  255  255  244  253  240  210  224  189   81   26   20   17   13    3    0   19   46   35   42   49   48   39   25   14    8    2    1    0    4   42   30   57  186  222  233  247  254  255
  255  255  255  255  255  255  255  255  255  247  255  251  221  228  225  177   76   50   30   30   38   44   54   65   97   96  100  109  109   86   45   11   30   40   46   25   30   76  150  241  232  241  251  255  255
  255  255  255  255  255  255  255  255  255  250  255  255  243  239  251  253  236  176  106   70   71   94  127  152  175  166  162  170  177  167  138  111   54   20   34   60  119  221  255  255  244  250  255  255  254
  255  255  255  255  255  255  255  255  255  252  249  255  255  252  249  255  255  255  252  251  248  241  238  241  223  222  220  220  222  227  231  233  243  204  219  236  244  255  255  235  251  254  255  255  253
  255  255  255  255  255  255  255  255  252  255  249  249  255  255  244  246  246  246  248  250  250  252  255  255  244  251  255  255  253  253  255  255  253  252  255  255  255  244  233  255  252  253  253  253  252];
image_data(:,:,2)=[254  254  254  254  254  254  254  254  255  235  251  255  236  255  242  255  255  255  234  255  255  242  255  242  255  253  251  253  255  255  251  246  255  249  250  253  248  251  255  251  243  245  255  255  241
  254  254  254  254  254  254  254  254  241  255  255  238  255  249  236  247  245  241  255  246  239  255  255  255  253  253  253  253  253  254  255  255  251  253  255  255  255  255  251  251  255  248  244  250  253
  254  254  254  254  254  254  254  254  255  255  236  254  255  226  195  180  172  215  255  255  252  253  254  235  248  254  255  255  254  250  249  251  250  255  241  199  159  136  166  228  248  253  245  250  255
  253  253  253  253  253  253  253  253  255  248  249  255  159  123   94   78   24   40  174  237  254  251  190  208  188  181  171  164  169  186  209  226  255  254  156   40   27   68   88   95  174  238  255  250  255
  253  253  253  253  253  253  253  253  245  246  255  194  114  142  113   81   54    2    8  183  231  142  170  202  227  233  240  242  231  206  177  156  196  127   25    0   38   75  101  143  116  190  255  247  250
  252  252  252  252  252  252  252  252  255  251  238   96  124   91   22    0   11    0   15   85  174  244  255  247  252  246  241  241  244  246  243  239  207  104   11    0    6    0    0   73  108  135  233  248  255
  253  253  253  253  253  253  253  253  244  247  239   91  121   18    1    5    0    5   65  201  253  222  233  235  237  238  239  241  241  239  235  232  239  214  131   30    0   17   18    0   91   90  229  250  255
  253  253  253  253  253  253  253  253  253  255  210   72   56    1   17    1    0   77  208  232  225  247  234  241  236  239  240  238  233  231  234  237  222  247  222  118   15    0    4    5   53   63  239  245  245
  252  250  255  247  255  255  233  255  216  195  252   67    9    7   13    1   39  165  229  215  234  236  226  239  229  252  219  235  235  226  255  236  228  214  220  222   85    6    2    0   35   48  231  255  246
  255  255  221  227  233  246  255  213  124  255  227   84   43   56    2   10  103  206  231  238  240  255  253  248  255  229  254  233  252  241  240  223  228  248  219  200  175   45    0   43   12  125  255  255  244
  245  242  218  203  139  170  250  153  212  204  139  231  131   19    5   49  190  195  226  242  137   39   50   63  154  234  250  255  141   21    0   16  120  223  239  190  215   94    0   43  113  236  254  250  251
  255  255  241  244  254  198  154  182  203  190  227  198  140  128   84  120  187  196  226  116   22   56  129   84    3  175  236  152   22   78  114   74    0   86  197  213  203  146  111  129  238  255  231  249  255
  251  219  185  145  154  206  182  102  222  201  167  198  245  241  246  162  182  213  156    9   35  207  184  108   36   41  252   98   10   77  152  180   50    0   93  231  200  161  194  255  255  255  238  255  255
  243  232  209  240  239  186  173  166  176  216  227  225  209  236  241  173  200  194   38    5   77  158    0    0   57   81  255  145   73    0    0   89  129    8    8  186  206  162  193  255  249  236  250  255  240
  248  247  255  240  182  167  194  210  147  230  173  183  204  166  159  134  186  162    0    0   46  102   50  115  255  244  244  255  255  135   47  123   60    4    0  128  208  171  205  252  255  250  250  244  247
  255  255  245  150  189  226  152  226  182  130  200  182  160  189  198  156  210  127    9    0    5   47  199  255  165  134  169   88  152  255  213   66    1    2    4  124  206  153  219  249  248  255  252  253  255
  255  254  220  222  230  165  174  149  255  149  178  248  210  200  206  140  172  206   45    0    5   80  252  206    0   44  136   53    7  184  248  114    5    7   67  185  203  156  198  255  251  242  255  255  248
  250  255  251  240  160  203  150  224  225  223  155  209  184  155  170  167  166  186  211  170  119  157  214  223  122    2   12   21   99  251  220  175  121  177  215  205  184  139  255  243  255  247  250  253  255
  255  240  255  198  177  219  182  235  201  191  194  175  255  239  172  130  152  168  188  221  235  186  172  244  255  213  121  192  239  233  207  181  233  248  195  184  161  185  244  255  253  255  245  249  255
  255  243  254  181  246  219  238  197  188  178  255  189  217  255  255  239  143  183  173  184  206  168  162  209  232  245  216  255  247  224  167  195  229  187  188  175  125  255  251  235  228  255  255  252  255
  242  255  245  235  254  240  243  197  170  216  230  249  173  226  255  255  218  125  157  190  178  183  166  162  213  163  108  182  196  199  172  188  199  167  178  155  215  220  131  145  179  235  255  255  248
  249  255  254  252  246  255  224  217  179  245  246  210  112   93  119  210  255  177  138  174  185  188  195  156  138  124   66  154  160  164  217  193  191  193  154  174  189   78   16   97  128  173  247  255  243
  255  240  255  240  255  255  222  235  207  226  222  132  153  106   35   37  141  255  208  148  142  161  206  167  185  188  233  209  164  188  176  177  166  158  175  163    0    0   89  101  102  102  214  254  244
  251  253  254  255  250  249  229  255  227  255  161   86  106  122  112   30    0   73  172  161  142  156  151  183  173  174  167  173  176  177  185  152  159   85   79    7   12   25   86  123   97   56  186  252  246
  255  255  255  255  255  255  255  255  252  252  106   58  100  133   90   32   41   13    8   58  159  114  136  152  152  149  153  162  156  142  139  146  137  122   24   27   49   13   62  114   85   57  137  255  253
  255  255  255  255  255  255  255  255  255  237  132   32   75  129   90   42   50   44   45  123  197  186  173  160  149  153  157  155  153  159  175  191  200  204  122   42   41   14   63   88   69   37  182  241  255
  254  254  254  254  254  254  254  254  243  254  159   32   45   83  101   20   75   80   90  186  203  219  207  211  203  212  217  214  212  214  216  213  197  183  158   95   97   38   40   48    9   87  252  245  245
  254  254  254  254  254  254  254  254  255  242  237   78    3   31   27   58   66   63   98  196  186  201  204  223  216  206  197  196  202  208  211  211  205  219  195   67   22   27   23    8   62  197  255  255  230
  254  254  254  254  254  254  254  254  252  255  253  234  110   12   11   47   39   55  137  212  212  219  223  214  234  226  227  234  233  223  220  226  205  212  202  124   45   68   61   82  228  255  237  255  249
  254  254  254  254  254  254  254  254  246  230  255  255  228  189   75   55   40   95  211  236  229  235  255  243  241  248  255  255  254  242  240  246  255  245  250  219   77   64  126  255  255  245  255  236  255
  254  254  254  254  254  254  254  254  255  255  226  236  255  255  234  152   89   68   85   46   35   84  170  232  252  255  252  241  247  255  250  227  162  148  146  149  135  219  255  250  237  240  255  242  253
  254  254  254  254  254  254  254  254  247  255  255  249  255  238  255  254   61   14   49  101  118  100   63   71  228  249  254  248  255  240  147   40   48   44   52   45   59  165  255  252  254  255  234  255  250
  255  255  255  255  255  255  255  255  250  255  255  249  242  255  243   72   27  141  201  212  210  206  175   89   46  230  247  252  242  108   24  129  175  201  189  193  127    0  108  255  239  252  252  255  251
  255  255  255  255  255  255  255  255  255  255  253  253  253  252  149   12  111  166  174  165  159  165  167  124   41  107  255  249  159   21   97  144  150  164  183  170  178  121   45  151  253  255  250  253  253
  255  255  255  255  255  255  255  255  255  250  253  255  255  245   68   16  120  133  122  116  115  119  131  120   97   37  201  245   63   40  123  111  127  124  127  146  147  155   73   43  241  255  249  251  255
  255  255  255  255  255  255  255  255  253  250  255  253  255  240   30   69   75   82   85   91   93   91   93   89  109   49  151  223   10   71   86   97   97  100   91  103   83  109  102   24  200  252  252  252  255
  255  255  255  255  255  255  255  255  255  255  255  251  249  235   12   67   64   71   79   75   74   79   78   78   83   42  151  165   29   68   72   76   66   85   98   60   83   90   59   40  175  248  255  250  255
  255  255  255  255  255  255  255  255  255  252  248  255  253  246   32   29   50   53   66   56   56   68   62   65   63   37  172  171   36   53   67   48   60   65   63   57   79   55   64   21  193  253  255  249  251
  255  255  255  255  255  255  255  255  253  250  244  254  242  251   87   19   31   19   35   34   38   46   30   39   38   59  204  224   21   18   37   45   47   41   23   53   37   23   81   41  226  251  252  255  252
  255  255  255  255  255  255  255  255  251  255  246  245  213  235  128   30   46   11   15   14   20   23    5   24   57   59  176  204   62   29   23   10   12   20   40   20   14   49   27  114  245  241  241  255  255
  255  255  255  255  255  255  255  255  255  244  253  240  210  224  189   81   26   20   17   13    3    0   19   46   35   42   49   48   39   25   14    8    2    1    0    4   42   30   57  186  222  233  247  254  255
  255  255  255  255  255  255  255  255  255  247  255  251  221  228  225  177   76   50   30   30   38   44   54   65   97   96  100  109  109   86   45   11   30   40   46   25   30   76  150  241  232  241  251  255  255
  255  255  255  255  255  255  255  255  255  250  255  255  243  239  251  253  236  176  106   70   71   94  127  152  175  166  162  170  177  167  138  111   54   20   34   60  119  221  255  255  244  250  255  255  254
  255  255  255  255  255  255  255  255  255  252  249  255  255  252  249  255  255  255  252  251  248  241  238  241  223  222  220  220  222  227  231  233  243  204  219  236  244  255  255  235  251  254  255  255  253
  255  255  255  255  255  255  255  255  252  255  249  249  255  255  244  246  246  246  248  250  250  252  255  255  244  251  255  255  253  253  255  255  253  252  255  255  255  244  233  255  252  253  253  253  252];
image_data(:,:,3)=[254  254  254  254  254  254  254  254  255  235  251  255  236  255  242  255  255  255  234  255  255  242  255  242  255  253  251  253  255  255  251  246  255  249  250  253  248  251  255  251  243  245  255  255  241
  254  254  254  254  254  254  254  254  241  255  255  238  255  249  236  247  245  241  255  246  239  255  255  255  253  253  253  253  253  254  255  255  251  253  255  255  255  255  251  251  255  248  244  250  253
  254  254  254  254  254  254  254  254  255  255  236  254  255  226  195  180  172  215  255  255  252  253  254  235  248  254  255  255  254  250  249  251  250  255  241  199  159  136  166  228  248  253  245  250  255
  253  253  253  253  253  253  253  253  255  248  249  255  159  123   94   78   24   40  174  237  254  251  190  208  188  181  171  164  169  186  209  226  255  254  156   40   27   68   88   95  174  238  255  250  255
  253  253  253  253  253  253  253  253  245  246  255  194  114  142  113   81   54    2    8  183  231  142  170  202  227  233  240  242  231  206  177  156  196  127   25    0   38   75  101  143  116  190  255  247  250
  252  252  252  252  252  252  252  252  255  251  238   96  124   91   22    0   11    0   15   85  174  244  255  247  252  246  241  241  244  246  243  239  207  104   11    0    6    0    0   73  108  135  233  248  255
  250  250  250  250  250  250  250  250  241  244  236   88  118   15    0    2    0    5   65  201  253  222  233  235  237  238  239  241  241  239  235  232  239  214  131   30    0   17   18    0   91   90  229  250  255
  250  250  250  250  250  250  250  250  250  252  207   69   53    0   14    0    0   77  208  232  225  247  234  241  236  239  240  238  233  231  234  237  222  247  222  118   15    0    4    5   53   63  239  245  245
  246  244  251  241  251  251  227  251  210  189  246   61    3    1    7    0   39  165  229  215  234  236  226  239  229  252  219  235  235  226  255  236  228  214  220  222   85    6    2    0   35   48  231  255  246
  251  251  215  221  227  240  251  207  118  251  221   78   37   50    0    4  103  206  231  238  240  255  253  248  255  229  254  233  252  241  240  223  228  248  219  200  175   45    0   43   12  125  255  255  244
  239  236  212  197  133  164  244  147  206  198  133  225  125   13    0   43  190  195  226  242  137   39   50   63  154  234  250  255  141   21    0   16  120  223  239  190  215   94    0   43  113  236  254  250  251
  251  251  235  238  248  192  148  176  197  184  221  192  134  122   78  114  184  196  226  116   22   56  129   84    3  175  236  152   22   78  114   74    0   86  197  213  203  146  111  129  238  255  231  249  255
  243  211  177  137  146  198  174   94  214  193  159  190  237  233  238  156  179  213  156    9   35  207  184  108   36   41  252   98   10   77  152  180   50    0   93  231  200  161  194  255  255  255  238  255  255
  235  224  201  232  231  178  165  158  168  208  219  217  201  228  233  167  197  194   38    5   77  158    0    0   57   81  255  145   73    0    0   89  129    8    8  186  206  162  193  255  249  236  250  255  240
  240  239  250  232  174  159  186  202  139  222  165  175  196  158  151  128  183  162    0    0   46  102   50  115  255  244  244  255  255  135   47  123   60    4    0  128  208  171  205  252  255  250  250  244  247
  250  250  237  142  181  218  144  218  174  122  192  174  152  181  190  150  207  127    9    0    5   47  199  255  165  134  169   88  152  255  213   66    1    2    4  124  206  153  219  249  248  255  252  253  255
  248  246  212  214  222  157  166  141  250  141  170  240  202  192  198  134  169  206   45    0    5   80  252  206    0   44  136   53    7  184  248  114    5    7   67  185  203  156  198  255  251  242  255  255  248
  242  250  243  232  152  195  142  216  217  215  147  201  176  147  162  161  163  186  211  170  119  157  214  223  122    2   12   21   99  251  220  175  121  177  215  205  184  139  255  243  255  247  250  253  255
  250  232  250  190  169  211  174  227  193  183  186  167  247  231  164  124  149  168  188  221  235  186  172  244  255  213  121  192  239  233  207  181  233  248  195  184  161  185  244  255  253  255  245  249  255
  250  235  246  173  238  211  230  189  180  170  250  181  209  250  250  233  140  183  173  184  206  168  162  209  232  245  216  255  247  224  167  195  229  187  188  175  125  255  251  235  228  255  255  252  255
  236  251  239  229  248  234  237  191  164  210  224  243  167  220  251  251  215  125  157  190  178  183  166  162  213  163  108  182  196  199  172  188  199  167  178  155  215  220  131  145  179  235  255  255  248
  243  251  248  246  240  251  218  211  173  239  240  204  106   87  113  204  255  177  138  174  185  188  195  156  138  124   66  154  160  164  217  193  191  193  154  174  189   78   16   97  128  173  247  255  243
  251  234  251  234  249  251  216  229  201  220  216  126  147  100   29   31  141  255  208  148  142  161  206  167  185  188  233  209  164  188  176  177  166  158  175  163    0    0   89  101  102  102  214  254  244
  245  247  248  251  244  243  223  251  221  251  155   80  100  116  106   27    0   73  172  161  142  156  151  183  173  174  167  173  176  177  185  152  159   85   79    7   12   25   86  123   97   56  186  252  246
  252  252  252  252  252  252  252  252  249  249  103   55   97  130   87   29   41   13    8   58  159  114  136  152  152  149  153  162  156  142  139  146  137  122   24   27   49   13   62  114   85   57  137  255  253
  252  252  252  252  252  252  252  252  253  234  129   29   72  126   87   39   50   44   45  123  197  186  173  160  149  153  157  155  153  159  175  191  200  204  122   42   41   14   63   88   69   37  182  241  255
  254  254  254  254  254  254  254  254  243  254  159   32   45   83  101   20   75   80   90  186  203  219  207  211  203  212  217  214  212  214  216  213  197  183  158   95   97   38   40   48    9   87  252  245  245
  254  254  254  254  254  254  254  254  255  242  237   78    3   31   27   58   66   63   98  196  186  201  204  223  216  206  197  196  202  208  211  211  205  219  195   67   22   27   23    8   62  197  255  255  230
  254  254  254  254  254  254  254  254  252  255  253  234  110   12   11   47   39   55  137  212  212  219  223  214  234  226  227  234  233  223  220  226  205  212  202  124   45   68   61   82  228  255  237  255  249
  254  254  254  254  254  254  254  254  246  230  255  255  228  189   75   55   40   95  211  236  229  235  255  243  241  248  255  255  254  242  240  246  255  245  250  219   77   64  126  255  255  245  255  236  255
  254  254  254  254  254  254  254  254  255  255  226  236  255  255  234  152   89   68   85   46   35   84  170  232  252  255  252  241  247  255  250  227  162  148  146  149  135  219  255  250  237  240  255  242  253
  254  254  254  254  254  254  254  254  247  255  255  249  255  238  255  254   61   14   49  101  118  100   63   71  228  249  254  248  255  240  147   40   48   44   52   45   59  165  255  252  254  255  234  255  250
  255  255  255  255  255  255  255  255  250  255  255  249  242  255  243   72   27  141  201  212  210  206  175   89   46  230  247  252  242  108   24  129  175  201  189  193  127    0  108  255  239  252  252  255  251
  255  255  255  255  255  255  255  255  255  255  253  253  253  252  149   12  111  166  174  165  159  165  167  124   41  107  255  249  159   21   97  144  150  164  183  170  178  121   45  151  253  255  250  253  253
  255  255  255  255  255  255  255  255  255  250  253  255  255  245   68   16  120  133  122  116  115  119  131  120   97   37  201  245   63   40  123  111  127  124  127  146  147  155   73   43  241  255  249  251  255
  255  255  255  255  255  255  255  255  253  250  255  253  255  240   30   69   75   82   85   91   93   91   93   89  109   49  151  223   10   71   86   97   97  100   91  103   83  109  102   24  200  252  252  252  255
  255  255  255  255  255  255  255  255  255  255  255  251  249  235   12   67   64   71   79   75   74   79   78   78   83   42  151  165   29   68   72   76   66   85   98   60   83   90   59   40  175  248  255  250  255
  255  255  255  255  255  255  255  255  255  252  248  255  253  246   32   29   50   53   66   56   56   68   62   65   63   37  172  171   36   53   67   48   60   65   63   57   79   55   64   21  193  253  255  249  251
  255  255  255  255  255  255  255  255  253  250  244  254  242  251   87   19   31   19   35   34   38   46   30   39   38   59  204  224   21   18   37   45   47   41   23   53   37   23   81   41  226  251  252  255  252
  255  255  255  255  255  255  255  255  251  255  246  245  213  235  128   30   46   11   15   14   20   23    5   24   57   59  176  204   62   29   23   10   12   20   40   20   14   49   27  114  245  241  241  255  255
  255  255  255  255  255  255  255  255  255  244  253  240  210  224  189   81   26   20   17   13    3    0   19   46   35   42   49   48   39   25   14    8    2    1    0    4   42   30   57  186  222  233  247  254  255
  255  255  255  255  255  255  255  255  255  247  255  251  221  228  225  177   76   50   30   30   38   44   54   65   97   96  100  109  109   86   45   11   30   40   46   25   30   76  150  241  232  241  251  255  255
  255  255  255  255  255  255  255  255  255  250  255  255  243  239  251  253  236  176  106   70   71   94  127  152  175  166  162  170  177  167  138  111   54   20   34   60  119  221  255  255  244  250  255  255  254
  255  255  255  255  255  255  255  255  255  252  249  255  255  252  249  255  255  255  252  251  248  241  238  241  223  222  220  220  222  227  231  233  243  204  219  236  244  255  255  235  251  254  255  255  253
  255  255  255  255  255  255  255  255  252  255  249  249  255  255  244  246  246  246  248  250  250  252  255  255  244  251  255  255  253  253  255  255  253  252  255  255  255  244  233  255  252  253  253  253  252];
set(handles.Image1,'CData',uint8(image_data));
image_data(:,:,1) = fliplr(image_data(:,:,1));
image_data(:,:,2) = fliplr(image_data(:,:,2));
image_data(:,:,3) = fliplr(image_data(:,:,3));
set(handles.Image2,'CData',uint8(image_data));


% --- Executes when PANDABedpostxFigure is resized.
function PANDABedpostxFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDABedpostxFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.PANDABedpostxFigure, 'Position');
    ResizeNativeFolderTable(handles);
    ResizeJobStatusTable(handles);
    
    FontSizeAdvancedOptionsUipanel = ceil(10 * PositionFigure(4) / 618);
    set( handles.AdvancedOptionsUipanel, 'FontSize', FontSizeAdvancedOptionsUipanel );
    FontSizePipelineOptionsUipanel = ceil(10 * PositionFigure(4) / 618);
    set( handles.PipelineOptionsUipanel, 'FontSize', FontSizePipelineOptionsUipanel );
end


function ResizeNativeFolderTable(handles)
NativeFolderPath = get(handles.NativeFolderTable, 'data');
PositionFigure = get(handles.PANDABedpostxFigure, 'Position');
WidthCell{1} = PositionFigure(3);
WidthCell{2} = 0;
if ~isempty(NativeFolderPath)
    for i = 1:length(NativeFolderPath)
        tmp{i} = length(NativeFolderPath{i}) * 8;
        tmp{i} = tmp{i} * PositionFigure(4) / 618;
    end
    NewWidth = max(cell2mat(tmp));
    if NewWidth > WidthCell{1}
        WidthCell{1} =  NewWidth;
    end
end
set(handles.NativeFolderTable, 'ColumnWidth', WidthCell);

function ResizeJobStatusTable(handles)
PositionFigure = get(handles.PANDABedpostxFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 4;
WidthCell{2} = WidthCell{1};
WidthCell{3} = WidthCell{1};
WidthCell{4} = WidthCell{1};
set(handles.JobStatusTable, 'ColumnWidth', WidthCell);


% --- Executes on button press in BedpostxText.
function BedpostxText_Callback(hObject, eventdata, handles)
% hObject    handle to BedpostxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SubjectFoldersListText.
function SubjectFoldersListText_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectFoldersListText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MonitorTableText.
function MonitorTableText_Callback(hObject, eventdata, handles)
% hObject    handle to MonitorTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FibersText.
function FibersText_Callback(hObject, eventdata, handles)
% hObject    handle to FibersText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in WeightText.
function WeightText_Callback(hObject, eventdata, handles)
% hObject    handle to WeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in BurninText.
function BurninText_Callback(hObject, eventdata, handles)
% hObject    handle to BurninText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TitleText.
function TitleText_Callback(hObject, eventdata, handles)
% hObject    handle to TitleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PipelineModeText.
function PipelineModeText_Callback(hObject, eventdata, handles)
% hObject    handle to PipelineModeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in QsubOptionsText.
function QsubOptionsText_Callback(hObject, eventdata, handles)
% hObject    handle to QsubOptionsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LogPathText.
function LogPathText_Callback(hObject, eventdata, handles)
% hObject    handle to LogPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MaxQueuedText.
function MaxQueuedText_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function PANDABedpostxFigure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to PANDABedpostxFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LogsButton.
function LogsButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BedpostxPipeline_opt;

LogsPath = '';
if isempty(BedpostxPipeline_opt)
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_Bedpostx','PANDA-files (*.PANDA_Bedpostx)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        cmdString = ['PANDAConfiguration = load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        LogsPath = PANDAConfiguration.BedpostxPipeline_opt.path_logs;    
    end
else
    LogsPath = BedpostxPipeline_opt.path_logs;
end
if ~isempty(LogsPath)
    try
        PANDALogsFile = [LogsPath filesep 'PIPE_logs.mat'];
        PANDAStatusFile = [LogsPath filesep 'PIPE_status.mat'];
        if exist(PANDALogsFile, 'file') & exist(PANDAStatusFile, 'file')
            PANDALogs = load(PANDALogsFile);
            PANDAStatus = load(PANDAStatusFile);
            JobNames = fieldnames(PANDALogs);
            FailedQuantity = 0;
            for i = 1:length(JobNames)
                if strcmp(PANDAStatus.(JobNames{i}), 'failed')
                    FailedQuantity = FailedQuantity + 1;
                    FailedJobNames{FailedQuantity} = JobNames{i};
                end 
            end
            if ~FailedQuantity
                msgbox('No job is failed.');
            else
                PANDA_FailedLogs(PANDALogs, FailedJobNames, LogsPath);
            end
        elseif ~exist(PANDAStatusFile, 'file')
            msgbox(['No such file: ' PANDAStatusFile]);
        elseif ~exist(PANDALogsFile, 'file')
            msgbox(['No such file: ' PANDALogsFile]);
        end
    catch
        none = 1;
    end
end


% --------------------------------------------------------------------
function NativeFolderTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to NativeFolderTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
