function varargout = PANDA_MoreUtilities(varargin)
% GUI for PANDA_MoreUtilities, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_MOREUTILITIES MATLAB code for PANDA_MoreUtilities.fig
%      PANDA_MOREUTILITIES, by itself, creates a new PANDA_MOREUTILITIES or raises the existing
%      singleton*.
%
%      H = PANDA_MOREUTILITIES returns the handle to a new PANDA_MOREUTILITIES or the handle to
%      the existing singleton*.
%
%      PANDA_MOREUTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_MOREUTILITIES.M with the given input arguments.
%
%      PANDA_MOREUTILITIES('Property','Value',...) creates a new PANDA_MOREUTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_MoreUtilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_MoreUtilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_MoreUtilities

% Last Modified by GUIDE v2.5 22-Jul-2015 19:29:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_MoreUtilities_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_MoreUtilities_OutputFcn, ...
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


% --- Executes just before PANDA_MoreUtilities is made visible.
function PANDA_MoreUtilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_MoreUtilities (see VARARGIN)

% Choose default command line output for PANDA_MoreUtilities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_MoreUtilities wait for user response (see UIRESUME)
% uiwait(handles.PANDAOtherUtilitiesFigure);
%
ScreenSize = get(0,'screensize');
Position_1 = 0.45 * ScreenSize(3);
Position_2 = 0.3 * ScreenSize(4);
set(gcf, 'Position', [Position_1, Position_2, 242, 370]);
%
TipStr = sprintf(['Reference: Gong G (2013) Local Diffusion Homogeneity (LDH): An Inter-Voxel' ...
    '\n Diffusion MRI Metric for Assessing Inter-Subject White Matter Variability.' ...
    '\n PLoS ONE 8(6): e66366. doi:10.1371/journal.pone.0066366']);
set(handles.PANDA_ImageConverterButton, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_MoreUtilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function QuitAll()
% % Close Tracking & Network figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDATrackingFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close the monitor table of Tracking & Network figure.
% theFig =findobj(allchild(0),'flat','Tag','PANDATrackingStatusFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Brain Parcellation figure.
% theFig =findobj(allchild(0),'flat','Tag','PANDABrainParcellationFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Bedpostx figure.
% theFig =findobj(allchild(0),'flat','Tag','PANDABedpostxFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close TBSS figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDATBSSFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Brain Extraction (T1) figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDAT1BrainExtractionFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Test Bvecs figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDATestBvecsFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Resample NIfTI figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDAResampleFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Image Converter figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDAImageFormatConvertFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close DICOM->NIfTI figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDADICOMNIfTIFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close DICOM Sorter figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDADICOMSorterFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close File Copyer figure. 
% theFig =findobj(allchild(0),'flat','Tag','PANDAFilesCopyerFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close LDH figure.
% theFig =findobj(allchild(0),'flat','Tag','PANDALDHFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end


% --- Executes when user attempts to close PANDAOtherUtilitiesFigure.
function PANDAOtherUtilitiesFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDAOtherUtilitiesFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% QuitAll();
delete(hObject);


% --- Executes on button press in PANDA_ImageConverterButton.
function PANDA_ImageConverterButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ImageConverterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ImageConverter;


% --- Executes on button press in PANDA_FileCopierButton.
function PANDA_FileCopierButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_FileCopierButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_FileCopier;


% --- Executes on button press in PANDA_AvgExtract.
function PANDA_AvgExtract_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_AvgExtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_AvgExtract;


% --- Executes on button press in PANDA_MapAtlas.
function PANDA_MapAtlas_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_MapAtlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_MapAtlas;


% --- Executes on button press in PANDA_MergeNIfTI.
function PANDA_MergeNIfTI_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_MergeNIfTI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_MergeNIfTI;


% % --- Executes on button press in PANDA_MergeVector.
% function PANDA_MergeVector_Callback(hObject, eventdata, handles)
% % hObject    handle to PANDA_MergeVector (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% PANDA_MergeVector;


% --- Executes on button press in PANDA_ClusterReport.
function PANDA_ClusterReport_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ClusterReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ClusterLocater;


% --- Executes on button press in PANDA_ROIExtract.
function PANDA_ROIExtract_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ROIExtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ROIExtract;


% --- Executes on button press in PANDA_WMMask.
function PANDA_WMMask_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_WMMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_WhiteMatterMask;


% % --- Executes on button press in PANDA_FDRCorr.
% function PANDA_FDRCorr_Callback(hObject, eventdata, handles)
% % hObject    handle to PANDA_FDRCorr (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PANDA_ImageSmootherButton.
function PANDA_ImageSmootherButton_Callback(hObject, eventdata, handles)
% hObject    handle to PANDA_ImageSmootherButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_ImageSmoother;


% % --- Executes on button press in PANDA_ImageThresholderButton.
% function PANDA_ImageThresholderButton_Callback(hObject, eventdata, handles)
% % hObject    handle to PANDA_ImageThresholderButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% % --- Executes on button press in PANDA_MatrixCalculatorButton.
% function PANDA_MatrixCalculatorButton_Callback(hObject, eventdata, handles)
% % hObject    handle to PANDA_MatrixCalculatorButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
