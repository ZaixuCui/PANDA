function varargout = PANDA_Select(varargin)
% GUI for selecting files/directories, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%      Copyright(c) 2012
%      State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%      Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%      Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%      Version 1.2.0;
%      Date 
%      Last edited 
%--------------------------------------------------------------------------
% PANDA_SELECT MATLAB code for PANDA_Select.fig
%      PANDA_SELECT, by itself, creates a new PANDA_SELECT or raises the existing
%      singleton*.
%
%      H = PANDA_SELECT returns the handle to a new PANDA_SELECT or the handle to
%      the existing singleton*.
%
%      PANDA_SELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANDA_SELECT.M with the given input arguments.
%
%      PANDA_SELECT('Property','Value',...) creates a new PANDA_SELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PANDA_Select_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PANDA_Select_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PANDA_Select

% Last Modified by GUIDE v2.5 15-Jul-2013 13:43:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PANDA_Select_OpeningFcn, ...
                   'gui_OutputFcn',  @PANDA_Select_OutputFcn, ...
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


% --- Executes just before PANDA_Select is made visible.
function PANDA_Select_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PANDA_Select (see VARARGIN)

% Choose default command line output for PANDA_Select
global Type;
global CurrentDir;
global SelectedDirectoriesFiles;
% global DirSelectedDirectoriesFiles;
% global ImgSelectedDirectoriesFiles;
% global ImgAllSelectedDirectoriesFiles;
% global FileSelectedDirectoriesFiles;
global DirPreviousDir;
global ImgPreviousDir;
global ImgAllPreviousDir;
global FilePreviousDir;
global Done;
global PreviousDirCell;
% global ParentGUI;

Done = 0;
handles.output = hObject;

% Update handles structure

if length(varargin) >= 2
    SelectedDirectoriesFiles = varargin{2};
else
    SelectedDirectoriesFiles = '';
end

if length(varargin) >= 1
    Type = varargin{1};
else
    Type = 'img';
end

if strcmp(Type, 'dir')
    set(handles.DirectoriesFilesText, 'String', 'Directories:');
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Directories...');
elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
    set(handles.DirectoriesFilesText, 'String', 'Images:');
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Images...');
elseif strcmp(Type, 'file')
    set(handles.DirectoriesFilesText, 'String', 'Files:');
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Files...');
end

% if strcmp(Type, 'dir') & ~isempty(DirPreviousDir) & exist(DirPreviousDir, 'dir')
%     CurrentDir = DirPreviousDir;
% elseif strcmp(Type, 'img') & ~isempty(ImgPreviousDir) & exist(ImgPreviousDir, 'dir')
%     CurrentDir = ImgPreviousDir;
% elseif strcmp(Type, 'imgAll') & ~isempty(ImgAllPreviousDir) & exist(ImgAllPreviousDir, 'dir')
%     CurrentDir = ImgAllPreviousDir;
% elseif strcmp(Type, 'file') & ~isempty(FilePreviousDir) & exist(FilePreviousDir, 'dir')
%     CurrentDir = FilePreviousDir;
% else
CurrentDir = pwd;
% end
set( handles.CurrentDirEdit, 'String', CurrentDir );
% Set previous dir pop-up menu
if ~isempty(PreviousDirCell)
    for i = 1:length(PreviousDirCell)
        if strcmp(PreviousDirCell{i}, CurrentDir)
            break;
        end
    end
    if i >= length(PreviousDirCell) & ~strcmp(PreviousDirCell{i}, CurrentDir)
        % Add the new path to the end
        PreviousDirCell{end + 1} = CurrentDir;
    else
        % Move the i-th path user selects to the end
        TmpPath = PreviousDirCell{i};
        for j = i + 1:length(PreviousDirCell)
            PreviousDirCell{j - 1} = PreviousDirCell{j};
        end
        PreviousDirCell{end} = TmpPath;
    end
else
    PreviousDirCell{1} = CurrentDir;
end
if length(PreviousDirCell) > 20
    tmp = PreviousDirCell;
    PreviousDirCell = '';
    j = 0;
    for i = (length(tmp) - 19):length(tmp)
        j = j + 1;
        PreviousDirCell{j} = tmp{i};
    end
end
% Convert the PreviousDirCell, the user select most recently should
% be upward
PreviousDirCellDisplay = '';
j = 0;
for i = length(PreviousDirCell):-1:1
    j = j + 1;
    PreviousDirCellDisplay{j} = PreviousDirCell{i};
end
set(handles.PreviouosDirMenu, 'String', PreviousDirCellDisplay);
%
DirFileList = dir(CurrentDir);
DirFileList = {DirFileList.name};
j = 0;
DirList = '';
for i = 1:length(DirFileList)
    if strcmp(DirFileList{i}, '.')
        continue;
    end
    if exist([CurrentDir filesep DirFileList{i}], 'dir')
        j = j + 1;
        DirList{j} = DirFileList{i};
    end
end
if isempty(DirFileList)
    DirList = {'..'};
end
set(handles.FolderListbox, 'Value', 1);
set(handles.FolderListbox, 'String', DirList);
if strcmp(Type, 'dir')
    DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep]);
    for i = 1:length(DirectoriesFiles)
        DirectoriesFiles{i} = DirectoriesFiles{i};
        [a,b,c] = fileparts(DirectoriesFiles{i});
        DirectoriesFiles{i} = [b c]; 
    end
    set(handles.DirectoriesFilesListbox, 'Value', 1);
    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
    if strcmp(Type, 'img')
        NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
        NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
        NII1  = g_ls([CurrentDir filesep '*.nii']);
        NII2 = g_ls([CurrentDir filesep '*.NII']);
        DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2];
    elseif strcmp(Type, 'imgAll')
        NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
        NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
        NII1  = g_ls([CurrentDir filesep '*.nii']);
        NII2 = g_ls([CurrentDir filesep '*.NII']);
        IMG1 = g_ls([CurrentDir filesep '*.img']);
        IMG2 = g_ls([CurrentDir filesep '*.IMG']);
        DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
    end
    for i = 1:length(DirectoriesFiles)
        [a,b,c] = fileparts(DirectoriesFiles{i});
        DirectoriesFiles{i} = [b c];
    end
    if ~isempty(DirectoriesFiles)
        set(handles.DirectoriesFilesListbox, 'Value', 1);
        set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
    else
        set(handles.DirectoriesFilesListbox, 'Value', 1);
        set(handles.DirectoriesFilesListbox, 'String', '');
    end
