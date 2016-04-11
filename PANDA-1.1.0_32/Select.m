function varargout = Select(varargin)
% GUI for selecting files/directories, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Version 1.1.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
% SELECT MATLAB code for Select.fig
%      SELECT, by itself, creates a new SELECT or raises the existing
%      singleton*.
%
%      H = SELECT returns the handle to a new SELECT or the handle to
%      the existing singleton*.
%
%      SELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT.M with the given input arguments.
%
%      SELECT('Property','Value',...) creates a new SELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Select_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Select_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Select

% Last Modified by GUIDE v2.5 03-May-2012 17:24:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Select_OpeningFcn, ...
                   'gui_OutputFcn',  @Select_OutputFcn, ...
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


% --- Executes just before Select is made visible.
function Select_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Select (see VARARGIN)

% Choose default command line output for Select
global Type;
global CurrentDir;
global SelectedDirectoriesFiles;
global DirSelectedDirectoriesFiles;
global ImgSelectedDirectoriesFiles;
global FileSelectedDirectoriesFiles;
global DirPreviousDir;
global ImgPreviousDir;
global FilePreviousDir;
global Done;
global PreviousDirCell;

Done = 0;
handles.output = hObject;

% Update handles structure

if length(varargin) >= 1
    Type = varargin{1};
else
    Type = 'img';
end
if strcmp(Type, 'dir')
    set(handles.DirectoriesFilesText, 'String', 'Directories:');
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Directories...');
elseif strcmp(Type, 'img')
    set(handles.DirectoriesFilesText, 'String', 'Images:');
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Images...');
elseif strcmp(Type, 'file')
    set(handles.DirectoriesFilesText, 'String', 'Files:');
    set(handles.SelectedDirectoriesFilesText, 'String', 'Select Files...');
end

if strcmp(Type, 'dir') & ~isempty(DirPreviousDir) & exist(DirPreviousDir, 'dir')
    CurrentDir = DirPreviousDir;
elseif strcmp(Type, 'img') & ~isempty(ImgPreviousDir) & exist(ImgPreviousDir, 'dir')
    CurrentDir = ImgPreviousDir;
elseif strcmp(Type, 'file') & ~isempty(FilePreviousDir) & exist(FilePreviousDir, 'dir')
    CurrentDir = FilePreviousDir;
else
    CurrentDir = pwd;
end
set( handles.CurrentDirEdit, 'String', CurrentDir );
% Set previous dir pop-up menu
if ~isempty(PreviousDirCell)
    for i = 1:length(PreviousDirCell)
        if strcmp(PreviousDirCell{i}, CurrentDir)
            break;
        end
    end
    if i >= length(PreviousDirCell) & ~strcmp(PreviousDirCell{i}, CurrentDir)
        PreviousDirCell{length(PreviousDirCell) + 1} = CurrentDir;
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
set( handles.PreviouosDirEdit, 'String', PreviousDirCell, 'Value', 1 );
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
    DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep], 'd');
    for i = 1:length(DirectoriesFiles)
        DirectoriesFiles{i} = DirectoriesFiles{i}(1:end - 1);
        [a,b,c] = fileparts(DirectoriesFiles{i});
        DirectoriesFiles{i} = [b c]; 
    end
    set(handles.DirectoriesFilesListbox, 'Value', 1);
    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
elseif strcmp(Type, 'img')
    NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
    NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
    NII1  = g_ls([CurrentDir filesep '*.nii']);
    NII2 = g_ls([CurrentDir filesep '*.NII']);
    IMG1 = g_ls([CurrentDir filesep '*.img']);
    IMG2 = g_ls([CurrentDir filesep '*.IMG']);
    DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
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
    FileList = g_ls([CurrentDir filesep '*'], '-d');
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

