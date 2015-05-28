function pipeline = g_tracking_pipeline( NativePathCell, SubjectIDArray, tracking_opt, pipeline_opt, FAPathCell, T1orPartitionOfSubjects_PathCell )
%
%__________________________________________________________________________
% SUMMARY OF G_TRACKING_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic
% fiber tracking for any number of subjects
%
% SYNTAX:
%
% 1) g_tracking_pipeline( NativePathCell, SubjectIDArray, tracking_opt )
% 2) g_tracking_pipeline( NativePathCell, SubjectIDArray, tracking_opt, pipeline_opt )
% 3) g_tracking_pipeline( NativePathCell, SubjectIDArray, tracking_opt, pipeline_opt, FAPathCell, T1orPartitionOfSubjects_PathCell )
%__________________________________________________________________________
% INPUTS:
%
% NATIVEPATHCELL
%        (cell of strings)
%        Input folder cell, there are two possibilities of each cell :
%        1) Full path of a folder containing four files as listed, if 
%           do deterministic fiber tracking, deterministic network 
%           construction and bedpostx & probabilistic network construction.
%           (1) A 4D image named data.nii.gz containing diffusion-weighted 
%               volumes and volumes without diffusion weighting.
%           (2) A 3D binary brain mask volume named 
%               nodif_brain_mask.nii.gz.
%           (3) A text file named bvecs containing gradient directions for 
%               diffusion weighted volumes.
%           (4) A text file named bvals containing b-values applied for 
%               each volume acquisition.
%        2) Full path of the bedpostx resultant folder, if do probabilitisc
%           network construction without bedpostx
%
% TRACKING_OPT
%        (structure) with the following fields :
%
%        DeterminFiberTracking
%            (integer, 0 or 1, default 0)
%            Select whether to do deterministic fiber tracking.
%            1 : Do deterministic fiber tracking.
%
%           [If DeterminFiberTracking = 1, the fields of tracking_opt as 
%           listed should be set.]
%           ImageOrientation
%               (string, default 'Auto')
%               Four selections: 'Auto'
%                                'Axial'
%                                'Coronal'
%                                'Sagittal'
%            
%           PropagationAlgorithm
%               (string, default 'FACT')
%               Four selections: 'FACT'
%                                '2nd-order Runge Kutta'
%                                'Interpolated Streamline'
%                                'Tensorline'
%
%           StepLength
%               (float) 
%               Default 0.1 for '2nd-order Runge Kutta' & 'Tensorline'. 
%               Default 0.5 for 'Interpolated Streamline'.
%
%           AngleThreshold
%               (integer, default 35)
%               Stop tracking when the angle of the corner is larger than 
%               the threshold.
%
%           MaskThresMin
%               (float, default 0.1)
%               The lower bound of FA threshold, tracking will be stopped 
%               if FA is lower than this value.
%
%           MaskThresMax
%               (float, default 1)
%               The upper bound of FA threshold, tracking will be stopped 
%               if FA is larger than this value.
%
%           Inversion
%               (string, default 'No Inversion')
%               Four selections: 'No Inversion'
%                                'Invert X'
%                                'Invert Y'
%                                'Invert Z'
%
%           Swap
%               (string, default 'No Swap')
%               Four selections: 'No Swap' 
%                                'Swap X/Y'  
%                                'Swap Y/Z'
%                                'Swap Z/X'
%
%           ApplySplineFilter
%               (string, 'Yes' or 'No', default 'Yes')
%               'Yes' : Apply apline filter.
%               Select whether to smooth & clean up the original track file.
%
%        NetworkNode
%            (integer, 0 or 1, default 0)
%            Select whether to do network node definition.
%            Only needed when doing network construction. 
%            1 : Do network node definition.
%
%            [If NetworkNode = 1, the fields of tracking_opt as listed 
%            should be set.]       
%            PartitionOfSubjects
%                (integer, 0 or 1,default 0, only needed when NetworkNode 
%                is 1)
%                1 : Use subjects' parcellated images in native space to 
%                define network nodes.
%
%            T1
%                (integer, only needed when NetworkNode is 1, 0 or 1,
%                default 0)
%                1 : Use subjects' T1 images to define network nodes.
%
%            PartitionTemplate
%                (string, only needed when T1 is 1, default AAL atlas with 
%                116 regions)
%                The full path of gray matter altas in standard space.
%
%        DeterministicNetwork
%            (integer, 0 or 1, default 0)
%            1 : Do deterministic network construction.
%            [If DeterministicNetwork is 1, DeterminFiberTracking and 
%            NetworkNode fields of tracking_opt must be 1 first.]
%
%        BedpostxProbabilisticNetwork
%            (integer, 0 or 1, default 0)
%            1 : Do bedpostx & probabilistic network construction.
%            [If BedpostxProbabilisticNetwork is 1, NetworkNode field of 
%            tracking_opt must be 1 first.]
%
%            [If BedpostxProbabilisticNetwork is 1, the fields of 
%            tracking_opt as listed should be set.]
%
%            Weight
%                (integer, default 1)
%                ARD weight, more weight means less secondary fibers per 
%                voxel.
%
%            Burnin
%                (integer, default 1000)
%                Brunin period.
%
%            Fibers
%                (integer, default 2)
%                Number of fibers per voxel.
%
%        ProbabilisticNetwork
%            (integer, 0 or 1, default 0)
%            1 : Do probabilistic network construction without bedpostx.
%            [If ProbabilisticNetwork is 1, NetworkNode field of 
%            tracking_opt must be 1 first.]
%
%            
%            [If BedpostxProbabilisticNetwork or ProbabilisticNetwork is 1, 
%            the fields of tracking_opt as listed should be set.]
%
%            LabelIdVector
%                (vector)
%                The ID of brain regions in atlas user interests.
%                For example: [1:90]
%
%            ProbabilisticTrackingType
%                (string, default 'OPD')
%                'OPD' : Output path distribution.
%                'PD' : Correct path distribution for the length of the
%                pathways and output path distribution.
%
% [Only one of DeterministicNetwork, BedpostxProbabilisticNetwork, and 
% ProbabilisticNetwork fields of tracking_opt can be 1 simultaneously.]
%
% PIPELINE_OPT
%        If pipeline_opt = 'default', then the default values will be
%        assigned to all its fields.
%
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
%
% FAPathCell
%        (cell of strings, only needed when tracking_opt.NetworkNode is 1)
%        Input file cell, each of which is full path of original FA 
%        calculated by dtifit.
%
% T1orPartitionOfSubjects_PathCell
%        (cell of strings, only needed when tracking_opt.NetworkNode is 1)
%        There are 2 possibilities under each cell:
%        (1) If tracking_opt.PartitionOfSubjects = 1, full path of 
%        subject's parcellated image in native space.
%        (2) If tracking_opt.T1 = 1, full path of subject's T1 image.
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
pipeline = '';
if nargin < 4
    % The default value of pipeline opt parameters
    pipeline_opt.mode = 'qsub';
    pipeline_opt.qsub_options = '-q all.q';
    pipeline_opt.mode_pipeline_manager = 'background';
    pipeline_opt.max_queued = 100;
    pipeline_opt.flag_verbose = 0;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.path_logs = [pwd filesep 'Tracking_logs'];
