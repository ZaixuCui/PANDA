function varargout = PANDA_Tracking(varargin)
% GUI for Tracking & Constructing Network(an independent component of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_TRACKING MATLAB code for PANDA_Tracking.fig
%      PANDA_TRACKING, by itself, creates a new PANDA_TRACKING or raises the existing
%      singleton*.
%
%      H = PANDA_TRACKING returns the handle to a new PANDA_TRACKING or the handle to
%      the existing singleton*.
%
%      PANDA_TRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_TRACKING.M with the given input arguments.
%
%      PANDA_TRACKING('Property','Value',...) creates a new PANDA_TRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Tracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Tracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Tracking

% Last Modified by GUIDE v2.5 24-Aug-2015 15:29:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Tracking_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Tracking_OutputFcn, ...
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


% --- Executes just before PANDA_Tracking is made visible.
function PANDA_Tracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Tracking (see VARARGIN)

% Choose default command line output for PANDA_Tracking
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes PANDA_Tracking wait for user response (see UIRESUME)
% uiwait(handles.PANDATrackingFigure);
global trackingAlone_opt;
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global NativePathCellTracking;
global NativePathSelectedTracking;
global TrackingPipeline_opt;
global StopFlag_InTrackingStatus;
global PANDAPath;

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

set(handles.AddNativeFolderButton, 'UserData', []);
set(handles.FAPathButton, 'UserData', []);

trackingAlone_opt.DeterminTrackingOptionChange = 0;
trackingAlone_opt.ImageOrientation = 'Auto';

NativePathSelectedTracking = 0;
StopFlag_InTrackingStatus = '';
% Pipeline options
set( handles.batchRadio, 'Value', 1);
TrackingPipeline_opt.mode = 'background';
set( handles.QsubOptionsEdit, 'String', '');
set( handles.QsubOptionsEdit, 'Enable', 'off');
TrackingPipeline_opt.path_logs = [pwd filesep 'Tracking_logs'];
set( handles.LogPathEdit, 'String', pwd );
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
    TrackingPipeline_opt.max_queued = str2num(QuantityOfCpu);
else
    TrackingPipeline_opt.max_queued = 2;
end
set(handles.MaxQueuedEdit, 'string', num2str(TrackingPipeline_opt.max_queued));
% Set the initial value of Deterministic Fiber Tracking
if ~isfield(trackingAlone_opt, 'DterminFiberTracking')
    trackingAlone_opt.DterminFiberTracking = 0;
    set( handles.FiberTrackingCheck, 'Value', 0);
%     set( handles.ImageOrientationText, 'Enable', 'off');
    trackingAlone_opt.ImageOrientation = 'Auto';
%     set( handles.ImageOrientationMenu, 'value', 1.0);
%     set( handles.ImageOrientationMenu, 'Enable', 'off');
    set( handles.AngleThresholdText, 'Enable', 'off');
    trackingAlone_opt.AngleThreshold = '45';
    set( handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
    set( handles.AngleThresholdEdit, 'Enable', 'off');
    set( handles.PropagationAlgorithmText, 'Enable', 'off');
    trackingAlone_opt.PropagationAlgorithm = 'FACT';
    set( handles.PropagationAlgorithmMenu, 'value', 1.0);    
    set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
    set( handles.StepLengthText, 'Enable', 'off');
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.MaskThresholdText, 'Enable', 'off');
    trackingAlone_opt.MaskThresMin = 0.2;
    set( handles.MaskThresMinEdit, 'String', '0.2');    
    set( handles.MaskThresMinEdit, 'Enable', 'off');
    set( handles.text7, 'Enable', 'off');
    trackingAlone_opt.MaskThresMax = 1;
    set( handles.MaskThresMaxEdit, 'String', '1');
    set( handles.MaskThresMaxEdit, 'Enable', 'off');
    trackingAlone_opt.ApplySplineFilter = 'No';
    set( handles.ApplySplineFilterCheck, 'Value', 0);
    set( handles.ApplySplineFilterCheck, 'Enable', 'off');
    set( handles.OrientationPatchText, 'Enable', 'off');
    trackingAlone_opt.Inversion = 'Invert Z';
    set( handles.InversionMenu, 'value', 4.0);
    set( handles.InversionMenu, 'Enable', 'off');
    trackingAlone_opt.Swap = 'No Swap';
    set( handles.SwapMenu, 'value', 1.0);
    set( handles.SwapMenu, 'Enable', 'off');
    trackingAlone_opt.RandomSeed_Flag = 0;
    set( handles.RandomSeedCheckbox, 'Value', 0);
    set( handles.RandomSeedCheckbox, 'Enable', 'off');
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
end
% Network Node Definition
if ~isfield(trackingAlone_opt, 'NetworkNode')
    trackingAlone_opt.NetworkNode = 0;
    set( handles.NetworkNodeCheck, 'value', 0.0);
    set( handles.FAPathButton, 'Enable', 'off');
    trackingAlone_opt.PartitionOfSubjects = 0;
    set( handles.PartitionCheck, 'Enable', 'off');
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    trackingAlone_opt.T1 = 0;
    set( handles.T1Check, 'Enable', 'off');
    set( handles.T1PathButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off'); 
    set( handles.PartitionTemplateEdit, 'String', '');
    set( handles.PartitionTemplateEdit, 'Enable', 'off'); 
    set( handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.T1TemplateText, 'Enable', 'off'); 
    set( handles.T1TemplateEdit, 'String', '');
    set( handles.T1TemplateEdit, 'Enable', 'off'); 
    set( handles.T1TemplateButton, 'Enable', 'off');
    set( handles.T1BetCheckbox, 'Enable', 'off'); 
    set( handles.BetFText, 'Enable', 'off');
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off'); 
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
    set( handles.T1CroppingGapText, 'Enable', 'off'); 
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%     set( handles.T1CroppingGapUnitText, 'Enable', 'off'); 
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionText, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
    FAPathCellTracking = '';
    T1orPartitionOfSubjectsPathCellTracking = '';
    DataCell = cell(4,1);
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of parcellated images';
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell, 'ColumnName', ColumnName );
    ResizeFAT1orParcellatedTable(handles);
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off');  
end
% network construction
trackingAlone_opt.DeterministicNetwork = 0;
trackingAlone_opt.ProbabilisticNetwork = 0;
trackingAlone_opt.BedpostxProbabilisticNetwork = 0;
% Set icon
SetIcon(handles);
%
TipStr = sprintf(['Two cases:' ...
    '\n 1. For deterministic tracking / network or Bedpostx+Probabilistic network:' ...
    '\n    Full path of a folder containing four files as listed:' ...
    '\n    (1) A 4D image named data.nii.gz containing diffusion-weighted' ... 
    '\n        volumes and volumes without diffusion weighting.' ...
    '\n    (2) A 3D binary brain mask volume named nodif_brain_mask.nii.gz.' ...
    '\n    (3) A text file named bvecs containing gradient directions for' ...
    '\n        diffusion weighted volumes.' ...
    '\n    (4) A text file named bvals containing b-values applied for' ...
    '\n        each volume acquisition.' ...
    '\n 2. For Probabilistic network:' ...
    '\n    Full path of the resulatnt folder of bedpostX.']);
set(handles.AddNativeFolderButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Digital IDs for subjects, \n for example, [1 4 8:20].' ...
    '\n Two methods to assign IDs' ...
    '\n 1. Input the IDs here.' ...
    '\n 2. Load .PANDA file to acquire the IDs of subjects in the full pipeline.']);
set(handles.SubjectIDEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['The full path of FA image and T1 image of each subject,' ...
    '\n the order of T1 images must be the same as FA images.']);
set(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'TooltipString', TipStr);
%
TipStr = sprintf(['Input all subjects'' FA images (native space) of each subject,' ...
    '\n the order of FA images should be equal to native folders.']);
set(handles.FAPathButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['When having subjects'' parcellated images in native space,' ...
    '\n please click this.']);
set(handles.PartitionCheck, 'TooltipString', TipStr);
%
TipStr = sprintf(['Input all subjects'' parcellated images in native space' ...
    '\n accroding to the order of subjects'' FA images.']);
set(handles.PartitionOfSubjectsButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['When having no subjects'' parcellated images in native space, please' ...
    '\n click this. Then, PANDA will do brain parcellation according to the' ...
    '\n method proposed in (Gong, et al., 2009).']);
set(handles.T1Check, 'TooltipString', TipStr);
%
TipStr = sprintf(['Input all subjects'' T1 images according to the order of' ...
    '\n subjects'' FA mages.']);
set(handles.T1PathButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Parcellated atlas in the MNI standard space for brain parcellation.' ...
    '\n Default, AAL atlas with 90 regions.']);
set(handles.PartitionTemplateEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('If brain extraction is need for T1 images, please click this.');
set(handles.T1BetCheckbox, 'TooltipString', TipStr);
%
TipStr = sprintf(['Fractional intensity threshold (0->1) for T1 brain extraction,' ... 
    '\n default = 0.5, smaller values give larger brain outline estimates.']);
set(handles.T1BetFEdit, 'TooltipString', TipStr);
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
TipStr = sprintf(['The path of FA image and T1 image of each subject,' ...
    '\n the order of T1 images must be the same as FA images.']);
set(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'TooltipString', TipStr);
%
TipStr = sprintf('Doing deterministic network construction.');
set(handles.DeterministicNetworkCheck, 'TooltipString', TipStr);
%
TipStr = sprintf(['Doing probabilistic network construction based on the results' ...
    '\n of bedpostX.']);
set(handles.ProbabilisticNetworkCheck, 'TooltipString', TipStr);
%
TipStr = sprintf('Doing bedpostX & probabilistic network construction.');
set(handles.BedpostxAndProbabilisticCheck, 'TooltipString', TipStr);
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
TipStr = sprintf('Status of the jobs.');
set(handles.StatusButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Terminate all the running jobs associated with the current input.' ...
    '\n Because all the jobs run in background, user can only terminate' ...
    '\n jobs by clicking this button.']);
set(handles.TerminateJobButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Load .PANDA_Tracking file to display the information in' ...
    '\n the GUI.']);
set(handles.LoadButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['After clicking the button, the information in the GUI' ...
    '\n will be saved in a .PANDA_Tracking file under ''Log_Path''.']);
set(handles.RUNButton, 'TooltipString', TipStr);

        
% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Tracking_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% % --- Executes on selection change in ImageOrientationMenu.
% function ImageOrientationMenu_Callback(hObject, eventdata, handles)
% % hObject    handle to ImageOrientationMenu (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns ImageOrientationMenu contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from ImageOrientationMenu
% global trackingAlone_opt;
% OldValue = trackingAlone_opt.ImageOrientation;
% sel = get(hObject, 'value');
% switch sel
%     case 1
%         trackingAlone_opt.ImageOrientation = 'Auto';
%     case 2
%         trackingAlone_opt.ImageOrientation = 'Axial';
%     case 3
%         trackingAlone_opt.ImageOrientation = 'Coronal';
%     case 4
%         trackingAlone_opt.ImageOrientation = 'Sagittal';
% end
% if ~strcmp(OldValue, trackingAlone_opt.ImageOrientation)
%     trackingAlone_opt.DeterminTrackingOptionChange = 1;
% end

% 
% % --- Executes during object creation, after setting all properties.
% function ImageOrientationMenu_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to ImageOrientationMenu (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% set(hObject,'BackgroundColor','white');


% --- Executes on selection change in PropagationAlgorithmMenu.
function PropagationAlgorithmMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PropagationAlgorithmMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PropagationAlgorithmMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PropagationAlgorithmMenu
global trackingAlone_opt;
sel = get(hObject, 'value');
switch sel
    case 1
        trackingAlone_opt.PropagationAlgorithm = 'FACT';
        set(handles.StepLengthEdit, 'String', '');
        set(handles.StepLengthEdit, 'Enable', 'off');
    case 2
        trackingAlone_opt.PropagationAlgorithm = '2nd-order Runge Kutta';
        set(handles.StepLengthEdit, 'Enable', 'on');
        trackingAlone_opt.StepLength = 0.1;
        set(handles.StepLengthEdit, 'String', '0.1');
    case 3
        trackingAlone_opt.PropagationAlgorithm = 'Interpolated Streamline';
        set(handles.StepLengthEdit, 'Enable', 'on');
        trackingAlone_opt.StepLength = 0.5;
        set(handles.StepLengthEdit, 'String', '0.5');
    case 4
        trackingAlone_opt.PropagationAlgorithm = 'Tensorline';
        set(handles.StepLengthEdit, 'Enable', 'on');
        trackingAlone_opt.StepLength = 0.1;
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
global trackingAlone_opt;
StepLengthString = get(hObject, 'string');
trackingAlone_opt.StepLength = str2double(StepLengthString);


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
global trackingAlone_opt;
trackingAlone_opt.AngleThreshold = get(hObject, 'string');



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
global trackingAlone_opt;
MaskThresMinString = get(hObject, 'string'); 
if isempty(MaskThresMinString)
    trackingAlone_opt.MaskThresMin = [];
else
    trackingAlone_opt.MaskThresMin = str2double(MaskThresMinString);
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
global trackingAlone_opt;
MaskThresMaxString = get(hObject, 'string');
if isempty(MaskThresMaxString)
    trackingAlone_opt.MaskThresMax = [];
else
    trackingAlone_opt.MaskThresMax = str2double(MaskThresMaxString);
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
global trackingAlone_opt;
OldValue = trackingAlone_opt.Inversion;
sel = get(hObject, 'value');
switch sel
    case 1
        trackingAlone_opt.Inversion = 'No Inversion';
    case 2
        trackingAlone_opt.Inversion = 'Invert X';
    case 3
        trackingAlone_opt.Inversion = 'Invert Y';
    case 4
        trackingAlone_opt.Inversion = 'Invert Z';
end
if ~strcmp(OldValue, trackingAlone_opt.Inversion)
    trackingAlone_opt.DeterminTrackingOptionChange = 1;
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
global trackingAlone_opt;
OldValue = trackingAlone_opt.Swap;
sel = get(hObject, 'value');
switch sel
    case 1
        trackingAlone_opt.Swap = 'No Swap';
    case 2
        trackingAlone_opt.Swap = 'Swap X/Y';
    case 3
        trackingAlone_opt.Swap = 'Swap Y/Z';
    case 4
        trackingAlone_opt.Swap = 'Swap Z/X';
end
if ~strcmp(OldValue, trackingAlone_opt.Swap)
    trackingAlone_opt.DeterminTrackingOptionChange = 1;
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
global trackingAlone_opt;
if get(hObject, 'value')
    trackingAlone_opt.ApplySplineFilter = 'Yes';
else
    trackingAlone_opt.ApplySplineFilter = 'No';
end


% --- Executes on button press in NetworkNodeCheck.
function NetworkNodeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to NetworkNodeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NetworkNodeCheck
global trackingAlone_opt;
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global TensorPrefixEdit;
global PANDAPath;

if get(hObject, 'value') == 1
    if isempty(FAPathCellTracking)
        info{1} = 'Are you sure to do Network Node Definition ?';
        info{2} = 'If you are sure to run, please select FA path first!';
        button = questdlg( info ,'Sure ?','Yes','No','Yes' );
        if strcmp(button,'Yes')
            set( handles.FAPathButton, 'Enable', 'on');
            set(hObject, 'value', 0);
            [a, FAPathCellTracking] = PANDA_Select('img');
            if ~isempty(FAPathCellTracking)
                trackingAlone_opt.NetworkNode = 1;
                trackingAlone_opt.PartitionOfSubjects = 1;
                trackingAlone_opt.T1 = 0;
                set( handles.NetworkNodeCheck, 'Value', 1.0);
                set( handles.PartitionCheck, 'Enable', 'on');
                set( handles.T1Check, 'Enable', 'on');
                set( handles.PartitionCheck, 'Value', 1.0);
                set( handles.T1Check, 'Value', 0.0);
                set( handles.LocationTableText, 'Enable', 'on' );
                set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on' );
                set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
                ColumnName{1} = 'Path of FA';
                ColumnName{2} = 'Path of parcellated images';
                set( handles.PartitionTemplateEdit, 'String', '');
                set( handles.PartitionTemplateEdit, 'Enable', 'off');
                set( handles.PartitionTemplateButton, 'Enable', 'off');
                set( handles.PartitionTemplateText, 'Enable', 'off');
                set( handles.T1TemplateEdit, 'String', '');
                set( handles.T1TemplateEdit, 'Enable', 'off');
                set( handles.T1TemplateButton, 'Enable', 'off');
                set( handles.T1TemplateText, 'Enable', 'off');
                set( handles.T1BetCheckbox, 'Value', 0); 
                set( handles.T1BetCheckbox, 'Enable', 'off'); 
                set( handles.BetFText, 'Enable', 'off');
                set( handles.T1BetFEdit, 'String', '');
                set( handles.T1BetFEdit, 'Enable', 'off'); 
                set( handles.T1CroppingGapCheckbox, 'Value', 0); 
                set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
                set( handles.T1CroppingGapText, 'Enable', 'off'); 
                set( handles.T1CroppingGapEdit, 'String', '');
                set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%                 set( handles.T1CroppingGapUnitText, 'Enable', 'off');
                set( handles.T1ResampleCheckbox, 'Enable', 'off');
                set( handles.T1ResampleCheckbox, 'Value', 0);
                set( handles.T1ResampleResolutionText, 'Enable', 'off');
                set( handles.T1ResampleResolutionEdit, 'String', '');
                set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
                set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
                if isempty(T1orPartitionOfSubjectsPathCellTracking)
                    FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
                    msgbox('Please select parcellated images (native space) or T1 images according to the order of FA images');
                else
                    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                end
                set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
                ResizeFAT1orParcellatedTable(handles);
            else
                trackingAlone_opt.NetworkNode = 0;
                set( handles.NetworkNodeCheck, 'Value', 0.0 );
                DataCell = cell(4,1);
                set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
                ResizeFAT1orParcellatedTable(handles);
                set( handles.LocationTableText, 'Enable', 'off' );
                set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off' );
                set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
                set( handles.PartitionTemplateText, 'Enable', 'off' );
                set( handles.PartitionTemplateEdit, 'String', '' );
                set( handles.PartitionTemplateEdit, 'Enable', 'off' );
                set( handles.PartitionTemplateButton, 'Enable', 'off' );
                set( handles.T1TemplateText, 'Enable', 'off' );
                set( handles.T1TemplateEdit, 'String', '' );
                set( handles.T1TemplateEdit, 'Enable', 'off' );
                set( handles.T1TemplateButton, 'Enable', 'off' );
                set( handles.PartitionCheck, 'value', 0.0 );
                set( handles.T1Check, 'value', 0.0 );
                set( handles.PartitionCheck, 'Enable', 'off' );
                set( handles.T1Check, 'Enable', 'off' );
                set( handles.T1BetCheckbox, 'Value', 0); 
                set( handles.T1BetCheckbox, 'Enable', 'off'); 
                set( handles.BetFText, 'Enable', 'off');
                set( handles.T1BetFEdit, 'String', '');
                set( handles.T1BetFEdit, 'Enable', 'off'); 
                set( handles.T1CroppingGapCheckbox, 'Value', 0); 
                set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
                set( handles.T1CroppingGapText, 'Enable', 'off'); 
                set( handles.T1CroppingGapEdit, 'String', '');
                set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%                 set( handles.T1CroppingGapUnitText, 'Enable', 'off');
                set( handles.T1ResampleCheckbox, 'Value', 0);
                set( handles.T1ResampleCheckbox, 'Enable', 'off');
                set( handles.T1ResampleResolutionText, 'Enable', 'off');
                set( handles.T1ResampleResolutionEdit, 'String', '');
                set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            end
        else
            set(hObject, 'Value', 0);
        end
    else
        trackingAlone_opt.NetworkNode = 1;
        if ~trackingAlone_opt.PartitionOfSubjects && ~trackingAlone_opt.T1
            trackingAlone_opt.PartitionOfSubjects = 1;
            trackingAlone_opt.T1 = 0;
        end
        set( handles.FAPathButton, 'Enable', 'on');
        set( handles.PartitionCheck, 'Enable', 'on');
        set( handles.T1Check, 'Enable', 'on');
        set( handles.LocationTableText, 'Enable', 'on' );
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on' );
        ColumnName{1} = 'Path of FA';
        if trackingAlone_opt.PartitionOfSubjects
            set( handles.PartitionCheck, 'Value', 1.0);
            set( handles.T1Check, 'Value', 0.0);
            set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
            set( handles.T1PathButton, 'Enable', 'off' );
            ColumnName{2} = 'Path of parcellated images';
            set( handles.PartitionTemplateEdit, 'String', '');
            set( handles.PartitionTemplateEdit, 'Enable', 'off');
            set( handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off');
            set( handles.T1TemplateEdit, 'String', '');
            set( handles.T1TemplateEdit, 'Enable', 'off');
            set( handles.T1TemplateButton, 'Enable', 'off');
            set( handles.T1TemplateText, 'Enable', 'off');
            set( handles.T1BetCheckbox, 'Value', 0);
            set( handles.T1BetCheckbox, 'Enable', 'off'); 
            set( handles.BetFText, 'Enable', 'off');
            set( handles.T1BetFEdit, 'String', '');
            set( handles.T1BetFEdit, 'Enable', 'off'); 
            set( handles.T1CroppingGapCheckbox, 'Value', 0);
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
            set( handles.T1CroppingGapText, 'Enable', 'off'); 
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off');
%             set( handles.T1CroppingGapUnitText, 'Enable', 'off');
            set( handles.T1ResampleCheckbox, 'Value', 0);
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionText, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
        else
            set( handles.PartitionCheck, 'Value', 0.0);
            set( handles.T1Check, 'Value', 1.0);
            set( handles.T1PathButton, 'Enable', 'on' );
            set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
            ColumnName{2} = 'Path of T1';
            trackingAlone_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
            set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
            set( handles.PartitionTemplateEdit, 'Enable', 'on');
            set( handles.PartitionTemplateButton, 'Enable', 'on');
            set( handles.PartitionTemplateText, 'Enable', 'on');
            trackingAlone_opt.T1Template = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain'];
            set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template);
            set( handles.T1TemplateEdit, 'Enable', 'on');
            set( handles.T1TemplateButton, 'Enable', 'on');
            set( handles.T1TemplateText, 'Enable', 'on');
            set( handles.T1BetCheckbox, 'Enable', 'on');
            trackingAlone_opt.T1Bet_Flag = 1;
            set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
            set( handles.BetFText, 'Enable', 'on'); 
            set( handles.T1BetFEdit, 'Enable', 'on'); 
            trackingAlone_opt.T1BetF = 0.5;
            set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF)); 
            set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
            trackingAlone_opt.T1Cropping_Flag = 1;
            set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
            set( handles.T1CroppingGapText, 'Enable', 'on');
            set( handles.T1CroppingGapEdit, 'Enable', 'on');
            trackingAlone_opt.T1CroppingGap = 3;
            set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