if strcmp(Type,'dir') & ~isempty(DirSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    set(handles.SelectedDirectoriesFilesListbox, 'String', DirSelectedDirectoriesFiles);
    SelectedDirectoriesFiles = DirSelectedDirectoriesFiles;
    DirectoriesQuantity = length(SelectedDirectoriesFiles);
    if DirectoriesQuantity == 1
        set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 directory.');
    else
        set(handles.SelectedDirectoriesFilesText, 'String', ['Selected ' num2str(DirectoriesQuantity) ' directories.']);
    end
end
if strcmp(Type,'img') & ~isempty(ImgSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    set(handles.SelectedDirectoriesFilesListbox, 'String', ImgSelectedDirectoriesFiles);
    SelectedDirectoriesFiles = ImgSelectedDirectoriesFiles;
    ImagesQuantity = length(SelectedDirectoriesFiles);
    if ImagesQuantity == 1
        set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 image.');
    else
        set(handles.SelectedDirectoriesFilesText, 'String', ['Selected '  num2str(ImagesQuantity) ' images.']);
    end
end
if strcmp(Type,'file') & ~isempty(FileSelectedDirectoriesFiles)
    set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
    set(handles.SelectedDirectoriesFilesListbox, 'String', FileSelectedDirectoriesFiles);
    SelectedDirectoriesFiles = FileSelectedDirectoriesFiles;
    FilesQuantity = length(SelectedDirectoriesFiles);
    if FilesQuantity == 1
        set(handles.SelectedDirectoriesFilesText, 'String', 'Selected 1 files.');
    else
        set(handles.SelectedDirectoriesFilesText, 'String', ['Selected ' num2str(FilesQuantity) ' files.']);
    end
end

set( handles.WildCardsCheck, 'Value', 0.0);

guidata(hObject, handles);

% UIWAIT makes Select wait for user response (see UIRESUME)
% uiwait(handles.SelectFigure);
uiwait(handles.SelectFigure);


% --- Outputs from this function are returned to the command line.
function varargout = Select_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global CurrentDir;
global DirPreviousDir;
global ImgPreviousDir;
global FilePreviousDir;
global SelectedDirectoriesFiles;
global DirSelectedDirectoriesFiles;
global ImgSelectedDirectoriesFiles;
global FileSelectedDirectoriesFiles;
global Type;
global Done;

if strcmp(Type, 'dir')
    DirPreviousDir = CurrentDir;
    DirSelectedDirectoriesFiles = SelectedDirectoriesFiles;
elseif strcmp(Type, 'img')
    ImgPreviousDir = CurrentDir;
    ImgSelectedDirectoriesFiles = SelectedDirectoriesFiles;
elseif strcmp(Type, 'file')
    FilePreviousDir = CurrentDir;
    FileSelectedDirectoriesFiles = SelectedDirectoriesFiles;
end

try
    varargout{1} = handles.output;
    SelectedDirectoriesFiles = reshape(SelectedDirectoriesFiles, length(SelectedDirectoriesFiles), 1);
    if Done == 1
        varargout{2} = SelectedDirectoriesFiles;
    else
        varargout{2} = '';
    end
    clear global SelectedDirectoriesFiles;
    delete(hObject);
catch
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
PreviousDir = CurrentDir;
CurrentDir = get(hObject, 'String');
if ~get(handles.WildCardsCheck, 'Value');
    if isempty(strfind(CurrentDir, '*'))
        % Set previous dir pop-up menu
        if ~isempty(PreviousDirCell)
            for i = 1:length(PreviousDirCell)
                if strcmp(PreviousDirCell{i}, CurrentDir)
                    break;
                end
            end
            if i >= length(PreviousDirCell) & ~strcmp(PreviousDirCell{i}, CurrentDir)
                PreviousDirCell{length(PreviousDirCell)+1} = CurrentDir;
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
        set(handles.PreviouosDirEdit, 'String', PreviousDirCell);
        %
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
            if strcmp(Type, 'dir')
                DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep], 'd');
                for i = 1:length(DirectoriesFiles)
                    DirectoriesFiles{i} = DirectoriesFiles{i}(1:end - 1);
                    [a,b,c] = fileparts(DirectoriesFiles{i});
                    DirectoriesFiles{i} = [b c]; 
                end
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
            elseif strcmp(Type, 'img')
                NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                NII1  = g_ls([CurrentDir filesep '*.nii']);
                NII2 = g_ls([CurrentDir filesep '*.NII']);
                IMG1 = g_ls([CurrentDir filesep '*.img']);
                IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
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
                FileList = g_ls([CurrentDir filesep '*'], '-d');
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
        msgbox(' * is not permitted in the path !');
        set( handles.CurrentDirEdit, 'String', PreviousDir);
    end