else
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
        pipeline_opt.mode_pipeline_manager = 'background';
    end
    if ~isfield(pipeline_opt,'max_queued')
        pipeline_opt.max_queued = 100;
    end
    if ~isfield(pipeline_opt,'path_logs')
        pipeline_opt.path_logs = [pwd filesep 'Tracking_logs'];
    end
end 

Option.ImageOrientation = tracking_opt.ImageOrientation;
Option.PropagationAlgorithm = tracking_opt.PropagationAlgorithm;
if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT')
    Option.StepLength = tracking_opt.StepLength;
end
Option.AngleThreshold = str2num(tracking_opt.AngleThreshold);
Option.MaskThresMin = tracking_opt.MaskThresMin;
Option.MaskThresMax = tracking_opt.MaskThresMax;
Option.Inversion = tracking_opt.Inversion;
Option.Swap = tracking_opt.Swap;
Option.ApplySplineFilter = tracking_opt.ApplySplineFilter;
Option.RandomSeed_Flag = tracking_opt.RandomSeed_Flag;
if tracking_opt.RandomSeed_Flag
    Option.RandomSeed = tracking_opt.RandomSeed;
end

if tracking_opt.DterminFiberTracking == 1
    
    for i = 1:length(NativePathCell)
        DeterministicTrackingResultExist(i) = 1;
    end
    
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(SubjectIDArray(i), '%05.0f');
        if NativePathCell{i}(end) == filesep
            NativePathCell{i}(end) = '';
        end
        DeterministicTrackingOutput{i} = g_DeterministicTracking_FileOut_Tracking( NativePathCell{i}, Option, Number_Of_Subject_String );
        if ~exist(DeterministicTrackingOutput{i}{1}, 'file')
            DeterministicTrackingResultExist(i) = 0;
        end
        if strcmp(Option.ApplySplineFilter, 'Yes')
            if ~exist(DeterministicTrackingOutput{i}{2}, 'file')
                DeterministicTrackingResultExist(i) = 0;
            end
        end
        if tracking_opt.DeterminTrackingOptionChange
            DeterministicTrackingResultExist(i) = 0;
        end
        
        if ~DeterministicTrackingResultExist(i)
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
            pipeline.(Job_Name1).files_out.files   = DeterministicTrackingOutput{i};
            pipeline.(Job_Name1).opt.NativeFolderPath    = NativePathCell{i};
            pipeline.(Job_Name1).opt.Prefix              = Number_Of_Subject_String;
            pipeline.(Job_Name1).opt.tracking_opt        = Option;
        end
    end
    
    save([pipeline_opt.path_logs filesep 'DeterministicTrackingResultExist.mat'], 'DeterministicTrackingResultExist');