%             set( handles.T1CroppingGapUnitText, 'Enable', 'on');
            set( handles.T1ResampleCheckbox, 'Enable', 'on');
            trackingAlone_opt.T1Resample_Flag = 1;
            set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
            set( handles.T1ResampleResolutionText, 'Enable', 'on');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
            trackingAlone_opt.T1ResampleResolution = [1 1 1];
            set( handles.T1ResampleResolutionEdit, 'String', '[1 1 1]');
        end
        if ~isempty(T1orPartitionOfSubjectsPathCellTracking)
            FAPath_T1orPartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
        else
            FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
        end
        msgbox('Please select parcellated images (native space) or T1 images according to the order of FA images');
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName, 'data', FAPath_T1orPartitionOfSubjectsPath );
        ResizeFAT1orParcellatedTable(handles);
    end
else
    trackingAlone_opt.NetworkNode = 0;
    set( handles.FAPathButton, 'Enable', 'off');
    DataCell = cell(4,1);
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
    ResizeFAT1orParcellatedTable(handles);
    set( handles.FAPathButton, 'Enable', 'off');
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off' );
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
    set( handles.T1PathButton, 'Enable', 'off' );
    set( handles.PartitionTemplateText, 'Enable', 'off' );
    set( handles.PartitionTemplateEdit, 'String', '' );
    set( handles.PartitionTemplateEdit, 'Enable', 'off' );
    set( handles.PartitionTemplateButton, 'Enable', 'off' );
    set( handles.T1TemplateText, 'Enable', 'off' );
    set( handles.T1TemplateEdit, 'String', '' );
    set( handles.T1TemplateEdit, 'Enable', 'off' );
    set( handles.T1TemplateButton, 'Enable', 'off' );
    set( handles.PartitionCheck, 'value', 0.0 );
    set( handles.T1Check, 'value', 0.0 );
    set( handles.PartitionCheck, 'Enable', 'off' );
    set( handles.T1Check, 'Enable', 'off' );
    set( handles.T1BetCheckbox, 'Value', 0);
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.BetFText, 'Enable', 'off');
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off');
    set( handles.T1CroppingGapCheckbox, 'Value', 0);
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
    set( handles.T1CroppingGapText, 'Enable', 'off');
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
%     set( handles.T1CroppingGapUnitText, 'Enable', 'off');
    set( handles.T1ResampleCheckbox, 'Value', 0);
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionText, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
end


% --- Executes on button press in PartitionOfSubjectsButton.
function PartitionOfSubjectsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionOfSubjectsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
T1orPartitionOfSubjectsPathCell_Button = get(hObject, 'UserData');
[x, T1orPartitionOfSubjectsPathCellTracking, Done] = PANDA_Select('img', T1orPartitionOfSubjectsPathCell_Button);
if Done == 1
    set(hObject, 'UserData', T1orPartitionOfSubjectsPathCellTracking);
    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
        T1orPartitionOfSubjectsPathCellTracking = '';
        msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
    else
        FAPath_PartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_PartitionOfSubjectsPath );
        ResizeFAT1orParcellatedTable(handles);
    end
end


% --- Executes on button press in T1PathButton.
function T1PathButton_Callback(hObject, eventdata, handles)
% hObject    handle to T1PathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
T1orPartitionOfSubjectsPathCell_Button = get(hObject, 'UserData');
[x, T1orPartitionOfSubjectsPathCellTracking, Done] = PANDA_Select('img', T1orPartitionOfSubjectsPathCell_Button);
if Done == 1
    set(hObject, 'UserData', T1orPartitionOfSubjectsPathCellTracking);
    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
        T1orPartitionOfSubjectsPathCellTracking = '';
        msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
    else
        FAPath_T1Path = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1Path );
        ResizeFAT1orParcellatedTable(handles);
    end
end


function PartitionTemplateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PartitionTemplateEdit as text
%        str2double(get(hObject,'String')) returns contents of PartitionTemplateEdit as a double
global trackingAlone_opt;
PartitionTemplatePath = get( handles.PartitionTemplateEdit, 'string' );
trackingAlone_opt.PartitionTemplate = PartitionTemplatePath;


% --- Executes during object creation, after setting all properties.
function PartitionTemplateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');


% --- Executes on button press in PartitionTemplateButton.
function PartitionTemplateButton_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackingAlone_opt;
[PartitionTemplateName,PartitionTemplateParent] = uigetfile({'*.nii;*.nii.gz','NIfTI-files (*.nii, *nii.gz)'});
PartitionTemplatePath = [PartitionTemplateParent PartitionTemplateName];
if PartitionTemplateParent ~= 0
    set( handles.PartitionTemplateEdit, 'string', PartitionTemplatePath );
    trackingAlone_opt.PartitionTemplate = PartitionTemplatePath;
end


% --- Executes on button press in RUNButton.
function RUNButton_Callback(hObject, eventdata, handles)
% hObject    handle to RUNButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Excute 'close' command, it will call PANDATrackingFigure_CloseRequestFcn function
global trackingAlone_opt;
global T1orPartitionOfSubjectsPathCellTracking;
global NativePathCellTracking;
global SubjectIDArrayTracking;
global FAPathCellTracking;
global TrackingPipeline_opt;
global JobStatusMonitorTimer_InTracking;
global StopFlag_InTrackingStatus;
global LockExistTracking;
global LockDisappearTracking;
global PANDAPath;

LockFilePath = [TrackingPipeline_opt.path_logs filesep 'PIPE.lock'];
if exist(LockFilePath, 'file') || strcmp(get(handles.LogPathEdit, 'Enable'), 'off')
    StringPrint{1} = ['A lock file ' LockFilePath ' has been found on the pipeline !'];
    StringPrint{2} = 'If you want to run this new pipeline, ';
    StringPrint{3} = ['please delete the lock file ' LockFilePath ' first !'];
    msgbox(StringPrint);
else
    DeterminFiberTrackingOptionsFinish = 0;
    NetworkNodeOptionsFinish = 0;
    PipelineOptionsFinish = 0;
    
    % Check input of pipeline options
    if strcmp(TrackingPipeline_opt.mode, 'qsub') && isempty(TrackingPipeline_opt.qsub_options)
        msgbox('Please input qsub options !');
    elseif isempty(TrackingPipeline_opt.max_queued)
        msgbox('Please input max queued !');
    elseif isempty(TrackingPipeline_opt.path_logs)
        msgbox('Please input log file path !');
    else
        PipelineOptionsFinish = 1;
    end
    % Check input of tracking options
    if trackingAlone_opt.DterminFiberTracking
        if isempty(NativePathCellTracking)
            msgbox('Please input subjects'' folders for Deterministic Fiber Tracking !');
        elseif isempty(SubjectIDArrayTracking)
            msgbox('Please input subjects'' ids.');
        elseif isempty(trackingAlone_opt.MaskThresMin)
            msgbox('Please input the minimum of mask threshold !');
        elseif isempty(trackingAlone_opt.MaskThresMax)
            msgbox('Please input the maximum of mask threshold !');
        elseif isempty(trackingAlone_opt.AngleThreshold)
            msgbox('Please input angle threshold !');
        elseif ~strcmp(trackingAlone_opt.PropagationAlgorithm, 'FACT') ...
                && ~isfield(trackingAlone_opt,'StepLength')
            msgbox('Please input step length !');
        else
            DeterminFiberTrackingOptionsFinish = 1;
        end
    else
        DeterminFiberTrackingOptionsFinish = 1;
    end
    % Check input of Network Node Definition options
    if trackingAlone_opt.NetworkNode
        if trackingAlone_opt.PartitionOfSubjects && isempty(T1orPartitionOfSubjectsPathCellTracking)
            msgbox('Please input parcellated images (native space) according the order of FA paths !');
        elseif trackingAlone_opt.T1 
            if isempty(T1orPartitionOfSubjectsPathCellTracking)
                msgbox('Please input T1 paths according the order of FA paths.');
            elseif isempty(trackingAlone_opt.PartitionTemplate)
                msgbox('Please input atlas (standard space).');
            elseif isempty(trackingAlone_opt.T1Template)
                msgbox('Please input the template of T1.');
            elseif isempty(trackingAlone_opt.T1BetF)
                msgbox('Please input f(skull_removal) for T1 brain extraction.');
            elseif trackingAlone_opt.T1Cropping_Flag
                if isempty(trackingAlone_opt.T1CroppingGap)
                    msgbox('Please input the cropping gap for cropping T1 image.');
                elseif trackingAlone_opt.T1Resample_Flag
                    if isempty(trackingAlone_opt.T1ResampleResolution)
                        msgbox('Please input the resolution for resampling T1 image.');
                    else
                        NetworkNodeOptionsFinish = 1;
                    end
                else
                    NetworkNodeOptionsFinish = 1;
                end
            elseif trackingAlone_opt.T1Resample_Flag
                if isempty(trackingAlone_opt.T1ResampleResolution)
                    msgbox('Please input the resolution for resampling T1 image.');
                else
                    NetworkNodeOptionsFinish = 1;
                end
            else
                NetworkNodeOptionsFinish = 1;
            end
        else
            NetworkNodeOptionsFinish = 1;
        end
    else
        NetworkNodeOptionsFinish = 1;
    end
    LogPathPermissionDenied = 0;
    try
        if ~exist(TrackingPipeline_opt.path_logs, 'dir')
            mkdir(TrackingPipeline_opt.path_logs);
        end
        x = 1;
        save([TrackingPipeline_opt.path_logs filesep 'permission_tag.mat'], 'x');
    catch
        LogPathPermissionDenied = 1;
        msgbox('Please change log path, perssion denied !');
    end
    if exist([TrackingPipeline_opt.path_logs filesep 'PIPE.lock'], 'file')
        Info{1} = ['A lock file ' TrackingPipeline_opt.path_logs filesep 'PIPE.lock has been found on the pipeline !'];
        Info{2} = 'Please change your log file path !';
        msgbox(Info);
    elseif DeterminFiberTrackingOptionsFinish & NetworkNodeOptionsFinish & PipelineOptionsFinish & ~LogPathPermissionDenied
        if trackingAlone_opt.NetworkNode & ~trackingAlone_opt.DeterministicNetwork ...
            && ~trackingAlone_opt.BedpostxProbabilisticNetwork & ~trackingAlone_opt.ProbabilisticNetwork
            msgbox('Please select network construction options, since you have chosen to do network node definition.');
        elseif trackingAlone_opt.NetworkNode & length(NativePathCellTracking) ~= length(FAPathCellTracking)
            msgbox('The quantity of subjects'' folders should be equal to the quantity of FA.');
        else
            info{1} = 'Are you sure to Run ?';
            button = questdlg( info ,'Sure to Run ?','Yes','No','Yes' );
            switch button
                case 'Yes'
                    % Save the configuration
                    DateNow = datevec(datenum(now));
                    DateNowString = [num2str(DateNow(1)) '_' num2str(DateNow(2), '%02d') '_' num2str(DateNow(3), '%02d') '_' num2str(DateNow(4), '%02d') '_' num2str(DateNow(5), '%02d')];
                    ParameterSaveFilePath = [TrackingPipeline_opt.path_logs  filesep DateNowString '.PANDA_Tracking'];

                    cmdString = [ 'save ' ParameterSaveFilePath ' NativePathCellTracking' ' SubjectIDArrayTracking' ' TrackingPipeline_opt' ' trackingAlone_opt' ' PANDAPath'];
                    eval(cmdString);
                    if trackingAlone_opt.NetworkNode == 1
                        cmdString = [ 'save ' ParameterSaveFilePath ' FAPathCellTracking' ' T1orPartitionOfSubjectsPathCellTracking' ' -append'];
                        eval(cmdString);
                    end
                    if trackingAlone_opt.DterminFiberTracking || trackingAlone_opt.ProbabilisticNetwork ...
                            || trackingAlone_opt.BedpostxProbabilisticNetwork
                        cmdString = [ 'save ' ParameterSaveFilePath ' NativePathCellTracking' ' -append'];
                        eval(cmdString);
                    end
                    if exist( ParameterSaveFilePath, 'file' )
                        clc;
                        disp( 'The variable is saved!' );
                        disp( [ 'The full path is ' ParameterSaveFilePath ] );
                        disp( 'The jobs will start running !' );
                    else
                        msgbox( 'Sorry, something has happened , the variables has not been saved!' );
                    end
                    % Excute the pipeline
                    if ~exist(TrackingPipeline_opt.path_logs)
                        mkdir(TrackingPipeline_opt.path_logs);
                    end
                    if trackingAlone_opt.NetworkNode == 1
                        command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat''); addpath(genpath(PANDAPath));'...
                            'pipeline=g_tracking_pipeline( NativePathCellTracking,SubjectIDArrayTracking,trackingAlone_opt,TrackingPipeline_opt,FAPathCellTracking,T1orPartitionOfSubjectsPathCellTracking );exit"'...
                            ' >"' TrackingPipeline_opt.path_logs filesep 'tracking_pipeline.loginfo" 2>&1'];
                    else
                        command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat''); addpath(genpath(PANDAPath));'...
                            'pipeline=g_tracking_pipeline( NativePathCellTracking,SubjectIDArrayTracking,trackingAlone_opt,TrackingPipeline_opt );exit"'...
                            ' >"' TrackingPipeline_opt.path_logs filesep 'tracking_pipeline.loginfo" 2>&1'];
                    end
                    TrackingPipelineShLocation = [TrackingPipeline_opt.path_logs filesep 'tracking_pipeline.sh'];
                    fid = fopen(TrackingPipelineShLocation, 'w');
                    BashString = '#!/bin/bash';
                    fprintf(fid, '%s\n%s', BashString, command);
                    fclose(fid);