else
%     set(handles.FolderListbox, 'String', '');
    DirectoriesFiles = g_ls(CurrentDir, 'd');
    OldDirectoriesFiles = DirectoriesFiles;
    clear DirectoriesFiles;
    DirectoriesFiles = '';
    if strcmp(Type, 'dir')
        j = 0;
        for i = 1:length(OldDirectoriesFiles)
            if exist(OldDirectoriesFiles{i}, 'dir')
                j = j + 1;
                DirectoriesFiles{j} = OldDirectoriesFiles{i};
            end
        end
        SelectedDirectoriesFiles = reshape(SelectedDirectoriesFiles, length(SelectedDirectoriesFiles), 1);
        DirectoriesFiles = reshape(DirectoriesFiles, length(DirectoriesFiles), 1);
        SelectedDirectoriesFiles = [SelectedDirectoriesFiles; DirectoriesFiles];
        set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
        set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    else 
        j = 0;
        for i = 1:length(OldDirectoriesFiles)
            if exist(OldDirectoriesFiles{i}, 'file') & ~exist(OldDirectoriesFiles{i}, 'dir')
                j = j + 1;
                DirectoriesFiles{j} = OldDirectoriesFiles{i};
            end
        end
        SelectedDirectoriesFiles = reshape(SelectedDirectoriesFiles, length(SelectedDirectoriesFiles), 1);
        DirectoriesFiles = reshape(DirectoriesFiles, length(DirectoriesFiles), 1);
        SelectedDirectoriesFiles = [SelectedDirectoriesFiles; DirectoriesFiles];
        set(handles.SelectedDirectoriesFilesListbox, 'Value', 1);
        set(handles.SelectedDirectoriesFilesListbox, 'String', SelectedDirectoriesFiles);
    end
    
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
    if strcmp(Type,'img') 
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
                    PreviousDirCell{length(PreviousDirCell)+1} = CurrentDir;
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
            set(handles.PreviouosDirEdit, 'String', PreviousDirCell);
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
                    DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep], 'd');
                    for i = 1:length(DirectoriesFiles)
                        DirectoriesFiles{i} = DirectoriesFiles{i}(1:end - 1);
                        [a,b,c] = fileparts(DirectoriesFiles{i});
                        DirectoriesFiles{i} = [b c]; 
                    end
                    set(handles.DirectoriesFilesListbox, 'Value', 1);
                    set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
                elseif strcmp(Type, 'img')
                    NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                    NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                    NII1  = g_ls([CurrentDir filesep '*.nii']);
                    NII2 = g_ls([CurrentDir filesep '*.NII']);
                    IMG1 = g_ls([CurrentDir filesep '*.img']);
                    IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                    DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
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
                    FileList = g_ls([CurrentDir filesep '*'], '-d');
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
                PreviousDirCell{length(PreviousDirCell) + 1} = CurrentDir;
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
        set(handles.PreviouosDirEdit, 'String', PreviousDirCell);
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
                DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep], 'd');
                for i = 1:length(DirectoriesFiles)
                    DirectoriesFiles{i} = DirectoriesFiles{i}(1:end - 1);
                    [a,b,c] = fileparts(DirectoriesFiles{i});
                    DirectoriesFiles{i} = [b c]; 
                end
                set(handles.DirectoriesFilesListbox, 'Value', 1);
                set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
            elseif strcmp(Type, 'img')
                NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
                NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
                NII1  = g_ls([CurrentDir filesep '*.nii']);
                NII2 = g_ls([CurrentDir filesep '*.NII']);
                IMG1 = g_ls([CurrentDir filesep '*.img']);
                IMG2 = g_ls([CurrentDir filesep '*.IMG']);
                DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
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
                FileList = g_ls([CurrentDir filesep '*'], '-d');
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
    if strcmp(Type,'img') & ~isempty(SelectedDirectoriesFiles)
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
    if strcmp(SelectedDirectoriesFiles{end},'')
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
        if strcmp(Type,'img') & ~isempty(SelectedID)
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
Done = 1;
SelectedDirectoriesFiles = get(handles.SelectedDirectoriesFilesListbox, 'String');
uiresume(handles.SelectFigure);


