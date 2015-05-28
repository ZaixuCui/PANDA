function pipeline = g_BetT1_pipeline( DataRaw_pathCell, index_vector, DataNii_path, prefix, BetT1_opt, T1BetPipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_BETT1_PIPELINE
% 
% The whole process of brain extraction of T1 images for any number of subjects.
%
% SYNTAX:
%
% 1) g_BetT1_pipeline( DataRaw_pathCell, index_vector, DataNii_path, prefix )
% 2) g_BetT1_pipeline( DataRaw_pathCell, index_vector, DataNii_path, prefix, BetT1_opt )
% 3) g_BetT1_pipeline( DataRaw_pathCell, index_vector, DataNii_path, prefix, BetT1_opt, T1BetPipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% DATARAW_PATHCELL
%        (cell of strings) 
%        The input folder cell, each of which includes the dcm/nifti data. 
%
% INDEX_VECTOR
%        (cell of integers) 
%        The order of the subjects.
%        For example: index_vector = [1:5] 
%                     The resultant nii folder for each subject is like 
%                     '/data/Handled_Data/001/'
%
% DATANII_PATH
%        (string) 
%        The path of output folder of nii data for all subjects.
%        For example: '/data/Handled_Data/'
%
% PREFIX
%        (string) 
%        Basename for the output file. 
%
% BETT1_OPT
%        (structure) with the following fields : 
%
%        BetT1_f_threshold
%            (single, default 0.5)
%            Fractional intensity thershold (0->1);
%            smaller values give larger brain outline estimates
%
%        T1Cropping_flag
%            (0 or 1, default 1)
%            The flag whether to crop the T1 image.
%
%        T1CroppingGap
%            (integer, default 3, Only needed when T1Cropping_flag=1)
%            The length from the boundary of the brain in T1 image to the 
%            cube we select.
%
%        T1Resample_Flag
%            (0 or 1, default 1)
%            The flag whether to resample the T1 image.
%
%        T1ResampleResolution
%            (1*3 vector, default [1 1 1])
%            The final voxel size of the resampled T1 image.
%
% T1BETPIPELINE_OPT
%        (structure) with the following fields :
%        
%        mode
%            (string, default )
%            'background' : 
%                Execute with only one computer.
%            'qsub'  : 
%                Execute in a distributed environment such as SGE, PBS. 
%
%        max_queued
%            (integer) The maximum number of jobs that can be processed 
%            simultaneously.
%            ('background' mode) Default value is 'quantity of cores'.
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
    
    psom_gb_vars;
    
    if nargin < 6
        % The default values of pipeline opt parameters
        T1BetPipeline_opt.mode = 'qsub';
        T1BetPipeline_opt.qsub_options = '-q all.q';
        T1BetPipeline_opt.mode_pipeline_manager = 'background';
        T1BetPipeline_opt.max_queued = 100;
        T1BetPipeline_opt.flag_verbose = 0;
        T1BetPipeline_opt.flag_pause = 0;
        T1BetPipeline_opt.path_logs = [DataNii_path filesep 'logs'];
    else
        if ~isfield(T1BetPipeline_opt,'flag_verbose')
            T1BetPipeline_opt.flag_verbose = 0;
        end
        if ~isfield(T1BetPipeline_opt,'flag_pause')
            T1BetPipeline_opt.flag_pause = 0;
        end
        if ~isfield(T1BetPipeline_opt,'mode')
            T1BetPipeline_opt.mode = 'qsub';
            T1BetPipeline_opt.qsub_options = '-q all.q';
        end
        if strcmp(T1BetPipeline_opt.mode,'qsub') && ~isfield(T1BetPipeline_opt,'qsub_options')
            T1BetPipeline_opt.qsub_options = '-q all.q';
        end
        if ~isfield(T1BetPipeline_opt,'mode_pipeline_manager')
            T1BetPipeline_opt.mode_pipeline_manager = 'background';
        end
        if ~isfield(T1BetPipeline_opt,'max_queued')
            T1BetPipeline_opt.max_queued = 3;
        end
        if ~isfield(T1BetPipeline_opt,'path_logs')
            T1BetPipeline_opt.path_logs = [DataNii_path filesep 'logs'];
        end
    end
    
    if nargin < 5
        % The default value of T1 opt parameters
        BetT1_opt.BetT1_f_threshold = 0.5;
        BetT1_opt.T1Cropping_Flag = 1;
        BetT1_opt.T1CroppingGap = 3;
        BetT1_opt.T1Resample_Flag = 1;
        BetT1_opt.T1ResampleResolution = [1 1 1];
    else
        if ~isfield(BetT1_opt, 'BetT1_f_threshold')
            BetT1_opt.BetT1_f_threshold = 0.5;
        end
        if ~isfield(BetT1_opt, 'T1Cropping_Flag')
            BetT1_opt.T1Cropping_Flag = 1;
        end
        if ~isfield(BetT1_opt, 'T1Resample_Flag')
            BetT1_opt.T1Resample_Flag = 1;
        end
        if BetT1_opt.T1Cropping_Flag & ~isfield(BetT1_opt, 'T1CroppingGap')
            BetT1_opt.T1CroppingGap = 3;
        end
        if BetT1_opt.T1Resample_Flag & ~isfield(BetT1_opt, 'T1ResampleResolution')
            BetT1_opt.T1ResampleResolution = [1 1 1];
        end
    end

    for i = 1:length(DataRaw_pathCell)
        
        Number_Of_Subject_String = num2str(index_vector(i), '%05.0f');
        ResultantFolder = [DataNii_path filesep Number_Of_Subject_String filesep 'T1'];
   
        NIfTIFile = g_ls([DataRaw_pathCell{i} filesep '*nii*']);
        
        if ~length(NIfTIFile)
            Job_Name1 = ['dcm2nii_' Number_Of_Subject_String];
            pipeline.(Job_Name1).command            = 'g_T1Dcm2nii( opt.DataRaw_path, opt.index, opt.DataNii_folder, opt.prefix )';
            if prefix
                pipeline.(Job_Name1).files_out.files{1} = [ResultantFolder filesep prefix '_' Number_Of_Subject_String '_t1.nii.gz'];
            else
                pipeline.(Job_Name1).files_out.files{1} = [ResultantFolder filesep Number_Of_Subject_String '_t1.nii.gz'];
            end
            pipeline.(Job_Name1).opt.DataRaw_path = DataRaw_pathCell{i}; 
            pipeline.(Job_Name1).opt.index = index_vector(i); 
            pipeline.(Job_Name1).opt.DataNii_folder   = ResultantFolder;
            pipeline.(Job_Name1).opt.prefix         = prefix;
        else
            Job_Name1 = ['CopyT1_' Number_Of_Subject_String];
            pipeline.(Job_Name1).command            = 'copyfile(opt.T1_NIfTI, files_out.files{1})';
            pipeline.(Job_Name1).opt.T1_NIfTI = NIfTIFile{1}; 
            if prefix
                pipeline.(Job_Name1).files_out.files{1} = [ResultantFolder filesep prefix '_' Number_Of_Subject_String '_t1.nii.gz'];
            else
                pipeline.(Job_Name1).files_out.files{1} = [ResultantFolder filesep Number_Of_Subject_String '_t1.nii.gz'];
            end
        end
        
        Job_Name2 = ['BetT1_' Number_Of_Subject_String];
        pipeline.(Job_Name2).command            = 'g_BetT1( files_in.files{1}, opt.bet_f )';
        pipeline.(Job_Name2).files_in.files     = pipeline.(Job_Name1).files_out.files;
        if prefix
            pipeline.(Job_Name2).files_out.files{1} = [ResultantFolder filesep prefix '_' Number_Of_Subject_String '_t1_swap_bet.nii.gz'];
        else
            pipeline.(Job_Name2).files_out.files{1} = [ResultantFolder filesep Number_Of_Subject_String '_t1_swap_bet.nii.gz'];
        end
        pipeline.(Job_Name2).opt.bet_f          = BetT1_opt.BetT1_f_threshold;
        
        if prefix
            NewT1PathPrefix = [ResultantFolder filesep prefix '_' Number_Of_Subject_String '_t1_swap_bet'];
        else
            NewT1PathPrefix = [ResultantFolder filesep Number_Of_Subject_String '_t1_swap_bet'];
        end
        
        if BetT1_opt.T1Cropping_Flag
            Job_Name3 = ['T1Cropped_' Number_Of_Subject_String];
            pipeline.(Job_Name3).command            = 'g_T1Cropped( files_in.files{1}, opt.T1CroppingGap )';
            pipeline.(Job_Name3).files_in.files     = pipeline.(Job_Name2).files_out.files;
            if prefix
                pipeline.(Job_Name3).files_out.files{1} = [ResultantFolder filesep prefix '_' Number_Of_Subject_String '_t1_swap_bet_crop.nii.gz'];
                NewT1PathPrefix = [ResultantFolder filesep prefix '_' Number_Of_Subject_String '_t1_swap_bet_crop'];
            else
                pipeline.(Job_Name3).files_out.files{1} = [ResultantFolder filesep Number_Of_Subject_String '_t1_swap_bet_crop.nii.gz'];
                NewT1PathPrefix = [ResultantFolder filesep Number_Of_Subject_String '_t1_swap_bet_crop'];
            end
            pipeline.(Job_Name3).opt.T1CroppingGap  = BetT1_opt.T1CroppingGap;
        end
        
        if BetT1_opt.T1Resample_Flag
            Job_Name4 = ['T1Resample_' Number_Of_Subject_String];
            pipeline.(Job_Name4).command            = 'g_resample_nii( opt.T1_Path, opt.ResampleResolution, files_out.files{1} )';
            if BetT1_opt.T1Cropping_Flag
                pipeline.(Job_Name4).files_in.files = pipeline.(Job_Name3).files_out.files;
                pipeline.(Job_Name4).opt.T1_Path    = pipeline.(Job_Name3).files_out.files{1};
            else
                pipeline.(Job_Name4).files_in.files = pipeline.(Job_Name2).files_out.files;
                pipeline.(Job_Name4).opt.T1_Path    = pipeline.(Job_Name2).files_out.files{1};  
            end
            pipeline.(Job_Name4).opt.ResampleResolution = BetT1_opt.T1ResampleResolution;  
            pipeline.(Job_Name4).files_out.files{1} = [NewT1PathPrefix '_resample.nii.gz'];
        end
    end

    psom_run_pipeline(pipeline,T1BetPipeline_opt);

catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' T1BetPipeline_opt.path_logs filesep 'T1Bet_pipeline.error']);
end
