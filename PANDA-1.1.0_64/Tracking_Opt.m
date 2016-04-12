function varargout = Tracking_Opt(varargin)
% GUI for Fiber Tracking_Opt (part of PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Version 1.1.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
% TRACKING_OPT MATLAB code for Tracking_Opt.fig
%      TRACKING_OPT, by itself, creates a new TRACKING_OPT or raises the existing
%      singleton*.
%
%      H = TRACKING_OPT returns the handle to a new TRACKING_OPT or the handle to
%      the existing singleton*.
%
%      TRACKING_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKING_OPT.M with the given input arguments.
%
%      TRACKING_OPT('Property','Value',...) creates a new TRACKING_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Tracking_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Tracking_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Tracking_Opt

% Last Modified by GUIDE v2.5 28-May-2012 22:56:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tracking_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @Tracking_Opt_OutputFcn, ...
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


% --- Executes just before Tracking_Opt is made visible.
function Tracking_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Tracking_Opt (see VARARGIN)

% Choose default command line output for Tracking_Opt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Tracking_Opt wait for user response (see UIRESUME)
% uiwait(handles.TrackingFigure);
global tracking_opt;
global DestinationPath_Edit;
global SubjectIDArray;
global FAPathCellMain;
global TensorPrefixEdit;
global LockFlagMain;
global T1orPartitionOfSubjectsPathCellMain;
global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));

if ~isfield(tracking_opt, 'DterminFiberTracking')
    tracking_opt.DterminFiberTracking = 0;
end
if tracking_opt.DterminFiberTracking == 0
    set( handles.FiberTrackingCheck, 'value', 0.0 );
    set( handles.ImageOrientationText, 'Enable', 'off');
    set( handles.ImageOrientationMenu, 'Enable', 'off');
    set( handles.AngleThresholdText, 'Enable', 'off');
    set( handles.AngleThresholdEdit, 'Enable', 'off');
    set( handles.PropagationAlgorithmText, 'Enable', 'off');
    set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
    set( handles.StepLengthText, 'Enable', 'off');
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.MaskThresholdText, 'Enable', 'off');
    set( handles.MaskThresMinEdit, 'Enable', 'off');
    set( handles.text7, 'Enable', 'off');
    set( handles.MaskThresMaxEdit, 'Enable', 'off');
    set( handles.ApplySplineFilterCheck, 'Enable', 'off');
    set( handles.OrientationPatchText, 'Enable', 'off');
    set( handles.InversionMenu, 'Enable', 'off');
    set( handles.SwapMenu, 'Enable', 'off');
else
    set( handles.FiberTrackingCheck, 'value', 1.0 );
    if strcmp(tracking_opt.ImageOrientation, 'Auto')
        set(handles.ImageOrientationMenu, 'value', 1.0);
    elseif strcmp(tracking_opt.ImageOrientation, 'Axial')
        set(handles.ImageOrientationMenu, 'value', 2.0);
    elseif strcmp(tracking_opt.ImageOrientation, 'Coronal')
        set(handles.ImageOrientationMenu, 'value', 3.0);    
    elseif strcmp(tracking_opt.ImageOrientation, 'Sagittal')
        set(handles.ImageOrientationMenu, 'value', 4.0);
    end
    set(handles.AngleThresholdEdit, 'String', tracking_opt.AngleThreshold);
    if strcmp(tracking_opt.PropagationAlgorithm, 'FACT')
        set(handles.PropagationAlgorithmMenu, 'value', 1.0);
        set(handles.StepLengthEdit,'Enable','off');
    elseif strcmp(tracking_opt.PropagationAlgorithm, '2nd-order Runge Kutta')
        set(handles.PropagationAlgorithmMenu, 'value', 2.0);
        set(handles.StepLengthEdit, 'String', num2str(tracking_opt.StepLength));
    elseif strcmp(tracking_opt.PropagationAlgorithm, 'Interpolated Streamline')
        set(handles.PropagationAlgorithmMenu, 'value', 3.0);   
        set(handles.StepLengthEdit, 'String', num2str(tracking_opt.StepLength));
    elseif strcmp(tracking_opt.PropagationAlgorithm, 'Tensorline')
        set(handles.PropagationAlgorithmMenu, 'value', 4.0);
        set(handles.StepLengthEdit, 'String', num2str(tracking_opt.StepLength));
    end
    set(handles.MaskThresMinEdit, 'String', num2str(tracking_opt.MaskThresMin));
    set(handles.MaskThresMaxEdit, 'String', num2str(tracking_opt.MaskThresMax));
    if strcmp(tracking_opt.ApplySplineFilter, 'Yes')
        set(handles.ApplySplineFilterCheck, 'value', 1.0);
    else
        set(handles.ApplySplineFilterCheck, 'value', 0.0);
    end
    if strcmp(tracking_opt.Inversion, 'No Inversion')
        set(handles.InversionMenu, 'value', 1.0);
    elseif strcmp(tracking_opt.Inversion, 'Invert X')
        set(handles.InversionMenu, 'value', 2.0);
    elseif strcmp(tracking_opt.Inversion, 'Invert Y')
        set(handles.InversionMenu, 'value', 3.0);    
    elseif strcmp(tracking_opt.Inversion, 'Invert Z')
        set(handles.InversionMenu, 'value', 4.0);
    end
    if strcmp(tracking_opt.Swap, 'No Swap')
        set(handles.SwapMenu, 'value', 1.0);
    elseif strcmp(tracking_opt.Swap, 'Swap X/Y')
        set(handles.SwapMenu, 'value', 2.0);
    elseif strcmp(tracking_opt.Swap, 'Swap Y/Z')
        set(handles.SwapMenu, 'value', 3.0);    
    elseif strcmp(tracking_opt.Swap, 'Swap Z/X')
        set(handles.SwapMenu, 'value', 4.0);
    end
end

if ~isfield(tracking_opt, 'NetworkNode')
    tracking_opt.NetworkNode = 0;