elseif strcmp(Type, 'file')
    FileList = g_ls([CurrentDir filesep '*']);
    DirectoriesFiles = '';
    j = 0;
    for i = 1:length(FileList)
        if ~exist(FileList{i}, 'dir')
            j = j + 1;
            [a,b,c] = fileparts(FileList{i});
            DirectoriesFiles{j} = [b c];
        end
    end
    set(handles.DirectoriesFilesListbox, 'Value', 1);
    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
end

if strcmp(Type,'dir') %& ~isempty(DirSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    %set(handles.SelectedDirectoriesFilesListbox, 'String', DirSelectedDirectoriesFiles);
    %SelectedDirectoriesFiles = DirSelectedDirectoriesFiles;
    set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    DirectoriesQuantity = length(SelectedDirectoriesFiles);
    if ~isempty(SelectedDirectoriesFiles)
        if DirectoriesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 directory.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected ' num2str(DirectoriesQuantity) ' directories.']);
        end
    end
end
if strcmp(Type,'img') %& ~isempty(ImgSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    %set(handles.SelectedDirectoriesFilesListbox, 'String', ImgSelectedDirectoriesFiles);
    %SelectedDirectoriesFiles = ImgSelectedDirectoriesFiles;
    set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    ImagesQuantity = length(SelectedDirectoriesFiles);
    if ~isempty(SelectedDirectoriesFiles)
        if ImagesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 image.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected '  num2str(ImagesQuantity) ' images.']);
        end
    end
end
if strcmp(Type, 'imgAll') %& ~isempty(ImgAllSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    %set(handles.SelectedDirectoriesFilesListbox, 'String', ImgAllSelectedDirectoriesFiles);
    %SelectedDirectoriesFiles = ImgAllSelectedDirectoriesFiles;
    set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    ImagesQuantity = length(SelectedDirectoriesFiles);
    if ~isempty(SelectedDirectoriesFiles)
        if ImagesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 image.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected '  num2str(ImagesQuantity) ' images.']);
        end
    end
end
if strcmp(Type,'file') %& ~isempty(FileSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    %set(handles.SelectedDirectoriesFilesListbox, 'String', FileSelectedDirectoriesFiles);
    %SelectedDirectoriesFiles = FileSelectedDirectoriesFiles;
    set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    FilesQuantity = length(SelectedDirectoriesFiles);
    if ~isempty(SelectedDirectoriesFiles)
        if FilesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 files.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected ' num2str(FilesQuantity) ' files.']);
        end
    end
end

set( handles.WildCardsCheck, 'Value', 0.0);

guidata(hObject, handles);

% UIWAIT makes PANDA_Select wait for user response (see UIRESUME)
% uiwait(handles.PANDASelectFigure);
uiwait(handles.PANDASelectFigure);


% --- Outputs from this function are returned to the command line.
function varargout = PANDA_Select_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global CurrentDir;
global DirPreviousDir;
global ImgPreviousDir;
global ImgAllPreviousDir;
global FilePreviousDir;
global SelectedDirectoriesFiles;
% global DirSelectedDirectoriesFiles;
% global ImgSelectedDirectoriesFiles;
% global ImgAllSelectedDirectoriesFiles;
% global FileSelectedDirectoriesFiles;
global Type;
global Done;

if strcmp(Type, 'dir')
    DirPreviousDir = CurrentDir;
%     DirSelectedDirectoriesFiles = SelectedDirectoriesFiles;
elseif strcmp(Type, 'img') 
    ImgPreviousDir = CurrentDir;
%     ImgSelectedDirectoriesFiles = SelectedDirectoriesFiles;
elseif strcmp(Type, 'imgAll')
    ImgAllPreviousDir = CurrentDir;
%     ImgAllSelectedDirectoriesFiles = SelectedDirectoriesFiles;
elseif strcmp(Type, 'file')
    FilePreviousDir = CurrentDir;
%     FileSelectedDirectoriesFiles = SelectedDirectoriesFiles;
end

try
    varargout{1} = handles.output;
    SelectedDirectoriesFiles = reshape(SelectedDirectoriesFiles, length(SelectedDirectoriesFiles), 1);
    if Done == 1
        varargout{2} = SelectedDirectoriesFiles;
        varargout{3} = 1;
    else
        varargout{2} = '';
        varargout{3} = 0;
    end
    clear global SelectedDirectoriesFiles;
    delete(hObject);
catch
    varargout{1} = '';
    varargout{2} = '';
    none = 1;
end


function CurrentDirEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentDirEdit as text
%        str2double(get(hObject,'String')) returns contents of CurrentDirEdit as a double
global CurrentDir;
global Type;
global PreviousDir;
global PreviousDirCell;
global SelectedDirectoriesFiles;
if isempty(strfind(CurrentDir, '*'))
    PreviousDir = CurrentDir;
end
CurrentDir = get(hObject, 'String');

set( hObject, 'UserData', '' );

if isempty(strfind(CurrentDir, '*'))
    if get(handles.WildCardsCheck, 'Value')
        set(handles.WildCardsCheck, 'Value', 0);
        set(handles.SubfoldersText, 'Enable', 'on');
        set(handles.FolderListbox, 'Enable', 'on');
        set(handles.DirectoriesFilesText, 'Enable', 'on');
        set(handles.DirectoriesFilesListbox, 'Enable', 'on');
    end
    %
    if exist(CurrentDir, 'dir')
        % Set previous dir pop-up menu
        if ~isempty(PreviousDirCell)
            for i = 1:length(PreviousDirCell)
                if strcmp(PreviousDirCell{i}, CurrentDir)
                    break;
                end
            end
            if i >= length(PreviousDirCell) & ~strcmp(PreviousDirCell{i}, CurrentDir)
                % Add the new path to the end
                PreviousDirCell{end + 1} = CurrentDir;
            else
                % Move the i-th path user selects to the end
                TmpPath = PreviousDirCell{i};
                for j = i + 1:length(PreviousDirCell)
                    PreviousDirCell{j - 1} = PreviousDirCell{j};
                end
                PreviousDirCell{end} = TmpPath;
            end
        else
            PreviousDirCell{1} = CurrentDir;
        end
        if length(PreviousDirCell) > 20
            tmp = PreviousDirCell;
            PreviousDirCell = '';
            j = 0;
            for i = (length(tmp) - 19):length(tmp)
                j = j + 1;
                PreviousDirCell{j} = tmp{i};
            end
        end
        % Convert the PreviousDirCell, the user select most recently should
        % be upward
        PreviousDirCellDisplay = '';
        j = 0;
        for i = length(PreviousDirCell):-1:1
            j = j + 1;
            PreviousDirCellDisplay{j} = PreviousDirCell{i};
        end
        set(handles.PreviouosDirMenu, 'String', PreviousDirCellDisplay);
        
        DirFileList = dir(CurrentDir);
        DirFileList = {DirFileList.name};
        j = 0;
        DirList = '';
        for i = 1:length(DirFileList)
            if strcmp(DirFileList{i}, '.')
                continue;
            end
            if exist([CurrentDir filesep DirFileList{i}], 'dir')
                j = j + 1;
                DirList{j} = DirFileList{i};
            end
        end
        if isempty(DirFileList)
            DirList = {'..'};
        end
        set(handles.FolderListbox, 'Value', 1);
        set(handles.FolderListbox, 'String', DirList);
        if strcmp(Type, 'dir')
            DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep]);
            for i = 1:length(DirectoriesFiles)
                DirectoriesFiles{i} = DirectoriesFiles{i};
                [a,b,c] = fileparts(DirectoriesFiles{i});
                DirectoriesFiles{i} = [b c];
            end
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
        elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
            if strcmp(Type, 'img')
                NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                NII1  = g_ls([CurrentDir filesep '*.nii']);
                NII2 = g_ls([CurrentDir filesep '*.NII']);
                DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2];
            elseif strcmp(Type, 'imgAll')
                NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                NII1  = g_ls([CurrentDir filesep '*.nii']);
                NII2 = g_ls([CurrentDir filesep '*.NII']);
                IMG1 = g_ls([CurrentDir filesep '*.img']);
                IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
            end
            for i = 1:length(DirectoriesFiles)
                [a,b,c] = fileparts(DirectoriesFiles{i});
                DirectoriesFiles{i} = [b c];
            end
            if ~isempty(DirectoriesFiles)
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
            else
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', '');
            end
        elseif strcmp(Type, 'file')
            FileList = g_ls([CurrentDir filesep '*']);
            DirectoriesFiles = '';
            j = 0;
            for i = 1:length(FileList)
                if ~exist(FileList{i}, 'dir')
                    j = j + 1;
                    [a,b,c] = fileparts(FileList{i});
                    DirectoriesFiles{j} = [b c];
                end
            end
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
        end
    else
        msgbox('The path is not exist !');
        CurrentDir = PreviousDir;
        set( handles.CurrentDirEdit, 'String', PreviousDir);
    end
else
    %
    j = 0;
    DirectoriesFiles = g_ls(CurrentDir);
    OldDirectoriesFiles = DirectoriesFiles;
    clear DirectoriesFiles;
    DirectoriesFiles = '';
    if strcmp(Type, 'dir')
        for i = 1:length(OldDirectoriesFiles)
            if exist(OldDirectoriesFiles{i}, 'dir')
                j = j + 1;
                DirectoriesFiles{j} = OldDirectoriesFiles{i};
            end
        end
    elseif strcmp(Type, 'img')
        for i = 1:length(OldDirectoriesFiles)
            if exist(OldDirectoriesFiles{i}, 'file') & ~exist(OldDirectoriesFiles{i}, 'dir') ...
                    & (strcmp(OldDirectoriesFiles{i}(end - 3:end), '.nii') | strcmp(OldDirectoriesFiles{i}(end - 6:end), '.nii.gz'))
                j = j + 1;
                DirectoriesFiles{j} = OldDirectoriesFiles{i};
            end
        end
    elseif strcmp(Type, 'imgAll')
        for i = 1:length(OldDirectoriesFiles)
            if exist(OldDirectoriesFiles{i}, 'file') & ~exist(OldDirectoriesFiles{i}, 'dir') ...
                    & (strcmp(OldDirectoriesFiles{i}(end - 3:end), '.nii') | strcmp(OldDirectoriesFiles{i}(end - 6:end), '.nii.gz') ...
                    | strcmp(OldDirectoriesFiles{i}(end - 3:end), '.img'))
                j = j + 1;
                DirectoriesFiles{j} = OldDirectoriesFiles{i};
            end
        end
    elseif strcmp(Type, 'file')
        for i = 1:length(OldDirectoriesFiles)
            if exist(OldDirectoriesFiles{i}, 'file') & ~exist(OldDirectoriesFiles{i}, 'dir')
                j = j + 1;
                DirectoriesFiles{j} = OldDirectoriesFiles{i};
            end
        end
    end
    if get(handles.WildCardsCheck, 'Value')
        SelectedDirectoriesFiles = reshape(SelectedDirectoriesFiles, length(SelectedDirectoriesFiles), 1);
        DirectoriesFiles = reshape(DirectoriesFiles, length(DirectoriesFiles), 1);
        SelectedDirectoriesFiles = [SelectedDirectoriesFiles; DirectoriesFiles];
        set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
        set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);

        SelectedQuantity = length(SelectedDirectoriesFiles);
        SelectedQuantityString = num2str(SelectedQuantity);
        SelectedString = '';
        if strcmp(Type,'dir')
            if SelectedQuantity <= 1
                SelectedString = ['Selected ' SelectedQuantityString ' directory. '];
            else
                SelectedString = ['Selected ' SelectedQuantityString ' directories. '];
            end
        end
        if strcmp(Type,'img') | strcmp(Type, 'imgAll')
            if SelectedQuantity <= 1
                SelectedString = ['Selected ' SelectedQuantityString ' image. '];
            else
                SelectedString = ['Selected ' SelectedQuantityString ' images. '];
            end
        end
        if strcmp(Type,'file')
            if SelectedQuantity <= 1
                SelectedString = ['Selected ' SelectedQuantityString ' file. '];
            else
                SelectedString = ['Selected ' SelectedQuantityString ' files. '];
            end
        end
        set(handles.SelectedDirectoriesFilesText, 'String', SelectedString);
    else
        set( hObject, 'UserData', DirectoriesFiles );
    end
