function varargout = PANDA_Utilities(varargin)
% GUI for PANDA_Utilities, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_UTILITIES MATLAB code for PANDA_Utilities.fig
%      PANDA_UTILITIES, by itself, creates a new PANDA_UTILITIES or raises the existing
%      singleton*.
%
%      H = PANDA_UTILITIES returns the handle to a new PANDA_UTILITIES or the handle to
%      the existing singleton*.
%
%      PANDA_UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_UTILITIES.M with the given input arguments.
%
%      PANDA_UTILITIES('Property','Value',...) creates a new PANDA_UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Utilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Utilities

% Last Modified by GUIDE v2.5 11-Sep-2013 13:23:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Utilities_OutputFcn, ...
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


% --- Executes just before PANDA_Utilities is made visible.
function PANDA_Utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Utilities (see VARARGIN)

% Choose default command line output for PANDA_Utilities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_Utilities wait for user response (see UIRESUME)
% uiwait(handles.UtilitiesFigure);
%
ScreenSize = get(0,'screensize');
Position_1 = 0.45 * ScreenSize(3) - 246;
Position_2 = 0.3 * ScreenSize(4);
set(gcf, 'Position', [Position_1, Position_2, 242, 538]);
%
TipStr = sprintf(['Reference: Gong G (2013) Local Diffusion Homogeneity (LDH): An Inter-Voxel' ...
    '\n Diffusion MRI Metric for Assessing Inter-Subject White Matter Variability.' ...
    '\n PLoS ONE 8(6): e66366. doi:10.1371/journal.pone.0066366']);
set(handles.LDHButton, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Utilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PANDA_TBSSButton.
function PANDA_TBSSButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_TBSSButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_TBSS;


% --- Executes on button press in PANDA_BedpostxButton.
function PANDA_BedpostxButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_BedpostxButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Bedpostx;


% --- Executes on button press in PANDA_FiberTrackingButton.
function PANDA_FiberTrackingButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_FiberTrackingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Tracking;


% --- Executes on button press in PANDA_NetworkNodeButton.
function PANDA_NetworkNodeButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_NetworkNodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_BrainParcellation;


% --- Executes on button press in PANDA_ImageFormatConvertButton.
function PANDA_ImageFormatConvertButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ImageFormatConvertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ImageConverter;


% --- Executes on button press in PANDA_DICOMSorterButton.
function PANDA_DICOMSorterButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_DICOMSorterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_DICOMSorter;


% --- Executes on button press in CopyFilesButton.
function CopyFilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to CopyFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_FileCopier;


% --- Executes on button press in PANDA_T1BrainExtractionButton.
function PANDA_T1BrainExtractionButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_T1BrainExtractionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_T1BrainExtraction;


% --- Executes on button press in PANDA_ResampleImageButton.
function PANDA_ResampleImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ResampleImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ResampleNIfTI;


% --- Executes on button press in PANDA_DICOMINfTIButton.
function PANDA_DICOMINfTIButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_DICOMINfTIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_DICOMToNIfTI;


% --- Executes on button press in PANDA_TestBvecsButton.
function PANDA_TestBvecsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_TestBvecsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_TestBvecs;


% --- Executes on button press in PANDA_FullPipeline.
function PANDA_FullPipeline_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_FullPipeline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA;



function QuitAll()
% Close Tracking & Network figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDATrackingFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close the monitor table of Tracking & Network figure.
theFig =findobj(allchild(0),'flat','Tag','PANDATrackingStatusFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Brain Parcellation figure.
theFig =findobj(allchild(0),'flat','Tag','PANDABrainParcellationFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Bedpostx figure.
theFig =findobj(allchild(0),'flat','Tag','PANDABedpostxFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close TBSS figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDATBSSFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Brain Extraction (T1) figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDAT1BrainExtractionFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Test Bvecs figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDATestBvecsFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Resample NIfTI figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDAResampleFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Image Converter figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDAImageFormatConvertFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close DICOM->NIfTI figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDADICOMNIfTIFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close DICOM Sorter figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDADICOMSorterFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close File Copyer figure. 
theFig =findobj(allchild(0),'flat','Tag','PANDAFilesCopyerFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close LDH figure.
theFig =findobj(allchild(0),'flat','Tag','PANDALDHFigure');
if ~isempty(theFig) 
    delete(theFig);
end


% --- Executes when user attempts to close UtilitiesFigure.
function UtilitiesFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to UtilitiesFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
QuitAll();
delete(hObject);


% --- Executes on button press in LDHButton.
function LDHButton_Callback(hObject, eventdata, handles)
% hObject    handle to LDHButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_LDH;
