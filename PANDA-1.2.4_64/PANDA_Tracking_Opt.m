function varargout = PANDA_Tracking_Opt(varargin)
% GUI for Tracking_Opt (part of PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_TRACKING_OPT MATLAB code for PANDA_Tracking_Opt.fig
%      PANDA_TRACKING_OPT, by itself, creates a new PANDA_TRACKING_OPT or raises the existing
%      singleton*.
%
%      H = PANDA_TRACKING_OPT returns the handle to a new PANDA_TRACKING_OPT or the handle to
%      the existing singleton*.
%
%      PANDA_TRACKING_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_TRACKING_OPT.M with the given input arguments.
%
%      PANDA_TRACKING_OPT('Property','Value',...) creates a new PANDA_TRACKING_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Tracking_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Tracking_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Tracking_Opt

% Last Modified by GUIDE v2.5 02-Nov-2012 12:13:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Tracking_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Tracking_Opt_OutputFcn, ...
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


% --- Executes just before PANDA_Tracking_Opt is made visible.
function PANDA_Tracking_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Tracking_Opt (see VARARGIN)

% Choose default command line output for PANDA_Tracking_Opt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_Tracking_Opt wait for user response (see UIRESUME)
% uiwait(handles.TrackingFigure);
global tracking_opt;
global DestinationPath_Edit;
global SubjectIDArray;
global FAPathCellMain;
global TensorPrefixEdit;
global LockFlagMain;
global T1orPartitionOfSubjectsPathCellMain;
global PANDAPath;
global TrackingOpt_ParametersChangeFlag;

% tracking_opt.DeterminTrackingOptionChange = 0;
TrackingOpt_ParametersChangeFlag = 0;

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
    set( handles.RandomSeedCheckbox, 'Enable', 'off');
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'Enable', 'off');
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
    if tracking_opt.RandomSeed_Flag 
        set(handles.RandomSeedCheckbox, 'Value', 1);
        set(handles.RandomSeedEdit, 'String', num2str(tracking_opt.RandomSeed));
    else
        set(handles.RandomSeedCheckbox, 'Value', 0);
        set(handles.RandomSeedEdit, 'Enable', 'off');
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off');
    set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
    set( handles.T1PathButton, 'Enable', 'off');
    set( handles.PartitionTemplateText, 'Enable', 'off'); 
    set( handles.PartitionTemplateEdit, 'String', '');
    set( handles.PartitionTemplateEdit, 'Enable', 'off'); 
    set( handles.PartitionTemplateButton, 'Enable', 'off');
    set( handles.T1BetCheckbox, 'Enable', 'off'); 
    set( handles.T1BetFText, 'Enable', 'off');
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off'); 
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
    set( handles.T1CroppingGapText, 'Enable', 'off'); 
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%     set( handles.T1CroppingGapUnitText, 'Enable', 'off');
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionText, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
elseif tracking_opt.NetworkNode == 1;
    set( handles.NetworkNodeCheck, 'value', 1.0);
    set( handles.LocationTableText, 'Enable', 'on' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on');    
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
        set( handles.T1BetCheckbox, 'Enable', 'off');
        set( handles.T1BetFText, 'Enable', 'off');
        set( handles.T1BetFEdit, 'String', '');
        set( handles.T1BetFEdit, 'Enable', 'off'); 
        set( handles.T1CroppingGapCheckbox, 'Enable', 'off'); 
        set( handles.T1CroppingGapText, 'Enable', 'off'); 
        set( handles.T1CroppingGapEdit, 'String', '');
        set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
%         set( handles.T1CroppingGapUnitText, 'Enable', 'off'); 
        set( handles.T1ResampleCheckbox, 'Enable', 'off');
        set( handles.T1ResampleResolutionText, 'Enable', 'off');
        set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
    else
        ColumnName{2} = 'Path of T1';
        set( handles.T1Check, 'Value', 1.0 );
        set( handles.PartitionOfSubjectsCheck, 'Value', 0.0 );
        set( handles.T1PathButton, 'Enable', 'on');
        set( handles.PartitionTemplateText, 'Enable', 'on');
        set( handles.PartitionTemplateEdit, 'Enable', 'on');
        set( handles.PartitionTemplateButton, 'Enable', 'on');
        if ~isfield( tracking_opt, 'PartitionTemplate')
            tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
        end
        set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate); 
        if ~isfield(tracking_opt, 'T1Bet_Flag')
            tracking_opt.T1Bet_Flag = 1;
        end
        set( handles.T1BetCheckbox, 'Enable', 'on'); 
        set( handles.T1BetCheckbox, 'Value', tracking_opt.T1Bet_Flag);
        if tracking_opt.T1Bet_Flag
            if ~isfield(tracking_opt, 'T1BetF')
                tracking_opt.T1BetF = 0.5;
            end
            set( handles.T1BetFEdit, 'Enable', 'on'); 
            set( handles.T1BetFEdit, 'String', num2str(tracking_opt.T1BetF)); 
        else
            set( handles.T1BetFEdit, 'String', ''); 
            set( handles.T1BetFEdit, 'Enable', 'off'); 
        end
        if ~isfield(tracking_opt, 'T1Cropping_Flag')
            tracking_opt.T1Cropping_Flag = 1;
        end
        set( handles.T1CroppingGapCheckbox, 'Enable', 'on'); 
        set( handles.T1CroppingGapCheckbox, 'Value', tracking_opt.T1Cropping_Flag);
        if tracking_opt.T1Cropping_Flag
            if ~isfield(tracking_opt, 'T1CroppingGap')
                tracking_opt.T1CroppingGap = 3;
            end
            set( handles.T1CroppingGapEdit, 'Enable', 'on'); 
            set( handles.T1CroppingGapEdit, 'String', num2str(tracking_opt.T1CroppingGap));
        else
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off'); 
        end
        if ~isfield(tracking_opt, 'T1Resample_Flag')
            tracking_opt.T1Resample_Flag = 1;
        end
        set( handles.T1ResampleCheckbox, 'Enable', 'on'); 
        set( handles.T1ResampleCheckbox, 'Value', tracking_opt.T1Resample_Flag);
        if tracking_opt.T1Resample_Flag
            if ~isfield(tracking_opt, 'T1ResampleResolution')
                tracking_opt.T1ResampleResolution = [1 1 1];
            end
            set( handles.T1ResampleResolutionText, 'Enable', 'on');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'on'); 
            set( handles.T1ResampleResolutionEdit, 'String', mat2str(tracking_opt.T1ResampleResolution));
        else
            set( handles.T1ResampleResolutionEdit, 'String', '');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off'); 
        end
    end
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
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
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );  
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
    set( handles.RandomSeedCheckbox, 'Enable', 'off' );
    set( handles.RandomSeedEdit, 'Enable', 'off' );
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
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.T1BetFEdit, 'Enable', 'off'); 
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
    LockFlagMain = 1;
