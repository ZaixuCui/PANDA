function pipeline = g_BrainParcellation_pipeline(FAPathCell, T1PathCell, PartitionTemplatePath, NetworkNodePipeline_opt)
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX_PIPELINE
% 
% The whole process of brain parcellation for any number of subjects
%
% SYNTAX:
% G_BRAINPARCELLATION_PIPELINE( FAPATHCELL, T1PATHCELL, PARTITIONTEMPLATEPATH, NETWORKNODEPIPELINE_OPT )
%__________________________________________________________________________
% INPUTS:
%
% FAPATHCELL
%        (cell of string)
%        the member of the cell is the path of FA of one subject
%
% T1PATHCELL
%        (cell of string)
%        the member of the cell is the path of T1 of one subject
%
% PARTITIONTEMPLATEPATH
%        (struct)
%        the atlas in the standard space
%
% NETWORKNODEPIPELINE_OPT
%        (struct)
%        options of the psom pipeline 
%        please refer to 'Howtouserpsom'
%        address: http://code.google.com/p/psom/wiki/HowToUsePsom     
%__________________________________________________________________________
% OUTPUTS:
%
% PIPELINE
%        the pipeline of our jobs
%__________________________________________________________________________
% USAGE:
%
%        1) g_BrainParcellation_pipeline( FAPathCell, T1PathCell, PartitionTemplatePath, NetworkNodePipeline_opt )
%        2) g_BrainParcellation_pipeline( FAPathCell, T1PathCell, PartitionTemplatePath )
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
% keywords: brain parcellation, pipeline, psom

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

if nargin <= 3
    % The default value of pipeline opt parameters
    NetworkNodePipeline_opt.mode = 'qsub';
    NetworkNodePipeline_opt.qsub_options = '-q all.q';
    NetworkNodePipeline_opt.mode_pipeline_manager = 'batch';
    NetworkNodePipeline_opt.max_queued = 3;
    NetworkNodePipeline_opt.flag_verbose = 0;
    NetworkNodePipeline_opt.flag_pause = 0;
    NetworkNodePipeline_opt.path_logs = [pwd filesep 'logs'];
else
    if ~isfield(NetworkNodePipeline_opt,'flag_verbose')
        NetworkNodePipeline_opt.flag_verbose = 0;
    end
    if ~isfield(NetworkNodePipeline_opt,'flag_pause')
        NetworkNodePipeline_opt.flag_pause = 0;
    end
    if ~isfield(NetworkNodePipeline_opt,'mode')
        NetworkNodePipeline_opt.mode = 'qsub';
        NetworkNodePipeline_opt.qsub_options = '-q all.q';
    end
    if strcmp(NetworkNodePipeline_opt.mode,'qsub') && ~isfield(NetworkNodePipeline_opt,'qsub_options')
        NetworkNodePipeline_opt.qsub_options = '-q all.q';
    end
    if ~isfield(NetworkNodePipeline_opt,'mode_pipeline_manager')
        NetworkNodePipeline_opt.mode_pipeline_manager = 'batch';
    end
    if ~isfield(NetworkNodePipeline_opt,'max_queued')
        NetworkNodePipeline_opt.max_queued = 3;
    end
    if ~isfield(NetworkNodePipeline_opt,'path_logs')
        NetworkNodePipeline_opt.path_logs = [pwd filesep 'logs'];
    end
end

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

psom_run_pipeline(pipeline,NetworkNodePipeline_opt);
catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' NetworkNodePipeline_opt.path_logs filesep 'BrainParcellation_pipeline.error']);
end