function pipeline = g_TBSS_pipeline( FAPathCell, DataPathCell, Threshold, ResultPath, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_TBSS_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic for 
% any number of subjects
%
% SYNTAX:
% G_TBSS_PIPELINE( FAPATHCELL, DATAPATHCELL, THRESHOLD, RESULTPATH, PIPELINE_OPT)
%__________________________________________________________________________
% INPUTS:
%
% FAPATHCELL
%        (cell of string)
%        the member of the cell is the path of FA of one subject
%
% DATAPATHCELL
%        (cell of string)
%        the member of the cell is the the path of the file to be 
%        projected to the skeleton
%
% THRESHOLD
%        (float) threshold for TBSS, always be 0.2
%        Please reference:http://www.fmrib.ox.ac.uk/fsl/tbss/index.html
%
% RESULTPATH
%        (string)
%        the path for the TBSS results
%
% PIPELINE_OPT
%        (struct)
%        options of the psom pipeline 
%        please refer to 'Howtouserpsom'
%        address: http://code.google.com/p/psom/wiki/HowToUsePsom
%       
%__________________________________________________________________________
% OUTPUTS:
%
% PIPELINE
%        the pipeline of our jobs
%__________________________________________________________________________
% USAGE:
%
%        1) g_TBSS_pipeline( FAPathCell, DataPathCell, Threshold, ResultPath, pipeline_opt )
%        2) g_TBSS_pipeline( FAPathCell, DataPathCell, Threshold, ResultPath )
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
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: TBSS, pipeline, psom

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

try
psom_gb_vars

if nargin <= 4
    % The default value of pipeline opt parameters
    pipeline_opt.mode = 'qsub';
    pipeline_opt.qsub_options = '-q all.q';
    pipeline_opt.mode_pipeline_manager = 'batch';
    pipeline_opt.max_queued = 40;
    pipeline_opt.flag_verbose = 0;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.path_logs = [ResultPath '/logs/'];
elseif nargin >= 5
    if ~isfield(pipeline_opt,'flag_verbose')
        pipeline_opt.flag_verbose = 0;
    end
    if ~isfield(pipeline_opt,'flag_pause')
        pipeline_opt.flag_pause = 0;
    end
    if ~isfield(pipeline_opt,'mode')
        pipeline_opt.mode = 'qsub';
        pipeline_opt.qsub_options = '-q all.q';
    end
    if strcmp(pipeline_opt.mode,'qsub') && ~isfield(pipeline_opt,'qsub_options')
        pipeline_opt.qsub_options = '-q all.q';
    end
    if ~isfield(pipeline_opt,'mode_pipeline_manager')
        pipeline_opt.mode_pipeline_manager = 'batch';
    end
    if ~isfield(pipeline_opt,'max_queued')
        pipeline_opt.max_queued = 40;
    end
    if ~isfield(pipeline_opt,'path_logs')
        pipeline_opt.path_logs = [ResultPath '/logs/'];
    end
end
% In any case, The log files of pipeline is in the path specified by 
% variable `ResultPath` 

ResultPath = [ResultPath filesep];
% Generate FA skeleton mask distance map
Job_Name1 = 'g_dismap';
pipeline.(Job_Name1).command           = 'g_dismap( opt.FA_normalized_1mm_cell, opt.Nii_Output_Path, opt.threshold )';
pipeline.(Job_Name1).files_out.files   = g_dismap_FileOut( Job_Name1, ResultPath );
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
        pipeline.(Job_Name2).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName,opt.ResultPath )';
        pipeline.(Job_Name2).files_in.files    = pipeline.(Job_Name1).files_out.files;
        pipeline.(Job_Name2).files_out.files   = g_2skeleton_FileOut_TBSS( DataResultPath,DataPathCell{j,i} );
        pipeline.(Job_Name2).opt.fileName      = DataPathCell{j,i};
        pipeline.(Job_Name2).opt.FA_fileName   = FAPathCell{j};
        pipeline.(Job_Name2).opt.Mean_FA_fileName   = pipeline.(Job_Name1).files_out.files{1};
        pipeline.(Job_Name2).opt.Dst_fileName  = pipeline.(Job_Name1).files_out.files{5};
        pipeline.(Job_Name2).opt.threshold     = Threshold;
        pipeline.(Job_Name2).opt.ResultPath    = DataResultPath;
        pipeline.(Job_Name2).opt.JobName       = Job_Name2;
    end
end

psom_run_pipeline(pipeline,pipeline_opt);
catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' TBSSResultPath filesep 'logs' filesep 'TBSS_pipeline.error']);
end