end

if tracking_opt.NetworkNode == 1 & ~tracking_opt.PartitionOfSubjects  
    for i = 1:length(FAPathCell)
        
        % Network Node Definition 
       
        Number_Of_Subject_String = num2str(SubjectIDArray(i), '%05.0f');
        [NativeFolder, FAFileName, FASuffix] = fileparts(FAPathCell{i}); 
        if strcmp(FASuffix, '.gz')
            [a, FAFileName, c] = fileparts(FAFileName);
        end
        [SubjectFolder, b, c] = fileparts(NativeFolder);
        T1Folder = [SubjectFolder filesep 'T1'];
        [T1ParentFolder, T1FileName, T1Suffix] = fileparts(T1orPartitionOfSubjects_PathCell{i});
        if strcmp(T1Suffix, '.gz')
            NewT1PathPrefix = [T1Folder filesep T1FileName(1:end - 4)];
            T1FileName = T1FileName(1:end - 4);
        elseif strcmp(T1Suffix, '.nii')
            NewT1PathPrefix = [T1Folder filesep T1FileName];
        else
            error('Not a .nii or .nii.gz file.');
        end
        
        if tracking_opt.T1Bet_Flag
            NewT1PathPrefix = [NewT1PathPrefix '_swap_bet'];
        end
        
        if tracking_opt.T1Cropping_Flag
            T1toFAMat = [NewT1PathPrefix '_crop_resample_2FA.mat'];
            if tracking_opt.T1Resample_Flag
                T1toMNI152_warp_inv = [NewT1PathPrefix '_crop_resample_2MNI152_warp_inv.nii.gz'];
            else
                T1toMNI152_warp_inv = [NewT1PathPrefix '_crop_2MNI152_warp_inv.nii.gz'];
            end
        else
            T1toFAMat = [NewT1PathPrefix '_resample_2FA.mat'];
            if tracking_opt.T1Resample_Flag
                T1toMNI152_warp_inv = [NewT1PathPrefix '_resample_2MNI152_warp_inv.nii.gz'];
            else
                T1toMNI152_warp_inv = [NewT1PathPrefix '_2MNI152_warp_inv.nii.gz'];
            end
        end
        
        Job_Name11 = [ 'CopyT1_' Number_Of_Subject_String ];
        pipeline.(Job_Name11).command         = 'if ~strcmp(opt.T1ParentFolder,opt.T1Path);if ~exist(opt.T1Folder);mkdir(opt.T1Folder);end;system([''cp '' opt.T1Path '' '' opt.T1Folder]);end;';
        if strcmp(T1Suffix, '.gz')
            pipeline.(Job_Name11).files_out.files{1} = [T1Folder filesep T1FileName '.nii' T1Suffix];
        else
            pipeline.(Job_Name11).files_out.files{1} = [T1Folder filesep T1FileName T1Suffix];
        end
        pipeline.(Job_Name11).opt.T1Folder = T1Folder;
        pipeline.(Job_Name11).opt.T1ParentFolder = T1ParentFolder;
        pipeline.(Job_Name11).opt.T1Path = T1orPartitionOfSubjects_PathCell{i};
        
        if tracking_opt.T1Bet_Flag
            Job_Name12 = [ 'BetT1_' Number_Of_Subject_String ];
            pipeline.(Job_Name12).command            = 'g_BetT1( opt.DataRaw_path, opt.bet_f )';
            pipeline.(Job_Name12).files_in.files     = pipeline.(Job_Name11).files_out.files;
            pipeline.(Job_Name12).files_out.files{1} = [T1Folder filesep T1FileName '_swap_bet.nii.gz'];
            pipeline.(Job_Name12).opt.DataRaw_path  = pipeline.(Job_Name11).files_out.files{1}; 
            pipeline.(Job_Name12).opt.bet_f         = tracking_opt.T1BetF;
        end
        
        if tracking_opt.T1Cropping_Flag
            Job_Name13 = ['T1Cropped_' Number_Of_Subject_String];
            pipeline.(Job_Name13).command            = 'g_T1Cropped( opt.T1FilePath, opt.T1CroppingGap )';
            if tracking_opt.T1Bet_Flag
                pipeline.(Job_Name13).files_in.files = pipeline.(Job_Name12).files_out.files;
                pipeline.(Job_Name13).opt.T1FilePath = [T1Folder filesep T1FileName '_swap_bet.nii.gz'];
            else
                pipeline.(Job_Name13).files_in.files = pipeline.(Job_Name11).files_out.files;
                pipeline.(Job_Name13).opt.T1FilePath = [T1Folder filesep T1FileName '.nii.gz'];
            end
            pipeline.(Job_Name13).files_out.files{1} = [NewT1PathPrefix '_crop.nii.gz'];
            pipeline.(Job_Name13).opt.T1CroppingGap  = tracking_opt.T1CroppingGap;
            
            NewT1PathPrefix = [NewT1PathPrefix '_crop'];
        end
        
        if tracking_opt.T1Resample_Flag
            Job_Name14 = ['T1Resample_' Number_Of_Subject_String];
            pipeline.(Job_Name14).command            = 'g_resample_nii( opt.T1_Path, [1 1 1], files_out.files{1} )';
            if tracking_opt.T1Cropping_Flag
                pipeline.(Job_Name14).files_in.files = pipeline.(Job_Name13).files_out.files;
                pipeline.(Job_Name14).opt.T1_Path    = pipeline.(Job_Name13).files_out.files{1};
            else
                pipeline.(Job_Name14).files_in.files = pipeline.(Job_Name12).files_out.files;
                pipeline.(Job_Name14).opt.T1_Path    = pipeline.(Job_Name12).files_out.files{1};
            end
            pipeline.(Job_Name14).files_out.files{1} = [NewT1PathPrefix '_resample.nii.gz'];

            NewT1PathPrefix = [NewT1PathPrefix '_resample'];
        end
        
        if tracking_opt.T1Resample_Flag
            FinalT1 = pipeline.(Job_Name14).files_out.files{1};
        elseif tracking_opt.T1Cropping_Flag
            FinalT1 = pipeline.(Job_Name13).files_out.files{1};
        elseif tracking_opt.T1Bet_Flag
            FinalT1 = pipeline.(Job_Name12).files_out.files{1};
        else
            FinalT1 = pipeline.(Job_Name11).files_out.files{1};
        end
        
        Job_Name15 = [ 'FAtoT1_' Number_Of_Subject_String ];
        pipeline.(Job_Name15).command            = 'g_FAtoT1( opt.FA_Path, opt.T1_Path)';
        pipeline.(Job_Name15).opt.FA_Path       = FAPathCell{i};
        pipeline.(Job_Name15).opt.T1_Path       = FinalT1;
        pipeline.(Job_Name15).files_in.files{1}      = FinalT1;
        pipeline.(Job_Name15).files_out.files{1}     = [T1Folder filesep FAFileName '_2T1.mat'];
        pipeline.(Job_Name15).files_out.files{2}     = [T1Folder filesep FAFileName '_2T1.nii.gz'];
        if strcmp(T1Suffix, '.gz')
            pipeline.(Job_Name15).files_out.files{3}     = [NewT1PathPrefix '_2FA.mat'];
        elseif strcmp(T1Suffix, '.nii')
            pipeline.(Job_Name15).files_out.files{3}     = [NewT1PathPrefix '_2FA.mat'];
        else
            error('Not a .nii or .nii.gz file.');
        end
        
        Job_Name16 = ['T1toMNI152_' Number_Of_Subject_String];
        pipeline.(Job_Name16).command            = 'g_T1toMNI152( opt.T1_Path, opt.T1Template_Path )';
        pipeline.(Job_Name16).opt.T1_Path        = FinalT1;
        pipeline.(Job_Name16).opt.T1Template_Path    = tracking_opt.T1Template;
        pipeline.(Job_Name16).files_in.files{1}      = FinalT1;
        pipeline.(Job_Name16).files_out.files{1}     = [NewT1PathPrefix '_2MNI152.nii.gz'];
        pipeline.(Job_Name16).files_out.files{2}     = [NewT1PathPrefix '_2MNI152_warp.nii.gz'];
        
        Job_Name17 = [ 'Invwarp_' Number_Of_Subject_String ];
        pipeline.(Job_Name17).command             = 'g_Invwarp( opt.WarpVolume, opt.ReferenceVolume )';
        pipeline.(Job_Name17).files_in.files{1}     = pipeline.(Job_Name16).files_out.files{2};
        pipeline.(Job_Name17).files_in.files{2}     = FinalT1;
        pipeline.(Job_Name17).files_out.files{1}    = T1toMNI152_warp_inv;
        pipeline.(Job_Name17).opt.ReferenceVolume   = FinalT1;
        pipeline.(Job_Name17).opt.WarpVolume        = pipeline.(Job_Name16).files_out.files{2};
        
        Job_Name18 = [ 'IndividualParcellated_' Number_Of_Subject_String ];
        pipeline.(Job_Name18).command             = 'g_IndividualParcellated( opt.FA_Path, opt.T1_Path, opt.PartitionTemplate, opt.T1toFAMat, opt.T1toMNI152_warp_inv )';
        pipeline.(Job_Name18).files_in.files{1} = pipeline.(Job_Name15).files_out.files{3};
        pipeline.(Job_Name18).files_in.files{2} = pipeline.(Job_Name17).files_out.files{1};
        pipeline.(Job_Name18).opt.PartitionTemplate = tracking_opt.PartitionTemplate;
        pipeline.(Job_Name18).opt.FA_Path = FAPathCell{i};
        pipeline.(Job_Name18).opt.T1toFAMat = pipeline.(Job_Name15).files_out.files{3};
        pipeline.(Job_Name18).opt.T1toMNI152_warp_inv = pipeline.(Job_Name17).files_out.files{1};
        pipeline.(Job_Name18).opt.T1_Path = FinalT1;
        [a, PartitionTemplateName, PartitionTemplateSuffix] = fileparts(tracking_opt.PartitionTemplate);
        if strcmp(PartitionTemplateSuffix, '.gz')
            T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateName(1:end-4) '.nii.gz'];
        elseif strcmp(PartitionTemplateSuffix, '.nii') || isempty(PartitionTemplateSuffix)
            T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateName '.nii.gz'];
        end
        pipeline.(Job_Name18).files_out.files{1} = T1toFA_PartitionTemplate;
        
    end