end


% --- Executes during object creation, after setting all properties.
function CurrentDirEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on selection change in FolderListbox.
function FolderListbox_Callback(hObject, eventdata, handles)
% hObject    handle to FolderListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FolderListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FolderListbox
global CurrentDir;
global Type;
global PreviousDir;
global PreviousDirCell;
FolderList = get(hObject, 'String');
if ~isempty(FolderList)
    SelectedID = get(hObject, 'Value');
    if CurrentDir(end) == '/' & length(CurrentDir) > 1
        CurrentDir = CurrentDir(1:end - 1);
    end
    if ~isempty(strfind(CurrentDir, '*'))
        CurrentDir = PreviousDir;
    end
    if SelectedID <= length(FolderList) & strcmp(FolderList{SelectedID}, '..')
        % Back to upper folder
        if length(CurrentDir) > 1
            CurrentDir = CurrentDir(1:end - 1);
            [CurrentDir, b, c] = fileparts(CurrentDir);
            set(handles.CurrentDirEdit, 'String', CurrentDir);
            % Set previous dir pop-up menu
            if ~isempty(PreviousDirCell)
                for i = 1:length(PreviousDirCell)
                    if strcmp(PreviousDirCell{i}, CurrentDir)
                        break;
                    end
                end
                if i >= length(PreviousDirCell) & ~strcmp(PreviousDirCell{i}, CurrentDir)
                    % Add the new path to the end
                    PreviousDirCell{end + 1} = CurrentDir;
                else
                    % Move the i-th path user selects to the end
                    TmpPath = PreviousDirCell{i};
                    for j = i + 1:length(PreviousDirCell)
                        PreviousDirCell{j - 1} = PreviousDirCell{j};
                    end
                    PreviousDirCell{end} = TmpPath;
                end
            else
                PreviousDirCell{1} = CurrentDir;
            end
            if length(PreviousDirCell) > 20
                tmp = PreviousDirCell;
                PreviousDirCell = '';
                j = 0;
                for i = (length(tmp) - 19):length(tmp)
                    j = j + 1;
                    PreviousDirCell{j} = tmp{i};
                end
            end
            % Convert the PreviousDirCell, the user select most recently should
            % be upward
            PreviousDirCellDisplay = '';
            j = 0;
            for i = length(PreviousDirCell):-1:1
                j = j + 1;
                PreviousDirCellDisplay{j} = PreviousDirCell{i};
            end
            set(handles.PreviouosDirMenu, 'String', PreviousDirCellDisplay);
            %
            DirFileList = dir(CurrentDir);
            DirFileList = {DirFileList.name};
            j = 0;
            DirList = '';
            for i = 1:length(DirFileList)
                if strcmp(DirFileList{i}, '.')
                    continue;
                end
                if exist([CurrentDir filesep DirFileList{i}], 'dir')
                    j = j + 1;
                    DirList{j} = DirFileList{i};
                end
            end
            if isempty(DirFileList)
                DirList = {'..'};
            end
            set(handles.FolderListbox, 'Value', 1);
            set(handles.FolderListbox, 'String', DirList);
