function pipeline = g_tracking_pipeline( NativePathCell, tracking_opt, pipeline_opt, FAPathCell, T1orPartitionOfSubjects_PathCell )
%
%__________________________________________________________________________
% SUMMARY OF G_TRACKING_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic
% fiber tracking for any number of subjects
%
% SYNTAX:
% G_TRACKING_PIPELINE( PIPELINE_OPT,TRACKING_OPT,NATIVEPATHCELL,FAPATHCELL,T1ORPARTITIONOFSUBJECTS_PATHCELL )
%__________________________________________________________________________
% INPUTS:
%
% NATIVEPATHCELL
%        (cell of string)
%        when do Deterministic fiber tracking ,it is the input.
%        when do Probabilistic fiber tracking, it is the input of bedpostx.
%
% TRACKING_OPT
%        (struct)
%        options of fiber tracking
%
% PIPELINE_OPT
%        (struct)
%        options of the psom pipeline 
%        please refer to 'Howtouserpsom'
%        address: http://code.google.com/p/psom/wiki/HowToUsePsom
%
% FAPATHCELL
%        (celll of string)
%        element is the path of FA, FA is used for network node definition
%
% T1ORPARTITIONOFSUBJECTS_PATHCELL
%        (cell of string)
%        if user has node definition file for every subject, the element is
%        node definition file for subject 
%        if user doesn't have node definition file for every subject, the
%        element is T1 image for subject
%__________________________________________________________________________
% OUTPUTS:
%
% PIPELINE
%        the pipeline of our jobs
%__________________________________________________________________________
% USAGE:
%
%        1) g_tracking_pipeline( pipeline_opt,tracking_opt,NativePathCell,FAPathCell,T1orPartitionOfSubjects_PathCell )
%        2) g_tracking_pipeline( NativePathCell, tracking_opt, pipeline_opt )
%        3) g_tracking_pipeline( NativePathCell, tracking_opt )
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
% keywords: tracking, pipeline, psom

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
    pipeline_opt.mode = 'qsub';
    pipeline_opt.qsub_options = '-q all.q';
    pipeline_opt.mode_pipeline_manager = 'batch';
    pipeline_opt.max_queued = 100;
    pipeline_opt.flag_verbose = 0;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.path_logs = [pwd filesep 'logs'];
elseif nargin >= 3
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
    if strcmp(pipeline_opt.mode,'qsub') & ~isfield(pipeline_opt,'qsub_options')
        pipeline_opt.qsub_options = '-q all.q';
    end
    if ~isfield(pipeline_opt,'mode_pipeline_manager')
        pipeline_opt.mode_pipeline_manager = 'batch';
    end
    if ~isfield(pipeline_opt,'max_queued')
        pipeline_opt.max_queued = 100;
    end
    if ~isfield(pipeline_opt,'path_logs')
        pipeline_opt.path_logs = [pwd filesep 'logs'];
    end
end 

Option.ImageOrientation = tracking_opt.ImageOrientation;
Option.PropagationAlgorithm = tracking_opt.PropagationAlgorithm;
if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT')
    Option.StepLength = tracking_opt.StepLength;
end
Option.AngleThreshold = tracking_opt.AngleThreshold;
Option.MaskThresMin = tracking_opt.MaskThresMin;
Option.MaskThresMax = tracking_opt.MaskThresMax;
Option.Inversion = tracking_opt.Inversion;
Option.Swap = tracking_opt.Swap;
Option.ApplySplineFilter = tracking_opt.ApplySplineFilter;
Option.PartitionOfSubjects = tracking_opt.PartitionOfSubjects;
Option.T1 = tracking_opt.T1;
if tracking_opt.DterminFiberTracking == 1
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(i, '%05.0f');
        % tracking       
        Job_Name1 = [ 'DeterministicTracking_' Number_Of_Subject_String ];
        pipeline.(Job_Name1).command           = 'g_DeterministicTracking( opt.NativeFolderPath,opt.tracking_opt,opt.Prefix )';
        pipeline.(Job_Name1).files_in.files{1} = [NativePathCell{i} filesep 'bvecs'];
        pipeline.(Job_Name1).files_in.files{2} = [NativePathCell{i} filesep 'bvals'];
        pipeline.(Job_Name1).files_in.files{3} = [NativePathCell{i} filesep 'data.nii.gz'];
        pipeline.(Job_Name1).files_in.files{4} = [NativePathCell{i} filesep 'nodif_brain_mask.nii.gz'];
        if NativePathCell{i}(end) == '/'
            NativePathCell{i} = NativePathCell{i}(1:end - 1);
        end
        pipeline.(Job_Name1).files_out.files   = g_DeterministicTracking_FileOut_Tracking( NativePathCell{i}, Option, Number_Of_Subject_String );
        pipeline.(Job_Name1).opt.NativeFolderPath    = NativePathCell{i};
        pipeline.(Job_Name1).opt.Prefix              = Number_Of_Subject_String;
        pipeline.(Job_Name1).opt.tracking_opt        = Option;
    end