end
if tracking_opt.NetworkNode == 0
    set( handles.NetworkNodeCheck, 'value', 0.0);
    set( handles.PartitionOfSubjectsCheck, 'Enable', 'off');
    set( handles.T1Check, 'Enable', 'off');
    DataCell = cell(4,1);
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', DataCell );
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'Enable', 'off');
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    set( handles.T1PathButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off'); 
    set( handles.PartitionTemplateEdit, 'String', '');
    set( handles.PartitionTemplateEdit, 'Enable', 'off'); 
    set( handles.PartitionTemplateButton, 'Enable', 'off');
elseif tracking_opt.NetworkNode == 1;
    set( handles.NetworkNodeCheck, 'value', 1.0);
    set( handles.LocationTableText, 'Enable', 'on' );
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'Enable', 'on');    
    ColumnName{1} = 'Path of FA';
    if ~tracking_opt.T1
        ColumnName{2} = 'Path of parcellated images';
        set( handles.PartitionOfSubjectsCheck, 'Value', 1.0 );
        set( handles.T1Check, 'Value', 0.0 );
        set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
        set( handles.T1PathButton, 'Enable', 'off');
        set( handles.PartitionTemplateEdit, 'String', '' );
        set( handles.PartitionTemplateEdit, 'Enable', 'off' );
        set( handles.PartitionTemplateButton, 'Enable', 'off' );
        set( handles.PartitionTemplateText, 'Enable', 'off' );
    else
        ColumnName{2} = 'Path of T1';
        set( handles.T1Check, 'Value', 1.0 );
        set( handles.PartitionOfSubjectsCheck, 'Value', 0.0 );
        set( handles.T1PathButton, 'Enable', 'on');
        set( handles.PartitionTemplateText, 'Enable', 'on');
        set( handles.PartitionTemplateEdit, 'Enable', 'on');
        set( handles.PartitionTemplateButton, 'Enable', 'on');
        if ~isfield( tracking_opt, 'PartitionTemplate')
            tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
        end
        set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);  
    end
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'ColumnName', ColumnName );
    if ~isempty(SubjectIDArray)
        FAPathCellMain = cell(length(SubjectIDArray),1);
        for i = 1:length(SubjectIDArray)
            FAPathCellMain{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f') filesep 'native_space' filesep TensorPrefixEdit '_' num2str(SubjectIDArray(i),'%05.0f') '_' 'FA.nii.gz'];
        end 
        if ~isempty(T1orPartitionOfSubjectsPathCellMain) & length(FAPathCellMain) == length(T1orPartitionOfSubjectsPathCellMain)
            FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
        else
            FAPath_T1orPartitionOfSubjectsPath = FAPathCellMain;
        end
        set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );  
        ResizeFAT1orParcellatedTable(handles);
    end
end
if ~isfield(tracking_opt, 'PartitionOfSubjects')
    tracking_opt.PartitionOfSubjects = 0;
end
if ~isfield(tracking_opt, 'T1')
    tracking_opt.T1 = 0;
end

if ~isfield(tracking_opt, 'DeterministicNetwork')
    tracking_opt.DeterministicNetwork = 0;
    set(handles.DeterministicNetworkCheck, 'value', 0.0);
elseif tracking_opt.DeterministicNetwork
    set(handles.DeterministicNetworkCheck, 'value', 1.0);
else
    set(handles.DeterministicNetworkCheck, 'value', 0.0);
end

if ~isfield(tracking_opt, 'BedpostxProbabilisticNetwork')
    tracking_opt.BedpostxProbabilisticNetwork = 0;
    set(handles.BedpostxAndProbabilisticCheck, 'value', 0.0);
elseif tracking_opt.BedpostxProbabilisticNetwork 
    set(handles.BedpostxAndProbabilisticCheck, 'value', 1.0);
else
    set(handles.BedpostxAndProbabilisticCheck, 'value', 0.0);
end

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if exist( LockFilePath, 'file' )
    set( handles.FiberTrackingCheck, 'Enable', 'off' );
    set( handles.ImageOrientationMenu, 'Enable', 'off' );
    set( handles.PropagationAlgorithmMenu, 'Enable', 'off' );
    set( handles.StepLengthEdit, 'Enable', 'off' );
    set( handles.AngleThresholdEdit, 'Enable', 'off' );
    set( handles.MaskThresMinEdit, 'Enable', 'off' );
    set( handles.MaskThresMaxEdit, 'Enable', 'off' );
    set( handles.InversionMenu, 'Enable', 'off' );
    set( handles.SwapMenu, 'Enable', 'off' );
    set( handles.ApplySplineFilterCheck, 'Enable', 'off' );
    set( handles.NetworkNodeCheck, 'Enable', 'off' );
    set( handles.PartitionOfSubjectsCheck, 'Enable', 'off' );
    set( handles.T1Check, 'Enable', 'off' );
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
    set( handles.T1PathButton, 'Enable', 'off' );    
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
    set( handles.PartitionTemplateEdit, 'Enable', 'off' );
    set( handles.PartitionTemplateButton, 'Enable', 'off' );
    set( handles.DeterministicNetworkCheck, 'Enable', 'off');
    set( handles.BedpostxAndProbabilisticCheck, 'Enable', 'off');
    LockFlagMain = 1;
else
    LockFlagMain = 0;
end

        
% --- Outputs from this function are returned to the command line.
function varargout = Tracking_Opt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ImageOrientationMenu.
function ImageOrientationMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ImageOrientationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageOrientationMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageOrientationMenu
global tracking_opt;
sel = get(hObject, 'value');
switch sel
    case 1
        tracking_opt.ImageOrientation = 'Auto';
    case 2
        tracking_opt.ImageOrientation = 'Axial';
    case 3
        tracking_opt.ImageOrientation = 'Coronal';
    case 4
        tracking_opt.ImageOrientation = 'Sagittal';
end


% --- Executes during object creation, after setting all properties.
function ImageOrientationMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageOrientationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


