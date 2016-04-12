function pipeline = g_BrainParcellation_pipeline(FAPathCell, T1PathCell, PartitionTemplatePath, pipeline_opt)
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX_PIPELINE
% 
% The whole process of brain parcellation for any number of subjects
%
% SYNTAX:
%
% 1) g_BrainParcellation_pipeline( FAPathCell, T1PathCell )
% 2) g_BrainParcellation_pipeline( FAPathCell, T1PathCell, PartitionTemplatePath )
% 3) g_BrainParcellation_pipeline( FAPathCell, T1PathCell, PartitionTemplatePath, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% FAPATHCELL
%        (cell of strings)
%        The input cell, each of which is the full path of subject's FA.
%        FA is original FA calculated by dtifit.
%
% T1PATHCELL
%        (cell of strings)
%        The input cell, each of which is the path of subject's T1.
%        T1 image should be skull stripped.
%
% PARTITIONTEMPLATEPATH
%        If PartitionTemplatePath = 'default', then the default values will 
%        be assigned to all its fields.
%        (string, default AAL atlas with 116 regions)
%        The full path of gray matter altas in standard space.
%
% PIPELINE_OPT
%        If pipeline_opt = 'default', then the default values will be
%        assigned to all its fields.
%
%        (structure) with the following fields :
%        
%        mode
%            (string, default )
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
% Neuroscience and Learning, Beijing Normal University, 2011.
% See licensing information in the code
% keywords: brain parcellation, pipeline, psom
% Please report bugs or requests to:
%   Zaixu Cui:         <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%   Suyu Zhong:        <a href="suyu.zhong@gmail.com">suyu.zhong@gmail.com</a>
%   Gaolang Gong (PI): <a href="gaolang.gong@gmail.com">gaolang.gong@gmail.com</a>

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
    disp('Please input subjects'' FA path.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
elseif nargin <= 1
    disp('Please input subjects'' T1 path.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
elseif ~iscell(FAPathCell)
    disp('The first parameter subjects'' FA paths should be a cell.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
elseif ~iscell(T1PathCell)
    disp('The second parameter subjects'' T1 paths should be a cell.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
else
    [FARows, FAColumns] = size(FAPathCell);
    if FAColumns ~= 1
        disp('The cell of FA path should be 1 column.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    
    [T1Rows, T1Columns] = size(T1PathCell);
    if T1Columns ~= 1
        disp('The cell of T1 path should be 1 column.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    
    if FARows ~= T1Rows
        disp('The number of rows of FA path Cell should be equal to the number of rows of T1 path cell.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    
    global PANDAPath;
    [PANDAPath y z] = fileparts(which('PANDA.m'));

    psom_gb_vars

    if nargin <= 2
        PartitionTemplatePath = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
    elseif strcmp(PartitionTemplatePath, 'default')
        PartitionTemplatePath = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
    else
        [x exist_flag] = system(['imtest ' PartitionTemplatePath]);
        exist_flag = str2num(exist_flag);
        if ~(exist_flag == 1)
            disp(['The file ' PartitionTemplatePath ' doesn''t exist.']);
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
    end

    if isunix
        try
            [a,QuantityOfCpu] = system('cat /proc/cpuinfo | grep processor | wc -l');
        catch
            QuantityOfCpu = '';
        end
    elseif ismac
        try
            [a,QuantityOfCpu] = system('cat /proc/cpuinfo | grep processor | wc -l');
        catch
            QuantityOfCpu = '';
        end
    end
    
    if nargin <= 3
        % The default value of pipeline opt parameters
        pipeline_opt.mode = 'batch';
        pipeline_opt.mode_pipeline_manager = 'batch';
        if ~isempty(QuantityOfCpu)
            pipeline_opt.max_queued = str2num(QuantityOfCpu);
        else
            pipeline_opt.max_queued = 4;
        end
        pipeline_opt.flag_verbose = 0;
        pipeline_opt.flag_pause = 0;
        pipeline_opt.flag_update = 1;
        pipeline_opt.path_logs = [pwd '/BrainParcellation_logs/'];
    elseif ~isstruct(pipeline_opt) && ~strcmp(pipeline_opt, 'default')
        disp('The value of the fifth parameter pipeline opt is invalid.');
        disp('see the help, type ''help g_dti_pipeline''.');
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
        pipeline_opt.flag_verbose = 0;
        pipeline_opt.flag_pause = 0;
        pipeline_opt.flag_update = 1;
        pipeline_opt.path_logs = [pwd '/BrainParcellation_logs/'];
    elseif nargin >= 4
        
        PipelineOptFields = {'mode', 'qsub_options', 'mode_pipeline_manager', 'max_queued', ...
            'flag_verbose', 'flag_pause', 'path_logs'};
        PipelineOptFields_UserInputs = fieldnames(pipeline_opt);
        for i = 1:length(PipelineOptFields_UserInputs)
            if isempty(find(strcmp(PipelineOptFields, PipelineOptFields_UserInputs{i})))
                disp([PipelineOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
                disp('See the help, type ''help g_dti_pipeline''.');
                return;
            end
        end
        
        if ~isfield(pipeline_opt,'flag_verbose')
            pipeline_opt.flag_verbose = 0;
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
            pipeline_opt.path_logs = [pwd '/BrainParcellation_logs/'];
        end
    end
    
    if ~strcmp(pipeline_opt.mode, 'batch') && ~strcmp(pipeline_opt.mode, 'qsub')
        disp('The mode of the pipeline should be ''batch'' or ''qsub''');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(pipeline_opt.max_queued)
        disp('The max queued of the pipeline shoud be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(pipeline_opt.max_queued) ~= pipeline_opt.max_queued
        disp('The max queued of the pipeline shoud be an integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if pipeline_opt.max_queued <= 0
        disp('The max queued of the pipeline shoud be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end

    try 
        LogPathPermissionDenied = 0;
        if ~exist(pipeline_opt.path_logs, 'dir')
            mkdir(pipeline_opt.path_logs);
        end
        x = 1;
        save([pipeline_opt.path_logs filesep 'permission_tag.mat'], 'x');
    catch
        LogPathPermissionDenied = 1;
        disp('Please change log path, perssion denied !');
    end

    if ~LogPathPermissionDenied
        for i = 1:length(FAPathCell)
            Number_Of_Subject_String = num2str(i, '%05.0f');
            Job_Name = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
            pipeline.(Job_Name).command           = 'g_PartitionTemplate2FA( opt.FA_Path,opt.T1_Path,opt.PartitionTemplate )';
            pipeline.(Job_Name).files_in.files{1} = FAPathCell{i};
            pipeline.(Job_Name).files_in.files{2} = T1PathCell{i};
            pipeline.(Job_Name).files_out.files   = g_PartitionTemplate2FA_FileOut_NetworkNode( FAPathCell{i},PartitionTemplatePath );
            pipeline.(Job_Name).opt.FA_Path       = FAPathCell{i};
            pipeline.(Job_Name).opt.T1_Path       = T1PathCell{i};
            pipeline.(Job_Name).opt.PartitionTemplate   = PartitionTemplatePath;
        end

        psom_run_pipeline(pipeline,pipeline_opt);
    end
end