end
if tracking_opt.NetworkNode == 1 & ~tracking_opt.PartitionOfSubjects  
    for i = 1:length(FAPathCell)
        Number_Of_Subject_String = num2str(i, '%05.0f');
        % Network Node Definition 
        Job_Name2 = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
        pipeline.(Job_Name2).command           = 'g_PartitionTemplate2FA( opt.FA_Path,opt.T1_Path,opt.PartitionTemplate )';
        pipeline.(Job_Name2).files_in.files{1} = FAPathCell{i};
        pipeline.(Job_Name2).files_in.files{2} = T1orPartitionOfSubjects_PathCell{i};
        pipeline.(Job_Name2).files_out.files   = g_PartitionTemplate2FA_FileOut_Tracking( FAPathCell{i},tracking_opt.PartitionTemplate );
        pipeline.(Job_Name2).opt.FA_Path       = FAPathCell{i};
        pipeline.(Job_Name2).opt.T1_Path       = T1orPartitionOfSubjects_PathCell{i};
        pipeline.(Job_Name2).opt.PartitionTemplate   = tracking_opt.PartitionTemplate;
    end
end
if tracking_opt.DeterministicNetwork == 1;
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(i, '%05.0f');
        % Deterministic Network
        Job_Name3 = [ 'FiberNumMatrix_',Number_Of_Subject_String ];
        pipeline.(Job_Name3).command           = 'g_FiberNumMatrix( opt.trackfilepath,opt.T1toFA_PartitionTemplate,opt.FAfilepath )';
        if ~tracking_opt.PartitionOfSubjects 
            PartitionTemplate2FA_Name = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
            pipeline.(Job_Name3).files_in.files1   = pipeline.(PartitionTemplate2FA_Name).files_out;
        end
        tracking_Name = [ 'DeterministicTracking_' Number_Of_Subject_String ];
        pipeline.(Job_Name3).files_in.files2   = pipeline.(tracking_Name).files_out;
        if tracking_opt.PartitionOfSubjects  
            pipeline.(Job_Name3).files_out.files   = g_FiberNumMatrix_FileOut_Tracking( NativePathCell{i},Option,T1orPartitionOfSubjects_PathCell{i},Number_Of_Subject_String );
        else
            pipeline.(Job_Name3).files_out.files   = g_FiberNumMatrix_FileOut_Tracking( NativePathCell{i},Option,tracking_opt.PartitionTemplate,Number_Of_Subject_String );
        end
        pipeline.(Job_Name3).opt.trackfilepath = pipeline.(tracking_Name).files_out.files{16};
        if tracking_opt.PartitionOfSubjects 
            pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = T1orPartitionOfSubjects_PathCell{i};
        else
            pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = pipeline.(PartitionTemplate2FA_Name).files_out.files{1};
        end
        pipeline.(Job_Name3).opt.FAfilepath = FAPathCell{i};
    end
end