end
if tracking_opt.DeterministicNetwork == 1;
    DeterministicNetworkOption = Option;
    DeterministicNetworkOption.PartitionOfSubjects = tracking_opt.PartitionOfSubjects;
    DeterministicNetworkOption.T1 = tracking_opt.T1;
    
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(SubjectIDArray(i), '%05.0f');
        % Deterministic Network
        Job_Name3 = [ 'DeterministicNetwork_',Number_Of_Subject_String ];
        pipeline.(Job_Name3).command           = 'g_DeterministicNetwork( opt.trackfilepath,opt.T1toFA_PartitionTemplate,opt.FAfilepath )';
        if ~tracking_opt.PartitionOfSubjects 
            IndividualParcellated_Name = [ 'IndividualParcellated_' Number_Of_Subject_String ];
            pipeline.(Job_Name3).files_in.files1   = pipeline.(IndividualParcellated_Name).files_out;
        end
        tracking_Name = [ 'DeterministicTracking_' Number_Of_Subject_String ];
%         pipeline.(Job_Name3).files_in.files2   = pipeline.(tracking_Name).files_out;
        pipeline.(Job_Name3).files_in.files2   = DeterministicTrackingOutput{i};
        if tracking_opt.PartitionOfSubjects  
            pipeline.(Job_Name3).files_out.files   = g_DeterministicNetwork_FileOut_Tracking( NativePathCell{i},DeterministicNetworkOption,T1orPartitionOfSubjects_PathCell{i},Number_Of_Subject_String );
        else
            pipeline.(Job_Name3).files_out.files   = g_DeterministicNetwork_FileOut_Tracking( NativePathCell{i},DeterministicNetworkOption,tracking_opt.PartitionTemplate,Number_Of_Subject_String );
        end
        pipeline.(Job_Name3).opt.trackfilepath = DeterministicTrackingOutput{i}{1};
        if tracking_opt.PartitionOfSubjects 
            pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = T1orPartitionOfSubjects_PathCell{i};
        else
            pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = pipeline.(IndividualParcellated_Name).files_out.files{1};
        end
        pipeline.(Job_Name3).opt.FAfilepath = FAPathCell{i};
    end