else
    LockFlagMain = 0;
end

%
TipStr = sprintf(['When having subjects'' parcellated images in native space,' ...
    '\n please click this.']);
set(handles.PartitionOfSubjectsCheck, 'TooltipString', TipStr);
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

        
% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Tracking_Opt_OutputFcn(hObject, eventdata, handles) 
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
global TrackingOpt_ParametersChangeFlag;
ImageOrientation_Previous = tracking_opt.ImageOrientation;
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
if ~strcmp(ImageOrientation_Previous, tracking_opt.ImageOrientation)
    TrackingOpt_ParametersChangeFlag = 1;
%     tracking_opt.DeterminTrackingOptionChange = 1;
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
global TrackingOpt_ParametersChangeFlag;
PropagationAlgorithm_Previous = tracking_opt.PropagationAlgorithm;
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
if ~strcmp(PropagationAlgorithm_Previous, tracking_opt.PropagationAlgorithm)
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;
StepLength_Previous = tracking_opt.StepLength;
StepLengthString = get(hObject, 'string');
tracking_opt.StepLength = str2double(StepLengthString);
if StepLength_Previous ~= tracking_opt.StepLength
    TrackingOpt_ParametersChangeFlag = 1;
end


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
global TrackingOpt_ParametersChangeFlag;
AngleThreshold_Previous = tracking_opt.AngleThreshold;
tracking_opt.AngleThreshold = get(hObject, 'string');
if ~strcmp(AngleThreshold_Previous, tracking_opt.AngleThreshold)
    TrackingOpt_ParametersChangeFlag = 1;
end



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
global TrackingOpt_ParametersChangeFlag;
MaskThresMin_Previous = tracking_opt.MaskThresMin;
MaskThresMinString = get(hObject, 'string'); 
if isempty(MaskThresMinString)
    tracking_opt.MaskThresMin = [];
else
    tracking_opt.MaskThresMin = str2double(MaskThresMinString);
end
if MaskThresMin_Previous ~= tracking_opt.MaskThresMin
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;
MaskThresMax_Previous = tracking_opt.MaskThresMax;
MaskThresMaxString = get(hObject, 'string');
if isempty(MaskThresMaxString)
    tracking_opt.MaskThresMax = [];
