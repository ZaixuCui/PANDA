function varargout = PANDA_T1BrainExtraction(varargin)
% GUI for T1BrainExtraction (an independent component of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_T1BRAINEXTRACTION MATLAB code for PANDA_T1BrainExtraction.fig
%      PANDA_T1BRAINEXTRACTION, by itself, creates a new PANDA_T1BRAINEXTRACTION or raises the existing
%      singleton*.
%
%      H = PANDA_T1BRAINEXTRACTION returns the handle to a new PANDA_T1BRAINEXTRACTION or the handle to
%      the existing singleton*.
%
%      PANDA_T1BRAINEXTRACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_T1BRAINEXTRACTION.M with the given input arguments.
%
%      PANDA_T1BRAINEXTRACTION('Property','Value',...) creates a new PANDA_T1BRAINEXTRACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_T1BrainExtraction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_T1BrainExtraction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_T1BrainExtraction

% Last Modified by GUIDE v2.5 12-Jun-2015 23:10:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_T1BrainExtraction_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_T1BrainExtraction_OutputFcn, ...
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


% --- Executes just before PANDA_T1BrainExtraction is made visible.
function PANDA_T1BrainExtraction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_T1BrainExtraction (see VARARGIN)

% Choose default command line output for PANDA_T1BrainExtraction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_T1BrainExtraction wait for user response (see UIRESUME)
% uiwait(handles.PANDAT1BrainExtractionFigure);
global BetT1_Data_Raw_Path_Cell;
global BetT1_SubjectIDArray;
global BetT1_DestinationPath_Edit;
global BetT1_TensorPrefixEdit;
global BetT1_Pipeline_opt;
global BetT1_opt;
global PANDAPath;

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

BetT1_Data_Raw_Path_Cell = '';
% Pipeline options
BetT1_Pipeline_opt.flag_verbose = 0;
BetT1_Pipeline_opt.flag_pause = 0;
set( handles.batchRadio, 'Value', 1);
BetT1_Pipeline_opt.mode = 'background';
set( handles.QsubOptionsEdit, 'String', '');
set( handles.QsubOptionsEdit, 'Enable', 'off');
BetT1_Pipeline_opt.qsub_options = '';
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
    BetT1_Pipeline_opt.max_queued = str2num(QuantityOfCpu);
else
    BetT1_Pipeline_opt.max_queued = 2;
end
set(handles.MaxQueuedEdit, 'string', num2str(BetT1_Pipeline_opt.max_queued));
BetT1_Pipeline_opt.path_logs = [BetT1_DestinationPath_Edit filesep 'logs'];
%
BetT1_opt.BetT1_f_threshold = 0.5;
set( handles.f_Edit, 'String', num2str(BetT1_opt.BetT1_f_threshold));
BetT1_opt.T1Cropping_Flag = 1;
set( handles.T1CroppingGapCheckbox, 'Value', 1);
BetT1_opt.T1CroppingGap = 3;
set( handles.T1CroppingGapEdit, 'Enable', 'on' );
set( handles.T1CroppingGapEdit, 'String', '3' );
BetT1_opt.T1Resample_Flag = 1;
set( handles.T1ResampleCheckbox, 'Value', 1);
BetT1_opt.T1ResampleResolution = [1 1 1];
set( handles.T1ResampleResolutionEdit, 'String', '[1 1 1]');
BetT1_opt.Robust_Flag = 1;
set( handles.RobustCheckBox, 'Value', 1);
BetT1_opt.EyeOptic_Flag = 0;
set( handles.EyeOpticCheckBox, 'Value', 0);
BetT1_opt.BiasField_Flag = 0;
set( handles.BiasFieldCheckBox, 'Value', 0);

% Set the Status Table to default
JobStatusCell = cell(4,4);
set( handles.JobStatusTable, 'data', JobStatusCell );

% Set icon
SetIcon(handles);

%
TipStr = sprintf(['Input subjects'' source folders:' ...
    '\n Under each folder, there should be DICOM / NIfTI files,' ...
    '\n If NIfTI is uesd, only one file should be in the source folder.']);
set(handles.RawDataPathButton, 'TooltipString', TipStr);
%
TipStr = sprintf('The path of the folder storing resultant files for all subjects.');
set(handles.DestinationPathEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['Digital IDs for subjects.' ... 
    '\n Example: [1 4 8:20].']);
set(handles.SubjectIDEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('The prefix of the names for the resultant files. \n (Optional parameter)');
set(handles.TensorPrefixEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['The path of each subject''s resultant folder is constructed by the ' ...
    '\n Result Path and subject IDs user inputs.' ...
    '\n For example, Subject IDs is [1:3], then, the path of results will be' ...
    '\n {Result_Path} / 00001' ...
    '\n {Result_Path} / 00002' ...
    '\n {Result_Path} / 00003']);
set(handles.RawPath_DestPath, 'TooltipString', TipStr);
%
TipStr = sprintf(['Fractional intensity threshold (0->1) for T1 brain extraction,' ... 
    '\n default = 0.5, smaller values give larger brain outline estimates.']);
set(handles.f_Edit, 'TooltipString', TipStr);
%
TipStr = sprintf(['If T1 images need to be cropped to reduce image size,' ...
    '\n please click this.']);
set(handles.T1CroppingGapCheckbox, 'TooltipString', TipStr);
%
TipStr = sprintf('The distance from the slected cube to the border of the brain.');
set(handles.T1CroppingGapEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('If T1 images need to be resampled, please click this.');
set(handles.T1ResampleCheckbox, 'TooltipString', TipStr);
%
TipStr = sprintf('The final resolution of the T1 images to be resampled.');
set(handles.T1ResampleResolutionEdit, 'TooltipString', TipStr);
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
TipStr = sprintf('Set the options of qsub, such as ''-V -q all.q'', ''-V -q all.q -p 8''.');
set(handles.QsubOptionsEdit, 'TooltipString', TipStr);
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
TipStr = sprintf(['Load .PANDA_BetT1 file to display the information in' ...
    '\n the GUI.']);
set(handles.LoadButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['After clicking the button, the information in the GUI' ...
    '\n will be saved in a .PANDA_BetT1 file under ''Log_Path''.']);
set(handles.RUNButton, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_T1BrainExtraction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
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


% --- Executes on button press in RawDataPathButton.
function RawDataPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to RawDataPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Data_Raw_Path_Cell;
global BetT1_SubjectIDArray;
global BetT1_DestinationPath_Edit;
global BetT1_TensorPrefixEdit;
BetT1_Data_Raw_Path_Cell_Origin = BetT1_Data_Raw_Path_Cell;
DataRawPathCell = get(hObject, 'UserData');
[a, BetT1_Data_Raw_Path_Cell, Done] = PANDA_Select('dir', DataRawPathCell);
if Done == 1
    set(hObject, 'UserData', BetT1_Data_Raw_Path_Cell);
    if ~isempty(BetT1_Data_Raw_Path_Cell)
        BetT1_SubjectIDArray = '';
        BetT1_DestinationPath_Edit = '';
        BetT1_TensorPrefixEdit = '';
        set( handles.DestinationPathEdit, 'String', '' );
        set( handles.SubjectIDEdit, 'String', '' );
        set( handles.TensorPrefixEdit, 'String', '');
        set( handles.RawPath_DestPath, 'data', BetT1_Data_Raw_Path_Cell );
        ResizeRawDestTable(handles);
    else
        BetT1_Data_Raw_Path_Cell = BetT1_Data_Raw_Path_Cell_Origin;
    end
end

function SubjectIDEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubjectIDEdit as text
%        str2double(get(hObject,'String')) returns contents of SubjectIDEdit as a double
global BetT1_SubjectIDArray;
global BetT1_Data_Raw_Path_Cell;
SubjectID_Text = mat2str(BetT1_SubjectIDArray);
SubjectID_Text_New = get( hObject, 'string' );
if ~isempty(BetT1_SubjectIDArray) & ~strcmp(SubjectID_Text, SubjectID_Text_New)
    button = questdlg('Subjects ID are changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
    case 'Yes'
        SubjectID_Text = SubjectID_Text_New;
    case 'No'
        set(hObject, 'string', SubjectID_Text);
        return;
    end
end
if isempty(BetT1_SubjectIDArray)
    SubjectID_Text = SubjectID_Text_New;
end
if ~isempty(SubjectID_Text)
    % Pick the destion path from edit text
    % User can input without selecting from DirSelect GUI
    BetT1_DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );
    if ~isempty(BetT1_DestinationPath_Edit)
        try
            BetT1_SubjectIDArray = eval( SubjectID_Text );
            set( hObject, 'string', mat2str(BetT1_SubjectIDArray) );
            % Judge whther the quantity of the subjects is equal to the quantity of the
            % subjects id
            if length(BetT1_Data_Raw_Path_Cell) ~= length(BetT1_SubjectIDArray)
                info{1} = ['Your subject IDs are ' mat2str(BetT1_SubjectIDArray)];
                info{2} = 'I am sorry, the quantity of the subjects is not equal to the quantity of the subjects IDs!';
                info{3} = 'I will delete the subject IDs, please input subject IDs again!';
                msgbox(info);
                set( hObject, 'string', '' );
                SubjectID_Text = '';
                BetT1_SubjectIDArray = '';
            else
                 % Combine Destination path to Subject id 
                DestiantionPath_Subject = cell(length(BetT1_SubjectIDArray),1);
                for i = 1:length(BetT1_SubjectIDArray)
                    DestiantionPath_Subject{i} = [BetT1_DestinationPath_Edit filesep num2str(BetT1_SubjectIDArray(i),'%05.0f')];
                end
                % Display the raw data path and the destination path in the table
                %save x.mat Data_Raw_Path_Cell DestiantionPath_Subject
                RawData_Destination = [BetT1_Data_Raw_Path_Cell, DestiantionPath_Subject];

                set( handles.RawPath_DestPath, 'data', RawData_Destination );
                ResizeRawDestTable(handles);
            end    
        catch
            msgbox('The subjects id you input is illegal');
            set(hObject, 'string', '');
        end
    end
end



% --- Executes during object creation, after setting all properties.
function SubjectIDEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


function DestinationPathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DestinationPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DestinationPathEdit as text
%        str2double(get(hObject,'String')) returns contents of DestinationPathEdit as a double
global BetT1_DestinationPath_Edit;
global BetT1_Pipeline_opt;
global BetT1_SubjectIDArray;
global BetT1_Data_Raw_Path_Cell;

BetT1_DestinationPath_Edit_New = get( hObject, 'string' );
if ~isempty(BetT1_DestinationPath_Edit) & ~strcmp(BetT1_DestinationPath_Edit, BetT1_DestinationPath_Edit_New)
    button = questdlg('Destination path is changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
    case 'Yes'
        BetT1_DestinationPath_Edit = BetT1_DestinationPath_Edit_New;
        BetT1_Pipeline_opt.path_logs = [BetT1_DestinationPath_Edit filesep 'logs'];
    case 'No'
        set(hObject, 'string', BetT1_DestinationPath_Edit);
        return;
    end
elseif isempty(BetT1_DestinationPath_Edit)
    BetT1_DestinationPath_Edit = BetT1_DestinationPath_Edit_New;
    BetT1_Pipeline_opt.path_logs = [BetT1_DestinationPath_Edit filesep 'logs'];
end
if ~isempty(BetT1_DestinationPath_Edit)
    LogPath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
    if exist(LogPath, 'file')
        info{1} = 'A lock of pipeline is already exist in this result path!';
        info{2} = 'To restart the existed pipeline, please select Yes !';
        info{3} = 'To start a new pipeline delete the existed pipeline, please select No !';
        button = questdlg(info,'Start a new one or restart the existed one ?','Yes','No','Yes');
        switch button
        case 'Yes'
            system(['rm ' BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock']);
        case 'No'
            system(['rm -R ' BetT1_DestinationPath_Edit filesep]);
            mkdir(BetT1_DestinationPath_Edit);
            return;
        end
    end
end
% Acquire the id of subjects
SubjectID_Text = get( handles.SubjectIDEdit, 'string' );
if ~isempty(SubjectID_Text)
    
    BetT1_SubjectIDArray = eval( SubjectID_Text );
    % Combine Destination path to Subject id 
    DestiantionPath_Subject = cell(length(BetT1_SubjectIDArray),1);
    for i = 1:length(BetT1_SubjectIDArray)
        DestiantionPath_Subject{i} = [BetT1_DestinationPath_Edit filesep num2str(BetT1_SubjectIDArray(i),'%05.0f')];
    end
    if length(BetT1_Data_Raw_Path_Cell) ~= length(BetT1_SubjectIDArray)
        set( handles.SubjectIDEdit, 'string', '' );
        SubjectID_Text = '';
        BetT1_SubjectIDArray = '';
    else
        % Display the raw data path and the destination path in the table
        RawData_Destination = [BetT1_Data_Raw_Path_Cell, DestiantionPath_Subject];

        set( handles.RawPath_DestPath, 'data', RawData_Destination );
        ResizeRawDestTable(handles);
    end
    
end


% --- Executes during object creation, after setting all properties.
function DestinationPathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DestinationPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in DestinationPathButton.
function DestinationPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to DestinationPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_DestinationPath_Edit;
global BetT1_Pipeline_opt;
global BetT1_SubjectIDArray;
global BetT1_Data_Raw_Path_Cell;

DestinationPath_Select = uigetdir;
if DestinationPath_Select ~= 0
    set( handles.DestinationPathEdit, 'string', DestinationPath_Select );
    BetT1_DestinationPath_Edit = DestinationPath_Select;
    BetT1_Pipeline_opt.path_logs = [BetT1_DestinationPath_Edit filesep 'logs'];
    LogPath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
    if exist(LogPath, 'file')
        info{1} = 'A lock of pipeline is already exist in this result path!';
        info{2} = 'To restart the existed pipeline, please select Yes !';
        info{3} = 'To start a new pipeline delete the existed pipeline, please select No !';
        button = questdlg(info,'Start a new one or restart the existed one ?','Yes','No','Yes');
        switch button
            case 'Yes'
                system(['rm ' BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock']);
            case 'No'
                system(['rm -R ' BetT1_DestinationPath_Edit filesep]);
                mkdir(BetT1_DestinationPath_Edit);
                return;
        end
    end
end  
% Acquire the id of subjects
SubjectID_Text = get( handles.SubjectIDEdit, 'string' );
if ~isempty(SubjectID_Text)
    
    BetT1_SubjectIDArray = eval( SubjectID_Text );
    % Combine Destination path to Subject id 
    DestiantionPath_Subject = cell(length(BetT1_SubjectIDArray),1);
    for i = 1:length(BetT1_SubjectIDArray)
        DestiantionPath_Subject{i} = [BetT1_DestinationPath_Edit filesep num2str(BetT1_SubjectIDArray(i),'%05.0f')];
    end
    if length(BetT1_Data_Raw_Path_Cell) ~= length(BetT1_SubjectIDArray)
        set( handles.SubjectIDEdit, 'string', '' );
        SubjectID_Text = '';
        BetT1_SubjectIDArray = '';
    else
        % Display the raw data path and the destination path in the table
        RawData_Destination = [BetT1_Data_Raw_Path_Cell, DestiantionPath_Subject];

        set( handles.RawPath_DestPath, 'data', RawData_Destination );
        ResizeRawDestTable(handles);
    end
    
end


function TensorPrefixEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TensorPrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TensorPrefixEdit as text
%        str2double(get(hObject,'String')) returns contents of TensorPrefixEdit as a double
global BetT1_TensorPrefixEdit;

BetT1_TensorPrefixEdit_New = get(hObject, 'string');
ChangeFlag = 0;
if ~isempty(BetT1_TensorPrefixEdit) & ~strcmp(BetT1_TensorPrefixEdit, BetT1_TensorPrefixEdit_New)
    button = questdlg('Tensor prefix is changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
    case 'Yes'
        BetT1_TensorPrefixEdit = BetT1_TensorPrefixEdit_New;
    case 'No'
        set(hObject, 'string', BetT1_TensorPrefixEdit);
        return;
    end
end
if isempty(BetT1_TensorPrefixEdit)
    BetT1_TensorPrefixEdit = BetT1_TensorPrefixEdit_New;
end


% --- Executes during object creation, after setting all properties.
function TensorPrefixEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TensorPrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


function f_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to f_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f_Edit as text
%        str2double(get(hObject,'String')) returns contents of f_Edit as a double
global BetT1_opt;
BetT1_f_threshold_String = get(hObject, 'String');
if ~isempty(BetT1_f_threshold_String)
    BetT1_opt.BetT1_f_threshold = str2num(BetT1_f_threshold_String);
    if isempty(BetT1_opt.BetT1_f_threshold)
        msgbox('Your input is illegal.');
        set(hObject, 'String', '');
    end
else
    BetT1_opt.BetT1_f_threshold = '';
end


% --- Executes during object creation, after setting all properties.
function f_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in batchRadio.
function batchRadio_Callback(hObject, eventdata, handles)
% hObject    handle to batchRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batchRadio


% --- Executes on button press in qsubRadio.
function qsubRadio_Callback(hObject, eventdata, handles)
% hObject    handle to qsubRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of qsubRadio



function MaxQueuedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxQueuedEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxQueuedEdit as a double
global BetT1_Pipeline_opt;
BetT1_Pipeline_opt.max_queued = str2num(get(hObject, 'String'));


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
global BetT1_Pipeline_opt;
BetT1_Pipeline_opt.qsub_options = get(hObject, 'String');


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


% --- Executes on button press in RUNButton.
function RUNButton_Callback(hObject, eventdata, handles)
% hObject    handle to RUNButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Data_Raw_Path_Cell;
global BetT1_DestinationPath_Edit;
global BetT1_SubjectIDArray;
global BetT1_TensorPrefixEdit;
global BetT1_Pipeline_opt;
global BetT1_opt;
global JobStatusMonitorTimerBetT1;
global BetT1StopFlag;
global LockExistBetT1;
global LockDisappearBetT1;
global PANDAPath;

BetT1StopFlag = '';
LockFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if exist(LockFilePath, 'file') | strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
    StringPrint{1} = ['A lock file ' LockFilePath ' has been found on the pipeline !'];
    StringPrint{2} = 'If you want to run this new pipeline, ';
    StringPrint{3} = ['please delete the lock file ' LockFilePath ' first !'];
    msgbox(StringPrint);
else
    if isempty(BetT1_Data_Raw_Path_Cell)
        msgbox('Please input raw DICOM/NIfTI of T1 images!');
    elseif isempty(BetT1_DestinationPath_Edit)
        msgbox('Please input the result path of T1 brain extraction!')
    elseif isempty(BetT1_SubjectIDArray)
        msgbox('Please assign IDs for subjects!');
    elseif isempty(BetT1_opt.BetT1_f_threshold)
        msgbox('Please input fractional intensity threshold for brain extraction!');
    elseif strcmp(BetT1_Pipeline_opt.mode, 'qsub') & isempty(BetT1_Pipeline_opt.qsub_options)
        msgbox('Please input qsub options !');
    elseif isempty(BetT1_Pipeline_opt.max_queued)
        msgbox('Please input max queued !');
    else
        LogPathPermissionDenied = 0;
        try
            if ~exist(BetT1_DestinationPath_Edit, 'dir')
                mkdir(BetT1_DestinationPath_Edit);
            end
            if ~exist([BetT1_DestinationPath_Edit filesep 'logs'], 'dir')
                mkdir([BetT1_DestinationPath_Edit filesep 'logs']);
            end
            x = 1;
            save([BetT1_DestinationPath_Edit filesep 'logs' filesep 'permission_tag.mat'], 'x');
        catch
            LogPathPermissionDenied = 1;
            msgbox('Please change destination path, perssion denied !');
        end
        if ~LogPathPermissionDenied
            info{1} = 'Are you sure to Run ?';
            button = questdlg( info ,'Sure to Run ?','Yes','No','Yes' );
            if strcmp(button, 'Yes')
                % Save the configuration
                DateNow = datevec(datenum(now));
                DateNowString = [num2str(DateNow(1)) '_' num2str(DateNow(2), '%02d') '_' num2str(DateNow(3), '%02d') '_' num2str(DateNow(4), '%02d') '_' num2str(DateNow(5), '%02d')];
                ParameterSaveFilePath = [BetT1_DestinationPath_Edit  filesep DateNowString '.PANDA_BetT1'];
                cmdString = [ 'save ' ParameterSaveFilePath ' BetT1_Data_Raw_Path_Cell' ' BetT1_DestinationPath_Edit' ' BetT1_SubjectIDArray' ...
                        ' BetT1_TensorPrefixEdit' ' BetT1_opt' ' BetT1_Pipeline_opt' ' PANDAPath'];
                eval(cmdString);
                if exist( ParameterSaveFilePath, 'file' )
                    clc;
                    disp( 'The variable is saved!' );
                    disp( [ 'The full path is ' ParameterSaveFilePath ] );
                    disp( 'The jobs will start running !' );
                else
                    msgbox( 'Sorry, something has happened , the variables has not been saved!' );
                end
                if exist( ParameterSaveFilePath, 'file' )
                    % Excute the pipeline
                    if ~exist(BetT1_DestinationPath_Edit, 'dir')
                        mkdir(BetT1_DestinationPath_Edit);
                    end
                    command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat'');'...
                        'addpath(genpath(PANDAPath)); pipeline=g_BetT1_pipeline( BetT1_Data_Raw_Path_Cell, BetT1_SubjectIDArray, BetT1_DestinationPath_Edit,'...
                        'BetT1_TensorPrefixEdit, BetT1_opt, BetT1_Pipeline_opt );exit"'...
                        ' >"' BetT1_DestinationPath_Edit filesep 'logs' filesep 'BetT1_pipeline.loginfo" 2>&1'];
                    BetT1PipelineShLocation = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'BetT1_pipeline.sh'];
                    fid = fopen(BetT1PipelineShLocation, 'w');
                    BashString = '#!/bin/bash';
                    fprintf(fid, '%s\n%s', BashString, command);
                    fclose(fid);
%                     instr_batch = ['at -f "' BetT1PipelineShLocation '" now'];
%                     system(instr_batch);
                    [~, ShPath] = system('which sh');
                    system([ShPath(1:end-1) ' ' BetT1PipelineShLocation ' &']);
                    % Set edit box and button unable
                    set(handles.RawDataPathButton, 'Enable', 'off');
                    set(handles.DestinationPathEdit, 'Enable', 'off');
                    set(handles.DestinationPathButton, 'Enable', 'off');
                    set(handles.SubjectIDEdit, 'Enable', 'off');
                    set(handles.TensorPrefixEdit, 'Enable', 'off');
                    set(handles.f_Edit, 'Enable', 'off');
                    set(handles.batchRadio, 'Enable', 'off');
                    set(handles.qsubRadio, 'Enable', 'off');
                    set(handles.MaxQueuedEdit, 'Enable', 'off');
                    set(handles.QsubOptionsEdit, 'Enable', 'off');
                    set(handles.T1CroppingGapCheckbox, 'Enable', 'off');
                    set(handles.T1CroppingGapEdit, 'Enable', 'off');
                    set(handles.T1ResampleCheckbox, 'Enable', 'off');
                    set(handles.T1ResampleResolutionEdit, 'Enable', 'off');
                    set(handles.RobustCheckBox, 'Enable', 'off');
                    set(handles.EyeOpticCheckBox, 'Enable', 'off');
                    set(handles.BiasFieldCheckBox, 'Enable', 'off');
                    % Set the initial value in the monitor table
                    StatusFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE_status.mat'];
                    % The initial status should be 'dcm2nii_dwi wait ...' for each job
                    JobsStatus = cell(length(BetT1_Data_Raw_Path_Cell), 4);
                    for i = 1:length(BetT1_Data_Raw_Path_Cell)
                        JobsStatus{i, 1} = 'wait';
                        JobsStatus{i, 2} = 'wait';
                        JobsStatus{i, 3} = 'wait';
                        JobsStatus{i, 4} = 'wait';
                    end
                    set( handles.JobStatusTable, 'data', JobsStatus);
                    LockExistBetT1 = 0;
                    LockDisappearBetT1 = 0;
                    % Start monitor function
                    JobStatusMonitorTimerBetT1 = timer( 'TimerFcn', {@JobStatusMonitorBetT1, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
                    start(JobStatusMonitorTimerBetT1);
                else
                    return;
                end
            end
        end
    end
end


% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Help;


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Data_Raw_Path_Cell;
global BetT1_DestinationPath_Edit;
global BetT1_SubjectIDArray;
global BetT1_TensorPrefixEdit;
global BetT1_Pipeline_opt;
global BetT1_opt;
global JobStatusMonitorTimerBetT1;
global BetT1StopFlag;
global LockExistBetT1;
global LockDisappearBetT1;
global PANDAPath;

if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
    msgbox('Please clear first !');
else
    FAT1PathCellBrainParcellation = '';
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_BetT1','T1_BrainExtraction-files (*.PANDA_BetT1)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        if ~isempty(BetT1_DestinationPath_Edit)
            LockFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
        end
        cmdString = ['load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        set( handles.DestinationPathEdit, 'String', BetT1_DestinationPath_Edit);
        set( handles.SubjectIDEdit, 'String', mat2str(BetT1_SubjectIDArray));
        set( handles.TensorPrefixEdit, 'String', BetT1_TensorPrefixEdit);
        for i = 1:length(BetT1_Data_Raw_Path_Cell)
            DestinationPathCell{i} = [BetT1_DestinationPath_Edit filesep num2str(BetT1_SubjectIDArray(i), '%05d')];
        end
        DestinationPathCell = reshape(DestinationPathCell, length(DestinationPathCell), 1);
        RawPath_DestPathCell = [BetT1_Data_Raw_Path_Cell, DestinationPathCell];
        set( handles.RawPath_DestPath, 'data', RawPath_DestPathCell );
        ResizeRawDestTable(handles);
        set( handles.f_Edit, 'String', num2str(BetT1_opt.BetT1_f_threshold));
        if strcmp(BetT1_Pipeline_opt.mode,'background')
            set( handles.batchRadio, 'Value', 1 );
        else
            set( handles.qsubRadio, 'Value', 1 );
            set( handles.QsubOptionsEdit, 'Enable', 'on');
            set( handles.QsubOptionsEdit, 'string', BetT1_Pipeline_opt.qsub_options);
        end
        set( handles.MaxQueuedEdit, 'string', num2str(BetT1_Pipeline_opt.max_queued) );
        if BetT1_opt.T1Cropping_Flag
            set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
            set( handles.T1CroppingGapCheckbox, 'Value', 1);
            set( handles.T1CroppingGapEdit, 'Enable', 'on');
            set( handles.T1CroppingGapEdit, 'String', num2str(BetT1_opt.T1CroppingGap));
        else
            set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
            set( handles.T1CroppingGapCheckbox, 'Value', 0);
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off');
        end
        if BetT1_opt.T1Resample_Flag
            set( handles.T1ResampleCheckbox, 'Enable', 'on');
            set( handles.T1ResampleCheckbox, 'Value', 1);
            set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
            set( handles.T1ResampleResolutionEdit, 'String', mat2str(BetT1_opt.T1ResampleResolution));
        else
            set( handles.T1ResampleCheckbox, 'Enable', 'on');
            set( handles.T1ResampleCheckbox, 'Value', 0);
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
        end
        if BetT1_opt.Robust_Flag
            set( handles.RobustCheckBox, 'Enable', 'on');
            set( handles.RobustCheckBox, 'Value', 1);
        else
            set( handles.RobustCheckBox, 'Enable', 'off');
            set( handles.RobustCheckBox, 'Value', 0);
        end
        if BetT1_opt.EyeOptic_Flag
            set( handles.EyeOpticCheckBox, 'Enable', 'on');
            set( handles.EyeOpticCheckBox, 'Value', 1);
        else
            set( handles.EyeOpticCheckBox, 'Enable', 'off');
            set( handles.EyeOpticCheckBox, 'Value', 0);
        end
        if BetT1_opt.BiasField_Flag
            set( handles.BiasFieldCheckBox, 'Enable', 'on');
            set( handles.BiasFieldCheckBox, 'Value', 1);
        else
            set( handles.BiasFieldCheckBox, 'Enable', 'off');
            set( handles.BiasFieldCheckBox, 'Value', 0);
        end
        % Display job status in the Job Status Table
        LockFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
        if exist(LockFilePath, 'file')
            LockExistBetT1 = 1;
            LockDisappearBetT1 = 0;
            JobStatusMonitorTimerBetT1 = timer( 'TimerFcn', {@JobStatusMonitorBetT1, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimerBetT1);
            % Set edit box and button unable
            set(handles.RawDataPathButton, 'Enable', 'off');
            set(handles.DestinationPathEdit, 'Enable', 'off');
            set(handles.DestinationPathButton, 'Enable', 'off');
            set(handles.SubjectIDEdit, 'Enable', 'off');
            set(handles.TensorPrefixEdit, 'Enable', 'off');
            set(handles.f_Edit, 'Enable', 'off');
            set(handles.batchRadio, 'Enable', 'off');
            set(handles.qsubRadio, 'Enable', 'off');
            set(handles.MaxQueuedEdit, 'Enable', 'off');
            set(handles.QsubOptionsEdit, 'Enable', 'off');
            set(handles.T1CroppingGapCheckbox, 'Enable', 'off');
            set(handles.T1CroppingGapEdit, 'Enable', 'off');
            set(handles.T1ResampleCheckbox, 'Enable', 'off');
            set(handles.T1ResampleResolutionEdit, 'Enable', 'off');
            set(handles.RobustCheckBox, 'Enable', 'off');
            set(handles.EyeOpticCheckBox, 'Enable', 'off');
            set(handles.BiasFieldCheckBox, 'Enable', 'off');
        else
            JobStatusMonitorBetT1(hObject, eventdata, handles);
        end
    end
end



% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Data_Raw_Path_Cell;
global BetT1_DestinationPath_Edit;
global BetT1_SubjectIDArray;
global BetT1_TensorPrefixEdit;
global BetT1_Pipeline_opt;
global BetT1_opt;
global JobStatusMonitorTimerBetT1;
global BetT1StopFlag;
global LockExistBetT1;
global LockDisappearBetT1;

button = questdlg('Are you sure to Clear ?','Sure to Clear ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop the monitor
        if ~isempty(JobStatusMonitorTimerBetT1)
            stop(JobStatusMonitorTimerBetT1);
            clear global JobStatusMonitorTimerBetT1;
        end
        
        clear global LockExistBetT1;
        clear global LockDisappearBetT1;

        set(handles.RawDataPathButton, 'Enable', 'on');
        set(handles.DestinationPathEdit, 'Enable', 'on');
        set(handles.DestinationPathEdit, 'String', '');
        set(handles.DestinationPathButton, 'Enable', 'on');
        set(handles.SubjectIDEdit, 'Enable', 'on');
        set(handles.SubjectIDEdit, 'String', '');
        set(handles.TensorPrefixEdit, 'Enable', 'on');
        set(handles.TensorPrefixEdit, 'String', '');
        set(handles.f_Edit, 'Enable', 'on');
        set(handles.f_Edit, 'String', '0.5');
        set(handles.batchRadio, 'Enable', 'on');
        set(handles.qsubRadio, 'Enable', 'on');
        set(handles.MaxQueuedEdit, 'Enable', 'on');
        set(handles.QsubOptionsEdit, 'Enable', 'on');
        set(handles.T1CroppingGapCheckbox, 'Enable', 'on');
        set(handles.T1CroppingGapCheckbox, 'Value', 1);
        set(handles.T1CroppingGapEdit, 'Enable', 'on');
        set(handles.T1CroppingGapEdit, 'String', '3');
        set(handles.T1ResampleCheckbox, 'Value', 1);
        set(handles.T1ResampleResolutionEdit, 'Enable', 'on');
        set(handles.T1ResampleResolutionEdit, 'String', '1');
        set(handles.RobustCheckBox, 'Enable', 'on');
        set(handles.RobustCheckBox, 'Value', 1);
        set(handles.EyeOpticCheckBox, 'Enable', 'on');
        set(handles.EyeOpticCheckBox, 'Value', 0);
        set(handles.BiasFieldCheckBox, 'Enable', 'on');
        set(handles.BiasFieldCheckBox, 'Value', 0);
        % Back to default values
        BetT1_Data_Raw_Path_Cell = '';
        BetT1_DestinationPath_Edit = '';
        BetT1_SubjectIDArray = '';
        BetT1_TensorPrefixEdit = '';
        BetT1_opt.BetT1_f_threshold = 0.5;
        BetT1_opt.T1Cropping_Flag = 1;
        BetT1_opt.T1CroppingGap = 3;
        BetT1_opt.T1Resample_Flag = 1;
        BetT1_opt.T1ResampleResolution = [1 1 1];
        BetT1_opt.Robust_Flag = 1;
        BetT1_opt.EyeOptic_Flag = 0;
        BetT1_opt.BiasField_Flag = 0;
        % Pipeline options
        BetT1_Pipeline_opt.flag_verbose = 0;
        BetT1_Pipeline_opt.flag_pause = 0;
        set( handles.batchRadio, 'Value', 1);
        BetT1_Pipeline_opt.mode = 'background';
        set( handles.QsubOptionsEdit, 'String', '');
        set( handles.QsubOptionsEdit, 'Enable', 'off');
        BetT1_Pipeline_opt.qsub_options = '';
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
            BetT1_Pipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            BetT1_Pipeline_opt.max_queued = 2;
        end
        set( handles.MaxQueuedEdit, 'string', num2str(BetT1_Pipeline_opt.max_queued));
        % Set the Paths Table to default
        RawDestPathCell = cell(4,2);
        set( handles.RawPath_DestPath, 'data', RawDestPathCell );
        ResizeRawDestTable(handles);
        % Set the Status Table to default
        JobStatusCell = cell(4,4);
        set( handles.JobStatusTable, 'data', JobStatusCell );
        ResizeJobStatusTable(handles);
    case 'No'
        return;
end

% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


% --- Executes on button press in TerminateButton.
function TerminateButton_Callback(hObject, eventdata, handles)
% hObject    handle to TerminateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_DestinationPath_Edit;
global BetT1StopFlag;
global JobStatusMonitorTimerBetT1;
global LockDisappearBetT1;

LockFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if isempty(BetT1_DestinationPath_Edit) || ~exist(LockFilePath, 'file')
    msgbox('No job is running !');
else
    button = questdlg('Are you sure to terminal this job ?','Sure to terminal ?','Yes','No','Yes');
    switch button
        case 'Yes'   
            % Stop the monitor
            if ~isempty(JobStatusMonitorTimerBetT1)
                stop(JobStatusMonitorTimerBetT1);
                clear global JobStatusMonitorTimerBetT1;
            end
            
            cmdString = ['rm -rf ' LockFilePath];
            system(cmdString);
            msgbox('The job is terminated sucessfully!');
            % Set edit box enable, Stop Monitor, Update job status table
            BetT1StopFlag = '(Stopped)';
            while exist(LockFilePath, 'file')
                system(['rm -rf ' LockFilePath]);
            end
            LockDisappearBetT1 = 1;
            JobStatusMonitorBetT1(hObject, eventdata, handles);
        case 'No'
            return;
    end
end


% --- Executes on key press with focus on DestinationPathEdit and none of its controls.
function DestinationPathEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to DestinationPathEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Data_Raw_Path_Cell;
if isempty(BetT1_Data_Raw_Path_Cell)
    msgbox( 'Please select the raw data path!' );
    set( hObject, 'string', '');
else
    FileExist = 1;
    for i = 1:length(BetT1_Data_Raw_Path_Cell)
        if ~exist(BetT1_Data_Raw_Path_Cell{i}, 'dir')
            FileExist = 0;
            break;
        end
    end
    if ~FileExist
        msgbox( 'Some folders do not exist !' );
        set( hObject, 'string', '');
    end
end


% --- Executes on key press with focus on SubjectIDEdit and none of its controls.
function SubjectIDEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
BetT1_DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );
if isempty(BetT1_DestinationPath_Edit)
    set( hObject, 'string', '');
    msgbox( 'Please input the destination path!' );
end


% --- Executes on key press with focus on TensorPrefixEdit and none of its controls.
function TensorPrefixEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to TensorPrefixEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Data_Raw_Path_Cell;
global BetT1_DestinationPath_Edit;
global BetT1_SubjectIDArray;
SubjectID_Text = get( handles.SubjectIDEdit, 'string' );
if isempty(SubjectID_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the subjects ID!');
else
    % Pick the destion path from edit text
    % User can input without selecting from DirSelect GUI
    BetT1_DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );

    BetT1_SubjectIDArray = eval( SubjectID_Text );
    % Combine Destination path to Subject id 
    DestiantionPath_Subject = cell(length(BetT1_SubjectIDArray),1);
    for i = 1:length(BetT1_SubjectIDArray)
        DestiantionPath_Subject{i} = [BetT1_DestinationPath_Edit filesep num2str(BetT1_SubjectIDArray(i),'%05.0f')];
    end
     %Display the raw data path and the destination path in the table
    %save x.mat Data_Raw_Path_Cell DestiantionPath_Subject
    RawData_Destination = [BetT1_Data_Raw_Path_Cell, DestiantionPath_Subject];
    %save x.mat RawData_Destination

    set( handles.RawPath_DestPath, 'data', RawData_Destination );
    ResizeRawDestTable(handles);
end


% --- Executes on key press with focus on f_Edit and none of its controls.
function f_Edit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to f_Edit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% global BetT1_Data_Raw_Path_Cell;
% global BetT1_DestinationPath_Edit;
% global BetT1_SubjectIDArray;
% SubjectID_Text = get( handles.SubjectIDEdit, 'string' );
% if isempty(SubjectID_Text)
%     set( hObject, 'string', '' );
%     msgbox('Please input the subjects ID!');
% else
%     % Pick the destion path from edit text
%     % User can input without selecting from DirSelect GUI
%     BetT1_DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );
% 
%     BetT1_SubjectIDArray = eval( SubjectID_Text );
%     % Combine Destination path to Subject id 
%     DestiantionPath_Subject = cell(length(BetT1_SubjectIDArray),1);
%     for i = 1:length(BetT1_SubjectIDArray)
%         DestiantionPath_Subject{i} = [BetT1_DestinationPath_Edit filesep num2str(BetT1_SubjectIDArray(i),'%05.0f')];
%     end
%      %Display the raw data path and the destination path in the table
%     %save x.mat Data_Raw_Path_Cell DestiantionPath_Subject
%     RawData_Destination = [BetT1_Data_Raw_Path_Cell, DestiantionPath_Subject];
%     %save x.mat RawData_Destination
% 
%     set( handles.RawPath_DestPath, 'data', RawData_Destination );
% %    ResizeRawDestTable(handles);
% end


% --- Monitor Function
function JobStatusMonitorBetT1(hObject, eventdata, handles)
% Print jobs status in the table
global BetT1_Data_Raw_Path_Cell;
global BetT1_DestinationPath_Edit;
global BetT1_SubjectIDArray;
global BetT1_TensorPrefixEdit;
global BetT1_Pipeline_opt;
global BetT1_opt;
global PANDAPath;
global BetT1StopFlag;
global JobStatusMonitorTimerBetT1;
global LockExistBetT1;
global LockDisappearBetT1;

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if ~LockExistBetT1 & exist( LockFilePath, 'file' )
    LockExistBetT1 = 1;
end
if LockExistBetT1 & ~exist( LockFilePath, 'file' )
    LockDisappearBetT1 = 1;
end
ErrorFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'T1Bet_pipeline.error'];
if LockDisappearBetT1 == 1 | exist(ErrorFilePath, 'file') 
    % Set edit box enable
    set(handles.RawDataPathButton, 'Enable', 'on');
    set(handles.DestinationPathEdit, 'Enable', 'on');
    set(handles.DestinationPathButton, 'Enable', 'on');
    set(handles.SubjectIDEdit, 'Enable', 'on');
    set(handles.TensorPrefixEdit, 'Enable', 'on');
    set(handles.f_Edit, 'Enable', 'on');
    set(handles.batchRadio, 'Enable', 'on');
    set(handles.qsubRadio, 'Enable', 'on');
    set(handles.MaxQueuedEdit, 'Enable', 'on');
    set(handles.T1CroppingGapCheckbox, 'Enable', 'on');
    if BetT1_opt.T1Cropping_Flag
        set(handles.T1CroppingGapEdit, 'Enable', 'on');
    end
    if strcmp(BetT1_Pipeline_opt.mode,'qsub')
        set(handles.QsubOptionsEdit, 'Enable', 'on');
    end
    set(handles.T1ResampleCheckbox, 'Enable', 'on');
    if BetT1_opt.T1Resample_Flag
        set(handles.T1ResampleResolutionEdit, 'Enable', 'on');
    end
    set(handles.RobustCheckBox, 'Enable', 'on');
    set(handles.EyeOpticCheckBox, 'Enable', 'on');
    set(handles.BiasFieldCheckBox, 'Enable', 'on');
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerBetT1)
        stop(JobStatusMonitorTimerBetT1);
        clear global JobStatusMonitorTimerBetT1;
    end
    %
    if exist(ErrorFilePath, 'file')
        Info{1} = 'Something is wrong !';
        Info{2} = ['Please look up ' BetT1_DestinationPath_Edit filesep 'logs' filesep ...
                   'BetT1_pipeline.loginfo for more information !'];
        msgbox(Info);
        BetT1StopFlag = '(Stopped)';
        delete(ErrorFilePath);
    end
end
        
StatusFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'PIPE_status_backup.mat'];
if exist( StatusFilePath, 'file' )
    warning('off');
    try    
        cmdString = ['load ' StatusFilePath];
        eval(cmdString);
        SubjectQuantity = length(BetT1_Data_Raw_Path_Cell);
        JobName = [' ', {'BetT1'}];
        if BetT1_opt.T1Cropping_Flag
            JobName = [JobName, {'T1Cropped'}];
        end
        if BetT1_opt.T1Resample_Flag
            JobName = [JobName, {'T1Resample'}];
        end
        JobQuantity = length(JobName);
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
            SubjectIDArrayString{i} = num2str(BetT1_SubjectIDArray(i),'%05.0f');
            
            NIfTIFile = g_ls([BetT1_Data_Raw_Path_Cell{i} filesep '*nii*']);
            if ~length(NIfTIFile)
                JobName{1} = 'dcm2nii';
            else
                JobName{1} = 'CopyT1';
            end
            
            for j = 1:JobQuantity
                % Check the status of all jobs of the ith subject and  acquire
                % the status of the subject
                % The subject has three situations:
                %     1. 'failed': which job 
                %     2. 'running': which job
                %     3. 'submitted': which job
                %     4. 'wait': which job
                %     5. 'finished'
                VariableName = [JobName{j} '_' SubjectIDArrayString{i}];
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
                StatusArray{i} = ['running' BetT1StopFlag];
                JobNameArray{i} = RunningJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(SubmittedJobName)
                StatusArray{i} = ['submitted' BetT1StopFlag];
                JobNameArray{i} = SubmittedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(FailedJobName)
                StatusArray{i} = ['failed' BetT1StopFlag];
                JobNameArray{i} = FailedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(WaitJobName)
                StatusArray{i} = ['wait' BetT1StopFlag];
                JobNameArray{i} = WaitJobName;
                JobLeftArray{i} = num2str(JobLeft);
            end
        end
        % Combine SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray
        % into a table
        SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray]; 
        set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
        % 
        JobsFinishFilePath = [BetT1_DestinationPath_Edit filesep 'logs' filesep 'jobs.finish'];
        if exist(JobsFinishFilePath, 'file')
            % Set edit box enable
            set(handles.RawDataPathButton, 'Enable', 'on');
            set(handles.DestinationPathEdit, 'Enable', 'on');
            set(handles.DestinationPathButton, 'Enable', 'on');
            set(handles.SubjectIDEdit, 'Enable', 'on');
            set(handles.TensorPrefixEdit, 'Enable', 'on');
            set(handles.f_Edit, 'Enable', 'on');
            set(handles.batchRadio, 'Enable', 'on');
            set(handles.qsubRadio, 'Enable', 'on');
            set(handles.MaxQueuedEdit, 'Enable', 'on');
            set(handles.T1CroppingGapCheckbox, 'Enable', 'on');
            if BetT1_opt.T1Cropping_Flag
                set(handles.T1CroppingGapEdit, 'Enable', 'on');
            end
            if strcmp(BetT1_Pipeline_opt.mode,'qsub')
                set(handles.QsubOptionsEdit, 'Enable', 'on');
            end
            set(handles.T1ResampleCheckbox, 'Enable', 'on');
            if BetT1_opt.T1Resample_Flag
                set(handles.T1ResampleResolutionEdit, 'Enable', 'on');
            end
            set(handles.RobustCheckBox, 'Enable', 'on');
            set(handles.EyeOpticCheckBox, 'Enable', 'on');
            set(handles.BiasFieldCheckBox, 'Enable', 'on');
            % Stop Monitor
            if ~isempty(JobStatusMonitorTimerBetT1)
                stop(JobStatusMonitorTimerBetT1);
                clear global JobStatusMonitorTimerBetT1;
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


% --- Executes when selected object is changed in PipelineOptionsUipanel.
function PipelineOptionsUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PipelineOptionsUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global BetT1_Pipeline_opt;
switch get(hObject, 'tag')
    case 'batchRadio'
        BetT1_Pipeline_opt.mode = 'background';
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
            BetT1_Pipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            BetT1_Pipeline_opt.max_queued = 2;
        end
        set(handles.MaxQueuedEdit, 'string', num2str(BetT1_Pipeline_opt.max_queued));
    case 'qsubRadio'
        BetT1_Pipeline_opt.mode = 'qsub';
        BetT1_Pipeline_opt.qsub_options = '-V -q all.q';
        set( handles.QsubOptionsEdit, 'Enable', 'on');
        set( handles.QsubOptionsEdit, 'String', '-V -q all.q');
        BetT1_Pipeline_opt.max_queued = 40;
        set(handles.MaxQueuedEdit, 'string', num2str(BetT1_Pipeline_opt.max_queued));
end


% --- Executes during object creation, after setting all properties.
function PipelineOptionsUipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PipelineOptionsUipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over SubjectIDEdit.
function SubjectIDEdit_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close PANDAT1BrainExtractionFigure.
function PANDAT1BrainExtractionFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDAT1BrainExtractionFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global BetT1_Data_Raw_Path_Cell;
global BetT1_DestinationPath_Edit;
global BetT1_SubjectIDArray;
global BetT1_TensorPrefixEdit;
global BetT1_Pipeline_opt;
global BetT1_opt;
global BetT1StopFlag;
global JobStatusMonitorTimerBetT1;
global LockExistBetT1;
global LockDisappearBetT1;

button = questdlg('Are you sure to quit ?','Sure to Quit ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop the monitor
        if ~isempty(JobStatusMonitorTimerBetT1)
            stop(JobStatusMonitorTimerBetT1);
            clear global JobStatusMonitorTimerBetT1;
        end
        clear global BetT1_Data_Raw_Path_Cell;
        clear global BetT1_DestinationPath_Edit;
        clear global BetT1_SubjectIDArray;
        clear global BetT1_TensorPrefixEdit;
        clear global BetT1_Pipeline_opt;
        clear global BetT1_opt;
        clear global BetT1StopFlag;
        clear global LockExistBetT1;
        clear global LockDisappearBetT1;
        delete(hObject);
    case 'No'
        return;
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


% --- Executes when PANDAT1BrainExtractionFigure is resized.
function PANDAT1BrainExtractionFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDAT1BrainExtractionFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.PANDAT1BrainExtractionFigure, 'Position');
    ResizeRawDestTable(handles);
    ResizeJobStatusTable(handles);
    FontSizePipelineOptionsUipanel = ceil(10 * PositionFigure(4) / 605);
    set( handles.T1OptionsUipanel, 'FontSize', FontSizePipelineOptionsUipanel );
    set( handles.PipelineOptionsUipanel, 'FontSize', FontSizePipelineOptionsUipanel );
end


function ResizeRawDestTable(handles)
RawPathDestPath = get(handles.RawPath_DestPath, 'data');
PositionFigure = get(handles.PANDAT1BrainExtractionFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 2;
WidthCell{2} = WidthCell{1};
if ~isempty(RawPathDestPath)
    [rows, columns] = size(RawPathDestPath);
    for i = 1:columns
        for j = 1:rows
            tmp_PANDA{j} = length(RawPathDestPath{j, i}) * 8;
            tmp_PANDA{j} = tmp_PANDA{j} * PositionFigure(4) / 718;
        end
        NewWidthCell{i} = max(cell2mat(tmp_PANDA));
        if NewWidthCell{i} > WidthCell{i}
           WidthCell{i} =  NewWidthCell{i};
        end
    end
end
set(handles.RawPath_DestPath, 'ColumnWidth', WidthCell);


function ResizeJobStatusTable(handles)
PositionFigure = get(handles.PANDAT1BrainExtractionFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 4;
WidthCell{2} = WidthCell{1};
WidthCell{3} = WidthCell{1};
WidthCell{4} = WidthCell{1};
set(handles.JobStatusTable, 'ColumnWidth', WidthCell);


% --- Executes on button press in T1CroppingGapCheckbox.
function T1CroppingGapCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1CroppingGapCheckbox
global BetT1_opt;
if get(hObject, 'Value')
    BetT1_opt.T1Cropping_Flag = 1;
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    if isempty(BetT1_opt.T1CroppingGap)
        BetT1_opt.T1CroppingGap = 3;
    end
    set( handles.T1CroppingGapEdit, 'String', num2str(BetT1_opt.T1CroppingGap));
else
    BetT1_opt.T1Cropping_Flag = 0;
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
end




function T1CroppingGapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1CroppingGapEdit as text
%        str2double(get(hObject,'String')) returns contents of T1CroppingGapEdit as a double
global BetT1_opt;
T1CroppingGapString = get(hObject,'String');
BetT1_opt.T1CroppingGap = str2num(T1CroppingGapString);


% --- Executes during object creation, after setting all properties.
function T1CroppingGapEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in T1ResampleCheckbox.
function T1ResampleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to T1ResampleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1ResampleCheckbox
global BetT1_opt;
if get(hObject, 'Value')
    BetT1_opt.T1Resample_Flag = 1;
    if isempty(BetT1_opt.T1ResampleResolution)
        BetT1_opt.T1ResampleResolution = [1 1 1];
    end
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'String', mat2str(BetT1_opt.T1ResampleResolution));
else
    BetT1_opt.T1Resample_Flag = 0;
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
end


function T1ResampleResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1ResampleResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1ResampleResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of T1ResampleResolutionEdit as a double
global BetT1_opt;
ResolutionString = get(hObject, 'String');
BetT1_opt.T1ResampleResolution = eval(ResolutionString);


% --- Executes during object creation, after setting all properties.
function T1ResampleResolutionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T1ResampleResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --------------------------------------------------------------------
function RawPath_DestPath_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RawPath_DestPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% RawPathDestPath = get(hObject, 'data');
% OrigineWidthCell = get(hObject, 'ColumnWidth');
% if ~isempty(RawPathDestPath)
%     NewWidthCell = OrigineWidthCell;
%     [rows, columns] = size(RawPathDestPath);
%     for i = 1:columns
%         for j = 1:rows
%             if NewWidthCell{i} < length(RawPathDestPath{j, i}) * 7.8
%                 NewWidthCell{i} = length(RawPathDestPath{j, i}) * 7.8;
%             end
%         end
%     end
%     set( handles.RawPath_DestPath, 'ColumnWidth', NewWidthCell);
% end


% --- Executes on button press in LogsButton.
function LogsButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BetT1_DestinationPath_Edit;

LogsPath = '';
if isempty(BetT1_DestinationPath_Edit)
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_BetT1','PANDA-files (*.PANDA_BetT1)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        cmdString = ['PANDAConfiguration = load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        LogsPath = [PANDAConfiguration.BetT1_DestinationPath_Edit filesep 'logs'];    
    end
else
    LogsPath = [BetT1_DestinationPath_Edit filesep 'logs'];
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
        msgbox('No job is failed.');
    end
end


% --- Executes during object creation, after setting all properties.
function PANDAT1BrainExtractionFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PANDAT1BrainExtractionFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in RobustCheckBox.
function RobustCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to RobustCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RobustCheckBox
global BetT1_opt;
if get(hObject, 'Value')
    BetT1_opt.Robust_Flag = 1;
else
    BetT1_opt.Robust_Flag = 0;
end


% --- Executes on button press in EyeOpticCheckBox.
function EyeOpticCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to EyeOpticCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EyeOpticCheckBox
global BetT1_opt;
if get(hObject, 'Value')
    BetT1_opt.EyeOptic_Flag = 1;
else
    BetT1_opt.EyeOptic_Flag = 0;
end


% --- Executes on button press in BiasFieldCheckBox.
function BiasFieldCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to BiasFieldCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BiasFieldCheckBox
global BetT1_opt;
if get(hObject, 'Value')
    BetT1_opt.BiasField_Flag = 1;
else
    BetT1_opt.BiasField_Flag = 0;
end