%             if ~get(handles.WildCardsCheck, 'Value')
                if strcmp(Type, 'dir')
                    DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep]);
                    for i = 1:length(DirectoriesFiles)
                        DirectoriesFiles{i} = DirectoriesFiles{i};
                        [a,b,c] = fileparts(DirectoriesFiles{i});
                        DirectoriesFiles{i} = [b c]; 
                    end
                    set(handles.DirectoriesFilesListbox, 'Value', 1);
                    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
                elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
                    if strcmp(Type, 'img')
                        NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                        NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                        NII1  = g_ls([CurrentDir filesep '*.nii']);
                        NII2 = g_ls([CurrentDir filesep '*.NII']);
                        DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2];
                    elseif strcmp(Type, 'imgAll')
                        NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                        NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                        NII1  = g_ls([CurrentDir filesep '*.nii']);
                        NII2 = g_ls([CurrentDir filesep '*.NII']);
                        IMG1 = g_ls([CurrentDir filesep '*.img']);
                        IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                        DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
                    end
                    for i = 1:length(DirectoriesFiles)
                        [a,b,c] = fileparts(DirectoriesFiles{i});
                        DirectoriesFiles{i} = [b c];
                    end
                    if ~isempty(DirectoriesFiles)
                        set(handles.DirectoriesFilesListbox, 'Value', 1);
                        set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
                    else
                        set(handles.DirectoriesFilesListbox, 'Value', 1);
                        set(handles.DirectoriesFilesListbox, 'String', '');
                    end
                elseif strcmp(Type, 'file')
                    FileList = g_ls([CurrentDir filesep '*']);
                    DirectoriesFiles = '';
                    j = 0;
                    for i = 1:length(FileList)
                        if ~exist(FileList{i}, 'dir')
                            j = j + 1;
                            [a,b,c] = fileparts(FileList{i});
                            DirectoriesFiles{j} = [b c];
                        end
                    end
                    set(handles.DirectoriesFilesListbox, 'Value', 1);
                    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
                end
