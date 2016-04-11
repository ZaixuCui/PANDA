function varargout = PANDA(varargin)
% GUI for software PANDA(Pipeline for Analysing braiN Diffusion imAges), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA MATLAB code for PANDA.fig
%      PANDA, by itself, creates a new PANDA or raises the existing
%      singleton*.
%
%      H = PANDA returns the handle to a new PANDA or the handle to
%      the existing singleton*.
%
%      PANDA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA.M with the given input arguments.
%
%      PANDA('Property','Value',...) creates a new PANDA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to runbutton (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA

% Last Modified by GUIDE v2.5 14-Oct-2012 21:23:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_OutputFcn, ...
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


% --- Executes just before PANDA is made visible.
function PANDA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA (see VARARGIN)

% Choose default command line output for PANDA
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global TensorPrefixEdit;
global pipeline_opt;
global dti_opt;
global tracking_opt;
global QuantityOfCpu;
global Utilities_Click;
global PANDAPath;
global PANDAMonitorMain_Realtime;

disp('Citing information:');
disp('If PANDA is uesd in your work, please cite it in your paper.');
disp('Reference: Cui Z, Zhong S, Xu P, He Y and Gong G (2013) PANDA: a pipeline toolbox for analyzing brain diffusion images. Front. Hum. Neurosci. 7:42. doi: 10.3389/fnhum.2013.00042');
disp('If LDH metric is used in your work, please cite it in your paper.');
disp('Reference: Gong G (2013) Local Diffusion Homogeneity (LDH): An Inter-Voxel Diffusion MRI Metric for Assessing Inter-Subject White Matter Variability. PLoS ONE 8(6): e66366. doi:10.1371/journal.pone.0066366');

PANDAMonitorMain_Realtime = 1;
set(handles.RealtimeCheckbox, 'Value', 1);
set(handles.StatusUpdateButton, 'Enable', 'off');

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

Utilities_Click = 0;

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA wait for user response (see UIRESUME)
% uiwait(handles.PANDAFigure);
% % Clear the value Data_Raw_Path_Cell stored
% Data_Raw_Path_Cell = '';
% % Clear the value SubjectIDArray stored
% SubjectIDArray = '';
% % Clear the value DestinationPath_Edit stored
% DestinationPath_Edit = '';
% % Clear the value TensorPrefixEdit stored
% TensorPrefixEdit = '';

% Set the initial value of pipeline_opt as default
pipeline_opt.mode = 'background';
% Calculate the quantity of cpu
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
pipeline_opt.flag_verbose = 0;
pipeline_opt.flag_pause = 0;

% Set the initial value of dti_opt as default
dti_opt.BET_1_f = 0.25;
dti_opt.BET_2_f = 0.25;
% Default, we will delete raw nii converted from DICOM
dti_opt.Delete_Flag = 1;
% Default value of cropping gap
dti_opt.Cropping_Flag = 1;
dti_opt.NIIcrop_slice_gap = 3;

% Default value of resampling the raw data
dti_opt.RawDataResample_Flag = 0;
dti_opt.RawDataResampleResolution = [2 2 2];
% Default value of orientation patch
dti_opt.Inversion = 'No Inversion';
dti_opt.Swap = 'No Swap';
% Default value of LDH
dti_opt.LDH_Flag = 1;
dti_opt.LDH_Neighborhood = 7;
% Default value of normalizing
dti_opt.Normalizing_Flag = 1;
dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
dti_opt.applywarp_1_ref_fileName = 1;
dti_opt.applywarp_3_ref_fileName = 1;
dti_opt.applywarp_5_ref_fileName = 1;
dti_opt.applywarp_7_ref_fileName = 1;
% Default value of resampling
dti_opt.Resampling_Flag = 1;
dti_opt.applywarp_2_ref_fileName = 2;
dti_opt.applywarp_4_ref_fileName = 2;
dti_opt.applywarp_6_ref_fileName = 2;
dti_opt.applywarp_8_ref_fileName = 2;
% Default value of smoothing
dti_opt.Smoothing_Flag = 1;
dti_opt.smoothNII_1_kernel_size = 6;
dti_opt.smoothNII_2_kernel_size = 6;
dti_opt.smoothNII_3_kernel_size = 6;
dti_opt.smoothNII_4_kernel_size = 6;
% Default for altas
dti_opt.Atlas_Flag = 1;
dti_opt.WM_Label_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
dti_opt.WM_Probtract_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
% Default, we will not do tbss
dti_opt.TBSS_Flag = 0;

% Set the initial value of tracking_opt as default
tracking_opt.DterminFiberTracking = 0;
tracking_opt.NetworkNode = 0;
tracking_opt.PartitionOfSubjects = 0;
tracking_opt.T1 = 0;
tracking_opt.DeterministicNetwork = 0;
tracking_opt.BedpostxProbabilisticNetwork = 0;

% Set icon
SetIcon(handles); 
%
TipStr = sprintf(['Input subjects'' source folders:' ...
    '\n Under each folder, there should be multiple / single subdirectories,' ...
    '\n each of which contains DICOM / NIfTI for one sequence.']);
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
TipStr = sprintf(['Real time: the monitor table will refresh every 10 seconds.' ...
    '\n Non real time: the monitor table will not refresh until the ' ...
    '\n ''Refresh'' button is clicked.']);
set(handles.RealtimeCheckbox, 'TooltipString', TipStr);
%
TipStr = sprintf('Options for environment of running PANDA.');
set(handles.PipelineOptionsButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Options for basic data processing and calculating' ...
    '\n diffusion metrics for statistics.']);
set(handles.DTIOptionsButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Options for fiber tracking and network construction.' ...
    '\n (Deterministic and Probabilistic)']);
set(handles.FiberTrackingButton, 'TooltipString', TipStr);
% %
% TipStr = sprintf(['Save the path of the raw DICOM / NIfTI, the path' ...
%     '\n of each subjetc'' results and all the parameters' ...
%     '\n in a file with extension of .PANDA.']);
% set(handles.SaveButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Load .PANDA file to display the information in' ...
    '\n the GUI.']);
set(handles.LoadButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['After clicking the button, the path of the raw' ...
    '\n DICOM / NIfTI, the path of each subjects'' results'...
    '\n and all the parameters will be saved in a .PANDA' ...
    '\n file under the path {Result_Path} / logs']);
set(handles.RUNButton, 'TooltipString', TipStr);
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
ScreenSize = get(0,'screensize');
Position_1 = 0.45 * ScreenSize(3);
Position_2 = 0.3 * ScreenSize(4);
set(gcf, 'Position', [Position_1, Position_2, 460, 538]);

% Open Utilities
PANDA_Utilities;


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
FSLDIR = getenv('FSLDIR');
if isempty(FSLDIR)
    msg{1} = 'Please install FSL first !';
    msg{2} = 'http://fsl.fmrib.ox.ac.uk/fsldownloads/fsldownloadmain.html';
    msg{3} = 'Download Centos version for Linux(Ubuntu, Centos, RedHat, Fedora, ...) and MAC version for MAC !';
    msgbox(msg);
    
    % Close Diffusion Opt figure.
    theFig =findobj(allchild(0),'flat','Tag','UtilitiesFigure');
    if ~isempty(theFig) 
        delete(theFig);
    end
    
    delete(hObject);
    
end


% --- Executes on button press in RawDataPathButton.
function RawDataPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to RawDataPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select the folder of the raw data
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global TensorPrefixEdit;

Data_Raw_Path_Cell_Origin = Data_Raw_Path_Cell;
DataRawPathCell_Button = get(hObject, 'UserData');
[a, Data_Raw_Path_Cell, Done] = PANDA_Select('dir', DataRawPathCell_Button);
if Done == 1
    set( handles.RawDataPathButton, 'UserData', Data_Raw_Path_Cell);
    for i = 1:length(Data_Raw_Path_Cell)  
        if length(Data_Raw_Path_Cell{i}) > 255
            Info{1} = ['The quantity of characters of ' num2str(i) ' subject is more than 255.'];
            Info{2} = 'Please correct.';
            msgbox(Info);
            return;
        else
            DirFileInfo = dir(Data_Raw_Path_Cell{i});
            if all(1 - [DirFileInfo(3:end).isdir])
                msgbox(['The input for the ' num2str(i) ' subject is illegal.']);
                Data_Raw_Path_Cell = '';
                return;
            end
        end
    end

    if ~isempty(Data_Raw_Path_Cell)
        set( handles.RawPath_DestPath, 'data', Data_Raw_Path_Cell );
        ResizeRawDestTable(handles);
        SubjectIDArray = '';
        DestinationPath_Edit = '';
        TensorPrefixEdit = '';
        set( handles.DestinationPathEdit, 'String', '' );
        set( handles.SubjectIDEdit, 'String', '' );
        set( handles.TensorPrefixEdit, 'String', '' );
    else
        % If Data_Raw_Path_Cell has value, and user open the cfg_getfile, do
        % nothing but close, the cfg_getfile will return '', so
        % Data_Raw_Path_Cell will be ''. So the Data_Raw_Path_Cell lose its
        % orgine value
        % So for this situation, we assign the orgine value to
        % Data_Raw_Path_Cell
        Data_Raw_Path_Cell = Data_Raw_Path_Cell_Origin;
    end
end


% --- Executes on button press in DestinationPathButton.
function DestinationPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to DestinationPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global DestinationPath_Edit;
global SubjectIDArray;
% Check whether the path is a folder,user can input without DirSelect GUI 
if isempty(Data_Raw_Path_Cell)
    msgbox('Please input the raw data path!');
