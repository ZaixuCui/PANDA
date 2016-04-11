function varargout = Diffusion_Opt(varargin)
% GUI for setting Diffusion options (part of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Version 1.1.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
% DIFFUSION_OPT MATLAB code for Diffusion_Opt.fig
%      DIFFUSION_OPT, by itself, creates a new DIFFUSION_OPT or raises the existing
%      singleton*.
%
%      H = DIFFUSION_OPT returns the handle to a new DIFFUSION_OPT or the handle to
%      the existing singleton*.
%
%      DIFFUSION_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIFFUSION_OPT.M with the given input arguments.
%
%      DIFFUSION_OPT('Property','Value',...) creates a new DIFFUSION_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Diffusion_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Diffusion_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only zero
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Diffusion_Opt

% Last Modified by GUIDE v2.5 22-May-2012 15:38:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Diffusion_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @Diffusion_Opt_OutputFcn, ...
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


% --- Executes just before Diffusion_Opt is made visible.
function Diffusion_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Diffusion_Opt (see VARARGIN)

% Choose default command line output for Diffusion_Opt
global dti_opt;
global LockFlag;
global DestinationPath_Edit;
global DeleteTagPrevious;
global PANDAPath;

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Diffusion_Opt wait for user response (see UIRESUME)
% uiwait(handles.DiffusionOptFigure);

% Set initial value of Bet parameter
if ~isfield(dti_opt,'BET_1_f')
    dti_opt.BET_1_f = 0.25;
end
set( handles.BetFEdit, 'String', num2str(dti_opt.BET_1_f) );
% Set initial value of Delete Flag parameter
if ~isfield(dti_opt,'Delete_Flag')
    dti_opt.Delete_Flag = 1;
end
if dti_opt.Delete_Flag == 0
    set( handles.zero , 'Value', 1);
    DeleteTagPrevious = 'zero';
else
    set( handles.one , 'Value', 1 );
    DeleteTagPrevious = 'one';
end
% Set initial value of NIIcrop Slice Gap parameter
if ~isfield(dti_opt,'NIIcrop_slice_gap')
    dti_opt.NIIcrop_slice_gap = 3;
end
set( handles.NIIcropSliceGapEdit, 'string', dti_opt.NIIcrop_slice_gap );
% Set initial value of FAnormalize target parameter
if ~isfield(dti_opt,'FAnormalize_target')
    dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
end
set( handles.FormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
% Set initial value of WM_Label_Atlas and WM_Probtract_Atlas
if ~isfield(dti_opt,'WM_Label_Atlas')
    dti_opt.WM_Label_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'WM_label'];
end
set( handles.WMLabelAtlasEdit, 'string', dti_opt.WM_Label_Atlas );
if ~isfield(dti_opt,'WM_Probtract_Atlas')
    dti_opt.WM_Probtract_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'WM_tract_prob'];
end
set( handles.WMProbtractAtlasEdit, 'string', dti_opt.WM_Probtract_Atlas );
% Set initial value of Applywarp Resolution parameter
dti_opt.applywarp_1_ref_fileName = 1;
dti_opt.applywarp_3_ref_fileName = 1;
dti_opt.applywarp_5_ref_fileName = 1;
dti_opt.applywarp_7_ref_fileName = 1;
if ~isfield(dti_opt,'applywarp_2_ref_fileName')  
    dti_opt.applywarp_2_ref_fileName = 2; 
end
if ~isfield(dti_opt,'applywarp_4_ref_fileName') 
    dti_opt.applywarp_4_ref_fileName = 2;
end
if ~isfield(dti_opt,'applywarp_4_ref_fileName') 
    dti_opt.applywarp_6_ref_fileName = 2;
end
if ~isfield(dti_opt,'applywarp_4_ref_fileName')
    dti_opt.applywarp_8_ref_fileName = 2;
end
ResolutionString = num2str(dti_opt.applywarp_2_ref_fileName);
set( handles.ApplywarpResolutionEdit, 'string', ResolutionString);
% Set initial value of Smooth Kernel Size parameter
if ~isfield(dti_opt,'smoothNII_1_kernel_size')
    dti_opt.smoothNII_1_kernel_size = 6;