%             end
        end
    elseif SelectedID <= length(FolderList) 
        % go to the folder user clicks
        if ~strcmp(CurrentDir, '/')
            CurrentDir = [CurrentDir filesep FolderList{SelectedID}];
        else
            CurrentDir = [CurrentDir FolderList{SelectedID}];
        end
        set(handles.CurrentDirEdit, 'String', CurrentDir);
        % Set previous dir pop-up menu
        if ~isempty(PreviousDirCell)
            for i = 1:length(PreviousDirCell)
                if strcmp(PreviousDirCell{i}, CurrentDir)
                    break;
                end
            end
            if i >= length(PreviousDirCell) & ~strcmp(PreviousDirCell{i}, CurrentDir)
                % Add the new path to the end
                PreviousDirCell{end + 1} = CurrentDir;
            else
                % Move the i-th path user selects to the end
                TmpPath = PreviousDirCell{i};
                for j = i + 1:length(PreviousDirCell)
                    PreviousDirCell{j - 1} = PreviousDirCell{j};
                end
                PreviousDirCell{end} = TmpPath;
            end
        else
            PreviousDirCell{1} = CurrentDir;
        end
        if length(PreviousDirCell) > 20
            tmp = PreviousDirCell;
            PreviousDirCell = '';
            j = 0;
            for i = (length(tmp) - 19):length(tmp)
                j = j + 1;
                PreviousDirCell{j} = tmp{i};
            end
        end
        % Convert the PreviousDirCell, the user select most recently should
        % be upward
        PreviousDirCellDisplay = '';
        j = 0;
        for i = length(PreviousDirCell):-1:1
            j = j + 1;
            PreviousDirCellDisplay{j} = PreviousDirCell{i};
        end
        set(handles.PreviouosDirMenu, 'String', PreviousDirCellDisplay);
        %
        DirFileList = dir(CurrentDir);
        DirFileList = {DirFileList.name};
        j = 0;
        DirList = '';
        for i = 1:length(DirFileList)
            if strcmp(DirFileList{i}, '.')
                continue;
            end
            if exist([CurrentDir filesep DirFileList{i}], 'dir')
                j = j + 1;
                DirList{j} = DirFileList{i};
            end
        end
        if isempty(DirFileList)
            DirList = {'..'};
        end
        set(handles.FolderListbox, 'Value', 1);
        set(handles.FolderListbox, 'String', DirList);
%         if ~get(handles.WildCardsCheck, 'Value')
            if strcmp(Type, 'dir')
                DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep]);
                for i = 1:length(DirectoriesFiles)
                    DirectoriesFiles{i} = DirectoriesFiles{i};
                    [a,b,c] = fileparts(DirectoriesFiles{i});
                    DirectoriesFiles{i} = [b c]; 
                end
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
            elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
                if strcmp(Type, 'img')
                    NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                    NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                    NII1  = g_ls([CurrentDir filesep '*.nii']);
                    NII2 = g_ls([CurrentDir filesep '*.NII']);
                    DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2];
                elseif strcmp(Type, 'imgAll')
                    NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                    NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                    NII1  = g_ls([CurrentDir filesep '*.nii']);
                    NII2 = g_ls([CurrentDir filesep '*.NII']);
                    IMG1 = g_ls([CurrentDir filesep '*.img']);
                    IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                    DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
                end
                for i = 1:length(DirectoriesFiles)
                    [a,b,c] = fileparts(DirectoriesFiles{i});
                    DirectoriesFiles{i} = [b c];
                end
                if ~isempty(DirectoriesFiles)
                    set(handles.DirectoriesFilesListbox, 'Value', 1);
                    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
                else
                    set(handles.DirectoriesFilesListbox, 'Value', 1);
                    set(handles.DirectoriesFilesListbox, 'String', '');
                end
            elseif strcmp(Type, 'file')
                FileList = g_ls([CurrentDir filesep '*']);
                DirectoriesFiles = '';
                j = 0;
                for i = 1:length(FileList)
                    if ~exist(FileList{i}, 'dir')
                        j = j + 1;
                        [a,b,c] = fileparts(FileList{i});
                        DirectoriesFiles{j} = [b c];
                    end
                end
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
            end
%         end
    end
end