% --- Executes on selection change in PropagationAlgorithmMenu.
function PropagationAlgorithmMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PropagationAlgorithmMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PropagationAlgorithmMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PropagationAlgorithmMenu
global tracking_opt;
sel = get(hObject, 'value');
switch sel
    case 1
        tracking_opt.PropagationAlgorithm = 'FACT';
        set(handles.StepLengthEdit, 'String', '');
        set(handles.StepLengthEdit, 'Enable', 'off');
    case 2
        tracking_opt.PropagationAlgorithm = '2nd-order Runge Kutta';
        set(handles.StepLengthEdit, 'Enable', 'on');
        tracking_opt.StepLength = 0.1;
        set(handles.StepLengthEdit, 'String', '0.1');
    case 3
        tracking_opt.PropagationAlgorithm = 'Interpolated Streamline';
        set(handles.StepLengthEdit, 'Enable', 'on');
        tracking_opt.StepLength = 0.5;
        set(handles.StepLengthEdit, 'String', '0.5');
    case 4
        tracking_opt.PropagationAlgorithm = 'Tensorline';
        set(handles.StepLengthEdit, 'Enable', 'on');
        tracking_opt.StepLength = 0.1;
        set(handles.StepLengthEdit, 'String', '0.1');
end


% --- Executes during object creation, after setting all properties.
function PropagationAlgorithmMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PropagationAlgorithmMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


function StepLengthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StepLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepLengthEdit as text
%        str2double(get(hObject,'String')) returns contents of StepLengthEdit as a double
global tracking_opt;
StepLengthString = get(hObject, 'string');
tracking_opt.StepLength = str2double(StepLengthString);


% --- Executes during object creation, after setting all properties.
function StepLengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


function AngleThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AngleThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AngleThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of AngleThresholdEdit as a double
global tracking_opt;
tracking_opt.AngleThreshold = get(hObject, 'string');



% --- Executes during object creation, after setting all properties.
function AngleThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');



function MaskThresMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaskThresMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskThresMinEdit as text
%        str2double(get(hObject,'String')) returns contents of MaskThresMinEdit as a double
global tracking_opt;
MaskThresMinString = get(hObject, 'string'); 
if isempty(MaskThresMinString)
    tracking_opt.MaskThresMin = [];
else
    tracking_opt.MaskThresMin = str2double(MaskThresMinString);
end


% --- Executes during object creation, after setting all properties.
function MaskThresMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskThresMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');



function MaskThresMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaskThresMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskThresMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of MaskThresMaxEdit as a double
global tracking_opt;
MaskThresMaxString = get(hObject, 'string');
if isempty(MaskThresMaxString)
    tracking_opt.MaskThresMax = [];
else
    tracking_opt.MaskThresMax = str2double(MaskThresMaxString);
end


% --- Executes during object creation, after setting all properties.
function MaskThresMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskThresMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


% --- Executes on selection change in InversionMenu.
function InversionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to InversionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InversionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InversionMenu
global tracking_opt;
sel = get(hObject, 'value');
switch sel
    case 1
        tracking_opt.Inversion = 'No Inversion';
    case 2
        tracking_opt.Inversion = 'Invert X';
    case 3
        tracking_opt.Inversion = 'Invert Y';
    case 4
        tracking_opt.Inversion = 'Invert Z';
end


% --- Executes during object creation, after setting all properties.
function InversionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InversionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


% --- Executes on selection change in SwapMenu.
function SwapMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SwapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SwapMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SwapMenu
global tracking_opt;
sel = get(hObject, 'value');
switch sel
    case 1
        tracking_opt.Swap = 'No Swap';
    case 2
        tracking_opt.Swap = 'Swap X/Y';
    case 3
        tracking_opt.Swap = 'Swap Y/Z';
    case 4
        tracking_opt.Swap = 'Swap Z/X';
end


% --- Executes during object creation, after setting all properties.
function SwapMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SwapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


% --- Executes on button press in ApplySplineFilterCheck.
function ApplySplineFilterCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ApplySplineFilterCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ApplySplineFilterCheck
global tracking_opt;
if get(hObject, 'value')
    tracking_opt.ApplySplineFilter = 'Yes';
else
    tracking_opt.ApplySplineFilter = 'No';
end


% --- Executes on button press in NetworkNodeCheck.
function NetworkNodeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to NetworkNodeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NetworkNodeCheck
global tracking_opt;
global DestinationPath_Edit;
global SubjectIDArray;
global FAPathCellMain;
global TensorPrefixEdit;
global T1PathCellBefore;
global PartitionOfSubjectsPathCellBefore;
global T1orPartitionOfSubjectsPathCellMain;

