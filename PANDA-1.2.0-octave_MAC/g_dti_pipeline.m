
function g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,File_Prefix,pipeline_opt,dti_opt,tracking_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_DTI_PIPELINE
% 
% The whole process of DTI data processing for any number of subjects.
%
% SYNTAX:
%
% 1) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,File_Prefix )
% 2) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,File_Prefix,pipeline_opt )
% 3) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,File_Prefix,pipeline_opt,dti_opt )
% 4) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,File_Prefix,pipeline_opt,dti_opt,tracking_opt )
%__________________________________________________________________________
% INPUTS:
%
% DATA_RAW_PATH_CELL
%        (cell of strings, n rows, 1 column) the input folder cell, each of
%        which includes the dcm/nifti data for a single acquisition.
%        For example: 'Data_Raw_Path_Cell{1} = '/data/Raw_Data/DTI_test1/'
%        There are 2 possibilities under each cell:
%        (1) multiple/single subdirectories, each of which contains dicoms
%        for each sequence( multiple/repetitive sequence ).
%        (2) multiple/single subdirectories, each of which contains three
%        files exactly, which are NIfTI image, b value file named as
%        '*bval*' and bvector file named as '*bvec*'.
%        The number of subdirectories should be the same as the number of
%        acquisitions for the DWI.
%
% INDEX_VECTOR
%        (vector, array of integers) digital IDs user sets for subjects.
%        For example: index_vector = [1 3 4:6] 
%                     The ID of the second subject is 3.
%                     The resultant folder for the second subject is like 
%                     '/data/Handled_Data/00003/'.
%
% NII_OUTPUT_PATH
%        (string) the path of folder storing resultant folders for all 
%        subjects
%        For example: '/data/Handled_Data/'.
%
% FILE_PREFIX
%        (string) basename for the output files
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
%                execute with only one computer
%            'qsub'  : 
%                execute in a distributed environment such as SGE, PBS 
%
%        max_queued
%            (integer) The maximum number of jobs that can be processed 
%            simultaneously.
%            ('batch' mode) default value is 'quantity of cores'
%            ('qsub' mode) default value is Inf
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
% DTI_OPT
%        If dti_opt = 'default', then the default values will be
%        assigned to all its fields.
%
%        (structure) with the following fields :
%
%        SkullRemoval_f
%            (float, default 0.25)
%            Fractional intensity threshold (0->1); smaller values give 
%            larger brain outline estimates. 
%
%        Cropping_gap
%            (integer, default 3)
%            The distance from the selected cube to the border of the
%            brain.
%
%        Normalizing_resolution
%            (integer, default 2)
%            If the value is 2, the final voxel size will be 2*2*2.
%
%        Smoothing_kernel
%            (integer, default 6)
%            Gaussian smoothing kernel size.
%
%        Normalizing_target
%            (string, default FMRIB58_FA standard space image)
%            The full path of template for registering FA of native space 
%            to MNI space.
%            default: $PANDADIR/data/Templates/FMRIB58_FA_1mm.nii.gz
%
%        WM_label_atlas
%            (string, default ICBM-DTI-81 WM labels atlas)
%            The full path of white matter atlas for calculating regional 
%            diffusion metrics.
%            default: $PANDADIR/data/atlases/rICBM_DTI/rICBM_DTI_81_WMPM_FMRIB58.nii.gz
%
%        WM_probtract_atlas
%            (string, default JHU WM tractography atlas)
%            The full path of white matter atlas for calculating regional 
%            diffusion metrics.
%            default: $PANDADIR/data/atlases/rICBM_DTI/JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz
%
%        Delete_rawNII
%            (integer, 0 or 1, default 1)
%            1 : delete raw nii converted from DICOM.
%
%        Applying_TBSS
%            (integer, 0 or 1, default 0)
%            1 : apply TBSS.
%
%        Skeleton_cutoff
%            (float, only needed when Applying_TBSS is 1, default 0.2)
%            FA threshold to exclude voxels in the grey matter or CSF.
%            Please reference:http://www.fmrib.ox.ac.uk/fsl/tbss/index.html
%
% TRACKING_OPT
%        If tracking_opt = 'default', then the default values will be
%        assigned to all its fields.
%
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
%            T1orPartitionOfSubjects_PathCell
%              (cell of strings, only needed when tracking_opt.NetworkNode 
%              is 1)
%              There are 2 possibilities under each cell:
%              (1) If tracking_opt.PartitionOfSubjects = 1, full path of
%              subjects' parcellated image in native space
%              (2) If tracking_opt.T1 = 1, full path of subjects' T1 image
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
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: dti, pipeline, psom
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

global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));



if nargin <= 0
    disp('Please input subjects'' raw data (DICOM or NIfTI).');
    disp('see the help, type ''help g_dti_pipeline''.');
