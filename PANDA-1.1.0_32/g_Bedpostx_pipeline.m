function pipeline = g_Bedpostx_pipeline( NativePathCellBedpostx, BedpostxAlone_opt, BedpostxPipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic
% fiber tracking for any number of subjects
%
% SYNTAX:
% G_BEDPOSTX_PIPELINE( NATIVEPATHCELLBEDPOSTX, BEDPOSTXALONE_OPT, BEDPOSTXPIPELINE_OPT )
%__________________________________________________________________________
% INPUTS:
%
% NATIVEPATHCELLBEDPOSTX
%        (cell of string)
%        the member of the cell is the path of a folder which contains
%        data, nodif_mask, bvals, bvecs
%
% BEDPOSTXPIPELINE_OPT
%        (struct)
%        options of the psom pipeline 
%        please refer to 'Howtouserpsom'
%        address: http://code.google.com/p/psom/wiki/HowToUsePsom
%
% BEDPOSTXALONE_OPT
%        (struct)
%        options of fiber bedpostx
%       
%__________________________________________________________________________
% OUTPUTS:
%
% PIPELINE
%        the pipeline of our jobs
%__________________________________________________________________________
% USAGE:
%
%        1) g_Bedpostx_Pipeline( NativePathCellBedpostx, BedpostxAlone_opt, BedpostxPipeline_opt )
%        2) g_Bedpostx_Pipeline( NativePathCellBedpostx,BedpostxAlone_opt )
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
% keywords: bedpostx, pipeline, psom

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

if nargin <= 2
    % The default value of pipeline opt parameters
    BedpostxPipeline_opt.mode = 'qsub';
    BedpostxPipeline_opt.qsub_options = '-q all.q';
    BedpostxPipeline_opt.mode_pipeline_manager = 'batch';
    BedpostxPipeline_opt.max_queued = 40;
    BedpostxPipeline_opt.flag_verbose = 0;
    BedpostxPipeline_opt.flag_pause = 0;
    BedpostxPipeline_opt.path_logs = [pwd filesep 'logs'];
else
    if ~isfield(BedpostxPipeline_opt,'flag_verbose')
        BedpostxPipeline_opt.flag_verbose = 0;
    end
    if ~isfield(BedpostxPipeline_opt,'flag_pause')
        BedpostxPipeline_opt.flag_pause = 0;
    end
    if ~isfield(BedpostxPipeline_opt,'mode')
        BedpostxPipeline_opt.mode = 'qsub';
        BedpostxPipeline_opt.qsub_options = '-q all.q';
    end
    if strcmp(BedpostxPipeline_opt.mode,'qsub') && ~isfield(BedpostxPipeline_opt,'qsub_options')
        BedpostxPipeline_opt.qsub_options = '-q all.q';
    end
    if ~isfield(BedpostxPipeline_opt,'mode_pipeline_manager')
        BedpostxPipeline_opt.mode_pipeline_manager = 'batch';
    end
    if ~isfield(BedpostxPipeline_opt,'max_queued')
        BedpostxPipeline_opt.max_queued = 40;
    end
    if ~isfield(BedpostxPipeline_opt,'path_logs')
        BedpostxPipeline_opt.path_logs = [pwd filesep 'logs'];
    end
end

for i = 1:length(NativePathCellBedpostx)
    Number_Of_Subject_String = num2str(i, '%05.0f');
    
    Job_Name1 = [ 'BedpostX_preproc_',Number_Of_Subject_String ];
    pipeline.(Job_Name1).command = 'g_bedpostX_preproc( opt.NativeFolder )';
    merge_Name = [ 'merge_' Number_Of_Subject_String ];
    pipeline.(Job_Name1).files_in.files = {};
    pipeline.(Job_Name1).files_out.files = g_bedpostX_preproc_FileOut( NativePathCellBedpostx{i} );
    pipeline.(Job_Name1).opt.NativeFolder = NativePathCellBedpostx{i};
    
    BedpostxFolder = [NativePathCellBedpostx{i} '.bedpostX'];
    for BedpostXJobNum = 1:10
        Job_Name2 = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(BedpostXJobNum, '%02.0f') ];
        pipeline.(Job_Name2).command = 'g_bedpostX( opt.NativeFolder, opt.BedpostXJobNum, opt.Fibers, opt.Weight, opt.Burnin )';
        pipeline.(Job_Name2).files_in.files = pipeline.(Job_Name1).files_out.files;
        pipeline.(Job_Name2).files_out.files = g_bedpostX_FileOut(BedpostxFolder, BedpostXJobNum);
        pipeline.(Job_Name2).opt.NativeFolder = NativePathCellBedpostx{i};
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

psom_run_pipeline(pipeline,BedpostxPipeline_opt);
catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' BedpostxPipeline_opt.path_logs filesep 'BedpostX_pipeline.error']);
end