OKButtonString = get(handles.OKButton, 'String');
if get(hObject, 'value') == 1
    if isempty(DestinationPath_Edit) 
        set(hObject, 'value', 0);
        msgbox('Please input the result path.');
    elseif isempty(SubjectIDArray) 
        set(hObject, 'value', 0);
        msgbox('Please input subject IDs.');
    else
        tracking_opt.NetworkNode = 1;
        tracking_opt.PartitionOfSubjects = 1;
        tracking_opt.T1 = 0;
        set( handles.PartitionOfSubjectsCheck, 'Enable', 'on');
        set( handles.T1Check, 'Enable', 'on');
        set( handles.PartitionOfSubjectsCheck, 'Value', 1.0);
        set( handles.T1Check, 'Value', 0.0);
        set( handles.LocationTableText, 'Enable', 'on' );
        set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'Enable', 'on' );
        set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
        ColumnName{1} = 'Path of FA';
        ColumnName{2} = 'Path of parcellated images';
        set(handles.PartitionTemplateEdit, 'String', '');
        set(handles.PartitionTemplateEdit, 'Enable', 'off');
        set(handles.PartitionTemplateButton, 'Enable', 'off');
        set( handles.PartitionTemplateText, 'Enable', 'off');
        set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'ColumnName', ColumnName );
        if strcmp(OKButtonString, 'OK')
            FAPathCellMain = cell(length(SubjectIDArray),1);
            for i = 1:length(SubjectIDArray)
                FAPathCellMain{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f') filesep 'native_space' filesep TensorPrefixEdit '_' num2str(SubjectIDArray(i),'%05.0f') '_' 'FA.nii.gz'];
            end
        end
        if ~isempty(PartitionOfSubjectsPathCellBefore)
            T1orPartitionOfSubjectsPathCellMain = PartitionOfSubjectsPathCellBefore;
        else
            T1orPartitionOfSubjectsPathCellMain = '';
        end
        FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
        if tracking_opt.PartitionOfSubjects & isempty(T1orPartitionOfSubjectsPathCellMain)
            msgbox('Please select parcellated images (native space) according to the order of FA images');
        elseif tracking_opt.T1 & isempty(T1orPartitionOfSubjectsPathCellMain)
            msgbox('Please select T1 images according to the order of FA images');
        end
    %     end
        set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
        ResizeFAT1orParcellatedTable(handles);
    end
else
    tracking_opt.NetworkNode = 0;
    % Change to partition of subjects, assign T1 path cell to  T1PathCellBefore
    if tracking_opt.T1
        T1PathCellBefore = T1orPartitionOfSubjectsPathCellMain;
    elseif tracking_opt.PartitionOfSubjects
        PartitionOfSubjectsPathCellBefore = T1orPartitionOfSubjectsPathCellMain;
    end
    %
    DataCell = cell(4,1);
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', DataCell );
    ResizeFAT1orParcellatedTable(handles);
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'Enable', 'off' );
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
    set( handles.T1PathButton, 'Enable', 'off' );
    set( handles.PartitionTemplateText, 'Enable', 'off' );
    set( handles.PartitionTemplateEdit, 'String', '' );
    set( handles.PartitionTemplateEdit, 'Enable', 'off' );
    set( handles.PartitionTemplateButton, 'Enable', 'off' );
    tracking_opt.PartitionOfSubjects = 1;
    tracking_opt.T1 = 0;
    set( handles.PartitionOfSubjectsCheck, 'value', 0.0 );
    set( handles.T1Check, 'value', 0.0 );
    set( handles.PartitionOfSubjectsCheck, 'Enable', 'off' );
    set( handles.T1Check, 'Enable', 'off' );
end


% --- Executes on button press in T1PathButton.
function T1PathButton_Callback(hObject, eventdata, handles)
% hObject    handle to T1PathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FAPathCellMain;
global T1orPartitionOfSubjectsPathCellMain;
[x,T1orPartitionOfSubjectsPathCellMain] = Select('img');
if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
    T1orPartitionOfSubjectsPathCellMain = '';
    msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
else
    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
end


function PartitionTemplateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PartitionTemplateEdit as text
%        str2double(get(hObject,'String')) returns contents of PartitionTemplateEdit as a double
global tracking_opt;
PartitionTemplatePath = get( handles.PartitionTemplateEdit, 'string' );
tracking_opt.PartitionTemplate = PartitionTemplatePath;


% --- Executes during object creation, after setting all properties.
function PartitionTemplateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PartitionTemplateButton.
function PartitionTemplateButton_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tracking_opt;
[PartitionTemplateName,PartitionTemplateParent] = uigetfile;
PartitionTemplatePath = [PartitionTemplateParent PartitionTemplateName];
if PartitionTemplateParent ~= 0
    set( handles.PartitionTemplateEdit, 'string', PartitionTemplatePath );
    tracking_opt.PartitionTemplate = PartitionTemplatePath;
end


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Excute 'close' command, it will call TrackingFigure_CloseRequestFcn function
global tracking_opt;
global LockFlagMain;
global T1orPartitionOfSubjectsPathCellMain;
global BedpostxAndProbabilisticOK;

FiberTrackingInputFinish = 0;
NetworkNodeInputFinish = 0;
BedpostxProbabilisticNetworkFinish = 0;
info_quantity = 0;
% In this situation, Tracking_Opt is open from panda
if LockFlagMain | (~tracking_opt.DterminFiberTracking & ~tracking_opt.NetworkNode ...
            & ~tracking_opt.BedpostxProbabilisticNetwork)
    close;
else
    if tracking_opt.DterminFiberTracking
        if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT') & isempty(tracking_opt.StepLength)
            msgbox('Please input step length !');
        elseif isempty(tracking_opt.AngleThreshold)
            msgbox('Please input angle threshold !');
        elseif isempty(tracking_opt.MaskThresMin)
            msgbox('Please input the minimum of mask threshold !');
        elseif isempty(tracking_opt.MaskThresMax)
            msgbox('Please input the maximum of mask threshold !');
        else
            FiberTrackingInputFinish = 1;
        end
    end
    if tracking_opt.NetworkNode
        if tracking_opt.PartitionOfSubjects & isempty(T1orPartitionOfSubjectsPathCellMain)
            msgbox('Please input parcellated images (native space) according the order of FA paths !');
        elseif tracking_opt.T1 
            if isempty(T1orPartitionOfSubjectsPathCellMain)
                msgbox('Please input T1 paths according the order of FA paths !');
            elseif isempty(tracking_opt.PartitionTemplate)
                msgbox('Please input atlas (standard space) !');
            else
                NetworkNodeInputFinish = 1;
            end
        else
            NetworkNodeInputFinish = 1;
        end
    end
    if tracking_opt.BedpostxProbabilisticNetwork & ~BedpostxAndProbabilisticOK
        msgbox('Please ensure your bedpostx and probabilistic options !');
    else
        if tracking_opt.BedpostxProbabilisticNetwork
            if isempty(tracking_opt.Fibers)
                msgbox('Please input number of fibers per voxel !');
            elseif isempty(tracking_opt.Weight)
                msgbox('Please input ARD weight, more weight means less secondary fibers per voxel !');
            elseif isempty(tracking_opt.Burnin)
                msgbox('please input burnin period !');
            elseif isempty(tracking_opt.ProbabilisticTrackingType)
                msgbox('Please select probabilistic tracking type !');
            elseif isempty(tracking_opt.LabelIdVector)
                msgbox('Please input label id vector of ROI !')
            else
                BedpostxProbabilisticNetworkFinish = 1;
            end
        end
    end
    Check_info = '';
    if FiberTrackingInputFinish
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = 'Deterministic Fiber Tracking = 1';
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Image Orientation = ' tracking_opt.ImageOrientation];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Propagation Algorithm = ' tracking_opt.PropagationAlgorithm];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Angle Threshold = ' tracking_opt.AngleThreshold];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Mask Threshold Minimum = ' num2str(tracking_opt.MaskThresMin)];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Mask Threshold Maximum = ' num2str(tracking_opt.MaskThresMax)];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Oriention Inversion = ' tracking_opt.Inversion];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['Oriention Swap = ' tracking_opt.Swap];
        if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT')
            info_quantity = info_quantity + 1;
            Check_info{info_quantity} = ['Step Length = ' num2str(tracking_opt.StepLength)];
        end
    end
    if NetworkNodeInputFinish 
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = 'Network Node Definition = 1';
        if tracking_opt.T1
            info_quantity = info_quantity + 1;
            Check_info{info_quantity} = ['Atlas (standard space) Path = ' tracking_opt.PartitionTemplate];
        end
    end
    if BedpostxProbabilisticNetworkFinish
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['number of fibers per voxel = ' num2str(tracking_opt.Fibers)];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['ARD weight = ' num2str(tracking_opt.Weight)];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['burnin period = ' num2str(tracking_opt.Burnin)];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['probabilistic tracking type = ' tracking_opt.ProbabilisticTrackingType];
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = ['label id vector of ROI = ' tracking_opt.LabelIdVectorText];
    end
    if tracking_opt.DeterministicNetwork
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = 'Deterministic Network = 1';
    end
    if tracking_opt.BedpostxProbabilisticNetwork
        info_quantity = info_quantity + 1;
        Check_info{info_quantity} = 'Probabilistic Network = 1';
    end
    Ensure = 1;
    if tracking_opt.DterminFiberTracking & ~FiberTrackingInputFinish
        Ensure = 0;
    end
    if tracking_opt.NetworkNode & ~NetworkNodeInputFinish
        Ensure = 0;
    end
    if tracking_opt.BedpostxProbabilisticNetwork & ~BedpostxProbabilisticNetworkFinish
        Ensure = 0;
    end
    if Ensure == 1
        button = questdlg( Check_info, 'Please check!', 'Yes', 'No', 'No');
        if strcmp(button,'Yes')
            close;
        end
    else
        close;
    end
