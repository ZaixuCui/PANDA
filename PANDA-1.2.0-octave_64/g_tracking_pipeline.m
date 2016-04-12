function g_tracking_pipeline( NativePathCell, index_vector, tracking_opt, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_TRACKING_PIPELINE
% 
% The whole process of deterministic fiber tracking and  Probabilistic
% fiber tracking for any number of subjects.
%
% SYNTAX:
%
% 1) g_tracking_pipeline( NativePathCell, index_vector, tracking_opt )
% 2) g_tracking_pipeline( NativePathCell, index_vector, tracking_opt, pipeline_opt )
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
% INDEX_VECTOR
%        (vector, array of integers) digital IDs user sets for subjects.
%        For example: index_vector = [1 3 4:6] 
%                     The ID of the second subject is 3.
%                     The ID will be in the name of resultant files.
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
%           RandomSeed_Flag
%               (integer, 0 or 1, default 0)
%               1: The location of seeds is random. 
%               0: The location of seed is in the center of the voxel.
%
%           RandomSeed
%               (integer, default 1)
%               The number of the seeds of each voxel.
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
%              T1Bet_Flag
%                (0 or 1, default 1)
%                The flag whether to do brain extraction for T1 image.
%
%              T1BetF
%                (single, default 0.5)
%                Fractional intensity thershold (0->1);
%                smaller values give larger brain outline estimates
%
%              T1Cropping_flag
%                (0 or 1, default 1)
%                The flag whether to crop the T1 image.
%
%              T1CroppingGap
%                (integer, default 3, Only needed when T1Cropping_flag=1)
%                The length from the boundary of the brain in T1 image to 
%                the cube we select.
%
%              T1Resample_Flag
%                (0 or 1, default 1)
%                The flag whether to resample the T1 image.
%
%              T1ResampleResolution
%                (1*3 vector, default [1 1 1])
%                The final voxel size of the resampled T1 image.
%
%              PartitionTemplate
%                (string, only needed when T1 is 1, default AAL atlas with 
%                90 regions)
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
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: tracking, pipeline, psom
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
    disp('Please input the first parameter NativePathCell.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
elseif ~iscell(NativePathCell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end

if nargin <= 1
    disp('Please assign IDs for the subjects.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
elseif length(NativePathCell) ~= length(index_vector)
    disp('The quantity of raw data should be equal to the quantity of IDs.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end

psom_gb_vars;

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
                'MaskThresMin', 'T1', 'MaskThresMax', 'RandomSeed_Flag', 'RandomSeed', 'Inversion', 'Swap', 'ApplySplineFilter', ...
                'PartitionOfSubjects', 'T1Bet_Flag', 'T1BetF', 'T1Cropping_flag', 'T1CroppingGap', 'T1Resample_Flag', ...
                'T1ResampleResolution', 'PartitionTemplate', 'Weight', 'Burnin', 'Fibers', 'LabelIdVector', ...
                'ProbabilisticTrackingType', 'FAPathCell', 'T1orPartitionOfSubjects_PathCell'};
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

if ~isnumeric(tracking_opt.DeterminFiberTracking)
    disp('The DeterminFiberTracking field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if tracking_opt.DeterminFiberTracking ~= 0 && tracking_opt.DeterminFiberTracking ~= 1
    disp('The DeterminFiberTracking field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if ~isnumeric(tracking_opt.NetworkNode)
    disp('The NetworkNode field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if tracking_opt.NetworkNode ~= 0 && tracking_opt.NetworkNode ~= 1
    disp('The NetworkNode field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if ~isnumeric(tracking_opt.DeterministicNetwork)
    disp('The DeterministicNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if tracking_opt.DeterministicNetwork ~= 0 && tracking_opt.DeterministicNetwork ~= 1
    disp('The DeterministicNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if ~isnumeric(tracking_opt.BedpostxProbabilisticNetwork)
    disp('The BedpostxProbabilisticNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if tracking_opt.BedpostxProbabilisticNetwork ~= 0 && tracking_opt.BedpostxProbabilisticNetwork ~= 1
    disp('The BedpostxProbabilisticNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if ~isnumeric(tracking_opt.ProbabilisticNetwork)
    disp('The ProbabilisticNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if tracking_opt.ProbabilisticNetwork ~= 0 && tracking_opt.ProbabilisticNetwork ~= 1
    disp('The ProbabilisticNetwork field of tracking_opt should be 0 or 1.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end

if tracking_opt.DeterminFiberTracking
    if ~strcmp(tracking_opt.ImageOrientation, 'Auto') && ~strcmp(tracking_opt.ImageOrientation, 'Axial') ...
        && ~strcmp(tracking_opt.ImageOrientation, 'Coronal') && ~strcmp(tracking_opt.ImageOrientation, 'Sagittal')
        disp('The ImageOrientation field of tracking_opt should be ''Auto'', ''Axial'', ''Coronal'' or ''Sagittal''.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT') && ~strcmp(tracking_opt.PropagationAlgorithm, '2nd-order Runge Kutta') ...
        && ~strcmp(tracking_opt.PropagationAlgorithm, 'Interpolated Streamline') && ~strcmp(tracking_opt.PropagationAlgorithm, 'Tensorline')
        disp('The ImageOrientation field of tracking_opt should be ''FACT'', ''2nd-order Runge Kutta'', ''Interpolated Streamline'' or ''Tensorline''.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT') 
        if ~isnumeric(tracking_opt.StepLength)
            disp('The StepLength field of tracking_opt should be a float number.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
    end
    if ~isnumeric(tracking_opt.AngleThreshold)
        disp('The AngleThreshold field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.MaskThresMin)
        disp('The MaskThresMin field of tracking_opt should be a float number.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.MaskThresMin < 0 || tracking_opt.MaskThresMin > 1
        disp('The MaskThresMin field of tracking_opt should be a float number in the range of [0 1].');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.MaskThresMax)
        disp('The MaskThresMax field of tracking_opt should be a float number.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.MaskThresMax < 0 || tracking_opt.MaskThresMax > 1
        disp('The MaskThresMax field of tracking_opt should be a float number in the range of [0 1].');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.MaskThresMin >  tracking_opt.MaskThresMax
        disp('The MaskThresMin field of tracking_opt should be smaller than the MaskThresMax field of tracking_opt.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.RandomSeed_Flag)
        disp('The RandomSeed_Flag field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.RandomSeed_Flag ~= 0 && tracking_opt.RandomSeed_Flag ~= 1
        disp('The RandomSeed_Flag field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.RandomSeed_Flag
        if ~isnumeric(tracking_opt.RandomSeed)
            disp('The RandomSeed field of tracking_opt should be an integer.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if round(tracking_opt.RandomSeed) ~= tracking_opt.RandomSeed
            disp('The RandomSeed field of tracking_opt should be an integer.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if tracking_opt.RandomSeed <= 0
            disp('The RandomSeed field of tracking_opt shoud be an positive integer.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
    end
    if ~strcmp(tracking_opt.Inversion, 'No Inversion') && ~strcmp(tracking_opt.Inversion, 'Invert X') ...
        && ~strcmp(tracking_opt.Inversion, 'Invert Y') && ~strcmp(tracking_opt.Inversion, 'Invert Z')
        disp('The Inversion field of tracking_opt should be ''No Inversion'', ''Invert X'', ''Invert Y'' or ''Invert Z''.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.Swap, 'No Swap') && ~strcmp(tracking_opt.Swap, 'Swap X/Y') ...
        && ~strcmp(tracking_opt.Swap, 'Swap Y/Z') && ~strcmp(tracking_opt.Swap, 'Swap Z/X')
        disp('The Swap field of tracking_opt should be ''No Swap'', ''Swap X/Y'', ''Swap Y/Z'' or ''Swap Z/X''.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~strcmp(tracking_opt.ApplySplineFilter, 'Yes') && ~strcmp(tracking_opt.ApplySplineFilter, 'No')
        disp('The ApplySplineFilter field of tracking_opt should be ''Yes'' or ''No''.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
end

if tracking_opt.NetworkNode 
    if ~isnumeric(tracking_opt.PartitionOfSubjects)
        disp('The PartitionOfSubjects field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.PartitionOfSubjects ~= 0 && tracking_opt.PartitionOfSubjects ~= 1
        disp('The PartitionOfSubjects field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.T1)
        disp('The T1 field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.T1 ~= 0 && tracking_opt.T1 ~= 1
        disp('The T1 field of tracking_opt should be 0 or 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~tracking_opt.PartitionOfSubjects && ~tracking_opt.T1
        disp('Sujects'' parcellated images or T1 images, which will be used for network node definition?');
        disp('If you want to use Sujects'' parcellated images, tracking_opt.PartitionOfSubjects should be 1.');
        disp('If you want to use T1 images, tracking_opt.T1 should be 1.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.PartitionOfSubjects && tracking_opt.T1
        disp('The filed ''PartitionOfSubjects'' and ''T1'' cannot be 1 Simultaneously');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isfield(tracking_opt, 'FAPathCell')
        disp('Please input subjects'' FA images, since you want to do network node definition.');
        disp('Assign value for FAPathCell field of tracking_opt.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~iscell(tracking_opt.FAPathCell)
        disp('The FAPathCell field of tracking_opt should be a cell.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isfield(tracking_opt, 'T1orPartitionOfSubjects_PathCell')
        if tracking_opt.PartitionOfSubjects
            disp('Please input subjects'' parcellated images, since the PartitionOfSubjects field is 1.');
            disp('Assign value for T1orPartitionOfSubjects_PathCell field of tracking_opt.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        elseif tracking_opt.T1
            disp('Please input subjects'' T1 images, since the T1 field is 1.');
            disp('Assign value for T1orPartitionOfSubjects_PathCell field of tracking_opt.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
    end
    if ~iscell(tracking_opt.T1orPartitionOfSubjects_PathCell)
        disp('The T1orPartitionOfSubjects_PathCell field of tracking_opt should be a cell.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if length(tracking_opt.FAPathCell) ~= length(tracking_opt.T1orPartitionOfSubjects_PathCell)
        disp('The quantity of FA images and the quantity of parcellated/T1 images should be the same.');
        disp('That is the length of tracking_opt.FAPathCell should be the same as tracking_opt.T1orPartitionOfSubjects_PathCell.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if tracking_opt.T1
        if ~isnumeric(tracking_opt.T1Bet_Flag)
            disp('The T1Bet_Flag of tracking_opt should be 0 or 1');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if tracking_opt.T1Bet_Flag ~= 0 && tracking_opt.T1Bet_Flag ~= 1
            disp('The T1Bet_Flag of tracking_opt should be 0 or 1');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.T1BetF)
            disp('The T1BetF of tracking_opt shoud be an positive value (0->1).');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if tracking_opt.T1BetF <= 0 || tracking_opt.T1BetF > 1
            disp('The T1BetF of tracking_opt shoud be an positive value (0->1).');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.T1Cropping_Flag)
            disp('The T1Cropping_Flag of tracking_opt should be 0 or 1');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if tracking_opt.T1Cropping_Flag ~= 0 && tracking_opt.T1Cropping_Flag ~= 1
            disp('The T1Cropping_Flag of tracking_opt should be 0 or 1');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.T1CroppingGap)
            disp('The T1CroppingGap of the tracking_opt shoud be an positive integer.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if round(tracking_opt.T1CroppingGap) ~= tracking_opt.T1CroppingGap
            disp('The T1CroppingGap of the tracking_opt shoud be an integer.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if tracking_opt.T1CroppingGap <= 0
            disp('The T1CroppingGap of the tracking_opt shoud be an positive integer.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.T1Resample_Flag)
            disp('The T1Resample_Flag of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        if tracking_opt.T1Resample_Flag ~= 0 && tracking_opt.T1Resample_Flag ~= 1
            disp('The T1Resample_Flag of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        try
            if length(tracking_opt.T1ResampleResolution) ~= 3
                disp('The T1ResampleResolution of tracking_opt should be 3 integers.');
                disp('see the help, type ''help g_tracking_pipeline''.');
                return;
            end
        catch
            disp('The T1ResampleResolution of tracking_opt is illegal.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
        [x exist_flag] = system(['imtest ' tracking_opt.PartitionTemplate]);
        exist_flag = str2num(exist_flag);
        if ~(exist_flag == 1)
            disp('The partition atlas doesn''t exist.');
            disp('see the help, type ''help g_tracking_pipeline''.');
            return;
        end
    end
end

if (tracking_opt.DeterministicNetwork + tracking_opt.BedpostxProbabilisticNetwork + tracking_opt.ProbabilisticNetwork) >= 2
    disp('Only one of DeterministicNetwork, BedpostxProbabilisticNetwork, and ProbabilisticNetwork fields of tracking_opt can be 1 simultaneously.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end

if tracking_opt.BedpostxProbabilisticNetwork
    if ~isnumeric(tracking_opt.Weight)
        disp('The Weight field of tracking_opt should be an positive integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if round(tracking_opt.Weight) ~= tracking_opt.Weight || tracking_opt.Weight < 0
        disp('The Weight field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.Burnin)
        disp('The Burnin field of tracking_opt should be an positive integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if round(tracking_opt.Burnin) ~= tracking_opt.Burnin || tracking_opt.Burnin < 0
        disp('The Burnin field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if ~isnumeric(tracking_opt.Fibers)
        disp('The Fibers field of tracking_opt should be an positive integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
    if round(tracking_opt.Fibers) ~= tracking_opt.Fibers || tracking_opt.Fibers < 0
        disp('The Fibers field of tracking_opt should be an integer.');
        disp('see the help, type ''help g_tracking_pipeline''.');
        return;
    end
end
if tracking_opt.BedpostxProbabilisticNetwork || tracking_opt.ProbabilisticNetwork
    if ~strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD') && ~strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
        disp('The ProbabilisticTrackingType field of tracking_opt should be an ''OPD'' or ''PD''.');
        disp('see the help, type ''help g_tracking_pipeline''.');
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
        [a,QuantityOfCpu] = system('sysctl -n machdep.cpu.core_count');
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
    pipeline_opt.flag_verbose = 1;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.flag_update = 1;
    pipeline_opt.path_logs = [pwd '/tracking_logs/'];
elseif ~isstruct(pipeline_opt) && ~strcmp(pipeline_opt, 'default')
    disp('The value of the fifth parameter pipeline opt is invalid.');
    disp('see the help, type ''help g_tracking_pipeline''.');
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
    pipeline_opt.path_logs = [pwd '/tracking_logs/'];
elseif nargin >= 4
    
    PipelineOptFields = {'mode', 'qsub_options', 'mode_pipeline_manager', 'max_queued', ...
        'flag_verbose', 'flag_pause', 'path_logs'};
    PipelineOptFields_UserInputs = fieldnames(pipeline_opt);
    for i = 1:length(PipelineOptFields_UserInputs)
        if isempty(find(strcmp(PipelineOptFields, PipelineOptFields_UserInputs{i})))
            disp([PipelineOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
            disp('See the help, type ''help g_tracking_pipeline''.');
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
        pipeline_opt.path_logs = [pwd '/tracking_logs/'];
    else
        pipeline_opt.path_logs = [pipeline_opt.path_logs '/tracking_logs/'];
    end
end

if ~strcmp(pipeline_opt.mode, 'batch') && ~strcmp(pipeline_opt.mode, 'qsub')
    disp('The mode of the pipeline should be ''batch'' or ''qsub''');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if ~isnumeric(pipeline_opt.max_queued)
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if round(pipeline_opt.max_queued) ~= pipeline_opt.max_queued
    disp('The max queued of the pipeline shoud be an integer.');
    disp('see the help, type ''help g_tracking_pipeline''.');
    return;
end
if pipeline_opt.max_queued <= 0
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_tracking_pipeline''.');
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
%         Option.PartitionOfSubjects = tracking_opt.PartitionOfSubjects;
%         Option.T1 = tracking_opt.T1;
        Option.RandomSeed_Flag = tracking_opt.RandomSeed_Flag;
        if tracking_opt.RandomSeed_Flag
            Option.RandomSeed = tracking_opt.RandomSeed;
        end
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
            [NativeFolder, FAFileName, FASuffix] = fileparts(tracking_opt.FAPathCell{i}); 
            if strcmp(FASuffix, '.gz')
                [a, FAFileName, c] = fileparts(FAFileName);
            end
            [SubjectFolder, b, c] = fileparts(NativeFolder);
            T1Folder = [SubjectFolder filesep 'T1'];
            [T1ParentFolder, T1FileName, T1Suffix] = fileparts(tracking_opt.T1orPartitionOfSubjects_PathCell{i});
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
            pipeline.(Job_Name11).opt.T1Path = tracking_opt.T1orPartitionOfSubjects_PathCell{i};

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
                    pipeline.(Job_Name13).files_in.files = pipeline.(Job_Name12).files_out.files;
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
            else
                FinalT1 = pipeline.(Job_Name12).files_out.files{1};
            end

            Job_Name15 = [ 'FAtoT1_' Number_Of_Subject_String ];
            pipeline.(Job_Name15).command            = 'g_FAtoT1( opt.FA_Path, opt.T1_Path)';
            pipeline.(Job_Name15).opt.FA_Path       = tracking_opt.FAPathCell{i};
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
            pipeline.(Job_Name16).command            = 'g_T1toMNI152( opt.T1_Path )';
            pipeline.(Job_Name16).opt.T1_Path        = FinalT1;
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
            pipeline.(Job_Name18).opt.FA_Path = tracking_opt.FAPathCell{i};
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
    
    Option.PartitionOfSubjects = tracking_opt.PartitionOfSubjects;
    Option.T1 = tracking_opt.T1;
    if tracking_opt.DeterministicNetwork == 1;
        for i = 1:length(NativePathCell)
            Number_Of_Subject_String = num2str(i, '%05.0f');
            % Deterministic Network
            Job_Name3 = [ 'DeterministicNetwork_',Number_Of_Subject_String ];
            pipeline.(Job_Name3).command           = 'g_DeterministicNetwork( opt.trackfilepath,opt.T1toFA_PartitionTemplate,opt.FAfilepath )';
            if ~tracking_opt.PartitionOfSubjects 
                IndividualParcellated_Name = [ 'IndividualParcellated_' Number_Of_Subject_String ];
                pipeline.(Job_Name3).files_in.files1   = pipeline.(IndividualParcellated_Name).files_out;
            end
            tracking_Name = [ 'DeterministicTracking_' Number_Of_Subject_String ];
            pipeline.(Job_Name3).files_in.files2   = pipeline.(tracking_Name).files_out;
            if tracking_opt.PartitionOfSubjects  
                pipeline.(Job_Name3).files_out.files   = g_DeterministicNetwork_FileOut_Tracking( NativePathCell{i},Option,tracking_opt.T1orPartitionOfSubjects_PathCell{i},Number_Of_Subject_String );
            else
                pipeline.(Job_Name3).files_out.files   = g_DeterministicNetwork_FileOut_Tracking( NativePathCell{i},Option,tracking_opt.PartitionTemplate,Number_Of_Subject_String );
            end
            pipeline.(Job_Name3).opt.trackfilepath = pipeline.(tracking_Name).files_out.files{1};
            if tracking_opt.PartitionOfSubjects 
                pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
            else
                pipeline.(Job_Name3).opt.T1toFA_PartitionTemplate = pipeline.(IndividualParcellated_Name).files_out.files{1};
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
            for ProbabilisticNetworkJobNum = 1:80
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

            for ProbabilisticNetworkPostJobNum = 1:10
                Job_Name9 = [ 'ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f') '_' Number_Of_Subject_String ];
                pipeline.(Job_Name9).command        = 'g_track4NETpost_fdt( opt.seed, opt.fdt, opt.ProbabilisticTrackingType, opt.LabelIdVector, opt.ProbabilisticNetworkPostJobNum, opt.prefix )';
                for ProbabilisticNetworkJobNum = 1:80
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
                pipeline.(Job_Name9).opt.ProbabilisticTrackingType = tracking_opt.ProbabilisticTrackingType;
                pipeline.(Job_Name9).opt.LabelIdVector = tracking_opt.LabelIdVector;
                pipeline.(Job_Name9).opt.ProbabilisticNetworkPostJobNum = ProbabilisticNetworkPostJobNum;
                pipeline.(Job_Name9).files_out.files = g_track4NETpost_fdt_FileOut( NativePathCell{i}, Number_Of_Subject_String, ProbabilisticNetworkPostJobNum );
                pipeline.(Job_Name9).opt.prefix = Number_Of_Subject_String;
            end
            
            Job_Name10 = [ 'ProbabilisticNetworkpost_MergeResults_' Number_Of_Subject_String ];
            pipeline.(Job_Name10).command        = 'g_ProbabilisticNetworkMergeResults(opt.ProbabilisticMatrix,opt.prefix,opt.ProbabilisticTrackingType,opt.LabelIdVector)';
            for j = 1:10
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

    psom_run_pipeline(pipeline,pipeline_opt);
    
end