else
    tracking_opt.MaskThresMax = str2double(MaskThresMaxString);
end
if MaskThresMax_Previous ~= tracking_opt.MaskThresMax
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;
Inversion_Previous = tracking_opt.Inversion;
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
if ~strcmp(Inversion_Previous, tracking_opt.Inversion)
    TrackingOpt_ParametersChangeFlag = 1;
%     tracking_opt.DeterminTrackingOptionChange = 1;
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
global TrackingOpt_ParametersChangeFlag;
Swap_Previous = tracking_opt.Swap;
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
if ~strcmp(Swap_Previous, tracking_opt.Swap)
    TrackingOpt_ParametersChangeFlag = 1;
%     tracking_opt.DeterminTrackingOptionChange = 1;
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
global TrackingOpt_ParametersChangeFlag;
ApplySplineFilter_Previous = tracking_opt.ApplySplineFilter;
if get(hObject, 'value')
    tracking_opt.ApplySplineFilter = 'Yes';
else
    tracking_opt.ApplySplineFilter = 'No';
end
if ~strcmp(ApplySplineFilter_Previous, tracking_opt.ApplySplineFilter)
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;
NetworkNode_Previous = tracking_opt.NetworkNode;
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
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on' );
        set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
        ColumnName{1} = 'Path of FA';
        ColumnName{2} = 'Path of parcellated images';
        set(handles.PartitionTemplateEdit, 'String', '');
        set(handles.PartitionTemplateEdit, 'Enable', 'off');
        set(handles.PartitionTemplateButton, 'Enable', 'off');
        set( handles.PartitionTemplateText, 'Enable', 'off');
        set( handles.T1BetCheckbox, 'Enable', 'off');
        set( handles.T1BetFText, 'Enable', 'off');
        set( handles.T1BetFEdit, 'String', '');
        set( handles.T1BetFEdit, 'Enable', 'off');
        set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
        set( handles.T1CroppingGapText, 'Enable', 'off');
        set( handles.T1CroppingGapEdit, 'String', '');
        set( handles.T1CroppingGapEdit, 'Enable', 'off');
%         set( handles.T1CroppingGapUnitText, 'Enable', 'off');
        set( handles.T1ResampleCheckbox, 'Enable', 'off');
        set( handles.T1ResampleResolutionText, 'Enable', 'off');
        set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
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
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', DataCell );
    ResizeFAT1orParcellatedTable(handles);
    set( handles.LocationTableText, 'Enable', 'off' );
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'off' );
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
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.T1BetFText, 'Enable', 'off');
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off');
    set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
    set( handles.T1CroppingGapText, 'Enable', 'off');
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
%     set( handles.T1CroppingGapUnitText, 'Enable', 'off'); 
    set( handles.T1ResampleCheckbox, 'Enable', 'off');
    set( handles.T1ResampleResolutionText, 'Enable', 'off');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
end
if NetworkNode_Previous ~= tracking_opt.NetworkNode
    TrackingOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in T1PathButton.
function T1PathButton_Callback(hObject, eventdata, handles)
% hObject    handle to T1PathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FAPathCellMain;
global T1orPartitionOfSubjectsPathCellMain;
T1orPartitionOfSubjectsPathCell_Button = get(hObject, 'UserData');
[x, T1orPartitionOfSubjectsPathCellMain, Done] = PANDA_Select('img', T1orPartitionOfSubjectsPathCell_Button);
if Done == 1 & ~isempty(T1orPartitionOfSubjectsPathCellMain)
    set(hObject, 'UserData', T1orPartitionOfSubjectsPathCellMain);
    if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
        T1orPartitionOfSubjectsPathCellMain = '';
        msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
    else
        FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
        ResizeFAT1orParcellatedTable(handles);
    end
end


function PartitionTemplateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PartitionTemplateEdit as text
%        str2double(get(hObject,'String')) returns contents of PartitionTemplateEdit as a double
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
PartitionTemplate_Previous = tracking_opt.PartitionTemplate;
PartitionTemplatePath = get( handles.PartitionTemplateEdit, 'string' );
tracking_opt.PartitionTemplate = PartitionTemplatePath;
if ~strcmp(PartitionTemplate_Previous, tracking_opt.PartitionTemplate)
    TrackingOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function PartitionTemplateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in PartitionTemplateButton.