if tracking_opt.BedpostxProbabilisticNetwork == 1
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(i, '%05.0f');
        % Bedpostx 
        Job_Name4 = [ 'BedpostX_preproc_',Number_Of_Subject_String ];
        pipeline.(Job_Name4).command = 'g_bedpostX_preproc( opt.NativeFolder )';
        merge_Name = [ 'merge_' Number_Of_Subject_String ];
        pipeline.(Job_Name4).files_in.files = {};
        pipeline.(Job_Name4).files_out.files = g_bedpostX_preproc_FileOut( NativePathCell{i} );
        pipeline.(Job_Name4).opt.NativeFolder = NativePathCell{i};
        
        BedpostxFolder = [NativePathCell{i} '.bedpostX'];
        for BedpostXJobNum = 1:10
            Job_Name5 = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(BedpostXJobNum, '%02.0f') ];
            pipeline.(Job_Name5).command = 'g_bedpostX( opt.NativeFolder, opt.BedpostXJobNum, opt.Fibers, opt.Weight, opt.Burnin )';
            pipeline.(Job_Name5).files_in.files = pipeline.(Job_Name4).files_out.files;
            pipeline.(Job_Name5).files_out.files = g_bedpostX_FileOut(BedpostxFolder, BedpostXJobNum);
            pipeline.(Job_Name5).opt.NativeFolder = NativePathCell{i};
            pipeline.(Job_Name5).opt.BedpostXJobNum = BedpostXJobNum;
            pipeline.(Job_Name5).opt.Weight = tracking_opt.Weight;
            pipeline.(Job_Name5).opt.Burnin = tracking_opt.Burnin;
            pipeline.(Job_Name5).opt.Fibers = tracking_opt.Fibers;
        end
        
        Job_Name6 = [ 'BedpostX_postproc_' Number_Of_Subject_String ];
        pipeline.(Job_Name6).command = 'g_bedpostX_postproc( opt.BedpostxFolder, opt.Fibers )';
        for j = 1:10
            Job_Name = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(j, '%02.0f') ];
            pipeline.(Job_Name6).files_in.files{j} = pipeline.(Job_Name).files_out.files{1};
        end
        pipeline.(Job_Name6).files_out.files = g_bedpostX_postproc_FileOut( BedpostxFolder );
        pipeline.(Job_Name6).opt.BedpostxFolder = BedpostxFolder;
        pipeline.(Job_Name6).opt.Fibers = tracking_opt.Fibers;
    end
end