%                     instr_batch = ['at -f "' TrackingPipelineShLocation '" now'];
%                     system(instr_batch);
                    [~, ShPath] = system('which sh');
                    system([ShPath(1:end-1) ' ' TrackingPipelineShLocation ' &']);
                    % Native Folder input
                    set(handles.AddNativeFolderButton, 'Enable', 'off');
                    set(handles.SubjectIDEdit, 'Enable', 'off');
                    set(handles.SubjectIDLoadButton, 'Enable', 'off');
                    % Deterministic Fiber Tracking
                    set( handles.FiberTrackingCheck, 'Enable', 'off' );
%                     set( handles.ImageOrientationMenu, 'Enable', 'off');
                    set( handles.AngleThresholdEdit, 'Enable', 'off');
                    set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
                    set( handles.StepLengthEdit, 'Enable', 'off');
                    set( handles.MaskThresMinEdit, 'Enable', 'off');
                    set( handles.MaskThresMaxEdit, 'Enable', 'off');
                    set( handles.ApplySplineFilterCheck, 'Enable', 'off');
                    set( handles.InversionMenu, 'Enable', 'off');
                    set( handles.SwapMenu, 'Enable', 'off');
                    set( handles.RandomSeedCheckbox, 'Enable', 'off');
                    set( handles.RandomSeedEdit, 'Enable', 'off');
                    % Network Node Definition
                    set( handles.NetworkNodeCheck, 'Enable', 'off');
                    set( handles.FAPathButton, 'Enable', 'off');
                    set( handles.PartitionCheck, 'Enable', 'off');
                    set( handles.T1Check, 'Enable', 'off');
                    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
                    set( handles.T1PathButton, 'Enable', 'off');
                    set( handles.PartitionTemplateEdit, 'Enable', 'off');
                    set( handles.PartitionTemplateButton, 'Enable', 'off');
                    set( handles.T1TemplateEdit, 'Enable', 'off');
                    set( handles.T1TemplateButton, 'Enable', 'off');
                    set( handles.T1BetCheckbox, 'Enable', 'off'); 
                    set( handles.T1BetFEdit, 'Enable', 'off'); 
                    set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
                    set( handles.T1CroppingGapEdit, 'Enable', 'off');
                    set( handles.T1ResampleCheckbox, 'Enable', 'off');
                    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
                    % Construct Network
                    set( handles.DeterministicNetworkCheck, 'Enable', 'off');
                    set( handles.ProbabilisticNetworkCheck, 'Enable', 'off');
                    set( handles.BedpostxAndProbabilisticCheck, 'Enable', 'off');
                    % Pipeline Options
                    set( handles.batchRadio, 'Enable', 'off');
                    set( handles.qsubRadio, 'Enable', 'off');
                    set( handles.QsubOptionsEdit, 'Enable', 'off');
                    set( handles.MaxQueuedEdit, 'Enable', 'off');
                    set( handles.LogPathEdit, 'Enable', 'off');
                    set( handles.LogPathButton, 'Enable', 'off');

                    LockExistTracking = 0;
                    LockDisappearTracking = 0;
                    % Start monitor function
                    StopFlag_InTrackingStatus = '';
                    JobStatusMonitorTimer_InTracking = timer( 'TimerFcn', {@JobStatusMonitorTracking, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
                    start(JobStatusMonitorTimer_InTracking);
                    
                    trackingAlone_opt.DeterminTrackingOptionChange = 0;
                case 'No'
                    return;
            end
        end
    end
end


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackingAlone_opt;
global T1orPartitionOfSubjectsPathCellTracking;
global NativePathCellTracking;
global SubjectIDArrayTracking;
global FAPathCellTracking;
global TrackingPipeline_opt;
global LockExistTracking;
global LockDisappearTracking;
global JobStatusMonitorTimer_InTracking;
global PANDAPath;

trackingAlone_opt.DeterminTrackingOptionChange = 0;

if strcmp(get(handles.LogPathEdit, 'Enable'), 'off')
    msgbox('Please clear first !');
else
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_Tracking','PANDA_Tracking-files (*.PANDA_Tracking)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        cmdString = ['load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        % Native Path Input
        %set( handles.SubjectFoldersListText, 'Enable', 'on');
        set( handles.SubjectIDEdit, 'Enable', 'on');
        set( handles.SubjectIDEdit, 'String', mat2str(SubjectIDArrayTracking));
        set( handles.SubjectIDLoadButton, 'Enable', 'on');
        for i = 1:length(SubjectIDArrayTracking)
            SubjectIDArrayCell{i} = num2str(SubjectIDArrayTracking(i), '%05d');
        end
        SubjectIDArrayCell = reshape(SubjectIDArrayCell, length(SubjectIDArrayCell), 1);
        SubjectFolderTable = [NativePathCellTracking SubjectIDArrayCell];
        set( handles.NativeFolderTable, 'data', SubjectFolderTable);
        ResizeSubjectFolderTable(handles);
        set( handles.AddNativeFolderButton, 'Enable', 'on');
        % Deterministic Fiber Tracking
        set( handles.FiberTrackingCheck, 'Enable', 'on');
%         set( handles.ImageOrientationText, 'Enable', 'on');
%         set( handles.ImageOrientationMenu, 'Enable', 'on');
        set( handles.AngleThresholdText, 'Enable', 'on');
        set( handles.AngleThresholdEdit, 'Enable', 'on');
        set( handles.PropagationAlgorithmText, 'Enable', 'on');
        set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
        set( handles.StepLengthText, 'Enable', 'on');
        set( handles.MaskThresholdText, 'Enable', 'on');
        set( handles.MaskThresMinEdit, 'Enable', 'on');
        set( handles.text7, 'Enable', 'on');
        set( handles.MaskThresMaxEdit, 'Enable', 'on');
        set( handles.ApplySplineFilterCheck, 'Enable', 'on');
        set( handles.OrientationPatchText, 'Enable', 'on');
        set( handles.InversionMenu, 'Enable', 'on');
        set( handles.SwapMenu, 'Enable', 'on');
        set( handles.RandomSeedCheckbox, 'Enable', 'on');
        set( handles.RandomSeedText, 'Enable', 'on');
        if trackingAlone_opt.RandomSeed_Flag
            set( handles.RandomSeedEdit, 'Enable', 'on');
        end
        if trackingAlone_opt.DterminFiberTracking     
            set( handles.FiberTrackingCheck, 'value', 1.0 );
%             if strcmp(trackingAlone_opt.ImageOrientation, 'Auto')
%                 set(handles.ImageOrientationMenu, 'value', 1.0);
%             elseif strcmp(trackingAlone_opt.ImageOrientation, 'Axial')
%                 set(handles.ImageOrientationMenu, 'value', 2.0);
%             elseif strcmp(trackingAlone_opt.ImageOrientation, 'Coronal')
%                 set(handles.ImageOrientationMenu, 'value', 3.0);    
%             elseif strcmp(trackingAlone_opt.ImageOrientation, 'Sagittal')
%                 set(handles.ImageOrientationMenu, 'value', 4.0);
%             end
            set(handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
            if strcmp(trackingAlone_opt.PropagationAlgorithm, 'FACT')
                set(handles.PropagationAlgorithmMenu, 'value', 1.0);
                set(handles.StepLengthEdit,'Enable','off');
            elseif strcmp(trackingAlone_opt.PropagationAlgorithm, '2nd-order Runge Kutta')
                set(handles.PropagationAlgorithmMenu, 'value', 2.0);
                set(handles.StepLengthEdit, 'String', num2str(trackingAlone_opt.StepLength));
            elseif strcmp(trackingAlone_opt.PropagationAlgorithm, 'Interpolated Streamline')
                set(handles.PropagationAlgorithmMenu, 'value', 3.0);   
                set(handles.StepLengthEdit, 'String', num2str(trackingAlone_opt.StepLength));
            elseif strcmp(trackingAlone_opt.PropagationAlgorithm, 'Tensorline')
                set(handles.PropagationAlgorithmMenu, 'value', 4.0);
                set(handles.StepLengthEdit, 'String', num2str(trackingAlone_opt.StepLength));
            end
            set(handles.MaskThresMinEdit, 'String', num2str(trackingAlone_opt.MaskThresMin));
            set(handles.MaskThresMaxEdit, 'String', num2str(trackingAlone_opt.MaskThresMax));
            if strcmp(trackingAlone_opt.ApplySplineFilter, 'Yes')
                set(handles.ApplySplineFilterCheck, 'value', 1.0);
            else
                set(handles.ApplySplineFilterCheck, 'value', 0.0);
            end
            if strcmp(trackingAlone_opt.Inversion, 'No Inversion')
                set(handles.InversionMenu, 'value', 1.0);
            elseif strcmp(trackingAlone_opt.Inversion, 'Invert X')
                set(handles.InversionMenu, 'value', 2.0);
            elseif strcmp(trackingAlone_opt.Inversion, 'Invert Y')
                set(handles.InversionMenu, 'value', 3.0);    
            elseif strcmp(trackingAlone_opt.Inversion, 'Invert Z')
                set(handles.InversionMenu, 'value', 4.0);
            end
            if strcmp(trackingAlone_opt.Swap, 'No Swap')
                set(handles.SwapMenu, 'value', 1.0);
            elseif strcmp(trackingAlone_opt.Swap, 'Swap X/Y')
                set(handles.SwapMenu, 'value', 2.0);
            elseif strcmp(trackingAlone_opt.Swap, 'Swap Y/Z')
                set(handles.SwapMenu, 'value', 3.0);    
            elseif strcmp(trackingAlone_opt.Swap, 'Swap Z/X')
                set(handles.SwapMenu, 'value', 4.0);
            end
            if trackingAlone_opt.RandomSeed_Flag
                set(handles.RandomSeedCheckbox, 'Value', 1);
                set(handles.RandomSeedEdit, 'String', num2str(trackingAlone_opt.RandomSeed));
            else
                set(handles.RandomSeedCheckbox, 'Value', 0);
            end
        else
            set( handles.FiberTrackingCheck, 'value', 0.0 );
%             set( handles.ImageOrientationText, 'Enable', 'off');
%             set( handles.ImageOrientationMenu, 'Enable', 'off');
            set( handles.AngleThresholdText, 'Enable', 'off');
            set( handles.AngleThresholdEdit, 'String', '45');
            set( handles.AngleThresholdEdit, 'Enable', 'off');
            set( handles.PropagationAlgorithmText, 'Enable', 'off');
            set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
            set( handles.StepLengthText, 'Enable', 'off');
            set( handles.StepLengthEdit, 'Enable', 'off');
            set( handles.MaskThresholdText, 'Enable', 'off');
            set( handles.MaskThresMinEdit, 'String', '0.2');
            set( handles.MaskThresMinEdit, 'Enable', 'off');
            set( handles.text7, 'Enable', 'off');
            set( handles.MaskThresMaxEdit, 'String', '1');
            set( handles.MaskThresMaxEdit, 'Enable', 'off');
            set( handles.ApplySplineFilterCheck, 'Enable', 'off');
            set( handles.OrientationPatchText, 'Enable', 'off');
            set( handles.InversionMenu, 'Enable', 'off');
            set( handles.SwapMenu, 'Enable', 'off');
            set( handles.RandomSeedCheckbox, 'Enable', 'off');
            set( handles.RandomSeedText, 'Enable', 'off');
            set( handles.RandomSeedEdit, 'Enable', 'off');
        end
        % Network Node Definition
        set( handles.NetworkNodeCheck, 'Enable', 'on');
        if trackingAlone_opt.NetworkNode
            set( handles.NetworkNodeCheck, 'value', 1.0);
            set( handles.FAPathButton, 'Enable', 'on' );
            set( handles.PartitionCheck, 'Enable', 'on' );
            set( handles.T1Check, 'Enable', 'on' );
            set( handles.LocationTableText, 'Enable', 'on' );
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on');    
            ColumnName{1} = 'Path of FA';
            if trackingAlone_opt.PartitionOfSubjects
                ColumnName{2} = 'Path of parcellated images';
                set( handles.PartitionCheck, 'Value', 1.0 );
                set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
                set( handles.T1PathButton, 'Enable', 'off');
                set( handles.T1Check, 'Value', 0.0 );
                set( handles.PartitionTemplateEdit, 'String', '' );
                set( handles.PartitionTemplateEdit, 'Enable', 'off' );
                set( handles.PartitionTemplateButton, 'Enable', 'off' );
                set( handles.PartitionTemplateText, 'Enable', 'off' );
                set( handles.T1TemplateEdit, 'String', '' );
                set( handles.T1TemplateEdit, 'Enable', 'off' );
                set( handles.T1TemplateButton, 'Enable', 'off' );
                set( handles.T1TemplateText, 'Enable', 'off' );
                set( handles.T1BetCheckbox, 'Enable', 'off');  
                set( handles.BetFText, 'Enable', 'off'); 
                set( handles.T1BetFEdit, 'String', '');
                set( handles.T1BetFEdit, 'Enable', 'off'); 
                set( handles.T1CroppingGapCheckbox, 'Enable', 'off');  
                set( handles.T1CroppingGapText, 'Enable', 'off'); 
                set( handles.T1CroppingGapEdit, 'String', '');
                set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%                 set( handles.T1CroppingGapUnitText, 'Enable', 'off'); 
                set( handles.T1ResampleCheckbox, 'Enable', 'off');
                set( handles.T1ResampleResolutionText, 'Enable', 'off');
                set( handles.T1ResampleResolutionEdit, 'String', '');
                set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            else
                ColumnName{2} = 'Path of T1';
                set( handles.T1Check, 'Value', 1.0 );
                set( handles.PartitionCheck, 'Value', 0.0 );
                set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
                set( handles.T1PathButton, 'Enable', 'on');
                set( handles.PartitionTemplateText, 'Enable', 'on');
                set( handles.PartitionTemplateEdit, 'Enable', 'on');
                set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
                set( handles.PartitionTemplateButton, 'Enable', 'on');
                set( handles.T1TemplateText, 'Enable', 'on');
                set( handles.T1TemplateEdit, 'Enable', 'on');
                set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template);
                set( handles.T1TemplateButton, 'Enable', 'on');
                set( handles.T1BetCheckbox, 'Enable', 'on'); 
                set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
                set( handles.BetFText, 'Enable', 'on');
                set( handles.T1BetFEdit, 'Enable', 'on'); 
                set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF)); 
                set( handles.T1CroppingGapCheckbox, 'Enable', 'on'); 
                set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
                if trackingAlone_opt.T1Cropping_Flag
                    set( handles.T1CroppingGapText, 'Enable', 'on'); 
                    set( handles.T1CroppingGapEdit, 'Enable', 'on'); 
                    set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
                end
%                 set( handles.T1CroppingGapUnitText, 'Enable', 'on'); 
                set( handles.T1ResampleCheckbox, 'Enable', 'on'); 
                set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
                if trackingAlone_opt.T1Resample_Flag
                    set( handles.T1ResampleResolutionText, 'Enable', 'on'); 
                    set( handles.T1ResampleResolutionEdit, 'Enable', 'on'); 
                    set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
                end
            end
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
            if ~isempty(FAPathCellTracking)
                if ~isempty(T1orPartitionOfSubjectsPathCellTracking) && length(FAPathCellTracking) == length(T1orPartitionOfSubjectsPathCellTracking)
                    FAPath_T1orPartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                else
                    FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
                end
                set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );   
                ResizeFAT1orParcellatedTable(handles);
            end
        else
            set( handles.NetworkNodeCheck, 'value', 0.0);
            set( handles.FAPathButton, 'Enable', 'off' );
            set( handles.PartitionCheck, 'Enable', 'off');
            set( handles.T1Check, 'Enable', 'off');
            DataCell = cell(4,1);
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
            ResizeFAT1orParcellatedTable(handles);
            set( handles.LocationTableText, 'Enable', 'off' );
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off');
            set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off'); 
            set( handles.PartitionTemplateEdit, 'String', '');
            set( handles.PartitionTemplateEdit, 'Enable', 'off'); 
            set( handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.T1TemplateText, 'Enable', 'off'); 
            set( handles.T1TemplateEdit, 'String', '');
            set( handles.T1TemplateEdit, 'Enable', 'off'); 
            set( handles.T1TemplateButton, 'Enable', 'off');
            set( handles.T1BetCheckbox, 'Enable', 'off'); 
            set( handles.BetFText, 'Enable', 'off');
            set( handles.T1BetFEdit, 'String', '');
            set( handles.T1BetFEdit, 'Enable', 'off'); 
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
            set( handles.T1CroppingGapText, 'Enable', 'off'); 
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionText, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
        end
        % Network Type
        if trackingAlone_opt.DeterministicNetwork
            set(handles.DeterministicNetworkCheck, 'value', 1.0);
        else
            set(handles.DeterministicNetworkCheck, 'value', 0.0);
        end
        if trackingAlone_opt.ProbabilisticNetwork 
            set(handles.ProbabilisticNetworkCheck, 'value', 1.0);
        else
            set(handles.ProbabilisticNetworkCheck, 'value', 0.0);
        end
        if trackingAlone_opt.BedpostxProbabilisticNetwork 
            set(handles.BedpostxAndProbabilisticCheck, 'value', 1.0);
        else
            set(handles.BedpostxAndProbabilisticCheck, 'value', 0.0);
        end
        % Pipeline Options
        if strcmp(TrackingPipeline_opt.mode,'background')
            set( handles.batchRadio, 'Value', 1);
        else
            set( handles.qsubRadio, 'Value', 1);
            set( handles.QsubOptionsEdit, 'Enable', 'on');
            set( handles.QsubOptionsEdit, 'String', TrackingPipeline_opt.qsub_options);
        end
        set(handles.MaxQueuedEdit, 'string', num2str(TrackingPipeline_opt.max_queued));
        [LogParentFolder, y, z] = fileparts(TrackingPipeline_opt.path_logs);
        set( handles.LogPathEdit, 'String', LogParentFolder);

        % If the jobs are running, all the edit boxes and button should be
        % unavailable
        LockFilePath = [TrackingPipeline_opt.path_logs filesep 'PIPE.lock'];
        if exist( LockFilePath, 'file' )
            Info{1} = 'Now, the jobs are running !';
            Info{2} = 'Please click the status button to check the status of the jobs !';
            msgbox(Info);
            % set native folder input unavailable
            set( handles.AddNativeFolderButton, 'Enable', 'off' );
            set( handles.SubjectIDEdit, 'Enable', 'off' );
            set( handles.SubjectIDLoadButton, 'Enable', 'off' );
            % set deterministic fiber tracking input unavailable
            set( handles.FiberTrackingCheck, 'Enable', 'off' );
