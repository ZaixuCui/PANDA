function g_TBSS_pipeline( FAPathCell, DataPathCell, ResultPath, Threshold, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_TBSS_PIPELINE
% 
% The whole process of TBSS for any number of subjects
%
% SYNTAX:
%
% 1) g_TBSS_pipeline( FAPathCell, DataPathCell, ResultPath )
% 2) g_TBSS_pipeline( FAPathCell, DataPathCell, ResultPath, Threshold  )
% 3) g_TBSS_pipeline( FAPathCell, DataPathCell, ResultPath, Threshold, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% FAPATHCELL
%        (cell of strings, n rows, 1 column)
%        The input cell, each of which is the full path of subject's FA.
%        FA should be in the standard space with voxel size of 1*1*1.
%
% DATAPATHCELL
%        (cell of strings, n rows, m columns)
%        The input cell, each of which is the full path of the data to be 
%        projected to the skeleton
%        Quantity of rows is quantity of subjects, quantity of columns is
%        quantity of data type.
%        For example, 3 subjects, and project FA, MD to mean skeleton
%                     DataPathCell should be like:
%                     .../001_FA_1mm.nii.gz     .../001_MD_1mm.nii.gz
%                     .../002_FA_1mm.nii.gz     .../002_MD_1mm.nii.gz
%                     .../003_FA_1mm.nii.gz     .../002_MD_1mm.nii.gz
%        Data should be in the standard space with voxel size of 1*1*1.
%
% RESULTPATH
%        (string)
%        The full path of the folder storing resultant files.
%
% THRESHOLD
%        (float, default 0.2, 0 <= threshold <= 1)
%        FA threshold to exclude voxels in the grey matter or CSF.
%        Please reference:http://www.fmrib.ox.ac.uk/fsl/tbss/index.html.
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
% See licensing information in the code
% keywords: TBSS, pipeline, psom
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
    disp('Please input subjects'' FA path.')
    disp('see the help, type ''help g_TBSS_pipeline''.');
    return;
elseif nargin <= 1
    disp('Please input subjects'' data path.')
    disp('see the help, type ''help g_TBSS_pipeline''.');
    return;
elseif ~iscell(FAPathCell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_TBSS_pipeline''.');
    return;
elseif ~iscell(DataPathCell)
    disp('The second parameter should be a cell.');
    disp('see the help, type ''help g_TBSS_pipeline''.');
    return;
elseif nargin <= 2
    disp('Please input the result path.');
    disp('see the help, type ''help g_TBSS_pipeline''.');
    return;
elseif nargin <= 3
    Threshold = 0.2;
end

if ~isfloat(Threshold)
    disp('Threshold should be a float number in the range of [0 1].');
    disp('see the help, type ''help g_TBSS_pipeline''.');
elseif Threshold < 0 || Threshold > 1
    disp('0 <= Threshold <= 1, the value input is out of the range.');
    disp('see the help, type ''help g_TBSS_pipeline''.');
else
    [FARows, FAColumns] = size(FAPathCell);
    if FAColumns ~= 1
        disp('The cell of FA path should be 1 column.');
        disp('see the help, type ''help g_TBSS_pipeline''.');
    else
        [DataRows, DataColumns] = size(DataPathCell);
        if FARows ~= DataRows
            disp('The number of rows of FA path Cell should be equal to the number of rows of data path cell.');
            disp('See the help, type ''help g_TBSS_pipeline''.');
        else
            try 
                ResultPathPermissionDenied = 0;
                if ~exist(ResultPath, 'dir')
                    mkdir(ResultPath);
                end
                if ~exist([ResultPath filesep 'logs'], 'dir')
                    mkdir([ResultPath filesep 'logs']);
                end
                x = 1;
                save([ResultPath filesep 'logs' filesep 'permission_tag.mat'], 'x');
            catch
                ResultPathPermissionDenied = 1;
                disp('Please change result path, perssion denied !');
            end
            
            if ~ResultPathPermissionDenied
                
                psom_gb_vars

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

                if nargin <= 4
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
                    pipeline_opt.path_logs = [ResultPath '/logs/'];
                elseif ~isstruct(pipeline_opt) %&& ~strcmp(pipeline_opt, 'default')
                    disp('The value of the fifth parameter pipeline opt is invalid.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
%                 elseif strcmp(pipeline_opt, 'default')
%                     The default value of pipeline opt parameters
%                     clear pipeline_opt;
%                     pipeline_opt.mode = 'batch';
%                     pipeline_opt.mode_pipeline_manager = 'batch';
%                     if ~isempty(QuantityOfCpu)
%                         pipeline_opt.max_queued = str2num(QuantityOfCpu);
%                     else
%                         pipeline_opt.max_queued = 4;
%                     end
%                     pipeline_opt.flag_verbose = 0;
%                     pipeline_opt.flag_pause = 0;
%                     pipeline_opt.flag_update = 1;
%                     pipeline_opt.path_logs = [ResultPath '/logs/'];
                elseif nargin >= 5

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
                        pipeline_opt.path_logs = [ResultPath '/logs/'];
                    else
                        pipeline_opt.path_logs = [pipeline_opt.path_logs '/logs/'];
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
                    disp('The max queued of the pipeline shoud be an positive integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if pipeline_opt.max_queued <= 0
                    disp('The max queued of the pipeline shoud be an positive integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                
                % In any case, The log files of pipeline is in the path specified by
                % variable `ResultPath`
                
                ResultPath = [ResultPath filesep];
                % Generate FA skeleton mask distance map
                Job_Name1 = 'g_dismap';
                pipeline.(Job_Name1).command           = 'g_dismap( opt.FA_normalized_1mm_cell, opt.Nii_Output_Path, opt.threshold )';
                pipeline.(Job_Name1).files_out.files   = g_dismap_FileOut( ResultPath );
                pipeline.(Job_Name1).opt.FA_normalized_1mm_cell = FAPathCell;
                pipeline.(Job_Name1).opt.Nii_Output_Path   = ResultPath;
                pipeline.(Job_Name1).opt.threshold         = Threshold;
                
                % skeleton_Data job
                [rows, cols] = size(DataPathCell);
                for i = 1:cols  % cols is the quantity of data type to be projected to the skeleton (such as MD, L1, ...)
                    DataResultPath = [ResultPath 'Data' num2str(i) filesep];
                    for j = 1:rows  % rows is the quantity of data of one type
                        Job_Name2 = [ 'skeleton_Data', num2str(i), '_', num2str(j) ];  % i is the number of the type
                        % j is the number of the subject
                        pipeline.(Job_Name2).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.ResultPath )';
                        pipeline.(Job_Name2).files_in.files    = pipeline.(Job_Name1).files_out.files;
                        pipeline.(Job_Name2).files_out.files   = g_2skeleton_FileOut_TBSS( DataResultPath,DataPathCell{j,i} );
                        pipeline.(Job_Name2).opt.fileName      = DataPathCell{j,i};
                        pipeline.(Job_Name2).opt.FA_fileName   = FAPathCell{j};
                        pipeline.(Job_Name2).opt.Mean_FA_fileName   = pipeline.(Job_Name1).files_out.files{1};
                        pipeline.(Job_Name2).opt.Dst_fileName  = pipeline.(Job_Name1).files_out.files{5};
                        pipeline.(Job_Name2).opt.threshold     = Threshold;
                        pipeline.(Job_Name2).opt.ResultPath    = DataResultPath;
                    end
                    
                    % Merge all Subjects' individual skeleton into a 4D skeleton
                    Job_Name3 = ['MergeSkeleton_Data', num2str(i)];
                    pipeline.(Job_Name3).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
                    for j = 1:rows
                        SkeletonJobName = [ 'skeleton_Data', num2str(i), '_', num2str(j) ];
                        pipeline.(Job_Name3).files_in.files{j} = pipeline.(SkeletonJobName).files_out.files{1};
                    end
                    pipeline.(Job_Name3).files_out.files{1}   = [ResultPath filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_data' num2str(i) '.nii.gz'];
                    pipeline.(Job_Name3).opt.SubjectIDs   = [1:rows];
                    pipeline.(Job_Name3).opt.ResultantFile   = [ResultPath filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_data' num2str(i) '.nii.gz'];
                end
                
                psom_run_pipeline(pipeline,pipeline_opt);
                
            end
        end
    end
end