function PartitionTemplateButton_Callback(hObject, eventdata, handles)
% hObject    handle to PartitionTemplateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
PartitionTemplate_Previous = tracking_opt.PartitionTemplate;
[PartitionTemplateName,PartitionTemplateParent] = uigetfile({'*.nii;*.nii.gz','NIfTI-files (*.nii, *nii.gz)'});
PartitionTemplatePath = [PartitionTemplateParent PartitionTemplateName];
if PartitionTemplateParent ~= 0
    set( handles.PartitionTemplateEdit, 'string', PartitionTemplatePath );
    tracking_opt.PartitionTemplate = PartitionTemplatePath;
end
if strcmp(PartitionTemplate_Previous, tracking_opt.PartitionTemplate)
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;

FiberTrackingInputFinish = 0;
NetworkNodeInputFinish = 0;
BedpostxProbabilisticNetworkFinish = 0;
info_quantity = 0;
Finish = 1;
% In this situation, PANDA_Tracking_Opt is open from panda
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
        elseif tracking_opt.RandomSeed_Flag & isempty(tracking_opt.RandomSeed)
            msgbox('Please input the random seed !');
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
            elseif isempty(tracking_opt.T1BetF)
                msgbox('Please input f(skull_removal) for T1 brain extraction.');
            elseif tracking_opt.T1Cropping_Flag
                if isempty(tracking_opt.T1CroppingGap)
                    msgbox('Please input the cropping gap for cropping T1 image.');
                elseif tracking_opt.T1Resample_Flag
                    if isempty(tracking_opt.T1ResampleResolution)
                        msgbox('Please input the resolution for resampling T1 image.');
                    else
                        NetworkNodeInputFinish = 1;
                    end
                end
            elseif tracking_opt.T1Resample_Flag
                if isempty(tracking_opt.T1ResampleResolution)
                    msgbox('Please input the resolution for resampling T1 image.');
                else
                    NetworkNodeInputFinish = 1;
                end
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
    
    Finish = 1;
    if (tracking_opt.DterminFiberTracking & ~FiberTrackingInputFinish) | ...
            (tracking_opt.NetworkNode & ~NetworkNodeInputFinish) | ...
            (tracking_opt.BedpostxProbabilisticNetwork & ~BedpostxProbabilisticNetworkFinish)
        Finish = 0;
    end
    
    if TrackingOpt_ParametersChangeFlag
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
            if tracking_opt.RandomSeed_Flag
                info_quantity = info_quantity + 1;
                Check_info{info_quantity} = ['Random Seed = ' num2str(tracking_opt.RandomSeed)];
            end
        end
        if NetworkNodeInputFinish 
            info_quantity = info_quantity + 1;
            Check_info{info_quantity} = 'Network Node Definition = 1';
            if tracking_opt.T1
                info_quantity = info_quantity + 1;
                Check_info{info_quantity} = ['Atlas (standard space) Path = ' tracking_opt.PartitionTemplate];
                info_quantity = info_quantity + 1;
                Check_info{info_quantity} = ['f(skull_removal) = ' num2str(tracking_opt.T1BetF)];
                if tracking_opt.T1Cropping_Flag
                    info_quantity = info_quantity + 1;
                    Check_info{info_quantity} = ['Cropping gap = ' num2str(tracking_opt.T1CroppingGap)];
                end
                if tracking_opt.T1Resample_Flag
                    info_quantity = info_quantity + 1;
                    Check_info{info_quantity} = ['Resample resolution = ' mat2str(tracking_opt.T1ResampleResolution)];
                end
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
        elseif Finish
            close;
        end
    elseif Finish 
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
T1orPartitionOfSubjectsPathCell_Button = get(hObject, 'UserData');
[x, T1orPartitionOfSubjectsPathCellMain, Done] = PANDA_Select('img', T1orPartitionOfSubjectsPathCell_Button);
if Done == 1 & ~isempty(T1orPartitionOfSubjectsPathCellMain)
    set(hObject, 'UserData', T1orPartitionOfSubjectsPathCellMain);
    if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
        T1orPartitionOfSubjectsPathCellMain = '';
        msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
    else
        FAPath_T1orPartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
        set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
        ResizeFAT1orParcellatedTable(handles);
    end
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
global TrackingOpt_ParametersChangeFlag;
PartitionOfSubjects_Previous = tracking_opt.PartitionOfSubjects;
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
    set( handles.T1BetCheckbox, 'Value', 0);
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.T1BetFText, 'Enable', 'off');
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath, 'ColumnName', ColumnName);
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
    tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
    set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);
    set( handles.T1BetCheckbox, 'Enable', 'on');
    tracking_opt.T1Bet_Flag = 1;
    set( handles.T1BetCheckbox, 'Value', 1);
    set( handles.T1BetFText, 'Enable', 'on');
    set( handles.T1BetFEdit, 'Enable', 'on');
    tracking_opt.T1BetF = 0.5;
    set( handles.T1BetFEdit, 'String', '0.5');
    set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
    tracking_opt.T1Cropping_Flag = 1;
    set( handles.T1CroppingGapCheckbox, 'Value', 1);
    set( handles.T1CroppingGapText, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    tracking_opt.T1CroppingGap = 3;
    set( handles.T1CroppingGapEdit, 'String', '3');
%     set( handles.T1CroppingGapUnitText, 'Enable', 'on'); 
    tracking_opt.T1Resample_Flag = 1;
    set( handles.T1ResampleCheckbox, 'Value', 1);
    set( handles.T1ResampleResolutionText, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    tracking_opt.T1ResampleResolution = [1 1 1];
    set( handles.T1ResampleResolutionEdit, 'String', '[1 1 1]');
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath, 'ColumnName', ColumnName );
    ResizeFAT1orParcellatedTable(handles);
end
if PartitionOfSubjects_Previous ~= tracking_opt.PartitionOfSubjects
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;
T1_Previous = tracking_opt.T1;
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
    set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);
    set( handles.T1BetCheckbox, 'Enable', 'on');
    tracking_opt.T1Bet_Flag = 1;
    set( handles.T1BetCheckbox, 'Value', 1);
    set( handles.T1BetFText, 'Enable', 'on');
    set( handles.T1BetFEdit, 'Enable', 'on');
    tracking_opt.T1BetF = 0.5;
    set( handles.T1BetFEdit, 'String', '0.5');
    set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
    tracking_opt.T1Cropping_Flag = 1;
    set( handles.T1CroppingGapCheckbox, 'Value', 1);
    set( handles.T1CroppingGapText, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    tracking_opt.T1CroppingGap = 3;
    set( handles.T1CroppingGapEdit, 'String', '3');
%     set( handles.T1CroppingGapUnitText, 'Enable', 'on'); 
    tracking_opt.T1Resample_Flag = 1;
    set( handles.T1ResampleCheckbox, 'Value', 1);
    set( handles.T1ResampleCheckbox, 'Enable', 'on');
    set( handles.T1ResampleResolutionText, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    tracking_opt.T1ResampleResolution = [1 1 1];
    set( handles.T1ResampleResolutionEdit, 'String', '[1 1 1]');
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
%     clear global T1orPartitionOfSubjectsPathCellMain;
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
    set( handles.T1BetCheckbox, 'Value', 0);
    set( handles.T1BetCheckbox, 'Enable', 'off');
    set( handles.T1BetFText, 'Enable', 'off');
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
    set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath );
    ResizeFAT1orParcellatedTable(handles);
%     clear global T1orPartitionOfSubjectsPathCellMain;
end
if T1_Previous ~= tracking_opt.T1
    TrackingOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in FiberTrackingCheck.
function FiberTrackingCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FiberTrackingCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FiberTrackingCheck
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
DeterminFiberTracking_Previous = tracking_opt.DterminFiberTracking;
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
    tracking_opt.RandomSeed_Flag = 0;
    set( handles.RandomSeedCheckbox, 'Enable', 'on');
    set( handles.RandomSeedCheckbox, 'Value', 0);
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
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
    set( handles.RandomSeedCheckbox, 'Value', 0);
    set( handles.RandomSeedCheckbox, 'Enable', 'off');
    set( handles.RandomSeedText, 'Enable', 'off');
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
end
if DeterminFiberTracking_Previous ~= tracking_opt.DterminFiberTracking
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;

DeterministicNetwork_Previous = tracking_opt.DeterministicNetwork;
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
            tracking_opt.RandomSeed_Flag = 0;
            set( handles.RandomSeedCheckbox, 'Value', 0);
            set( handles.RandomSeedCheckbox, 'Enable', 'on');
            set( handles.RandomSeedText, 'Enable', 'off');
            set( handles.RandomSeedEdit, 'String', '');
            set( handles.RandomSeedEdit, 'Enable', 'off');
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
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'Enable', 'on' );
            set( handles.PartitionOfSubjectsButton, 'Enable', 'on' );
            ColumnName{1} = 'Path of FA';
            ColumnName{2} = 'Path of parcellated images';
            set(handles.PartitionTemplateEdit, 'String', '');
            set(handles.PartitionTemplateEdit, 'Enable', 'off');
            set(handles.PartitionTemplateButton, 'Enable', 'off');
            set( handles.PartitionTemplateText, 'Enable', 'off');
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnName', ColumnName );
            set( handles.T1BetCheckbox, 'Enable', 'off');
            set( handles.T1BetFText, 'Enable', 'off');
            set( handles.T1BetFEdit, 'String', '');
            set( handles.T1BetFEdit, 'Enable', 'off');
            set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
            set( handles.T1CroppingGapText, 'Enable', 'off');
            set( handles.T1CroppingGapEdit, 'String', '');
            set( handles.T1CroppingGapEdit, 'Enable', 'off');