%             set( handles.ImageOrientationMenu, 'Enable', 'off' );
            set( handles.AngleThresholdEdit, 'Enable', 'off' );
            set( handles.PropagationAlgorithmMenu, 'Enable', 'off' );
            set( handles.StepLengthEdit, 'Enable', 'off' );
            set( handles.MaskThresMinEdit, 'Enable', 'off' );
            set( handles.MaskThresMaxEdit, 'Enable', 'off' );
            set( handles.InversionMenu, 'Enable', 'off' );
            set( handles.SwapMenu, 'Enable', 'off' );
            set( handles.ApplySplineFilterCheck, 'Enable', 'off' );
            set( handles.RandomSeedCheckbox, 'Enable', 'off' );
            set( handles.RandomSeedEdit, 'Enable', 'off' );
            % set network node definition unavailable
            set( handles.NetworkNodeCheck, 'Enable', 'off' );
            set( handles.FAPathButton, 'Enable', 'off' );
            set( handles.PartitionCheck, 'Enable', 'off' );
            set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
            set( handles.T1Check, 'Enable', 'off' );
            set( handles.T1PathButton, 'Enable', 'off' );    
            set( handles.PartitionTemplateEdit, 'Enable', 'off' );
            set( handles.PartitionTemplateButton, 'Enable', 'off' );
            set( handles.T1TemplateEdit, 'Enable', 'off' );
            set( handles.T1TemplateButton, 'Enable', 'off' );
            set( handles.T1BetCheckbox, 'Enable', 'off'); 
            set( handles.T1BetFEdit, 'Enable', 'off'); 
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
            set( handles.T1CroppingGapEdit, 'Enable', 'off');
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            % set network construction options unavailable
            set(handles.DeterministicNetworkCheck, 'Enable', 'off');
            set(handles.ProbabilisticNetworkCheck, 'Enable', 'off');
            set(handles.BedpostxAndProbabilisticCheck, 'Enable', 'off');
            % set pipeline options unavailable
            set( handles.batchRadio, 'Enable', 'off' );
            set( handles.qsubRadio, 'Enable', 'off' );
            set( handles.QsubOptionsEdit, 'Enable', 'off' );
            set( handles.MaxQueuedEdit, 'Enable', 'off' );
            set( handles.LogPathEdit, 'Enable', 'off' );
            set( handles.LogPathButton, 'Enable', 'off' );

            LockExistTracking = 1;
            LockDisappearTracking = 0;
            % Start monitor function
            JobStatusMonitorTimer_InTracking = timer( 'TimerFcn', {@JobStatusMonitorTracking, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimer_InTracking);
        end
    end
end
    

% --- Executes when user attempts to close PANDATrackingFigure.
function PANDATrackingFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDATrackingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global TrackingPipeline_opt;
global NativePathCellTracking;
global JobStatusMonitorTimer_InTracking;
% global FiberTrackNativePathCellBefore;
% global ProbNativePathCellBefore;
% global BedAndProbNativePathCellBefore;

button = questdlg('Are you sure to quit ?','Sure to Quit ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop the monitor
        if ~isempty(JobStatusMonitorTimer_InTracking)
            stop(JobStatusMonitorTimer_InTracking);
            clear global JobStatusMonitorTimer_InTracking;
        end
        clear global FAPathCellTracking;
        clear global T1orPartitionOfSubjectsPathCellTracking;
        clear global TrackingPipeline_opt;
        clear global NativePathCellTracking;
        clear global trackingAlone_opt;
%         clear global FiberTrackNativePathCellBefore;
%         clear global ProbNativePathCellBefore;
%         clear global BedAndProbNativePathCellBefore;
        % Clear the paths in Select GUI
        delete(hObject);
    case 'No'
        return;
end


% --- Executes during object creation, after setting all properties.
function PANDATrackingFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PANDATrackingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in PartitionCheck.
function PartitionCheck_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value')global FAPathCellTracking;
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global trackingAlone_opt;
global PANDAPath;

if get( hObject, 'value' )
    trackingAlone_opt.PartitionOfSubjects = 1;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
    set( handles.T1Check, 'value', 0.0);
    trackingAlone_opt.T1 = 0;
    set( handles.T1PathButton, 'Enable', 'off');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of parcellated images';
    set( handles.PartitionTemplateEdit, 'String', '');
    set( handles.PartitionTemplateEdit, 'Enable', 'off');
    set( handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off');
    set( handles.T1TemplateEdit, 'String', '');
    set( handles.T1TemplateEdit, 'Enable', 'off');
    set( handles.T1TemplateButton, 'Enable', 'off');
    set( handles.T1TemplateText, 'Enable', 'off');
    set( handles.T1BetCheckbox, 'Value', 0);
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.BetFText, 'Enable', 'off');
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off');
    set( handles.T1CroppingGapCheckbox, 'Value', 0);
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
    set( handles.T1CroppingGapText, 'Enable', 'off');
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
%     set( handles.T1CroppingGapUnitText, 'Enable', 'off');
    set( handles.T1ResampleCheckbox, 'Value', 0);
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionText, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
    clear global T1orPartitionOfSubjectsPathCellTracking;
else
    trackingAlone_opt.PartitionOfSubjects = 0;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    set( handles.T1Check, 'value', 1.0);
    trackingAlone_opt.T1 = 1;
    set( handles.T1PathButton, 'Enable', 'on');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of T1';
    set( handles.PartitionTemplateEdit, 'Enable', 'on');
    set( handles.PartitionTemplateButton, 'Enable', 'on');
    set( handles.PartitionTemplateText, 'Enable', 'on');
    set( handles.T1TemplateEdit, 'Enable', 'on');
    set( handles.T1TemplateButton, 'Enable', 'on');
    set( handles.T1TemplateText, 'Enable', 'on');
    trackingAlone_opt.T1Bet_Flag = 1;
    set( handles.T1BetCheckbox, 'Enable', 'on');
    set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
    set( handles.BetFText, 'Enable', 'on');
    trackingAlone_opt.T1BetF = 0.5;
    set( handles.T1BetFEdit, 'Enable', 'on');
    set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF));
    trackingAlone_opt.T1Cropping_Flag = 1;
    set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
    set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
    set( handles.T1CroppingGapText, 'Enable', 'on');
    trackingAlone_opt.T1CroppingGap = 3;
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
%     set( handles.T1CroppingGapUnitText, 'Enable', 'on');
    trackingAlone_opt.T1Resample_Flag = 1;
    set( handles.T1ResampleCheckbox, 'Enable', 'on');
    set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
    set( handles.T1ResampleResolutionText, 'Enable', 'on');
    trackingAlone_opt.T1ResampleResolution = [1 1 1];
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    trackingAlone_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
    set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
    trackingAlone_opt.T1Template = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain'];
    set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template);
    FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
    clear global T1orPartitionOfSubjectsPathCellTracking;
end


% --- Executes on button press in T1Check.
function T1Check_Callback(hObject, eventdata, handles)
% hObject    handle to T1Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1Check
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global trackingAlone_opt;
global PANDAPath;

if get( hObject, 'value' )
    trackingAlone_opt.T1 = 1;
    set( handles.T1PathButton, 'Enable', 'on');
    set( handles.PartitionCheck, 'value', 0.0);
    trackingAlone_opt.PartitionOfSubjects = 0;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of T1';
    set( handles.PartitionTemplateEdit, 'Enable', 'on');
    set( handles.PartitionTemplateButton, 'Enable', 'on');
    set( handles.PartitionTemplateText, 'Enable', 'on');
    set( handles.T1TemplateEdit, 'Enable', 'on');
    set( handles.T1TemplateButton, 'Enable', 'on');
    set( handles.T1TemplateText, 'Enable', 'on');
    trackingAlone_opt.T1Bet_Flag = 1;
    set( handles.T1BetCheckbox, 'Enable', 'on');
    set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
    trackingAlone_opt.T1BetF = 0.5;
    set( handles.BetFText, 'Enable', 'on');
    set( handles.T1BetFEdit, 'Enable', 'on');
    set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF));
    trackingAlone_opt.T1Cropping_Flag = 1;
    set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
    set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
    trackingAlone_opt.T1CroppingGap = 3;
    set( handles.T1CroppingGapText, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
%     set( handles.T1CroppingGapUnitText, 'Enable', 'on');
    trackingAlone_opt.T1Resample_Flag = 1;
    set( handles.T1ResampleCheckbox, 'Enable', 'on');
    set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
    set( handles.T1ResampleResolutionText, 'Enable', 'on');
    trackingAlone_opt.T1ResampleResolution = [1 1 1];
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    trackingAlone_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
    set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
    trackingAlone_opt.T1Template = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain'];
    set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template);
    FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
    clear global T1orPartitionOfSubjectsPathCellTracking;
else
    trackingAlone_opt.T1 = 0;
    set( handles.T1PathButton, 'Enable', 'off');
    set( handles.PartitionCheck, 'value', 1.0);
    trackingAlone_opt.PartitionOfSubjects = 1;
    set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of parcellated images';
    set( handles.PartitionTemplateEdit, 'String', '');
    set( handles.PartitionTemplateEdit, 'Enable', 'off');
    set( handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off');
    set( handles.T1TemplateEdit, 'String', '');
    set( handles.T1TemplateEdit, 'Enable', 'off');
    set( handles.T1TemplateButton, 'Enable', 'off');
    set( handles.T1TemplateText, 'Enable', 'off');
    set( handles.T1BetCheckbox, 'Value', 0);
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.BetFText, 'Enable', 'off');
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off');
    set( handles.T1CroppingGapCheckbox, 'Value', 0);
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
    set( handles.T1CroppingGapText, 'Enable', 'off');
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
%     set( handles.T1CroppingGapUnitText, 'Enable', 'off');
    set( handles.T1ResampleCheckbox, 'Value', 0)
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionText, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
    clear global T1orPartitionOfSubjectsPathCellTracking;
end


% --- Executes on button press in FiberTrackingCheck.
function FiberTrackingCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FiberTrackingCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FiberTrackingCheck
global trackingAlone_opt;
global NativePathCellTracking;
global SubjectIDArrayTracking;
global TrackingPipeline_opt;
% global FiberTrackNativePathCellBefore;
if get(hObject, 'Value')
    if isempty(NativePathCellTracking)
        info{1} = 'Are you sure to do deterministic fiber tracking ?';
        info{2} = 'If you are sure, please add the native folder consisting of data, bvals, bvecs and nodif_brain_mask first!';
        button = questdlg( info ,'Sure to Run ?','Yes','No','Yes' );
        if strcmp(button, 'Yes')
            DeterminFiberTrackingPathAutoOpen( handles );
            if isempty(NativePathCellTracking)
                set(hObject, 'Value', 0);
%             else
%                 FiberTrackNativePathCellBefore = NativePathCellTracking;
            end
        else
            set(hObject, 'Value', 0);
        end
    else
        % Native folder input
        if isempty(SubjectIDArrayTracking)
            set( handles.NativeFolderTable, 'data', NativePathCellTracking);
            ResizeSubjectFolderTable(handles);
        else
            for i = 1:length(SubjectIDArrayTracking)
                SubjectIDArrayCell{i} = num2str(SubjectIDArrayTracking(i), '%05d');
            end
            SubjectIDArrayCell = reshape(SubjectIDArrayCell, length(SubjectIDArrayCell), 1);
            SubjectFolderTable = [NativePathCellTracking SubjectIDArrayCell];
            set(handles.NativeFolderTable, 'data', SubjectFolderTable);
            ResizeSubjectFolderTable(handles);
        end
        % Deterministic fiber tracking
        trackingAlone_opt.DterminFiberTracking = 1;
        set( handles.FiberTrackingCheck, 'value', 1.0 );
%         set( handles.ImageOrientationText, 'Enable', 'on');
%         set( handles.ImageOrientationMenu, 'Enable', 'on');
        trackingAlone_opt.ImageOrientation = 'Auto';
%         set( handles.ImageOrientationMenu, 'value', 1.0);
        set( handles.AngleThresholdText, 'Enable', 'on');
        set( handles.AngleThresholdEdit, 'Enable', 'on');
        trackingAlone_opt.AngleThreshold = '45';
        set( handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
        set( handles.PropagationAlgorithmText, 'Enable', 'on');
        set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
        trackingAlone_opt.PropagationAlgorithm = 'FACT';
        set( handles.PropagationAlgorithmMenu, 'value', 1.0);
        set( handles.StepLengthEdit, 'Enable', 'off');
        set( handles.StepLengthText, 'Enable', 'on');
        set( handles.StepLengthEdit, 'Enable', 'off');
        set( handles.MaskThresholdText, 'Enable', 'on');
        set( handles.MaskThresMinEdit, 'Enable', 'on');
        trackingAlone_opt.MaskThresMin = 0.2;
        set( handles.MaskThresMinEdit, 'String', num2str(trackingAlone_opt.MaskThresMin));
        set( handles.text7, 'Enable', 'on');
        set( handles.MaskThresMaxEdit, 'Enable', 'on');
        trackingAlone_opt.MaskThresMax = 1;
        set( handles.MaskThresMaxEdit, 'String', num2str(trackingAlone_opt.MaskThresMax));
        set( handles.ApplySplineFilterCheck, 'Enable', 'on');
        set( handles.ApplySplineFilterCheck, 'Value', 1.0);
        trackingAlone_opt.ApplySplineFilter = 'Yes';
        set( handles.OrientationPatchText, 'Enable', 'on');
        set( handles.InversionMenu, 'Enable', 'on');
        trackingAlone_opt.Inversion = 'Invert Z';
        set( handles.InversionMenu, 'value', 4.0);
        set( handles.SwapMenu, 'Enable', 'on');
        trackingAlone_opt.Swap = 'No Swap';
        set( handles.SwapMenu, 'value', 1.0);
        trackingAlone_opt.RandomSeed_Flag = 0;
        set( handles.RandomSeedCheckbox, 'Value', 0);
        set( handles.RandomSeedCheckbox, 'Enable', 'on');
        set( handles.RandomSeedText, 'Enable', 'on');
        set( handles.RandomSeedEdit, 'String', '');
        set( handles.RandomSeedEdit, 'Enable', 'off');
    end
else
    trackingAlone_opt.DterminFiberTracking = 0;
    set( handles.FiberTrackingCheck, 'value', 0.0 );
%     set( handles.ImageOrientationText, 'Enable', 'off');
%     set( handles.ImageOrientationMenu, 'Enable', 'off');
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
    set( handles.RandomSeedCheckbox, 'Value', 0);
    set( handles.RandomSeedCheckbox, 'Enable', 'off');
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
end


% --- Executes on button press in AddNativeFolderButton.
function AddNativeFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddNativeFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TrackingPipeline_opt;
global NativePathCellTracking;
% global FiberTrackNativePathCellBefore;
NativePathCell_Button = get(hObject, 'UserData');
[a, NativePathCellTracking, Done] = PANDA_Select('dir', NativePathCell_Button);
if Done == 1
    set(hObject, 'UserData', NativePathCellTracking);
    % FiberTrackNativePathCellBefore = NativePathCellTracking;
    if ~isempty(NativePathCellTracking)
        set(handles.NativeFolderTable, 'data', NativePathCellTracking);
        set(handles.SubjectIDEdit, 'String', '');
        ResizeSubjectFolderTable(handles);
    end
end

% --- Executes on button press in DeterministicNetworkCheck.
function DeterministicNetworkCheck_Callback(hObject, eventdata, handles)
% hObject    handle to DeterministicNetworkCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DeterministicNetworkCheck
global T1orPartitionOfSubjectsPathCellTracking;
global trackingAlone_opt;
global NativePathCellTracking;
global FAPathCellTracking;
global PANDAPath;

if get(hObject,'Value')
    trackingAlone_opt.ProbabilisticNetwork = 0;
    set(handles.ProbabilisticNetworkCheck, 'Value', 0.0);
    trackingAlone_opt.BedpostxProbabilisticNetwork = 0;
    set(handles.BedpostxAndProbabilisticCheck, 'Value', 0.0);
    set(handles.FiberTrackingCheck, 'Enable', 'on');
    set(handles.NetworkNodeCheck, 'Enable', 'on');

    if ~trackingAlone_opt.DterminFiberTracking && isempty(NativePathCellTracking)
        NativeInfo{1} = 'Are you sure to do deterministic network construction ?';
        NativeInfo{2} = 'If you are sure, you should do deterministic tracking first !';
        NativeInfo{3} = 'So, please add the native folder consisting of data, bvals, bvecs and nodif_brain_mask first!';
        NativeButton = questdlg( NativeInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(NativeButton, 'Yes')
            DeterminFiberTrackingPathAutoOpen( handles );
            if isempty(NativePathCellTracking)
                set(hObject, 'Value', 0);
            end
        else
            set(hObject, 'Value', 0);
        end
    elseif ~isempty(NativePathCellTracking)
        DeterminFiberTrackingPathAutoOpen( handles );
    end
    if trackingAlone_opt.DterminFiberTracking && ~trackingAlone_opt.NetworkNode
        NetworkNodeInfo{1} = 'Then you should do network node definition !';
        NetworkNodeInfo{2} = 'Please select FA path for network node definition !';
        NetworkNodeButton = questdlg( NetworkNodeInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(NetworkNodeButton, 'Yes')
            NetworkNodePathAutoOpen( handles );
        else
            set(hObject, 'Value', 0);
        end
    elseif ~isempty(FAPathCellTracking)
        trackingAlone_opt.NetworkNode = 1;
    end
    if ~isempty(NativePathCellTracking) && trackingAlone_opt.NetworkNode ...
            && ~isempty(FAPathCellTracking) && isempty(T1orPartitionOfSubjectsPathCellTracking)
        PartitionOrT1Info{1} = 'Do you have parcellated images (native space) of subjects?';
        PartitionOrT1Info{2} = 'If you have, please select Parcellated Check and input parcellated images (native space);';
        PartitionOrT1Info{3} = 'Otherwise, please select T1 Check and input T1 images for subjects, PANDA will create parcellated images for each subject.';
        PartitionOrT1Button = questdlg( PartitionOrT1Info ,'Sure ?','Yes','No','Yes' );
        if strcmp(PartitionOrT1Button,'Yes')
            trackingAlone_opt.PartitionOfSubjects = 1;
            trackingAlone_opt.T1 = 0;
            set( handles.PartitionCheck, 'Value', 1 );
            set( handles.T1Check, 'Value', 0 );
            set( handles.PartitionTemplateEdit, 'String', '');
            set( handles.PartitionTemplateEdit, 'Enable', 'off');
            set( handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off');
            set( handles.T1TemplateEdit, 'String', '');
            set( handles.T1TemplateEdit, 'Enable', 'off');
            set( handles.T1TemplateButton, 'Enable', 'off');
            set( handles.T1TemplateText, 'Enable', 'off');
            set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
            set( handles.T1PathButton, 'Enable', 'off');
            set( handles.T1BetCheckbox, 'Enable', 'off'); 
            set( handles.BetFText, 'Enable', 'off');
            set( handles.T1BetFEdit, 'String', '');
            set( handles.T1BetFEdit, 'Enable', 'off'); 
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
            set( handles.T1CroppingGapText, 'Enable', 'off'); 
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionText, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            if trackingAlone_opt.DterminFiberTracking && trackingAlone_opt.NetworkNode ...
                    && isempty(T1orPartitionOfSubjectsPathCellTracking)
                PartitionInfo{1} = 'Then, you should select parcellated images (native space) of subject according to FA path in the table';
                PartitionInfo{2} = 'Are you sure?';
                PartitionButton = questdlg( PartitionInfo ,'Sure ?','Yes','No','Yes' );
                if strcmp(PartitionButton, 'Yes')
                    [x,T1orPartitionOfSubjectsPathCellTracking] = PANDA_Select('img');
                    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
                        T1orPartitionOfSubjectsPathCellTracking = '';
                        msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
                    else
                        FAPath_PartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_PartitionOfSubjectsPath );
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
            set( handles.PartitionCheck, 'Value', 0 );
            set( handles.PartitionTemplateEdit, 'Enable', 'on');
            set( handles.PartitionTemplateButton, 'Enable', 'on');
            set( handles.PartitionTemplateText, 'Enable', 'on');
            set( handles.T1TemplateEdit, 'Enable', 'on');
            set( handles.T1TemplateButton, 'Enable', 'on');
            set( handles.T1TemplateText, 'Enable', 'on');
            set( handles.T1PathButton, 'Enable', 'on');
            set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
            trackingAlone_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
            set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
            trackingAlone_opt.T1Template = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain'];
            set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template); 
            trackingAlone_opt.T1Bet_Flag = 1;
            set( handles.T1BetCheckbox, 'Enable', 'on'); 
            set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
            set( handles.BetFText, 'Enable', 'on'); 
            trackingAlone_opt.T1BetF = 0.5;
            set( handles.T1BetFEdit, 'Enable', 'on'); 
            set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF)); 
            trackingAlone_opt.T1Cropping_Flag = 1;
            set( handles.T1CroppingGapCheckbox, 'Enable', 'on'); 
            set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
            trackingAlone_opt.T1CroppingGap = 3;
            set( handles.T1CroppingGapText, 'Enable', 'on');
            set( handles.T1CroppingGapEdit, 'Enable', 'on');
            set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
            trackingAlone_opt.T1Resample_Flag = 1;
            set( handles.T1ResampleCheckbox, 'Enable', 'on');
            set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
            set( handles.T1ResampleResolutionText, 'Enable', 'on');
            trackingAlone_opt.T1ResampleResolution = [1 1 1];
            set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
            set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
            if trackingAlone_opt.DterminFiberTracking && trackingAlone_opt.NetworkNode ...
                    && isempty(T1orPartitionOfSubjectsPathCellTracking)
                T1Info{1} = 'Then, you should select T1 for each subject according to FA path in the table';
                T1Info{2} = 'Are you sure?';
                button = questdlg( T1Info ,'Sure ?','Yes','No','Yes' );
                if strcmp(button, 'Yes')
                    [x, T1orPartitionOfSubjectsPathCellTracking] = PANDA_Select('img');
                    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
                        T1orPartitionOfSubjectsPathCellTracking = '';
                        msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
                    else
                        FAPath_T1Path = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1Path );
                        ResizeFAT1orParcellatedTable(handles);
                    end
                else
                    set(hObject, 'Value', 0);
                end
            end
        else
            set(hObject, 'Value', 0);
        end
    end
    
    if trackingAlone_opt.DterminFiberTracking && trackingAlone_opt.NetworkNode ...
            && ~isempty(T1orPartitionOfSubjectsPathCellTracking)
        trackingAlone_opt.DeterministicNetwork = 1;
    end