else
    FileExist = 1;
    for i = 1:length(Data_Raw_Path_Cell)
        if ~exist(Data_Raw_Path_Cell{i}, 'dir')
            FileExist = 0;
            break;
        end
    end
    if ~FileExist
        msgbox( 'Some folders do not exist !' );
        set( hObject, 'string', '');
    end
    
    if FileExist
        % Display Data_Raw_Path_Cell in the table
        set( handles.RawPath_DestPath, 'data', Data_Raw_Path_Cell );

        DestinationPath_Select = uigetdir;
        if DestinationPath_Select ~= 0
            % Check whether the path is a folder
            set( handles.DestinationPathEdit, 'string', DestinationPath_Select );
            % Pick the destion path from edit text
            % User can input without selecting from DirSelect GUI
            DestinationPath_Edit = DestinationPath_Select;
            LogPath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
            if exist(LogPath, 'file')
                info{1} = 'A lock of pipeline is already exist in this result path!';
                info{2} = 'To restart the existed pipeline, please select Yes !';
                info{3} = 'To start a new pipeline delete the existed pipeline, please select No !';
                button = questdlg(info,'Start a new one or restart the existed one ?','Yes','No','Yes');
                switch button
                    case 'Yes'
                        system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock']);
                    case 'No'
                        system(['rm -R ' DestinationPath_Edit filesep]);
                        mkdir(DestinationPath_Edit);
                        return;
                end
            end

            if ~isempty(SubjectIDArray)

    %             % Judge whther the quantity of the subjects is equal to the quantity of the
    %             % subjects id
    %             if length(Data_Raw_Path_Cell) ~= length(SubjectIDArray)
    %                 msgbox('I am sorry, the quantity of the subjects is equal to the quantity of the subjects id!');
    %                 error( 'not match!' );
    %             end
                % Combine Destination path to Subject id 
                DestiantionPath_Subject = cell(length(SubjectIDArray),1);
                for i = 1:length(SubjectIDArray)
                    DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
                end
                % Display the raw data path and the destination path in the table
                RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];

                set( handles.RawPath_DestPath, 'data', RawData_Destination );
                ResizeRawDestTable(handles);

            end
        end
    end
end


function DestinationPathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DestinationPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DestinationPathEdit as text
%        str2double(get(hObject,'String')) returns contents of DestinationPathEdit as a double
% Store the data of the subjects in a cell named Data_Raw_Path_Cell
global Data_Raw_Path_Cell;
global DestinationPath_Edit;
global SubjectIDArray

% Pick the destion path from edit text
% User can input without selecting from DirSelect GUI
DestinationPath_Edit_New = get( hObject, 'string' );
if ~isempty(DestinationPath_Edit) & ~strcmp(DestinationPath_Edit, DestinationPath_Edit_New)
    button = questdlg('Destination path is changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
    case 'Yes'    
%         if exist([DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'],'file')
%             system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock']);
%             DestinationPath_Edit = DestinationPath_Edit_New;
%         else
        DestinationPath_Edit = DestinationPath_Edit_New;
%         end
    case 'No'
        set(hObject, 'string', DestinationPath_Edit);
        return;
    end
elseif isempty(DestinationPath_Edit)
    DestinationPath_Edit = DestinationPath_Edit_New;
end
if ~isempty(DestinationPath_Edit)
    LogPath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
    if exist(LogPath, 'file')
        info{1} = 'A lock of pipeline is already exist in this result path!';
        info{2} = 'To restart the existed pipeline, please select Yes !';
        info{3} = 'To start a new pipeline delete the existed pipeline, please select No !';
        button = questdlg(info,'Start a new one or restart the existed one ?','Yes','No','Yes');
        switch button
        case 'Yes'
            system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock']);
        case 'No'
            system(['rm -R ' DestinationPath_Edit filesep]);
            mkdir(DestinationPath_Edit);
            return;
        end
    end
end
% Acquire the id of subjects
SubjectID_Text = get( handles.SubjectIDEdit, 'string' );
if ~isempty(SubjectID_Text)

    SubjectIDArray = eval( SubjectID_Text );
    % Combine Destination path to Subject id 
    DestiantionPath_Subject = cell(length(SubjectIDArray),1);
    for i = 1:length(SubjectIDArray)
        DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
    end
    if length(Data_Raw_Path_Cell) ~= length(SubjectIDArray)
        set( handles.SubjectIDEdit, 'string', '' );
        SubjectID_Text = '';
        SubjectIDArray = '';
    else
        % Display the raw data path and the destination path in the table
        RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];

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


% --- Executes on key press with focus on DestinationPathEdit and none of its controls.
function DestinationPathEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to DestinationPathEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
if isempty(Data_Raw_Path_Cell)
    msgbox( 'Please select the raw data path!' );
    set( hObject, 'string', '');
else
    FileExist = 1;
    for i = 1:length(Data_Raw_Path_Cell)
        if ~exist(Data_Raw_Path_Cell{i}, 'dir')
            FileExist = 0;
            break;
        end
    end
    if ~FileExist
        msgbox( 'Some folders do not exist !' );
        set( hObject, 'string', '');
    end
end


function SubjectIDEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubjectIDEdit as text
%        str2double(get(hObject,'String')) returns contents of SubjectIDEdit as a double
global Data_Raw_Path_Cell;
global DestinationPath_Edit;
global SubjectIDArray;

SubjectID_Text = mat2str(SubjectIDArray);
% Acquire the id of subjects
SubjectID_Text_New = get( hObject, 'string' );
if ~isempty(SubjectIDArray) & ~strcmp(SubjectID_Text, SubjectID_Text_New)
    button = questdlg('Subjects ID are changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
    case 'Yes'
        SubjectID_Text = SubjectID_Text_New;
    case 'No'
        set(hObject, 'string', SubjectID_Text);
        return;
    end
end
if isempty(SubjectIDArray)
    SubjectID_Text = SubjectID_Text_New;
end
if ~isempty(SubjectID_Text)
    % Pick the destion path from edit text
    % User can input without selecting from DirSelect GUI
    DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );

    try
        SubjectIDArray = eval( SubjectID_Text );
        set( hObject, 'string', mat2str(SubjectIDArray) );
        % Judge whther the quantity of the subjects is equal to the quantity of the
        % subjects id
        if length(Data_Raw_Path_Cell) ~= length(SubjectIDArray)
            info{1} = ['Your subject IDs are ' mat2str(SubjectIDArray)];
            info{2} = 'I am sorry, the quantity of the subjects is not equal to the quantity of the subjects IDs!';
            info{3} = 'I will delete the subject IDs, please input subject IDs again!';
            msgbox(info);
            set( hObject, 'string', '' );
            SubjectID_Text = '';
            SubjectIDArray = '';
        else
             % Combine Destination path to Subject id 
            DestiantionPath_Subject = cell(length(SubjectIDArray),1);
            for i = 1:length(SubjectIDArray)
                DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
            end
            % Display the raw data path and the destination path in the table
            %save x.mat Data_Raw_Path_Cell DestiantionPath_Subject
            RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];

            set( handles.RawPath_DestPath, 'data', RawData_Destination );
            ResizeRawDestTable(handles);
        end    
    catch
        msgbox('The subjects id you input is illegal');
        set(hObject, 'string', '');
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


% --- Executes on key press with focus on SubjectIDEdit and none of its controls.
function SubjectIDEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );
if isempty(DestinationPath_Edit)
    set( hObject, 'string', '');
    msgbox( 'Please input the destination path!' );
end


function TensorPrefixEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TensorPrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TensorPrefixEdit as text
%        str2double(get(hObject,'String')) returns contents of TensorPrefixEdit as a double
global TensorPrefixEdit;

TensorPrefixEdit_New = get(hObject, 'string');
if ~isempty(TensorPrefixEdit) & ~strcmp(TensorPrefixEdit, TensorPrefixEdit_New)
    button = questdlg('Tensor prefix is changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
    case 'Yes'
        TensorPrefixEdit = TensorPrefixEdit_New;
    case 'No'
        set(hObject, 'string', TensorPrefixEdit);
        return;
    end
end
if isempty(TensorPrefixEdit)
    TensorPrefixEdit = TensorPrefixEdit_New;
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


% --- Executes on key press with focus on TensorPrefixEdit and none of its controls.
function TensorPrefixEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to TensorPrefixEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global DestinationPath_Edit;
global SubjectIDArray;
SubjectID_Text = get( handles.SubjectIDEdit, 'string' );
if isempty(SubjectID_Text)
    set( hObject, 'string', '' );
    msgbox('Please input the subjects ID!');
else
    % Pick the destion path from edit text
    % User can input without selecting from DirSelect GUI
    DestinationPath_Edit = get( handles.DestinationPathEdit, 'string' );

    SubjectIDArray = eval( SubjectID_Text );
    % Combine Destination path to Subject id 
    DestiantionPath_Subject = cell(length(SubjectIDArray),1);
    for i = 1:length(SubjectIDArray)
        DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
    end
     %Display the raw data path and the destination path in the table
    %save x.mat Data_Raw_Path_Cell DestiantionPath_Subject
    RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];
    %save x.mat RawData_Destination

    set( handles.RawPath_DestPath, 'data', RawData_Destination );
    ResizeRawDestTable(handles);
end


% --- Executes on button press in PipelineOptionsButton.
function PipelineOptionsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PipelineOptionsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Pipeline_Opt;


% --- Executes on button press in DTIOptionsButton.
function DTIOptionsButton_Callback(hObject, eventdata, handles)
% hObject    handle to DTIOptionsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Diffusion_Opt;


