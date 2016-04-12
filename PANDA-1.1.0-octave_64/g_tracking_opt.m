function tracking_opt = g_tracking_opt( tracking_opt )   
%
% SUMMARY OF G_TRACKING_OPT
%
% Set default values for tracking_opt.
%
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%--------------------------------------------------------------------------
global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));

if nargin == 0
    
    tracking_opt.DeterminFiberTracking = 0;
    tracking_opt.NetworkNode = 0;
    tracking_opt.PartitionOfSubjects = 0;
    tracking_opt.DeterministicNetwork = 0;
    tracking_opt.BedpostxProbabilisticNetwork = 0;
    
else
    
    if ~isfield(tracking_opt, 'DeterministicNetwork')
        tracking_opt.DeterministicNetwork = 0;
    else
        tracking_opt.NetworkNode = 1;
        tracking_opt.DeterminFiberTracking = 1;
    end
    
    if ~isfield(tracking_opt, 'BedpostxProbabilisticNetwork')
        tracking_opt.BedpostxProbabilisticNetwork = 0;
    elseif tracking_opt.BedpostxProbabilisticNetwork
        tracking_opt.NetworkNode = 1;
        if ~isfield(tracking_opt, 'Weight');tracking_opt.Weight = 1;end;
        if ~isfield(tracking_opt, 'Burnin');tracking_opt.Burnin = 1000;end;
        if ~isfield(tracking_opt, 'Fibers');tracking_opt.Fibers = 2;end;
        if ~isfield(tracking_opt, 'ProbabilisticTrackingType');tracking_opt.ProbabilisticTrackingType = 'OPD';end;
        if ~isfield(tracking_opt, 'LabelIdVector');tracking_opt.LabelIdVector = [1:90];end;
    end
    
    if ~isfield(tracking_opt, 'DeterminFiberTracking')
        tracking_opt.DeterminFiberTracking = 0;
    elseif tracking_opt.DeterminFiberTracking 
        if ~isfield(tracking_opt, 'ImageOrientation');tracking_opt.ImageOrientation = 'Auto';end;
        if ~isfield(tracking_opt, 'PropagationAlgorithm')
            tracking_opt.PropagationAlgorithm = 'FACT';
        elseif strcmp(tracking_opt.PropagationAlgorithm, '2nd-order Runge Kutta') | strcmp(tracking_opt.PropagationAlgorithm, 'Tensorline')
            if ~isfield(tracking_opt, 'StepLength')
                tracking_opt.StepLength = 0.1;
            end
        elseif strcmp(tracking_opt.PropagationAlgorithm, 'Interpolated Streamline')
            if ~isfield(tracking_opt, 'StepLength')
                tracking_opt.StepLength = 0.5;
            end
        end
        if ~isfield(tracking_opt, 'AngleThreshold')
            tracking_opt.AngleThreshold = 35;
        end
        if ~isfield(tracking_opt, 'MaskThresMin');tracking_opt.MaskThresMin = 0.1;end;
        if ~isfield(tracking_opt, 'MaskThresMax');tracking_opt.MaskThresMax = 1;end;
        if ~isfield(tracking_opt, 'Inversion');tracking_opt.Inversion = 'No Inversion';end;
        if ~isfield(tracking_opt, 'Swap');tracking_opt.Swap = 'No Swap';end;
        if ~isfield(tracking_opt, 'ApplySplineFilter');tracking_opt.ApplySplineFilter = 'Yes';end;
    end
    
    if ~isfield(tracking_opt, 'NetworkNode')
        tracking_opt.NetworkNode = 0;
    elseif tracking_opt.NetworkNode
        if ~isfield(tracking_opt, 'PartitionOfSubjects')
            tracking_opt.PartitionOfSubjects = 0;
            tracking_opt.T1 = 1;
        elseif tracking_opt.PartitionOfSubjects
            tracking_opt.T1 = 0;
        elseif ~tracking_opt.PartitionOfSubjects
            tracking_opt.T1 = 1;
        end
        if tracking_opt.T1 && ~isfield(tracking_opt, 'PartitionTemplate')
            tracking_opt.PartitionTemplate = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
        end
    end
    
end