% --- Executes during object creation, after setting all properties.
function FolderListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FolderListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on selection change in DirectoriesFilesListbox.
function DirectoriesFilesListbox_Callback(hObject, eventdata, handles)
% hObject    handle to DirectoriesFilesListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DirectoriesFilesListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DirectoriesFilesListbox
% global DirectoriesFiles;
global SelectedDirectoriesFiles;
global CurrentDir;
global Type;
DirectoriesFiles = get(hObject, 'String');
if ~isempty(DirectoriesFiles)
    SelectedID = get(hObject, 'Value');
    for i = 1:length(SelectedID)
        if ~strcmp(DirectoriesFiles{SelectedID(i)}, '')
            % Add the selected one in Selected Directories Listbox
            SelectedDirectoriesFiles{end + 1} = [CurrentDir filesep DirectoriesFiles{SelectedID(i)}];
        end
    end
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    
    if strcmp(Type,'dir') & ~isempty(SelectedDirectoriesFiles)
        DirectoriesQuantity = length(SelectedDirectoriesFiles);
        if DirectoriesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 directory.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected ' num2str(DirectoriesQuantity) ' directories.']);
        end
    end
    if (strcmp(Type,'img') | strcmp(Type, 'imgAll')) & ~isempty(SelectedDirectoriesFiles)
        ImagesQuantity = length(SelectedDirectoriesFiles);
        if ImagesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 image.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected '  num2str(ImagesQuantity) ' images.']);
        end
    end
    if strcmp(Type,'file') & ~isempty(SelectedDirectoriesFiles)
        FilesQuantity = length(SelectedDirectoriesFiles);
        if FilesQuantity == 1
            set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 files.');
        else
            set(handles.SelectedDirectoriesFilesText, 'String', ['Selected ' num2str(FilesQuantity) ' files.']);
        end
    end
    
    % Delete the selected ones in Directories Listbox
    OldDirectoriesFiles = DirectoriesFiles;
    DirectoriesFiles = '';
    j = 0;
    for m = 1:length(OldDirectoriesFiles)
        for i = 1:length(SelectedID)
            if m == SelectedID(i)
                break; 
            end
        end
        if i >= length(SelectedID) & m ~= SelectedID(i)
            j = j + 1;
            DirectoriesFiles{j} = OldDirectoriesFiles{m};
        end
    end
    set(handles.DirectoriesFilesListbox, 'Value', 1);
    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
end


% --- Executes during object creation, after setting all properties.
function DirectoriesFilesListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DirectoriesFilesListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on selection change in SelectedDirectoriesFilesListbox.
function SelectedDirectoriesFilesListbox_Callback(hObject, eventdata, handles)
% hObject    handle to SelectedDirectoriesFilesListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectedDirectoriesFilesListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectedDirectoriesFilesListbox
global SelectedDirectoriesFiles;
global Type;
SelectedDirectoriesFiles = get(hObject, 'String');
if ~isempty(SelectedDirectoriesFiles)
    if strcmp(SelectedDirectoriesFiles{end}, '')
        SelectedDirectoriesFiles = SelectedDirectoriesFiles(1:end - 1);
    end
    if ~isempty(SelectedDirectoriesFiles)
        SelectedID = get(hObject, 'Value');
        % Delete the selected one in Selected Directories Listbox
        OldSelectedDirectoriesFiles = SelectedDirectoriesFiles;
        SelectedDirectoriesFiles = '';
        j = 0;
        for m = 1:length(OldSelectedDirectoriesFiles)
            for i = 1:length(SelectedID)
                if m == SelectedID(i)
                    break;
                end
            end
            if i >= length(SelectedID) & m ~= SelectedID(i)
                j = j + 1;
                SelectedDirectoriesFiles{j} = OldSelectedDirectoriesFiles{m};
            end
        end
        set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
        set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
        
        DeleteQuantity = length(SelectedID);
        RemainQuantity = length(SelectedDirectoriesFiles);
        DeleteQuantityString = num2str(DeleteQuantity);
        RemainQuantityString = num2str(RemainQuantity);
        DeleteString = '';
        RemainString = '';
        if strcmp(Type,'dir') & ~isempty(SelectedID)
            if DeleteQuantity <= 1
                DeleteString = ['Unselected ' DeleteQuantityString ' directory. '];
            else
                DeleteString = ['Unselected ' DeleteQuantityString ' directories. '];
            end
            if RemainQuantity <= 1
                RemainString = [RemainQuantityString ' directory remain.'];
            else
                RemainString = [RemainQuantityString ' directories remain.'];
            end
        end
        if (strcmp(Type,'img') | strcmp(Type, 'imgAll')) & ~isempty(SelectedID)
            if DeleteQuantity <= 1
                DeleteString = ['Unselected ' DeleteQuantityString ' image. '];
            else
                DeleteString = ['Unselected ' DeleteQuantityString ' images. '];
            end
            if RemainQuantity <= 1
                RemainString = [RemainQuantityString ' image remain.'];
            else
                RemainString = [RemainQuantityString ' images remain.'];
            end
        end
        if strcmp(Type,'file') & ~isempty(SelectedID)
            if DeleteQuantity <= 1
                DeleteString = ['Unselected ' DeleteQuantityString ' file. '];
            else
                DeleteString = ['Unselected ' DeleteQuantityString ' files. '];
            end
            if RemainQuantity <= 1
                RemainString = [RemainQuantityString ' file remain.'];
            else
                RemainString = [RemainQuantityString ' files remain.'];
            end
        end
        set(handles.SelectedDirectoriesFilesText, 'String', [DeleteString RemainString]);
    end
end


% --- Executes during object creation, after setting all properties.
function SelectedDirectoriesFilesListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectedDirectoriesFilesListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in DoneButton.
function DoneButton_Callback(hObject, eventdata, handles)
% hObject    handle to DoneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Done;
global SelectedDirectoriesFiles;
global PreviousDirCell;
clear global PreviousDirCell;
Done = 1;
SelectedDirectoriesFiles = get(handles.SelectedDirectoriesFilesListbox, 'String');
uiresume(handles.PANDASelectFigure);


% --- Executes when user attempts to close PANDASelectFigure.
function PANDASelectFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PANDASelectFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global PreviousDirCell;
clear global PreviousDirCell;
uiresume(handles.PANDASelectFigure);


% --- Executes on button press in WildCardsCheck.
function WildCardsCheck_Callback(hObject, eventdata, handles)
% hObject    handle to WildCardsCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WildCardsCheck
global CurrentDir;
global Type;
global BeforeWildCardsCurrentDir;
global BeforeWildCardsType;
% global BeforeWildCardsSelectedDirectoriesFiles;
global SelectedDirectoriesFiles;