% --- Executes on button press in RUNButton.
function RUNButton_Callback(hObject, eventdata, handles)
% hObject    handle to RUNButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global SubjectIDArray;
global SubjectIDArrayString;
global DestinationPath_Edit;
global TensorPrefixEdit;
global pipeline_opt;
global dti_opt;
global tracking_opt;
global LoadFlag;
global StopFlag;
global T1orPartitionOfSubjectsPathCellMain;
global FAPathCellMain;
global JobStatusMonitorTimerMain;
global JobName;
global LockExistMain;
global LockDisappearMain;
global Count;
global LoadFlag;
global PANDAPath;
Count = 0;
LoadFlag = 0;

[PANDAPath, y, z] = fileparts(which('PANDA.m'));

LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if exist(LockFilePath, 'file') | strcmp(get(handles.RawDataPathButton, 'Enable'),'off')
    StringPrint{1} = ['A lock file ' LockFilePath ' has been found on the pipeline !'];
    StringPrint{2} = 'If you want to run this new pipeline, ';
    StringPrint{3} = ['please delete the lock file ' LockFilePath ' first !'];
    msgbox(StringPrint);
else
    if isempty(Data_Raw_Path_Cell)
        msgbox( 'Please select the raw data path!' );
    elseif isempty(DestinationPath_Edit)
        msgbox( 'Please input the destination path!' );
    elseif isempty(SubjectIDArray)
        msgbox( 'Please input the subjects ID!' );
    else
        LogPathPermissionDenied = 0;
        try
            if ~exist(DestinationPath_Edit, 'dir')
                mkdir(DestinationPath_Edit);
            end
            if ~exist([DestinationPath_Edit filesep 'logs'], 'dir')
                mkdir([DestinationPath_Edit filesep 'logs']);
            end
            x = 1;
            save([DestinationPath_Edit filesep 'logs' filesep 'permission_tag.mat'], 'x');
        catch
            LogPathPermissionDenied = 1;
            msgbox('Please change destination path, permission denied !');
        end
        if ~LogPathPermissionDenied
            info{1} = 'Are you sure to Run ?';
            button = questdlg( info ,'Sure to Run ?','Yes','No','Yes' );
            switch button
                case 'Yes'
                    % Save the configuration
                    DateNow = datevec(datenum(now));
                    DateNowString = [num2str(DateNow(1)) '_' num2str(DateNow(2), '%02d') '_' num2str(DateNow(3), '%02d') '_' num2str(DateNow(4), '%02d') '_' num2str(DateNow(5), '%02d')];
                    ParameterSaveFilePath = [DestinationPath_Edit  filesep DateNowString '.PANDA'];
                    
                    cmdString = [ 'save ' ParameterSaveFilePath ' Data_Raw_Path_Cell' ' SubjectIDArray' ' DestinationPath_Edit' ...
                        ' TensorPrefixEdit' ' pipeline_opt' ' dti_opt' ' tracking_opt' ' PANDAPath'];
                    eval(cmdString);
                    if ~isfield(tracking_opt, 'NetworkNode')
                        tracking_opt.NetworkNode = 0;
                    end
                    if tracking_opt.NetworkNode == 1
                        cmdString = [ 'save ' ParameterSaveFilePath ' FAPathCellMain' ' T1orPartitionOfSubjectsPathCellMain' ' -append'];
                        eval(cmdString);
                    end
                    if exist( ParameterSaveFilePath, 'file' )
                        clc;
                        disp( 'The variable is saved!' );
                        disp( [ 'The full path is ' ParameterSaveFilePath ] );
                        disp( 'The jobs will start running !' );
                    else
                        msgbox( 'Sorry, something has happened, the variables has not been saved!' );
                    end
                    % Excute the pipeline
                    if ~exist(DestinationPath_Edit)
                        mkdir(DestinationPath_Edit);
                    end
                    if tracking_opt.NetworkNode == 1
                        command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat''); addpath(genpath(PANDAPath));'...
                            'pipeline=g_dti_pipeline(Data_Raw_Path_Cell,SubjectIDArray,DestinationPath_Edit,TensorPrefixEdit,pipeline_opt,dti_opt,tracking_opt,T1orPartitionOfSubjectsPathCellMain);exit"'...
                            ' >"' DestinationPath_Edit filesep 'logs' filesep 'dti_pipeline.loginfo" 2>&1'];
                    else
                        command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat''); addpath(genpath(PANDAPath));'...
                            'pipeline=g_dti_pipeline(Data_Raw_Path_Cell,SubjectIDArray,DestinationPath_Edit,TensorPrefixEdit,pipeline_opt,dti_opt,tracking_opt);exit"'...
                            ' >"' DestinationPath_Edit filesep 'logs' filesep 'dti_pipeline.loginfo" 2>&1'];
                    end
                    DTIPipelineShLocation = [DestinationPath_Edit filesep 'logs' filesep 'dti_pipeline.sh'];
                    fid = fopen(DTIPipelineShLocation, 'w');
                    BashString = '#!/bin/bash';
                    fprintf(fid, '%s\n%s', BashString, command);
                    fclose(fid);
                    [~, ShPath] = system('which sh');
                    system([ShPath(1:end-1) ' ' DTIPipelineShLocation ' &']);
                    % Set edit box unable
                    set(handles.DestinationPathEdit, 'Enable', 'off');
                    set(handles.SubjectIDEdit, 'Enable', 'off');
                    set(handles.TensorPrefixEdit, 'Enable', 'off');
                    set(handles.RawDataPathButton, 'Enable', 'off');
                    set(handles.DestinationPathButton, 'Enable', 'off');
                    % Set the initial value in the monitor table
                    set(handles.RealtimeCheckbox, 'Value', 1);
                    set(handles.StatusUpdateButton, 'Enable', 'off');
                    StatusTablePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];
                    if ~exist(StatusTablePath)
                        % The initial status should be 'dcm2nii_dwi wait ...' for each job
                        %                             JobsStatus = cell(length(SubjectIDArray), 4);
                        %                             for i = 1:length(SubjectIDArray)
                        %                                 JobsStatus{i, 1} = num2str(i, '%05.0f');
                        %                                 JobsStatus{i, 2} = 'wait';
                        %                                 JobsStatus{i, 3} = 'dcm2nii_dwi';
                        %                                 JobsStatus{i, 4} = num2str(length(JobName));
                        %                             end
                        %                             set( handles.JobStatusTable, 'data', JobsStatus);
                        
                        % Empty the status table and Wait until status table file is created
                        JobsStatus = cell(4, 4);
                        set( handles.JobStatusTable, 'data', JobsStatus );
                        for i = 1:length(SubjectIDArray)
                            SubjectIDArrayString{i} = num2str(SubjectIDArray(i), '%05d');
                        end
                    else
                        % The initial status should be read from the former
                        % status table
                        try
                            cmdString = ['load ' StatusTablePath];
                            eval(cmdString);
                            % Combine SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray
                            % into a table
                            for i = 1:length(StatusArray)
                                StatusArray{i} = 'wait';
                            end
                            SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray];
                            set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
                        catch
                            none = 1;
                        end
                    end
                    %                         %
                    %                         JobsStatus = cell(4, 4);
                    %                         set( handles.JobStatusTable, 'data', JobsStatus );
                    %                         for i = 1:length(SubjectIDArray)
                    %                             SubjectIDArrayString{i} = num2str(SubjectIDArray(i), '%05d');
                    %                         end
                    %
                    LockExistMain = 0;
                    LockDisappearMain = 0;
                    % Calculate the jobs status in the background
                    MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
                    system(['touch ' MonitorTagPath]);
                    command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat'');'...
                        'addpath(genpath(PANDAPath));g_CalculateJobStatusMain(DestinationPath_Edit,SubjectIDArray,dti_opt,tracking_opt);exit"'...
                        ' >"' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo" 2>&1'];
                    CalculateJobStatusMainShLocation = [DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh'];
                    fid = fopen(CalculateJobStatusMainShLocation, 'w');
                    BashString = '#!/bin/bash';
                    fprintf(fid, '%s\n%s', BashString, command);
                    fclose(fid);
%                     instr_batch = ['at -f "' CalculateJobStatusMainShLocation '" now'];
%                     system(instr_batch);
                    [~, ShPath] = system('which sh');
                    system([ShPath(1:end-1) ' ' CalculateJobStatusMainShLocation ' &']);
                    % Start monitor function
                    StopFlag = '';
                    JobStatusMonitorTimerMain = timer( 'TimerFcn', {@JobStatusMonitorMain, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
                    start(JobStatusMonitorTimerMain);
                    
%                     tracking_opt.DeterminTrackingOptionChange = 0;
                case 'No'
                    return;
            end
        end
    end
end


% % --- Executes on button press in SaveButton.
% function SaveButton_Callback(hObject, eventdata, handles)
% % hObject    handle to SaveButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global Data_Raw_Path_Cell;
% global SubjectIDArray;
% global DestinationPath_Edit;
% global TensorPrefixEdit;
% global pipeline_opt;
% global dti_opt;
% global tracking_opt;
% global FAPathCellMain;
% global T1orPartitionOfSubjectsPathCellMain;
% [ ParameterSaveFileNameTemp,ParameterSavePath ] = uiputfile( {'*.PANDA', 'PANDA-files (*.PANDA)'},'Save Configuration' );
% ParameterSaveFileName = [ ParameterSaveFileNameTemp(1:end-5) 'PANDA'];
% ParameterSaveFilePath = [ ParameterSavePath ParameterSaveFileName ];
% % If user cancel, ParameterSavePath will be 0, nothing will happen
% if ParameterSavePath ~= 0 
%     cmdString = [ 'save ' ParameterSaveFilePath ' Data_Raw_Path_Cell' ' SubjectIDArray' ' DestinationPath_Edit' ...
%                   ' TensorPrefixEdit' ' pipeline_opt' ' dti_opt' ' tracking_opt'];
%     eval(cmdString);
%     if tracking_opt.NetworkNode == 1
%         cmdString = [ 'save ' ParameterSaveFilePath ' FAPathCellMain' ' T1orPartitionOfSubjectsPathCellMain' ' -append'];
%         eval(cmdString);
%     end
%     if exist( ParameterSaveFilePath, 'file' )
%         info{1} = 'The variable is saved sucessfully!';
%         info{2} = [ 'The full path is ' ParameterSaveFilePath ];
%         msgbox(info);
%     else
%         msgbox( 'Sorry, something has happened , the variables has not been saved!' );
%     end
% end


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global SubjectIDArray;
global SubjectIDArrayString;
global DestinationPath_Edit;
global TensorPrefixEdit;
global pipeline_opt;
global dti_opt;
global tracking_opt;
global LoadFlag;
global JobStatusMonitorTimerMain;
global StopFlag;
global T1orPartitionOfSubjectsPathCellMain;
global FAPathCellMain;
global LockExistMain;
global LockDisappearMain;
global AlreadyDisplay;
global PANDAPath;

% tracking_opt.DeterminTrackingOptionChange = 0;

StopFlag = '';
if ~isempty(JobStatusMonitorTimerMain)
    stop(JobStatusMonitorTimerMain);
    JobStatusMonitorTimerMain = '';
end

if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
    msgbox('Please clear first !');
else
    LoadFlag = 1;
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA','PANDA-files (*.PANDA)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        if ~isempty(DestinationPath_Edit)
            LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
        else
            LockFilePath = '';
        end
        CanLoad = 0;
        if exist(LockFilePath, 'file')
            StringPrint{1} = ['A lock file ' LockFilePath ' has been found on the pipeline !'];
            StringPrint{2} = 'So may be the job is running now.';
            StringPrint{3} = 'Are you sure to delete the old pipeline and start a new one ?';
            button = questdlg( StringPrint ,'Sure to Run ?','Yes','No','Yes' );
            if strcmp(button, 'Yes')
                system(['rm ' LockFilePath]);
                CanLoad = 1;
            end
        else 
            CanLoad = 1;
        end
        if CanLoad == 1
            cmdString = ['load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
            eval( cmdString );
            if ~isempty(DestinationPath_Edit)
                set( handles.DestinationPathEdit, 'string', DestinationPath_Edit );
            end
            if ~isempty(SubjectIDArray)
                set( handles.SubjectIDEdit, 'string', mat2str(SubjectIDArray) );
            end
            if ~isempty(TensorPrefixEdit)
                set( handles.TensorPrefixEdit, 'string', TensorPrefixEdit);
            end
            % Combine Destination path to Subject id 
            if ~isempty(Data_Raw_Path_Cell) & ~isempty(DestinationPath_Edit) & ~isempty(SubjectIDArray)
                if ~exist(DestinationPath_Edit, 'dir')
                    mkdir(DestinationPath_Edit);
                end
                % Judge whther the quantity of the subjects is equal to the quantity of the
                % subjects id
                if length(Data_Raw_Path_Cell) ~= length(SubjectIDArray)
                    info{1} = ['Your subjects id is ' mat2str(SubjectIDArray)];
                    info{2} = 'I am sorry, the quantity of the subjects is equal to the quantity of the subjects id!';
                    info{3} = 'I will delete the subject id, please write subjects id again!';
                    msgbox(info);
                    set( handles.SubjectIDEdit, 'string', '' );
                    SubjectIDArray = '';
                else
                    DestiantionPath_Subject = cell(length(SubjectIDArray),1);
                    for i = 1:length(SubjectIDArray)
                        DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
                    end
                    % Display the raw data path and the destination path in the table
                    RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];

                    set( handles.RawPath_DestPath, 'data', RawData_Destination );
                    ResizeRawDestTable(handles);
                    %
                    for i = 1:length(SubjectIDArray)
                        SubjectIDArrayString{i} = num2str(SubjectIDArray(i), '%05d');
                    end
                    % Display job status in the Job Status Table
                    LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
                    if exist(LockFilePath, 'file')
                        LockExistMain = 1;
                        LockDisappearMain = 0;
                        StopFlag = '';
                        LoadFlag = 1;
                        % Calculate the jobs status in the background
                        set(handles.RealtimeCheckbox, 'Value', 1);
                        set(handles.StatusUpdateButton, 'Enable', 'off');
                        MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
                        system(['touch ' MonitorTagPath]);
                        command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath filesep ParameterSaveFileName ...
                            ''',''-mat''); addpath(genpath(PANDAPath)); g_CalculateJobStatusMain(DestinationPath_Edit,SubjectIDArray,dti_opt,tracking_opt,1);exit"'...
                                ' >"' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo" 2>&1'];
                        CalculateJobStatusMainShLocation = [DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh'];
                        fid = fopen(CalculateJobStatusMainShLocation, 'w');
                        BashString = '#!/bin/bash';
                        fprintf(fid, '%s\n%s', BashString, command);
                        fclose(fid);
%                         instr_batch = ['at -f "' CalculateJobStatusMainShLocation '" now'];
%                         system(instr_batch);
                        [~, ShPath] = system('which sh');
                        system([ShPath(1:end-1) ' ' CalculateJobStatusMainShLocation ' &']);
                        %
                        JobStatusMonitorTimerMain = timer( 'TimerFcn', {@JobStatusMonitorMain, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
                        start(JobStatusMonitorTimerMain);
                        % Set edit box unable
                        set(handles.DestinationPathEdit, 'Enable', 'off');
                        set(handles.SubjectIDEdit, 'Enable', 'off');
                        set(handles.TensorPrefixEdit, 'Enable', 'off');
                        set(handles.RawDataPathButton, 'Enable', 'off');
                        set(handles.DestinationPathButton, 'Enable', 'off');
                    else
                        if exist([DestinationPath_Edit filesep 'logs'], 'dir')
                            LockExistMain = 0;
                            LockDisappearMain = 0;
                            LoadFlag = 2;
                            StopFlag = '(Stopped)';
                            AlreadyDisplay = 0;
                            StatusTableFilePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];
                            % If the status table already exists, the function
                            % JobStatusMonitorMain will display it in the table
                            if ~exist(StatusTableFilePath, 'file')
                                command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath filesep ParameterSaveFileName ...
                                    ''',''-mat''); addpath(genpath(PANDAPath)); g_CalculateJobStatusMain(DestinationPath_Edit,SubjectIDArray,dti_opt,tracking_opt,0);exit"'...
                                        ' >"' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo" 2>&1'];
                                CalculateJobStatusMainShLocation = [DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh'];
                                fid = fopen(CalculateJobStatusMainShLocation, 'w');
                                BashString = '#!/bin/bash';
                                fprintf(fid, '%s\n%s', BashString, command);
                                fclose(fid);
%                                 instr_batch = ['at -f "' CalculateJobStatusMainShLocation '" now'];
%                                 system(instr_batch);
                                [~, ShPath] = system('which sh');
                                system([ShPath(1:end-1) ' ' CalculateJobStatusMainShLocation ' &']);
                                % wait for the creation of the status table  
                            end
                            %
                            JobStatusMonitorTimerMain = timer( 'TimerFcn', {@JobStatusMonitorMain, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
                            start(JobStatusMonitorTimerMain);
                        end
                    end
                end
            elseif ~isempty(Data_Raw_Path_Cell)
                set( handles.RawPath_DestPath, 'data', Data_Raw_Path_Cell );
                ResizeRawDestTable(handles);
            end
        end
    end
end


% --- Executes during object creation, after setting all properties.
function LoadButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global LoadFlag;
LoadFlag = 0;


% --- Executes when user attempts to close PANDAFigure.
function PANDAFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global TensorPrefixEdit;
global pipeline_opt;
global dti_opt;
global tracking_opt;
global LoadFlag;
global T1orPartitionOfSubjectsPathCellMain;
global FAPathCellMain;
global JobStatusMonitorTimerMain;
global JobStatusMonitorTimerMain2;
global StopFlag;

button = questdlg('Are you sure to quit ?','Sure to Quit ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Delete calculate job status tag
        MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
        if exist(MonitorTagPath, 'file')
            delete(MonitorTagPath);
        end
        % Stop Monitor
        if ~isempty(JobStatusMonitorTimerMain)
            stop(JobStatusMonitorTimerMain);
            clear global JobStatusMonitorTimerMain;
        end
        if ~isempty(JobStatusMonitorTimerMain2)
            stop(JobStatusMonitorTimerMain2);
            clear global JobStatusMonitorTimerMain2;
        end
        % Delete Status Table
        StatusTableFilePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];
        if exist(StatusTableFilePath, 'file') 
            system(['rm -rf ' StatusTableFilePath]);
        end
        %
        clear global Data_Raw_Path_Cell;
        clear global SubjectIDArray;
        clear global DestinationPath_Edit;
        clear global TensorPrefixEdit;
        clear global pipeline_opt;
        clear global dti_opt;
        clear global LoadFlag;
        clear global T1orPartitionOfSubjectsPathCellMain;
        clear global FAPathCellMain;
        clear global tracking_opt;
        QuitAll();
        delete(hObject);
    case 'No'
        return;
end


% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global TensorPrefixEdit;
global pipeline_opt;
global dti_opt;
global tracking_opt;
global T1orPartitionOfSubjectsPathCellMain;
global FAPathCellMain;
global JobStatusMonitorTimerMain;
global JobStatusMonitorTimerMain2;
global LockExistMain;
global LockDisappearMain;
global StopFlag;
global PANDAPath;
global PANDAMonitorMain_Realtime;

button = questdlg('Are you sure to Clear ?','Sure to Clear ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Delete calculate job status tag
        MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
        if exist(MonitorTagPath, 'file')
            delete(MonitorTagPath);
        end
        % Stop Monitor if any
        if ~isempty(JobStatusMonitorTimerMain)
            stop(JobStatusMonitorTimerMain);
            clear global JobStatusMonitorTimerMain;
        end
        if ~isempty(JobStatusMonitorTimerMain2)
            stop(JobStatusMonitorTimerMain2);
            clear global JobStatusMonitorTimerMain2;
        end
        %
        clear global LockExistMain;
        clear global LockDisappearMain;
        % Set edit box unable
        set(handles.DestinationPathEdit, 'Enable', 'on');
        set(handles.SubjectIDEdit, 'Enable', 'on');
        set(handles.TensorPrefixEdit, 'Enable', 'on');
        set(handles.RawDataPathButton, 'Enable', 'on');
        set(handles.DestinationPathButton, 'Enable', 'on');
        % Set edit box and the table empty
        set(handles.DestinationPathEdit, 'String', '');
        set(handles.SubjectIDEdit, 'String', '');
        set(handles.TensorPrefixEdit, 'String', '');
            % RawPath_DestPath table: 4 row, 2 column default
        a = cell(4, 2);
        set( handles.RawPath_DestPath,'Data', a );
        ResizeRawDestTable(handles);
            % JobStatusTable table: 4 row, 4 column default
        a = cell(4, 4);
        set( handles.JobStatusTable, 'data', a);
        ResizeJobStatusTable(handles);
        % Delete Status Table
        StatusTablePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];
        if exist(StatusTablePath, 'file') 
            system(['rm -rf ' StatusTablePath]);
        end
        % Set variables empty
        % Clear the value Data_Raw_Path_Cell stored
        Data_Raw_Path_Cell = '';
        % Clear the value SubjectIDArray stored
        SubjectIDArray = '';
        % Clear the value DestinationPath_Edit stored
        DestinationPath_Edit = '';
        % Clear the value TensorPrefixEdit stored
        TensorPrefixEdit = '';
        % Set the initial value of pipeline_opt as default
        pipeline_opt.mode = 'background';
          % Calculate the quantity of cpu
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
        pipeline_opt.flag_verbose = 0;
        pipeline_opt.flag_pause = 0;
        % Set the initial value of dti_opt as default
        dti_opt.BET_1_f = 0.25;
        dti_opt.BET_2_f = 0.25;
        % Default, we will delete
        dti_opt.Delete_Flag = 1;
        dti_opt.NIIcrop_slice_gap = 3;
        dti_opt.LDH_Flag = 1;
        dti_opt.LDH_Neighborhood = 7;
        dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        dti_opt.applywarp_1_ref_fileName = 1;
        dti_opt.applywarp_2_ref_fileName = 2;
        dti_opt.applywarp_3_ref_fileName = 1;
        dti_opt.applywarp_4_ref_fileName = 2;
        dti_opt.applywarp_5_ref_fileName = 1;
        dti_opt.applywarp_6_ref_fileName = 2;
        dti_opt.applywarp_7_ref_fileName = 1;
        dti_opt.applywarp_8_ref_fileName = 2;
        dti_opt.Smoothing_Flag = 1;
        dti_opt.smoothNII_1_kernel_size = 6;
        dti_opt.smoothNII_2_kernel_size = 6;
        dti_opt.smoothNII_3_kernel_size = 6;
        dti_opt.smoothNII_4_kernel_size = 6;
        dti_opt.Atlas_Flag = 1;
        dti_opt.WM_Label_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
        dti_opt.WM_Probtract_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
        % Default, we will not do tbss
        dti_opt.TBSS_Flag = 0;
        % Set the initial value of tracking_opt as default
        tracking_opt.DterminFiberTracking = 0;
        tracking_opt.OutputFormat = 'Nifti';
        tracking_opt.ImageOrientation = 'Auto';
        tracking_opt.PropagationAlgorithm = 'FACT';
        tracking_opt.AngleThreshold = '35';
        tracking_opt.MaskThresMin = 0.1;
        tracking_opt.MaskThresMax = 1;
        tracking_opt.Inversion = 'No Inversion';
        tracking_opt.Swap = 'No Swap';
        tracking_opt.ApplySplineFilter = 'Yes';
        try
            if tracking_opt.NetworkNode == 1
                clear global T1orPartitionOfSubjectsPathCellMain;
                clear global FAPathCellMain;
            end
        catch
            none = 1;
        end
        tracking_opt.NetworkNode = 0;
        tracking_opt.PartitionOfSubjects = 0;
        tracking_opt.T1 = 0;
        tracking_opt.DeterministicNetwork = 0;
        tracking_opt.BedpostxProbabilisticNetwork = 0;
        %
        PANDAMonitorMain_Realtime = 1;
        set(handles.RealtimeCheckbox, 'Value', 1);
        set(handles.StatusUpdateButton, 'Enable', 'off');
    case 'No'
        return;
end


% --- Executes on button press in TerminateButton.
function TerminateButton_Callback(hObject, eventdata, handles)
% hObject    handle to TerminateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DestinationPath_Edit;
global StopFlag;
global LockDisappearMain;
global JobStatusMonitorTimerMain;
global JobStatusMonitorTimerMain2;

LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if isempty(DestinationPath_Edit) | ~exist(LockFilePath, 'file')
    msgbox('No job is running !');
else
    button = questdlg('Are you sure to terminal this job ?','Sure to terminal ?','Yes','No','Yes');
    switch button
        case 'Yes' 
            % Stop Monitor
            if ~isempty(JobStatusMonitorTimerMain)
                stop(JobStatusMonitorTimerMain);
                clear global JobStatusMonitorTimerMain;
            end
            if ~isempty(JobStatusMonitorTimerMain2)
                stop(JobStatusMonitorTimerMain2);
                clear global JobStatusMonitorTimerMain2;
            end
            %
            if exist(LockFilePath, 'file')
                system(['rm -rf ' LockFilePath]);
            end
            msgbox('The job is terminated sucessfully!');
            % Delete calculate job status tag
            MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
            if exist(MonitorTagPath, 'file')
                system(['rm -rf ' MonitorTagPath]);
            end
            % Delete Status Table
%             StatusTablePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];
%             if exist(StatusTablePath, 'file') 
%                 system(['rm -rf ' StatusTablePath]);
%             end
            % Set edit box enable, Stop Monitor, Update job status table
            StopFlag = '(Stopped)';
            while exist(LockFilePath, 'file')
                system(['rm -rf ' LockFilePath]);
            end
            LockDisappearMain = 1;
            JobStatusMonitorMain(hObject, eventdata, handles);    
        case 'No'
            return;
    end
end


% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global TensorPrefixEdit;
global pipeline_opt;
global dti_opt;
global tracking_opt;
global LoadFlag;
global StatusArray;
global JobStatusMonitorTimerMain;
global JobStatusMonitorTimerMain2;
global StopFlag;

button = questdlg('Are you sure to quit ?','Sure to Quit ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Delete calculate job status tag
        MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
        if exist(MonitorTagPath, 'file')
            delete(MonitorTagPath);
        end
        % Stop Monitor
        if ~isempty(JobStatusMonitorTimerMain)
            stop(JobStatusMonitorTimerMain);
            clear global JobStatusMonitorTimerMain;
        end
        if ~isempty(JobStatusMonitorTimerMain2)
            stop(JobStatusMonitorTimerMain2);
            clear global JobStatusMonitorTimerMain2;
        end
        % Delete Status Table
        StatusTableFilePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];
        if exist(StatusTableFilePath, 'file') 
            system(['rm -rf ' StatusTableFilePath]);
        end
        % Clear variables
        clear global Data_Raw_Path_Cell;
        clear global SubjectIDArray;
        clear global DestinationPath_Edit;
        clear global TensorPrefixEdit;
        clear global pipeline_opt;
        clear global dti_opt;
        clear global LoadFlag;
        clear global T1orPartitionOfSubjectsPathCellMain;
        clear global FAPathCellMain;
        clear global tracking_opt;
        QuitAll();
        delete(handles.PANDAFigure);
    case 'No'
        return;
end


% --- Monitor Function
function JobStatusMonitorMain(hObject, eventdata, handles)
% Print jobs status in the table
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global StopFlag;
global StatusArray;
global dti_opt;
global tracking_opt;
global JobStatusMonitorTimerMain;
global JobName;
global LockExistMain;
global LockDisappearMain;
global Count;
global LoadFlag;
global AlreadyDisplay;

PipelineStatusFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE_status_backup.mat'];
if ~exist(PipelineStatusFilePath, 'file') & LoadFlag
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerMain)
        stop(JobStatusMonitorTimerMain);
        clear global JobStatusMonitorTimerMain;
    end
end

StatusTableFilePath = [DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'];

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if ~LockExistMain & exist( LockFilePath, 'file' )
    LockExistMain = 1;
end
if LockExistMain & ~exist( LockFilePath, 'file' )
    LockDisappearMain = 1;
end
ErrorFilePath = [DestinationPath_Edit filesep 'logs' filesep 'dti_pipeline.error'];
if LockDisappearMain == 1 | exist(ErrorFilePath, 'file')
    % Delete calculate job status tag
    MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
    if exist(MonitorTagPath, 'file')
        system(['rm -rf ' MonitorTagPath]);
    end
    % Set edit box enable
    set(handles.DestinationPathEdit, 'Enable', 'on');
    set(handles.SubjectIDEdit, 'Enable', 'on');
    set(handles.TensorPrefixEdit, 'Enable', 'on');
    set(handles.RawDataPathButton, 'Enable', 'on');
    set(handles.DestinationPathButton, 'Enable', 'on');
    
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerMain)
        stop(JobStatusMonitorTimerMain);
        clear global JobStatusMonitorTimerMain;
    end
    %
    if exist([DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo'], 'file')
        system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo']);
    end
    if exist([DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh'], 'file')
        system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh']);
    end
    %
    if exist(ErrorFilePath, 'file')
        Info{1} = 'Something is wrong !';
        Info{2} = ['Please look up ' DestinationPath_Edit filesep ...
                   'logs' filesep 'dti_pipeline.loginfo for more information !'];
        msgbox(Info);
        StopFlag = '(Stopped)';
        system(['rm -rf ' ErrorFilePath]);
    end
end
        
if ~exist( StatusTableFilePath, 'file' ) 
    Count = Count + 1;
    if Count == 1
        StatusTable = cell(length(Data_Raw_Path_Cell), 4);
        for i = 1:length(Data_Raw_Path_Cell)
            StatusTable{i,1} = 'wait.';
            StatusTable{i,2} = 'wait.';
            StatusTable{i,3} = 'wait.';
            StatusTable{i,4} = 'wait.';
        end
        set( handles.JobStatusTable, 'data', StatusTable);
    elseif Count == 2
        for i = 1:length(Data_Raw_Path_Cell)
            StatusTable{i,1} = 'wait..';
            StatusTable{i,2} = 'wait..';
            StatusTable{i,3} = 'wait..';
            StatusTable{i,4} = 'wait..';
        end
        set( handles.JobStatusTable, 'data', StatusTable);
    elseif Count == 3;
        Count = 0;
        for i = 1:length(Data_Raw_Path_Cell)
            StatusTable{i,1} = 'wait...';
            StatusTable{i,2} = 'wait...';
            StatusTable{i,3} = 'wait...';
            StatusTable{i,4} = 'wait...';
        end
        set( handles.JobStatusTable, 'data', StatusTable);
    end
end
RunningFlag = 0;
if exist( StatusTableFilePath, 'file' )
    warning('off');
    try
        cmdString = ['load ' StatusTableFilePath];
        eval(cmdString);
        % Combine SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray
        % into a table
        for i = 1:length(StatusArray)
            if ~strcmp(StatusArray{i}, 'finished') & ~strcmp(StatusArray{i}, 'failed')
                StatusArray{i} = [StatusArray{i} StopFlag];
                RunningFlag = 1;
            end
        end
        SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray]; 
        set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
        %
        JobsFinishFilePath = [DestinationPath_Edit filesep 'logs' filesep 'jobs.finish'];
        if exist(JobsFinishFilePath, 'file') %| ~RunningFlag 
            % Delete calculate job status tag
            MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
            if exist(MonitorTagPath, 'file')
                delete(MonitorTagPath);
            end
            % Set edit box enable
            set(handles.DestinationPathEdit, 'Enable', 'on');
            set(handles.SubjectIDEdit, 'Enable', 'on');
            set(handles.TensorPrefixEdit, 'Enable', 'on');
            set(handles.RawDataPathButton, 'Enable', 'on');
            set(handles.DestinationPathButton, 'Enable', 'on');
            % Stop Monitor
            if ~isempty(JobStatusMonitorTimerMain)
                stop(JobStatusMonitorTimerMain);
                clear global JobStatusMonitorTimerMain;
            end
            %
            system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo']);
            system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh']);
            % 
            if exist(JobsFinishFilePath, 'file')
                msgbox('All jobs have been successfully completed.');
                system(['rm -rf ' JobsFinishFilePath]);
            end
        end
        if LoadFlag == 2
            AlreadyDisplay = 1;
        end
    catch
        none = 0;
    end
    warning('on'); 
end
if LockDisappearMain == 1 | exist(ErrorFilePath, 'file') 
    % Delete Status Table
    if exist(StatusTableFilePath, 'file') & isempty(StopFlag)
        system(['rm -rf ' StatusTableFilePath]);
    end
end
if LoadFlag == 2 & ~RunningFlag & AlreadyDisplay
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerMain)
        stop(JobStatusMonitorTimerMain);
        clear global JobStatusMonitorTimerMain;
    end
end


% --- Monitor Function
function JobStatusMonitorMain2(hObject, eventdata, handles)
% Print jobs status in the table
global Data_Raw_Path_Cell;
global SubjectIDArray;
global DestinationPath_Edit;
global StopFlag;
global dti_opt;
global tracking_opt;
global JobStatusMonitorTimerMain2;
global LockExistMain;
global LockDisappearMain;

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if ~LockExistMain & exist( LockFilePath, 'file' )
    LockExistMain = 1;
end
if LockExistMain & ~exist( LockFilePath, 'file' )
    LockDisappearMain = 1;
end
ErrorFilePath = [DestinationPath_Edit filesep 'logs' filesep 'dti_pipeline.error'];
if LockDisappearMain == 1 | exist(ErrorFilePath, 'file')
    % Delete calculate job status tag
    MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
    if exist(MonitorTagPath, 'file')
        system(['rm -rf ' MonitorTagPath]);
    end
    % Set edit box enable
    set(handles.DestinationPathEdit, 'Enable', 'on');
    set(handles.SubjectIDEdit, 'Enable', 'on');
    set(handles.TensorPrefixEdit, 'Enable', 'on');
    set(handles.RawDataPathButton, 'Enable', 'on');
    set(handles.DestinationPathButton, 'Enable', 'on');
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerMain2)
        stop(JobStatusMonitorTimerMain2);
        clear global JobStatusMonitorTimerMain2;
    end
    %
    if exist([DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo'], 'file')
        system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo']);
    end
    if exist([DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh'], 'file')
        system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh']);
    end
    %
    if exist(ErrorFilePath, 'file')
        Info{1} = 'Something is wrong !';
        Info{2} = ['Please look up ' DestinationPath_Edit filesep ...
                   'logs' filesep 'dti_pipeline.loginfo for more information !'];
        msgbox(Info);
        StopFlag = '(Stopped)';
        system(['rm -rf ' ErrorFilePath]);
    end
end
        
JobsFinishFilePath = [DestinationPath_Edit filesep 'logs' filesep 'jobs.finish'];
if exist(JobsFinishFilePath, 'file')
    % Set edit box enable
    set(handles.DestinationPathEdit, 'Enable', 'on');
    set(handles.SubjectIDEdit, 'Enable', 'on');
    set(handles.TensorPrefixEdit, 'Enable', 'on');
    set(handles.RawDataPathButton, 'Enable', 'on');
    set(handles.DestinationPathButton, 'Enable', 'on');
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerMain2)
        stop(JobStatusMonitorTimerMain2);
        clear global JobStatusMonitorTimerMain2;
    end
    %
    system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo']);
    system(['rm ' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh']);
    %
    if exist(JobsFinishFilePath, 'file')
        msgbox('All jobs have been successfully completed.');
        system(['rm -rf ' JobsFinishFilePath]);
    end
end



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over DestinationPathEdit.
function DestinationPathEdit_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to DestinationPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FiberTrackingButton.
function FiberTrackingButton_Callback(hObject, eventdata, handles)
% hObject    handle to FiberTrackingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Tracking_Opt;


% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PANDA_Help;


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


% --- Executes on button press in UtilitiesButton.
function UtilitiesButton_Callback(hObject, eventdata, handles)
% hObject    handle to UtilitiesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global Data_Raw_Path_Cell;
% global SubjectIDArray;
% global DestinationPath_Edit;
% global TensorPrefixEdit;
% global pipeline_opt;
% global dti_opt;
% global tracking_opt;
% global LoadFlag;
% global StatusArray;
% global JobStatusMonitorTimerMain;
% % Clear variables
% clear global Data_Raw_Path_Cell;
% clear global SubjectIDArray;
% clear global DestinationPath_Edit;
% clear global TensorPrefixEdit;
% clear global pipeline_opt;
% clear global dti_opt;
% clear global LoadFlag;
% clear global T1orPartitionOfSubjectsPathCellMain;
% clear global FAPathCellMain;
% clear global tracking_opt;
% % Stop Monitor
% if ~isempty(JobStatusMonitorTimerMain)
%     stop(JobStatusMonitorTimerMain);
% end
% delete(handles.PANDAFigure);
PANDA_Utilities;


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


% --- Executes when PANDAFigure is resized.
function PANDAFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.PANDAFigure, 'Position');
    ResizeRawDestTable(handles);
    ResizeJobStatusTable(handles);
end


function ResizeRawDestTable(handles)
RawPathDestPath = get(handles.RawPath_DestPath, 'data');
PositionFigure = get(handles.PANDAFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 2;
WidthCell{2} = WidthCell{1};
if ~isempty(RawPathDestPath)
    [rows, columns] = size(RawPathDestPath);
    for i = 1:columns
        for j = 1:rows
            tmp_PANDA{j} = length(RawPathDestPath{j, i}) * 8;
            tmp_PANDA{j} = tmp_PANDA{j} * PositionFigure(4) / 550;
        end
        NewWidthCell{i} = max(cell2mat(tmp_PANDA));
        if NewWidthCell{i} > WidthCell{i}
           WidthCell{i} =  NewWidthCell{i};
        end
    end
end
set(handles.RawPath_DestPath, 'ColumnWidth', WidthCell);


function ResizeJobStatusTable(handles)
PositionFigure = get(handles.PANDAFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 4;
WidthCell{2} = WidthCell{1};
WidthCell{3} = WidthCell{1};
WidthCell{4} = WidthCell{1};
set(handles.JobStatusTable, 'ColumnWidth', WidthCell);


% --- Executes on button press in ResultPathText.
function ResultPathText_Callback(hObject, eventdata, handles)
% hObject    handle to ResultPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SubjectIDsText.
function SubjectIDsText_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectIDsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FilePrefixText.
function FilePrefixText_Callback(hObject, eventdata, handles)
% hObject    handle to FilePrefixText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function FilePrefixText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilePrefixText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in LocationTableText.
function LocationTableText_Callback(hObject, eventdata, handles)
% hObject    handle to LocationTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MonitorTableText.
function MonitorTableText_Callback(hObject, eventdata, handles)
% hObject    handle to MonitorTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TitleText.
function TitleText_Callback(hObject, eventdata, handles)
% hObject    handle to TitleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function QuitAll()
% Add by Zaixu Cui 09/10/2012.
% Close Pipeline Opt figure.
theFig =findobj(allchild(0),'flat','Tag','PipelineOptFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Diffusion Opt figure.
theFig =findobj(allchild(0),'flat','Tag','DiffusionOptFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% Close Tracking Opt figure.
theFig =findobj(allchild(0),'flat','Tag','TrackingFigure');
if ~isempty(theFig) 
    delete(theFig);
end
% % Close Bedpostx and Probabilistic Opt figure.
% theFig =findobj(allchild(0),'flat','Tag','BedpostxAndProbabilisticOptFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end
% % Close Probabilistic Opt figure.
% theFig =findobj(allchild(0),'flat','Tag','ProbabilisticOptFigure');
% if ~isempty(theFig) 
%     delete(theFig);
% end


% --- Executes during object deletion, before destroying properties.
function PANDAFigure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LogsButton.
function LogsButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DestinationPath_Edit;

LogsPath = '';
if isempty(DestinationPath_Edit)
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA','PANDA-files (*.PANDA)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        cmdString = ['PANDAConfiguration = load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'');'];
        eval( cmdString );
        LogsPath = [PANDAConfiguration.DestinationPath_Edit filesep 'logs'];    
    end
else
    LogsPath = [DestinationPath_Edit filesep 'logs'];
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


% --- Executes when selected cell(s) is changed in RawPath_DestPath.
function RawPath_DestPath_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to RawPath_DestPath (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global Data_Raw_Path_Cell;
global DestinationPath_Edit;
global SubjectIDArray;
if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
    RunningFlag = 1;
else
    RunningFlag = 0;
end
if ~RunningFlag
    RawPathDestPathTableData = get(handles.RawPath_DestPath, 'data');
    if ~isempty(RawPathDestPathTableData)
        if ~isempty(RawPathDestPathTableData{1,1})
            if ~isempty(eventdata.Indices)
                DeletedSubjectNum = eventdata.Indices(1);
                info{1} = ['Are you sure to delete this subject?'];
                button = questdlg( info ,'Sure to delete ?','Yes','No','No' );
                if strcmp(button, 'Yes')
                    Data_Raw_Path_Cell(DeletedSubjectNum) = [];
                    if ~isempty(SubjectIDArray)
                        SubjectIDArray(DeletedSubjectNum) = [];
                        % Combine Destination path to Subject id 
                        if ~isempty(SubjectIDArray)
                            DestiantionPath_Subject = cell(length(SubjectIDArray),1);
                            for i = 1:length(SubjectIDArray)
                                DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
                                DestiantionPath_Subject = reshape(DestiantionPath_Subject, length(DestiantionPath_Subject), 1);
                            end
                        else
                            DestiantionPath_Subject = [];
                        end  
                        RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];
                    else
                        RawData_Destination = Data_Raw_Path_Cell;
                    end
                    % Display the raw data path and the destination path in the table
                    if isempty(RawData_Destination)
                         RawData_Destination = cell(4, 2);
                    end
                    set( handles.RawPath_DestPath, 'data', RawData_Destination );
                    ResizeRawDestTable(handles);
                    % Update subject IDs in the edit
                    if ~isempty(SubjectIDArray)
                        SubjectIDString = mat2str(SubjectIDArray);
                        set(handles.SubjectIDEdit, 'String', SubjectIDString);
                    end
                else
                    set( handles.RawPath_DestPath, 'data', '' );
                    if ~isempty(SubjectIDArray)
                        for i = 1:length(SubjectIDArray)
                            DestiantionPath_Subject{i} = [DestinationPath_Edit filesep num2str(SubjectIDArray(i),'%05.0f')];
                            DestiantionPath_Subject = reshape(DestiantionPath_Subject, length(DestiantionPath_Subject), 1);
                        end
                        RawData_Destination = [Data_Raw_Path_Cell, DestiantionPath_Subject];
                    else
                        RawData_Destination = Data_Raw_Path_Cell;
                    end
                    set( handles.RawPath_DestPath, 'data', RawData_Destination );
                    ResizeRawDestTable(handles);
                end
            end
        end
    end
end


% --- Executes on key press with focus on RawPath_DestPath and none of its controls.
function RawPath_DestPath_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to RawPath_DestPath (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


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
%     PositionFigure = get(handles.PANDAFigure, 'Position');
%     for i = 1:columns
%         for j = 1:rows
%             if NewWidthCell{i} < length(RawPathDestPath{j, i}) * 8
%                 NewWidthCell{i} = length(RawPathDestPath{j, i}) * 8;
%             end
%         end
%         NewWidthCell{i} = NewWidthCell{i} * PositionFigure(4) / 538;
%     end
%     set( handles.RawPath_DestPath, 'ColumnWidth', NewWidthCell);
% end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function PANDAFigure_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function PANDAFigure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.RawDataPathButton, 'Enable', 'off');


% --------------------------------------------------------------------
function JobStatusTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to JobStatusTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on PANDAFigure and none of its controls.
function PANDAFigure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background.
function PANDAFigure_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PANDAFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RealtimeCheckbox.
function RealtimeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to RealtimeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RealtimeCheckbox
global DestinationPath_Edit;
global SubjectIDArray;
global dti_opt;
global tracking_opt;
global PANDAMonitorMain_Realtime;
global JobStatusMonitorTimerMain;
global JobStatusMonitorTimerMain2;
if get(hObject,'Value')
    PANDAMonitorMain_Realtime= 1;
    if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
        % Calculate the jobs status in the background
        [PANDAPath y z] = fileparts(which('PANDA.m'));
        ParameterSaveFilePath = [DestinationPath_Edit filesep 'logs' filesep 'TmpPath.mat'];
        if exist(ParameterSaveFilePath, 'file')
            delete(ParameterSaveFilePath);
        end
        cmdString = [ 'save ' ParameterSaveFilePath ' PANDAPath DestinationPath_Edit SubjectIDArray dti_opt tracking_opt'];
        eval(cmdString);
        MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
        system(['touch ' MonitorTagPath]);
        command = ['"' matlabroot filesep 'bin' filesep 'matlab" -nosplash -nodesktop -r "load(''' ParameterSaveFilePath ''',''-mat'');'...
            'addpath(genpath(PANDAPath));g_CalculateJobStatusMain(DestinationPath_Edit,SubjectIDArray,dti_opt,tracking_opt);exit"'...
            ' >"' DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.loginfo" 2>&1'];
        CalculateJobStatusMainShLocation = [DestinationPath_Edit filesep 'logs' filesep 'CalculateJobStatusMain.sh'];
        fid = fopen(CalculateJobStatusMainShLocation, 'w');
        BashString = '#!/bin/bash';
        fprintf(fid, '%s\n%s', BashString, command);
        fclose(fid);
%         instr_batch = ['at -f "' CalculateJobStatusMainShLocation '" now'];
%         system(instr_batch);
        [~, ShPath] = system('which sh');
        system([ShPath(1:end-1) ' ' CalculateJobStatusMainShLocation ' &']);
        %
        if ~isempty(JobStatusMonitorTimerMain2)
            stop(JobStatusMonitorTimerMain2);
            clear global JobStatusMonitorTimerMain2;
        end
        if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
            JobStatusMonitorTimerMain = timer( 'TimerFcn', {@JobStatusMonitorMain, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimerMain);
        end
    end
    set(handles.StatusUpdateButton, 'Enable', 'off');
else
    PANDAMonitorMain_Realtime= 0;
    if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
        %
        MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
        %
        if exist(MonitorTagPath, 'file')
            delete(MonitorTagPath);
        end
        if ~isempty(JobStatusMonitorTimerMain)
            stop(JobStatusMonitorTimerMain);
            clear global JobStatusMonitorTimerMain;
        end
        if strcmp(get(handles.RawDataPathButton, 'Enable'), 'off')
            JobStatusMonitorTimerMain2 = timer( 'TimerFcn', {@JobStatusMonitorMain2, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimerMain2);
        end
    end
    set(handles.StatusUpdateButton, 'Enable', 'on');
end


% --- Executes on button press in StatusUpdateButton.
function StatusUpdateButton_Callback(hObject, eventdata, handles)
% hObject    handle to StatusUpdateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SubjectIDArray;
global DestinationPath_Edit;
global StopFlag;
global dti_opt;
global tracking_opt;
global LockExistMain;
global LockDisappearMain;

LockFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE.lock'];
if exist(LockFilePath, 'file')
    LockFlag = 1;
else
    LockFlag = 0;
end

StatusFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE_status.mat'];
if exist( StatusFilePath, 'file' )
    try
        warning('off');
        cmdString = ['load ' StatusFilePath];
        eval(cmdString);
        SubjectQuantity = length(SubjectIDArray);
        JobName = {'dcm2nii_dwi', 'DataParameters'};
        if dti_opt.RawDataResample_Flag
            JobName = [JobName, {'ResampleRawData'}];
        end
        if ~strcmp(dti_opt.Inversion, 'No Inversion') & ~strcmp(dti_opt.Swap, 'No Swap')
            JobName = [JobName, {'OrientationPatch'}];
        end
        JobName = [JobName, {'extractB0', 'BET_1'}];
        if dti_opt.Cropping_Flag
            JobName = [JobName, {'Split_Crop'}];
        else
            JobName = [JobName, {'Split'}];
        end
        JobName = [JobName, {'EDDYCURRENT', 'average', 'BET_2', 'merge', 'dtifit'}];
        if dti_opt.LDH_Flag
            JobName = [JobName, {'LDH'}];
        end
        if dti_opt.Normalizing_Flag
            JobName = [JobName, {'BeforeNormalize_FA', 'BeforeNormalize_MD', 'BeforeNormalize_L1','BeforeNormalize_L23m',...
                'FAnormalize', 'applywarp_FA_1mm', 'applywarp_MD_1mm', 'applywarp_L1_1mm', 'applywarp_L23m_1mm'}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {'BeforeNormalize_LDHs', 'BeforeNormalize_LDHk', 'applywarp_LDHs_1mm', 'applywarp_LDHk_1mm'}];
            end
        end
        if dti_opt.Resampling_Flag
            if dti_opt.applywarp_2_ref_fileName ~= 1
                JobName = [JobName, {['applywarp_FA_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
            end
            if dti_opt.applywarp_4_ref_fileName ~= 1
                JobName = [JobName, {['applywarp_MD_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
            end
            if dti_opt.applywarp_6_ref_fileName ~= 1
                JobName = [JobName, {['applywarp_L1_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
            end
            if dti_opt.applywarp_8_ref_fileName ~= 1
                JobName = [JobName, {['applywarp_L23m_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {['applywarp_LDHs_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                    JobName = [JobName, {['applywarp_LDHk_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                end
            end
        end
        if dti_opt.Smoothing_Flag
            JobName = [JobName, {['smoothNII_FA_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm'], ...
                ['smoothNII_MD_' num2str(dti_opt.applywarp_4_ref_fileName) 'mm'],...
                ['smoothNII_L1_' num2str(dti_opt.applywarp_6_ref_fileName) 'mm'],...
                ['smoothNII_L23m_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm']}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {['smoothNII_LDHs_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm'], ...
                ['smoothNII_LDHk_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm']}];
            end
        end
        if dti_opt.Atlas_Flag
            JobName = [JobName, {'atlas_FA_1mm', 'atlas_MD_1mm', 'atlas_L1_1mm', 'atlas_L23m_1mm'}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {'atlas_LDHs_1mm', 'atlas_LDHk_1mm'}];
            end
        end
        JobName = [JobName, {'delete_tmp_file'}];

        if dti_opt.TBSS_Flag == 1
            JobName = [JobName, {'TBSSDismap', 'skeleton_FA', 'skeleton_MD', 'skeleton_L1', 'skeleton_L23m' ...
                    'skeleton_atlas_FA', 'skeleton_atlas_MD', 'skeleton_atlas_L1', 'skeleton_atlas_L23m'}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {'skeleton_LDHs', 'skeleton_LDHk', 'skeleton_atlas_LDHs', 'skeleton_atlas_LDHk'}];
            end
        end
        if tracking_opt.DterminFiberTracking
            JobName = [JobName, {'DeterministicTracking'}];
        end
        if tracking_opt.NetworkNode && ~tracking_opt.PartitionOfSubjects
            NetworkNodeJobName = {'CopyT1'};
            if tracking_opt.T1Bet_Flag
                NetworkNodeJobName = [NetworkNodeJobName, {'BetT1'}];
            end
            if tracking_opt.T1Cropping_Flag
                NetworkNodeJobName = [NetworkNodeJobName, {'T1Cropped'}];
            end
            if tracking_opt.T1Resample_Flag
                NetworkNodeJobName = [NetworkNodeJobName, {'T1Resample'}];
            end
            NetworkNodeJobName = [NetworkNodeJobName, {'FAtoT1', 'T1toMNI152', 'Invwarp', 'IndividualParcellated'}];
            JobName = [JobName, NetworkNodeJobName];
        end
        if tracking_opt.DeterministicNetwork == 1
            JobName = [JobName, {'DeterministicNetwork'}];
        end
        if tracking_opt.BedpostxProbabilisticNetwork
            JobName = [JobName, {'BedpostX_preproc'}];
            for BedpostXJobNum = 1:10
                JobName = [JobName, {['BedpostX_' num2str(BedpostXJobNum, '%02.0f')]}];
            end
            JobName = [JobName, {'BedpostX_postproc', 'ProbabilisticNetworkpre'}];
            ProbabilisticNetworkJobQuantity = min(length(tracking_opt.LabelIdVector), 80);
            for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
                JobName = [JobName, {['ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d')]}];
            end
            ProbabilisticNetworkPostJobQuantity = min(length(tracking_opt.LabelIdVector), 10);
            for ProbabilisticNetworkPostJobNum = 1:ProbabilisticNetworkPostJobQuantity
                JobName = [JobName, {['ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f')]}];
            end
            JobName = [ JobName, {'ProbabilisticNetworkpost_MergeResults'}];
        end
        
        JobName = [JobName, {'ExportParametersToExcel'}];
        if dti_opt.Atlas_Flag | dti_opt.TBSS_Flag
            JobName = [JobName, {'Split_WMLabel', 'Split_WMProbtract'}];
        end
        if dti_opt.Atlas_Flag
            JobName = [JobName, {'ExportAtlasResults_FA_ToExcel', 'ExportAtlasResults_MD_ToExcel', ...
                'ExportAtlasResults_L1_ToExcel', 'ExportAtlasResults_L23m_ToExcel'}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {'ExportAtlasResults_LDHs_ToExcel', 'ExportAtlasResults_LDHk_ToExcel'}];
            end
        end
        if dti_opt.TBSS_Flag == 1
            JobName = [JobName, {'MergeSkeleton_FA', 'MergeSkeleton_MD', 'MergeSkeleton_L1', 'MergeSkeleton_L23m', ...
                    'ExportAtlasResults_FASkeleton_ToExcel', 'ExportAtlasResults_MDSkeleton_ToExcel', ...
                    'ExportAtlasResults_L1Skeleton_ToExcel', 'ExportAtlasResults_L23mSkeleton_ToExcel'}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {'MergeSkeleton_LDHs', 'MergeSkeleton_LDHk', ...
                        'ExportAtlasResults_LDHsSkeleton_ToExcel', 'ExportAtlasResults_LDHkSkeleton_ToExcel'}];
            end
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
            SubjectID = SubjectIDArray(i);
            SubjectIDArrayString{i} = num2str(SubjectIDArray(i),'%05.0f');
            for j = 1:JobQuantity
                % Check the status of all jobs of the ith subject and  acquire
                % the status of the subject
                % The subject has three situations:
                %     1. 'failed': which job
                %     2. 'running': which job
                %     3. 'submitted': which job
                %     4. 'wait': which job
                %     5. 'finished'
                if strcmp(JobName{j},'TBSSDismap') | strcmp(JobName{j},'ExportParametersToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_FA_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_MD_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_L1_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_L23m_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_LDHs_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_LDHk_ToExcel') ...
                            | strcmp(JobName{j},'MergeSkeleton_FA') | strcmp(JobName{j},'MergeSkeleton_MD') ...
                            | strcmp(JobName{j},'MergeSkeleton_L1') | strcmp(JobName{j},'MergeSkeleton_L23m') ...
                            | strcmp(JobName{j},'MergeSkeleton_LDHs') | strcmp(JobName{j},'MergeSkeleton_LDHk') ...
                            | strcmp(JobName{j},'ExportAtlasResults_FASkeleton_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_MDSkeleton_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_L1Skeleton_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_L23mSkeleton_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_LDHsSkeleton_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_LDHkSkeleton_ToExcel') ...
                            | strcmp(JobName{j},'Split_WMLabel') | strcmp(JobName{j},'Split_WMProbtract')
                    VariableName = JobName{j};
                else
                    VariableName = [JobName{j} '_' SubjectIDArrayString{i}];
                end
                
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
                StatusArray{i} = 'finished';
                JobNameArray{i} = '';
                JobLeftArray{i} = '0';
            elseif ~isempty(RunningJobName)
                StatusArray{i} = 'running';
                JobNameArray{i} = RunningJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(SubmittedJobName)
                StatusArray{i} = 'submitted';
                JobNameArray{i} = SubmittedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(FailedJobName)
                StatusArray{i} = 'failed';
                JobNameArray{i} = FailedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(WaitJobName)
                StatusArray{i} = 'wait';
                JobNameArray{i} = WaitJobName;
                JobLeftArray{i} = num2str(JobLeft);
            end
        end
        for i = 1:length(StatusArray)
            if ~strcmp(StatusArray{i}, 'finished') & ~strcmp(StatusArray{i}, 'failed')
                StatusArray{i} = [StatusArray{i} StopFlag];
                RunningFlag = 1;
            end
        end
        SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray]; 
        set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
        warning('on');
    end
end


% --- Executes when entered data in editable cell(s) in RawPath_DestPath.
function RawPath_DestPath_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to RawPath_DestPath (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