end
if ~isfield(dti_opt,'smoothNII_2_kernel_size')
    dti_opt.smoothNII_2_kernel_size = 6;
end
if ~isfield(dti_opt,'smoothNII_3_kernel_size')
    dti_opt.smoothNII_3_kernel_size = 6;
end
if ~isfield(dti_opt,'smoothNII_4_kernel_size')
    dti_opt.smoothNII_4_kernel_size = 6;
end
set( handles.SmoothKernelSizeEdit, 'string', num2str(dti_opt.smoothNII_4_kernel_size) );
% Set initial value of TBSS_Flag and dismap threshold
if ~isfield(dti_opt,'TBSS_Flag')
    dti_opt.TBSS_Flag = 0;
    set(handles.TbssCheckBox, 'Value', 0);
    set(handles.DismapThresholdEdit, 'Enable', 'off');
else
    set(handles.TbssCheckBox, 'Value', dti_opt.TBSS_Flag);
    if dti_opt.TBSS_Flag
        set(handles.DismapThresholdEdit, 'Enable', 'on');
        set(handles.DismapThresholdEdit, 'String', '0.2');
    else
        set(handles.DismapThresholdEdit, 'String', '');
        set(handles.DismapThresholdEdit, 'Enable', 'off');
    end
end
% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if exist( LockFilePath, 'file' )
    set( handles.BetFEdit, 'Enable', 'off' );
    set( handles.NIIcropSliceGapEdit, 'Enable', 'off' );
    set( handles.FormalizeTargetEdit, 'Enable', 'off' );
    set( handles.ApplywarpResolutionEdit, 'Enable', 'off' );
    set( handles.SmoothKernelSizeEdit, 'Enable', 'off' );
    set( handles.FormalizeTargetButton, 'Enable', 'off' );
    set( handles.TbssCheckBox, 'Enable', 'off' );
    set( handles.DismapThresholdEdit, 'Enable', 'off' );
    set( handles.WMLabelAtlasEdit, 'Enable', 'off' );
    set( handles.WMLabelAtlasButton, 'Enable', 'off' );
    set( handles.WMProbtractAtlasEdit, 'Enable', 'off' );
    set( handles.WMProbtractAtlasButton, 'Enable', 'off' );
    % LockFlag is used to set radio group unable
    LockFlag = 1;
else
    LockFlag = 0;
end


% --- Outputs from this function are returned to the command line.
function varargout = Diffusion_Opt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function BetFEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BetFEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BetFEdit as text
%        str2double(get(hObject,'String')) returns contents of BetFEdit as a double
global dti_opt;
BetFString = get(hObject, 'string');
if ~isempty(BetFString)
    dti_opt.BET_1_f = str2double(BetFString);
    dti_opt.BET_2_f = str2double(BetFString);
else
    dti_opt.BET_1_f = '';
    dti_opt.BET_2_f = '';
end


