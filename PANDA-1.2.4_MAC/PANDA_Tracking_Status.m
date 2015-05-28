function varargout = PANDA_Tracking_Status(varargin)
% GUI for Fiber Tracking status (part of software of PANDA_Tracking), by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_TRACKING_STATUS MATLAB code for PANDA_Tracking_Status.fig
%      PANDA_TRACKING_STATUS, by itself, creates a new PANDA_TRACKING_STATUS or raises the existing
%      singleton*.
%
%      H = PANDA_TRACKING_STATUS returns the handle to a new PANDA_TRACKING_STATUS or the handle to
%      the existing singleton*.
%
%      PANDA_TRACKING_STATUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_TRACKING_STATUS.M with the given input arguments.
%
%      PANDA_TRACKING_STATUS('Property','Value',...) creates a new PANDA_TRACKING_STATUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Tracking_Status_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Tracking_Status_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Tracking_Status

% Last Modified by GUIDE v2.5 01-Oct-2012 15:20:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Tracking_Status_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Tracking_Status_OutputFcn, ...
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


% --- Executes just before PANDA_Tracking_Status is made visible.
function PANDA_Tracking_Status_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Tracking_Status (see VARARGIN)

% Choose default command line output for PANDA_Tracking_Status

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PANDA_Tracking_Status wait for user response (see UIRESUME)
% uiwait(handles.PANDATrackingStatusFigure);

% Start monitor function
global JobStatusMonitorTimer_Status;
JobStatusMonitorTimer_Status = timer( 'TimerFcn', {@JobStatusMonitor, handles}, 'period', 10, 'ExecutionMode', 'fixedRate');
start(JobStatusMonitorTimer_Status);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Tracking_Status_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Stop Monitor
close;


% --- Monitor Function
function JobStatusMonitor(hObject, eventdata, handles)
global trackingAlone_opt;
global TrackingPipeline_opt;
global NativePathCellTracking;
global SubjectIDArrayTracking;
global FAPathCell;
global StatusFilePath;
global StopFlag_InTrackingStatus;

if ~isempty(trackingAlone_opt)
    StatusFilePath = [TrackingPipeline_opt.path_logs filesep 'PIPE_status_backup.mat'];
    if exist( StatusFilePath, 'file' )
        warning('off');
        try
            cmdString = ['load ' StatusFilePath];
            eval(cmdString);
            if ~isempty(NativePathCellTracking)
                SubjectQuantity = length(NativePathCellTracking);
            elseif ~isempty(FAPathCell)
                SubjectQuantity = length(FAPathCell);
            end
            JobName = [];
            if trackingAlone_opt.DterminFiberTracking == 1 
                JobName = [JobName, {'DeterministicTracking'}];
            end
            if trackingAlone_opt.NetworkNode == 1 
                if trackingAlone_opt.T1
                    JobName = [JobName, { 'CopyT1' }];
                    if trackingAlone_opt.T1Bet_Flag
                        JobName = [JobName, {'BetT1'}];
                    end
                    if trackingAlone_opt.T1Cropping_Flag
                        JobName = [JobName, {'T1Cropped'}];
                    end
                    if trackingAlone_opt.T1Resample_Flag
                        JobName = [JobName, {'T1Resample'}];
                    end
                    JobName = [JobName, { 'FAtoT1', 'T1toMNI152', 'Invwarp', 'IndividualParcellated'}];
                end
            end
            if trackingAlone_opt.DeterministicNetwork == 1
                JobName = [JobName, {'DeterministicNetwork'}];
            end
            if trackingAlone_opt.BedpostxProbabilisticNetwork
                JobName = [JobName, {'BedpostX_preproc'}];
                for BedpostXJobNum = 1:10
                    JobName = [JobName, {['BedpostX_' num2str(BedpostXJobNum, '%02.0f')]}];
                end
                JobName = [JobName, {'BedpostX_postproc'}];
            end
            if trackingAlone_opt.ProbabilisticNetwork || trackingAlone_opt.BedpostxProbabilisticNetwork
                JobName = [JobName, {'ProbabilisticNetworkpre'}];
                ProbabilisticNetworkJobQuantity = min(length(trackingAlone_opt.LabelIdVector), 80);
                for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
                    JobName = [JobName, {['ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d')]}];
                end
                ProbabilisticNetworkPostJobQuantity = min(length(trackingAlone_opt.LabelIdVector), 10);
                for ProbabilisticNetworkPostJobNum = 1:ProbabilisticNetworkPostJobQuantity
                    JobName = [JobName, {['ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f')]}];
                end
                JobName = [ JobName, {'ProbabilisticNetworkpost_MergeResults'}];
            end
            JobQuantity = length(JobName);
            SubjectIDArrayString = cell(SubjectQuantity, 1);
            StatusArray = cell(SubjectQuantity, 1);
            JobNameArray = cell(SubjectQuantity, 1);
            JobLeftArray = cell(SubjectQuantity, 1);
            
            if trackingAlone_opt.DterminFiberTracking == 1
                if exist([TrackingPipeline_opt.path_logs filesep 'DeterministicTrackingResultExist.mat'], 'file')
                    cmdString = ['load ' TrackingPipeline_opt.path_logs filesep 'DeterministicTrackingResultExist.mat'];
                    eval(cmdString);
                end
            end
            
            for i = 1:SubjectQuantity 
            % Calculate job status of the ith subject 
                RunningJobName = '';
                WaitJobName = '';
                SubmittedJobName = '';
                FailedJobName = '';
                JobLeft = 0;
                StatusArray{i} = 'none';
                SubjectIDArrayString{i} = num2str(SubjectIDArrayTracking(i),'%05.0f');