%             set( handles.T1CroppingGapUnitText, 'Enable', 'off'); 
            set( handles.T1ResampleCheckbox, 'Enable', 'off');
            set( handles.T1ResampleResolutionText, 'Enable', 'off');
            set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
            FAPathCellMain = cell(length(SubjectIDArray),1);
            for i = 1:length(SubjectIDArray)
                FAPathCellMain{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f') filesep 'native_space' filesep TensorPrefixEdit '_' num2str(SubjectIDArray(i),'%05.0f') '_' 'FA.nii.gz'];
            end
            FAPath_T1orPartitionOfSubjectsPath = FAPathCellMain;
            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1orPartitionOfSubjectsPath ); 
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
                set( handles.T1BetCheckbox, 'Enable', 'off');
                set( handles.T1BetFText, 'Enable', 'off');
                set( handles.T1BetFEdit, 'String', '');
                set( handles.T1BetFEdit, 'Enable', 'off');
                set( handles.T1CroppingGapCheckbox, 'Enable', 'off');
                set( handles.T1CroppingGapText, 'Enable', 'off');
                set( handles.T1CroppingGapEdit, 'String', '');
                set( handles.T1CroppingGapEdit, 'Enable', 'off');
%                 set( handles.T1CroppingGapUnitText, 'Enable', 'off'); 
                set( handles.T1ResampleCheckbox, 'Enable', 'off');
                set( handles.T1ResampleResolutionText, 'Enable', 'off');
                set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
                if tracking_opt.DterminFiberTracking && tracking_opt.NetworkNode 