else
    trackingAlone_opt.DeterministicNetwork = 0;
    % Set native path empty
%     NativePathCellTracking = '';
%     set(handles.NativeFolderListbox, 'Value', 1);
%     set(handles.NativeFolderListbox, 'String', NativePathCellTracking)
    % Set deterministic fiber tracking unselected
%     trackingAlone_opt.DterminFiberTracking = 0;
%     set( handles.FiberTrackingCheck, 'value', 0.0 );
%     set( handles.ImageOrientationText, 'Enable', 'off');
%     set( handles.ImageOrientationMenu, 'Enable', 'off');
%     set( handles.AngleThresholdText, 'Enable', 'off');
%     set( handles.AngleThresholdEdit, 'String', '' );
%     set( handles.AngleThresholdEdit, 'Enable', 'off');
%     set( handles.PropagationAlgorithmText, 'Enable', 'off');
%     set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
%     set( handles.StepLengthText, 'Enable', 'off');
%     set( handles.StepLengthEdit, 'String', '');
%     set( handles.StepLengthEdit, 'Enable', 'off');
%     set( handles.MaskThresholdText, 'Enable', 'off');
%     set(handles.MaskThresMinEdit, 'String', '');
%     set( handles.MaskThresMinEdit, 'Enable', 'off');
%     set( handles.text7, 'Enable', 'off');
%     set(handles.MaskThresMaxEdit, 'String', '');
%     set( handles.MaskThresMaxEdit, 'Enable', 'off');
%     set( handles.ApplySplineFilterCheck, 'Value', 0.0);
%     set( handles.ApplySplineFilterCheck, 'Enable', 'off');
%     set( handles.OrientationPatchText, 'Enable', 'off');
%     set( handles.InversionMenu, 'Enable', 'off');
%     set( handles.SwapMenu, 'Enable', 'off');
end


% --- Executes on button press in ProbabilisticNetworkCheck.
function ProbabilisticNetworkCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ProbabilisticNetworkCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ProbabilisticNetworkCheck
global trackingAlone_opt;
global NativePathCellTracking;
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global PANDAPath;
% global ProbNativePathCellBefore;
if get(hObject,'Value')
    trackingAlone_opt.DeterministicNetwork = 0;
    set( handles.DeterministicNetworkCheck, 'Value', 0);
    trackingAlone_opt.BedpostxProbabilisticNetwork = 0;
    set( handles.BedpostxAndProbabilisticCheck, 'Value', 0);
    % Make Fiber Tracking unavaliable
    trackingAlone_opt.DterminFiberTracking = 0;
    set( handles.FiberTrackingCheck, 'Value', 0);
    set( handles.FiberTrackingCheck, 'Enable', 'off');
%     set( handles.ImageOrientationText, 'Enable', 'off');
    trackingAlone_opt.ImageOrientation = 'Auto';
%     set( handles.ImageOrientationMenu, 'value', 1.0);
%     set( handles.ImageOrientationMenu, 'Enable', 'off');
    set( handles.AngleThresholdText, 'Enable', 'off');
    trackingAlone_opt.AngleThreshold = '45';
    set( handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
    set( handles.AngleThresholdEdit, 'Enable', 'off');
    set( handles.PropagationAlgorithmText, 'Enable', 'off');
    trackingAlone_opt.PropagationAlgorithm = 'FACT';
    set( handles.PropagationAlgorithmMenu, 'value', 1.0);    
    set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
    set( handles.StepLengthText, 'Enable', 'off');
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.MaskThresholdText, 'Enable', 'off');
    trackingAlone_opt.MaskThresMin = 0.2;
    set( handles.MaskThresMinEdit, 'String', '0.2');    
    set( handles.MaskThresMinEdit, 'Enable', 'off');
    set( handles.text7, 'Enable', 'off');
    trackingAlone_opt.MaskThresMax = 1;
    set( handles.MaskThresMaxEdit, 'String', '1');
    set( handles.MaskThresMaxEdit, 'Enable', 'off');
    trackingAlone_opt.ApplySplineFilter = 'No';
    set( handles.ApplySplineFilterCheck, 'Value', 0);
    set( handles.ApplySplineFilterCheck, 'Enable', 'off');
    set( handles.OrientationPatchText, 'Enable', 'off');
    trackingAlone_opt.Inversion = 'Invert Z';
    set( handles.InversionMenu, 'value', 4.0);
    set( handles.InversionMenu, 'Enable', 'off');
    trackingAlone_opt.Swap = 'No Swap';
    set(handles.SwapMenu, 'value', 1.0);
    set( handles.SwapMenu, 'Enable', 'off');
    trackingAlone_opt.RandomSeed_Flag = 0;
    set( handles.RandomSeedCheckbox, 'Value', 0);
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
    
%     NativePathCellTracking = ProbNativePathCellBefore;
%     if ~isempty(ProbNativePathCellBefore)
%         set( handles.NativeFolderListbox, 'String', ProbNativePathCellBefore);
%     end
    if isempty(NativePathCellTracking)
        SubjectFolders = cell(4, 2);
        set( handles.NativeFolderTable, 'data', SubjectFolders);
        ResizeSubjectFolderTable(handles);
        set( handles.FiberTrackingCheck, 'value', 0.0 );
        BedpostxInfo{1} = 'Are you sure to do probabilistic network construction ?';
        BedpostxInfo{2} = 'If you are sure, please add the result folder of bedpostx first!';
        BedpostxButton = questdlg( BedpostxInfo ,'Sure to Run ?','Yes','No','Yes' );
        if strcmp(BedpostxButton, 'Yes') 
            [a, NativePathCellTracking] = PANDA_Select('dir');
            if ~isempty(NativePathCellTracking)
                set(handles.NativeFolderTable, 'data', NativePathCellTracking);
                ResizeSubjectFolderTable(handles);
%                 ProbNativePathCellBefore = NativePathCellTracking;
            else
                set(hObject, 'Value', 0);
            end
        else
            set(hObject, 'Value', 0);
            return;
        end
    end
    if ~isempty(NativePathCellTracking) && ~trackingAlone_opt.NetworkNode
        NetworkNodeInfo{1} = 'Then you should do network node definition !';
        NetworkNodeInfo{2} = 'Please select FA path for network node definition !';
        NetworkNodeButton = questdlg( NetworkNodeInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(NetworkNodeButton, 'Yes')
            NetworkNodePathAutoOpen( handles );
        else
            set(hObject, 'Value', 0);
        end
    elseif ~isempty(FAPathCellTracking)
        trackingAlone_opt.NetworkNode = 1;
    end
    if ~isempty(NativePathCellTracking) && trackingAlone_opt.NetworkNode ...
            && ~isempty(FAPathCellTracking) && isempty(T1orPartitionOfSubjectsPathCellTracking)
        PartitionOrT1Info{1} = 'Do you have parcellated images (native space) of subjects?';
        PartitionOrT1Info{2} = 'If you have, please select Parcellated Check and input parcellated images (native space);';
        PartitionOrT1Info{3} = 'Otherwise, please select T1 Check and input T1 images for subjects, PANDA will create parcellated images for each subject.';
        PartitionOrT1Button = questdlg( PartitionOrT1Info ,'Sure ?','Yes','No','Yes' );
        if strcmp(PartitionOrT1Button,'Yes')
            trackingAlone_opt.PartitionOfSubjects = 1;
            trackingAlone_opt.T1 = 0;
            set( handles.PartitionCheck, 'Value', 1 );
            set( handles.T1Check, 'Value', 0 );
            set( handles.PartitionTemplateEdit, 'String', '');
            set( handles.PartitionTemplateEdit, 'Enable', 'off');
            set( handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off');
            set( handles.T1TemplateEdit, 'String', '');
            set( handles.T1TemplateEdit, 'Enable', 'off');
            set( handles.T1TemplateButton, 'Enable', 'off');
            set( handles.T1TemplateText, 'Enable', 'off');
            set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
            set( handles.T1PathButton, 'Enable', 'off');
            set( handles.T1BetCheckbox, 'Enable', 'off'); 
            set( handles.BetFText, 'Enable', 'off');
            set( handles.T1BetFEdit, 'String', '');
            set( handles.T1BetFEdit, 'Enable', 'off'); 
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
            set( handles.T1CroppingGapText, 'Enable', 'off'); 
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off');
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionText, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            if trackingAlone_opt.NetworkNode && isempty(T1orPartitionOfSubjectsPathCellTracking)
                PartitionInfo{1} = 'Then, you should select parcellated images (native space) for each subject according to FA path in the table';
                PartitionInfo{2} = 'Are you sure?';
                PartitionButton = questdlg( PartitionInfo ,'Sure ?','Yes','No','Yes' );
                if strcmp(PartitionButton, 'Yes')
                    [x,T1orPartitionOfSubjectsPathCellTracking] = PANDA_Select('img');
                    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
                        T1orPartitionOfSubjectsPathCellTracking = '';
                        msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
                    else
                        FAPath_PartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_PartitionOfSubjectsPath );
                        ResizeFAT1orParcellatedTable(handles);
                    end
                else
                    set(hObject, 'Value', 0);
                end
            end
        elseif strcmp(PartitionOrT1Button,'No')
            if ~isempty(NativePathCellTracking) && trackingAlone_opt.NetworkNode ...
                    && isempty(T1orPartitionOfSubjectsPathCellTracking)
                trackingAlone_opt.T1 = 1;
                trackingAlone_opt.PartitionOfSubjects = 0;
                set( handles.T1Check, 'Value', 1 );
                set( handles.PartitionCheck, 'Value', 0 );
                set( handles.PartitionTemplateEdit, 'Enable', 'on');
                set( handles.PartitionTemplateButton, 'Enable', 'on');
                set( handles.PartitionTemplateText, 'Enable', 'on');
                set( handles.T1TemplateEdit, 'Enable', 'on');
                set( handles.T1TemplateButton, 'Enable', 'on');
                set( handles.T1TemplateText, 'Enable', 'on');
                set( handles.T1PathButton, 'Enable', 'on');
                set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
                trackingAlone_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
                set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
                trackingAlone_opt.T1Template = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain'];
                set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template); 
                trackingAlone_opt.T1Bet_Flag = 1;
                set( handles.T1BetCheckbox, 'Enable', 'on'); 
                set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
                trackingAlone_opt.T1BetF = 0.5;
                set( handles.BetFText, 'Enable', 'on'); 
                set( handles.T1BetFEdit, 'Enable', 'on'); 
                set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF)); 
                trackingAlone_opt.T1Cropping_Flag = 1;
                set( handles.T1CroppingGapCheckbox, 'Enable', 'on'); 
                set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
                trackingAlone_opt.T1CroppingGap = 3;
                set( handles.T1CroppingGapText, 'Enable', 'on');
                set( handles.T1CroppingGapEdit, 'Enable', 'on'); 
                set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
                trackingAlone_opt.T1Resample_Flag = 1;
                set( handles.T1ResampleCheckbox, 'Enable', 'on');
                set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
                set( handles.T1ResampleResolutionText, 'Enable', 'on');
                trackingAlone_opt.T1ResampleResolution = [1 1 1];
                set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
                set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
                T1Info{1} = 'Then, you should select T1 for each subject according to FA path in the table';
                T1Info{2} = 'Are you sure?';
                T1Button = questdlg( T1Info ,'Sure ?','Yes','No','Yes' );
                if strcmp(T1Button, 'Yes')
                    [x,T1orPartitionOfSubjectsPathCellTracking] = PANDA_Select('img');
                    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
                        T1orPartitionOfSubjectsPathCellTracking = '';
                        msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
                    else
                        FAPath_T1Path = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1Path );
                        ResizeFAT1orParcellatedTable(handles);
                    end
                else
                    set(hObject, 'Value', 0);
                end
            end
        else
            set(hObject, 'Value', 0);
        end
    end
 
    
    if ~isempty(NativePathCellTracking) && trackingAlone_opt.NetworkNode ...
            && ~isempty(T1orPartitionOfSubjectsPathCellTracking)
        [x, ProbabilisticTracking_opt, ProbabilisticOK] = PANDA_Probabilistic_Opt;
        if ProbabilisticOK
            trackingAlone_opt.ProbabilisticTrackingType = ProbabilisticTracking_opt.ProbabilisticTrackingType;
            trackingAlone_opt.LabelIdVector = ProbabilisticTracking_opt.LabelIdVector;
            trackingAlone_opt.ProbabilisticNetwork = 1;
            clear global BedpostxAndProbabilisticOK;
        else
            set(hObject, 'Value', 0);
        end
    end
else
    trackingAlone_opt.ProbabilisticNetwork = 0;
    % Make Deterministic Fiber Tracking Check available
    set(handles.FiberTrackingCheck, 'Enable', 'on');
    % Set native path empty
%     NativePathCellTracking = '';
%     set(handles.NativeFolderListbox, 'Value', 1);
%     set(handles.NativeFolderListbox, 'String', NativePathCellTracking)
end


