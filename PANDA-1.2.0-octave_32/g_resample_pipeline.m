function g_resample_pipeline( RawImages_Cell, Voxel_Size, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_RESAMPLE_PIPELINE
% 
% Resampling the NIfTI images to certain resolution.
%
% SYNTAX:
%
% 1) g_resample_pipeline( RawImages_Cell, Voxel_Size )
% 2) g_resample_pipeline( RawImages_Cell, Voxel_Size, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% RAWIMAGES_CELL
%        (cell of strings) 
%        The input folder cell, each of which includes the DICOM data.
%
% VOXEL_SIZE
%        (array of integer)
%        The final voxel size of the resampled images. 
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
%        path_logs
%            (string, default is a folder name 'logs' in current directory) 
%            The full path of the folder containg the log information.
%            For example: /data/logs/
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
    disp('Please input subjects'' raw NIfTI images to be resampled.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
if ~iscell(RawImages_Cell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
[RawDataRows, RawDataColumns] = size(RawImages_Cell);
if RawDataColumns ~= 1
    disp('The quantity of columns of raw data cell should be 1.');
    disp('RawImages_Cell is a n*1 matrix.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
if nargin <= 1
    disp('Please input the final voxel size of the resampled images.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
try
    if length(Voxel_Size) ~= 3
        disp('The voxel size should have three elements.');
        disp('For example: [2 2 2]');
        disp('see the help, type ''help g_resample_pipeline''.');
        return;
    end
catch 
    disp('The voxel size you input is illegal.');
    return;
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

if nargin <= 2
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
    pipeline_opt.path_logs = [pwd '/Resample_logs/'];
elseif ~isstruct(pipeline_opt) && ~strcmp(pipeline_opt, 'default')
    disp('The value of the fifth parameter pipeline opt is invalid.');
    disp('see the help, type ''help g_resample_pipeline''.');
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
    pipeline_opt.path_logs = [pwd '/Resample_logs/'];
elseif nargin >= 3
    
    PipelineOptFields = {'mode', 'qsub_options', 'mode_pipeline_manager', 'max_queued', ...
        'flag_verbose', 'flag_pause', 'path_logs'};
    PipelineOptFields_UserInputs = fieldnames(pipeline_opt);
    for i = 1:length(PipelineOptFields_UserInputs)
        if isempty(find(strcmp(PipelineOptFields, PipelineOptFields_UserInputs{i})))
            disp([PipelineOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
            disp('See the help, type ''help g_resample_pipeline''.');
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
        pipeline_opt.path_logs = [pwd '/Resample_logs/'];
    else
        pipeline_opt.path_logs = [pipeline_opt.path_logs '/Resample_logs/'];
    end
end

if ~strcmp(pipeline_opt.mode, 'batch') && ~strcmp(pipeline_opt.mode, 'qsub')
    disp('The mode of the pipeline should be ''batch'' or ''qsub''');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
if ~isnumeric(pipeline_opt.max_queued)
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
if round(pipeline_opt.max_queued) ~= pipeline_opt.max_queued
    disp('The max queued of the pipeline shoud be an integer.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end
if pipeline_opt.max_queued <= 0
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_resample_pipeline''.');
    return;
end

for i = 1:length(RawImages_Cell)
    
    JobName = ['Resample_' num2str(i, '%05d')];  
    
    [ParentFolder FileName FileSuffix] = fileparts(RawImages_Cell{i});
    ResampledImagePath = [ParentFolder filesep 'r' FileName FileSuffix];
    
    pipeline.(JobName).command = 'g_resample_nii(opt.RawImage,opt.VoxelSize,files_out.files{1})';
    pipeline.(JobName).opt.RawImage = RawImages_Cell{i};
    pipeline.(JobName).opt.VoxelSize = Voxel_Size;
    pipeline.(JobName).files_out.files{1} = ResampledImagePath;
    
end

psom_run_pipeline(pipeline, pipeline_opt);