end

if tracking_opt.BedpostxProbabilisticNetwork == 1
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(SubjectIDArray(i), '%05.0f');
        % Bedpostx 
        Job_Name4 = [ 'BedpostX_preproc_',Number_Of_Subject_String ];
        pipeline.(Job_Name4).command = 'g_bedpostX_preproc( opt.NativeFolder )';
        merge_Name = [ 'merge_' Number_Of_Subject_String ];
        pipeline.(Job_Name4).files_in.files = {};
        pipeline.(Job_Name4).files_out.files = g_bedpostX_preproc_FileOut( NativePathCell{i} );
        pipeline.(Job_Name4).opt.NativeFolder = NativePathCell{i};
        
        BedpostxFolder = [NativePathCell{i} '.bedpostX'];
        for BedpostXJobNum = 1:10
            Job_Name5 = [ 'BedpostX_' num2str(BedpostXJobNum, '%02.0f') '_' Number_Of_Subject_String ];
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
            Job_Name = [ 'BedpostX_' num2str(j, '%02.0f') '_' Number_Of_Subject_String ];
            pipeline.(Job_Name6).files_in.files{j} = pipeline.(Job_Name).files_out.files{1};
        end
        pipeline.(Job_Name6).files_out.files = g_bedpostX_postproc_FileOut( BedpostxFolder );
        pipeline.(Job_Name6).opt.BedpostxFolder = BedpostxFolder;
        pipeline.(Job_Name6).opt.Fibers = tracking_opt.Fibers;
    end