%                         && isempty(T1orPartitionOfSubjectsPathCellMain) 
                    PartitionInfo{1} = 'Then, you should select parcellated image (native space) for each subject according to FA path in the table';
                    PartitionInfo{2} = 'Are you sure?';
                    PartitionButton = questdlg( PartitionInfo ,'Sure ?','Yes','No','Yes' );
                    if strcmp(PartitionButton, 'Yes')
                        [x,T1orPartitionOfSubjectsPathCellMain] = PANDA_Select('img');
                        if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
                            T1orPartitionOfSubjectsPathCellMain = '';
                            msgbox('The quantity of FA images is not equal to the quantity of parcellated images (native space)!');
                        else
                            FAPath_PartitionOfSubjectsPath = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
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
                set( handles.PartitionOfSubjectsCheck, 'Value', 0 );
                set( handles.PartitionTemplateEdit, 'Enable', 'on');
                set( handles.PartitionTemplateButton, 'Enable', 'on');
                set( handles.PartitionTemplateText, 'Enable', 'on');
                set( handles.T1PathButton, 'Enable', 'on');
                set( handles.PartitionOfSubjectsButton, 'Enable', 'off');
                tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
                set( handles.PartitionTemplateEdit, 'String', tracking_opt.PartitionTemplate);
                set( handles.T1BetCheckbox, 'Enable', 'on');
                tracking_opt.T1Bet_Flag = 1;
                set( handles.T1BetCheckbox, 'Value', 1);
                set( handles.T1BetFText, 'Enable', 'on');
                set( handles.T1BetFEdit, 'Enable', 'on');
                tracking_opt.T1BetF = 0.5;
                set( handles.T1BetFEdit, 'String', '0.5');
                set( handles.T1CroppingGapCheckbox, 'Enable', 'on');
                tracking_opt.T1Cropping_Flag = 1;
                set( handles.T1CroppingGapCheckbox, 'Value', 1);
                set( handles.T1CroppingGapText, 'Enable', 'on');
                set( handles.T1CroppingGapEdit, 'Enable', 'on');
                tracking_opt.T1CroppingGap = 3;
                set( handles.T1CroppingGapEdit, 'String', '3');