% --- Executes on button press in BedpostxAndProbabilisticCheck.
function BedpostxAndProbabilisticCheck_Callback(hObject, eventdata, handles)
% hObject    handle to BedpostxAndProbabilisticCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BedpostxAndProbabilisticCheck
global trackingAlone_opt;
global NativePathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global BedpostxAndProbabilisticOK;
global PANDAPath;
% global BedAndProbNativePathCellBefore;
global FAPathCellTracking;
if get(hObject,'Value')
    trackingAlone_opt.DeterministicNetwork = 0;
    set( handles.DeterministicNetworkCheck, 'Value', 0);
    trackingAlone_opt.ProbabilisticNetwork = 0;
    set( handles.ProbabilisticNetworkCheck, 'Value', 0);
    % Make Fiber Tracking unavaliable
    trackingAlone_opt.DterminFiberTracking = 0;
    set( handles.FiberTrackingCheck, 'Value', 0);
    set( handles.FiberTrackingCheck, 'Enable', 'off');
%     set( handles.ImageOrientationText, 'Enable', 'off');
    trackingAlone_opt.ImageOrientation = 'Auto';
%     set( handles.ImageOrientationMenu, 'value', 1.0);
%     set( handles.ImageOrientationMenu, 'Enable', 'off');
    set( handles.AngleThresholdText, 'Enable', 'off');
    trackingAlone_opt.AngleThreshold = '45';
    set( handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
    set( handles.AngleThresholdEdit, 'Enable', 'off');
    set( handles.PropagationAlgorithmText, 'Enable', 'off');
    trackingAlone_opt.PropagationAlgorithm = 'FACT';
    set( handles.PropagationAlgorithmMenu, 'value', 1.0);    
    set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
    set( handles.StepLengthText, 'Enable', 'off');
    set( handles.StepLengthEdit, 'Enable', 'off');
    set( handles.MaskThresholdText, 'Enable', 'off');
    trackingAlone_opt.MaskThresMin = 0.2;
    set( handles.MaskThresMinEdit, 'String', '0.2');    
    set( handles.MaskThresMinEdit, 'Enable', 'off');
    set( handles.text7, 'Enable', 'off');
    trackingAlone_opt.MaskThresMax = 1;
    set( handles.MaskThresMaxEdit, 'String', '1');
    set( handles.MaskThresMaxEdit, 'Enable', 'off');
    trackingAlone_opt.ApplySplineFilter = 'No';
    set( handles.ApplySplineFilterCheck, 'Value', 0);
    set( handles.ApplySplineFilterCheck, 'Enable', 'off');
    set( handles.OrientationPatchText, 'Enable', 'off');
    trackingAlone_opt.Inversion = 'Invert Z';
    set( handles.InversionMenu, 'value', 4.0);
    set( handles.InversionMenu, 'Enable', 'off');
    trackingAlone_opt.Swap = 'No Swap';
    set( handles.SwapMenu, 'value', 1.0);
    set( handles.SwapMenu, 'Enable', 'off');
    trackingAlone_opt.RandomSeed_Flag = 0;
    set( handles.RandomSeedCheckbox, 'Value', 0);
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
%     NativePathCellTracking = BedAndProbNativePathCellBefore;
%     if ~isempty(BedAndProbNativePathCellBefore)
%         set(handles.NativeFolderListbox, 'String', BedAndProbNativePathCellBefore);
%     end
    if isempty(NativePathCellTracking)
        NativeInfo{1} = 'Are you sure to do bedpostx and probabilistic network construction ?';
        NativeInfo{2} = 'If you are sure, please add the native folder consisting of data, bvecs, bvals, nodif_brain_mask, first!';
        NativeButton = questdlg( NativeInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(NativeButton, 'Yes')
            [a, NativePathCellTracking] = PANDA_Select('dir');
            if ~isempty(NativePathCellTracking)
                set(handles.NativeFolderTable, 'data', NativePathCellTracking);
                ResizeSubjectFolderTable(handles);
%                 BedAndProbNativePathCellBefore = NativePathCellTracking;
            else
                set(hObject, 'Value', 0);
            end
        else
            set(hObject, 'Value', 0);
            return;
        end
    end
    if ~isempty(NativePathCellTracking) && ~trackingAlone_opt.NetworkNode ... 
            && isempty(FAPathCellTracking)
        NetworkNodeInfo{1} = 'Then you should do network node definition !';
        NetworkNodeInfo{2} = 'Please select FA path for network node definition !';
        NetworkNodeButton = questdlg( NetworkNodeInfo ,'Sure ?','Yes','No','Yes' );
        if strcmp(NetworkNodeButton, 'Yes')
            NetworkNodePathAutoOpen( handles );
        else
            set(hObject, 'Value', 0);
        end
    elseif ~isempty(FAPathCellTracking)
        trackingAlone_opt.NetworkNode = 1;
    end
    if ~isempty(NativePathCellTracking) && trackingAlone_opt.NetworkNode ...
            && ~isempty(FAPathCellTracking) && isempty(T1orPartitionOfSubjectsPathCellTracking)
        PartitionOrT1Info{1} = 'Do you have parcellated images (native space) of subjects?';
        PartitionOrT1Info{2} = 'If you have, please select Parcellated Check and input parcellated images (native space);';
        PartitionOrT1Info{3} = 'Otherwise, please select T1 Check and input T1 images for subjects, PANDA will create parcellated images for each subject.';
        PartitionOrT1Button = questdlg( PartitionOrT1Info ,'Sure ?','Yes','No','Yes' );
        if strcmp(PartitionOrT1Button,'Yes')
            trackingAlone_opt.PartitionOfSubjects = 1;
            trackingAlone_opt.T1 = 0;
            set( handles.PartitionCheck, 'Value', 1 );
            set( handles.T1Check, 'Value', 0 );
            set( handles.PartitionTemplateEdit, 'String', '');
            set( handles.PartitionTemplateEdit, 'Enable', 'off');
            set( handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off');
            set( handles.T1TemplateEdit, 'String', '');
            set( handles.T1TemplateEdit, 'Enable', 'off');
            set( handles.T1TemplateButton, 'Enable', 'off');
            set( handles.T1TemplateText, 'Enable', 'off');
            set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
            set( handles.T1PathButton, 'Enable', 'off');
            set( handles.T1BetCheckbox, 'Enable', 'off'); 
            set( handles.BetFText, 'Enable', 'off');
            set( handles.T1BetFEdit, 'String', '');
            set( handles.T1BetFEdit, 'Enable', 'off'); 
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
            set( handles.T1CroppingGapText, 'Enable', 'off'); 
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionText, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            if ~isempty(NativePathCellTracking) && isempty(T1orPartitionOfSubjectsPathCellTracking)
                PartitionInfo{1} = 'Then, you should select parcellated images for each subject according to FA path in the table';
                PartitionInfo{2} = 'Are you sure?';
                PartitionButton = questdlg( PartitionInfo ,'Sure ?','Yes','No','Yes' );
                if strcmp(PartitionButton, 'Yes')
                    [x,T1orPartitionOfSubjectsPathCellTracking] = PANDA_Select('img');
                    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
                        T1orPartitionOfSubjectsPathCellTracking = '';
                        msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
                    else
                        FAPath_PartitionOfSubjectsPath = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_PartitionOfSubjectsPath );
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
            set( handles.PartitionCheck, 'Value', 0 );
            set( handles.PartitionTemplateEdit, 'Enable', 'on');
            set( handles.PartitionTemplateButton, 'Enable', 'on');
            set( handles.PartitionTemplateText, 'Enable', 'on');
            set( handles.T1TemplateEdit, 'Enable', 'on');
            set( handles.T1TemplateButton, 'Enable', 'on');
            set( handles.T1TemplateText, 'Enable', 'on');
            set( handles.T1PathButton, 'Enable', 'on');
            set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
            trackingAlone_opt.T1Bet_Flag = 1;
            set( handles.T1BetCheckbox, 'Enable', 'on');
            set( handles.T1BetCheckbox, 'Value', trackingAlone_opt.T1Bet_Flag);
            trackingAlone_opt.T1BetF = 0.5;
            set( handles.BetFText, 'Enable', 'on');
            set( handles.T1BetFEdit, 'Enable', 'on');
            set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF));
            trackingAlone_opt.T1Cropping_Flag = 1;
            set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
            set( handles.T1CroppingGapCheckbox, 'Value', trackingAlone_opt.T1Cropping_Flag);
            trackingAlone_opt.T1CroppingGap = 3;
            set( handles.T1CroppingGapText, 'Enable', 'on');
            set( handles.T1CroppingGapEdit, 'Enable', 'on');
            set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
            trackingAlone_opt.T1Resample_Flag = 1;
            set( handles.T1ResampleCheckbox, 'Enable', 'on');
            set( handles.T1ResampleCheckbox, 'Value', trackingAlone_opt.T1Resample_Flag);
            set( handles.T1ResampleResolutionText, 'Enable', 'on');
            trackingAlone_opt.T1ResampleResolution = [1 1 1];
            set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
            set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
            trackingAlone_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
            set( handles.PartitionTemplateEdit, 'String', trackingAlone_opt.PartitionTemplate);
            trackingAlone_opt.T1Template = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain'];
            set( handles.T1TemplateEdit, 'String', trackingAlone_opt.T1Template);
            if ~isempty(NativePathCellTracking) && isempty(T1orPartitionOfSubjectsPathCellTracking)
                T1Info{1} = 'Then, you should select T1 for each subject according to FA path in the table';
                T1Info{2} = 'Are you sure?';
                T1Button = questdlg( T1Info ,'Sure ?','Yes','No','Yes' );
                if strcmp(T1Button, 'Yes')
                    [x,T1orPartitionOfSubjectsPathCellTracking] = PANDA_Select('img');
                    if length(FAPathCellTracking) ~= length(T1orPartitionOfSubjectsPathCellTracking)
                        T1orPartitionOfSubjectsPathCellTracking = '';
                        msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
                        set(hObject, 'Value', 0);
                    else
                        FAPath_T1Path = [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking];
                        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1Path );
                        ResizeFAT1orParcellatedTable(handles);
                        set(hObject, 'Value', 0);
                    end
                else
                    set(hObject, 'Value', 0);
                end
            end
        else
            set(hObject, 'Value', 0);
        end
%     else
%         set(hObject, 'Value', 0);
    end
    
    if ~isempty(NativePathCellTracking) && trackingAlone_opt.NetworkNode ...
            && ~isempty(T1orPartitionOfSubjectsPathCellTracking)
        [x, Bedpostx_opt, ProbabilisticTracking_opt, BedpostxAndProbabilisticOK] = PANDA_BedpostxAndProbabilistic_Opt;
        if BedpostxAndProbabilisticOK
            trackingAlone_opt.Fibers = Bedpostx_opt.Fibers;
            trackingAlone_opt.Weight = Bedpostx_opt.Weight;
            trackingAlone_opt.Burnin = Bedpostx_opt.Burnin;
            trackingAlone_opt.ProbabilisticTrackingType = ProbabilisticTracking_opt.ProbabilisticTrackingType;
            trackingAlone_opt.LabelIdVector = ProbabilisticTracking_opt.LabelIdVector;
            trackingAlone_opt.BedpostxProbabilisticNetwork = 1;
            clear global BedpostxAndProbabilisticOK;
        else
            set(hObject, 'Value', 0);
        end
    end
else
    trackingAlone_opt.BedpostxProbabilisticNetwork = 0;
    % Make Deterministic Fiber Tracking Check available
    set(handles.FiberTrackingCheck, 'Enable', 'on');
    % Set native path empty
%     NativePathCellTracking = '';
%     set(handles.NativeFolderListbox, 'Value', 1);
%     set(handles.NativeFolderListbox, 'String', NativePathCellTracking)
end

function DeterminFiberTrackingPathAutoOpen( handles )
global NativePathCellTracking;
global trackingAlone_opt;
if isempty(NativePathCellTracking)
    [a, NativePathCellTracking] = PANDA_Select('dir');
end
if ~isempty(NativePathCellTracking)
    if strcmp(get( handles.PropagationAlgorithmMenu, 'Enable' ), 'off')
        set(handles.FiberTrackingCheck, 'Value', 1)
    %     FiberTrackNativePathCellBefore = NativePathCellTracking;
        set(handles.NativeFolderTable, 'data', NativePathCellTracking);
        ResizeSubjectFolderTable(handles);
        trackingAlone_opt.DterminFiberTracking = 1;
%         set( handles.ImageOrientationText, 'Enable', 'on');
%         set( handles.ImageOrientationMenu, 'Enable', 'on');
        trackingAlone_opt.ImageOrientation = 'Auto';