%                 if trackingAlone_opt.DterminFiberTracking & DeterministicTrackingResultExist(i)
%                     JobQuantity = JobQuantity - 1;
%                 end
                for j = 1:JobQuantity
                    % Check the status of all jobs of the ith subject and  acquire
                    % the status of the subject
                    % The subject has three situations:
                    %     1. 'failed': which job 
                    %     2. 'running': which job
                    %     3. 'submitted': which job
                    %     4. 'wait': which job
                    %     5. 'finished'
                    if strcmp(JobName{j},'DeterministicTracking')
                        if DeterministicTrackingResultExist(i)
                            continue;
                        end
                    end
                    
                    VariableName = [JobName{j} '_' SubjectIDArrayString{i}];
                    if strcmp(eval(VariableName), 'running')
                        JobLeft = JobLeft + 1;
                        if isempty(RunningJobName)
                            RunningJobName = JobName{j};
                            RunningJobLeft = num2str(JobQuantity - j);
                        end
                    elseif strcmp(eval(VariableName), 'submitted')
                        JobLeft = JobLeft + 1;
                        if isempty(SubmittedJobName)
                            SubmittedJobName = JobName{j};
                            SubmittedJobLeft = num2str(JobQuantity - j);
                        end
                    elseif strcmp(eval(VariableName), 'none')
                        JobLeft = JobLeft + 1;
                        if isempty(WaitJobName)
                            WaitJobName = JobName{j};
                            WaitJobLeft = num2str(JobQuantity - j + 1);
                        end
                    elseif strcmp(eval(VariableName), 'failed')
                        JobLeft = JobLeft + 1;
                        if isempty(FailedJobName)
                            FailedJobName = JobName{j};
                            FailedJobLeft = num2str(JobQuantity - j + 1);
                        end
                    end
                end  
                if isempty(RunningJobName) & isempty(SubmittedJobName) ...
                    & isempty(WaitJobName) & isempty(FailedJobName)
                    StatusArray{i} = ['finished'];
                    JobNameArray{i} = '';
                    JobLeftArray{i} = '0';
                elseif ~isempty(RunningJobName)
                    StatusArray{i} = ['running' StopFlag_InTrackingStatus];
                    JobNameArray{i} = RunningJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                elseif ~isempty(SubmittedJobName)
                    StatusArray{i} = ['submitted' StopFlag_InTrackingStatus];
                    JobNameArray{i} = SubmittedJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                elseif ~isempty(FailedJobName)
                    StatusArray{i} = ['failed' StopFlag_InTrackingStatus];
                    JobNameArray{i} = FailedJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                elseif ~isempty(WaitJobName)
                    StatusArray{i} = ['wait' StopFlag_InTrackingStatus];
                    JobNameArray{i} = WaitJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                end
            end    
            % Combine SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray
            % into a table
            SubjectsJobStatusTable = [SubjectIDArrayString, StatusArray, JobNameArray, JobLeftArray]; 
            set( handles.JobStatusTable, 'data', SubjectsJobStatusTable);
            ResizeJobStatusTable(handles); 
        catch
            none = 0;
        end
        warning('off');
    end
end


% --- Executes when user attempts to close PANDATrackingStatusFigure.
function PANDATrackingStatusFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDATrackingStatusFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global JobStatusMonitorTimer_Status;
if ~isempty(JobStatusMonitorTimer_Status)
    stop(JobStatusMonitorTimer_Status);
    clear global JobStatusMonitorTimer_Status;
end
delete(hObject);


% --- Executes when PANDATrackingStatusFigure is resized.
function PANDATrackingStatusFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDATrackingStatusFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    PositionFigure = get(handles.PANDATrackingStatusFigure, 'Position');
    ResizeJobStatusTable(handles);
end


function ResizeJobStatusTable(handles)
PositionFigure = get(handles.PANDATrackingStatusFigure, 'Position');
WidthCell{1} = PositionFigure(3) / 4;
WidthCell{2} = WidthCell{1};
WidthCell{3} = WidthCell{1};
WidthCell{4} = WidthCell{1};
set(handles.JobStatusTable, 'ColumnWidth', WidthCell);


% --- Executes on button press in StatusTableText.
function StatusTableText_Callback(hObject, eventdata, handles)
% hObject    handle to StatusTableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function JobStatusTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to JobStatusTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
