function varargout = PANDA_Diffusion_Opt(varargin)
% GUI for setting Diffusion options (part of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_DIFFUSION_OPT MATLAB code for PANDA_Diffusion_Opt.fig
%      PANDA_DIFFUSION_OPT, by itself, creates a new PANDA_DIFFUSION_OPT or raises the existing
%      singleton*.
%
%      H = PANDA_DIFFUSION_OPT returns the handle to a new PANDA_DIFFUSION_OPT or the handle to
%      the existing singleton*.
%
%      PANDA_DIFFUSION_OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_DIFFUSION_OPT.M with the given input arguments.
%
%      PANDA_DIFFUSION_OPT('Property','Value',...) creates a new PANDA_DIFFUSION_OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Diffusion_Opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Diffusion_Opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only KeepRadio
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Diffusion_Opt

% Last Modified by GUIDE v2.5 04-Sep-2013 15:19:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Diffusion_Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Diffusion_Opt_OutputFcn, ...
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


% --- Executes just before PANDA_Diffusion_Opt is made visible.
function PANDA_Diffusion_Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Diffusion_Opt (see VARARGIN)

% Choose default command line output for PANDA_Diffusion_Opt
global dti_opt;
global LockFlag;
global DestinationPath_Edit;
global DeleteTagPrevious;
global PANDAPath;
global DiffusionOpt_ParametersChangeFlag;

DiffusionOpt_ParametersChangeFlag = 0;

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_Diffusion_Opt wait for user response (see UIRESUME)
% uiwait(handles.DiffusionOptFigure);

% Set initial value of raw data resample resolution
if ~isfield(dti_opt, 'RawDataResample_Flag')
    dti_opt.RawDataResample_Flag = 0;
end
set(handles.RawDataResampleCheckbox, 'Value', dti_opt.RawDataResample_Flag);
if ~dti_opt.RawDataResample_Flag
    set( handles.RawDataResampleResolutionEdit, 'String', '' );
    set( handles.RawDataResampleResolutionEdit, 'Enable', 'off' );
else
    if ~isfield(dti_opt,'RawDataResampleResolution')
        dti_opt.RawDataResampleResolution = [2 2 2];
    elseif isempty(dti_opt.RawDataResampleResolution)
        dti_opt.RawDataResampleResolution = [2 2 2];
    end
    set( handles.RawDataResampleResolutionEdit, 'Enable', 'on' );
    set( handles.RawDataResampleResolutionEdit, 'string', mat2str(dti_opt.RawDataResampleResolution) );
end
% Set initial value of orientation patch
if ~isfield(dti_opt, 'Inversion')
    dti_opt.Inversion = 'No Inversion';
end
if ~isfield(dti_opt, 'Swap')
    dti_opt.Swap = 'No Swap';
end
if strcmp(dti_opt.Inversion, 'No Inversion')
    set(handles.InversionMenu, 'value', 1.0);
elseif strcmp(dti_opt.Inversion, 'Invert X')
    set(handles.InversionMenu, 'value', 2.0);
elseif strcmp(dti_opt.Inversion, 'Invert Y')
    set(handles.InversionMenu, 'value', 3.0);
elseif strcmp(dti_opt.Inversion, 'Invert Z')
    set(handles.InversionMenu, 'value', 4.0);
end
if strcmp(dti_opt.Swap, 'No Swap')
    set(handles.SwapMenu, 'value', 1.0);
elseif strcmp(dti_opt.Swap, 'Swap X/Y')
    set(handles.SwapMenu, 'value', 2.0);
elseif strcmp(dti_opt.Swap, 'Swap Y/Z')
    set(handles.SwapMenu, 'value', 3.0);
elseif strcmp(dti_opt.Swap, 'Swap Z/X')
    set(handles.SwapMenu, 'value', 4.0);
end
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
    set( handles.KeepRadio , 'Value', 1);
    DeleteTagPrevious = 'KeepRadio';
else
    set( handles.DeleteRadio , 'Value', 1 );
    DeleteTagPrevious = 'DeleteRadio';
end
% Set initial value of NIIcrop Slice Gap parameter
if ~isfield(dti_opt, 'Cropping_Flag')
    dti_opt.Cropping_Flag = 1;
end
set(handles.CroppingCheckBox, 'Value', dti_opt.Cropping_Flag);
if ~dti_opt.Cropping_Flag
    set( handles.NIIcropSliceGapEdit, 'String', '' );
    set( handles.NIIcropSliceGapEdit, 'Enable', 'off' );
else
    if ~isfield(dti_opt,'NIIcrop_slice_gap')
        dti_opt.NIIcrop_slice_gap = 3;
    end
    set( handles.NIIcropSliceGapEdit, 'Enable', 'on' );
    set( handles.NIIcropSliceGapEdit, 'string', dti_opt.NIIcrop_slice_gap );
end
% Set initial value of LDH neighborhood cluster
if ~isfield(dti_opt, 'LDH_Neighborhood')
    dti_opt.LDH_Neighborhood = 7;
end
if dti_opt.LDH_Neighborhood == 7
    set(handles.SevenRadio, 'Value', 1);
    LDHTagPrevious = 'SevenRadio';
elseif dti_opt.LDH_Neighborhood == 19
    set(handles.NineteenRadio, 'Value', 1);
    LDHTagPrevious = 'NineteenRadio';
elseif dti_opt.LDH_Neighborhood == 27
    set(handles.TwentySevenRadio, 'Value', 1);
    LDHTagPrevious = 'TwentySevenRadio';
end
% Set initial value of FAnormalize target parameter
if ~isfield(dti_opt, 'Normalizing_Flag')
    dti_opt.Normalizing_Flag = 1;   
end
set(handles.NormalizingCheckBox, 'Value', dti_opt.Normalizing_Flag);
if ~dti_opt.Normalizing_Flag
    set( handles.NormalizeTargetEdit, 'String', '' );
    set( handles.NormalizeTargetEdit, 'Enable', 'off' );
    dti_opt.Resampling_Flag = 0;
else
    if ~isfield(dti_opt,'FAnormalize_target')
        dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
    end
    set( handles.NormalizeTargetEdit, 'Enable', 'on' );
    set( handles.NormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
end
% Set initial value of Resampling parameter
if ~isfield(dti_opt, 'Resampling_Flag')
    dti_opt.Resampling_Flag = 1;
end
set(handles.ResampleCheckBox, 'Value', dti_opt.Resampling_Flag);
if ~dti_opt.Resampling_Flag
    set( handles.ApplywarpResolutionEdit, 'String', '' );
    set( handles.ApplywarpResolutionEdit, 'Enable', 'off' );
    dti_opt.Smoothing_Flag = 0;
else
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
    set( handles.ApplywarpResolutionEdit, 'Enable', 'on' );
    ResolutionString = num2str(dti_opt.applywarp_2_ref_fileName);
    set( handles.ApplywarpResolutionEdit, 'string', ResolutionString);
end
% Set initial value of Smooth Kernel Size parameter
if ~isfield(dti_opt, 'Smoothing_Flag')
    dti_opt.Smoothing_Flag = 1;
end
set(handles.SmoothingCheckBox, 'Value', dti_opt.Smoothing_Flag);
if ~dti_opt.Smoothing_Flag
    set( handles.SmoothKernelSizeEdit, 'String', '' );
    set( handles.SmoothKernelSizeEdit, 'Enable', 'off' );
else
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
    set( handles.SmoothKernelSizeEdit, 'Enable', 'on' );
    set( handles.SmoothKernelSizeEdit, 'string', num2str(dti_opt.smoothNII_4_kernel_size) );
end
% Set initial value of WM_Label_Atlas and WM_Probtract_Atlas
if ~isfield(dti_opt, 'Atlas_Flag')
    dti_opt.Atlas_Flag = 1;   
end
set(handles.AtlasCheckBox, 'Value', dti_opt.Atlas_Flag);
if ~dti_opt.Atlas_Flag
    set( handles.WMLabelAtlasEdit, 'String', '' );
    set( handles.WMLabelAtlasEdit, 'Enable', 'off' );
    set( handles.WMLabelAtlasButton, 'Enable', 'off' );
    set( handles.WMProbtractAtlasEdit, 'String', '' );
    set( handles.WMProbtractAtlasEdit, 'Enable', 'off' );
    set( handles.WMProbtractAtlasButton, 'Enable', 'off' );
else
    if ~isfield(dti_opt,'WM_Label_Atlas')
        dti_opt.WM_Label_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
    end
    set( handles.WMLabelAtlasEdit, 'Enable', 'on' );
    set( handles.WMLabelAtlasEdit, 'string', dti_opt.WM_Label_Atlas );
    set( handles.WMLabelAtlasButton, 'Enable', 'on' );
    if ~isfield(dti_opt,'WM_Probtract_Atlas')
        dti_opt.WM_Probtract_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
    end
    set( handles.WMProbtractAtlasEdit, 'Enable', 'on' );
    set( handles.WMProbtractAtlasEdit, 'string', dti_opt.WM_Probtract_Atlas );
    set( handles.WMProbtractAtlasButton, 'Enable', 'on' );
end
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
    %
    set( handles.RawDataResampleCheckbox, 'Enable', 'off' );
    set( handles.RawDataResampleResolutionEdit, 'Enable', 'off' );
    %
    set( handles.BetFEdit, 'Enable', 'off' );
    %
    set( handles.CroppingCheckBox, 'Enable', 'off' );
    set( handles.NIIcropSliceGapEdit, 'Enable', 'off' );
    %
    set( handles.NormalizingCheckBox, 'Enable', 'off' );
    set( handles.NormalizeTargetButton, 'Enable', 'off' );
    set( handles.NormalizeTargetEdit, 'Enable', 'off' );
    %
    set( handles.ResampleCheckBox, 'Enable', 'off' );
    set( handles.ApplywarpResolutionEdit, 'Enable', 'off' );
    %
    set( handles.SmoothingCheckBox, 'Enable', 'off' );
    set( handles.SmoothKernelSizeEdit, 'Enable', 'off' );
    %
    set( handles.TbssCheckBox, 'Enable', 'off' );
    set( handles.DismapThresholdEdit, 'Enable', 'off' );
    %
    set( handles.InversionMenu, 'Enable', 'off' );
    set( handles.SwapMenu, 'Enable', 'off' );
    %
    set( handles.AtlasCheckBox, 'Enable', 'off' );
    set( handles.WMLabelAtlasEdit, 'Enable', 'off' );
    set( handles.WMLabelAtlasButton, 'Enable', 'off' );
    set( handles.WMProbtractAtlasEdit, 'Enable', 'off' );
    set( handles.WMProbtractAtlasButton, 'Enable', 'off' );
    % LockFlag is used to set radio group unable
    LockFlag = 1;
else
    LockFlag = 0;
end
%
TipStr = sprintf('If the raw data needs to be resampled, please click this.');
set(handles.RawDataResampleCheckbox, 'TooltipString', TipStr);
%
TipStr = sprintf('The final voxel size of the raw data after resampling.');
set(handles.RawDataResampleResolutionEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['Correct the original bvecs for the right fiber oritation' ...
    '\n which can be acquired with TestBvecs Utility.']);
set(handles.InversionMenu, 'TooltipString', TipStr);
%
TipStr = sprintf(['Correct the original bvecs for the right fiber oritation' ...
    '\n which can be acquired with TestBvecs Utility.']);
set(handles.SwapMenu, 'TooltipString', TipStr);
%
TipStr = sprintf('Keep the raw nifti converted from DICOM.');
set(handles.KeepRadio, 'TooltipString', TipStr);
%
TipStr = sprintf('Delete the raw nifti converted from DICOM.');
set(handles.DeleteRadio, 'TooltipString', TipStr);
%
TipStr = sprintf(['Fractional intensity threshold (0->1) for brain extraction,' ... 
    '\n default = 0.5, smaller values give larger brain outline estimates.']);
set(handles.BetFEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['If dMRI images need to be cropped to reduce image size,' ...
    '\n please click this.']);
set(handles.CroppingCheckBox, 'TooltipString', TipStr);
%
TipStr = sprintf(['The distance from the slected cube to the border of the brain' ...
    '\n for images.']);
set(handles.NIIcropSliceGapEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['Reference: Gong G (2013) Local Diffusion Homogeneity (LDH): An Inter-Voxel' ...
    '\n Diffusion MRI Metric for Assessing Inter-Subject White Matter Variability.' ...
    '\n PLoS ONE 8(6): e66366. doi:10.1371/journal.pone.0066366']);
set(handles.SevenRadio, 'TooltipString', TipStr);
set(handles.NineteenRadio, 'TooltipString', TipStr);
set(handles.TwentySevenRadio, 'TooltipString', TipStr);
%
TipStr = sprintf(['If individual images in native space need to be registered to' ...
    '\n a standardized template, please click this.']);
set(handles.NormalizingCheckBox, 'TooltipString', TipStr);
%
TipStr = sprintf(['The full path of FA template.' ...
    '\n Default: FMRIB58 FA template in MNI space.']);
set(handles.NormalizeTargetEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['If the images in standard space need to be resampled, please' ...
    '\n click this.']);
set(handles.ResampleCheckBox, 'TooltipString', TipStr);
%
TipStr = sprintf(['The final voxel size of the standardized images after' ...
    '\n resapmling.']);
set(handles.ApplywarpResolutionEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['If the images in standard space need to be smoothed, please' ...
    '\n click this.']);
set(handles.SmoothingCheckBox, 'TooltipString', TipStr);
%
TipStr = sprintf('Smooth kernel size for smoothing.');
set(handles.SmoothKernelSizeEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('FA threshold to exclude voxels in the grey matter or CSF.');
set(handles.DismapThresholdEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['Atlas based analysis:' ...
    '\n Regional diffusion metrics (i.e., FA, MD, AD, and RD) are calculated by' ...
    '\n averaging the values within each region of the WM atlases.']);
set(handles.AtlasCheckBox, 'TooltipString', TipStr);
%
TipStr = sprintf(['The full path of the white matter atlas image.' ...
    '\n Default: ICBM-DTI-81 WM labels atlases.']);
set(handles.WMLabelAtlasEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['The full path of the white matter atlas image.' ...
    '\n Default: JHU WM tractography atlases.']);
set(handles.WMProbtractAtlasEdit, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Diffusion_Opt_OutputFcn(hObject, eventdata, handles) 
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
global DiffusionOpt_ParametersChangeFlag;
BetF_Previous = dti_opt.BET_1_f;
BetFString = get(hObject, 'string');
if ~isempty(BetFString)
    dti_opt.BET_1_f = str2double(BetFString);
    dti_opt.BET_2_f = str2double(BetFString);
else
    dti_opt.BET_1_f = '';
    dti_opt.BET_2_f = '';
end
if BetF_Previous ~= dti_opt.BET_1_f
    DiffusionOpt_ParametersChangeFlag = 1;
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
function KeepRadio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KeepRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function DeleteRadio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeleteRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function DeleteDataFromDICOMUipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeleteDataFromDICOMUipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in DeleteDataFromDICOMUipanel.
function DeleteDataFromDICOMUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in DeleteDataFromDICOMUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
global LockFlag;
global DeleteTagPrevious;
global DiffusionOpt_ParametersChangeFlag;
DeleteFlag_Previous = dti_opt.Delete_Flag;
if LockFlag == 0
    switch get( hObject, 'Tag')
        case 'KeepRadio'
            dti_opt.Delete_Flag = 0;
        case 'DeleteRadio'
            dti_opt.Delete_Flag = 1;
    end
    if DeleteFlag_Previous ~= dti_opt.Delete_Flag
        DiffusionOpt_ParametersChangeFlag = 1;
    end
else
    switch DeleteTagPrevious
        case 'KeepRadio'
            set( handles.KeepRadio, 'Value', 1 );
        case 'DeleteRadio'
            set( handles.DeleteRadio, 'Value', 1 );
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


% --- Executes on button press in NormalizeTargetButton.
function NormalizeTargetButton_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
NormalizingTarget_Previous = dti_opt.FAnormalize_target;
NIIcropSliceGap_Text = get( handles.NIIcropSliceGapEdit, 'string' );
if isempty(NIIcropSliceGap_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the NIIcrop Slice Gap !');
else
    [NormalizeTargetName,NormalizeTargetParent] = uigetfile({'*.nii;*.nii.gz','NIfTI-files (*.nii, *nii.gz)'});
    NormalizeTargetPath = [NormalizeTargetParent NormalizeTargetName];
    if ~isnumeric(NormalizeTargetName) & ~isnumeric(NormalizeTargetParent)
        set( handles.NormalizeTargetEdit, 'string', NormalizeTargetPath );
        dti_opt.FAnormalize_target = NormalizeTargetPath;
    end
end
if ~strcmp(NormalizingTarget_Previous, dti_opt.FAnormalize_target)
    DiffusionOpt_ParametersChangeFlag = 1;
end


function NormalizeTargetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NormalizeTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of NormalizeTargetEdit as a double
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
NormalizeTargetPath_Previous = dti_opt.FAnormalize_target;
NIIcropSliceGap_Text = get( handles.NIIcropSliceGapEdit, 'string' );
if isempty(NIIcropSliceGap_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the NIIcrop Slice Gap !');
else
    NormalizeTargetPath = get( handles.NormalizeTargetEdit, 'string' );
    dti_opt.FAnormalize_target = NormalizeTargetPath;
end
if ~strcmp(NormalizeTargetPath_Previous, dti_opt.FAnormalize_target)
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function NormalizeTargetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on key press with focus on NormalizeTargetEdit and none of its controls.
function NormalizeTargetEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetEdit (see GCBO)
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
global DiffusionOpt_ParametersChangeFlag;
ApplywarpResolution_Previous = dti_opt.applywarp_2_ref_fileName;
ApplywarpResolutionString = get(hObject, 'string');
if ~strcmp(ApplywarpResolutionString, '1') & ~strcmp(ApplywarpResolutionString, '2')
    set(hObject, 'String', num2str(dti_opt.applywarp_2_ref_fileName));
    msgbox('The value can be only 1 or 2 now.');
else
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
end
if ApplywarpResolution_Previous ~= dti_opt.applywarp_2_ref_fileName
    DiffusionOpt_ParametersChangeFlag = 1;
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
NormalizeTarget_Text = get( handles.NormalizeTargetEdit, 'string' );
if isempty(NormalizeTarget_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the Normalize Target !');
end


function SmoothKernelSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothKernelSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothKernelSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of SmoothKernelSizeEdit as a double
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
SmoothKernelSize_Previous = dti_opt.smoothNII_1_kernel_size;
SmoothKernelSizeString = get(hObject,'string');
if ~isempty(SmoothKernelSizeString)
    dti_opt.smoothNII_1_kernel_size = str2double(SmoothKernelSizeString);
    dti_opt.smoothNII_2_kernel_size = str2double(SmoothKernelSizeString);
    dti_opt.smoothNII_3_kernel_size = str2double(SmoothKernelSizeString);
    dti_opt.smoothNII_4_kernel_size = str2double(SmoothKernelSizeString);
else
    dti_opt.smoothNII_1_kernel_size = '';
end
if SmoothKernelSize_Previous ~= dti_opt.smoothNII_1_kernel_size
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function SmoothKernelSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothKernelSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


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
global DiffusionOpt_ParametersChangeFlag;
if LockFlag == 0
    if dti_opt.RawDataResample_Flag
        if isempty(dti_opt.RawDataResampleResolution)
            msgbox('Please input the resolution for resampling the raw data !');
            return;
        end
    end
    if isempty(dti_opt.BET_1_f) 
        msgbox('Please input the f(skull removal) !');
        return;
    end
    if dti_opt.Cropping_Flag
        if isempty(dti_opt.NIIcrop_slice_gap)
            msgbox('Please input the Cropping Gap !');
            return;
        end
    end
    if dti_opt.Normalizing_Flag
        if isempty(dti_opt.FAnormalize_target)
            msgbox('Please input the Normalization Target !');
            return;
        end
    end
    if dti_opt.Resampling_Flag 
        if isempty(dti_opt.applywarp_2_ref_fileName)
            msgbox('Please input the Normalize Resolution !');
            return;
        end
    end
    if dti_opt.Smoothing_Flag
        if isempty(dti_opt.smoothNII_1_kernel_size)
            msgbox('Please input the Smoothing kernel !');
            return;
        end
    end
    if dti_opt.Atlas_Flag
        if isempty(dti_opt.WM_Label_Atlas)
            msgbox('Please input white matter label atlas !');
            return;
        end
        if isempty(dti_opt.WM_Probtract_Atlas)
            msgbox('Please input white matter probtract atlas !');
            return;
        end
    end
    if dti_opt.TBSS_Flag
        if isempty(dti_opt.dismap_threshold)
            msgbox('Please input the Skeleton Cutoff!');
            return;
        end
    end
    if DiffusionOpt_ParametersChangeFlag
        Info_Quantity = 0;
        if dti_opt.RawDataResample_Flag
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' Rawdata resampling resolution = ' mat2str(dti_opt.RawDataResampleResolution)];
        end
        Check_info{Info_Quantity + 1} = [' Orientation Inversion = ' dti_opt.Inversion];
        Check_info{Info_Quantity + 2} = [' Orientation Swap = ' dti_opt.Swap];
        Check_info{Info_Quantity + 3} = [' Delete Flag = ' num2str(dti_opt.Delete_Flag)];
        Check_info{Info_Quantity + 4} = [' f(skull removal) = ' num2str(dti_opt.BET_1_f)]; 
        Check_info{Info_Quantity + 5} = [' LDH Neighborhood = ' num2str(dti_opt.LDH_Neighborhood)];
        Info_Quantity = Info_Quantity + 5;
    %     Info_Quantity = Info_Quantity + 1;
    %     Check_info{Info_Quantity} = [' Cropping Flag = ' num2str(dti_opt.Cropping_Flag)];
        if dti_opt.Cropping_Flag
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' Cropping Gap = ' num2str(dti_opt.NIIcrop_slice_gap)];
        end
    %     Info_Quantity = Info_Quantity + 1;
    %     Check_info{Info_Quantity} = [' Normalizing Flag = ' num2str(dti_opt.Normalizing_Flag)];
        if dti_opt.Normalizing_Flag
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' Normalizing Target = ' dti_opt.FAnormalize_target];
        end
    %     Info_Quantity = Info_Quantity + 1;
    %     Check_info{Info_Quantity} = [' Resampling Flag = ' num2str(dti_opt.Resampling_Flag)];
        if dti_opt.Resampling_Flag
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' Normalizing Resolution = ' num2str(dti_opt.applywarp_2_ref_fileName)];
        end
    %     Info_Quantity = Info_Quantity + 1;
    %     Check_info{Info_Quantity} = [' Smoothing Flag = ' num2str(dti_opt.Smoothing_Flag)];
        if dti_opt.Smoothing_Flag
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' Smoothing kernel = ' num2str(dti_opt.smoothNII_1_kernel_size)];
        end
    %     Info_Quantity = Info_Quantity + 1;
    %     Check_info{Info_Quantity} = [' Atlas Flag = ' num2str(dti_opt.Atlas_Flag)];
        if dti_opt.Atlas_Flag
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' White matter label altas = ' dti_opt.WM_Label_Atlas];
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' White matter probtract altas = ' dti_opt.WM_Probtract_Atlas];
        end
    %     Info_Quantity = Info_Quantity + 1;
    %     Check_info{Info_Quantity} = [' TBSS Flag = ' num2str(dti_opt.TBSS_Flag)];
        if dti_opt.TBSS_Flag == 1
            Info_Quantity = Info_Quantity + 1;
            Check_info{Info_Quantity} = [' Skeleton Cutoff = ' num2str(dti_opt.dismap_threshold)];
        end
        button = questdlg( Check_info, 'Please check!', 'Yes', 'No', 'No');
        if strcmp(button,'Yes')
            close;
        end
    else
        close;
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
global DiffusionOpt_ParametersChangeFlag;
TBSS_Flag_Previous = dti_opt.TBSS_Flag;
if get(hObject, 'value')
    if ~dti_opt.Normalizing_Flag
        dti_opt.Normalizing_Flag = 1;
        set( handles.NormalizingCheckBox, 'Value', 1);
        set( handles.NormalizeTargetEdit, 'Enable', 'on' );
        if ~isfield(dti_opt,'FAnormalize_target')
            dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        end
        set( handles.NormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
    end
    dti_opt.TBSS_Flag = 1;
    dti_opt.dismap_threshold = 0.2;
    set(handles.DismapThresholdEdit, 'Enable', 'on');
    set(handles.DismapThresholdEdit, 'String', '0.2');
else
    dti_opt.TBSS_Flag = 0;
    set(handles.DismapThresholdEdit, 'String', '');
    set(handles.DismapThresholdEdit, 'Enable', 'off');
end
if TBSS_Flag_Previous ~= dti_opt.TBSS_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


function DismapThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DismapThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DismapThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of DismapThresholdEdit as a double
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
dismap_threshold_Previous = dti_opt.dismap_threshold;
DismapThreshold = get(hObject, 'string');
if ~isempty(DismapThreshold)
    dti_opt.dismap_threshold = str2double(DismapThreshold);
else
    dti_opt.dismap_threshold = '';
end
if dismap_threshold_Previous ~= dti_opt.dismap_threshold
    DiffusionOpt_ParametersChangeFlag = 1;
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
    FontSizeUipanel = ceil(12 * PositionFigure(4) / 500);
    set( handles.PreprocessingUipanel, 'FontSize', FontSizeUipanel );
    set( handles.DiffusionMetricsUipanel, 'FontSize', FontSizeUipanel ); 
    FontSizeUipanel = ceil(12 * PositionFigure(4) / 580);
    set( handles.OrientationPatchUipanel, 'FontSize', FontSizeUipanel );
    set( handles.DeleteDataFromDICOMUipanel, 'FontSize', FontSizeUipanel );
    set( handles.LDHUipanel, 'FontSize', FontSizeUipanel );
    set( handles.SmoothingUipanel, 'FontSize', FontSizeUipanel );
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
global DiffusionOpt_ParametersChangeFlag;
WMProbtractAtlas_Previous = dti_opt.WM_Probtract_Atlas;
WMLabelAtlas_Text = get( handles.WMLabelAtlasEdit, 'string' );
if isempty(WMLabelAtlas_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the white matter label atlas path !');
else
    WMProbtractAtlasPath = get( handles.WMProbtractAtlasEdit, 'string' );
    dti_opt.WM_Probtract_Atlas = WMProbtractAtlasPath;
end
if ~strcmp(WMProbtractAtlas_Previous, dti_opt.WM_Probtract_Atlas)
    DiffusionOpt_ParametersChangeFlag = 1;
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
global DiffusionOpt_ParametersChangeFlag;
WMLabelAtlas_Previous = dti_opt.WM_Label_Atlas;
NormalizingTarget_Text = get( handles.NormalizeTargetEdit, 'string' );
if isempty(NormalizingTarget_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the normalizing target !');
else
    WMLabelAtlasPath = get( handles.WMLabelAtlasEdit, 'string' );
    dti_opt.WM_Label_Atlas = WMLabelAtlasPath;
end
if ~strcmp(WMLabelAtlas_Previous, dti_opt.WM_Label_Atlas)
    DiffusionOpt_ParametersChangeFlag = 1;
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
global DiffusionOpt_ParametersChangeFlag;
WMProbtractAtlas_Previous = dti_opt.WM_Probtract_Atlas;
WMLabelAtlas_Text = get( handles.WMLabelAtlasEdit, 'string' );
if isempty(WMLabelAtlas_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the white matter label atlas !');
else
    [WMProbtractAtlasFolderName ParentFolder] = uigetfile({'*.nii.gz','NIfTI-files (*.nii.gz)'});
    WMProbtractAtlasFolderPath = [ParentFolder WMProbtractAtlasFolderName];
    if ~isnumeric(WMProbtractAtlasFolderPath) 
        set( handles.WMProbtractAtlasEdit, 'string', WMProbtractAtlasFolderPath );
        dti_opt.WM_Probtract_Atlas = WMProbtractAtlasFolderPath;
    end
end
if ~strcmp(WMProbtractAtlas_Previous, dti_opt.WM_Probtract_Atlas)
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in WMLabelAtlasButton.
function WMLabelAtlasButton_Callback(hObject, eventdata, handles)
% hObject    handle to WMLabelAtlasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
WMLabelAtlas_Previous = dti_opt.WM_Label_Atlas;
NormalizingTarget_Text = get( handles.NormalizeTargetEdit, 'string' );
if isempty(NormalizingTarget_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the normalizing target !');
else
    [WMLabelAtlasFolderName ParentFolder] = uigetfile({'*.nii.gz','NIfTI-files (*.nii.gz)'});
    WMLabelAtlasFolderPath = [ParentFolder WMLabelAtlasFolderName];
    if ~isnumeric(WMLabelAtlasFolderPath) 
        set( handles.WMLabelAtlasEdit, 'string', WMLabelAtlasFolderPath );
        dti_opt.WM_Label_Atlas = WMLabelAtlasFolderPath;
    end
end
if ~strcmp(WMLabelAtlas_Previous, dti_opt.WM_Label_Atlas)
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in CroppingCheckBox.
function CroppingCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to CroppingCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CroppingCheckBox
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Cropping_Flag_Previous = dti_opt.Cropping_Flag;
if get(hObject, 'Value')
    dti_opt.Cropping_Flag = 1;
    if ~isfield(dti_opt,'NIIcrop_slice_gap')
        dti_opt.NIIcrop_slice_gap = 3;
    end
    set( handles.NIIcropSliceGapEdit, 'Enable', 'on' );
    set( handles.NIIcropSliceGapEdit, 'string', dti_opt.NIIcrop_slice_gap );
else
    dti_opt.Cropping_Flag = 0;
    set( handles.NIIcropSliceGapEdit, 'String', '' );
    set( handles.NIIcropSliceGapEdit, 'Enable', 'off' );
end
if Cropping_Flag_Previous ~= dti_opt.Cropping_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in NormalizingCheckBox.
function NormalizingCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizingCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NormalizingCheckBox
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Normalizing_Flag_Previous = dti_opt.Normalizing_Flag;
if get(hObject, 'Value')
    dti_opt.Normalizing_Flag = 1;
    if ~isfield(dti_opt,'FAnormalize_target')
        dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
    end
    set( handles.NormalizeTargetEdit, 'Enable', 'on' );
    set( handles.NormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
else
    % Parameters for normalizing
    dti_opt.Normalizing_Flag = 0;
    set( handles.NormalizingCheckBox, 'Value', 0);
    set( handles.NormalizeTargetEdit, 'String', '' );
    set( handles.NormalizeTargetEdit, 'Enable', 'off' );
    % Parameters for resampling
    dti_opt.Resampling_Flag = 0;
    set( handles.ResampleCheckBox, 'Value', 0);
    set( handles.ApplywarpResolutionEdit, 'string', '' );
    set( handles.ApplywarpResolutionEdit, 'Enable', 'off' );
    % Parameters for smoothing 
    dti_opt.Smoothing_Flag = 0;
    set( handles.SmoothingCheckBox, 'Value', 0);
    set( handles.SmoothKernelSizeEdit, 'String', '' );
    set( handles.SmoothKernelSizeEdit, 'Enable', 'off' );
    % Parameters for atlas
    dti_opt.Atlas_Flag = 0; 
    set( handles.AtlasCheckBox, 'Value', 0);
    set( handles.WMLabelAtlasEdit, 'String', '' );
    set( handles.WMLabelAtlasEdit, 'Enable', 'off' );
    set( handles.WMProbtractAtlasEdit, 'String', '' );
    set( handles.WMProbtractAtlasEdit, 'Enable', 'off' );
    % Parameters for TBSS
    dti_opt.TBSS_Flag = 0;
    set( handles.TbssCheckBox, 'Value', 0);
    set(handles.DismapThresholdEdit, 'String', '');
    set(handles.DismapThresholdEdit, 'Enable', 'off');
end
if Normalizing_Flag_Previous ~= dti_opt.Normalizing_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in ResampleCheckBox.
function ResampleCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ResampleCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ResampleCheckBox
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Resampling_Flag_Previous = dti_opt.Resampling_Flag;
if get(hObject, 'Value')
    if ~dti_opt.Normalizing_Flag
        dti_opt.Normalizing_Flag = 1;
        set( handles.NormalizingCheckBox, 'Value', 1);
        set( handles.NormalizeTargetEdit, 'Enable', 'on' );
        if ~isfield(dti_opt,'FAnormalize_target')
            dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        end
        set( handles.NormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
    end
    % Parameters for resampling
    dti_opt.Resampling_Flag = 1;
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
    set( handles.ApplywarpResolutionEdit, 'Enable', 'on' );
    ResolutionString = num2str(dti_opt.applywarp_2_ref_fileName);
    set( handles.ApplywarpResolutionEdit, 'string', ResolutionString);
else
    % Parameters for resampling
    dti_opt.Resampling_Flag = 0;
    set( handles.ApplywarpResolutionEdit, 'string', '' );
    set( handles.ApplywarpResolutionEdit, 'Enable', 'off' );
    % Parameters for smoothing 
    dti_opt.Smoothing_Flag = 0;
    set( handles.SmoothingCheckBox, 'Value', 0);
    set( handles.SmoothKernelSizeEdit, 'String', '' );
    set( handles.SmoothKernelSizeEdit, 'Enable', 'off' );
end
if Resampling_Flag_Previous ~= dti_opt.Resampling_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in SmoothingCheckBox.
function SmoothingCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothingCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SmoothingCheckBox
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Smoothing_Flag_Previous = dti_opt.Smoothing_Flag;
if get(hObject, 'Value')
    if ~dti_opt.Normalizing_Flag
        dti_opt.Normalizing_Flag = 1;
        set( handles.NormalizingCheckBox, 'Value', 1 );
        set( handles.NormalizeTargetEdit, 'Enable', 'on' );
        if ~isfield(dti_opt,'FAnormalize_target')
            dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        end
        set( handles.NormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
    end
    if ~dti_opt.Resampling_Flag
        dti_opt.Resampling_Flag = 1;
        set( handles.ResampleCheckBox, 'Value', 1 );
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
        set( handles.ApplywarpResolutionEdit, 'Enable', 'on' );
        ResolutionString = num2str(dti_opt.applywarp_2_ref_fileName);
        set( handles.ApplywarpResolutionEdit, 'string', ResolutionString);
    end
    dti_opt.Smoothing_Flag = 1;
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
    set( handles.SmoothKernelSizeEdit, 'Enable', 'on' );
    set( handles.SmoothKernelSizeEdit, 'string', num2str(dti_opt.smoothNII_4_kernel_size) );
else
    dti_opt.Smoothing_Flag = 0;
    set( handles.SmoothKernelSizeEdit, 'String', '' );
    set( handles.SmoothKernelSizeEdit, 'Enable', 'off' );
end
if Smoothing_Flag_Previous ~= dti_opt.Smoothing_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on button press in AtlasCheckBox.
function AtlasCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to AtlasCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AtlasCheckBox
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Atlas_Flag_Previous = dti_opt.Atlas_Flag;
if get(hObject, 'Value')
    if ~dti_opt.Normalizing_Flag
        dti_opt.Normalizing_Flag = 1;
        set( handles.NormalizingCheckBox, 'Value', 1);
        set( handles.NormalizeTargetEdit, 'Enable', 'on' );
        if ~isfield(dti_opt,'FAnormalize_target')
            dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        end
        set( handles.NormalizeTargetEdit, 'string', dti_opt.FAnormalize_target );
    end
    dti_opt.Atlas_Flag = 1;
    if ~isfield(dti_opt,'WM_Label_Atlas')
        dti_opt.WM_Label_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
    end
    set( handles.WMLabelAtlasEdit, 'Enable', 'on' );
    set( handles.WMLabelAtlasEdit, 'string', dti_opt.WM_Label_Atlas );
    set( handles.WMLabelAtlasButton, 'Enable', 'on' );
    if ~isfield(dti_opt,'WM_Probtract_Atlas')
        dti_opt.WM_Probtract_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
    end
    set( handles.WMProbtractAtlasEdit, 'Enable', 'on' );
    set( handles.WMProbtractAtlasEdit, 'string', dti_opt.WM_Probtract_Atlas );
    set( handles.WMProbtractAtlasButton, 'Enable', 'on' );
else
    dti_opt.Atlas_Flag = 0; 
    set( handles.WMLabelAtlasEdit, 'String', '' );
    set( handles.WMLabelAtlasEdit, 'Enable', 'off' );
    set( handles.WMLabelAtlasButton, 'Enable', 'off' );
    set( handles.WMProbtractAtlasEdit, 'String', '' );
    set( handles.WMProbtractAtlasEdit, 'Enable', 'off' );
    set( handles.WMProbtractAtlasButton, 'Enable', 'off' );
end
if Atlas_Flag_Previous ~= dti_opt.Atlas_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


function RawDataResampleResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RawDataResampleResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawDataResampleResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of RawDataResampleResolutionEdit as a double
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
RawDataResampleResolution_Preivous = dti_opt.RawDataResampleResolution;
RawDataResampleResolutionString = get(hObject, 'string');
if ~isempty(RawDataResampleResolutionString)
    dti_opt.RawDataResampleResolution = eval(RawDataResampleResolutionString);
else
    dti_opt.RawDataResampleResolution = '';
end
if length(dti_opt.RawDataResampleResolution) ~= 3
    msgbox('The input is illegal !');
    dti_opt.RawDataResampleResolution = '';
    set(hObject, 'String', '');
end
if length(RawDataResampleResolution_Preivous) ~= length(dti_opt.RawDataResampleResolution)
    DiffusionOpt_ParametersChangeFlag = 1;
elseif RawDataResampleResolution_Preivous ~= dti_opt.RawDataResampleResolution
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function RawDataResampleResolutionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RawDataResampleResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in RawDataResampleCheckbox.
function RawDataResampleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to RawDataResampleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RawDataResampleCheckbox
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
RawDataResample_Flag_Previous = dti_opt.RawDataResample_Flag;
if get(hObject, 'Value')
    dti_opt.RawDataResample_Flag = 1;
    if ~isfield(dti_opt,'RawDataResampleResolution')
        dti_opt.RawDataResampleResolution = [2 2 2];
    end
    set( handles.RawDataResampleResolutionEdit, 'Enable', 'on' );
    set( handles.RawDataResampleResolutionEdit, 'string', mat2str(dti_opt.RawDataResampleResolution) );
else
    dti_opt.RawDataResample_Flag = 0;
    set( handles.RawDataResampleResolutionEdit, 'String', '' );
    set( handles.RawDataResampleResolutionEdit, 'Enable', 'off' );
end
if RawDataResample_Flag_Previous ~= dti_opt.RawDataResample_Flag
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes on selection change in InversionMenu.
function InversionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to InversionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InversionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InversionMenu
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Inversion_Preivous = dti_opt.Inversion;
sel = get(hObject, 'value');
switch sel
    case 1
        dti_opt.Inversion = 'No Inversion';
    case 2
        dti_opt.Inversion = 'Invert X';
    case 3
        dti_opt.Inversion = 'Invert Y';
    case 4
        dti_opt.Inversion = 'Invert Z';
end
if ~strcmp(Inversion_Preivous, dti_opt.Inversion)
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function InversionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InversionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on selection change in SwapMenu.
function SwapMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SwapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SwapMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SwapMenu
global dti_opt;
global DiffusionOpt_ParametersChangeFlag;
Swap_Previous = dti_opt.Swap;
sel = get(hObject, 'value');
switch sel
    case 1
        dti_opt.Swap = 'No Swap';
    case 2
        dti_opt.Swap = 'Swap X/Y';
    case 3
        dti_opt.Swap = 'Swap Y/Z';
    case 4
        dti_opt.Swap = 'Swap Z/X';
end
if ~strcmp(Swap_Previous, dti_opt.Swap)
    DiffusionOpt_ParametersChangeFlag = 1;
end


% --- Executes during object creation, after setting all properties.
function SwapMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SwapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes when selected object is changed in LDHUipanel.
function LDHUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in LDHUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dti_opt;
global LockFlag;
global LDHTagPrevious;
global DiffusionOpt_ParametersChangeFlag;
LDHNeighborhood_Previous = dti_opt.LDH_Neighborhood;
if LockFlag == 0
    switch get( hObject, 'Tag')
        case 'SevenRadio'
            dti_opt.LDH_Neighborhood = 7;
        case 'NineteenRadio'
            dti_opt.LDH_Neighborhood = 19;
        case 'TwentySevenRadio'
            dti_opt.LDH_Neighborhood = 27;
    end
    if LDHNeighborhood_Previous ~= dti_opt.LDH_Neighborhood
        DiffusionOpt_ParametersChangeFlag = 1;
    end
else
    switch LDHTagPrevious
        case 'SevenRadio'
            set( handles.SevenRadio, 'Value', 1 );
        case 'NineteenRadio'
            set( handles.NineteenRadio, 'Value', 1 );
        case 'TwentySevenRadio'
            set( handles.TwentySevenRadio, 'Value', 1 );
    end
end