DirList = '';
if get(hObject, 'Value')
    BeforeWildCardsCurrentDir = CurrentDir;
    BeforeWildCardsType = Type;
%     BeforeWildCardsSelectedDirectoriesFiles = SelectedDirectoriesFiles; 
    set(handles.DirectoriesFilesText, 'Enable', 'off');
%     set(handles.SubfoldersText, 'Enable', 'off');
%     set(handles.FolderListbox, 'Enable', 'off');
%     set(handles.DirectoriesFilesListbox, 'Value', 1);
%     set(handles.DirectoriesFilesListbox, 'String', '');
    set(handles.DirectoriesFilesListbox, 'Enable', 'off');
%     set(handles.SelectedDirectoriesFilesListbox, 'String', '');
    DirectoriesFiles = get( handles.CurrentDirEdit, 'UserData' );
    set( handles.CurrentDirEdit, 'UserData', '' );
    % Get the path of the currentdir, judge whether it is equal to the
    % paths stored in the 'UserData'
    
    if ~isempty(DirectoriesFiles)
        SelectedDirectoriesFiles = reshape(SelectedDirectoriesFiles, length(SelectedDirectoriesFiles), 1);
        DirectoriesFiles = reshape(DirectoriesFiles, length(DirectoriesFiles), 1);
        SelectedDirectoriesFiles = [SelectedDirectoriesFiles; DirectoriesFiles];
        set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
        set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);

        SelectedQuantity = length(SelectedDirectoriesFiles);
        SelectedQuantityString = num2str(SelectedQuantity);
        SelectedString = '';
        if strcmp(Type,'dir')
            if SelectedQuantity <= 1
                SelectedString = ['Selected ' SelectedQuantityString ' directory. '];
            else
                SelectedString = ['Selected ' SelectedQuantityString ' directories. '];
            end
        end
        if strcmp(Type,'img') | strcmp(Type, 'imgAll')
            if SelectedQuantity <= 1
                SelectedString = ['Selected ' SelectedQuantityString ' image. '];
            else
                SelectedString = ['Selected ' SelectedQuantityString ' images. '];
            end
        end
        if strcmp(Type,'file')
            if SelectedQuantity <= 1
                SelectedString = ['Selected ' SelectedQuantityString ' file. '];
            else
                SelectedString = ['Selected ' SelectedQuantityString ' files. '];
            end
        end
        set(handles.SelectedDirectoriesFilesText, 'String', SelectedString);
    end
else
    set(handles.SubfoldersText, 'Enable', 'on');
    set(handles.FolderListbox, 'Enable', 'on');
    set(handles.DirectoriesFilesText, 'Enable', 'on');
    set(handles.DirectoriesFilesListbox, 'Enable', 'on');
    CurrentDir = pwd;
    Type = BeforeWildCardsType;
    set(handles.CurrentDirEdit, 'String', CurrentDir);
    DirFileList = dir(CurrentDir);
    DirFileList = {DirFileList.name};
    j = 0;
    for i = 1:length(DirFileList)
        if strcmp(DirFileList{i}, '.')
            continue;
        end
        if exist([CurrentDir filesep DirFileList{i}], 'dir')
            j = j + 1;
            DirList{j} = DirFileList{i};
        end
    end
    set(handles.FolderListbox, 'Value', 1);
    set(handles.FolderListbox, 'String', DirList);
    if strcmp(Type, 'dir')
        DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep]);
        for i = 1:length(DirectoriesFiles)
            DirectoriesFiles{i} = DirectoriesFiles{i};
            [a,b,c] = fileparts(DirectoriesFiles{i});
            DirectoriesFiles{i} = [b c]; 
        end
        set(handles.DirectoriesFilesListbox, 'Value', 1);
        set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
    elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
        if strcmp(Type, 'img')
            NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
            NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
            NII1  = g_ls([CurrentDir filesep '*.nii']);
            NII2 = g_ls([CurrentDir filesep '*.NII']);
            DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2];
        elseif strcmp(Type, 'imgAll')
            NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
            NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
            NII1  = g_ls([CurrentDir filesep '*.nii']);
            NII2 = g_ls([CurrentDir filesep '*.NII']);
            IMG1 = g_ls([CurrentDir filesep '*.img']);
            IMG2 = g_ls([CurrentDir filesep '*.IMG']);
            DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
        end
        for i = 1:length(DirectoriesFiles)
            [a,b,c] = fileparts(DirectoriesFiles{i});
            DirectoriesFiles{i} = [b c];
        end
        if ~isempty(DirectoriesFiles)
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
        else
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', '');
        end
    elseif strcmp(Type, 'file')
        FileList = g_ls([CurrentDir filesep '*']);
        DirectoriesFiles = '';
        j = 0;
        for i = 1:length(FileList)
            if ~exist(FileList{i}, 'dir')
                j = j + 1;
                [a,b,c] = fileparts(FileList{i});
                DirectoriesFiles{j} = [b c];
            end
        end
        set(handles.DirectoriesFilesListbox, 'Value', 1);
        set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
    end
%     SelectedDirectoriesFiles = BeforeWildCardsSelectedDirectoriesFiles;
%     set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
%     if ~isempty(SelectedDirectoriesFiles)
%         set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
%     else
%         set(handles.SelectedDirectoriesFilesListbox, 'String', '');
%     end
end


% --- Executes on selection change in PreviouosDirMenu.
function PreviouosDirMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PreviouosDirMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PreviouosDirMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PreviouosDirMenu
global CurrentDir;
global PreviousDir;
global Type;
tmp = get(handles.CurrentDirEdit, 'String');
if isempty(strfind(tmp, '*'))
    PreviousDir = tmp;
