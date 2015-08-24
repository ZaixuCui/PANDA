function g_Bedpostx_pipeline( NativePathCell, BedpostxAlone_opt, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic
% fiber tracking for any number of subjects
%
% SYNTAX:
%
% 1) g_Bedpostx_pipeline( NativePathCell )
% 2) g_Bedpostx_pipeline( NativePathCell, BedpostxAlone_opt )
% 3) g_Bedpostx_pipeline( NativePathCell, BedpostxAlone_opt, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% NativePathCell
%        (cell of strings)
%        The input cell, each of which is the path of a folder which 
%        contains four files as listed: 
%        1) A 4D image named data.nii.gz containing diffusion-weighted 
%           volumes and volumes without diffusion weighting.
%        2) A 3D binary brain mask volume named nodif_brain_mask.nii.gz.
%        3) A text file named bvecs containing gradient directions for 
%           diffusion weighted volumes.
%        4) A text file named bvals containing b-values applied for each 
%           volume acquisition.
%
% BEDPOSTXALONE_OPT
%        If BedpostxAlone_opt = 'default', then the default values will be
%        assigned to all its fields.
%
%        (struct) with the following fields :
%
%        Weight
%            (integer, default 1)
%            ARD weight, more weight means less secondary fibers per voxel.
%
%        Burnin
%            (integer, default 1000)
%            Brunin period.
%
%        Fibers
%            (integer, default 2)
%            Number of fibers per voxel.
%
% PIPELINE_OPT
%        If pipeline_opt = 'default', then the default values will be
%        assigned to all its fields.
%
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
% See licensing information in the code
% keywords: bedpostx, pipeline, psom
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
    disp('Please input subjects'' native folders.');
    disp('see the help, type ''help g_Bedpostx_pipeline''.');
elseif ~iscell(NativePathCell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_Bedpostx_pipeline''.');
else
    
    psom_gb_vars

    if nargin <= 1
        BedpostxAlone_opt.Fibers = 2;
        BedpostxAlone_opt.Weight = 1;
        BedpostxAlone_opt.Burnin = 1000;
    elseif ~isstruct(BedpostxAlone_opt) && ~strcmp(BedpostxAlone_opt, 'default')
        disp('The value of the second parameter bedpostx opt is invalid.');
        disp('see the help, type ''help g_Bedpostx_pipeline''.');
        return;
    elseif strcmp(BedpostxAlone_opt, 'default')
        clear BedpostxAlone_opt;
        BedpostxAlone_opt.Fibers = 2;
        BedpostxAlone_opt.Weight = 1;
        BedpostxAlone_opt.Burnin = 1000;
    else
        
        BedpostxAloneOptFields = {'Weight', 'Fibers', 'Burnin'};
        BedpostxAloneOptFields_UserInputs = fieldnames(BedpostxAlone_opt);
        for i = 1:length(BedpostxAloneOptFields_UserInputs)
            if isempty(find(strcmp(BedpostxAloneOptFields, BedpostxAloneOptFields_UserInputs{i})))
                disp([BedpostxAloneOptFields_UserInputs{i} ' is not the field of BedpostxAlone opt.']);
                disp('See the help, type ''help g_Bedpostx_pipeline''.');
                return;
            end
        end
        
        if ~isfield(BedpostxAlone_opt, 'Fibers')
            BedpostxAlone_opt.Fibers = 2;
        end
        if ~isfield(BedpostxAlone_opt, 'Weight')
            BedpostxAlone_opt.Weight = 1;
        end
        if ~isfield(BedpostxAlone_opt, 'Burnin')
            BedpostxAlone_opt.Burnin = 1000;
        end
        
    end
    
    if ~isnumeric(BedpostxAlone_opt.Weight)
        disp('The Weight field of BedpostxAlone_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(BedpostxAlone_opt.Weight) ~= BedpostxAlone_opt.Weight || BedpostxAlone_opt.Weight < 0
        disp('The Weight field of BedpostxAlone_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(BedpostxAlone_opt.Burnin)
        disp('The Burnin field of BedpostxAlone_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(BedpostxAlone_opt.Burnin) ~= BedpostxAlone_opt.Burnin || BedpostxAlone_opt.Burnin < 0
        disp('The Burnin field of BedpostxAlone_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(BedpostxAlone_opt.Fibers)
        disp('The Fibers field of BedpostxAlone_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(BedpostxAlone_opt.Fibers) ~= BedpostxAlone_opt.Fibers || BedpostxAlone_opt.Fibers < 0
        disp('The Fibers field of BedpostxAlone_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end

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
        pipeline_opt.path_logs = [pwd '/Bedpostx_logs/'];
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
        pipeline_opt.flag_verbose = 1;
        pipeline_opt.flag_pause = 0;
        pipeline_opt.flag_update = 1;
        pipeline_opt.path_logs = [pwd '/Bedpostx_logs/'];
    elseif nargin >= 3
        
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
            pipeline_opt.path_logs = [pwd '/Bedpostx_logs/'];
        else
            pipeline_opt.path_logs = [pipeline_opt.path_logs '/Bedpostx_logs/'];
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
        for i = 1:length(NativePathCell)
            Number_Of_Subject_String = num2str(i, '%05.0f');

            Job_Name1 = [ 'BedpostX_preproc_',Number_Of_Subject_String ];
            pipeline.(Job_Name1).command = 'g_bedpostX_preproc( opt.NativeFolder )';
            merge_Name = [ 'merge_' Number_Of_Subject_String ];
            pipeline.(Job_Name1).files_in.files = {};
            pipeline.(Job_Name1).files_out.files = g_bedpostX_preproc_FileOut( NativePathCell{i} );
            pipeline.(Job_Name1).opt.NativeFolder = NativePathCell{i};

            BedpostxFolder = [NativePathCell{i} '.bedpostX'];
            for BedpostXJobNum = 1:10
                Job_Name2 = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(BedpostXJobNum, '%02.0f') ];
                pipeline.(Job_Name2).command = 'g_bedpostX( opt.NativeFolder, opt.BedpostXJobNum, opt.Fibers, opt.Weight, opt.Burnin )';
                pipeline.(Job_Name2).files_in.files = pipeline.(Job_Name1).files_out.files;
                pipeline.(Job_Name2).files_out.files = g_bedpostX_FileOut(BedpostxFolder, BedpostXJobNum);
                pipeline.(Job_Name2).opt.NativeFolder = NativePathCell{i};
                pipeline.(Job_Name2).opt.BedpostXJobNum = BedpostXJobNum;
                pipeline.(Job_Name2).opt.Weight = BedpostxAlone_opt.Weight;
                pipeline.(Job_Name2).opt.Burnin = BedpostxAlone_opt.Burnin;
                pipeline.(Job_Name2).opt.Fibers = BedpostxAlone_opt.Fibers;
            end

            Job_Name3 = [ 'BedpostX_postproc_' Number_Of_Subject_String ];
            pipeline.(Job_Name3).command = 'g_bedpostX_postproc( opt.BedpostxFolder,opt.Fibers )';
            for j = 1:10
                Job_Name = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(j, '%02.0f') ];
                pipeline.(Job_Name3).files_in.files{j} = pipeline.(Job_Name).files_out.files{1};
            end
            pipeline.(Job_Name3).files_out.files = g_bedpostX_postproc_FileOut( BedpostxFolder );
            pipeline.(Job_Name3).opt.BedpostxFolder = BedpostxFolder;
            pipeline.(Job_Name3).opt.Fibers = BedpostxAlone_opt.Fibers;
        end

        psom_run_pipeline(pipeline,pipeline_opt);
    end
end
