function varargout = PANDA_LDH(varargin)
% GUI for calculating LDH (an independent component of software PANDA), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2015
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.3.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_LDH MATLAB code for PANDA_LDH.fig
%      PANDA_LDH, by itself, creates a new PANDA_LDH or raises the existing
%      singleton*.
%
%      H = PANDA_LDH returns the handle to a new PANDA_LDH or the handle to
%      the existing singleton*.
%
%      PANDA_LDH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_LDH.M with the given input arguments.
%
%      PANDA_LDH('Property','Value',...) creates a new PANDA_LDH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_LDH_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_LDH_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_LDH

% Last Modified by GUIDE v2.5 20-Jul-2015 15:48:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_LDH_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_LDH_OutputFcn, ...
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


% --- Executes just before PANDA_LDH is made visible.
function PANDA_LDH_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_LDH (see VARARGIN)

% Choose default command line output for PANDA_LDH
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_LDH wait for user response (see UIRESUME)
% uiwait(handles.PANDALDHFigure);
global LDH_Pipeline_opt;
global PANDAPath;
global Neighborhood;
global LDH_NormalizeTarget;

[PANDAPath, ~, ~] = fileparts(which('PANDA.m'));
Neighborhood = 7;
set(handles.SevenRadio, 'Value', 1);
set( handles.NineteenRadio, 'Value', 0);
set( handles.TwentySevenRadio, 'Value', 0);
LDH_Data_Raw_Path_Cell = '';
LDH_NormalizeTarget = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
set(handles.NormalizeTargetEdit, 'String', LDH_NormalizeTarget);
% Pipeline options
LDH_Pipeline_opt.flag_verbose = 0;
LDH_Pipeline_opt.flag_pause = 0;
set( handles.batchRadio, 'Value', 1);
LDH_Pipeline_opt.mode = 'background';
set( handles.QsubOptionsEdit, 'String', '');
set( handles.QsubOptionsEdit, 'Enable', 'off');
LDH_Pipeline_opt.qsub_options = '';
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
    LDH_Pipeline_opt.max_queued = str2num(QuantityOfCpu);
else
    LDH_Pipeline_opt.max_queued = 2;
end
set(handles.MaxQueuedEdit, 'string', num2str(LDH_Pipeline_opt.max_queued));
% Set the Status Table to default
JobStatusCell = cell(4,4);
set( handles.JobStatusTable, 'data', JobStatusCell );
% Set icon
SetIcon(handles);
%
TipStr = sprintf(['Cell of 4D DWI image containing diffusion-weighted volumes' ...
    '\n    and volumes without diffusion weighting.']);
set(handles.DWIPathButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Cell of text file containing b-values applied for' ...
    '\n    each volume acquisition.']);
set(handles.BvalsPathButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['Digital IDs for subjects.' ... 
    '\n Example: [1 4 8:20].']);
set(handles.SubjectIDEdit, 'TooltipString', TipStr);
%
TipStr = sprintf('The prefix of the names for the resultant files. \n (Optional parameter)');
set(handles.FilePrefixEdit, 'TooltipString', TipStr);
%
TipStr = sprintf(['Reference: Gong G (2013) Local Diffusion Homogeneity (LDH): An Inter-Voxel' ...
    '\n Diffusion MRI Metric for Assessing Inter-Subject White Matter Variability.' ...
    '\n PLoS ONE 8(6): e66366. doi:10.1371/journal.pone.0066366']);
set(handles.SevenRadio, 'TooltipString', TipStr);
set(handles.NineteenRadio, 'TooltipString', TipStr);
set(handles.TwentySevenRadio, 'TooltipString', TipStr);
%
TipStr = sprintf(['The path of each subject''s resultant folder is constructed by the ' ...
    '\n Result Path and subject IDs user inputs.' ...
    '\n For example, Subject IDs is [1:3], then, the path of results will be' ...
    '\n {Result_Path} / 00001' ...
    '\n {Result_Path} / 00002' ...
    '\n {Result_Path} / 00003']);
set(handles.RawPath_DestPath, 'TooltipString', TipStr);
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
TipStr = sprintf(['Load .PANDA_DICOMNIfTI file to display the information in' ...
    '\n the GUI.']);
set(handles.LoadButton, 'TooltipString', TipStr);
%
TipStr = sprintf(['After clicking the button, the information in the GUI' ...
    '\n will be saved in a .PANDA_DICOMNIfTI file under ''Log_Path''.']);
set(handles.RUNButton, 'TooltipString', TipStr);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_LDH_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in DWIPathButton.
function DWIPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to DWIPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_DWIList;
DWIList_Button = get(hObject, 'UserData');
[a, LDH_DWIList, Done] = PANDA_Select('img', DWIList_Button);
if Done == 1
    set( hObject, 'UserData', LDH_DWIList );
    if ~isempty(LDH_DWIList)
        DWITable = LDH_DWIList;
        set( handles.RawPath_DestPath, 'data', DWITable);
    else
        DWITable = cell(4,3);
        set( handles.RawPath_DestPath, 'data', DWITable);  
    end
    ResizeRawPathDestPathTable(handles);
end


function SubjectIDEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubjectIDEdit as text
%        str2double(get(hObject,'String')) returns contents of SubjectIDEdit as a double
global LDH_DWIList;
global LDH_BvalsList;
global LDH_FAList;
global LDH_SubjectIDArray;
global LDH_ResultPath;
if isempty(LDH_BvalsList)
    msgbox('Please input bvals files for all the subjects.');
    set(hObject, 'String', '');
elseif isempty(LDH_FAList)
    msgbox('Please input FA files for all the subjects.');
    set(hObject, 'String', '');
elseif isempty(LDH_ResultPath)
    msgbox('Please input result path.');
    set(hObject, 'String', '');