%         set( handles.ImageOrientationMenu, 'value', 1.0);
        set( handles.AngleThresholdText, 'Enable', 'on');
        set( handles.AngleThresholdEdit, 'Enable', 'on');
        trackingAlone_opt.AngleThreshold = '45';
        set( handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
        set( handles.PropagationAlgorithmText, 'Enable', 'on');
        set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
        trackingAlone_opt.PropagationAlgorithm = 'FACT';
        set( handles.PropagationAlgorithmMenu, 'value', 1.0);
        set( handles.StepLengthEdit, 'Enable', 'off');
        set( handles.StepLengthText, 'Enable', 'on');
        set( handles.StepLengthEdit, 'Enable', 'off');
        set( handles.MaskThresholdText, 'Enable', 'on');
        set( handles.MaskThresMinEdit, 'Enable', 'on');
        trackingAlone_opt.MaskThresMin = 0.2;
        set( handles.MaskThresMinEdit, 'String', num2str(trackingAlone_opt.MaskThresMin));
        set( handles.text7, 'Enable', 'on');
        set( handles.MaskThresMaxEdit, 'Enable', 'on');
        trackingAlone_opt.MaskThresMax = 1;
        set( handles.MaskThresMaxEdit, 'String', num2str(trackingAlone_opt.MaskThresMax));
        set( handles.ApplySplineFilterCheck, 'Enable', 'on');
        set( handles.ApplySplineFilterCheck, 'Value', 1.0);
        trackingAlone_opt.ApplySplineFilter = 'Yes';
        set( handles.OrientationPatchText, 'Enable', 'on');
        set( handles.InversionMenu, 'Enable', 'on');
        trackingAlone_opt.Inversion = 'Invert Z';
        set( handles.InversionMenu, 'value', 4.0);
        set( handles.SwapMenu, 'Enable', 'on');
        trackingAlone_opt.Swap = 'No Swap';
        set( handles.SwapMenu, 'value', 1.0);
        trackingAlone_opt.RandomSeed_Flag = 0;
        set( handles.RandomSeedCheckbox, 'Value', 0);
        set( handles.RandomSeedCheckbox, 'Enable', 'on');
        set( handles.RandomSeedText, 'Enable', 'on');
        set( handles.RandomSeedEdit, 'String', '');
        set( handles.RandomSeedEdit, 'Enable', 'off');
    end
end


function NetworkNodePathAutoOpen( handles )
global FAPathCellTracking;
global trackingAlone_opt;
global T1orPartitionOfSubjectsPathCellTracking;
set( handles.FAPathButton, 'Enable', 'on');
% set( handles.FiberTrackingCheck, 'value', 0);
[a, FAPathCellTracking] = PANDA_Select('img');
if ~isempty(FAPathCellTracking)
    trackingAlone_opt.NetworkNode = 1;
    trackingAlone_opt.PartitionOfSubjects = 1;
    trackingAlone_opt.T1 = 0;
    set( handles.NetworkNodeCheck, 'Value', 1.0);
    set( handles.PartitionCheck, 'Enable', 'on');
    set( handles.T1Check, 'Enable', 'on');
    set( handles.PartitionCheck, 'Value', 1.0);
    set( handles.T1Check, 'Value', 0.0);
    set( handles.LocationTableText, 'Enable', 'on' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on' );
    set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
    ColumnName{1} = 'Path of FA';
    ColumnName{2} = 'Path of parcellated images';
    set( handles.PartitionTemplateEdit, 'String', '');
    set( handles.PartitionTemplateEdit, 'Enable', 'off');
    set( handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off');
    set( handles.T1TemplateEdit, 'String', '');
    set( handles.T1TemplateEdit, 'Enable', 'off');
    set( handles.T1TemplateButton, 'Enable', 'off');
    set( handles.T1TemplateText, 'Enable', 'off');
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    if isempty(T1orPartitionOfSubjectsPathCellTracking)
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPathCellTracking );
    else
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', [FAPathCellTracking T1orPartitionOfSubjectsPathCellTracking] );
    end
    ResizeFAT1orParcellatedTable(handles);
else
    trackingAlone_opt.NetworkNode = 0;
    set( handles.NetworkNodeCheck, 'Value', 0.0 );
    DataCell = cell(4,1);
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
    ResizeFAT1orParcellatedTable(handles);
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off' );
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
    set( handles.PartitionTemplateText, 'Enable', 'off' );
    set( handles.PartitionTemplateEdit, 'String', '' );
    set( handles.PartitionTemplateEdit, 'Enable', 'off' );
    set( handles.PartitionTemplateButton, 'Enable', 'off' );
    set( handles.T1TemplateText, 'Enable', 'off' );
    set( handles.T1TemplateEdit, 'String', '' );
    set( handles.T1TemplateEdit, 'Enable', 'off' );
    set( handles.T1TemplateButton, 'Enable', 'off' );
    set( handles.PartitionCheck, 'value', 0.0 );
    set( handles.T1Check, 'value', 0.0 );
    set( handles.PartitionCheck, 'Enable', 'off' );
    set( handles.T1Check, 'Enable', 'off' );
end



% --- Executes on button press in FAPathButton.
function FAPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to FAPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FAPathCellTracking;
global trackingAlone_opt;
FAPathTracking_Button = get(hObject, 'UserData');
[a, FAPathCellTracking, Done] = PANDA_Select('img', FAPathTracking_Button);
if Done == 1
    set(hObject, 'UserData', FAPathCellTracking);
    if ~isempty(FAPathCellTracking)
        trackingAlone_opt.NetworkNode = 1;
        trackingAlone_opt.PartitionOfSubjects = 1;
        trackingAlone_opt.T1 = 0;
        set( handles.NetworkNodeCheck, 'Value', 1.0);
        set( handles.PartitionCheck, 'Enable', 'on');
        set( handles.T1Check, 'Enable', 'on');
        set( handles.PartitionCheck, 'Value', 1.0);
        set( handles.T1Check, 'Value', 0.0);
        set( handles.LocationTableText, 'Enable', 'on' );
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on' );
        set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
        ColumnName{1} = 'Path of FA';
        ColumnName{2} = 'Path of parcellated images';
        set( handles.PartitionTemplateEdit, 'String', '');
        set( handles.PartitionTemplateEdit, 'Enable', 'off');
        set( handles.PartitionTemplateButton, 'Enable', 'off');
        set( handles.PartitionTemplateText, 'Enable', 'off');
        set( handles.T1TemplateEdit, 'String', '');
        set( handles.T1TemplateEdit, 'Enable', 'off');
        set( handles.T1TemplateButton, 'Enable', 'off');
        set( handles.T1TemplateText, 'Enable', 'off');
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
        FAPath_T1orPartitionOfSubjectsPath = FAPathCellTracking;
        msgbox('Please select parcellated images (native space) or T1 images according to the order of FA images');
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
        ResizeFAT1orParcellatedTable(handles);
    % else
    %     trackingAlone_opt.NetworkNode = 0;
    %     set( handles.NetworkNodeCheck, 'Value', 0.0 );
    %     DataCell = cell(4,1);
    %     set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
    %     ResizeFAT1orParcellatedTable(handles);
    %     set( handles.LocationTableText, 'Enable', 'off' );
    %     set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off' );
    %     set( handles.PartitionOfSubjectsButton, 'Enable', 'off' );
    %     set( handles.PartitionTemplateText, 'Enable', 'off' );
    %     set( handles.PartitionTemplateEdit, 'String', '' );
    %     set( handles.PartitionTemplateEdit, 'Enable', 'off' );
    %     set( handles.PartitionTemplateButton, 'Enable', 'off' );
    %     set( handles.PartitionCheck, 'value', 0.0 );
    %     set( handles.T1Check, 'value', 0.0 );
    %     set( handles.PartitionCheck, 'Enable', 'off' );
    %     set( handles.T1Check, 'Enable', 'off' );
    end
end



function MaxQueuedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxQueuedEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxQueuedEdit as a double
global TrackingPipeline_opt;
TrackingPipeline_opt.max_queued = str2num(get(hObject, 'String'));


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
global TrackingPipeline_opt;
TrackingPipeline_opt.qsub_options = get(hObject, 'String');


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
global TrackingPipeline_opt;
LogPath = get(hObject, 'String');
if ~exist(LogPath, 'dir') & ~isempty(LogPath)
    try
        mkdir(LogPath);
    catch
        msgbox('The path you input is illegal !');
    end
end
TrackingPipeline_opt.path_logs = [LogPath filesep 'Tracking_logs'];


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
global TrackingPipeline_opt;
LogPath = uigetdir;
if LogPath
    TrackingPipeline_opt.path_logs = [LogPath filesep 'Tracking_logs'];
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
global TrackingPipeline_opt;
switch get(hObject, 'tag')
    case 'batchRadio'
        TrackingPipeline_opt.mode = 'background';
        set( handles.QsubOptionsEdit, 'String', '');
        set( handles.QsubOptionsEdit, 'Enable', 'off');
        LogPath = [pwd filesep 'Tracking_logs'];
        TrackingPipeline_opt.path_logs = LogPath;
        set( handles.LogPathEdit, 'String', TrackingPipeline_opt.path_logs);
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
            TrackingPipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            TrackingPipeline_opt.max_queued = 2;
        end
        set(handles.MaxQueuedEdit, 'string', num2str(TrackingPipeline_opt.max_queued));
    case 'qsubRadio'
        TrackingPipeline_opt.mode = 'qsub';
        TrackingPipeline_opt.qsub_options = '-V -q all.q';
        set( handles.QsubOptionsEdit, 'Enable', 'on');
        set( handles.QsubOptionsEdit, 'String', '-V -q all.q');
        LogPath = [pwd filesep 'Tracking_logs'];
        TrackingPipeline_opt.path_logs = LogPath;
        set( handles.LogPathEdit, 'String', TrackingPipeline_opt.path_logs);
        TrackingPipeline_opt.max_queued = 40;
        set(handles.MaxQueuedEdit, 'string', num2str(TrackingPipeline_opt.max_queued));
end


% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Native folders input
global trackingAlone_opt;
global FAPathCellTracking;
global T1orPartitionOfSubjectsPathCellTracking;
global NativePathCellTracking;
global SubjectIDArrayTracking;
global NativePathSelectedTracking;
global TrackingPipeline_opt;
global JobStatusMonitorTimer_InTracking;
% global FiberTrackNativePathCellBefore;
% global ProbNativePathCellBefore;
% global BedAndProbNativePathCellBefore;
global LockExistTracking;
global LockDisappearTracking;

button = questdlg('Are you sure to clear ?','Sure to clear ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop the monitor
        if ~isempty(JobStatusMonitorTimer_InTracking)
            stop(JobStatusMonitorTimer_InTracking);
            clear global JobStatusMonitorTimer_InTracking;
        end

        clear global FAPathCellTracking;
        clear global T1orPartitionOfSubjectsPathCellTracking;
        clear global NativePathCellTracking;
        clear global SubjectIDArrayTracking;
        clear global NativePathSelectedTracking;
%         clear global FiberTrackNativePathCellBefore;
%         clear global ProbNativePathCellBefore;
%         clear global BedAndProbNativePathCellBefore;
        clear global LockExistTracking;
        clear global LockDisappearTracking;

        %set( handles.SubjectFoldersListText, 'Enable', 'on');
        SubjectFolders = cell(4, 2);
        set( handles.NativeFolderTable, 'data', SubjectFolders);
        ResizeSubjectFolderTable(handles);
        set( handles.AddNativeFolderButton, 'Enable', 'on');
        set( handles.SubjectIDEdit, 'String', '');
        set( handles.SubjectIDEdit, 'Enable', 'on');
        set( handles.SubjectIDLoadButton, 'Enable', 'on');
        % Deterministic fiber tracking
        trackingAlone_opt.DterminFiberTracking = 0;
        set( handles.FiberTrackingCheck, 'Enable', 'on' );
        set( handles.FiberTrackingCheck, 'value', 0.0 );
%         set( handles.ImageOrientationText, 'Enable', 'off');
        trackingAlone_opt.ImageOrientation = 'Auto';
%         set( handles.ImageOrientationMenu, 'value', 1.0);
%         set( handles.ImageOrientationMenu, 'Enable', 'off');
        set( handles.AngleThresholdText, 'Enable', 'off');
        trackingAlone_opt.AngleThreshold = '45';
        set( handles.AngleThresholdEdit, 'String', trackingAlone_opt.AngleThreshold);
        set( handles.AngleThresholdEdit, 'Enable', 'off');
        set( handles.PropagationAlgorithmText, 'Enable', 'off');
        trackingAlone_opt.PropagationAlgorithm = 'FACT';
        set( handles.PropagationAlgorithmMenu, 'value', 1.0); 
        set( handles.PropagationAlgorithmMenu, 'Enable', 'off');
        set( handles.StepLengthText, 'Enable', 'off');
        set( handles.StepLengthEdit, 'String', '');
        set( handles.StepLengthEdit, 'Enable', 'off');
        set( handles.MaskThresholdText, 'Enable', 'off');
        trackingAlone_opt.MaskThresMin = 0.2;
        set( handles.MaskThresMinEdit, 'String', '0.2');
        set( handles.MaskThresMinEdit, 'Enable', 'off');
        set( handles.text7, 'Enable', 'off');
        trackingAlone_opt.MaskThresMax = 1;
        set( handles.MaskThresMaxEdit, 'String', '1');
        set( handles.MaskThresMaxEdit, 'Enable', 'off');
        trackingAlone_opt.ApplySplineFilter = 'No';
        set( handles.ApplySplineFilterCheck, 'Value', 0);
        set( handles.ApplySplineFilterCheck, 'Enable', 'off');
        set( handles.OrientationPatchText, 'Enable', 'off');
        trackingAlone_opt.Inversion = 'Invert Z';
        set( handles.InversionMenu, 'value', 4.0);
        set( handles.InversionMenu, 'Enable', 'off');
        trackingAlone_opt.Swap = 'No Swap';
        set(handles.SwapMenu, 'value', 1.0);
        set( handles.SwapMenu, 'Enable', 'off');
        trackingAlone_opt.RandomSeed_Flag = 0;
        set( handles.RandomSeedCheckbox, 'Value', 0);
        set( handles.RandomSeedText, 'Enable', 'off');
        set( handles.RandomSeedEdit, 'String', '');
        set( handles.RandomSeedEdit, 'Enable', 'off');
        % Network node definition
        trackingAlone_opt.NetworkNode = 0;
        set( handles.NetworkNodeCheck, 'Enable', 'on');
        set( handles.NetworkNodeCheck, 'value', 0.0);
        set( handles.FAPathButton, 'Enable', 'off');
        trackingAlone_opt.PartitionOfSubjects = 0;
        set( handles.PartitionCheck, 'Value', 0);
        set( handles.PartitionCheck, 'Enable', 'off');
        trackingAlone_opt.T1 = 0;
        set( handles.T1Check, 'Value', 0);
        set( handles.T1Check, 'Enable', 'off');
        FAPathCell = '';
        T1orPartitionOfSubjectsPathCellTracking = '';
        DataCell = cell(4,1);
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
        ResizeFAT1orParcellatedTable(handles);
        set( handles.LocationTableText, 'Enable', 'off' );
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off');
        set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
        set( handles.T1PathButton, 'Enable', 'off');
        set( handles.PartitionTemplateText, 'Enable', 'off');
        set( handles.PartitionTemplateEdit, 'String', '');
        set( handles.PartitionTemplateEdit, 'Enable', 'off');
        set( handles.PartitionTemplateButton, 'Enable', 'off');
        set( handles.T1TemplateText, 'Enable', 'off');
        set( handles.T1TemplateEdit, 'String', '');
        set( handles.T1TemplateEdit, 'Enable', 'off');
        set( handles.T1TemplateButton, 'Enable', 'off');
        set( handles.T1BetCheckbox, 'Value', 0);
        set( handles.T1BetCheckbox, 'Enable', 'off'); 
        set( handles.BetFText, 'Enable', 'off');
        set( handles.T1BetFEdit, 'String', '');
        set( handles.T1BetFEdit, 'Enable', 'off'); 
        set( handles.T1CroppingGapCheckbox, 'Value', 0);
        set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
        set( handles.T1CroppingGapText, 'Enable', 'off'); 
        set( handles.T1CroppingGapEdit, 'String', '');
        set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%         set( handles.T1CroppingGapUnitText, 'Enable', 'off');
        set( handles.T1ResampleCheckbox, 'Value', 0);
        set( handles.T1ResampleCheckbox, 'Enable', 'off');
        set( handles.T1ResampleResolutionText, 'Enable', 'off');
        set( handles.T1ResampleResolutionEdit, 'String', '');
        set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
        % Construct network
        trackingAlone_opt.DeterministicNetwork = 0;    
        set( handles.DeterministicNetworkCheck, 'Enable', 'on');
        set( handles.DeterministicNetworkCheck, 'value', 0.0);
        trackingAlone_opt.ProbabilisticNetwork = 0;
        set( handles.ProbabilisticNetworkCheck, 'Enable', 'on');
        set( handles.ProbabilisticNetworkCheck, 'value', 0.0);
        trackingAlone_opt.BedpostxProbabilisticNetwork = 0;
        set( handles.BedpostxAndProbabilisticCheck, 'Enable', 'on');
        set( handles.BedpostxAndProbabilisticCheck, 'value', 0.0);
        % Pipeline options
        set( handles.batchRadio, 'Enable', 'on');
        set( handles.batchRadio, 'Value', 1);
        set( handles.qsubRadio, 'Enable', 'on');
        TrackingPipeline_opt.mode = 'background';
        TrackingPipeline_opt.qsub_options = '';
        set( handles.QsubOptionsEdit, 'String', '');
        set( handles.QsubOptionsEdit, 'Enable', 'off');
        LogPathParent = pwd;
        TrackingPipeline_opt.path_logs = [LogPathParent filesep 'Tracking_logs'];
        set( handles.LogPathEdit, 'Enable', 'on');
        set( handles.LogPathEdit, 'String', LogPathParent);
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
            TrackingPipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            TrackingPipeline_opt.max_queued = 2;
        end
        set( handles.MaxQueuedEdit, 'Enable', 'on');
        set( handles.MaxQueuedEdit, 'string', num2str(TrackingPipeline_opt.max_queued));
        set( handles.LogPathButton, 'Enable', 'on');
    case 'No'
        return;
end


% --- Executes on button press in StatusButton.
function StatusButton_Callback(hObject, eventdata, handles)
% hObject    handle to StatusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LockExistTracking;
if ~LockExistTracking
    Info{1} = 'Please wait for a moment !';
    Info{2} = 'The status file has not been created yet !';
    msgbox(Info);
else
    PANDA_Tracking_Status;
end


% --- Executes on button press in TerminateJobButton.
function TerminateJobButton_Callback(hObject, eventdata, handles)
% hObject    handle to TerminateJobButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TrackingPipeline_opt;
global StopFlag_InTrackingStatus;
global JobStatusMonitorTimer_InTracking;
global trackingAlone_opt;
global LockDisappearTracking;

if ~isempty(TrackingPipeline_opt)
    % Stop the monitor
    if ~isempty(JobStatusMonitorTimer_InTracking)
        stop(JobStatusMonitorTimer_InTracking);
        clear global JobStatusMonitorTimer_InTracking;
    end
    % Delete file
    LockFilePath = [TrackingPipeline_opt.path_logs filesep 'PIPE.lock'];
    if isempty(TrackingPipeline_opt.path_logs) | ~exist(LockFilePath, 'file')
        msgbox('No job is running !');
    else
        button = questdlg('Are you sure to terminal this job ?','Sure to terminal ?','Yes','No','Yes');
        switch button
            case 'Yes'   
                system(['rm -rf ' LockFilePath]);
                while exist(LockFilePath, 'file')
                    system(['rm -rf ' LockFilePath]);
                end
                LockDisappearTracking = 1;
                % Set edit box enable, Stop Monitor, Update job status table
                StopFlag_InTrackingStatus = '(Stopped)';
                % Set the status of edit boxes and buttons 
                % Native folders input
                %set( handles.SubjectFoldersListText, 'Enable', 'on');
                set( handles.AddNativeFolderButton, 'Enable', 'on');
                set( handles.SubjectIDEdit, 'Enable', 'on');
                set( handles.SubjectIDLoadButton, 'Enable', 'on');
                % Deterministic fiber tracking
                set( handles.FiberTrackingCheck, 'Enable', 'on');
                if trackingAlone_opt.DterminFiberTracking 
%                     set( handles.ImageOrientationMenu, 'Enable', 'on');
                    set( handles.AngleThresholdEdit, 'Enable', 'on');
                    set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
                    if ~strcmp(trackingAlone_opt.PropagationAlgorithm, 'FACT')
                        set( handles.StepLengthEdit, 'Enable', 'on');
                    end   
                    set( handles.MaskThresMinEdit, 'Enable', 'on');
                    set( handles.MaskThresMaxEdit, 'Enable', 'on');
                    set( handles.ApplySplineFilterCheck, 'Enable', 'on');
                    set( handles.InversionMenu, 'Enable', 'on');
                    set( handles.SwapMenu, 'Enable', 'on');
                    set( handles.RandomSeedCheckbox, 'Enable', 'on');
                    if trackingAlone_opt.RandomSeed_Flag
                        set( handles.RandomSeedEdit, 'Enable', 'on');
                    end
                end
                % Network node definition
                set( handles.NetworkNodeCheck, 'Enable', 'on');
                if trackingAlone_opt.NetworkNode  
                    set( handles.FAPathButton, 'Enable', 'on');
                    if trackingAlone_opt.PartitionOfSubjects
                        set( handles.PartitionCheck, 'Enable', 'on');
                        set( handles.T1Check, 'Enable', 'on');
                        set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
                    elseif trackingAlone_opt.T1
                        set( handles.T1Check, 'Enable', 'on');
                        set( handles.PartitionCheck, 'Enable', 'on');
                        set( handles.T1PathButton, 'Enable', 'on');
                        set( handles.PartitionTemplateEdit, 'Enable', 'on');
                        set( handles.PartitionTemplateButton, 'Enable', 'on');
                        set( handles.T1BetCheckbox, 'Enable', 'on'); 
                        set( handles.BetFText, 'Enable', 'on');
                        if trackingAlone_opt.T1Bet_Flag
                            set( handles.T1BetFEdit, 'Enable', 'on');
                        end
                        set( handles.T1CroppingGapCheckbox, 'Enable', 'on'); 
                        set( handles.T1CroppingGapText, 'Enable', 'on');
                        if trackingAlone_opt.T1Cropping_Flag
                            set( handles.T1CroppingGapEdit, 'Enable', 'on');
                        end
                        set( handles.T1ResampleCheckbox, 'Enable', 'on');
                        set( handles.T1ResampleResolutionText, 'Enable', 'on');
                        if trackingAlone_opt.T1Resample_Flag
                            set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
                        end
                    end
                    set(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on');
                end
                % Network construction
                set( handles.DeterministicNetworkCheck, 'Enable', 'on');
                set( handles.ProbabilisticNetworkCheck, 'Enable', 'on');
                set( handles.BedpostxAndProbabilisticCheck, 'Enable', 'on');
                % Pipeline options
                set( handles.batchRadio, 'Enable', 'on');
                set( handles.qsubRadio, 'Enable', 'on');
                if strcmp(TrackingPipeline_opt.mode, 'qsub')
                    set( handles.QsubOptionsEdit, 'Enable', 'on');
                end
                set( handles.MaxQueuedEdit, 'Enable', 'on');
                set( handles.LogPathEdit, 'Enable', 'on');
                set( handles.LogPathButton, 'Enable', 'on');
                
                msgbox('The jobs are terminated successfully !');
            case 'No'
                return;
        end
    end
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
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


% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Help;


% --- Executes during object creation, after setting all properties.
function PipelineOptionsUipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PipelineOptionsUipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Monitor Function
function JobStatusMonitorTracking(hObject, eventdata, handles)
global trackingAlone_opt;
global TrackingPipeline_opt;
global JobStatusMonitorTimer_InTracking;
global StopFlag_InTrackingStatus;
global LockExistTracking;
global LockDisappearTracking;

if ~isempty(trackingAlone_opt)
    LockFilePath = [TrackingPipeline_opt.path_logs filesep 'PIPE.lock'];
    if ~LockExistTracking & exist( LockFilePath, 'file' )
        LockExistTracking = 1;
    end
    if LockExistTracking & ~exist( LockFilePath, 'file' )
        LockDisappearTracking = 1;
    end
    
    ErrorFilePath = [TrackingPipeline_opt.path_logs filesep 'tracking_pipeline.error'];
    
    JobsFinishFilePath = [TrackingPipeline_opt.path_logs filesep 'jobs.finish'];
    
    if LockDisappearTracking == 1 | exist(ErrorFilePath, 'file') | exist(JobsFinishFilePath, 'file')
        % Set edit boxes and buttons enable
        % Native folders input
        %set( handles.SubjectFoldersListText, 'Enable', 'on');
        set( handles.AddNativeFolderButton, 'Enable', 'on');
        set( handles.SubjectIDEdit, 'Enable', 'on');
        set( handles.SubjectIDLoadButton, 'Enable', 'on');
        % Deterministic fiber tracking
        set( handles.FiberTrackingCheck, 'Enable', 'on');
        if trackingAlone_opt.DterminFiberTracking
%             set( handles.ImageOrientationMenu, 'Enable', 'on');
            set( handles.AngleThresholdEdit, 'Enable', 'on');
            set( handles.PropagationAlgorithmMenu, 'Enable', 'on');
            if ~strcmp(trackingAlone_opt.PropagationAlgorithm, 'FACT')
                set( handles.StepLengthEdit, 'Enable', 'on');
            end
            set( handles.MaskThresMinEdit, 'Enable', 'on');
            set( handles.MaskThresMaxEdit, 'Enable', 'on');
            set( handles.ApplySplineFilterCheck, 'Enable', 'on');
            set( handles.InversionMenu, 'Enable', 'on');
            set( handles.SwapMenu, 'Enable', 'on');
            set( handles.RandomSeedCheckbox, 'Enable', 'on');
            if trackingAlone_opt.RandomSeed_Flag
                set( handles.RandomSeedEdit, 'Enable', 'on');
            end
        end
        % Network node definition
        set( handles.NetworkNodeCheck, 'Enable', 'on');
        if trackingAlone_opt.NetworkNode
            set( handles.FAPathButton, 'Enable', 'on');
            set( handles.LocationTableText, 'Enable', 'on');
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on');
            set( handles.PartitionCheck, 'Enable', 'on');
            set( handles.T1Check, 'Enable', 'on');
            if trackingAlone_opt.PartitionOfSubjects
                set( handles.PartitionOfSubjectsButton, 'Enable', 'on');
            elseif trackingAlone_opt.T1
                set( handles.T1PathButton, 'Enable', 'on');
                set( handles.PartitionTemplateEdit, 'Enable', 'on');
                set( handles.PartitionTemplateButton, 'Enable', 'on');
                set( handles.T1TemplateEdit, 'Enable', 'on');
                set( handles.T1TemplateButton, 'Enable', 'on');
                set( handles.T1TemplateText, 'Enable', 'on');
                set( handles.T1BetCheckbox, 'Enable', 'on');
                set( handles.BetFText, 'Enable', 'on');
                if trackingAlone_opt.T1Bet_Flag
                    set( handles.T1BetFEdit, 'Enable', 'on');
                end
                set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
                set( handles.T1CroppingGapText, 'Enable', 'on');
                if trackingAlone_opt.T1Cropping_Flag
                    set( handles.T1CroppingGapEdit, 'Enable', 'on');
                end
                set( handles.T1ResampleCheckbox, 'Enable', 'on');
                set( handles.T1ResampleResolutionText, 'Enable', 'on');
                if trackingAlone_opt.T1Resample_Flag
                    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
                end
            end
        end
        % Network construction
        set( handles.DeterministicNetworkCheck, 'Enable', 'on');
        set( handles.ProbabilisticNetworkCheck, 'Enable', 'on');
        set( handles.BedpostxAndProbabilisticCheck, 'Enable', 'on');
        % Pipeline options
        set( handles.batchRadio, 'Enable', 'on');
        set( handles.qsubRadio, 'Enable', 'on');
        if strcmp(TrackingPipeline_opt.mode, 'qsub')
            set( handles.QsubOptionsEdit, 'Enable', 'on');
        end
        set( handles.MaxQueuedEdit, 'Enable', 'on');
        set( handles.LogPathEdit, 'Enable', 'on');
        set( handles.LogPathButton, 'Enable', 'on');
        if ~isempty(JobStatusMonitorTimer_InTracking)
            stop(JobStatusMonitorTimer_InTracking);
            clear global JobStatusMonitorTimer_InTracking;
        end
        %
        if exist(ErrorFilePath, 'file')
            Info{1} = 'Something is wrong !';
            Info{2} = ['Please look up ' TrackingPipeline_opt.path_logs filesep ...
                       'tracking_pipeline.loginfo for more information !'];
            msgbox(Info);
            StopFlag_InTrackingStatus = '(Stopped)';
            delete(ErrorFilePath);
        end
        % 
        if exist(JobsFinishFilePath, 'file')
            delete(JobsFinishFilePath);
        end
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


% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


% --- Executes when PANDATrackingFigure is resized.
function PANDATrackingFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDATrackingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.PANDATrackingFigure, 'Position');
    ResizeSubjectFolderTable(handles);
    ResizeFAT1orParcellatedTable(handles);
    
    FontSizeT1OptionsUipanel = ceil(8 * PositionFigure(4) / 690);
    set( handles.T1OptionsUipanel, 'FontSize', FontSizeT1OptionsUipanel );
    FontSizeNetworkConstructionUipanel = ceil(8 * PositionFigure(4) / 630);
    set( handles.NetworkConstructionUipanel, 'FontSize', FontSizeNetworkConstructionUipanel );
    FontSizePipelineOptionsUipanel = ceil(8 * PositionFigure(4) / 630);
    set( handles.PipelineOptionsUipanel, 'FontSize', FontSizePipelineOptionsUipanel );
end

function ResizeSubjectFolderTable(handles)
SubjectFoldersID = get(handles.NativeFolderTable, 'data');
PositionFigure = get(handles.PANDATrackingFigure, 'Position');
WidthCell{1} = (PositionFigure(3) / 7) * 5;
WidthCell{2} = (PositionFigure(3) / 7) * 2;
if ~isempty(SubjectFoldersID)
    [rows, columns] = size(SubjectFoldersID);
    for i = 1:columns
        for j = 1:rows
            tmp_PANDA{j} = length(SubjectFoldersID{j, i}) * 8;
            tmp_PANDA{j} = tmp_PANDA{j} * PositionFigure(4) / 768;
        end
        NewWidthCell{i} = max(cell2mat(tmp_PANDA));
        if NewWidthCell{i} > WidthCell{i}
           WidthCell{i} =  NewWidthCell{i};
        end
    end
end
set(handles.NativeFolderTable, 'ColumnWidth', WidthCell);

function ResizeFAT1orParcellatedTable(handles)
FAT1orParcellated = get(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data');
PositionFigure = get(handles.PANDATrackingFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 2;
WidthCell{2} = WidthCell{1};
if ~isempty(FAT1orParcellated)
    [rows, columns] = size(FAT1orParcellated);
    for i = 1:columns
        for j = 1:rows
            tmp_PANDA{j} = length(FAT1orParcellated{j, i}) * 8;
            tmp_PANDA{j} = tmp_PANDA{j} * PositionFigure(4) / 768;
        end
        NewWidthCell{i} = max(cell2mat(tmp_PANDA));
        if NewWidthCell{i} > WidthCell{i}
           WidthCell{i} =  NewWidthCell{i};
        end
    end
end
set(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnWidth', WidthCell);


% % --- Executes on button press in SubjectFoldersListText.
% function SubjectFoldersListText_Callback(hObject, eventdata, handles)
% % hObject    handle to SubjectFoldersListText (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LocationTableText.
function LocationTableText_Callback(hObject, eventdata, handles)
% hObject    handle to LocationTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TrackingText.
function TrackingText_Callback(hObject, eventdata, handles)
% hObject    handle to TrackingText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NetworkText.
function NetworkText_Callback(hObject, eventdata, handles)
% hObject    handle to NetworkText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TitleText.
function TitleText_Callback(hObject, eventdata, handles)
% hObject    handle to TitleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % --- Executes on button press in ImageOrientationText.
% function ImageOrientationText_Callback(hObject, eventdata, handles)
% % hObject    handle to ImageOrientationText (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in MaxQueuedText.
function MaxQueuedText_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LogPathText.
function LogPathText_Callback(hObject, eventdata, handles)
% hObject    handle to LogPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function T1BetFEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1BetFEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1BetFEdit as text
%        str2double(get(hObject,'String')) returns contents of T1BetFEdit as a double
global trackingAlone_opt;
BetFString = get(hObject,'String');
trackingAlone_opt.T1BetF = str2num(BetFString);


% --- Executes during object creation, after setting all properties.
function T1BetFEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T1BetFEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


function T1CroppingGapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1CroppingGapEdit as text
%        str2double(get(hObject,'String')) returns contents of T1CroppingGapEdit as a double
global trackingAlone_opt;
T1CroppingGapString = get(hObject,'String');
trackingAlone_opt.T1CroppingGap = str2num(T1CroppingGapString);


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


% --- Executes on button press in T1CroppingGapCheckbox.
function T1CroppingGapCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1CroppingGapCheckbox
global trackingAlone_opt;
if get(hObject, 'Value')
    trackingAlone_opt.T1Cropping_Flag = 1;
    if isempty(trackingAlone_opt.T1CroppingGap)
        trackingAlone_opt.T1CroppingGap = 3;
    end
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'String', num2str(trackingAlone_opt.T1CroppingGap));
else
    trackingAlone_opt.T1Cropping_Flag = 0;
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
end


% --- Executes on button press in T1ResampleCheckbox.
function T1ResampleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to T1ResampleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1ResampleCheckbox
global trackingAlone_opt;
if get(hObject, 'Value')
    trackingAlone_opt.T1Resample_Flag = 1;
    if isempty(trackingAlone_opt.T1ResampleResolution)
        trackingAlone_opt.T1ResampleResolution = [1 1 1];
    end
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'String', mat2str(trackingAlone_opt.T1ResampleResolution));
else
    trackingAlone_opt.T1Resample_Flag = 0;
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
end


function T1ResampleResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1ResampleResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1ResampleResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of T1ResampleResolutionEdit as a double
global trackingAlone_opt;
ResolutionString = get(hObject, 'String');
trackingAlone_opt.T1ResampleResolution = eval(ResolutionString);


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



function RandomSeedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RandomSeedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RandomSeedEdit as text
%        str2double(get(hObject,'String')) returns contents of RandomSeedEdit as a double
global trackingAlone_opt;
RandomSeedString = get(hObject, 'string');
trackingAlone_opt.RandomSeed = str2num(RandomSeedString);


% --- Executes during object creation, after setting all properties.
function RandomSeedEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RandomSeedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in RandomSeedCheckbox.
function RandomSeedCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to RandomSeedCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RandomSeedCheckbox
global trackingAlone_opt;
if get(hObject, 'Value')
    trackingAlone_opt.RandomSeed_Flag = 1;
    set( handles.RandomSeedText, 'Enable', 'on');
    set( handles.RandomSeedEdit, 'Enable', 'on')
    trackingAlone_opt.RandomSeed = 1;
    set( handles.RandomSeedEdit, 'String', '1');
else
    trackingAlone_opt.RandomSeed_Flag = 0;
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
end


function SubjectIDEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubjectIDEdit as text
%        str2double(get(hObject,'String')) returns contents of SubjectIDEdit as a double
global SubjectIDArrayTracking;
global NativePathCellTracking;
SubjectIDString = get(hObject, 'String');
if ~isempty(SubjectIDString)
    try
        SubjectIDArrayTracking = eval(SubjectIDString);
        if length(SubjectIDArrayTracking) ~= length(NativePathCellTracking)
            msgbox('The quantity of subject folders is not equal to the quantity of subject IDs.');
            set(hObject, 'String', '');
        else
            set(hObject, 'String', mat2str(SubjectIDArrayTracking));
            for i = 1:length(SubjectIDArrayTracking)
                SubjectIDArrayCell{i} = num2str(SubjectIDArrayTracking(i), '%05d');
            end
            SubjectIDArrayCell = reshape(SubjectIDArrayCell, length(SubjectIDArrayCell), 1);
            SubjectFolderTable = [NativePathCellTracking SubjectIDArrayCell];
            set(handles.NativeFolderTable, 'data', SubjectFolderTable);
            ResizeSubjectFolderTable(handles);
        end
    catch
        msgbox('The input is illegal.');
    end
else
    SubjectFolderTable = NativePathCellTracking;
    set(handles.NativeFolderTable, 'data', SubjectFolderTable);
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


% --- Executes on button press in SubjectIDLoadButton.
function SubjectIDLoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectIDLoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SubjectIDArrayTracking;
global NativePathCellTracking;
if isempty(NativePathCellTracking)
    msgbox('Please input subjects'' folders first.');
else
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA','PANDA-files (*.PANDA)'},'Load Configuration');
    if ParameterSaveFileName
        cmdString = ['tmp_PANDA = load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'');'];
        eval( cmdString );
        SubjectIDArrayTmp = tmp_PANDA.SubjectIDArray;
        if length(SubjectIDArrayTmp) ~= length(NativePathCellTracking)
            msgbox('The quantity of subject folders is not equal to the quantity of subject IDs.');
        else
            SubjectIDArrayTrackingStr = mat2str(SubjectIDArrayTracking);
            set( handles.SubjectIDEdit, 'String', SubjectIDArrayTrackingStr);
            SubjectIDArrayTracking = SubjectIDArrayTmp;
            for i = 1:length(SubjectIDArrayTracking)
                SubjectIDArrayCell{i} = num2str(SubjectIDArrayTracking(i), '%05d');
            end
            SubjectIDArrayCell = reshape(SubjectIDArrayCell, length(SubjectIDArrayCell), 1);
            SubjectFolderTable = [NativePathCellTracking SubjectIDArrayCell];
            set(handles.NativeFolderTable, 'data', SubjectFolderTable);
            ResizeSubjectFolderTable(handles);
        end
    end
end


% --- Executes on key press with focus on SubjectIDLoadButton and none of its controls.
function SubjectIDLoadButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SubjectIDLoadButton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on SubjectIDEdit and none of its controls.
function SubjectIDEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global NativePathCellTracking;
if isempty(NativePathCellTracking)
    msgbox('Please input subjects'' folders first.');
    set(hObject, 'String', '');
end


% --------------------------------------------------------------------
function NativeFolderTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to NativeFolderTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% FolderPathId = get(hObject, 'data');
% OrigineWidthCell = get(hObject, 'ColumnWidth');
% if ~isempty(FolderPathId)
%     NewWidthCell = OrigineWidthCell;
%     [rows, columns] = size(FolderPathId);
%     for i = 1:columns
%         for j = 1:rows
%             if NewWidthCell{i} < length(FolderPathId{j, i}) * 7.8
%                 NewWidthCell{i} = length(FolderPathId{j, i}) * 7.8;
%             end
%         end
%     end
%     set( handles.NativeFolderTable, 'ColumnWidth', NewWidthCell);
% end


% --------------------------------------------------------------------
function FAPath_T1orPartitionOfSubjectsPathTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FAPath_T1orPartitionOfSubjectsPathTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% FAPathParcellatedT1Path = get(hObject, 'data');
% OrigineWidthCell = get(hObject, 'ColumnWidth');
% if ~isempty(FAPathParcellatedT1Path)
%     NewWidthCell = OrigineWidthCell;
%     [rows, columns] = size(FAPathParcellatedT1Path);
%     for i = 1:columns
%         for j = 1:rows
%             if NewWidthCell{i} < length(FAPathParcellatedT1Path{j, i}) * 7.8
%                 NewWidthCell{i} = length(FAPathParcellatedT1Path{j, i}) * 7.8;
%             end
%         end
%     end
%     set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnWidth', NewWidthCell);
% end


% --- Executes on button press in T1BetCheckbox.
function T1BetCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to T1BetCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1BetCheckbox
global trackingAlone_opt;
if get(hObject, 'Value')
    trackingAlone_opt.T1Bet_Flag = 1;
    if isempty(trackingAlone_opt.T1BetF)
        trackingAlone_opt.T1BetF = 0.5;
    end
    set( handles.T1BetFEdit, 'Enable', 'on');
    set( handles.T1BetFEdit, 'String', num2str(trackingAlone_opt.T1BetF));
else
    trackingAlone_opt.T1Bet_Flag = 0;
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off');
end


% --- Executes on button press in LogsButton.
function LogsButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TrackingPipeline_opt;

LogsPath = '';
if isempty(TrackingPipeline_opt)
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_Tracking','PANDA-files (*.PANDA_Tracking)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        cmdString = ['PANDAConfiguration = load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        LogsPath = PANDAConfiguration.TrackingPipeline_opt.path_logs;    
    end
else
    LogsPath = TrackingPipeline_opt.path_logs;
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


% --- Executes when selected cell(s) is changed in FAPath_T1orPartitionOfSubjectsPathTable.
function FAPath_T1orPartitionOfSubjectsPathTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to FAPath_T1orPartitionOfSubjectsPathTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)



function T1TemplateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1TemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1TemplateEdit as text
%        str2double(get(hObject,'String')) returns contents of T1TemplateEdit as a double
global trackingAlone_opt;
T1TemplatePath = get( handles.T1TemplateEdit, 'string' );
trackingAlone_opt.T1Template = T1TemplatePath;

% --- Executes during object creation, after setting all properties.
function T1TemplateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T1TemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in T1TemplateButton.
function T1TemplateButton_Callback(hObject, eventdata, handles)
% hObject    handle to T1TemplateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackingAlone_opt;
[T1TemplateName,T1TemplateParent] = uigetfile({'*.nii;*.nii.gz','NIfTI-files (*.nii, *nii.gz)'});
T1TemplatePath = [T1TemplateParent T1TemplateName];
if T1TemplateParent ~= 0
    set( handles.T1TemplateEdit, 'string', T1TemplatePath );
    trackingAlone_opt.T1Template = T1TemplatePath;
end