if tracking_opt.ProbabilisticNetwork | tracking_opt.BedpostxProbabilisticNetwork
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(i, '%05.0f');
        [SubjectFolder, b, c] = fileparts(NativePathCell{i});
        % Probabilistic Network
        ProbabilisticFolder = [SubjectFolder filesep 'Network' filesep 'Probabilistic']; 
        Job_Name7 = [ 'ProbabilisticNetworkpre_',Number_Of_Subject_String ];
        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
            pipeline.(Job_Name7).command        = 'g_OPDtrackNETpre( opt.LabelFile, opt.LabelVector, opt.ResultantFolder )';
        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
            pipeline.(Job_Name7).command        = 'g_PDtrackNETpre( opt.LabelFile, opt.LabelVector, opt.ResultantFolder )';
        end
        if tracking_opt.BedpostxProbabilisticNetwork
            Bedpostx_Name = [ 'BedpostX_postproc_' Number_Of_Subject_String ];
            pipeline.(Job_Name7).files_in.files = pipeline.(Bedpostx_Name).files_out.files;
        else
            pipeline.(Job_Name7).files_in.files = NativePathCell{i};
        end
        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
            pipeline.(Job_Name7).files_out.files   = g_OPDtrackNETpre_FileOut( ProbabilisticFolder, tracking_opt.LabelIdVector );
        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
            pipeline.(Job_Name7).files_out.files   = g_PDtrackNETpre_FileOut( ProbabilisticFolder, tracking_opt.LabelIdVector );
        end
        if tracking_opt.PartitionOfSubjects
            pipeline.(Job_Name7).opt.LabelFile   = T1orPartitionOfSubjects_PathCell{i};
        else
            PartitionTemplate2FA_Name = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
            pipeline.(Job_Name7).files_in.Labelfiles  = pipeline.(PartitionTemplate2FA_Name).files_out.files;
            pipeline.(Job_Name7).opt.LabelFile   = pipeline.(PartitionTemplate2FA_Name).files_out.files{1};
        end
        pipeline.(Job_Name7).opt.LabelVector     = tracking_opt.LabelIdVector;
        pipeline.(Job_Name7).opt.ResultantFolder = ProbabilisticFolder;
        
        for j = 1:length(tracking_opt.LabelIdVector)
            LabelSeedFileName = pipeline.(Job_Name7).files_out.files{2 * j};
            LabelTermFileName = pipeline.(Job_Name7).files_out.files{2 * j + 1};
            Job_Name8 = [ 'ProbabilisticNetwork_' Number_Of_Subject_String '_' num2str(j, '%02d')];
            if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
                pipeline.(Job_Name8).command        = 'g_OPDtrackNET( opt.BedostxFolder, opt.LabelSeedFileName, opt.LabelTermFileName, opt.TargetsTxtFileName, opt.JobName )';
            elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
                pipeline.(Job_Name8).command        = 'g_PDtrackNET( opt.BedostxFolder, opt.LabelSeedFileName, opt.LabelTermFileName, opt.TargetsTxtFileName, opt.JobName )';
            end
            ProbabilisticNetworkPre_Name = [ 'ProbabilisticNetworkpre_',Number_Of_Subject_String ];
            pipeline.(Job_Name8).files_in.files{1} = pipeline.(Job_Name7).files_out.files{1};
            pipeline.(Job_Name8).files_in.files{2} = LabelSeedFileName;
            pipeline.(Job_Name8).files_in.files{3} = LabelTermFileName;
            if tracking_opt.BedpostxProbabilisticNetwork
                BedpostxFolder = [ NativePathCell{i} '.bedpostX'];
            elseif tracking_opt.ProbabilisticNetwork
                BedpostxFolder = NativePathCell{i};
            end
            pipeline.(Job_Name8).files_out.files   = g_OPDtrackNET_FileOut( LabelSeedFileName, Job_Name8 );
            pipeline.(Job_Name8).opt.BedostxFolder = BedpostxFolder;  
            pipeline.(Job_Name8).opt.LabelSeedFileName = LabelSeedFileName;
            pipeline.(Job_Name8).opt.LabelTermFileName = LabelTermFileName;
            pipeline.(Job_Name8).opt.TargetsTxtFileName = pipeline.(Job_Name7).files_out.files{1};
            pipeline.(Job_Name8).opt.JobName = Job_Name8;
        end
        
        Job_Name9 = [ 'ProbabilisticNetworkpost_' Number_Of_Subject_String ];
        pipeline.(Job_Name9).command        = 'g_track4NETpost_fdt( opt.seed, opt.fdt, opt.prefix )';
        for j = 1:length(tracking_opt.LabelIdVector)
            Job_Name = [ 'ProbabilisticNetwork_' Number_Of_Subject_String '_' num2str(j, '%02d')];
            pipeline.(Job_Name9).files_in{j}       = pipeline.(Job_Name).files_out.files{1};
        end
        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
            for id = 1:length(tracking_opt.LabelIdVector)
                pipeline.(Job_Name9).opt.seed{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                           '_OPDtrackNET' filesep 'Label' num2str(tracking_opt.LabelIdVector(id), '%02.0f') '_SeedMask.nii.gz' ];
                pipeline.(Job_Name9).opt.fdt{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                           '_OPDtrackNET' filesep 'fdt_paths.nii.gz' ];
            end
        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
            for id = 1:length(tracking_opt.LabelIdVector)
                pipeline.(Job_Name9).opt.seed{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                           '_PDtrackNET' filesep 'Label' num2str(tracking_opt.LabelIdVector(id), '%02.0f') '_SeedMask.nii.gz' ];
                pipeline.(Job_Name9).opt.fdt{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                           '_PDtrackNET' filesep 'fdt_paths.nii.gz' ];
            end
        end
        pipeline.(Job_Name9).files_out = g_track4NETpost_fdt_FileOut( NativePathCell{i}, Number_Of_Subject_String );
        pipeline.(Job_Name9).opt.prefix = Number_Of_Subject_String;
    end
end

psom_run_pipeline(pipeline,pipeline_opt);

catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    disp(['touch ' pipeline_opt.path_logs filesep 'tracking_pipeline.error']);
    system(['touch ' pipeline_opt.path_logs filesep 'tracking_pipeline.error']);
end