end


% --- Executes when user attempts to close TrackingFigure.
function TrackingFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to TrackingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object creation, after setting all properties.
function TrackingFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrackingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in PartitionOfSubjectsButton.
function PartitionOfSubjectsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionOfSubjectsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FAPathCellMain;
global T1orPartitionOfSubjectsPathCellMain;
[x,T1orPartitionOfSubjectsPathCellMain] = Select('img');
if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
    T1orPartitionOfSubjectsPathCellMain = '';
    msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
else
    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
end


% --- Executes on button press in PartitionOfSubjectsCheck.
function PartitionOfSubjectsCheck_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionOfSubjectsCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value')
global FAPathCellMain;
global tracking_opt;
global T1orPartitionOfSubjectsPathCellMain;
global T1PathCellBefore;
global PartitionOfSubjectsPathCellBefore;
global PANDAPath;
if get( hObject, 'value' )
    tracking_opt.PartitionOfSubjects = 1;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
    set( handles.T1Check, 'value', 0.0);
    tracking_opt.T1 = 0;
    set( handles.T1PathButton, 'Enable', 'off');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of parcellated images';
    set(handles.PartitionTemplateEdit, 'String', '');
    set(handles.PartitionTemplateEdit, 'Enable', 'off');
    set(handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off');
    % Change to partition of subjects, assign T1 path cell to  T1PathCellBefore
    if ~isempty(T1orPartitionOfSubjectsPathCellMain)
        T1PathCellBefore = T1orPartitionOfSubjectsPathCellMain;
    end
    %
    if ~isempty(PartitionOfSubjectsPathCellBefore)
        T1orPartitionOfSubjectsPathCellMain = PartitionOfSubjectsPathCellBefore;
    else
        T1orPartitionOfSubjectsPathCellMain = '';
    end
    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath, 'ColumnName', ColumnName);
    ResizeFAT1orParcellatedTable(handles);
else
    tracking_opt.PartitionOfSubjects = 0;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    set( handles.T1Check, 'value', 1.0);
    tracking_opt.T1 = 1;
    set( handles.T1PathButton, 'Enable', 'on');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of T1';
    set(handles.PartitionTemplateEdit, 'Enable', 'on');
    set(handles.PartitionTemplateButton, 'Enable', 'on');
    set( handles.PartitionTemplateText, 'Enable', 'on');
    tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
    set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);
    % Change to T1, assign parition of subjects path cell to  PartitionOfSubjectsPathCellBefore
    if ~isempty(T1orPartitionOfSubjectsPathCellMain)
        PartitionOfSubjectsPathCellBefore = T1orPartitionOfSubjectsPathCellMain;
    end
    % 
    if ~isempty(T1PathCellBefore)
        T1orPartitionOfSubjectsPathCellMain = T1PathCellBefore;
    else
        T1orPartitionOfSubjectsPathCellMain = '';
    end
    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath, 'ColumnName', ColumnName );
    ResizeFAT1orParcellatedTable(handles);
end


% --- Executes on button press in T1Check.
function T1Check_Callback(hObject, eventdata, handles)
% hObject    handle to T1Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1Check
global FAPathCellMain;
global T1orPartitionOfSubjectsPathCellMain;
global tracking_opt;
global T1PathCellBefore;
global PartitionOfSubjectsPathCellBefore;
global PANDAPath;
if get( hObject, 'value' )
    tracking_opt.T1 = 1;
    set( handles.T1PathButton, 'Enable', 'on');
    set( handles.PartitionOfSubjectsCheck, 'value', 0.0);
    tracking_opt.PartitionOfSubjects = 0;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of T1';
    set(handles.PartitionTemplateEdit, 'Enable', 'on');
    set(handles.PartitionTemplateButton, 'Enable', 'on');
    set( handles.PartitionTemplateText, 'Enable', 'on');
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'ColumnName', ColumnName );
    tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
    set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);
    % Change to T1, assign parition of subjects path cell to  PartitionOfSubjectsPathCellBefore
    if ~isempty(T1orPartitionOfSubjectsPathCellMain)
        PartitionOfSubjectsPathCellBefore = T1orPartitionOfSubjectsPathCellMain;
    end
    % 
    if ~isempty(T1PathCellBefore)
        T1orPartitionOfSubjectsPathCellMain = T1PathCellBefore;
    else
        T1orPartitionOfSubjectsPathCellMain = '';
    end
    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
    clear global T1orPartitionOfSubjectsPathCellMain;
