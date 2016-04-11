function pipeline = g_tracking_pipeline( NativePathCell, tracking_opt, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_TRACKING_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic
% fiber tracking for any number of subjects.
%
% SYNTAX:
%
% 1) g_tracking_pipeline( NativePathCell, tracking_opt )
% 2) g_tracking_pipeline( NativePathCell, tracking_opt, pipeline_opt )
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
%            FAPathCell
%            (cell of strings, only needed when tracking_opt.NetworkNode 
%            is 1)
%            Input file cell, each of which is full path of original FA 
%            calculated by dtifit.
%
%            T1orPartitionOfSubjects_PathCell
%            (cell of strings, only needed when tracking_opt.NetworkNode 
%            is 1)
%            There are 2 possibilities under each cell:
%            (1) If tracking_opt.PartitionOfSubjects = 1, full path of
%            subject's parcellated image in native space.
%            (2) If tracking_opt.T1 = 1, full path of subject's T1 image.
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
%
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
% keywords: tracking, pipeline, psom
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
    disp('Please input the first parameter NativePathCell.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
elseif ~iscell(NativePathCell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end

psom_gb_vars

if nargin <= 1
    disp('Please input the second parameter, options of tracking & network.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
elseif ~isstruct(tracking_opt)
    disp('The value of the second parameter tracking opt is invalid.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
else
    
    TrackingOptFields = {'DeterminFiberTracking', 'NetworkNode', 'DeterministicNetwork', 'BedpostxProbabilisticNetwork', ...
        'ProbabilisticNetwork', 'ImageOrientation', 'PropagationAlgorithm', 'StepLength', 'AngleThreshold', ...
        'MaskThresMin', 'MaskThresMax', 'Inversion', 'Swap', 'ApplySplineFilter', 'PartitionOfSubjects', ...
        'T1', 'PartitionTemplate', 'Weight', 'Burnin', 'Fibers', 'LabelIdVector', 'ProbabilisticTrackingType', ...
        'FAPathCell', 'T1orPartitionOfSubjects_PathCell'};
    TrackingOptFields_UserInputs = fieldnames(tracking_opt);
    for i = 1:length(TrackingOptFields_UserInputs)
        if isempty(find(strcmp(TrackingOptFields, TrackingOptFields_UserInputs{i})))
            disp([TrackingOptFields_UserInputs{i} ' is not the field of tracking opt.']);
            disp('See the help, type ''help g_tracking_pipeline''.');
            return;
        end
    end
    
    tracking_opt_new = g_trackingAlone_opt(tracking_opt);
    tracking_opt = tracking_opt_new;
end

if tracking_opt.DeterminFiberTracking ~= 0 && tracking_opt.DeterminFiberTracking ~= 1
    disp('The DeterminFiberTracking field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_dti_pipeline''.');
    return;
end
if tracking_opt.NetworkNode ~= 0 && tracking_opt.NetworkNode ~= 1
    disp('The NetworkNode field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_dti_pipeline''.');
    return;
end
if tracking_opt.DeterministicNetwork ~= 0 && tracking_opt.DeterministicNetwork ~= 1
    disp('The DeterministicNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_dti_pipeline''.');
    return;
end
if tracking_opt.BedpostxProbabilisticNetwork ~= 0 && tracking_opt.BedpostxProbabilisticNetwork ~= 1
    disp('The BedpostxProbabilisticNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_dti_pipeline''.');
    return;
end

if tracking_opt.ProbabilisticNetwork ~= 0 && tracking_opt.ProbabilisticNetwork ~= 1
    disp('The ProbabilisticNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_dti_pipeline''.');
    return;
end

if tracking_opt.DeterminFiberTracking
    if ~strcmp(tracking_opt.ImageOrientation, 'Auto') && ~strcmp(tracking_opt.ImageOrientation, 'Axial') ...
        && ~strcmp(tracking_opt.ImageOrientation, 'Coronal') && ~strcmp(tracking_opt.ImageOrientation, 'Sagittal')
        disp('The ImageOrientation field of tracking_opt should be ''Auto'', ''Axial'', ''Coronal'' or ''Sagittal''.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT') && ~strcmp(tracking_opt.PropagationAlgorithm, '2nd-order Runge Kutta') ...
        && ~strcmp(tracking_opt.PropagationAlgorithm, 'Interpolated Streamline') && ~strcmp(tracking_opt.PropagationAlgorithm, 'Tensorline')
        disp('The ImageOrientation field of tracking_opt should be ''FACT'', ''2nd-order Runge Kutta'', ''Interpolated Streamline'' or ''Tensorline''.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT') 
        if ~isnumeric(tracking_opt.StepLength)
            disp('The StepLength field of tracking_opt should be a float number.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
    end
    if ~isnumeric(tracking_opt.AngleThreshold)
        disp('The AngleThreshold field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.MaskThresMin)
        disp('The MaskThresMin field of tracking_opt should be a float number.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if tracking_opt.MaskThresMin < 0 || tracking_opt.MaskThresMin > 1
        disp('The MaskThresMin field of tracking_opt should be a float number in the range of [0 1].');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.MaskThresMax)
        disp('The MaskThresMax field of tracking_opt should be a float number.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if tracking_opt.MaskThresMax < 0 || tracking_opt.MaskThresMax > 1
        disp('The MaskThresMax field of tracking_opt should be a float number in the range of [0 1].');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if tracking_opt.MaskThresMin >  tracking_opt.MaskThresMax
        disp('The MaskThresMin field of tracking_opt should be smaller than the MaskThresMax field of tracking_opt.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.Inversion, 'No Inversion') && ~strcmp(tracking_opt.Inversion, 'Invert X') ...
        && ~strcmp(tracking_opt.Inversion, 'Invert Y') && ~strcmp(tracking_opt.Inversion, 'Invert Z')
        disp('The Inversion field of tracking_opt should be ''No Inversion'', ''Invert X'', ''Invert Y'' or ''Invert Z''.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.Swap, 'No Swap') && ~strcmp(tracking_opt.Swap, 'Swap X/Y') ...
        && ~strcmp(tracking_opt.Swap, 'Swap Y/Z') && ~strcmp(tracking_opt.Swap, 'Swap Z/X')
        disp('The Swap field of tracking_opt should be ''No Swap'', ''Swap X/Y'', ''Swap Y/Z'' or ''Swap Z/X''.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.ApplySplineFilter, 'Yes') && ~strcmp(tracking_opt.ApplySplineFilter, 'No')
        disp('The ApplySplineFilter field of tracking_opt should be ''Yes'' or ''No''.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
end

if tracking_opt.NetworkNode
    if tracking_opt.PartitionOfSubjects ~= 0 && tracking_opt.PartitionOfSubjects ~= 1
        disp('The PartitionOfSubjects field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if tracking_opt.T1 ~= 0 && tracking_opt.T1 ~= 1
        disp('The T1 field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~tracking_opt.PartitionOfSubjects && ~tracking_opt.T1
        disp('Sujects'' parcellated images or T1 images, which will be used for network node definition?');
        disp('If you want to use Sujects'' parcellated images, tracking_opt.PartitionOfSubjects should be 1.');
        disp('If you want to use T1 images, tracking_opt.T1 should be 1.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if tracking_opt.PartitionOfSubjects && tracking_opt.T1
        disp('The filed ''PartitionOfSubjects'' and ''T1'' cannot be 1 Simultaneously');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isfield(tracking_opt, 'FAPathCell')
        disp('Please input the path of all subject''s FA for network node definition.');
        disp('Assign value for FAPathCell field of tracking_opt.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~iscell(tracking_opt.FAPathCell)
        disp('The FAPathCell field of tracking_opt should be a cell.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isfield(tracking_opt, 'T1orPartitionOfSubjects_PathCell')
        if tracking_opt.PartitionOfSubjects
            disp('Please input subjects'' parcellated images, since the PartitionOfSubjects field is 1.');
            disp('Assign value for T1orPartitionOfSubjects_PathCell field of tracking_opt.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        elseif tracking_opt.T1
            disp('Please input subjects'' T1 images, since the T1 field is 1.');
            disp('Assign value for T1orPartitionOfSubjects_PathCell field of tracking_opt.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
    end
    if ~iscell(tracking_opt.T1orPartitionOfSubjects_PathCell)
        disp('The T1orPartitionOfSubjects_PathCell field of tracking_opt should be a cell.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if tracking_opt.T1
        [x exist_flag] = system(['imtest ' tracking_opt.PartitionTemplate]);
        exist_flag = str2num(exist_flag);
        if ~(exist_flag == 1)
            disp('The partition atlas doesn''t exist.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
    end
end

if (tracking_opt.DeterministicNetwork + tracking_opt.BedpostxProbabilisticNetwork + tracking_opt.ProbabilisticNetwork) >= 2
    disp('Only one of DeterministicNetwork, BedpostxProbabilisticNetwork, and ProbabilisticNetwork fields of tracking_opt can be 1 simultaneously.');
    disp('see the help, type ''help g_dti_pipeline''.');
    return;
end

if tracking_opt.BedpostxProbabilisticNetwork
    if ~isnumeric(tracking_opt.Weight)
        disp('The Weight field of tracking_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(tracking_opt.Weight) ~= tracking_opt.Weight || tracking_opt.Weight < 0
        disp('The Weight field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.Burnin)
        disp('The Burnin field of tracking_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(tracking_opt.Burnin) ~= tracking_opt.Burnin || tracking_opt.Burnin < 0
        disp('The Burnin field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.Fibers)
        disp('The Fibers field of tracking_opt should be an positive integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
    if round(tracking_opt.Fibers) ~= tracking_opt.Fibers || tracking_opt.Fibers < 0
        disp('The Fibers field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_dti_pipeline''.');
        return;
    end
end
if tracking_opt.BedpostxProbabilisticNetwork || tracking_opt.ProbabilisticNetwork
    if ~strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD') && ~strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
        disp('The ProbabilisticTrackingType field of tracking_opt should be an ''OPD'' or ''PD''.');
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

if nargin <= 2
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
    pipeline_opt.path_logs = [pwd '/tracking_logs/'];
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
    pipeline_opt.path_logs = [pwd '/tracking_logs/'];
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
        pipeline_opt.path_logs = [pwd '/tracking_logs/'];
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
    
    if tracking_opt.DeterminFiberTracking
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
        if tracking_opt.DeterminFiberTracking == 1
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
    end
    if tracking_opt.NetworkNode == 1 && ~tracking_opt.PartitionOfSubjects  
        for i = 1:length(tracking_opt.FAPathCell)
            Number_Of_Subject_String = num2str(i, '%05.0f');
            % Network Node Definition 
            Job_Name2 = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
            pipeline.(Job_Name2).command           = 'g_PartitionTemplate2FA( opt.FA_Path,opt.T1_Path,opt.PartitionTemplate )';
            pipeline.(Job_Name2).files_in.files{1} = tracking_opt.FAPathCell{i};
            pipeline.(Job_Name2).files_in.files{2} = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
            pipeline.(Job_Name2).files_out.files   = g_PartitionTemplate2FA_FileOut_Tracking( tracking_opt.FAPathCell{i},tracking_opt.PartitionTemplate );
            pipeline.(Job_Name2).opt.FA_Path       = tracking_opt.FAPathCell{i};
            pipeline.(Job_Name2).opt.T1_Path       = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
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
                pipeline.(Job_Name3).files_out.files   = g_FiberNumMatrix_FileOut_Tracking( NativePathCell{i},Option,tracking_opt.T1orPartitionOfSubjects_PathCell{i},Number_Of_Subject_String );
            else
                pipeline.(Job_Name3).files_out.files   = g_FiberNumMatrix_FileOut_Tracking( NativePathCell{i},Option,tracking_opt.PartitionTemplate,Number_Of_Subject_String );
            end
            pipeline.(Job_Name3).opt.trackfilepath = pipeline.(tracking_Name).files_out.files{16};
            if tracking_opt.PartitionOfSubjects 
                pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
            else
                pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = pipeline.(PartitionTemplate2FA_Name).files_out.files{1};
            end
            pipeline.(Job_Name3).opt.FAfilepath = tracking_opt.FAPathCell{i};
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

    if tracking_opt.ProbabilisticNetwork || tracking_opt.BedpostxProbabilisticNetwork
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
                pipeline.(Job_Name7).opt.LabelFile   = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
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
    
end