%                 set( handles.T1CroppingGapUnitText, 'Enable', 'on'); 
                tracking_opt.T1Resample_Flag = 1;
                set( handles.T1ResampleCheckbox, 'Value', 1);
                set( handles.T1ResampleResolutionText, 'Enable', 'on');
                set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
                tracking_opt.T1ResampleResolution = [1 1 1];
                set( handles.T1ResampleResolutionEdit, 'String', '[1 1 1]');
                if tracking_opt.DterminFiberTracking && tracking_opt.NetworkNode 
%                         && isempty(T1orPartitionOfSubjectsPathCellMain) 
                    T1Info{1} = 'Then, you should select T1 for each subject according to FA path in the table';
                    T1Info{2} = 'Are you sure?';
                    button = questdlg( T1Info ,'Sure ?','Yes','No','Yes' );
                    if strcmp(button, 'Yes')
                        [x, T1orPartitionOfSubjectsPathCellMain] = PANDA_Select('img');
                        if length(FAPathCellMain) ~= length(T1orPartitionOfSubjectsPathCellMain)
                            T1orPartitionOfSubjectsPathCellMain = '';
                            msgbox('The quantity of FA images is not equal to the quantity of T1 images!');
                        else
                            FAPath_T1Path = [FAPathCellMain T1orPartitionOfSubjectsPathCellMain];
                            set( handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data', FAPath_T1Path );
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
if DeterministicNetwork_Previous ~= tracking_opt.DeterministicNetwork
    TrackingOpt_ParametersChangeFlag = 1;
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
global TrackingOpt_ParametersChangeFlag;
BedpostxProbabilisticNetwork_Previous = tracking_opt.BedpostxProbabilisticNetwork;
if get(hObject,'Value')
    % If open alone, native folder input should be available
    % Make Fiber PANDA_Tracking_Opt unavaliable
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
        [BedpostxAndProbabilisticOpenId, Bedpostx_opt, ProbabilisticTracking_opt, BedpostxAndProbabilisticOK] = PANDA_BedpostxAndProbabilistic_Opt;
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
if BedpostxProbabilisticNetwork_Previous ~= tracking_opt.BedpostxProbabilisticNetwork
    TrackingOpt_ParametersChangeFlag = 1;
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
    
    FontSizeT1OptionsUipanel = fix(8 * PositionFigure(4) / 479);
    set( handles.T1OptionsUipanel, 'FontSize', FontSizeT1OptionsUipanel );
    FontSizeNetworkConstructionUipanel = fix(8 * PositionFigure(4) / 400);
    set( handles.NetworkConstructionUipanel, 'FontSize', FontSizeNetworkConstructionUipanel );
%     end
end


function ResizeFAT1orParcellatedTable(handles)
FAT1orParcellated = get(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'data');
PositionFigure = get(handles.TrackingFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 2;
WidthCell{2} = WidthCell{1};
if ~isempty(FAT1orParcellated)
    [rows, columns] = size(FAT1orParcellated);
    for i = 1:columns
        for j = 1:rows
            tmp{j} = length(FAT1orParcellated{j, i}) * 8;
            tmp{j} = tmp{j} * PositionFigure(4) / 550;
        end
        NewWidthCell{i} = max(cell2mat(tmp));
        if NewWidthCell{i} > WidthCell{i}
           WidthCell{i} =  NewWidthCell{i};
        end
    end
end
set(handles.FAPath_T1orPartitionOfSubjectsPathTable, 'ColumnWidth', WidthCell);


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



function T1BetFEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1BetFEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1BetFEdit as text
%        str2double(get(hObject,'String')) returns contents of T1BetFEdit as a double
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
BetF_Previous = tracking_opt.T1BetF;
BetFString = get(hObject,'String');
tracking_opt.T1BetF = str2num(BetFString);
if BetF_Previous ~= tracking_opt.T1BetF
    TrackingOpt_ParametersChangeFlag = 1;
end


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


% --- Executes on button press in T1CroppingGapCheckbox.
function T1CroppingGapCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T1CroppingGapCheckbox
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
T1Cropping_Flag_Previous = tracking_opt.T1Cropping_Flag;
if get(hObject, 'Value')
    tracking_opt.T1Cropping_Flag = 1;
    if isempty(tracking_opt.T1CroppingGap)
        tracking_opt.T1CroppingGap = 3;
    end
    set( handles.T1CroppingGapEdit, 'Enable', 'on');
    set( handles.T1CroppingGapEdit, 'String', num2str(tracking_opt.T1CroppingGap));
else
    tracking_opt.T1Cropping_Flag = 0;
    set( handles.T1CroppingGapEdit, 'String', '');
    set( handles.T1CroppingGapEdit, 'Enable', 'off');
end
if T1Cropping_Flag_Previous ~= tracking_opt.T1Cropping_Flag
    TrackingOpt_ParametersChangeFlag = 1;
end


function T1CroppingGapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1CroppingGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1CroppingGapEdit as text
%        str2double(get(hObject,'String')) returns contents of T1CroppingGapEdit as a double
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
T1CroppingGap_Previous = tracking_opt.T1CroppingGap;
T1CroppingGapString = get(hObject,'String');
tracking_opt.T1CroppingGap = str2num(T1CroppingGapString);
if T1CroppingGap_Previous ~= tracking_opt.T1CroppingGap
    TrackingOpt_ParametersChangeFlag = 1;
end


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
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
T1Resample_Flag_Previous = tracking_opt.T1Resample_Flag;
if get(hObject, 'Value')
    tracking_opt.T1Resample_Flag = 1;
    if isempty(tracking_opt.T1ResampleResolution)
        tracking_opt.T1ResampleResolution = [1 1 1];
    end
    set( handles.T1ResampleResolutionEdit, 'Enable', 'on');
    set( handles.T1ResampleResolutionEdit, 'String', mat2str(tracking_opt.T1ResampleResolution));
else
    tracking_opt.T1Resample_Flag = 0;
    set( handles.T1ResampleResolutionEdit, 'String', '');
    set( handles.T1ResampleResolutionEdit, 'Enable', 'off');
end
if T1Resample_Flag_Previous ~= tracking_opt.T1Resample_Flag
    TrackingOpt_ParametersChangeFlag = 1;
end


function T1ResampleResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to T1ResampleResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1ResampleResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of T1ResampleResolutionEdit as a double
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
T1ResampleResolution_Previous = tracking_opt.T1ResampleResolution;
ResolutionString = get(hObject, 'String');
tracking_opt.T1ResampleResolution = eval(ResolutionString);
if T1ResampleResolution_Previous ~= tracking_opt.T1ResampleResolution
    TrackingOpt_ParametersChangeFlag = 1;
end


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


% --- Executes on button press in RandomSeedCheckbox.
function RandomSeedCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to RandomSeedCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RandomSeedCheckbox
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
RandomSeed_Flag_Previous = tracking_opt.RandomSeed_Flag;
if get(hObject, 'Value')
    tracking_opt.RandomSeed_Flag = 1;
    set( handles.RandomSeedText, 'Enable', 'on');
    set( handles.RandomSeedEdit, 'Enable', 'on')
    tracking_opt.RandomSeed = 1;
    set( handles.RandomSeedEdit, 'String', '1');
else
    tracking_opt.RandomSeed_Flag = 0;
    set( handles.RandomSeedEdit, 'String', '');
    set( handles.RandomSeedEdit, 'Enable', 'off');
end
if RandomSeed_Flag_Previous ~= tracking_opt.RandomSeed_Flag
    TrackingOpt_ParametersChangeFlag = 1;
end


function RandomSeedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RandomSeedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RandomSeedEdit as text
%        str2double(get(hObject,'String')) returns contents of RandomSeedEdit as a double
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
RandomSeed_Previous = tracking_opt.RandomSeed;
RandomSeedString = get(hObject, 'string');
tracking_opt.RandomSeed = str2num(RandomSeedString);
if RandomSeed_Previous ~= tracking_opt.RandomSeed
    TrackingOpt_ParametersChangeFlag = 1;
end


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


% --------------------------------------------------------------------
function FAPath_T1orPartitionOfSubjectsPathTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FAPath_T1orPartitionOfSubjectsPathTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% FAPathParcellatedT1Path = get(hObject, 'data');
% OrigineWidthCell = get(hObject, 'ColumnWidth');
% if ~isempty(FolderPathId)
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
global tracking_opt;
global TrackingOpt_ParametersChangeFlag;
T1Bet_Flag_Previous = tracking_opt.T1Bet_Flag;
if get(hObject, 'Value')
    tracking_opt.T1Bet_Flag = 1;
    if isempty(tracking_opt.T1BetF)
        tracking_opt.T1BetF = 0.5;
    end
    set( handles.T1BetFEdit, 'Enable', 'on');
    set( handles.T1BetFEdit, 'String', num2str(tracking_opt.T1BetF));
else
    tracking_opt.T1Bet_Flag = 0;
    set( handles.T1BetFEdit, 'String', '');
    set( handles.T1BetFEdit, 'Enable', 'off');
end
if T1Bet_Flag_Previous ~= tracking_opt.T1Bet_Flag
    TrackingOpt_ParametersChangeFlag = 1;
end