elseif ~iscell(Data_Raw_Path_Cell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_dti_pipeline''.');
else
    if nargin <= 3
        File_Prefix = '';
    end
    [RawDataRows, RawDataColumns] = size(Data_Raw_Path_Cell);
    if RawDataColumns ~= 1
        disp('The quantity of columns of raw data cell should be 1.');
        disp('Data_Raw_Path_Cell is a n*1 matrix.');
        disp('see the help, type ''help g_dti_pipeline''.');
    elseif nargin <= 1
        disp('Please assign IDs for the subjects.');
        disp('see the help, type ''help g_dti_pipeline''.');
    elseif RawDataRows ~= length(index_vector)
        disp('The quantity of raw data should be equal to the quantity of IDs.');
        disp('see the help, type ''help g_dti_pipeline''.');
    elseif nargin <= 2
        disp('Please input the path of folder storing the resultant files.');
        disp('see the help, type ''help g_dti_pipeline''.');
    else
        
        psom_gb_vars;
        
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

        if nargin <= 4
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
            pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
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
            pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
        elseif nargin >= 5
            
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
                pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
            else
                pipeline_opt.path_logs = [pipeline_opt.path_logs '/logs/'];
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

        if nargin <= 5
            % The default value of opt will be used
            dti_opt.RawDataResample_Flag = 1;
            dti_opt.RawDataResampleResolution = [2 2 2];
            dti_opt.Inversion = 'No Inversion';
            dti_opt.Swap = 'No Swap';
            dti_opt.SkullRemoval_f = 0.25;
            dti_opt.Cropping_Flag = 1;
            dti_opt.Cropping_gap = 3;
            dti_opt.Normalizing_resolution = 2;
            dti_opt.Smoothing_kernel = 6;
            dti_opt.Normalizing_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
            dti_opt.WM_label_atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
            dti_opt.WM_probtract_atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
            dti_opt.Delete_rawNII = 1;
            dti_opt.Applying_TBSS = 0;
        elseif ~isstruct(dti_opt) && ~strcmp(dti_opt, 'default')
            disp('The value of the sixth parameter dti opt is invalid.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        elseif strcmp(dti_opt, 'default')
            % The default value of opt will be used
            clear dti_opt;
            dti_opt.RawDataResample_Flag = 1;
            dti_opt.RawDataResampleResolution = [2 2 2];
            dti_opt.Inversion = 'No Inversion';
            dti_opt.Swap = 'No Swap';
            dti_opt.SkullRemoval_f = 0.25;
            dti_opt.Cropping_Flag = 1;
            dti_opt.Cropping_gap = 3;
            dti_opt.Normalizing_resolution = 2;
            dti_opt.Smoothing_kernel = 6;
            dti_opt.Normalizing_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
            dti_opt.WM_label_atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
            dti_opt.WM_probtract_atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
            dti_opt.Delete_rawNII = 1;
            dti_opt.Applying_TBSS = 0;
        else
            
            if ~isfield(dti_opt, 'RawDataResample_Flag'),dti_opt.RawDataResample_Flag = 1;end;
            if dti_opt.RawDataResample_Flag
                if ~isfield(dti_opt, 'RawDataResampleResolution'),dti_opt.RawDataResampleResolution = [2 2 2];end;
            end
            if ~isfield(dti_opt, 'Inversion'),dti_opt.Inversion = 'No Inversion';end;
            if ~isfield(dti_opt, 'Swap'),dti_opt.Swap = 'No Swap';end;
            if ~isfield(dti_opt, 'SkullRemoval_f'),dti_opt.SkullRemoval_f = 0.25;end;
            if ~isfield(dti_opt, 'Cropping_Flag'),dti_opt.Cropping_Flag = 1;end;
            if dti_opt.Cropping_Flag
                if ~isfield(dti_opt, 'Cropping_gap'),dti_opt.Cropping_gap = 3;end;
            end
            if ~isfield(dti_opt, 'Normalizing_resolution'),dti_opt.Normalizing_resolution = 2;end;
            if ~isfield(dti_opt, 'Normalizing_resolution'),dti_opt.Normalizing_resolution = 2;end;
            if ~isfield(dti_opt, 'Smoothing_kernel'),dti_opt.Smoothing_kernel = 2;end;
            if ~isfield(dti_opt, 'Normalizing_target')
                dti_opt.Normalizing_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
            end
            if ~isfield(dti_opt, 'WM_label_atlas')
                dti_opt.WM_label_atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
            end
            if ~isfield(dti_opt, 'WM_probtract_atlas')
                dti_opt.WM_probtract_atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
            end
            if ~isfield(dti_opt, 'Delete_rawNII'),dti_opt.Delete_rawNII = 1;end;
            if ~isfield(dti_opt, 'Applying_TBSS')
                dti_opt.Applying_TBSS = 0;
            elseif dti_opt.Applying_TBSS == 1
                if ~isfield(dti_opt, 'Skeleton_cutoff')
                    dti_opt.Skeleton_cutoff = 0.2;
                end
            end
            
            DTIOptFields = {'RawDataResample_Flag', 'RawDataResampleResolution', 'SkullRemoval_f', 'Cropping_Flag', ...
                'Cropping_gap', 'Normalizing_resolution', 'Smoothing_kernel', 'Normalizing_target', ...
                'WM_label_atlas', 'WM_probtract_atlas', 'Delete_rawNII', 'Applying_TBSS', 'Skeleton_cutoff'};
            DTIOptFields_UserInputs = fieldnames(dti_opt);
            for i = 1:length(DTIOptFields_UserInputs)
                if isempty(find(strcmp(DTIOptFields, DTIOptFields_UserInputs{i})))
                    disp([DTIOptFields_UserInputs{i} ' is not the field of dti opt.']);
                    disp('See the help, type ''help g_dti_pipeline''.');
                    return;
                end
            end
            
            if ~isnumeric(dti_opt.RawDataResample_Flag)
                disp('The RawDataResample_Flag of dti_opt should be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.RawDataResample_Flag ~= 1 && dti_opt.RawDataResample_Flag ~= 0
                disp('The RawDataResample_Flag of dti_opt should be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.RawDataResample_Flag
                try 
                    if length(eval(dti_opt.RawDataResample_Flag)) ~= 3
                        disp('The RawDataResampleResolution of dti_opt should be a vector with 3 elements.');
                        disp('see the help, type ''help g_dti_pipeline''.');
                        return;
                    end
                catch
                    disp('The RawDataResampleResolution of dti_opt should be a vector with 3 elements.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
            end
            if ~strcmp(dti_opt.Inversion, 'No Inversion') && ~strcmp(dti_opt.Inversion, 'Invert X') ...
                && ~strcmp(dti_opt.Inversion, 'Invert Y') && ~strcmp(dti_opt.Inversion, 'Invert Z') 
                disp('The Inversion field of dti_opt should be ''No Inversion'', ''Invert X'', ''Invert Y'' or ''Invert Z''.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~strcmp(dti_opt.Swap, 'No Swap') && ~strcmp(dti_opt.Swap, 'Swap X/Y') ...
                && ~strcmp(dti_opt.Swap, 'Swap Y/Z') && ~strcmp(dti_opt.Swap, 'Swap Z/X')
                disp('The Swap field of dti_opt should be ''No Swap'', ''Swap X/Y'', ''Swap Y/Z'' or ''Swap Z/X''.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(dti_opt.SkullRemoval_f)
                disp('The SkullRemoval_f field of dti_opt should be a float number in the range of [0 1].');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.SkullRemoval_f > 1 || dti_opt.SkullRemoval_f < 0
                disp('The SkullRemoval_f field of dti_opt should be a float number in the range of [0 1].');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(dti_opt.Cropping_Flag)
                disp('The Cropping_Flag field of dti_opt shoud be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Cropping_Flag ~= 0 && dti_opt.Cropping_Flag ~= 1
                disp('The Cropping_Flag field of dti_opt shoud be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Cropping_Flag
                if round(dti_opt.Cropping_gap) ~= dti_opt.Cropping_gap
                    disp('The Cropping_gap field of dti_opt shoud be an integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if dti_opt.Cropping_gap <= 0
                    disp('The Cropping_gap field of dti_opt shoud be an positive integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
            end
            if ~isnumeric(dti_opt.Normalizing_resolution)
                disp('The resample resolution can only be 1 or 2 temporarily, we will improve it in next version.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Normalizing_resolution ~= 1 && dti_opt.Normalizing_resolution ~= 2
                disp('The resample resolution can only be 1 or 2 temporarily, we will improve it in next version.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if round(dti_opt.Smoothing_kernel) ~= dti_opt.Smoothing_kernel
                disp('The Smoothing_kernel field of dti_opt shoud be an integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Smoothing_kernel <= 0
                disp('The Smoothing_kernel field of dti_opt shoud be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            [x exist_flag] = system(['imtest ' dti_opt.Normalizing_target]);
            exist_flag = str2num(exist_flag);
            if ~(exist_flag == 1)
                disp(['The file ' dti_opt.Normalizing_target ' doesn''t exist.']);
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~exist(dti_opt.WM_label_atlas, 'dir')
                disp(['The directory' dti_opt.WM_label_atlas 'doesn''t exist.']);
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~exist(dti_opt.WM_probtract_atlas, 'dir')
                disp(['The directory' dti_opt.WM_probtract_atlas 'doesn''t exist.']);
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(dti_opt.Delete_rawNII)
                disp('The Delete_rawNII field of dti_opt shoud be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Delete_rawNII ~= 0 && dti_opt.Delete_rawNII ~= 1
                disp('The Delete_rawNII field of dti_opt shoud be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(dti_opt.Applying_TBSS)
                disp('The Applying_TBSS field of dti_opt shoud be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Applying_TBSS ~= 0 && dti_opt.Applying_TBSS ~= 1
                disp('The Applying_TBSS field of dti_opt shoud be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if dti_opt.Applying_TBSS
                if ~isnumeric(dti_opt.Skeleton_cutoff)
                    disp('The Skeleton_cutoff field of dti_opt should be a float number in the range of [0 1].');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if dti_opt.Skeleton_cutoff > 1 || dti_opt.Skeleton_cutoff < 0
                    disp('The Skeleton_cutoff field of dti_opt should be a float number in the range of [0 1].');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
            end
        end
        % Convert the field of user inputs to program needs
        dti_opt_new = g_diffusion_opt(dti_opt);
        dti_opt = dti_opt_new;
        
        if nargin <= 6
            tracking_opt = g_tracking_opt();
        elseif ~isstruct(tracking_opt) && ~strcmp(tracking_opt, 'default')
            disp('The value of the seventh parameter tracking opt is invalid.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        elseif strcmp(tracking_opt, 'default')
            clear tracking_opt;
            tracking_opt = g_tracking_opt();
        else
            
            TrackingOptFields = {'DeterminFiberTracking', 'NetworkNode', 'DeterministicNetwork', 'BedpostxProbabilisticNetwork', ...
                'ImageOrientation', 'PropagationAlgorithm', 'StepLength', 'AngleThreshold', 'MaskThresMin', 'T1', ...
                'MaskThresMax', 'RandomSeed_Flag', 'RandomSeed', 'Inversion', 'Swap', 'ApplySplineFilter', 'PartitionOfSubjects', ...
                'T1Bet_Flag', 'T1BetF', 'T1Cropping_flag', 'T1CroppingGap', 'T1Resample_Flag', 'T1ResampleResolution', ...
                'PartitionTemplate', 'Weight', 'Burnin', 'Fibers', 'LabelIdVector', 'ProbabilisticTrackingType', 'FAPathCell', ...
                'T1orPartitionOfSubjects_PathCell'};
            TrackingOptFields_UserInputs = fieldnames(tracking_opt);
            for i = 1:length(TrackingOptFields_UserInputs)
                if isempty(find(strcmp(TrackingOptFields, TrackingOptFields_UserInputs{i})))
                    disp([TrackingOptFields_UserInputs{i} ' is not the field of tracking opt.']);
                    disp('See the help, type ''help g_dti_pipeline''.');
                    return;
                end
            end
    
            tracking_opt_new = g_tracking_opt(tracking_opt);
            tracking_opt = tracking_opt_new;
        end
        
        if ~isnumeric(tracking_opt.DeterminFiberTracking)
            disp('The DeterminFiberTracking field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if tracking_opt.DeterminFiberTracking ~= 0 && tracking_opt.DeterminFiberTracking ~= 1
            disp('The DeterminFiberTracking field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.NetworkNode)
            disp('The NetworkNode field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if tracking_opt.NetworkNode ~= 0 && tracking_opt.NetworkNode ~= 1
            disp('The NetworkNode field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.DeterministicNetwork)
            disp('The DeterministicNetwork field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if tracking_opt.DeterministicNetwork ~= 0 && tracking_opt.DeterministicNetwork ~= 1
            disp('The DeterministicNetwork field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if ~isnumeric(tracking_opt.BedpostxProbabilisticNetwork)
            disp('The BedpostxProbabilisticNetwork field of tracking_opt should be 0 or 1.');
            disp('see the help, type ''help g_dti_pipeline''.');
            return;
        end
        if tracking_opt.BedpostxProbabilisticNetwork ~= 0 && tracking_opt.BedpostxProbabilisticNetwork ~= 1
            disp('The BedpostxProbabilisticNetwork field of tracking_opt should be 0 or 1.');
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
            if ~isnumeric(tracking_opt.PartitionOfSubjects)
                disp('The PartitionOfSubjects field of tracking_opt should be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if tracking_opt.PartitionOfSubjects ~= 0 && tracking_opt.PartitionOfSubjects ~= 1
                disp('The PartitionOfSubjects field of tracking_opt should be 0 or 1.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(tracking_opt.T1)
                disp('The T1 field of tracking_opt should be 0 or 1.');
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
            if ~isfield(tracking_opt, 'T1orPartitionOfSubjects_PathCell')
                if tracking_opt.PartitionOfSubjects
                    disp('Please input subjects'' parcellated images, since the tracking_opt.PartitionOfSubjects is 1.');
                    disp('Assign value for T1orPartitionOfSubjects_PathCell field of tracking_opt.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                elseif tracking_opt.T1
                    disp('Please input subjects'' T1 images, since the tracking_opt.T1 is 1.');
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
                if ~isnumeric(tracking_opt.T1Bet_Flag)
                    disp('The T1Bet_Flag of tracking_opt should be 0 or 1');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if tracking_opt.T1Bet_Flag ~= 0 && tracking_opt.T1Bet_Flag ~= 1
                    disp('The T1Bet_Flag of tracking_opt should be 0 or 1');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if ~isnumeric(tracking_opt.T1BetF)
                    disp('The T1BetF of tracking_opt shoud be an positive value (0->1).');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if tracking_opt.T1BetF < 0 || tracking_opt.T1BetF > 1
                    disp('The T1BetF of tracking_opt shoud be an positive value (0->1).');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if ~isnumeric(tracking_opt.T1Cropping_Flag)
                    disp('The T1Cropping_Flag of tracking_opt should be 0 or 1');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if tracking_opt.T1Cropping_Flag ~= 0 && tracking_opt.T1Cropping_Flag ~= 1
                    disp('The T1Cropping_Flag of tracking_opt should be 0 or 1');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end    
                if ~isnumeric(tracking_opt.T1CroppingGap)
                    disp('The T1CroppingGap of the tracking_opt shoud be an positive integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if round(tracking_opt.T1CroppingGap) ~= tracking_opt.T1CroppingGap
                    disp('The T1CroppingGap of the tracking_opt shoud be an integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if tracking_opt.T1CroppingGap <= 0
                    disp('The T1CroppingGap of the tracking_opt shoud be an positive integer.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if ~isnumeric(tracking_opt.T1Resample_Flag)
                    disp('The T1Resample_Flag of tracking_opt should be 0 or 1.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                if tracking_opt.T1Resample_Flag ~= 0 && tracking_opt.T1Resample_Flag ~= 1
                    disp('The T1Resample_Flag of tracking_opt should be 0 or 1.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end 
                try
                    if length(tracking_opt.T1ResampleResolution) ~= 3
                        disp('The T1ResampleResolution of tracking_opt should be 3 integers.');
                        disp('see the help, type ''help g_dti_pipeline''.');
                        return;
                    end
                catch
                    disp('The T1ResampleResolution of tracking_opt is illegal.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
                [x exist_flag] = system(['imtest ' tracking_opt.PartitionTemplate]);
                exist_flag = str2num(exist_flag);
                if ~(exist_flag == 1)
                    disp('The partition atlas doesn''t exist.');
                    disp('see the help, type ''help g_dti_pipeline''.');
                    return;
                end
            end
        end
        
        if tracking_opt.BedpostxProbabilisticNetwork
            if ~isnumeric(tracking_opt.Weight)
                disp('The Weight field of tracking_opt should be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if round(tracking_opt.Weight) ~= tracking_opt.Weight || tracking_opt.Weight < 0
                disp('The Weight field of tracking_opt should be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(tracking_opt.Burnin)
                disp('The Burnin field of tracking_opt should be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if round(tracking_opt.Burnin) ~= tracking_opt.Burnin || tracking_opt.Burnin < 0
                disp('The Burnin field of tracking_opt should be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~isnumeric(tracking_opt.Fibers)
                disp('The Fibers field of tracking_opt should be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if round(tracking_opt.Fibers) ~= tracking_opt.Fibers || tracking_opt.Fibers < 0
                disp('The Fibers field of tracking_opt should be an positive integer.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
            if ~strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD') && ~strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
                disp('The ProbabilisticTrackingType field of tracking_opt should be an ''OPD'' or ''PD''.');
                disp('see the help, type ''help g_dti_pipeline''.');
                return;
            end
        end
        
        try 
            ResultPathPermissionDenied = 0;
            if ~exist(Nii_Output_Path, 'dir')
                mkdir(Nii_Output_Path);
            end
            if ~exist([Nii_Output_Path filesep 'logs'], 'dir')
                mkdir([Nii_Output_Path filesep 'logs']);
            end
            x = 1;
            save([Nii_Output_Path filesep 'logs' filesep 'permission_tag.mat'], 'x');
        catch
            ResultPathPermissionDenied = 1;
            disp('Please change result path, perssion denied !');
        end

        if ~ResultPathPermissionDenied
            
            % Handle the data one subject after one and make them a big pipeline  
            for i = 1:length(Data_Raw_Path_Cell)

                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                if ~strcmp( Data_Raw_Path_Cell{i}(end),'/' )
                    Data_Raw_Path_Cell{i} = [Data_Raw_Path_Cell{i},'/'];
                end

                % Calculate the quantity of the sequences
%                 Quantity_Of_Sequence = g_Calculate_Sequence( Data_Raw_Path_Cell{i} );
                Quantity_Of_Sequence = length(dir(Data_Raw_Path_Cell{i})) - 2;

                % Basename for the output file of the dtifit
                if isempty(File_Prefix) 
                    dtifit_Prefix = Number_Of_Subject_String;
                else
                    dtifit_Prefix = [File_Prefix '_' Number_Of_Subject_String];
                end

                if ~strcmp( Nii_Output_Path(end),'/' )
                    Nii_Output_Path = [Nii_Output_Path,'/'];
                end
                SubjectFolder = [Nii_Output_Path Number_Of_Subject_String];
                if ~exist(SubjectFolder, 'dir')
                    mkdir(SubjectFolder);
                end
                % Create a folder to store temporary file
                Tmp_Folder = [Nii_Output_Path Number_Of_Subject_String filesep 'tmp'];
                if ~exist(Tmp_Folder,'dir')
                    mkdir(Tmp_Folder);
                end
                % Create a folder to store .done files
                Output_Done_Folder = [Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'OutputDone'];
                if ~exist(Output_Done_Folder,'dir')
                    mkdir(Output_Done_Folder);
                end
                % Create a folder to store quantity control files
                Quality_Control_Folder = [Nii_Output_Path Number_Of_Subject_String filesep 'quality_control'];
                if ~exist(Quality_Control_Folder,'dir')
                    mkdir(Quality_Control_Folder);
                end
                % Create a folder to store image files in native space
                Native_Folder = [Nii_Output_Path Number_Of_Subject_String filesep 'native_space'];
                if ~exist(Native_Folder,'dir')
                    mkdir(Native_Folder);
                end
                % Create a folder to store transformated image files
                Transformation_Folder = [Nii_Output_Path Number_Of_Subject_String filesep 'transformation'];
                if ~exist(Transformation_Folder,'dir')
                    mkdir(Transformation_Folder);
                end
                % Create a folder to store image files in non-linear space
                NonLinear_Folder = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space'];
                if ~exist(NonLinear_Folder,'dir')
                    mkdir(NonLinear_Folder);
                end

                % Save the raw path and the path of nii data to matrix file
                variable_name = ['subject_info_',Number_Of_Subject_String];
                Subject_Info_File = [Nii_Output_Path,'subject_info.mat'];
                tmp = [Data_Raw_Path_Cell{i} '  ' Nii_Output_Path Number_Of_Subject_String '/'];
                eval([variable_name '=tmp;']);
                if ~exist(Subject_Info_File,'file')
                    save(Subject_Info_File,variable_name);
                else
                    % don't need to checking wether the data is already exist,because
                    %this command will cover variables with the same name
                    save(Subject_Info_File,variable_name,'-append');
                end

                % Save the raw path and the path of nii data to txt file
                fid = fopen(cat(2, Nii_Output_Path, 'subject_info.txt'), 'a+');
                % check whether the subject information is already exist
                exist_flag = 0; % 0:not exist  1:exist
                while(~feof(fid))
                    raw_path = fscanf(fid, '%s', [1]);
                    nii_path = fscanf(fid, '%s', [1]);
                    if(strcmp(raw_path,Data_Raw_Path_Cell{i}))
                        exist_flag = 1;
                        break;
                    end
               end
               if exist_flag == 0
                    fprintf(fid, Data_Raw_Path_Cell{i});fprintf(fid, ' \t');
                    fprintf(fid, [Nii_Output_Path Number_Of_Subject_String '/']);fprintf(fid, '\n');
               end
               fclose(fid);

                % Define jobs
                
                % dcm2nii_dwi job
                Job_Name1 = [ 'dcm2nii_dwi_',Number_Of_Subject_String ];
                pipeline.(Job_Name1).command             =  'g_dcm2nii_dwi( opt.Data_Raw_Folder_Path,opt.Nii_Output_Folder_Path,opt.Prefix )';
                pipeline.(Job_Name1).files_in            =  {};
                   % if the files specified in the files_out.files are successfully
                   % produced, the job is successfull
                pipeline.(Job_Name1).files_out.files     =  g_dcm2nii_dwi_FileOut( Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dtifit_Prefix );
                   % option of the job, will be used as parameters of g_dcm2nii_dwi
                pipeline.(Job_Name1).opt.Data_Raw_Folder_Path    =  Data_Raw_Path_Cell{i};
                pipeline.(Job_Name1).opt.Nii_Output_Folder_Path    =  [Nii_Output_Path filesep Number_Of_Subject_String filesep];
                pipeline.(Job_Name1).opt.Prefix          = dtifit_Prefix;
                
                if dti_opt.RawDataResample_Flag
                    % ResampleRawData job
                    Job_Name90 = [ 'ResampleRawData_',Number_Of_Subject_String ];
                    pipeline.(Job_Name90).command             =  'for m = 1:length(opt.RawData);g_resample_nii(opt.RawData{m},opt.ResampleResolution,files_out.files{m});end';
                    pipeline.(Job_Name90).files_in.files      =  pipeline.(Job_Name1).files_out.files;
                    for j = 1:Quantity_Of_Sequence
                        pipeline.(Job_Name90).opt.RawData{j}  = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(j,'%02.0f') '.nii.gz'];
                    end
                    pipeline.(Job_Name90).opt.ResampleResolution = dti_opt.RawDataResampleResolution;
                    for j = 1:Quantity_Of_Sequence
                        pipeline.(Job_Name90).files_out.files{j} = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(j,'%02.0f') '_resample.nii.gz'];
                    end
                end

                % ResampleRawData job
                if ~strcmp(dti_opt.Inversion, 'No Inversion') && ~strcmp(dti_opt.Swap, 'No Swap')
                    Job_Name91 = [ 'OrientationPatch_',Number_Of_Subject_String ];
                    pipeline.(Job_Name91).command             =  'g_OrientationPatch(opt.Bvecs_File,opt.Inversion,opt.Swap)';
                    pipeline.(Job_Name91).files_in.files      = pipeline.(Job_Name1).files_out.files;
                    for j = 1:Quantity_Of_Sequence
                        pipeline.(Job_Name91).opt.Bvecs_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 2};
                    end
                    pipeline.(Job_Name91).opt.Inversion       = dti_opt.Inversion;
                    pipeline.(Job_Name91).opt.Swap            = dti_opt.Swap;
                    for j = 1:Quantity_Of_Sequence
                        pipeline.(Job_Name91).files_out.files{j}  = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'tmp' filesep dtifit_Prefix '_bvecs_' num2str(i,'%02.0f') '_Orientation'];
                    end
                end

                % extractB0 job
                Job_Name2 = [ 'extractB0_',Number_Of_Subject_String ];
                pipeline.(Job_Name2).command             = 'g_extractB0 ( opt.DWI_File,0)';
                if ~dti_opt.RawDataResample_Flag
                    pipeline.(Job_Name2).files_in.files  = pipeline.(Job_Name1).files_out.files;
                    pipeline.(Job_Name2).opt.DWI_File    = pipeline.(Job_Name1).files_out.files{3};
                else
                    pipeline.(Job_Name2).files_in.files  = pipeline.(Job_Name90).files_out.files;
                    pipeline.(Job_Name2).opt.DWI_File    = pipeline.(Job_Name90).files_out.files{1};
                end
                pipeline.(Job_Name2).files_out.files     = g_extractB0_FileOut( Nii_Output_Path,Number_Of_Subject_String );

                % BET job 
                Job_Name3 = [ 'BET_1_',Number_Of_Subject_String ];
                pipeline.(Job_Name3).command                 = 'g_BET( opt.BET_File,opt.f )';
                pipeline.(Job_Name3).files_in.files          = pipeline.(Job_Name2).files_out.files;
                pipeline.(Job_Name3).files_out.files         = g_BET_1_FileOut( Nii_Output_Path,Number_Of_Subject_String );
                pipeline.(Job_Name3).opt.BET_File            = pipeline.(Job_Name2).files_out.files{1};
                pipeline.(Job_Name3).opt.f                   = dti_opt.BET_1_f;

                % NIIcrop job
                if dti_opt.Cropping_Flag
                    Job_Name4 = [ 'Split_Crop_',Number_Of_Subject_String ];    
                else
                    Job_Name4 = [ 'Split_',Number_Of_Subject_String ];  
                end
                Job_Name4 = [ 'NIIcrop_',Number_Of_Subject_String ];
                pipeline.(Job_Name4).command             = 'g_NIIcrop( opt.DWI_File,opt.MaskFileName,opt.Cropping_Flag,opt.slice_gap )';
                pipeline.(Job_Name4).files_in.files      = pipeline.(Job_Name3).files_out.files;
                pipeline.(Job_Name4).files_out.files     = g_NIIcrop_FileOut( Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dti_opt.NIIcrop_suffix_flag,dtifit_Prefix );
                pipeline.(Job_Name4).files_out.variables = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'NIIcrop_output.mat']};
                for j = 1:Quantity_Of_Sequence
                    pipeline.(Job_Name4).opt.DWI_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 3};
                end
                pipeline.(Job_Name4).opt.MaskFileName    = pipeline.(Job_Name3).files_out.files{2};
                pipeline.(Job_Name4).opt.slice_gap       = dti_opt.NIIcrop_slice_gap;
                pipeline.(Job_Name4).opt.Cropping_Flag   = dti_opt.Cropping_Flag;

                % EDDYCURRENT job
                Job_Name5 = [ 'EDDYCURRENT_',Number_Of_Subject_String ];
                pipeline.(Job_Name5).command                = 'g_EDDYCURRENT( opt.B0_File,files_in.variables{1},opt.QuantityOfSequence,opt.Prefix )';
                pipeline.(Job_Name5).files_in.files         = pipeline.(Job_Name4).files_out.files;
                pipeline.(Job_Name5).files_in.variables     = pipeline.(Job_Name4).files_out.variables;
                pipeline.(Job_Name5).files_out.files        = g_EDDYCURRENT_FileOut( Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dtifit_Prefix );
                pipeline.(Job_Name5).files_out.variables    = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'EDDYCURRENT_output.mat']};
                pipeline.(Job_Name5).opt.B0_File            = pipeline.(Job_Name4).files_out.files{1};
                pipeline.(Job_Name5).opt.QuantityOfSequence = Quantity_Of_Sequence;
                pipeline.(Job_Name5).opt.Prefix             = dtifit_Prefix;

                % average job
                Job_Name6 = [ 'average_',Number_Of_Subject_String ];
                pipeline.(Job_Name6).command                     = 'g_average( files_in.variables{1},opt.QuantityOfSequence,opt.Prefix )';
                pipeline.(Job_Name6).files_in.files              = pipeline.(Job_Name5).files_out.files;
                pipeline.(Job_Name6).files_in.variables          = pipeline.(Job_Name5).files_out.variables;
                pipeline.(Job_Name6).files_out.files             = g_average_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name6).files_out.variables         = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'average_output.mat']};
                pipeline.(Job_Name6).opt.DataNii_folder          = [Nii_Output_Path Number_Of_Subject_String '/'];     
                pipeline.(Job_Name6).opt.QuantityOfSequence      = Quantity_Of_Sequence;
                pipeline.(Job_Name6).opt.Prefix                  = dtifit_Prefix;

                % BET_2 job
                Job_Name7 = [ 'BET_2_',Number_Of_Subject_String ];
                pipeline.(Job_Name7).command               = 'g_BET( opt.BET_File,opt.f )';
                pipeline.(Job_Name7).files_in.files        = pipeline.(Job_Name6).files_out.files;
                pipeline.(Job_Name7).files_out.files       = g_BET_2_FileOut( Nii_Output_Path,Number_Of_Subject_String );
                pipeline.(Job_Name7).opt.BET_File          = pipeline.(Job_Name6).files_out.files{4};  % b0 file
                pipeline.(Job_Name7).opt.f                 = dti_opt.BET_2_f;

                % merge job
                Job_Name8 = [ 'merge_',Number_Of_Subject_String ];
                pipeline.(Job_Name8).command               =  'g_merge( opt.Nii_Output_Folder_Path,files_in.variables{1},opt.Prefix,opt.MaskFile )';
                pipeline.(Job_Name8).files_in.files        =  pipeline.(Job_Name7).files_out.files;
                pipeline.(Job_Name8).files_in.variables    =  pipeline.(Job_Name6).files_out.variables;
                pipeline.(Job_Name8).files_out.files       =  g_merge_FileOut( Nii_Output_Path,Number_Of_Subject_String );
                pipeline.(Job_Name8).opt.Nii_Output_Folder_Path    =  [Nii_Output_Path Number_Of_Subject_String filesep];
                pipeline.(Job_Name8).opt.Prefix                    = dtifit_Prefix;
                pipeline.(Job_Name8).opt.MaskFile                  = [Nii_Output_Path Number_Of_Subject_String filesep 'native_space' filesep 'nodif_brain_mask.nii.gz'];

                % dtifit job
                Job_Name9 = [ 'dtifit_',Number_Of_Subject_String ];
                pipeline.(Job_Name9).command             = 'g_dtifit( opt.fdt_dir,opt.Prefix )';
                pipeline.(Job_Name9).files_in.files      = pipeline.(Job_Name8).files_out.files;
                pipeline.(Job_Name9).files_out.files     = g_dtifit_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name9).opt.fdt_dir         = [Nii_Output_Path Number_Of_Subject_String '/'];
                pipeline.(Job_Name9).opt.Prefix          = dtifit_Prefix;

                % FA_BeforeNormalize job
                Job_Name10 = [ 'BeforeNormalize_FA_',Number_Of_Subject_String ];
                pipeline.(Job_Name10).command                = 'g_BeforeNormalize( opt.FA_file )';
                pipeline.(Job_Name10).files_in.files         = pipeline.(Job_Name9).files_out.files;
                pipeline.(Job_Name10).files_out.files        = g_BeforeNormalize_FA_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name10).opt.FA_file            = pipeline.(Job_Name9).files_out.files{1};
                
                % MD_BeforeNormalize job
                Job_Name11 = [ 'BeforeNormalize_MD_',Number_Of_Subject_String ];
                pipeline.(Job_Name11).command                = 'g_BeforeNormalize( opt.MD_file )';
                pipeline.(Job_Name11).files_in.files         = pipeline.(Job_Name9).files_out.files;
                pipeline.(Job_Name11).files_out.files        = g_BeforeNormalize_MD_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name11).opt.MD_file            = pipeline.(Job_Name9).files_out.files{6};
                
                % L1_BeforeNormalize job
                Job_Name12 = [ 'BeforeNormalize_L1_',Number_Of_Subject_String ];
                pipeline.(Job_Name12).command                = 'g_BeforeNormalize( opt.L1_file )';
                pipeline.(Job_Name12).files_in.files         = pipeline.(Job_Name9).files_out.files;
                pipeline.(Job_Name12).files_out.files        = g_BeforeNormalize_L1_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name12).opt.L1_file            = pipeline.(Job_Name9).files_out.files{2};
                
                % L23m_BeforeNormalize job
                Job_Name13 = [ 'BeforeNormalize_L23m_',Number_Of_Subject_String ];
                pipeline.(Job_Name13).command                = 'g_BeforeNormalize( opt.L23m_file )';
                pipeline.(Job_Name13).files_in.files         = pipeline.(Job_Name9).files_out.files;
                pipeline.(Job_Name13).files_out.files        = g_BeforeNormalize_L23m_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name13).opt.L23m_file            = pipeline.(Job_Name9).files_out.files{5};
                
                % FAnormalize job
                Job_Name15 = [ 'FAnormalize_',Number_Of_Subject_String ];
                pipeline.(Job_Name15).command             = 'g_FAnormalize( opt.FA_4tbss_file,opt.target )';
                pipeline.(Job_Name15).files_in.files      = pipeline.(Job_Name10).files_out.files;
                pipeline.(Job_Name15).files_out.files     = g_FAnormalize_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name15).opt.FA_4tbss_file   = pipeline.(Job_Name10).files_out.files{1};
                pipeline.(Job_Name15).opt.target          = dti_opt.FAnormalize_target;
                
                % applywarp_1 job
                Job_Name16 = [ 'applywarp_FA_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name16).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.target_fileName )';
                pipeline.(Job_Name16).files_in.files    = pipeline.(Job_Name15).files_out.files;
                pipeline.(Job_Name16).files_out.files     = g_applywarp_1_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name16).opt.raw_file        = pipeline.(Job_Name10).files_out.files{1};
                pipeline.(Job_Name16).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                pipeline.(Job_Name16).opt.ref_fileName    = dti_opt.applywarp_1_ref_fileName;
                pipeline.(Job_Name16).opt.target_fileName = dti_opt.FAnormalize_target;
                
                % applywarp_3 job
                Job_Name18 = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name18).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                pipeline.(Job_Name18).files_in.files1     = pipeline.(Job_Name11).files_out.files;
                pipeline.(Job_Name18).files_in.files2     = pipeline.(Job_Name15).files_out.files;
                pipeline.(Job_Name18).files_out.files    = g_applywarp_3_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name18).opt.raw_file        = pipeline.(Job_Name11).files_out.files{1};
                pipeline.(Job_Name18).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                pipeline.(Job_Name18).opt.ref_fileName    = dti_opt.applywarp_3_ref_fileName;
                
                % applywarp_5 job
                Job_Name20 = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name20).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name12).files_out.files;
                pipeline.(Job_Name20).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                pipeline.(Job_Name20).files_out.files     = g_applywarp_5_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name20).opt.raw_file        = pipeline.(Job_Name12).files_out.files{1};
                pipeline.(Job_Name20).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                pipeline.(Job_Name20).opt.ref_fileName    = dti_opt.applywarp_5_ref_fileName;
                
                % applywarp_7 job
                Job_Name22 = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name22).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name13).files_out.files;
                pipeline.(Job_Name22).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                pipeline.(Job_Name22).files_out.files   = g_applywarp_7_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name22).opt.raw_file        = pipeline.(Job_Name13).files_out.files{1};
                pipeline.(Job_Name22).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                pipeline.(Job_Name22).opt.ref_fileName    = dti_opt.applywarp_7_ref_fileName;
                
                % applywarp_2 job
                if dti_opt.applywarp_2_ref_fileName ~= 1
                    Job_Name17 = [ 'applywarp_FA_',num2str(dti_opt.applywarp_2_ref_fileName),'mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name17).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                    pipeline.(Job_Name17).files_in.files    = pipeline.(Job_Name15).files_out.files;
                    pipeline.(Job_Name17).files_out.files     = g_applywarp_2_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_2_ref_fileName );
                    pipeline.(Job_Name17).opt.raw_file        = pipeline.(Job_Name10).files_out.files{1};
                    pipeline.(Job_Name17).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                    pipeline.(Job_Name17).opt.ref_fileName    = dti_opt.applywarp_2_ref_fileName;
                end
                
                % applywarp_4 job
                if dti_opt.applywarp_4_ref_fileName ~= 1
                    Job_Name19 = [ 'applywarp_MD_',num2str(dti_opt.applywarp_4_ref_fileName),'mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name19).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                    pipeline.(Job_Name19).files_in.files1    = pipeline.(Job_Name11).files_out.files;
                    pipeline.(Job_Name19).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                    pipeline.(Job_Name19).files_out.files    = g_applywarp_4_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_4_ref_fileName );
                    pipeline.(Job_Name19).opt.raw_file        = pipeline.(Job_Name11).files_out.files{1};
                    pipeline.(Job_Name19).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                    pipeline.(Job_Name19).opt.ref_fileName    = dti_opt.applywarp_4_ref_fileName;
                end
                
                % applywarp_6 job
                if dti_opt.applywarp_6_ref_fileName ~= 1
                    Job_Name21 = [ 'applywarp_L1_',num2str(dti_opt.applywarp_6_ref_fileName),'mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name21).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                    pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name12).files_out.files;
                    pipeline.(Job_Name21).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                    pipeline.(Job_Name21).files_out.files   = g_applywarp_6_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_6_ref_fileName );
                    pipeline.(Job_Name21).opt.raw_file        = pipeline.(Job_Name12).files_out.files{1};
                    pipeline.(Job_Name21).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                    pipeline.(Job_Name21).opt.ref_fileName    = dti_opt.applywarp_6_ref_fileName;
                end
                
                % applywarp_8 job
                if dti_opt.applywarp_8_ref_fileName ~= 1
                    Job_Name23 = [ 'applywarp_L23m_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name23).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName )';
                    pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name13).files_out.files;
                    pipeline.(Job_Name23).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                    pipeline.(Job_Name23).files_out.files   = g_applywarp_8_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_8_ref_fileName );
                    pipeline.(Job_Name23).opt.raw_file        = pipeline.(Job_Name13) .files_out.files{1};
                    pipeline.(Job_Name23).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
                    pipeline.(Job_Name23).opt.ref_fileName    = dti_opt.applywarp_8_ref_fileName;
                end

                % smoothNII_1 job
                Job_Name24 = [ 'smoothNII_FA_',num2str(dti_opt.applywarp_2_ref_fileName),'mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name24).command           = 'g_smoothNII( opt.fileName,opt.kernel_size )';
                if dti_opt.applywarp_2_ref_fileName ~= 1
                    pipeline.(Job_Name24).files_in.files    = pipeline.(Job_Name17).files_out.files;
                    pipeline.(Job_Name24).opt.fileName      = pipeline.(Job_Name17).files_out.files{1};
                else
                    pipeline.(Job_Name24).files_in.files    = pipeline.(Job_Name16).files_out.files;
                    pipeline.(Job_Name24).opt.fileName      = pipeline.(Job_Name16).files_out.files{1};
                end
                pipeline.(Job_Name24).files_out.files   = g_smoothNII_1_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_2_ref_fileName );
                
                pipeline.(Job_Name24).opt.kernel_size   = dti_opt.smoothNII_1_kernel_size;
                
                % smoothNII_2 job
                Job_Name25 = [ 'smoothNII_MD_',num2str(dti_opt.applywarp_4_ref_fileName),'mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name25).command           = 'g_smoothNII( opt.fileName,opt.kernel_size )';
                if dti_opt.applywarp_4_ref_fileName ~= 1
                    pipeline.(Job_Name25).files_in.files    = pipeline.(Job_Name19).files_out.files;
                    pipeline.(Job_Name25).opt.fileName      = pipeline.(Job_Name19).files_out.files{1};
                else
                    pipeline.(Job_Name25).files_in.files    = pipeline.(Job_Name18).files_out.files;
                    pipeline.(Job_Name25).opt.fileName      = pipeline.(Job_Name18).files_out.files{1};
                end
                pipeline.(Job_Name25).files_out.files   = g_smoothNII_2_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_4_ref_fileName );
                
                pipeline.(Job_Name25).opt.kernel_size   = dti_opt.smoothNII_2_kernel_size;
                
                % smoothNII_3 job
                Job_Name26 = [ 'smoothNII_L1_',num2str(dti_opt.applywarp_6_ref_fileName),'mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name26).command           = 'g_smoothNII( opt.fileName,opt.kernel_size )';
                if dti_opt.applywarp_6_ref_fileName ~= 1
                    pipeline.(Job_Name26).files_in.files    = pipeline.(Job_Name21).files_out.files;
                    pipeline.(Job_Name26).opt.fileName      = pipeline.(Job_Name21).files_out.files{1};
                else
                    pipeline.(Job_Name26).files_in.files    = pipeline.(Job_Name20).files_out.files;
                    pipeline.(Job_Name26).opt.fileName      = pipeline.(Job_Name20).files_out.files{1};
                end
                pipeline.(Job_Name26).files_out.files   = g_smoothNII_3_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_6_ref_fileName );
                pipeline.(Job_Name26).opt.kernel_size   = dti_opt.smoothNII_3_kernel_size;
                
                % smoothNII_4 job
                Job_Name27 = [ 'smoothNII_L23m_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name27).command           = 'g_smoothNII( opt.fileName,opt.kernel_size )';
                if dti_opt.applywarp_6_ref_fileName ~= 1
                    pipeline.(Job_Name27).files_in.files    = pipeline.(Job_Name23).files_out.files;
                    pipeline.(Job_Name27).opt.fileName      = pipeline.(Job_Name23).files_out.files{1};
                else
                    pipeline.(Job_Name27).files_in.files    = pipeline.(Job_Name22).files_out.files;
                    pipeline.(Job_Name27).opt.fileName      = pipeline.(Job_Name22).files_out.files{1};
                end
                pipeline.(Job_Name27).files_out.files   = g_smoothNII_4_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_8_ref_fileName );
                pipeline.(Job_Name27).opt.kernel_size   = dti_opt.smoothNII_4_kernel_size;

            end

            Job_Name93 = 'Split_WMLabel';
            pipeline.(Job_Name93).command  = 'g_Split_ROI(opt.AtlasImage, opt.ResultantFolder, opt.JobName)';
            %     pipeline.(Job_Name93).files_in.files = pipeline.(Job_Name2).files_out.files;
            pipeline.(Job_Name93).opt.AtlasImage = dti_opt.WM_Label_Atlas;
            pipeline.(Job_Name93).opt.ResultantFolder = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
            pipeline.(Job_Name93).opt.JobName    =  Job_Name93;
            pipeline.(Job_Name93).files_out.files{1}  = [Nii_Output_Path filesep 'logs' filesep Job_Name93 '.done'];
            
            Job_Name94 = 'Split_WMProbtract';
            pipeline.(Job_Name94).command   = 'g_Split_ROI(opt.AtlasImage, opt.ResultantFolder, opt.JobName)';
            %     pipeline.(Job_Name94).files_in.files = pipeline.(Job_Name2).files_out.files;
            pipeline.(Job_Name94).opt.AtlasImage = dti_opt.WM_Probtract_Atlas;
            pipeline.(Job_Name94).opt.ResultantFolder = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
            pipeline.(Job_Name94).opt.JobName    =  Job_Name94;
            pipeline.(Job_Name94).files_out.files{1}  = [Nii_Output_Path filesep 'logs' filesep Job_Name94 '.done'];
            
            for i = 1:length(Data_Raw_Path_Cell)

                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                SubjectFolder = [Nii_Output_Path Number_Of_Subject_String];
                Native_Folder = [SubjectFolder filesep 'native_space'];
                % Basename for the output file of the dtifit
                if isempty(File_Prefix)
                    dtifit_Prefix = Number_Of_Subject_String;
                else
                    dtifit_Prefix = [File_Prefix '_' Number_Of_Subject_String];
                end
                    
                % JHUatlas_1mm_1 job
                Job_Name28 = [ 'atlas_FA_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name28).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas )';
                Applywarp_FA_JobName = [ 'applywarp_FA_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name28).files_in.files    = pipeline.(Applywarp_FA_JobName).files_out.files;
                pipeline.(Job_Name28).files_out.files   = g_JHUatlas_1mm_1_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name28).opt.Dmetric_fileName    = pipeline.(Applywarp_FA_JobName).files_out.files{1};
                pipeline.(Job_Name28).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
                pipeline.(Job_Name28).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
                
                % JHUatlas_1mm_2 job
                Job_Name29 = [ 'atlas_MD_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name29).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas )';
                Applywarp_MD_JobName = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name29).files_in.files    = pipeline.(Applywarp_MD_JobName).files_out.files;
                pipeline.(Job_Name29).files_out.files   = g_JHUatlas_1mm_2_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name29).opt.Dmetric_fileName    = pipeline.(Applywarp_MD_JobName).files_out.files{1};
                pipeline.(Job_Name29).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
                pipeline.(Job_Name29).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
                
                % JHUatlas_1mm_3 job
                Job_Name30 = [ 'atlas_L1_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name30).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas )';
                Applywarp_L1_JobName = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name30).files_in.files    = pipeline.(Applywarp_L1_JobName).files_out.files;
                pipeline.(Job_Name30).files_out.files   = g_JHUatlas_1mm_3_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name30).opt.Dmetric_fileName    = pipeline.(Applywarp_L1_JobName).files_out.files{1};
                pipeline.(Job_Name30).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
                pipeline.(Job_Name30).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
                
                % JHUatlas_1mm_4 job
                Job_Name31 = [ 'atlas_L23m_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name31).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas )';
                Applywarp_L23m_JobName = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name31).files_in.files    = pipeline.(Applywarp_L23m_JobName).files_out.files;
                pipeline.(Job_Name31).files_out.files   = g_JHUatlas_1mm_4_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                pipeline.(Job_Name31).opt.Dmetric_fileName    = pipeline.(Applywarp_L23m_JobName).files_out.files{1};
                pipeline.(Job_Name31).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
                pipeline.(Job_Name31).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];

                % delete tmporary file
                Job_Name32 = [ 'delete_tmp_file_',Number_Of_Subject_String ];
                pipeline.(Job_Name32).command           = 'g_delete_tmp_file( opt.Nii_Output_Folder_Path,opt.Delete_Flag,opt.QuantityOfSequence,opt.Prefix )';
                pipeline.(Job_Name32).files_in.files{1} = pipeline.(Job_Name24).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{2} = pipeline.(Job_Name25).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{3} = pipeline.(Job_Name26).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{4} = pipeline.(Job_Name27).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{5} = pipeline.(Job_Name28).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{6} = pipeline.(Job_Name28).files_out.files{2};
                pipeline.(Job_Name32).files_in.files{7} = pipeline.(Job_Name29).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{8} = pipeline.(Job_Name29).files_out.files{2};
                pipeline.(Job_Name32).files_in.files{9} = pipeline.(Job_Name30).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{10} = pipeline.(Job_Name30).files_out.files{2};
                pipeline.(Job_Name32).files_in.files{11} = pipeline.(Job_Name31).files_out.files{1};
                pipeline.(Job_Name32).files_in.files{12} = pipeline.(Job_Name31).files_out.files{2};
                pipeline.(Job_Name32).files_out.files   = g_delete_tmp_file_FileOut( Nii_Output_Path,Number_Of_Subject_String );
                pipeline.(Job_Name32).opt.Nii_Output_Folder_Path    = [Nii_Output_Path filesep Number_Of_Subject_String '/'];
                pipeline.(Job_Name32).opt.Delete_Flag               = dti_opt.Delete_Flag;
                pipeline.(Job_Name32).opt.QuantityOfSequence        = Quantity_Of_Sequence;
                pipeline.(Job_Name32).opt.Prefix                     = dtifit_Prefix;

            end

            if dti_opt.TBSS_Flag
                % Generate FA skeleton mask distance map
                Job_Name33 = 'TBSSDismap';
                pipeline.(Job_Name33).command           = 'g_dismap( opt.FA_normalized_1mm_cell, opt.Nii_Output_Path, opt.threshold )';
                for i = 1:length(Data_Raw_Path_Cell)
                    Number_Of_Subject = index_vector(i);
                    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            %         Delete_Tmp_Job_Name = [ 'delete_tmp_file_' Number_Of_Subject_String ];
            %         pipeline.(Job_Name33).files_in.files{i} = pipeline.(Delete_Tmp_Job_Name).files_out.files{1};
                    FANormalize_1mm_Job_Name = [ 'applywarp_FA_1mm_' Number_Of_Subject_String ];
                    pipeline.(Job_Name33).files_in.files{i} = pipeline.(FANormalize_1mm_Job_Name).files_out.files{1};
                    pipeline.(Job_Name33).opt.FA_normalized_1mm_cell{i}  = pipeline.(FANormalize_1mm_Job_Name).files_out.files{1};
                end
                pipeline.(Job_Name33).files_out.files   = g_dismap_FileOut( Nii_Output_Path );
                pipeline.(Job_Name33).opt.Nii_Output_Path   = Nii_Output_Path;
                pipeline.(Job_Name33).opt.threshold         = dti_opt.dismap_threshold;
            end

            for i = 1:length(Data_Raw_Path_Cell)
                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                SubjectFolder = [Nii_Output_Path Number_Of_Subject_String];
                Native_Folder = [SubjectFolder filesep 'native_space'];

                % Basename for the output file of the dtifit
                if isempty(File_Prefix)
                    dtifit_Prefix = Number_Of_Subject_String;
                else
                    dtifit_Prefix = [File_Prefix '_' Number_Of_Subject_String];
                end

                if dti_opt.TBSS_Flag
                    % skeleton_FA job
                    Job_Name34 = [ 'skeleton_FA_',Number_Of_Subject_String ];
                    pipeline.(Job_Name34).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold )';
                    Applywarp_1_Name = [ 'applywarp_FA_1mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name34).files_in.files{1} = pipeline.(Applywarp_1_Name).files_out.files{1};
                    pipeline.(Job_Name34).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
                    pipeline.(Job_Name34).files_out.files   = g_2skeleton_FA_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                    pipeline.(Job_Name34).opt.fileName      = pipeline.(Applywarp_1_Name).files_out.files{1};
                    pipeline.(Job_Name34).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
                    pipeline.(Job_Name34).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
                    pipeline.(Job_Name34).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
                    pipeline.(Job_Name34).opt.threshold     = dti_opt.dismap_threshold;

                    % skeleton_MD job
                    Job_Name35 = [ 'skeleton_MD_',Number_Of_Subject_String ];
                    pipeline.(Job_Name35).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold )';
                    Applywarp_3_Name = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name35).files_in.files{1} = pipeline.(Applywarp_3_Name).files_out.files{1};
                    pipeline.(Job_Name35).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
                    pipeline.(Job_Name35).files_out.files   = g_2skeleton_MD_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                    pipeline.(Job_Name35).opt.fileName      = pipeline.(Applywarp_3_Name).files_out.files{1};
                    pipeline.(Job_Name35).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
                    pipeline.(Job_Name35).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
                    pipeline.(Job_Name35).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
                    pipeline.(Job_Name35).opt.threshold     = dti_opt.dismap_threshold;

                    % skeleton_L1 job
                    Job_Name36 = [ 'skeleton_L1_',Number_Of_Subject_String ];
                    pipeline.(Job_Name36).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold )';
                    Applywarp_5_Name = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name36).files_in.files{1} = pipeline.(Applywarp_5_Name).files_out.files{1};
                    pipeline.(Job_Name36).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
                    pipeline.(Job_Name36).files_out.files   = g_2skeleton_L1_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                    pipeline.(Job_Name36).opt.fileName      = pipeline.(Applywarp_5_Name).files_out.files{1};
                    pipeline.(Job_Name36).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
                    pipeline.(Job_Name36).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
                    pipeline.(Job_Name36).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
                    pipeline.(Job_Name36).opt.threshold     = dti_opt.dismap_threshold;

                    % skeleton_L23m job
                    Job_Name37 = [ 'skeleton_L23m_',Number_Of_Subject_String ];
                    pipeline.(Job_Name37).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold )';
                    Applywarp_7_Name = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
                    pipeline.(Job_Name37).files_in.files{1} = pipeline.(Applywarp_7_Name).files_out.files{1};
                    pipeline.(Job_Name37).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
                    pipeline.(Job_Name37).files_out.files   = g_2skeleton_L23m_FileOut( Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
                    pipeline.(Job_Name37).opt.fileName      = pipeline.(Applywarp_7_Name).files_out.files{1};
                    pipeline.(Job_Name37).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
                    pipeline.(Job_Name37).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
                    pipeline.(Job_Name37).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
                    pipeline.(Job_Name37).opt.threshold     = dti_opt.dismap_threshold;
                end

                if tracking_opt.DeterminFiberTracking == 1
                    % tracking
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
                    Option.RandomSeed_Flag = tracking_opt.RandomSeed_Flag;
                    if tracking_opt.RandomSeed_Flag
                        Option.RandomSeed = tracking_opt.RandomSeed;
                    end

                    Job_Name38 = [ 'DeterministicTracking_',Number_Of_Subject_String ];
                    pipeline.(Job_Name38).command           = 'g_DeterministicTracking( opt.NativeFolderPath,opt.tracking_opt,opt.Prefix )';
                    merge_Name = [ 'merge_' Number_Of_Subject_String ];
                    pipeline.(Job_Name38).files_in.files{1} = pipeline.(merge_Name).files_out.files{1};
                    pipeline.(Job_Name38).files_in.files{2} = pipeline.(merge_Name).files_out.files{2};
                    pipeline.(Job_Name38).files_in.files{3} = pipeline.(merge_Name).files_out.files{3};
                    pipeline.(Job_Name38).files_out.files   = g_DeterministicTracking_FileOut( Nii_Output_Path,Number_Of_Subject_String,Option,dtifit_Prefix );
                    pipeline.(Job_Name38).opt.NativeFolderPath    = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'native_space'];
                    pipeline.(Job_Name38).opt.tracking_opt        = Option;
                    pipeline.(Job_Name38).opt.Prefix          = dtifit_Prefix;
                end

                % Network Node Definition
                if tracking_opt.NetworkNode == 1 && ~tracking_opt.PartitionOfSubjects 
                    FAFileName = [dtifit_Prefix '_FA'];
                    FAPath = [Native_Folder filesep FAFileName '.nii.gz'];
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

                    Job_Name60 = [ 'CopyT1_' Number_Of_Subject_String ];
                    pipeline.(Job_Name60).command         = 'if ~strcmp(opt.T1ParentFolder,opt.T1Path);if ~exist(opt.T1Folder);mkdir(opt.T1Folder);end;system([''cp '' opt.T1Path '' '' opt.T1Folder]);end;';
                    if strcmp(T1Suffix, '.gz')
                        pipeline.(Job_Name60).files_out.files{1} = [T1Folder filesep T1FileName '.nii' T1Suffix];
                    else
                        pipeline.(Job_Name60).files_out.files{1} = [T1Folder filesep T1FileName T1Suffix];
                    end
                    pipeline.(Job_Name60).opt.T1Folder = T1Folder;
                    pipeline.(Job_Name60).opt.T1ParentFolder = T1ParentFolder;
                    pipeline.(Job_Name60).opt.T1Path = tracking_opt.T1orPartitionOfSubjects_PathCell{i};

                    if tracking_opt.T1Bet_Flag
                        Job_Name61 = [ 'BetT1_' Number_Of_Subject_String ];
                        pipeline.(Job_Name61).command            = 'g_BetT1( opt.DataRaw_path, opt.bet_f )';
                        pipeline.(Job_Name61).files_in.files     = pipeline.(Job_Name60).files_out.files;
                        pipeline.(Job_Name61).files_out.files{1} = [T1Folder filesep T1FileName '_swap_bet.nii.gz'];
                        pipeline.(Job_Name61).opt.DataRaw_path  = pipeline.(Job_Name60).files_out.files{1}; 
                        pipeline.(Job_Name61).opt.bet_f         = tracking_opt.T1BetF;
                    end

                    if tracking_opt.T1Cropping_Flag
                        Job_Name62 = ['T1Cropped_' Number_Of_Subject_String];
                        pipeline.(Job_Name62).command            = 'g_T1Cropped( opt.T1FilePath, opt.T1CroppingGap )';
                        if tracking_opt.T1Bet_Flag
                            pipeline.(Job_Name62).files_in.files = pipeline.(Job_Name61).files_out.files;
                            pipeline.(Job_Name62).opt.T1FilePath = [T1Folder filesep T1FileName '_swap_bet.nii.gz'];
                        else
                            pipeline.(Job_Name62).files_in.files = pipeline.(Job_Name60).files_out.files;
                            pipeline.(Job_Name62).opt.T1FilePath = [T1Folder filesep T1FileName '.nii.gz'];
                        end
                        pipeline.(Job_Name62).files_out.files{1} = [NewT1PathPrefix '_crop.nii.gz'];
                        pipeline.(Job_Name62).opt.T1CroppingGap  = tracking_opt.T1CroppingGap;

                        NewT1PathPrefix = [NewT1PathPrefix '_crop'];
                    end

                    if tracking_opt.T1Resample_Flag
                        Job_Name63 = ['T1Resample_' Number_Of_Subject_String];
                        pipeline.(Job_Name63).command            = 'g_resample_nii( opt.T1_Path, [1 1 1], files_out.files{1} )';
                        if tracking_opt.T1Cropping_Flag
                            pipeline.(Job_Name63).files_in.files = pipeline.(Job_Name62).files_out.files;
                            pipeline.(Job_Name63).opt.T1_Path    = pipeline.(Job_Name62).files_out.files{1};
                        else
                            pipeline.(Job_Name63).files_in.files = pipeline.(Job_Name61).files_out.files;
                            pipeline.(Job_Name63).opt.T1_Path    = pipeline.(Job_Name61).files_out.files{1};
                        end
                        pipeline.(Job_Name63).files_out.files{1} = [NewT1PathPrefix '_resample.nii.gz'];

                        NewT1PathPrefix = [NewT1PathPrefix '_resample'];
                    end

                    if tracking_opt.T1Resample_Flag
                        FinalT1 = pipeline.(Job_Name63).files_out.files{1};
                    elseif tracking_opt.T1Cropping_Flag
                        FinalT1 = pipeline.(Job_Name62).files_out.files{1};
                    else
                        FinalT1 = pipeline.(Job_Name61).files_out.files{1};
                    end

                    Job_Name64 = [ 'FAtoT1_' Number_Of_Subject_String ];
                    pipeline.(Job_Name64).command            = 'g_FAtoT1( opt.FA_Path, opt.T1_Path)';
                    pipeline.(Job_Name64).opt.T1_Path        = FinalT1;
                    dtifitJobName = [ 'dtifit_' Number_Of_Subject_String ];
                    pipeline.(Job_Name64).opt.FA_Path       = pipeline.(dtifitJobName).files_out.files{1};
                    pipeline.(Job_Name64).files_in.files{1}      = pipeline.(dtifitJobName).files_out.files{1};
                    pipeline.(Job_Name64).files_in.files{2}      = FinalT1;
                    pipeline.(Job_Name64).files_out.files{1}     = [T1Folder filesep FAFileName '_2T1.mat'];
                    pipeline.(Job_Name64).files_out.files{2}     = [T1Folder filesep FAFileName '_2T1.nii.gz'];
                    if strcmp(T1Suffix, '.gz')
                        pipeline.(Job_Name64).files_out.files{3}     = [NewT1PathPrefix '_2FA.mat'];
                    elseif strcmp(T1Suffix, '.nii')
                        pipeline.(Job_Name64).files_out.files{3}     = [NewT1PathPrefix '_2FA.mat'];
                    else
                        error('Not a .nii or .nii.gz file.');
                    end

                    Job_Name65 = ['T1toMNI152_' Number_Of_Subject_String];
                    pipeline.(Job_Name65).command            = 'g_T1toMNI152( opt.T1_Path )';
                    pipeline.(Job_Name65).opt.T1_Path        = [NewT1PathPrefix '.nii.gz'];
                    pipeline.(Job_Name65).files_in.files{1}      = FinalT1;
                    pipeline.(Job_Name65).files_out.files{1}     = [NewT1PathPrefix '_2MNI152.nii.gz'];
                    pipeline.(Job_Name65).files_out.files{2}     = [NewT1PathPrefix '_2MNI152_warp.nii.gz'];

                    Job_Name66 = [ 'Invwarp_' Number_Of_Subject_String ];
                    pipeline.(Job_Name66).command             = 'g_Invwarp( opt.WarpVolume, opt.ReferenceVolume )';
                    pipeline.(Job_Name66).files_in.files{1}     = pipeline.(Job_Name65).files_out.files{2};
                    pipeline.(Job_Name66).files_in.files{2}     = FinalT1;
                    pipeline.(Job_Name66).files_out.files{1}    = T1toMNI152_warp_inv;
                    pipeline.(Job_Name66).opt.ReferenceVolume   = FinalT1;
                    pipeline.(Job_Name66).opt.WarpVolume        = pipeline.(Job_Name65).files_out.files{2};

                    Job_Name67 = [ 'IndividualParcellated_' Number_Of_Subject_String ];
                    pipeline.(Job_Name67).command             = 'g_IndividualParcellated( opt.FA_Path, opt.T1_Path, opt.PartitionTemplate, opt.T1toFAMat, opt.T1toMNI152_warp_inv )';
                    pipeline.(Job_Name67).files_in.files{1} = pipeline.(Job_Name64).files_out.files{3};
                    pipeline.(Job_Name67).files_in.files{2} = pipeline.(Job_Name66).files_out.files{1};
                    pipeline.(Job_Name67).opt.PartitionTemplate = tracking_opt.PartitionTemplate;
                    pipeline.(Job_Name67).opt.FA_Path   = pipeline.(dtifitJobName).files_out.files{1};
                    pipeline.(Job_Name67).opt.T1toFAMat = pipeline.(Job_Name64).files_out.files{3};
                    pipeline.(Job_Name67).opt.T1toMNI152_warp_inv = pipeline.(Job_Name66).files_out.files{1};
                    pipeline.(Job_Name67).opt.T1_Path = FinalT1;
                    [a, PartitionTemplateName, PartitionTemplateSuffix] = fileparts(tracking_opt.PartitionTemplate);
                    if strcmp(PartitionTemplateSuffix, '.gz')
                        T1toFA_PartitionTemplate = [Native_Folder filesep FAFileName '_Parcellated_' PartitionTemplateName(1:end-4) '.nii.gz'];
                    elseif strcmp(PartitionTemplateSuffix, '.nii') || isempty(PartitionTemplateSuffix)
                        T1toFA_PartitionTemplate = [Native_Folder filesep FAFileName '_Parcellated_' PartitionTemplateName '.nii.gz'];
                    end
                    pipeline.(Job_Name67).files_out.files{1} = T1toFA_PartitionTemplate;
                end

                % Deterministic Network
                if tracking_opt.DeterministicNetwork == 1
                    Job_Name40 = [ 'DeterministicNetwork_',Number_Of_Subject_String ];
                    pipeline.(Job_Name40).command           = 'g_DeterministicNetwork( opt.trackfilepath,opt.T1toFA_PartitionTemplate,opt.FAfilepath )';
                    if ~tracking_opt.PartitionOfSubjects 
                        IndividualParcellated_Name = [ 'IndividualParcellated_' Number_Of_Subject_String ];
                        pipeline.(Job_Name40).files_in.files1   = pipeline.(IndividualParcellated_Name).files_out;
                    end
                    tracking_Name = [ 'DeterministicTracking_' Number_Of_Subject_String ];
                    pipeline.(Job_Name40).files_in.files2   = pipeline.(tracking_Name).files_out;
                    if tracking_opt.PartitionOfSubjects
                        pipeline.(Job_Name40).files_out.files   = g_DeterministicNetwork_FileOut( Nii_Output_Path,Number_Of_Subject_String,tracking_opt,tracking_opt.T1orPartitionOfSubjects_PathCell{i},dtifit_Prefix );
                    else
                        pipeline.(Job_Name40).files_out.files   = g_DeterministicNetwork_FileOut( Nii_Output_Path,Number_Of_Subject_String,tracking_opt,tracking_opt.PartitionTemplate,dtifit_Prefix );
                    end
                    pipeline.(Job_Name40).opt.trackfilepath = pipeline.(tracking_Name).files_out.files{1};
                    if tracking_opt.PartitionOfSubjects 
                        pipeline.(Job_Name40).opt.T1toFA_PartitionTemplate = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
                    else
                        pipeline.(Job_Name40).opt.T1toFA_PartitionTemplate = pipeline.(IndividualParcellated_Name).files_out.files{1};
                    end
                    dtifit_Name = [ 'dtifit_',Number_Of_Subject_String ];
                    pipeline.(Job_Name40).opt.FAfilepath =  pipeline.(dtifit_Name).files_out.files{1};
                end

                % Bedpostx
                if tracking_opt.BedpostxProbabilisticNetwork
                    Job_Name41 = [ 'BedpostX_preproc_',Number_Of_Subject_String ];
                    pipeline.(Job_Name41).command = 'g_bedpostX_preproc( opt.NativeFolder )';
                    merge_Name = [ 'merge_' Number_Of_Subject_String ];
                    pipeline.(Job_Name41).files_in.files{1} = pipeline.(merge_Name).files_out.files{1};
                    pipeline.(Job_Name41).files_in.files{2} = pipeline.(merge_Name).files_out.files{2};
                    pipeline.(Job_Name41).files_in.files{3} = pipeline.(merge_Name).files_out.files{3};
                    NativeFolderPath = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'native_space' ];
                    pipeline.(Job_Name41).files_out.files = g_bedpostX_preproc_FileOut( NativeFolderPath );
                    pipeline.(Job_Name41).opt.NativeFolder = NativeFolderPath;

                    BedpostxFolder = [NativeFolderPath '.bedpostX'];
                    for BedpostXJobNum = 1:10
                        Job_Name42 = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(BedpostXJobNum, '%02.0f') ];
                        pipeline.(Job_Name42).command = 'g_bedpostX( opt.NativeFolder, opt.BedpostXJobNum, opt.Fibers, opt.Weight, opt.Burnin )';
                        pipeline.(Job_Name42).files_in.files = pipeline.(Job_Name41).files_out.files;
                        pipeline.(Job_Name42).files_out.files = g_bedpostX_FileOut(BedpostxFolder, BedpostXJobNum);
                        pipeline.(Job_Name42).opt.NativeFolder = NativeFolderPath;
                        pipeline.(Job_Name42).opt.BedpostXJobNum = BedpostXJobNum;
                        pipeline.(Job_Name42).opt.Weight = tracking_opt.Weight;
                        pipeline.(Job_Name42).opt.Burnin = tracking_opt.Burnin;
                        pipeline.(Job_Name42).opt.Fibers = tracking_opt.Fibers;
                    end

                    Job_Name43 = [ 'BedpostX_postproc_' Number_Of_Subject_String ];
                    pipeline.(Job_Name43).command = 'g_bedpostX_postproc( opt.BedpostxFolder,opt.Fibers )';
                    for BedpostXJobNum = 1:10
                        Job_Name = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(BedpostXJobNum, '%02.0f') ];
                        pipeline.(Job_Name43).files_in.files{BedpostXJobNum} = pipeline.(Job_Name).files_out.files{1};
                    end
                    pipeline.(Job_Name43).files_out.files = g_bedpostX_postproc_FileOut( BedpostxFolder );
                    pipeline.(Job_Name43).opt.BedpostxFolder = BedpostxFolder;
                    pipeline.(Job_Name43).opt.Fibers = tracking_opt.Fibers;
                end

                % Probabilistic Network
                if tracking_opt.BedpostxProbabilisticNetwork
                    ProbabilisticFolder = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'Network' filesep 'Probabilistic']; 
                    Job_Name44 = [ 'ProbabilisticNetworkpre_',Number_Of_Subject_String ];
                    if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
                        pipeline.(Job_Name44).command        = 'g_OPDtrackNETpre( opt.LabelFile, opt.LabelVector, opt.ResultantFolder )';
                    elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
                        pipeline.(Job_Name44).command        = 'g_PDtrackNETpre( opt.LabelFile, opt.LabelVector, opt.ResultantFolder )';
                    end
                    Bedpostx_Name = [ 'BedpostX_postproc_' Number_Of_Subject_String ];
                    pipeline.(Job_Name44).files_in.files = pipeline.(Bedpostx_Name).files_out.files;
                    if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
                        pipeline.(Job_Name44).files_out.files   = g_OPDtrackNETpre_FileOut( ProbabilisticFolder, tracking_opt.LabelIdVector );
                    elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
                        pipeline.(Job_Name44).files_out.files   = g_PDtrackNETpre_FileOut( ProbabilisticFolder, tracking_opt.LabelIdVector );
                    end
                    if tracking_opt.PartitionOfSubjects
                        pipeline.(Job_Name44).opt.LabelFile   = tracking_opt.T1orPartitionOfSubjects_PathCell{i};
                    else
                        IndividualParcellated_Name = [ 'IndividualParcellated_' Number_Of_Subject_String ];
                        pipeline.(Job_Name44).files_in.Labelfiles  = pipeline.(IndividualParcellated_Name).files_out.files;
                        pipeline.(Job_Name44).opt.LabelFile   = pipeline.(IndividualParcellated_Name).files_out.files{1};
                    end
                    pipeline.(Job_Name44).opt.LabelVector     = tracking_opt.LabelIdVector;
                    pipeline.(Job_Name44).opt.ResultantFolder = ProbabilisticFolder;

                    for j = 1:length(tracking_opt.LabelIdVector)
                        LabelSeedFileNameCell{j} = pipeline.(Job_Name44).files_out.files{2 * j};
                        LabelTermFileNameCell{j} = pipeline.(Job_Name44).files_out.files{2 * j + 1};
                    end
                    for ProbabilisticNetworkJobNum = 1:80
                        Job_Name45 = ['ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d') '_' Number_Of_Subject_String];
                        pipeline.(Job_Name45).command = 'g_ProbabilisticNetwork( opt.BedostxFolder, opt.LabelSeedFileNameCell, opt.LabelTermFileNameCell, opt.TargetsTxtFileName, opt.ProbabilisticTrackingType, opt.ProbabilisticNetworkJobNum, opt.JobName )';
                        ProbabilisticNetworkPre_Name = [ 'ProbabilisticNetworkpre_' num2str(ProbabilisticNetworkJobNum) '_' Number_Of_Subject_String];
                        pipeline.(Job_Name45).files_in.files = pipeline.(Job_Name44).files_out.files;
                        pipeline.(Job_Name45).files_out.files{1} = [ProbabilisticFolder filesep 'OutputDone' filesep Job_Name45 '.done'];
                        BedpostxFolder = [ Native_Folder '.bedpostX'];
                        pipeline.(Job_Name45).opt.BedostxFolder = BedpostxFolder;  
                        pipeline.(Job_Name45).opt.LabelSeedFileNameCell = LabelSeedFileNameCell;
                        pipeline.(Job_Name45).opt.LabelTermFileNameCell = LabelTermFileNameCell;
                        pipeline.(Job_Name45).opt.TargetsTxtFileName = pipeline.(Job_Name44).files_out.files{1};
                        pipeline.(Job_Name45).opt.ProbabilisticTrackingType = tracking_opt.ProbabilisticTrackingType;
                        pipeline.(Job_Name45).opt.ProbabilisticNetworkJobNum = ProbabilisticNetworkJobNum;
                        pipeline.(Job_Name45).opt.JobName = Job_Name45;
                    end

                    for ProbabilisticNetworkPostJobNum = 1:10
                        Job_Name46 = [ 'ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f') '_'  Number_Of_Subject_String];
                        pipeline.(Job_Name46).command        = 'g_track4NETpost_fdt( opt.seed, opt.fdt, opt.ProbabilisticTrackingType, opt.LabelIdVector, opt.ProbabilisticNetworkPostJobNum, opt.prefix )';
                        for ProbabilisticNetworkJobNum = 1:80
                            Job_Name = [ 'ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d') '_' Number_Of_Subject_String];
                            pipeline.(Job_Name46).files_in.files{ProbabilisticNetworkJobNum}    = pipeline.(Job_Name).files_out.files{1};
                        end
                        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
                            for id = 1:length(tracking_opt.LabelIdVector)
                                pipeline.(Job_Name46).opt.seed{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                                           '_OPDtrackNET' filesep 'Label' num2str(tracking_opt.LabelIdVector(id), '%02.0f') '_SeedMask.nii.gz' ];
                                pipeline.(Job_Name46).opt.fdt{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                                           '_OPDtrackNET' filesep 'fdt_paths.nii.gz' ];
                            end
                        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
                            for id = 1:length(tracking_opt.LabelIdVector)
                                pipeline.(Job_Name46).opt.seed{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                                           '_PDtrackNET' filesep 'Label' num2str(tracking_opt.LabelIdVector(id), '%02.0f') '_SeedMask.nii.gz' ];
                                pipeline.(Job_Name46).opt.fdt{id} = [ ProbabilisticFolder filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') ...
                                                           '_PDtrackNET' filesep 'fdt_paths.nii.gz' ];
                            end
                        end
                        pipeline.(Job_Name46).opt.ProbabilisticTrackingType = tracking_opt.ProbabilisticTrackingType;
                        pipeline.(Job_Name46).opt.LabelIdVector = tracking_opt.LabelIdVector;
                        pipeline.(Job_Name46).opt.ProbabilisticNetworkPostJobNum = ProbabilisticNetworkPostJobNum;
                        pipeline.(Job_Name46).files_out.files = g_track4NETpost_fdt_FileOut( Native_Folder, Number_Of_Subject_String, ProbabilisticNetworkPostJobNum );
                        pipeline.(Job_Name46).opt.prefix = Number_Of_Subject_String;
                    end
                    
                    Job_Name80 = [ 'ProbabilisticNetworkpost_MergeResults_' Number_Of_Subject_String ];
                    pipeline.(Job_Name80).command        = 'g_ProbabilisticNetworkMergeResults(opt.ProbabilisticMatrix,opt.prefix,opt.ProbabilisticTrackingType,opt.LabelIdVector)';
                    for j = 1:10
                        Job_Name = [ 'ProbabilisticNetworkpost_' num2str(j, '%02.0f') '_' Number_Of_Subject_String];
                        pipeline.(Job_Name80).files_in.files{j}     = pipeline.(Job_Name).files_out.files{1};
                        pipeline.(Job_Name80).opt.ProbabilisticMatrix{j} = pipeline.(Job_Name).files_out.files{1};
                    end
                    pipeline.(Job_Name80).opt.prefix = Number_Of_Subject_String;
                    pipeline.(Job_Name80).opt.ProbabilisticTrackingType = tracking_opt.ProbabilisticTrackingType;
                    pipeline.(Job_Name80).opt.LabelIdVector = tracking_opt.LabelIdVector;
                    pipeline.(Job_Name80).files_out.files{1} = [ SubjectFolder filesep 'Network' filesep 'Probabilistic' filesep Number_Of_Subject_String '_ProbabilisticMatrix_' ...
                        tracking_opt.ProbabilisticTrackingType '_' num2str(length(tracking_opt.LabelIdVector)) '.txt' ];
                end
            end
            
            Job_Name48 = 'ExportAtlasResults_FA_ToExcel';
            pipeline.(Job_Name48).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeFloderPath, opt.WMtractFolderPath, opt.ResultantFolder, opt.Type )';
            for i = 1:length(Data_Raw_Path_Cell)
                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                AtlasFAJobName = [ 'atlas_FA_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name48).files_in.files{i * 2 - 1} = pipeline.(AtlasFAJobName).files_out.files{1};
                pipeline.(Job_Name48).files_in.files{i * 2} = pipeline.(AtlasFAJobName).files_out.files{2};
            end
            pipeline.(Job_Name48).files_out.files{1} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMlabelResults_FA.xls'];
            pipeline.(Job_Name48).files_out.files{2} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMtractResults_FA.xls'];
            pipeline.(Job_Name48).opt.WMlabeFloderPath = dti_opt.WM_Label_Atlas;
            pipeline.(Job_Name48).opt.WMtractFolderPath = dti_opt.WM_Probtract_Atlas;
            pipeline.(Job_Name48).opt.ResultantFolder = [Nii_Output_Path filesep 'AllAtlasResults'];
            pipeline.(Job_Name48).opt.Type = 'FA';
            
            Job_Name49 = 'ExportAtlasResults_MD_ToExcel';
            pipeline.(Job_Name49).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeFloderPath, opt.WMtractFolderPath, opt.ResultantFolder, opt.Type )';
            for i = 1:length(Data_Raw_Path_Cell)
                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                AtlasMDJobName = [ 'atlas_MD_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name49).files_in.files{i * 2 - 1} = pipeline.(AtlasMDJobName).files_out.files{1};
                pipeline.(Job_Name49).files_in.files{i * 2} = pipeline.(AtlasMDJobName).files_out.files{2};
            end
            pipeline.(Job_Name49).files_out.files{1} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMlabelResults_MD.xls'];
            pipeline.(Job_Name49).files_out.files{2} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMtractResults_MD.xls'];
            pipeline.(Job_Name49).opt.WMlabeFloderPath = dti_opt.WM_Label_Atlas;
            pipeline.(Job_Name49).opt.WMtractFolderPath = dti_opt.WM_Probtract_Atlas;
            pipeline.(Job_Name49).opt.ResultantFolder = [Nii_Output_Path filesep 'AllAtlasResults'];
            pipeline.(Job_Name49).opt.Type = 'MD';
            
            Job_Name50 = 'ExportAtlasResults_L1_ToExcel';
            pipeline.(Job_Name50).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeFloderPath, opt.WMtractFolderPath, opt.ResultantFolder, opt.Type )';
            for i = 1:length(Data_Raw_Path_Cell)
                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                AtlasL1JobName = [ 'atlas_L1_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name50).files_in.files{i * 2 - 1} = pipeline.(AtlasL1JobName).files_out.files{1};
                pipeline.(Job_Name50).files_in.files{i * 2} = pipeline.(AtlasL1JobName).files_out.files{2};
            end
            pipeline.(Job_Name50).files_out.files{1} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMlabelResults_L1.xls'];
            pipeline.(Job_Name50).files_out.files{2} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMtractResults_L1.xls'];
            pipeline.(Job_Name50).opt.WMlabeFloderPath = dti_opt.WM_Label_Atlas;
            pipeline.(Job_Name50).opt.WMtractFolderPath = dti_opt.WM_Probtract_Atlas;
            pipeline.(Job_Name50).opt.ResultantFolder = [Nii_Output_Path filesep 'AllAtlasResults'];
            pipeline.(Job_Name50).opt.Type = 'L1';
            
            Job_Name51 = 'ExportAtlasResults_L23m_ToExcel';
            pipeline.(Job_Name51).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeFloderPath, opt.WMtractFolderPath, opt.ResultantFolder, opt.Type )';
            for i = 1:length(Data_Raw_Path_Cell)
                Number_Of_Subject = index_vector(i);
                Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                AtlasL23mJobName = [ 'atlas_L23m_1mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name51).files_in.files{i * 2 - 1} = pipeline.(AtlasL23mJobName).files_out.files{1};
                pipeline.(Job_Name51).files_in.files{i * 2} = pipeline.(AtlasL23mJobName).files_out.files{2};
            end
            pipeline.(Job_Name51).files_out.files{1} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMlabelResults_L23m.xls'];
            pipeline.(Job_Name51).files_out.files{2} = [Nii_Output_Path filesep 'AllAtlasResults' filesep 'WMtractResults_L23m.xls'];
            pipeline.(Job_Name51).opt.WMlabeFloderPath = dti_opt.WM_Label_Atlas;
            pipeline.(Job_Name51).opt.WMtractFolderPath = dti_opt.WM_Probtract_Atlas;
            pipeline.(Job_Name51).opt.ResultantFolder = [Nii_Output_Path filesep 'AllAtlasResults'];
            pipeline.(Job_Name51).opt.Type = 'L23m';

            if dti_opt.TBSS_Flag
                % Merge all Subjects' individual skeleton into a 4D skeleton
                Job_Name52 = 'MergeSkeleton_FA';
                pipeline.(Job_Name52).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
                for i = 1:length(Data_Raw_Path_Cell)
                    Number_Of_Subject = index_vector(i);
                    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                    SkeletonFAJobName = [ 'skeleton_FA_' Number_Of_Subject_String ];
                    pipeline.(Job_Name52).files_in.files{i} = pipeline.(SkeletonFAJobName).files_out.files{1};
                end
                pipeline.(Job_Name52).files_out.files{1}   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_FA.nii.gz'];
                pipeline.(Job_Name52).opt.SubjectIDs   = index_vector;
                pipeline.(Job_Name52).opt.ResultantFile   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_FA.nii.gz'];

                Job_Name53 = 'MergeSkeleton_MD';
                pipeline.(Job_Name53).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
                for i = 1:length(Data_Raw_Path_Cell)
                    Number_Of_Subject = index_vector(i);
                    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                    SkeletonMDJobName = [ 'skeleton_MD_' Number_Of_Subject_String ];
                    pipeline.(Job_Name53).files_in.files{i} = pipeline.(SkeletonMDJobName).files_out.files{1};
                end
                pipeline.(Job_Name53).files_out.files{1}   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_MD.nii.gz'];
                pipeline.(Job_Name53).opt.SubjectIDs   = index_vector;
                pipeline.(Job_Name53).opt.ResultantFile   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_MD.nii.gz'];

                Job_Name54 = 'MergeSkeleton_L1';
                pipeline.(Job_Name54).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
                for i = 1:length(Data_Raw_Path_Cell)
                    Number_Of_Subject = index_vector(i);
                    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                    SkeletonL1JobName = [ 'skeleton_L1_' Number_Of_Subject_String ];
                    pipeline.(Job_Name54).files_in.files{i} = pipeline.(SkeletonL1JobName).files_out.files{1};
                end
                pipeline.(Job_Name54).files_out.files{1}   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_L1.nii.gz'];
                pipeline.(Job_Name54).opt.SubjectIDs   = index_vector;
                pipeline.(Job_Name54).opt.ResultantFile   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_L1.nii.gz'];

                Job_Name55 = 'MergeSkeleton_L23m';
                pipeline.(Job_Name55).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
                for i = 1:length(Data_Raw_Path_Cell)
                    Number_Of_Subject = index_vector(i);
                    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
                    SkeletonL23mJobName = [ 'skeleton_L23m_' Number_Of_Subject_String ];
                    pipeline.(Job_Name55).files_in.files{i} = pipeline.(SkeletonL23mJobName).files_out.files{1};
                end
                pipeline.(Job_Name55).files_out.files{1}   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_L23m.nii.gz'];
                pipeline.(Job_Name55).opt.SubjectIDs   = index_vector;
                pipeline.(Job_Name55).opt.ResultantFile   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_L23m.nii.gz'];
            end


            % Excute the pipeline
%             psom_visu_dependencies(pipeline);
            psom_run_pipeline(pipeline,pipeline_opt);
        
        end
    end
end