else
    SubjectID_Text = mat2str(LDH_SubjectIDArray);
    SubjectID_Text_New = get( hObject, 'string' );
    if ~isempty(LDH_SubjectIDArray) & ~strcmp(SubjectID_Text, SubjectID_Text_New)
        button = questdlg('Subjects ID are changed, are you sure ?','Sure to change ?','Yes','No','Yes');
        switch button
        case 'Yes'
            SubjectID_Text = SubjectID_Text_New;
        case 'No'
            set(hObject, 'string', SubjectID_Text);
            return;
        end
    end
    if isempty(LDH_SubjectIDArray)
        SubjectID_Text = SubjectID_Text_New;
    end
    if ~isempty(SubjectID_Text)
        try
            LDH_SubjectIDArray = eval( SubjectID_Text );
            set( hObject, 'string', mat2str(LDH_SubjectIDArray) );
            % Judge whther the quantity of the subjects is equal to the quantity of the
            % subjects id
            if length(LDH_DWIList) ~= length(LDH_SubjectIDArray)
                info{1} = ['Your subject IDs are ' mat2str(LDH_SubjectIDArray)];
                info{2} = 'I am sorry, the quantity of the subjects is not equal to the quantity of the subjects IDs!';
                info{3} = 'I will delete the subject IDs, please input subject IDs again!';
                msgbox(info);
                set( hObject, 'string', '' );
                SubjectID_Text = '';
                LDH_SubjectIDArray = '';
            else
                % Combine Destination path to Subject id 
                ResultantFolderList = cell(length(LDH_DWIList), 1);
                for i = 1:length(LDH_SubjectIDArray)
                    ResultantFolderList{i} = [LDH_ResultPath filesep num2str(LDH_SubjectIDArray(i), '%05d')];  
                end
                RawData_Destination = [LDH_DWIList LDH_BvalsList LDH_FAList ResultantFolderList];
                set( handles.RawPath_DestPath, 'data', RawData_Destination);  
                ResizeRawPathDestPathTable(handles);
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


function FilePrefixEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FilePrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilePrefixEdit as text
%        str2double(get(hObject,'String')) returns contents of FilePrefixEdit as a double
global LDH_FilePrefixEdit;

TensorPrefixEdit_New = get(hObject, 'string');
ChangeFlag = 0;
if ~isempty(LDH_FilePrefixEdit) & ~strcmp(LDH_FilePrefixEdit, TensorPrefixEdit_New)
    button = questdlg('File prefix is changed, are you sure ?','Sure to change ?','Yes','No','Yes');
    switch button
        case 'Yes'
            LDH_FilePrefixEdit = TensorPrefixEdit_New;
        case 'No'
            set(hObject, 'string', LDH_FilePrefixEdit);
            return;
    end
end
if isempty(LDH_FilePrefixEdit)
    LDH_FilePrefixEdit = TensorPrefixEdit_New;
end
    

% --- Executes during object creation, after setting all properties.
function FilePrefixEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilePrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
%end


function MaxQueuedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxQueuedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxQueuedEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxQueuedEdit as a double
global LDH_Pipeline_opt;
LDH_Pipeline_opt.max_queued = str2num(get(hObject, 'String'));


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
global LDH_Pipeline_opt;
LDH_Pipeline_opt.qsub_options = get(hObject, 'String');


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
global LDH_DWIList;
global LDH_BvalsList;
global LDH_FAList;
global LDH_SubjectIDArray;
global LDH_FilePrefixEdit;
global Neighborhood;
global LDH_Pipeline_opt;
global JobStatusMonitorTimerLDH;
global LDHStopFlag;
global LockExistLDH;
global LockDisappearLDH;
global PANDAPath;
global LDH_ResultPath;
global LDH_NormalizeTarget;

LDHStopFlag = '';
LockFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE.lock'];
if exist(LockFilePath, 'file') | strcmp(get(handles.DWIPathButton, 'Enable'), 'off')
    StringPrint{1} = ['A lock file ' LockFilePath ' has been found on the pipeline !'];
    StringPrint{2} = 'If you want to run this new pipeline, ';
    StringPrint{3} = ['please delete the lock file ' LockFilePath ' first !'];
    msgbox(StringPrint);