% --- Executes during object creation, after setting all properties.
function BetFEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BetFEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function zero_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function one_CreateFcn(hObject, eventdata, handles)
% hObject    handle to one (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function DeleteDataFromDICOM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeleteDataFromDICOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in DeleteDataFromDICOM.
function DeleteDataFromDICOM_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in DeleteDataFromDICOM 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
global LockFlag;
global DeleteTagPrevious;
if LockFlag == 0
    switch get( hObject, 'Tag')
        case 'zero'
            dti_opt.Delete_Flag = 0;
        case 'one'
            dti_opt.Delete_Flag = 1;
    end
else
    switch DeleteTagPrevious
        case 'zero'
            set( handles.zero, 'Value', 1 );
        case 'one'
            set( handles.one, 'Value', 1 );
    end
end


function NIIcropSliceGapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NIIcropSliceGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NIIcropSliceGapEdit as text
%        str2double(get(hObject,'String')) returns contents of NIIcropSliceGapEdit as a double
global dti_opt;
NIIcropSliceGapString = get(hObject, 'string');
if ~isempty(NIIcropSliceGapString)
    dti_opt.NIIcrop_slice_gap = str2double(NIIcropSliceGapString);
else
    dti_opt.NIIcrop_slice_gap = '';
end


% --- Executes during object creation, after setting all properties.
function NIIcropSliceGapEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NIIcropSliceGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on NIIcropSliceGapEdit and none of its controls.
function NIIcropSliceGapEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to NIIcropSliceGapEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
BetF_Text = get( handles.BetFEdit, 'string' );
if isempty(BetF_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the Bet f !');
end


% --- Executes on button press in FormalizeTargetButton.
function FormalizeTargetButton_Callback(hObject, eventdata, handles)
% hObject    handle to FormalizeTargetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
NIIcropSliceGap_Text = get( handles.NIIcropSliceGapEdit, 'string' );
if isempty(NIIcropSliceGap_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the NIIcrop Slice Gap !');
else
    [FormalizeTargetName,FormalizeTargetParent] = uigetfile;
    FormalizeTargetPath = [FormalizeTargetParent filesep FormalizeTargetName];
    if ~isnumeric(FormalizeTargetName) & ~isnumeric(FormalizeTargetParent)
        set( handles.FormalizeTargetEdit, 'string', FormalizeTargetPath );
        dti_opt.FAnormalize_target = FormalizeTargetPath;
    end
end


function FormalizeTargetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FormalizeTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FormalizeTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of FormalizeTargetEdit as a double
global dti_opt;
NIIcropSliceGap_Text = get( handles.NIIcropSliceGapEdit, 'string' );
if isempty(NIIcropSliceGap_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the NIIcrop Slice Gap !');
else
    FormalizeTargetPath = get( handles.FormalizeTargetEdit, 'string' );
    dti_opt.FAnormalize_target = FormalizeTargetPath;
end


% --- Executes during object creation, after setting all properties.
function FormalizeTargetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FormalizeTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on FormalizeTargetEdit and none of its controls.
function FormalizeTargetEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to FormalizeTargetEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
NIIcropSliceGap_Text = get( handles.NIIcropSliceGapEdit, 'string' );
if isempty(NIIcropSliceGap_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the NIIcrop Slice Gap !');
end


function ApplywarpResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ApplywarpResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ApplywarpResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of ApplywarpResolutionEdit as a double
global dti_opt;
ApplywarpResolutionString = get(hObject, 'string');
if ~isempty(ApplywarpResolutionString)
    Resolution = str2num(ApplywarpResolutionString);
    dti_opt.applywarp_1_ref_fileName = 1;
    dti_opt.applywarp_2_ref_fileName = Resolution;
    dti_opt.applywarp_3_ref_fileName = 1;
    dti_opt.applywarp_4_ref_fileName = Resolution;
    dti_opt.applywarp_5_ref_fileName = 1;
    dti_opt.applywarp_6_ref_fileName = Resolution;
    dti_opt.applywarp_7_ref_fileName = 1;
    dti_opt.applywarp_8_ref_fileName = Resolution;
else
    dti_opt.applywarp_2_ref_fileName = '';
end


% --- Executes during object creation, after setting all properties.
function ApplywarpResolutionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplywarpResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on ApplywarpResolutionEdit and none of its controls.
function ApplywarpResolutionEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ApplywarpResolutionEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
FormalizeTarget_Text = get( handles.FormalizeTargetEdit, 'string' );
if isempty(FormalizeTarget_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the Formalize Target !');
end


function SmoothKernelSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothKernelSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothKernelSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of SmoothKernelSizeEdit as a double
global dti_opt;
SmoothKernelSizeString = get(hObject,'string');
if ~isempty(SmoothKernelSizeString)
    dti_opt.smoothNII_1_kernel_size = str2double(SmoothKernelSizeString);
    dti_opt.smoothNII_2_kernel_size = str2double(SmoothKernelSizeString);
    dti_opt.smoothNII_3_kernel_size = str2double(SmoothKernelSizeString);
    dti_opt.smoothNII_4_kernel_size = str2double(SmoothKernelSizeString);
else
    dti_opt.smoothNII_1_kernel_size = '';
end


% --- Executes during object creation, after setting all properties.
function SmoothKernelSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothKernelSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on SmoothKernelSizeEdit and none of its controls.
function SmoothKernelSizeEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SmoothKernelSizeEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
ApplywarpResolution_Text = get( handles.ApplywarpResolutionEdit, 'string' );
if isempty(ApplywarpResolution_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the Applywarp Resolution !');
end


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Excute 'close' command, it will call DiffusionOptFigure_CloseRequestFcn function
global dti_opt;
global LockFlag;

if LockFlag == 0
    if isempty(dti_opt.BET_1_f) 
        msgbox('Please input the f(skull removal) !');
    elseif isempty(dti_opt.NIIcrop_slice_gap)
        msgbox('Please input the Cropping Gap !');
    elseif isempty(dti_opt.FAnormalize_target)
        msgbox('Please input the Normalization Target !');
    elseif isempty(dti_opt.applywarp_1_ref_fileName) | isempty(dti_opt.applywarp_2_ref_fileName)
        msgbox('Please input the Resample Resolution !');
    elseif isempty(dti_opt.smoothNII_1_kernel_size)
        msgbox('Please input the Smoothing kernel !');
    elseif isempty(dti_opt.WM_Label_Atlas)
        msgbox('Please input white matter label atlas !');
    elseif isempty(dti_opt.WM_Probtract_Atlas)
        msgbox('Please input white matter probtract atlas !');
    elseif dti_opt.TBSS_Flag & isempty(dti_opt.dismap_threshold)
        msgbox('Please input the Skeleton Cutoff!');
    else
        Check_info{1} = [' f(skull removal) = ' num2str(dti_opt.BET_1_f)];
        Check_info{2} = [' Delete Flag = ' num2str(dti_opt.Delete_Flag)];
        Check_info{3} = [' Cropping Gap = ' num2str(dti_opt.NIIcrop_slice_gap)];
        Check_info{4} = [' Normalization Target = ' dti_opt.FAnormalize_target]; 
        Check_info{5} = [' Resample Resolution = ' num2str(dti_opt.applywarp_2_ref_fileName)];
        Check_info{6} = [' Smoothing kernel = ' num2str(dti_opt.smoothNII_1_kernel_size)];
        Check_info{7} = [' White matter label altas = ' dti_opt.WM_Label_Atlas];
        Check_info{8} = [' White matter probtract altas = ' dti_opt.WM_Probtract_Atlas];
        Check_info{9} = [' TBSS Flag = ' num2str(dti_opt.TBSS_Flag)];
        if dti_opt.TBSS_Flag == 1
            Check_info{10} = [' Skeleton Cutoff = ' num2str(dti_opt.dismap_threshold)];
        end
        button = questdlg( Check_info, 'Please check!', 'Yes', 'No', 'No');
        if strcmp(button,'Yes')
            close;
        end
    end
else
    close;
end


% --- Executes on button press in TbssCheckBox.
function TbssCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to TbssCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TbssCheckBox
global dti_opt;
if get(hObject, 'value')
    dti_opt.TBSS_Flag = 1;
    dti_opt.dismap_threshold = 0.2;
    set(handles.DismapThresholdEdit, 'Enable', 'on');
    set(handles.DismapThresholdEdit, 'String', '0.2');
else
    dti_opt.TBSS_Flag = 0;
    set(handles.DismapThresholdEdit, 'String', '');
    set(handles.DismapThresholdEdit, 'Enable', 'off');
end


function DismapThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DismapThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DismapThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of DismapThresholdEdit as a double
global dti_opt;
DismapThreshold = get(hObject, 'string');
if ~isempty(DismapThreshold)
    dti_opt.dismap_threshold = str2double(DismapThreshold);
else
    dti_opt.dismap_threshold = '';
end


% --- Executes during object creation, after setting all properties.
function DismapThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DismapThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
%end


% --- Executes when user attempts to close DiffusionOptFigure.
function DiffusionOptFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to DiffusionOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

    


% --- Executes when DiffusionOptFigure is resized.
function DiffusionOptFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to DiffusionOptFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)  
    PositionFigure = get(handles.DiffusionOptFigure, 'Position');
    FontSizeUipanel = ceil(12 * PositionFigure(4) / 280);
    set( handles.DeleteDataFromDICOM, 'FontSize', FontSizeUipanel );
    set( handles.TBSSUipanel, 'FontSize', FontSizeUipanel );
end


% --- Executes on button press in SkeletonCutoffText.
function SkeletonCutoffText_Callback(hObject, eventdata, handles)
% hObject    handle to SkeletonCutoffText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SkullRemovalText.
function SkullRemovalText_Callback(hObject, eventdata, handles)
% hObject    handle to SkullRemovalText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CroppingGapText.
function CroppingGapText_Callback(hObject, eventdata, handles)
% hObject    handle to CroppingGapText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ResampleResolutionText.
function ResampleResolutionText_Callback(hObject, eventdata, handles)
% hObject    handle to ResampleResolutionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SmoothingKernelText.
function SmoothingKernelText_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothingKernelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NormalizingTargetText.
function NormalizingTargetText_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizingTargetText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function WMProbtractAtlasEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WMProbtractAtlasEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WMProbtractAtlasEdit as text
%        str2double(get(hObject,'String')) returns contents of WMProbtractAtlasEdit as a double
global dti_opt;
WMLabelAtlas_Text = get( handles.WMLabelAtlasEdit, 'string' );
if isempty(WMLabelAtlas_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the white matter label atlas path !');
else
    WMProbtractAtlasPath = get( handles.WMProbtractAtlasEdit, 'string' );
    dti_opt.WM_Probtract_Atlas = WMProbtractAtlasPath;
end


% --- Executes during object creation, after setting all properties.
function WMProbtractAtlasEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WMProbtractAtlasEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
%end



function WMLabelAtlasEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WMLabelAtlasEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WMLabelAtlasEdit as text
%        str2double(get(hObject,'String')) returns contents of WMLabelAtlasEdit as a double
global dti_opt;
NormalizingTarget_Text = get( handles.FormalizeTargetEdit, 'string' );
if isempty(NormalizingTarget_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the normalizing target !');
else
    WMLabelAtlasPath = get( handles.WMLabelAtlasEdit, 'string' );
    dti_opt.WM_Label_Atlas = WMLabelAtlasPath;
end


% --- Executes during object creation, after setting all properties.
function WMLabelAtlasEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WMLabelAtlasEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in WMProbtractAtlasButton.
function WMProbtractAtlasButton_Callback(hObject, eventdata, handles)
% hObject    handle to WMProbtractAtlasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
WMLabelAtlas_Text = get( handles.WMLabelAtlasEdit, 'string' );
if isempty(WMLabelAtlas_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the white matter label atlas !');
else
    [WMProbtractAtlasName,WMProbtractAtlasParent] = uigetfile;
    WMProbtractAtlasPath = [WMProbtractAtlasParent filesep WMProbtractAtlasName];
    if ~isnumeric(WMProbtractAtlasName) & ~isnumeric(WMProbtractAtlasParent)
        set( handles.WMProbtractAtlasEdit, 'string', WMProbtractAtlasPath );
        dti_opt.WM_Probtract_Atlas = WMProbtractAtlasPath;
    end
end


% --- Executes on button press in WMLabelAtlasButton.
function WMLabelAtlasButton_Callback(hObject, eventdata, handles)
% hObject    handle to WMLabelAtlasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
NormalizingTarget_Text = get( handles.FormalizeTargetEdit, 'string' );
if isempty(NormalizingTarget_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the normalizing target !');
else
    [WMLabelAtlasName,WMLabelAtlasParent] = uigetfile;
    WMLabelAtlasPath = [WMLabelAtlasParent filesep WMLabelAtlasName];
    if ~isnumeric(WMLabelAtlasName) & ~isnumeric(WMLabelAtlasParent)
        set( handles.WMLabelAtlasEdit, 'string', WMLabelAtlasPath );
        dti_opt.WM_Label_Atlas = WMLabelAtlasPath;
    end
end