else
    tracking_opt.T1 = 0;
    set( handles.T1PathButton, 'Enable', 'off');
    set( handles.PartitionOfSubjectsCheck, 'value', 1.0);
    tracking_opt.PartitionOfSubjects = 1;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of parcellated images';
    set(handles.PartitionTemplateEdit, 'String', '');
    set(handles.PartitionTemplateEdit, 'Enable', 'off');
    set(handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off');
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'ColumnName', ColumnName );
    % Change to partition of subjects, assign T1 path cell to  T1PathCellBefore
    if ~isempty(T1orPartitionOfSubjectsPathCellMain)
        T1PathCellBefore = T1orPartitionOfSubjectsPathCellMain;
    end
    %
    if ~isempty(PartitionOfSubjectsPathCellBefore)
        T1orPartitionOfSubjectsPathCellMain = PartitionOfSubjectsPathCellBefore;
    else
        T1orPartitionOfSubjectsPathCellMain = '';
    end
    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
    set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
    clear global T1orPartitionOfSubjectsPathCellMain;
end


% --- Executes on button press in FiberTrackingCheck.
function FiberTrackingCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FiberTrackingCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FiberTrackingCheck
global tracking_opt;
if get(hObject, 'Value')
    tracking_opt.DterminFiberTracking = 1;
    set( handles.FiberTrackingCheck, 'value', 1.0 );
    set( handles.ImageOrientationText, 'Enable', 'on');
    set( handles.ImageOrientationMenu, 'Enable', 'on');
    tracking_opt.ImageOrientation = 'Auto';
    set( handles.ImageOrientationMenu, 'value', 1.0);
    set( handles.AngleThresholdText, 'Enable', 'on');
    set( handles.AngleThresholdEdit, 'Enable', 'on');
    tracking_opt.AngleThreshold = '35';
    set( handles.AngleThresholdEdit, 'String', tracking_opt.AngleThreshold);
    set( handles.PropagationAlgorithmText, 'Enable', 'on');
    set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
    tracking_opt.PropagationAlgorithm = 'FACT';
    set( handles.PropagationAlgorithmMenu, 'value', 1.0);
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.StepLengthText, 'Enable', 'on');
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.MaskThresholdText, 'Enable', 'on');
    set( handles.MaskThresMinEdit, 'Enable', 'on');
    tracking_opt.MaskThresMin = 0.1;
    set( handles.MaskThresMinEdit, 'String', num2str(tracking_opt.MaskThresMin));
    set( handles.text7, 'Enable', 'on');
    set( handles.MaskThresMaxEdit, 'Enable', 'on');
    tracking_opt.MaskThresMax = 1;
    set( handles.MaskThresMaxEdit, 'String', num2str(tracking_opt.MaskThresMax));
    set( handles.ApplySplineFilterCheck, 'Enable', 'on');
    set( handles.ApplySplineFilterCheck, 'Value', 1.0);
    tracking_opt.ApplySplineFilter = 'Yes';
    set( handles.OrientationPatchText, 'Enable', 'on');
    set( handles.InversionMenu, 'Enable', 'on');
    tracking_opt.Inversion = 'No Inversion';
    set( handles.InversionMenu, 'value', 1.0);
    set( handles.SwapMenu, 'Enable', 'on');
    tracking_opt.Swap = 'No Swap';
    set( handles.SwapMenu, 'value', 1.0);
else
    tracking_opt.DterminFiberTracking = 0;
    set( handles.FiberTrackingCheck, 'value', 0.0 );
    set( handles.ImageOrientationText, 'Enable', 'off');
    set( handles.ImageOrientationMenu, 'Enable', 'off');
    set( handles.AngleThresholdText, 'Enable', 'off');
    set( handles.AngleThresholdEdit, 'String', '' );
    set( handles.AngleThresholdEdit, 'Enable', 'off');
    set( handles.PropagationAlgorithmText, 'Enable', 'off');
    set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
    set( handles.StepLengthText, 'Enable', 'off');
    set( handles.StepLengthEdit, 'String', '');
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.MaskThresholdText, 'Enable', 'off');
    set(handles.MaskThresMinEdit, 'String', '');
    set( handles.MaskThresMinEdit, 'Enable', 'off');
    set( handles.text7, 'Enable', 'off');
    set(handles.MaskThresMaxEdit, 'String', '');
    set( handles.MaskThresMaxEdit, 'Enable', 'off');
    set( handles.ApplySplineFilterCheck, 'Value', 0.0);
    set( handles.ApplySplineFilterCheck, 'Enable', 'off');
    set( handles.OrientationPatchText, 'Enable', 'off');
    set( handles.InversionMenu, 'Enable', 'off');
    set( handles.SwapMenu, 'Enable', 'off');
end


% --- Executes on button press in DeterministicNetworkCheck.
function DeterministicNetworkCheck_Callback(hObject, eventdata, handles)
% hObject    handle to DeterministicNetworkCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DeterministicNetworkCheck
global T1orPartitionOfSubjectsPathCellMain;
global tracking_opt;
global DestinationPath_Edit;
global SubjectIDArray;
global FAPathCellMain;
global TensorPrefixEdit;
global PANDAPath;

