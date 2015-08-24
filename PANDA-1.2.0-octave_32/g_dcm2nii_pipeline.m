function g_dcm2nii_pipeline( DICOM_Cell, SubjectID, Destination_Path, Type, File_Prefix, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_DCM2NII_PIPELINE
% 
% Convert DICOM files to NIfTI images for any number of subjects.
%
% SYNTAX:
%
% 1) g_dcm2nii_pipeline( DICOM_Cell, SubjectID, Destination_Path, Type )
% 2) g_dcm2nii_pipeline( DICOM_Cell, SubjectID, Destination_Path, Type, File_Prefix )
% 3) g_dcm2nii_pipeline( DICOM_Cell, SubjectID, Destination_Path, Type, File_Prefix, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% DICOM_CELL
%        (cell of strings) 
%        The input folder cell, each of which includes the DICOM data.
%
% SUBJECTID
%        (cell of integers) 
%        The order of the subjects.
%        For example: SubjectID = [1:5] 
%                     The resultant folder for each subject is like 
%                     '/data/Handled_Data/00001/'
%
% DESTINATION_PATH
%        (string) 
%        The full path of resultant folder for all subjects.
%        For example: '/data/Handled_Data/'
%
% TYPE 
%        (string)
%        Three selections: 'dMRI'
%                          'fMRI'
%                          'T1'
%
% FILE_PREFIX
%        (string) 
%        Basename for the output file. 
%
% PIPELINE_OPT
%        (structure) with the following fields :
%        
%        mode
%            (string, default 'batch')
%            'batch' : 
%                Execute with only one computer.
%            'qsub'  : 
%                Execute in a distributed environment such as SGE, PBS. 
%
%        max_queued
%            (integer) The maximum number of jobs that can be processed 
%            simultaneously.
%            ('batch' mode) Default value is 'quantity of cores'.
%            ('qsub' mode) Default value is Inf.
%
%        qsub_options
%            (string) Only needed in the 'qsub' mode.          
%            This field can be used to pass any argument when submitting a
%            job with qsub. For example, '-q all.q@yeatman,all.q@zeus' will
%            force qsub to only use the yeatman and zeus workstations in 
%            the all.q queue. It can also be used to put restrictions on 
%            the minimum avalaible memory, etc.
%        
%        please refer to 'Howtouserpsom'
%        address: http://code.google.com/p/psom/wiki/HowToUsePsom       
%__________________________________________________________________________
% OUTPUTS:
%
% PIPELINE
%        the pipeline of our jobs
%__________________________________________________________________________
% COMMENTS:
% 
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: T1, bet, pipeline, psom
% Please report bugs or requests to:
%   Zaixu Cui:            zaixucui@gmail.com
%   Suyu Zhong:           suyu.zhong@gmail.com
%   Gaolang Gong (PI):    gaolang.gong@gmail.com

% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documation files, to deal in the
% Software without restriction, including without limitation the rights to
% use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

if nargin <= 0
    disp('Please input subjects'' raw DICOM data.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if ~iscell(DICOM_Cell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
[RawDataRows, RawDataColumns] = size(DICOM_Cell);
if RawDataColumns ~= 1
    disp('The quantity of columns of raw data cell should be 1.');
    disp('DICOM_Cell is a n*1 matrix.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if nargin <= 1
    disp('Please assign IDs for the subjects.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if RawDataRows ~= length(SubjectID)
    disp('The quantity of raw data should be equal to the quantity of IDs.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if nargin <= 2
    disp('Please input the path of folder storing the resultant files.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
try
    if ~exist(Destination_Path, 'dir')
        mkdir(Destination_Path);
        if ~strcmp(Destination_Path(1), filesep)
            Destination_Path = [pwd filesep Destination_Path];
        end
    else
        x = 1;
        save([Destination_Path filesep 'permission_tag.mat'], 'x');
    end
catch
    disp('Maybe the Destination_Path is illegal or permission denied.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if nargin <= 3
    disp('Please input the type of the data you want to convert.');
    disp('Three choices:');
    disp('1. dti  2. fMRI  3. t1');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if ~strcmp(Type, 'dMRI') && ~strcmp(Type, 'fMRI') && ~strcmp(Type, 'T1')
    disp('Type of DICOM data shoule be ''dMRI'', ''fMRI'' or ''T1''.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if nargin <= 4
    File_Prefix = '';
end
        
psom_gb_vars;

if isunix
    try
        [a,QuantityOfCpu] = system('cat /proc/cpuinfo | grep processor | wc -l');
    catch
        QuantityOfCpu = '';
    end
elseif ismac
    try
        [a,QuantityOfCpu] = system('sysctl -n machdep.cpu.core_count');
    catch
        QuantityOfCpu = '';
    end
end

if nargin <= 5
    % The default value of pipeline opt parameters
    pipeline_opt.mode = 'batch';
    pipeline_opt.mode_pipeline_manager = 'batch';
    if ~isempty(QuantityOfCpu)
        pipeline_opt.max_queued = str2num(QuantityOfCpu);
    else
        pipeline_opt.max_queued = 4;
    end
    pipeline_opt.flag_verbose = 1;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.flag_update = 1;
    pipeline_opt.path_logs = [Destination_Path '/dcm2nii_logs/'];
elseif ~isstruct(pipeline_opt) && ~strcmp(pipeline_opt, 'default')
    disp('The value of the fifth parameter pipeline opt is invalid.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
elseif strcmp(pipeline_opt, 'default')
    % The default value of pipeline opt parameters
    clear pipeline_opt;
    pipeline_opt.mode = 'batch';
    pipeline_opt.mode_pipeline_manager = 'batch';
    if ~isempty(QuantityOfCpu)
        pipeline_opt.max_queued = str2num(QuantityOfCpu);
    else
        pipeline_opt.max_queued = 4;
    end
    pipeline_opt.flag_verbose = 1;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.flag_update = 1;
    pipeline_opt.path_logs = [Destination_Path '/dcm2nii_logs/'];
elseif nargin >= 6
    
    PipelineOptFields = {'mode', 'qsub_options', 'mode_pipeline_manager', 'max_queued', ...
        'flag_verbose', 'flag_pause', 'path_logs'};
    PipelineOptFields_UserInputs = fieldnames(pipeline_opt);
    for i = 1:length(PipelineOptFields_UserInputs)
        if isempty(find(strcmp(PipelineOptFields, PipelineOptFields_UserInputs{i})))
            disp([PipelineOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
            disp('See the help, type ''help g_dcm2nii_pipeline''.');
            return;
        end
    end
    
    if ~isfield(pipeline_opt,'flag_verbose')
        pipeline_opt.flag_verbose = 1;
    end
    if ~isfield(pipeline_opt,'flag_pause')
        pipeline_opt.flag_pause = 0;
    end
    if ~isfield(pipeline_opt,'flag_update')
        pipeline_opt.flag_update = 1;
    end
    if ~isfield(pipeline_opt,'mode')
        pipeline_opt.mode = 'batch';
    end
    if strcmp(pipeline_opt.mode,'qsub') && ~isfield(pipeline_opt,'qsub_options')
        pipeline_opt.qsub_options = '-q all.q';
    end
    if ~isfield(pipeline_opt,'mode_pipeline_manager')
        pipeline_opt.mode_pipeline_manager = 'batch';
    end
    if ~isfield(pipeline_opt,'max_queued')
        if strcmp(pipeline_opt.mode, 'batch')
            if ~isempty(QuantityOfCpu)
                pipeline_opt.max_queued = str2num(QuantityOfCpu);
            else
                pipeline_opt.max_queued = 4;
            end
        elseif strcmp(pipeline_opt.mode, 'qsub')
            pipeline_opt.max_queued = 100;
        end
    end
    if ~isfield(pipeline_opt,'path_logs')
        pipeline_opt.path_logs = [Destination_Path '/dcm2nii_logs/'];
    else
        pipeline_opt.path_logs = [pipeline_opt.path_logs '/dcm2nii_logs/'];
    end
end

if ~strcmp(pipeline_opt.mode, 'batch') && ~strcmp(pipeline_opt.mode, 'qsub')
    disp('The mode of the pipeline should be ''batch'' or ''qsub''');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if ~isnumeric(pipeline_opt.max_queued)
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if round(pipeline_opt.max_queued) ~= pipeline_opt.max_queued
    disp('The max queued of the pipeline shoud be an integer.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end
if pipeline_opt.max_queued <= 0
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_dcm2nii_pipeline''.');
    return;
end

for i = 1:length(DICOM_Cell)
    
    Number_Of_Subject_String = num2str(SubjectID(i), '%05d');
    SubjectFolder = [Destination_Path filesep Number_Of_Subject_String];
    if ~exist(SubjectFolder, 'dir')
        mkdir(SubjectFolder);
    end
    
    % Save the raw path and the path of nii data to matrix file
    variable_name = ['subject_info_',Number_Of_Subject_String];
    Subject_Info_File = [Destination_Path filesep 'subject_info.mat'];
    tmp = [DICOM_Cell{i} '  ' SubjectFolder '/'];
    eval([variable_name ' = tmp;']);
    if ~exist(Subject_Info_File, 'file')
        save(Subject_Info_File, variable_name);
    else
        % don't need to checking wether the data is already exist,because
        %this command will cover variables with the same name
        save(Subject_Info_File,variable_name,'-append');
    end
    
    % Save the raw path and the path of nii data to txt file
    fid = fopen([Destination_Path filesep 'subject_info.txt'], 'a+');
    % check whether the subject information is already exist
    exist_flag = 0; % 0:not exist  1:exist
    while(~feof(fid))
        raw_path = fscanf(fid, '%s', [1]);
        nii_path = fscanf(fid, '%s', [1]);
        if(strcmp(raw_path, DICOM_Cell{i}))
            exist_flag = 1;
            break;
        end
    end
    if exist_flag == 0
        fprintf(fid, DICOM_Cell{i});fprintf(fid, ' \t');
        fprintf(fid, [Destination_Path filesep Number_Of_Subject_String '/']);fprintf(fid, '\n');
    end
    fclose(fid);
    
    JobName = ['dcm2nii_' num2str(SubjectID(i), '%05d')];
    if strcmp(Type, 'T1')
        pipeline.(JobName).command = 'g_dcm2nii_t1(opt.DICOMFolder,opt.Prefix,opt.OutputFolder)';
    elseif strcmp(Type, 'dMRI')
        pipeline.(JobName).command = 'g_dcm2nii_dMRI(opt.DICOMFolder,opt.Prefix,opt.OutputFolder)';
    else
        pipeline.(JobName).command = 'g_dcm2nii_fMRI(opt.DICOMFolder,opt.Prefix,opt.OutputFolder)';
    end
    pipeline.(JobName).opt.DICOMFolder = DICOM_Cell{i};
    pipeline.(JobName).opt.Prefix = [File_Prefix '_' Number_Of_Subject_String];
    pipeline.(JobName).opt.OutputFolder = SubjectFolder;
    pipeline.(JobName).files_out.files{1} = [SubjectFolder filesep 'dcm2nii.done'];
    
end

psom_run_pipeline(pipeline, pipeline_opt);