end
PreviousDirCell = get(hObject, 'String');
sel = get(hObject, 'Value');
% Update the previous dir menu, move the selected one to the top
TmpPath = PreviousDirCell{sel};
for i = sel - 1 : -1 : 1
    PreviousDirCell{i + 1} = PreviousDirCell{i};
end
PreviousDirCell{1} = TmpPath;
set( handles.PreviouosDirMenu, 'String', PreviousDirCell, 'Value', 1);
% Update current directory
CurrentDir = TmpPath;
set(handles.CurrentDirEdit, 'String', CurrentDir);

if exist(CurrentDir, 'dir')
    DirFileList = dir(CurrentDir);
    DirFileList = {DirFileList.name};
    j = 0;
    DirList = '';
    for i = 1:length(DirFileList)
        if strcmp(DirFileList{i}, '.')
            continue;
        end
        if exist([CurrentDir filesep DirFileList{i}], 'dir')
            j = j + 1;
            DirList{j} = DirFileList{i};
        end
    end
    if isempty(DirFileList)
        DirList = {'..'};
    end
    set(handles.FolderListbox, 'Value', 1);
    set(handles.FolderListbox, 'String', DirList);
%     if ~get(handles.WildCardsCheck, 'Value')
        if strcmp(Type, 'dir')
            DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep]);
            for i = 1:length(DirectoriesFiles)
                DirectoriesFiles{i} = DirectoriesFiles{i};
                [a,b,c] = fileparts(DirectoriesFiles{i});
                DirectoriesFiles{i} = [b c];
            end
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
        elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
            if strcmp(Type, 'img')
                NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                NII1  = g_ls([CurrentDir filesep '*.nii']);
                NII2 = g_ls([CurrentDir filesep '*.NII']);
                DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2];
            elseif strcmp(Type, 'imgAll')
                NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                NII1  = g_ls([CurrentDir filesep '*.nii']);
                NII2 = g_ls([CurrentDir filesep '*.NII']);
                IMG1 = g_ls([CurrentDir filesep '*.img']);
                IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
            end
            for i = 1:length(DirectoriesFiles)
                [a,b,c] = fileparts(DirectoriesFiles{i});
                DirectoriesFiles{i} = [b c];
            end
            if ~isempty(DirectoriesFiles)
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
            else
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', '');
            end
        elseif strcmp(Type, 'file')
            FileList = g_ls([CurrentDir filesep '*']);
            DirectoriesFiles = '';
            j = 0;
            for i = 1:length(FileList)
                if ~exist(FileList{i}, 'dir')
                    j = j + 1;
                    [a,b,c] = fileparts(FileList{i});
                    DirectoriesFiles{j} = [b c];
                end
            end
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
        end
%     end
else
    msgbox('The path is not exist !');
    CurrentDir = PreviousDir;
    set( handles.CurrentDirEdit, 'String', PreviousDir);
end


% --- Executes during object creation, after setting all properties.
function PreviouosDirMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreviouosDirMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes when PANDASelectFigure is resized.
function PANDASelectFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PANDASelectFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SelectedDirectoriesFilesText.
function SelectedDirectoriesFilesText_Callback(hObject, eventdata, handles)
% hObject    handle to SelectedDirectoriesFilesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SubfoldersText.
function SubfoldersText_Callback(hObject, eventdata, handles)
% hObject    handle to SubfoldersText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DirectoriesFilesText.
function DirectoriesFilesText_Callback(hObject, eventdata, handles)
% hObject    handle to DirectoriesFilesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ClearAllButton.
function ClearAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SelectedDirectoriesFiles;
global Type;

SelectedDirectoriesFiles = '';
set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
set(handles.SelectedDirectoriesFilesListbox, 'String', '');

if strcmp(Type, 'dir')
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Directories...');
elseif strcmp(Type, 'img') | strcmp(Type, 'imgAll')
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Images...');
elseif strcmp(Type, 'file')
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Files...');
end


% --- Executes on button press in AddPathButton.
function AddPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handlAddPathListes    structure with handles and user data (see GUIDATA)
global Type;
global AddPathList;
global SelectedDirectoriesFiles;
[x AddPathList] = PANDA_AddPath;
if ~isempty(AddPathList)
    [RowsQuantity tmp] = size(AddPathList);
    for i = 1:RowsQuantity
        AddPathCell{i} = AddPathList(i, :);
        SpaceID = find(AddPathCell{i} == ' ');
        AddPathCell{i}(SpaceID) = '';
    end
    AddPathCell = AddPathCell';
    SelectedDirectoriesFiles = [SelectedDirectoriesFiles;AddPathCell];
end
%
SelectedQuantity = length(SelectedDirectoriesFiles);
if strcmp(Type,'dir')
    if SelectedQuantity <= 1
        SelectedString = ['Selected ' num2str(SelectedQuantity) ' directory. '];
    else
        SelectedString = ['Selected ' num2str(SelectedQuantity) ' directories. '];
    end
end
if strcmp(Type,'img') | strcmp(Type, 'imgAll')
    if SelectedQuantity <= 1
        SelectedString = ['Selected ' num2str(SelectedQuantity) ' image. '];
    else
        SelectedString = ['Selected ' num2str(SelectedQuantity) ' images. '];
    end
end
if strcmp(Type,'file')
    if SelectedQuantity <= 1
        SelectedString = ['Selected ' num2str(SelectedQuantity) ' file. '];
    else
        SelectedString = ['Selected ' num2str(SelectedQuantity) ' files. '];
    end
end
set(handles.SelectedDirectoriesFilesText, 'String', SelectedString);
set(handles.DirectoriesFilesListbox, 'Value', 1);
set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);


% --- Executes during object creation, after setting all properties.
function AddPathButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