end

if tracking_opt.ProbabilisticNetwork || tracking_opt.BedpostxProbabilisticNetwork
    BrainRegionsQuantity = length(tracking_opt.LabelIdVector);
    for i = 1:length(NativePathCell)
        Number_Of_Subject_String = num2str(SubjectIDArray(i), '%05.0f');
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
            IndividualParcellated_Name = [ 'IndividualParcellated_' Number_Of_Subject_String ];
            pipeline.(Job_Name7).files_in.Labelfiles  = pipeline.(IndividualParcellated_Name).files_out.files;
            pipeline.(Job_Name7).opt.LabelFile   = pipeline.(IndividualParcellated_Name).files_out.files{1};
        end
        pipeline.(Job_Name7).opt.LabelVector     = tracking_opt.LabelIdVector;
        pipeline.(Job_Name7).opt.ResultantFolder = ProbabilisticFolder;
        
        
        for j = 1:length(tracking_opt.LabelIdVector)
            LabelSeedFileNameCell{j} = pipeline.(Job_Name7).files_out.files{2 * j};
            LabelTermFileNameCell{j} = pipeline.(Job_Name7).files_out.files{2 * j + 1};
        end
        ProbabilisticNetworkJobQuantity = min(length(tracking_opt.LabelIdVector), 80);
        for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
            Job_Name8 = ['ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d') '_' Number_Of_Subject_String];
            pipeline.(Job_Name8).command = 'g_ProbabilisticNetwork( opt.BedostxFolder, opt.LabelSeedFileNameCell, opt.LabelTermFileNameCell, opt.TargetsTxtFileName, opt.ProbabilisticTrackingType, opt.ProbabilisticNetworkJobNum, opt.JobName )';
            pipeline.(Job_Name8).files_in.files = pipeline.(Job_Name7).files_out.files;
            pipeline.(Job_Name8).files_out.files{1} = [ProbabilisticFolder filesep 'OutputDone' filesep Job_Name8 '.done'];
            if tracking_opt.BedpostxProbabilisticNetwork
                BedpostxFolder = [ NativePathCell{i} '.bedpostX'];
            elseif tracking_opt.ProbabilisticNetwork
                BedpostxFolder = NativePathCell{i};
            end
            pipeline.(Job_Name8).opt.BedostxFolder = BedpostxFolder;  
            pipeline.(Job_Name8).opt.LabelSeedFileNameCell = LabelSeedFileNameCell;
            pipeline.(Job_Name8).opt.LabelTermFileNameCell = LabelTermFileNameCell;
            pipeline.(Job_Name8).opt.TargetsTxtFileName = pipeline.(Job_Name7).files_out.files{1};
            pipeline.(Job_Name8).opt.ProbabilisticTrackingType = tracking_opt.ProbabilisticTrackingType;
            pipeline.(Job_Name8).opt.ProbabilisticNetworkJobNum = ProbabilisticNetworkJobNum;
            pipeline.(Job_Name8).opt.JobName = Job_Name8;
        end
        
        ProbabilisticNetworkPostJobQuantity = min(length(tracking_opt.LabelIdVector), 10);
        for ProbabilisticNetworkPostJobNum = 1:ProbabilisticNetworkPostJobQuantity
            Job_Name9 = [ 'ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f') '_' Number_Of_Subject_String ];
            pipeline.(Job_Name9).command        = 'g_track4NETpost_fdt( opt.seed, opt.fdt, opt.ProbabilisticNetworkPostJobNum, opt.prefix )';
            for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
                Job_Name = [ 'ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d') '_' Number_Of_Subject_String ];
                pipeline.(Job_Name9).files_in.files{ProbabilisticNetworkJobNum}    = pipeline.(Job_Name).files_out.files{1};
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
            pipeline.(Job_Name9).opt.ProbabilisticNetworkPostJobNum = ProbabilisticNetworkPostJobNum;
            pipeline.(Job_Name9).opt.prefix = Number_Of_Subject_String;
            pipeline.(Job_Name9).files_out.files = g_track4NETpost_fdt_FileOut( NativePathCell{i}, Number_Of_Subject_String, ProbabilisticNetworkPostJobNum );
        end
        
        Job_Name10 = [ 'ProbabilisticNetworkpost_MergeResults_' Number_Of_Subject_String ];
        pipeline.(Job_Name10).command        = 'g_ProbabilisticNetworkMergeResults(opt.ProbabilisticMatrix,opt.prefix,opt.ProbabilisticTrackingType,opt.LabelIdVector)';
        for j = 1:ProbabilisticNetworkPostJobQuantity
            Job_Name = [ 'ProbabilisticNetworkpost_' num2str(j, '%02.0f') '_' Number_Of_Subject_String ];
            pipeline.(Job_Name10).files_in.files{j}     = pipeline.(Job_Name).files_out.files{1};
            pipeline.(Job_Name10).opt.ProbabilisticMatrix{j} = pipeline.(Job_Name).files_out.files{1};
        end
        pipeline.(Job_Name10).opt.prefix = Number_Of_Subject_String;
        pipeline.(Job_Name10).opt.ProbabilisticTrackingType = tracking_opt.ProbabilisticTrackingType;
        pipeline.(Job_Name10).opt.LabelIdVector = tracking_opt.LabelIdVector;
        pipeline.(Job_Name10).files_out.files{1} = [ SubjectFolder filesep 'Network' filesep 'Probabilistic' filesep Number_Of_Subject_String '_ProbabilisticMatrix_' ...
            tracking_opt.ProbabilisticTrackingType '_' num2str(length(tracking_opt.LabelIdVector)) '.txt' ];
    end
end

if ~isempty(pipeline)
    psom_run_pipeline(pipeline,pipeline_opt);
else
    system(['touch ' pipeline_opt.path_logs filesep 'PIPE.lock']);
    pause(15);
    system(['rm ' pipeline_opt.path_logs filesep 'PIPE.lock']);
end

catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' pipeline_opt.path_logs filesep 'tracking_pipeline.error']);
end