else
    if  isempty(LDH_DWIList)
        msgbox('Please input DWI images for all the subjects first.');
    elseif isempty(LDH_BvalsList)
        msgbox('Please input bvals files for all the subjects first.');
    elseif isempty(LDH_SubjectIDArray)
        msgbox('Please assign IDs for subjects!');
    else
        LogPathPermissionDenied = 0;
        try
            if ~exist([LDH_ResultPath filesep 'logs'], 'dir')
                mkdir([LDH_ResultPath filesep 'logs']);
            end
            x = 1;
            save([LDH_ResultPath filesep 'logs' filesep 'permission_tag.mat'], 'x');
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
                ParameterSaveFilePath = [LDH_ResultPath  filesep DateNowString '.PANDA_LDH'];
                cmdString = [ 'save ' ParameterSaveFilePath ' LDH_DWIList' ' LDH_BvalsList' ' LDH_SubjectIDArray' ' LDH_FAList' ' LDH_ResultPath'...
                        ' LDH_FilePrefixEdit' ' LDH_Pipeline_opt' ' Neighborhood' ' PANDAPath'];
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
                    if ~exist([LDH_ResultPath filesep 'logs'])
                        mkdir([LDH_ResultPath filesep 'logs']);
                    end
                    
                    LDH_Pipeline_opt.mode_pipeline_manager = 'background';
                    LDH_Pipeline_opt.flag_verbose = 0;
                    LDH_Pipeline_opt.flag_pause = 0;
                    LDH_Pipeline_opt.path_logs = [LDH_ResultPath filesep 'logs'];
                    
                    for i = 1:length(LDH_DWIList)
                        
                        Number_Of_Subject_String = num2str(LDH_SubjectIDArray(i), '%05d');
                        [ResultantFolder y z] = fileparts(LDH_DWIList{i});
                        
                        if ~isempty(LDH_FilePrefixEdit)
                            FilePrefix = [LDH_FilePrefixEdit '_' Number_Of_Subject_String];
                        else
                            FilePrefix = Number_Of_Subject_String;
                        end
                        
                        Job_Name = ['DWI2LDH_' Number_Of_Subject_String];
                        pipeline.(Job_Name).command           = 'g_DWI2LDH( opt.DWI4D,opt.Bval,opt.Nvoxel,opt.Prefix,opt.SubjectID,opt.type,opt.ResultantFolder )';
                        pipeline.(Job_Name).files_out.files{1}= [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood - 1, '%02d') 'LDHs.nii.gz'];
                        pipeline.(Job_Name).files_out.files{2}= [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood, '%02d') 'LDHk.nii.gz'];
                        pipeline.(Job_Name).opt.DWI4D         = LDH_DWIList{i};
                        pipeline.(Job_Name).opt.Bval          = LDH_BvalsList{i};
                        pipeline.(Job_Name).opt.Nvoxel        = Neighborhood - 1;
                        pipeline.(Job_Name).opt.Prefix        = LDH_FilePrefixEdit;
                        pipeline.(Job_Name).opt.SubjectID     = Number_Of_Subject_String;
                        pipeline.(Job_Name).opt.type          = 'both';
                        pipeline.(Job_Name).opt.ResultantFolder = [LDH_ResultPath filesep Number_Of_Subject_String];
                        
                        [~, FileName, Suffix] = fileparts(LDH_FAList{i});
                        if strcmp(Suffix, '.gz')
                            FABeforeNormalize_Output = [LDH_ResultPath filesep Number_Of_Subject_String filesep FileName(1:end-4) '_4normalize.nii.gz'];
                            FANormalize_Output = [LDH_ResultPath filesep Number_Of_Subject_String filesep 'transformation' filesep FileName(1:end-4) '_4normalize_to_target_warp.nii.gz'];
                        elseif strcmp(Suffix, '.nii')
                            FABeforeNormalize_Output = [LDH_ResultPath filesep Number_Of_Subject_String filesep FileName '_4normalize.nii.gz'];
                            FANormalize_Output = [LDH_ResultPath filesep Number_Of_Subject_String filesep 'transformation' filesep FileName '_4normalize_to_target_warp.nii.gz'];
                        end
                        LDHsBeforeNormalize_Output = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood - 1, '%02d') 'LDHs_4normalize.nii.gz'];
                        LDHkBeforeNormalize_Output = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood, '%02d') 'LDHk_4normalize.nii.gz'];
                        
                        Job_Name20 = [ 'CopyFA_',Number_Of_Subject_String ];
                        pipeline.(Job_Name20).command                = 'system([''cp '' opt.FA '' '' files_out.files{1}])';
                        pipeline.(Job_Name20).files_out.files{1}     = [LDH_ResultPath filesep Number_Of_Subject_String filesep FileName Suffix];
                        pipeline.(Job_Name20).opt.FA                 = LDH_FAList{i};
                        
                        Job_Name2 = [ 'BeforeNormalize_FA_',Number_Of_Subject_String ];
                        pipeline.(Job_Name2).command                = 'g_BeforeNormalize( opt.FA_file,opt.JobName )';
                        pipeline.(Job_Name2).files_in               = pipeline.(Job_Name20).files_out.files;
                        pipeline.(Job_Name2).files_out.files{1}     = FABeforeNormalize_Output;
                        pipeline.(Job_Name2).opt.FA_file            = pipeline.(Job_Name20).files_out.files{1};
                        pipeline.(Job_Name2).opt.JobName    = Job_Name2;
                        
                        Job_Name3 = [ 'BeforeNormalize_LDHs_',Number_Of_Subject_String ];
                        pipeline.(Job_Name3).command                = 'g_BeforeNormalize( opt.LDHs_file,opt.JobName )';
                        pipeline.(Job_Name3).files_in     = pipeline.(Job_Name).files_out.files{1};
                        pipeline.(Job_Name3).files_out.files{1}     = LDHsBeforeNormalize_Output;
                        pipeline.(Job_Name3).opt.LDHs_file          = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood - 1, '%02d') 'LDHs.nii.gz'];
                        pipeline.(Job_Name3).opt.JobName    = Job_Name3;
                        
                        Job_Name4 = [ 'BeforeNormalize_LDHk_',Number_Of_Subject_String ];
                        pipeline.(Job_Name4).command                = 'g_BeforeNormalize( opt.LDHk_file,opt.JobName )';
                        pipeline.(Job_Name4).files_in     = pipeline.(Job_Name).files_out.files{2};
                        pipeline.(Job_Name4).files_out.files{1}     = LDHkBeforeNormalize_Output;
                        pipeline.(Job_Name4).opt.LDHk_file          = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood, '%02d') 'LDHk.nii.gz'];
                        pipeline.(Job_Name4).opt.JobName    = Job_Name4;
                        
                        Job_Name5 = [ 'FAnormalize_',Number_Of_Subject_String ];
                        pipeline.(Job_Name5).command             = 'g_FAnormalize( opt.FA_4tbss_file,opt.target,opt.JobName,opt.ResultantFolder )';
                        pipeline.(Job_Name5).files_in.files      = pipeline.(Job_Name2).files_out.files;
                        pipeline.(Job_Name5).files_out.files{1}  = FANormalize_Output;
                        pipeline.(Job_Name5).opt.FA_4tbss_file   = FABeforeNormalize_Output;
                        pipeline.(Job_Name5).opt.target          = LDH_NormalizeTarget;
                        pipeline.(Job_Name5).opt.JobName    =  Job_Name5;
                        pipeline.(Job_Name5).opt.ResultantFolder = [LDH_ResultPath filesep Number_Of_Subject_String];
                        
                        % applywarp LDH (1mm) Spearman job
                        Job_Name6 = [ 'applywarp_LDHs_1mm_',Number_Of_Subject_String ];
                        pipeline.(Job_Name6).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName,[],opt.ResultantFolder )';
                        pipeline.(Job_Name6).files_in.files1    = pipeline.(Job_Name3).files_out.files;
                        pipeline.(Job_Name6).files_in.files2    = pipeline.(Job_Name5).files_out.files;
                        pipeline.(Job_Name6).files_out.files{1} = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm.nii.gz'];
                        pipeline.(Job_Name6).opt.raw_file       = LDHsBeforeNormalize_Output;
                        pipeline.(Job_Name6).opt.warp_file      = FANormalize_Output;
                        pipeline.(Job_Name6).opt.ref_fileName   = 1;
                        pipeline.(Job_Name6).opt.JobName    =  Job_Name6;
                        pipeline.(Job_Name6).opt.ResultantFolder = [LDH_ResultPath filesep Number_Of_Subject_String];

                        % applywarp LDH (1mm) Kendall job
                        Job_Name7 = [ 'applywarp_LDHk_1mm_',Number_Of_Subject_String ];
                        pipeline.(Job_Name7).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName,[],opt.ResultantFolder )';
                        pipeline.(Job_Name7).files_in.files1    = pipeline.(Job_Name4).files_out.files;
                        pipeline.(Job_Name7).files_in.files2    = pipeline.(Job_Name5).files_out.files;
                        pipeline.(Job_Name7).files_out.files{1} = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm.nii.gz'];
                        pipeline.(Job_Name7).opt.raw_file       = LDHkBeforeNormalize_Output;
                        pipeline.(Job_Name7).opt.warp_file      = FANormalize_Output;
                        pipeline.(Job_Name7).opt.ref_fileName   = 1;
                        pipeline.(Job_Name7).opt.JobName    =  Job_Name7;
                        pipeline.(Job_Name7).opt.ResultantFolder = [LDH_ResultPath filesep Number_Of_Subject_String];
                        
                        % applywarp LDH (2mm) Spearman job
                        Job_Name8 = [ 'applywarp_LDHs_2mm_',Number_Of_Subject_String ];
                        pipeline.(Job_Name8).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName,[],opt.ResultantFolder )';
                        pipeline.(Job_Name8).files_in.files1    = pipeline.(Job_Name3).files_out.files;
                        pipeline.(Job_Name8).files_in.files2    = pipeline.(Job_Name5).files_out.files;
                        pipeline.(Job_Name8).files_out.files{1} = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_2mm.nii.gz'];
                        pipeline.(Job_Name8).opt.raw_file       = LDHsBeforeNormalize_Output;
                        pipeline.(Job_Name8).opt.warp_file      = FANormalize_Output;
                        pipeline.(Job_Name8).opt.ref_fileName   = 2;
                        pipeline.(Job_Name8).opt.JobName    =  Job_Name8;
                        pipeline.(Job_Name8).opt.ResultantFolder = [LDH_ResultPath filesep Number_Of_Subject_String];

                        % applywarp LDH (2mm) Kendall job
                        Job_Name9 = [ 'applywarp_LDHk_2mm_',Number_Of_Subject_String ];
                        pipeline.(Job_Name9).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName,[],opt.ResultantFolder )';
                        pipeline.(Job_Name9).files_in.files1    = pipeline.(Job_Name4).files_out.files;
                        pipeline.(Job_Name9).files_in.files2    = pipeline.(Job_Name5).files_out.files;
                        pipeline.(Job_Name9).files_out.files{1} = [LDH_ResultPath filesep  Number_Of_Subject_String filesep FilePrefix '_' num2str(Neighborhood, '%02d') 'LDHk_4normalize_to_target_2mm.nii.gz'];
                        pipeline.(Job_Name9).opt.raw_file       = LDHkBeforeNormalize_Output;
                        pipeline.(Job_Name9).opt.warp_file      = FANormalize_Output;
                        pipeline.(Job_Name9).opt.ref_fileName   = 2;
                        pipeline.(Job_Name9).opt.JobName    =  Job_Name9;
                        pipeline.(Job_Name9).opt.ResultantFolder = [LDH_ResultPath filesep Number_Of_Subject_String];
                        
                    end
                        
                    psom_run_pipeline(pipeline, LDH_Pipeline_opt);
                    
                    set(handles.DWIPathButton, 'Enable', 'off');
                    set(handles.BvalsPathButton, 'Enable', 'off');
                    set(handles.SubjectIDEdit, 'Enable', 'off');
                    set(handles.FilePrefixEdit, 'Enable', 'off');
                    set(handles.SevenRadio, 'Enable', 'off');
                    set(handles.NineteenRadio, 'Enable', 'off');
                    set(handles.TwentySevenRadio, 'Enable', 'off');
                    set(handles.FAPathButton, 'Enable', 'off');
                    set(handles.NormalizeTargetEdit, 'Enable', 'off');
                    set(handles.NormalizeTargetButton, 'Enable', 'off');
                    set(handles.ResultPathEdit, 'Enable', 'off');
                    set(handles.ResultPathButton, 'Enable', 'off');
                    set(handles.batchRadio, 'Enable', 'off');
                    set(handles.qsubRadio, 'Enable', 'off');
                    set(handles.MaxQueuedEdit, 'Enable', 'off');
                    set(handles.QsubOptionsEdit, 'Enable', 'off');
                    
                    % Set the initial value in the monitor table
                    StatusFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE_status.mat'];
                    
                    JobsStatus = cell(length(LDH_DWIList), 4);
                    for i = 1:length(LDH_DWIList)
                        JobsStatus{i, 1} = 'wait';
                        JobsStatus{i, 2} = 'wait';
                        JobsStatus{i, 3} = 'wait';
                        JobsStatus{i, 4} = 'wait';
                    end
                    set( handles.JobStatusTable, 'data', JobsStatus);
                    LockExistLDH = 0;
                    LockDisappearLDH = 0;
                    % Start monitor function
                    LDHStopFlag = '';
                    JobStatusMonitorTimerLDH = timer( 'TimerFcn', {@JobStatusMonitorLDH, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
                    start(JobStatusMonitorTimerLDH);
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
global LDH_DWIList;
global LDH_BvalsList;
global LDH_SubjectIDArray;
global LDH_FilePrefixEdit;
global Neighborhood;
global LDH_Pipeline_opt;
global JobStatusMonitorTimerLDH;
global LDHStopFlag;
global LockExistLDH;
global LockDisappearLDH;
global PANDAPath;
global LDH_FAList;
global LDH_ResultPath;

if strcmp(get(handles.DWIPathButton, 'Enable'), 'off')
    msgbox('Please clear first !');
else
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_LDH','LDH-files (*.PANDA_LDH)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        if ~isempty([LDH_ResultPath filesep 'logs'])
            LockFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE.lock'];
        end
        cmdString = ['load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        set( handles.SubjectIDEdit, 'String', mat2str(LDH_SubjectIDArray));
        set( handles.FilePrefixEdit, 'String', LDH_FilePrefixEdit);
        if Neighborhood == 7
            set(handles.SevenRadio, 'Value', 1);
            set(handles.NineteenRadio, 'Value', 0);
            set(handles.TwentySevenRadio, 'Value', 0);
        elseif Neighborhood == 19
            set(handles.SevenRadio, 'Value', 0);
            set(handles.NineteenRadio, 'Value', 1);
            set(handles.TwentySevenRadio, 'Value', 0);
        elseif Neighborhood == 27
            set(handles.SevenRadio, 'Value', 0);
            set(handles.NineteenRadio, 'Value', 0);
            set(handles.TwentySevenRadio, 'Value', 1);
        end
        set(handles.ResultPathEdit, 'String', LDH_ResultPath);
        ResultantFolderList = cell(length(LDH_DWIList), 1);
        for i = 1:length(LDH_SubjectIDArray)
            ResultantFolderList{i} = [LDH_ResultPath filesep num2str(LDH_SubjectIDArray(i), '%05d')];
        end
        RawData_Destination = [LDH_DWIList LDH_BvalsList LDH_FAList ResultantFolderList];
        set( handles.RawPath_DestPath, 'data', RawData_Destination);
        ResizeRawPathDestPathTable(handles);
        if strcmp(LDH_Pipeline_opt.mode,'background')
            set( handles.batchRadio, 'Value', 1 );
        else
            set( handles.qsubRadio, 'Value', 1 );
            set( handles.QsubOptionsEdit, 'Enable', 'on');
            set( handles.QsubOptionsEdit, 'string', LDH_Pipeline_opt.qsub_options);
        end
        set( handles.MaxQueuedEdit, 'string', num2str(LDH_Pipeline_opt.max_queued) );
        % Display job status in the Job Status Table
        LockFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE.lock'];
        if exist(LockFilePath, 'file')
            LockExistLDH = 1;
            LockDisappearLDH = 0;
            LDHStopFlag = '';
            JobStatusMonitorTimerLDH = timer( 'TimerFcn', {@JobStatusMonitorLDH, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
            start(JobStatusMonitorTimerLDH);
            % Set edit box and button unable
            set(handles.DWIPathButton, 'Enable', 'off');
            set(handles.BvalsPathButton, 'Enable', 'off');
            set(handles.SubjectIDEdit, 'Enable', 'off');
            set(handles.FilePrefixEdit, 'Enable', 'off');
            set(handles.SevenRadio, 'Enable', 'off');
            set(handles.NineteenRadio, 'Enable', 'off');
            set(handles.TwentySevenRadio, 'Enable', 'off');
            set(handles.FAPathButton, 'Enable', 'off');
            set(handles.NormalizeTargetEdit, 'Enable', 'off');
            set(handles.NormalizeTargetButton, 'Enable', 'off');
            set(handles.ResultPathEdit, 'Enable', 'off');
            set(handles.ResultPathButton, 'Enable', 'off');
            set(handles.batchRadio, 'Enable', 'off');
            set(handles.qsubRadio, 'Enable', 'off');
            set(handles.MaxQueuedEdit, 'Enable', 'off');
            set(handles.QsubOptionsEdit, 'Enable', 'off');
        else
            LDHStopFlag = '(Stopped)'; 
            JobStatusMonitorLDH(hObject, eventdata, handles);
        end
    end
end


% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_DWIList;
global LDH_BvalsList;
global LDH_FAList;
global LDH_SubjectIDArray;
global LDH_FilePrefixEdit;
global Neighborhood;
global LDH_Pipeline_opt;
global JobStatusMonitorTimerLDH;
global LDHStopFlag;
global LockExistLDH;
global LockDisappearLDH;
global LDH_NormalizeTarget;

button = questdlg('Are you sure to Clear ?','Sure to Clear ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop the monitor
        if ~isempty(JobStatusMonitorTimerLDH)
            stop(JobStatusMonitorTimerLDH);
            clear global JobStatusMonitorTimerLDH;
        end
        
        clear global LDHStopFlag;
        clear global LockExistLDH;
        clear global LockDisappearLDH;

        set(handles.DWIPathButton, 'Enable', 'on');
        set(handles.BvalsPathButton, 'Enable', 'on');
        set(handles.SubjectIDEdit, 'Enable', 'on');
        set(handles.SubjectIDEdit, 'String', '');
        set(handles.FilePrefixEdit, 'Enable', 'on');
        set(handles.FilePrefixEdit, 'String', '');
        set(handles.SevenRadio, 'Enable', 'on');
        set(handles.NineteenRadio, 'Enable', 'on');
        set(handles.TwentySevenRadio, 'Enable', 'on');
        set(handles.SevenRadio, 'Value', 1);
        set(handles.FAPathButton, 'Enable', 'on');
        set(handles.NormalizeTargetEdit, 'Enable', 'on');
        LDH_NormalizeTarget = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        set(handles.NormalizeTargetEdit, 'String', LDH_NormalizeTarget);
        set(handles.NormalizeTargetButton, 'Enable', 'on');
        set(handles.ResultPathEdit, 'Enable', 'on');
        set(handles.ResultPathEdit, 'String', '');
        set(handles.ResultPathButton, 'Enable', 'on');
        set(handles.batchRadio, 'Enable', 'on');
        set(handles.qsubRadio, 'Enable', 'on');
        set(handles.MaxQueuedEdit, 'Enable', 'on');
        set(handles.QsubOptionsEdit, 'Enable', 'off');
        % Back to default values
        LDH_DWIList = '';
        LDH_BvalsList = '';
        LDH_FAList = '';
        LDH_SubjectIDArray = '';
        LDH_FilePrefixEdit = '';
        Neighborhood = 7;
        % Pipeline options
        LDH_Pipeline_opt.flag_verbose = 0;
        LDH_Pipeline_opt.flag_pause = 0;
        set( handles.batchRadio, 'Value', 1);
        LDH_Pipeline_opt.mode = 'background';
        set( handles.QsubOptionsEdit, 'String', '');
        set( handles.QsubOptionsEdit, 'Enable', 'off');
        LDH_Pipeline_opt.qsub_options = '';
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
            LDH_Pipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            LDH_Pipeline_opt.max_queued = 2;
        end
        set( handles.MaxQueuedEdit, 'string', num2str(LDH_Pipeline_opt.max_queued));
        % Set the Paths Table to default
        RawDestPathCell = cell(4,3);
        set( handles.RawPath_DestPath, 'data', RawDestPathCell );
        ResizeRawPathDestPathTable(handles);
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
global LDHStopFlag;
global LDH_Pipeline_opt;
global JobStatusMonitorTimerLDH;
global LockDisappearLDH;
global LDH_ResultPath;

LockFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE.lock'];
if ~exist(LockFilePath, 'file')
    msgbox('No job is running !');
else
    button = questdlg('Are you sure to terminal this job ?','Sure to terminal ?','Yes','No','Yes');
    switch button
        case 'Yes'   
            % Stop the monitor
            if ~isempty(JobStatusMonitorTimerLDH)
                stop(JobStatusMonitorTimerLDH);
                clear global JobStatusMonitorTimerLDH;
            end
            
            cmdString = ['rm -rf ' LockFilePath];
            system(cmdString);
            msgbox('The job is terminated sucessfully!');
            % Set edit box enable, Stop Monitor, Update job status table
            LDHStopFlag = '(Stopped)';
            while exist(LockFilePath, 'file')
                system(['rm -rf ' LockFilePath]);
            end
            LockDisappearLDH = 1;
            JobStatusMonitorLDH(hObject, eventdata, handles);
        case 'No'
            return;
    end
end


% --- Executes on button press in LogsButton.
function LogsButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_DWIList;
global LDH_Pipeline_opt;
global LDH_ResultPath;
if isempty(LDH_DWIList)
    [ParameterSaveFileName,ParameterSaveFilePath] = uigetfile({'*.PANDA_LDH','PANDA-files (*.PANDA_LDH)'},'Load Configuration');
    if ParameterSaveFileName ~= 0
        cmdString = ['PANDAConfiguration = load(''' ParameterSaveFilePath filesep ParameterSaveFileName ''', ''-mat'')'];
        eval( cmdString );
        LogsPath = [LDH_ResultPath filesep 'logs'];    
    end
else
    try
        PANDALogsFile = [LDH_ResultPath filesep 'logs' filesep 'PIPE_logs.mat'];
        PANDAStatusFile = [LDH_ResultPath filesep 'logs' filesep 'PIPE_status.mat'];
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
                PANDA_FailedLogs(PANDALogs, FailedJobNames, [LDH_ResultPath filesep 'logs']);
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


% --- Executes on button press in SevenRadio.
function SevenRadio_Callback(hObject, eventdata, handles)
% hObject    handle to SevenRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SevenRadio
global Neighborhood;
Neighborhood = 7;
set(handles.SevenRadio, 'Value', 1);
set(handles.NineteenRadio, 'Value', 0);
set(handles.TwentySevenRadio, 'Value', 0);


% --- Executes on button press in NineteenRadio.
function NineteenRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NineteenRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NineteenRadio
global Neighborhood;
Neighborhood = 19;
set(handles.SevenRadio, 'Value', 0);
set(handles.NineteenRadio, 'Value', 1);
set(handles.TwentySevenRadio, 'Value', 0);


% --- Executes on button press in TwentySevenRadio.
function TwentySevenRadio_Callback(hObject, eventdata, handles)
% hObject    handle to TwentySevenRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TwentySevenRadio
global Neighborhood;
Neighborhood = 27;
set(handles.SevenRadio, 'Value', 0);
set(handles.NineteenRadio, 'Value', 0);
set(handles.TwentySevenRadio, 'Value', 1);


% --- Executes on button press in BvalsPathButton.
function BvalsPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to BvalsPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_DWIList;
global LDH_BvalsList;
if isempty(LDH_DWIList)
    msgbox('Please input DWI images for all the subjects first.');
else
    BvalsList_Button = get(hObject, 'UserData');
    [~, LDH_BvalsList, Done] = PANDA_Select('file', BvalsList_Button);
    if Done == 1
        set( hObject, 'UserData', LDH_BvalsList );
        if ~isempty(LDH_DWIList) & ~isempty(LDH_BvalsList) 
            if length(LDH_DWIList) ~= length(LDH_BvalsList)
                msgbox(['I''m sorry, the quantity of bvals files should be equal to the quantity' ...
                    ' of DWI images']);
                LDH_BvalsList = '';
            else
                DWI_BvalsTable = [LDH_DWIList LDH_BvalsList];
                set( handles.RawPath_DestPath, 'data', DWI_BvalsTable);
            end
        else
            DWI_BvalsTable = LDH_DWIList;
            set( handles.RawPath_DestPath, 'data', DWI_BvalsTable);  
        end
        ResizeRawPathDestPathTable(handles);
    end
end


function ResizeRawPathDestPathTable(handles)
RawPathDestPath = get(handles.RawPath_DestPath, 'data');
PositionFigure = get(handles.PANDALDHFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 4;
WidthCell{2} = WidthCell{1};
WidthCell{3} = WidthCell{1};
WidthCell{4} = WidthCell{1};
if ~isempty(RawPathDestPath)
    [rows, columns] = size(RawPathDestPath);
    for i = 1:columns
        for j = 1:rows
            tmp_PANDA{j} = length(RawPathDestPath{j, i}) * 8;
            tmp_PANDA{j} = tmp_PANDA{j} * PositionFigure(4) / 701;
        end
        NewWidthCell{i} = max(cell2mat(tmp_PANDA));
        if NewWidthCell{i} > WidthCell{i}
           WidthCell{i} =  NewWidthCell{i};
        end
    end
end
set(handles.RawPath_DestPath, 'ColumnWidth', WidthCell);


function ResizeJobStatusTable(handles)
PositionFigure = get(handles.PANDALDHFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 4;
WidthCell{2} = WidthCell{1};
WidthCell{3} = WidthCell{1};
WidthCell{4} = WidthCell{1};
set(handles.JobStatusTable, 'ColumnWidth', WidthCell);


% --- Executes when PANDALDHFigure is resized.
function PANDALDHFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDALDHFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.PANDALDHFigure, 'Position');
    ResizeRawPathDestPathTable(handles);
    ResizeJobStatusTable(handles);
    FontSizePipelineOptionsUipanel = ceil(10 * PositionFigure(4) / 605);
    set( handles.PipelineOptionsUipanel, 'FontSize', FontSizePipelineOptionsUipanel );
end


% --- Executes when selected object is changed in PipelineOptionsUipanel.
function PipelineOptionsUipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PipelineOptionsUipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global LDH_Pipeline_opt;
switch get(hObject, 'tag')
    case 'batchRadio'
        LDH_Pipeline_opt.mode = 'background';
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
            LDH_Pipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            LDH_Pipeline_opt.max_queued = 2;
        end
        set(handles.MaxQueuedEdit, 'string', num2str(LDH_Pipeline_opt.max_queued));
    case 'qsubRadio'
        LDH_Pipeline_opt.mode = 'qsub';
        LDH_Pipeline_opt.qsub_options = '-V -q all.q';
        set( handles.QsubOptionsEdit, 'Enable', 'on');
        set( handles.QsubOptionsEdit, 'String', '-V -q all.q');
        LDH_Pipeline_opt.max_queued = 40;
        set(handles.MaxQueuedEdit, 'string', num2str(LDH_Pipeline_opt.max_queued));
end


% --- Executes when user attempts to close PANDALDHFigure.
function PANDALDHFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDALDHFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

global LDH_DWIList;
global LDH_BvalsList;
global LDH_FAList;
global LDH_SubjectIDArray;
global LDH_FilePrefixEdit;
global Neighborhood;
global LDH_Pipeline_opt;
global LDHStopFlag;
global JobStatusMonitorTimerLDH;
global LockExistLDH;
global LockDisappearLDH;

button = questdlg('Are you sure to quit ?','Sure to Quit ?','Yes','No','Yes');
switch button
    case 'Yes'
        % Stop the monitor
        if ~isempty(JobStatusMonitorTimerLDH)
            stop(JobStatusMonitorTimerLDH);
            clear global JobStatusMonitorTimerLDH;
        end
        clear global LDH_DWIList;
        clear global LDH_BvalsList;
        clear global LDH_FAList;
        clear global LDH_SubjectIDArray;
        clear global LDH_FilePrefixEdit;
        clear global Neighborhood;
        clear global LDH_Pipeline_opt;
        clear global LDHStopFlag;
        clear global LockExistLDH;
        clear global LockDisappearLDH;
        delete(hObject);
    case 'No'
        return;
end



% function LogPathEdit_Callback(hObject, eventdata, handles)
% % hObject    handle to LogPathEdit (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of LogPathEdit as text
% %        str2double(get(hObject,'String')) returns contents of LogPathEdit as a double
% global LDH_Pipeline_opt;
% LogPath = get(hObject, 'String');
% if ~exist(LogPath, 'dir')
%     try
%         mkdir(LogPath);
%     catch
%         msgbox('The path you input is illegal !');
%     end
% end
% LDH_Pipeline_opt.path_logs = [LogPath filesep 'LDH_logs'];


% % --- Executes during object creation, after setting all properties.
% function LogPathEdit_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to LogPathEdit (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% %if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% %end


% % --- Executes on button press in LogPathButton.
% function LogPathButton_Callback(hObject, eventdata, handles)
% % hObject    handle to LogPathButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global LDH_Pipeline_opt;
% LogPath = uigetdir;
% if LogPath
%     LDH_Pipeline_opt.path_logs = [LogPath filesep 'LDH_logs'];
%     set( handles.LogPathEdit, 'String', LogPath);
% end


% --- Monitor Function
function JobStatusMonitorLDH(hObject, eventdata, handles)
% Print jobs status in the table
global LDH_DWIList;
global LDH_SubjectIDArray;
global LDH_Pipeline_opt;
global JobStatusMonitorTimerLDH;
global LDHStopFlag;
global LockExistLDH;
global LockDisappearLDH;
global LDH_ResultPath;

% Judge whether the job is running, if so, the edit box will readonly
LockFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE.lock'];
if LockExistLDH == 0 & exist( LockFilePath, 'file' )
    LockExistLDH = 1;
end
if LockExistLDH & ~exist( LockFilePath, 'file' )
    LockDisappearLDH = 1;
end
if LockDisappearLDH == 1
    % Set edit box enable
    set(handles.DWIPathButton, 'Enable', 'on');
    set(handles.BvalsPathButton, 'Enable', 'on');
    set(handles.SubjectIDEdit, 'Enable', 'on');
    set(handles.FilePrefixEdit, 'Enable', 'on');
    set(handles.SevenRadio, 'Enable', 'on');
    set(handles.NineteenRadio, 'Enable', 'on');
    set(handles.TwentySevenRadio, 'Enable', 'on');
    set(handles.SevenRadio, 'Value', 1);
    set(handles.FAPathButton, 'Enable', 'on');
    set(handles.NormalizeTargetEdit, 'Enable', 'on');
    set(handles.NormalizeTargetButton, 'Enable', 'on');
    set(handles.ResultPathEdit, 'Enable', 'on');
    set(handles.ResultPathButton, 'Enable', 'on');
    set(handles.batchRadio, 'Enable', 'on');
    set(handles.qsubRadio, 'Enable', 'on');
    set(handles.MaxQueuedEdit, 'Enable', 'on');
    if strcmp(LDH_Pipeline_opt.mode,'qsub')
        set(handles.QsubOptionsEdit, 'Enable', 'on');
    end
    % Stop Monitor
    if ~isempty(JobStatusMonitorTimerLDH)
        stop(JobStatusMonitorTimerLDH);
        clear global JobStatusMonitorTimerLDH;
    end
end
        
StatusFilePath = [LDH_ResultPath filesep 'logs' filesep 'PIPE_status_backup.mat'];
if exist( StatusFilePath, 'file' )
    warning('off');
    try    
        cmdString = ['load ' StatusFilePath];
        eval(cmdString);
        SubjectQuantity = length(LDH_DWIList);
        JobName = { 'DWI2LDH', 'CopyFA', 'BeforeNormalize_FA', 'BeforeNormalize_LDHs', 'BeforeNormalize_LDHk', ...
            'FAnormalize', 'applywarp_LDHs_1mm', 'applywarp_LDHk_1mm', 'applywarp_LDHs_2mm', 'applywarp_LDHk_2mm'};
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
            SubjectIDArrayString{i} = num2str(LDH_SubjectIDArray(i),'%05.0f');
            
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
                StatusArray{i} = ['running' LDHStopFlag];
                JobNameArray{i} = RunningJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(SubmittedJobName)
                StatusArray{i} = ['submitted' LDHStopFlag];
                JobNameArray{i} = SubmittedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(FailedJobName)
                StatusArray{i} = ['failed' LDHStopFlag];
                JobNameArray{i} = FailedJobName;
                JobLeftArray{i} = num2str(JobLeft);
            elseif ~isempty(WaitJobName)
                StatusArray{i} = ['wait' LDHStopFlag];
                JobNameArray{i} = WaitJobName;
                JobLeftArray{i} = num2str(JobLeft);
            end
        end
        % Combine SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray
        % into a table
        SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray]; 
        set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
        % 
        JobsFinishFilePath = [LDH_ResultPath filesep 'logs' filesep 'jobs.finish'];
        if exist(JobsFinishFilePath, 'file')
            % Set edit box enable
            set(handles.DWIPathButton, 'Enable', 'on');
            set(handles.BvalsPathButton, 'Enable', 'on');
            set(handles.SubjectIDEdit, 'Enable', 'on');
            set(handles.FilePrefixEdit, 'Enable', 'on');
            set(handles.SevenRadio, 'Enable', 'on');
            set(handles.NineteenRadio, 'Enable', 'on');
            set(handles.TwentySevenRadio, 'Enable', 'on');
            set(handles.SevenRadio, 'Value', 1);
            set(handles.NineteenRadio, 'Value', 1);
            set(handles.TwentySevenRadio, 'Value', 1);
            set(handles.FAPathButton, 'Enable', 'on');
            set(handles.NormalizeTargetEdit, 'Enable', 'on');
            set(handles.NormalizeTargetButton, 'Enable', 'on');
            set(handles.ResultPathEdit, 'Enable', 'on');
            set(handles.ResultPathButton, 'Enable', 'on');
            set(handles.batchRadio, 'Enable', 'on');
            set(handles.qsubRadio, 'Enable', 'on');
            set(handles.MaxQueuedEdit, 'Enable', 'on');
            if strcmp(LDH_Pipeline_opt.mode,'qsub')
                set(handles.QsubOptionsEdit, 'Enable', 'on');
            end
            % Stop Monitor
            if ~isempty(JobStatusMonitorTimerLDH)
                stop(JobStatusMonitorTimerLDH);
                clear global JobStatusMonitorTimerLDH;
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


% --- Executes on button press in FAPathButton.
function FAPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to FAPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_FAList;
global LDH_DWIList;
global LDH_BvalsList;
if isempty(LDH_DWIList)
    msgbox('Please input DWI images for all the subjects first.');
elseif isempty(LDH_BvalsList)
    msgbox('Please input b value files for all the subjects.');
else
    FAList_Button = get(hObject, 'UserData');
    [~, LDH_FAList, Done] = PANDA_Select('img', FAList_Button);
    if Done == 1
        set( hObject, 'UserData', LDH_FAList );
        if ~isempty(LDH_FAList)
            FATable = [LDH_DWIList LDH_BvalsList LDH_FAList];
            set( handles.RawPath_DestPath, 'data', FATable);
        else
            FATable = [LDH_DWIList LDH_BvalsList];
            set( handles.RawPath_DestPath, 'data', FATable);  
        end
        ResizeRawPathDestPathTable(handles);
    end
end


function NormalizeTargetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NormalizeTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of NormalizeTargetEdit as a double
global LDH_NormalizeTarget;
NormalizeTargetPath = get( handles.NormalizeTargetEdit, 'string' );
LDH_NormalizeTarget = NormalizeTargetPath;


% --- Executes during object creation, after setting all properties.
function NormalizeTargetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in NormalizeTargetButton.
function NormalizeTargetButton_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizeTargetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_NormalizeTarget;
[NormalizeTargetName,NormalizeTargetParent] = uigetfile({'*.nii;*.nii.gz','NIfTI-files (*.nii, *nii.gz)'});
NormalizeTargetPath = [NormalizeTargetParent NormalizeTargetName];
if ~isnumeric(NormalizeTargetName) & ~isnumeric(NormalizeTargetParent)
    set( handles.NormalizeTargetEdit, 'string', NormalizeTargetPath );
    LDH_NormalizeTarget = NormalizeTargetPath;
end


function ResultPathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ResultPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ResultPathEdit as text
%        str2double(get(hObject,'String')) returns contents of ResultPathEdit as a double
global LDH_ResultPath;
global LDH_FAList;
global LDH_DWIList;
global LDH_BvalsList;
global LDH_SubjectIDArray;
if isempty(LDH_DWIList)
    msgbox('Please input DWI images for all the subjects first.');
elseif isempty(LDH_BvalsList)
    msgbox('Please input b value files for all the subjects.');
elseif isempty(LDH_FAList)
    msgbox('Please input FA images for all the subjects.');
else
    ResultPathInput = get(hObject, 'String');
    if ~isempty(ResultPathInput) & ~exist(ResultPathInput, 'dir')
        try
            mkdir(ResultPathInput);
        catch
            msgbox('The path you input is illegal !');
            return;
        end
    end
    LDH_ResultPath = ResultPathInput;
    % Combine Destination path to Subject id 
    ResultantFolderList = cell(length(LDH_DWIList), 1);
    for i = 1:length(LDH_SubjectIDArray)
        ResultantFolderList{i} = [LDH_ResultPath filesep num2str(LDH_SubjectIDArray(i), '%05d')];
    end
    RawData_Destination = [LDH_DWIList LDH_BvalsList LDH_FAList ResultantFolderList];
    set( handles.RawPath_DestPath, 'data', RawData_Destination);
    ResizeRawPathDestPathTable(handles);
end


% --- Executes during object creation, after setting all properties.
function ResultPathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResultPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in ResultPathButton.
function ResultPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResultPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LDH_ResultPath;
global LDH_FAList;
global LDH_DWIList;
global LDH_BvalsList;
global LDH_SubjectIDArray;
if isempty(LDH_DWIList)
    msgbox('Please input DWI images for all the subjects first.');
elseif isempty(LDH_BvalsList)
    msgbox('Please input b value files for all the subjects.');
elseif isempty(LDH_FAList)
    msgbox('Please input FA images for all the subjects.');
else
    ResultPathInput = uigetdir;
    if ResultPathInput
        LDH_ResultPath = ResultPathInput;
        set(handles.ResultPathEdit, 'String', LDH_ResultPath);
        % Combine Destination path to Subject id 
        ResultantFolderList = cell(length(LDH_DWIList), 1);
        for i = 1:length(LDH_SubjectIDArray)
            ResultantFolderList{i} = [LDH_ResultPath filesep num2str(LDH_SubjectIDArray(i), '%05d')];
        end
        RawData_Destination = [LDH_DWIList LDH_BvalsList LDH_FAList ResultantFolderList];
        set( handles.RawPath_DestPath, 'data', RawData_Destination);
        ResizeRawPathDestPathTable(handles);
    end
end