if get(hObject,'Value')
    set(handles.FiberTrackingCheck, 'Enable', 'on');
    set(handles.NetworkNodeCheck, 'Enable', 'on');
    if ~tracking_opt.DterminFiberTracking
        DterminFiberTrackingInfo{1} = 'Are you sure to do deterministic network construction ?';
        DterminFiberTrackingInfo{2} = 'If you are sure, deterministic tracking will be selected automatically first !';
        DterminFiberTrackingButton = questdlg( DterminFiberTrackingInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(DterminFiberTrackingButton, 'Yes')
            tracking_opt.DterminFiberTracking = 1;
            set( handles.FiberTrackingCheck, 'value', 1.0 );
            set( handles.ImageOrientationText, 'Enable', 'on');
            set( handles.ImageOrientationMenu, 'Enable', 'on');
            tracking_opt.ImageOrientation = 'Auto';
            set( handles.ImageOrientationMenu, 'value', 1.0);
            set( handles.AngleThresholdText, 'Enable', 'on');
            set( handles.AngleThresholdEdit, 'Enable', 'on');
            tracking_opt.AngleThreshold = '35';
            set( handles.AngleThresholdEdit, 'String', tracking_opt.AngleThreshold);
            set( handles.PropagationAlgorithmText, 'Enable', 'on');
            set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
            tracking_opt.PropagationAlgorithm = 'FACT';
            set( handles.PropagationAlgorithmMenu, 'value', 1.0);
            set( handles.StepLengthEdit, 'Enable', 'off');
            set( handles.StepLengthText, 'Enable', 'on');
            set( handles.StepLengthEdit, 'Enable', 'off');
            set( handles.MaskThresholdText, 'Enable', 'on');
            set( handles.MaskThresMinEdit, 'Enable', 'on');
            tracking_opt.MaskThresMin = 0.1;
            set( handles.MaskThresMinEdit, 'String', num2str(tracking_opt.MaskThresMin));
            set( handles.text7, 'Enable', 'on');
            set( handles.MaskThresMaxEdit, 'Enable', 'on');
            tracking_opt.MaskThresMax = 1;
            set( handles.MaskThresMaxEdit, 'String', num2str(tracking_opt.MaskThresMax));
            set( handles.ApplySplineFilterCheck, 'Enable', 'on');
            set( handles.ApplySplineFilterCheck, 'Value', 1.0);
            tracking_opt.ApplySplineFilter = 'Yes';
            set( handles.OrientationPatchText, 'Enable', 'on');
            set( handles.InversionMenu, 'Enable', 'on');
            tracking_opt.Inversion = 'No Inversion';
            set( handles.InversionMenu, 'value', 1.0);
            set( handles.SwapMenu, 'Enable', 'on');
            tracking_opt.Swap = 'No Swap';
            set( handles.SwapMenu, 'value', 1.0);
        else
            tracking_opt.DterminFiberTracking = 0;
            set(hObject, 'Value', 0);
        end
    end
    if tracking_opt.DterminFiberTracking & ~tracking_opt.NetworkNode
        NetworkNodeInfo{1} = 'Then you should do network node definition !';
        NetworkNodeButton = questdlg( NetworkNodeInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(NetworkNodeButton, 'Yes')
            tracking_opt.NetworkNode = 1;
            set( handles.NetworkNodeCheck, 'Value', 1);
            tracking_opt.PartitionOfSubjects = 1;
            tracking_opt.T1 = 0;
            set( handles.PartitionOfSubjectsCheck, 'Enable', 'on');
            set( handles.T1Check, 'Enable', 'on');
            set( handles.PartitionOfSubjectsCheck, 'Value', 1.0);
            set( handles.T1Check, 'Value', 0.0);
            set( handles.LocationTableText, 'Enable', 'on' );
            set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'Enable', 'on' );
            set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
            ColumnName{1} = 'Path of FA';
            ColumnName{2} = 'Path of parcellated images';
            set(handles.PartitionTemplateEdit, 'String', '');
            set(handles.PartitionTemplateEdit, 'Enable', 'off');
            set(handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off');
            set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'ColumnName', ColumnName );
            FAPathCellMain = cell(length(SubjectIDArray),1);
            for i = 1:length(SubjectIDArray)
                FAPathCellMain{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f') filesep 'native_space' filesep TensorPrefixEdit '_' num2str(SubjectIDArray(i),'%05.0f') '_' 'FA.nii.gz'];
            end
            FAPath_T1orPartitionOfSubjectsPath = FAPathCellMain;
            set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath ); 
            ResizeFAT1orParcellatedTable(handles);
            % Remind to input partition files or T1 files
            PartitionOrT1Info{1} = 'Do you have parcellated images (native space) of subjects?';
            PartitionOrT1Info{2} = 'If you have, please select Parcellated Check and input parcellated images (native space);';
            PartitionOrT1Info{3} = 'Otherwise, please select T1 Check and input T1 images for subjects, PANDA will create parcellated images for each subject.';
            PartitionOrT1Button = questdlg( PartitionOrT1Info ,'Sure ?','Yes','No','Yes' );
            if strcmp(PartitionOrT1Button,'Yes')
                tracking_opt.PartitionOfSubjects = 1;
                tracking_opt.T1 = 0;
                set( handles.PartitionOfSubjectsCheck, 'Value', 1 );
                set( handles.T1Check, 'Value', 0 );
                set( handles.PartitionTemplateEdit, 'String', '');
                set( handles.PartitionTemplateEdit, 'Enable', 'off');
                set( handles.PartitionTemplateButton, 'Enable', 'off');
                set( handles.PartitionTemplateText, 'Enable', 'off');
                set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
                set( handles.T1PathButton, 'Enable', 'off');
                if tracking_opt.DterminFiberTracking && tracking_opt.NetworkNode ...
%                         && isempty(T1orPartitionOfSubjectsPathCellMain) 
                    PartitionInfo{1} = 'Then, you should select parcellated image (native space) for each subject according to FA path in the table';
                    PartitionInfo{2} = 'Are you sure?';
                    PartitionButton = questdlg( PartitionInfo ,'Sure ?','Yes','No','Yes' );
                    if strcmp(PartitionButton, 'Yes')
                        [x,T1orPartitionOfSubjectsPathCellMain] = Select('img');
                        if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
                            T1orPartitionOfSubjectsPathCellMain = '';
                            msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
                        else
                            FAPath_PartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
                            set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_PartitionOfSubjectsPath );
                            ResizeFAT1orParcellatedTable(handles);
                        end
                    else
                        set(hObject, 'Value', 0);
                    end
                end
            elseif strcmp(PartitionOrT1Button,'No')
                trackingAlone_opt.T1 = 1;
                trackingAlone_opt.PartitionOfSubjects = 0;
                set( handles.T1Check, 'Value', 1 );
                set( handles.PartitionOfSubjectsCheck, 'Value', 0 );
                set( handles.PartitionTemplateEdit, 'Enable', 'on');
                set( handles.PartitionTemplateButton, 'Enable', 'on');
                set( handles.PartitionTemplateText, 'Enable', 'on');
                set( handles.T1PathButton, 'Enable', 'on');
                set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
                tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
                set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);
                if tracking_opt.DterminFiberTracking && tracking_opt.NetworkNode ...