% --- Executes when user attempts to close SelectFigure.
function SelectFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SelectFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.SelectFigure);


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
else
    set(handles.SubfoldersText, 'Enable', 'on');
    set(handles.FolderListbox, 'Enable', 'on');
    set(handles.DirectoriesFilesText, 'Enable', 'on');
    set(handles.DirectoriesFilesListbox, 'Enable', 'on');
    CurrentDir = BeforeWildCardsCurrentDir;
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
        DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep], 'd');
        for i = 1:length(DirectoriesFiles)
            DirectoriesFiles{i} = DirectoriesFiles{i}(1:end - 1);
            [a,b,c] = fileparts(DirectoriesFiles{i});
            DirectoriesFiles{i} = [b c]; 
        end
        set(handles.DirectoriesFilesListbox, 'Value', 1);
        set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
    elseif strcmp(Type, 'img')
        NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
        NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
        NII1  = g_ls([CurrentDir filesep '*.nii']);
        NII2 = g_ls([CurrentDir filesep '*.NII']);
        IMG1 = g_ls([CurrentDir filesep '*.img']);
        IMG2 = g_ls([CurrentDir filesep '*.IMG']);
        DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
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
        FileList = g_ls([CurrentDir filesep '*'], '-d');
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


% --- Executes on selection change in PreviouosDirEdit.
function PreviouosDirEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PreviouosDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PreviouosDirEdit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PreviouosDirEdit
global CurrentDir;
global PreviousDir;
global Type;
PreviousDir = get(handles.CurrentDirEdit, 'String');
PreviousDirCell = get(hObject, 'String');
sel = get(hObject, 'Value');
CurrentDir = PreviousDirCell{sel};
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
            DirectoriesFiles = g_ls([CurrentDir filesep '*' filesep], 'd');
            for i = 1:length(DirectoriesFiles)
                DirectoriesFiles{i} = DirectoriesFiles{i}(1:end - 1);
                [a,b,c] = fileparts(DirectoriesFiles{i});
                DirectoriesFiles{i} = [b c];
            end
            set(handles.DirectoriesFilesListbox, 'Value', 1);
            set(handles.DirectoriesFilesListbox, 'String', DirectoriesFiles);
        elseif strcmp(Type, 'img')
            NIIGZ1 = g_ls([CurrentDir filesep '*.nii.gz']);
            NIIGZ2 = g_ls([CurrentDir filesep '*.NII.GZ']);
            NII1  = g_ls([CurrentDir filesep '*.nii']);
            NII2 = g_ls([CurrentDir filesep '*.NII']);
            IMG1 = g_ls([CurrentDir filesep '*.img']);
            IMG2 = g_ls([CurrentDir filesep '*.IMG']);
            DirectoriesFiles = [NIIGZ1; NIIGZ2; NII1; NII2; IMG1; IMG2];
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
            FileList = g_ls([CurrentDir filesep '*'], '-d');
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
function PreviouosDirEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreviouosDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
%end


% --- Executes when SelectFigure is resized.
function SelectFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to SelectFigure (see GCBO)
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