%                         && isempty(T1orPartitionOfSubjectsPathCellMain) 
                    T1Info{1} = 'Then, you should select T1 for each subject according to FA path in the table';
                    T1Info{2} = 'Are you sure?';
                    button = questdlg( T1Info ,'Sure ?','Yes','No','Yes' );
                    if strcmp(button, 'Yes')
                        [x, T1orPartitionOfSubjectsPathCellMain] = Select('img');
                        if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
                            T1orPartitionOfSubjectsPathCellMain = '';
                            msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
                        else
                            FAPath_T1Path = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
                            set( handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'data', FAPath_T1Path );
                            ResizeFAT1orParcellatedTable(handles);
                        end
                    else
                        set(hObject, 'Value', 0);
                    end
                end
            end
        else
            tracking_opt.NetworkNode = 0;
            set(hObject, 'Value', 0);
        end
    elseif isempty(T1orPartitionOfSubjectsPathCellMain) & tracking_opt.PartitionOfSubjects
        msgbox('Please select parcellated images (native space) according to the order of FA path !');
        set(hObject, 'Value', 0);
    elseif isempty(T1orPartitionOfSubjectsPathCellMain) & tracking_opt.T1
        msgbox('Please select T1 file according to the order of FA path !');
        set(hObject, 'Value', 0);
    elseif get(hObject, 'Value') == 1
        tracking_opt.DeterministicNetwork = 1;
    end
else
    tracking_opt.DeterministicNetwork = 0;
end


% --- Executes on button press in BedpostxAndProbabilisticCheck.
function BedpostxAndProbabilisticCheck_Callback(hObject, eventdata, handles)
% hObject    handle to BedpostxAndProbabilisticCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BedpostxAndProbabilisticCheck
global tracking_opt;
global T1orPartitionOfSubjectsPathCellMain;
global BedpostxAndProbabilisticOK;
if get(hObject,'Value')
    % If open alone, native folder input should be available
    % Make Fiber Tracking_Opt unavaliable
    if ~tracking_opt.NetworkNode
        msgbox('Please select Network Node First !');
        set(hObject, 'Value', 0);
    elseif isempty(T1orPartitionOfSubjectsPathCellMain) & tracking_opt.PartitionOfSubjects
        msgbox('Please select parcellated images (native space) according to the order of FA path !');
        set(hObject, 'Value', 0);
    elseif isempty(T1orPartitionOfSubjectsPathCellMain) & tracking_opt.T1
        msgbox('Please select T1 file according to the order of FA path !');
        set(hObject, 'Value', 0);
    else
        [BedpostxAndProbabilisticOpenId, Bedpostx_opt, ProbabilisticTracking_opt, BedpostxAndProbabilisticOK] = BedpostxAndProbabilistic_Opt;
        if BedpostxAndProbabilisticOK          
            tracking_opt.Fibers = Bedpostx_opt.Fibers;
            tracking_opt.Weight = Bedpostx_opt.Weight;
            tracking_opt.Burnin = Bedpostx_opt.Burnin;
            tracking_opt.ProbabilisticTrackingType = ProbabilisticTracking_opt.ProbabilisticTrackingType;
            tracking_opt.LabelIdVector = ProbabilisticTracking_opt.LabelIdVector;
            tracking_opt.LabelIdVectorText = ProbabilisticTracking_opt.LabelIdVectorText;
            tracking_opt.BedpostxProbabilisticNetwork = 1;
            clear global BedpostxAndProbabilisticOK;
        else
            set(hObject, 'Value', 0);
        end
    end
else
    tracking_opt.BedpostxProbabilisticNetwork = 0;
%     delete(BedpostxAndProbabilisticOpenId);
end


% --- Executes when TrackingFigure is resized.
function TrackingFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to TrackingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.TrackingFigure, 'Position');
%     if PositionFigure(4) < 200
    ResizeFAT1orParcellatedTable(handles);

    FontSizeNetworkConstructionUipanel = fix(8 * PositionFigure(4) / 479);
    set( handles.NetworkConstructionUipanel, 'FontSize', FontSizeNetworkConstructionUipanel );
%     end
end


function ResizeFAT1orParcellatedTable(handles)
PositionFigure = get(handles.TrackingFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 2;
WidthCell{2} = WidthCell{1};
set(handles.FAPath_T1orPartitionTOfSubjectsPathTable, 'ColumnWidth', WidthCell);


% --- Executes when NetworkConstructionUipanel is resized.
function NetworkConstructionUipanel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to NetworkConstructionUipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function LocationTableText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LocationTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in LocationTableText.
function LocationTableText_Callback(hObject, eventdata, handles)
% hObject    handle to LocationTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ImageOrientationText.
function ImageOrientationText_Callback(hObject, eventdata, handles)
% hObject    handle to ImageOrientationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PropagationAlgorithmText.
function PropagationAlgorithmText_Callback(hObject, eventdata, handles)
% hObject    handle to PropagationAlgorithmText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MaskThresholdText.
function MaskThresholdText_Callback(hObject, eventdata, handles)
% hObject    handle to MaskThresholdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OrientationPatchText.
function OrientationPatchText_Callback(hObject, eventdata, handles)
% hObject    handle to OrientationPatchText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AngleThresholdText.
function AngleThresholdText_Callback(hObject, eventdata, handles)
% hObject    handle to AngleThresholdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in StepLengthText.
function StepLengthText_Callback(hObject, eventdata, handles)
% hObject    handle to StepLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
