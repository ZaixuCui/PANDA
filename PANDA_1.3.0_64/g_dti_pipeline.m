
function pipeline = g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt,dti_opt,tracking_opt,T1orPartitionOfSubjects_PathCell )
%
%__________________________________________________________________________
% SUMMARY OF G_DTI_PIPELINE
% 
% The whole process of DTI data processing for any number of subjects.
%
% SYNTAX:
% 
% 1) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix)
% 2) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt )
% 3) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt,dti_opt )
% 4) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt,dti_opt,tracking_opt )
% 5) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt,dti_opt,tracking_opt,T1orPartitionOfSubjects_PathCell )
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
%            (string, default )
%            'background' : 
%                execute with only one computer
%            'qsub'  : 
%                execute in a distributed environment such as SGE, PBS 
%
%        max_queued
%            (integer) The maximum number of jobs that can be processed 
%            simultaneously.
%            ('background' mode) default value is 'quantity of cores'
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
%        Resample_resolution
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
%
%        WM_label_atlas
%            (string, default ICBM-DTI-81 WM labels atlas)
%            The full path of white matter atlas for calculating regional 
%            diffusion metrics.
%
%        WM_probtract_atlas
%            (string, default JHU WM tractography atlas)
%            The full path of white matter atlas for calculating regional 
%            diffusion metrics.
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
% T1orPartitionOfSubjects_PathCell
%            (cell of strings, only needed when tracking_opt.NetworkNode 
%            is 1)
%            There are 2 possibilities under each cell:
%            (1) If tracking_opt.PartitionOfSubjects = 1, full path of
%            subjects' parcellated image in native space
%            (2) If tracking_opt.T1 = 1, full path of subjects' T1 image
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
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: dti, pipeline, psom

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

pipeline = '';
psom_gb_vars

if nargin <= 4
    % The default value of pipeline opt parameters
    pipeline_opt.mode = 'qsub';
    pipeline_opt.qsub_options = '-V -q all.q';
    pipeline_opt.mode_pipeline_manager = 'background';
    pipeline_opt.max_queued = 100;
    pipeline_opt.flag_verbose = 0;
    pipeline_opt.flag_pause = 0;
    pipeline_opt.flag_update = 1;
    pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
elseif nargin >= 5
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
        pipeline_opt.mode = 'qsub';
        pipeline_opt.qsub_options = '-V -q all.q';
    end
    if strcmp(pipeline_opt.mode,'qsub') & ~isfield(pipeline_opt,'qsub_options')
        pipeline_opt.qsub_options = '-V -q all.q';
    end
    if ~isfield(pipeline_opt,'mode_pipeline_manager')
        pipeline_opt.mode_pipeline_manager = 'background';
    end
    if ~isfield(pipeline_opt,'max_queued')
        pipeline_opt.max_queued = 100;
    end
    if ~isfield(pipeline_opt,'path_logs')
        pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
    end
end
    
if nargin <= 5
    % The default value of dti opt will be used
    dti_opt = g_dti_opt();
else
    % The value user specified will be used, and those not be specified
    % will be default
    dti_opt_new = g_dti_opt(dti_opt);
    dti_opt = dti_opt_new;
end

if nargin <= 6
    % The default value of tracking opt will be used
    tracking_opt = g_tracking_opt();
else
    tracking_opt_new = g_tracking_opt(tracking_opt);
    tracking_opt = tracking_opt_new;
end

if length(Data_Raw_Path_Cell) ~= length(index_vector)
    error('not match!');
end

% Handle the data one subject after one and make them a big pipeline 

if dti_opt.Atlas_Flag | dti_opt.TBSS_Flag
    % Split WM label atlas and WM probtract atlas into folders containing ROIs
    % Run after extractB0 job, because if extractB0 is finished, then PANDA work well; and the monitor table will be more clear 
    
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
end

for i = 1:length(Data_Raw_Path_Cell)
    
    Number_Of_Subject = index_vector(i);
    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
    if ~strcmp( Data_Raw_Path_Cell{i}(end),'/' )
        Data_Raw_Path_Cell{i} = [Data_Raw_Path_Cell{i},'/'];
    end
    
    % Calculate the quantity of the sequences
    %Quantity_Of_Sequence = g_Calculate_Sequence( Data_Raw_Path_Cell{i},i );
    Quantity_Of_Sequence = length(g_ls([Data_Raw_Path_Cell{i} '/*/']));

    % Basename for the output file of the dtifit
    if isempty(FA_Prefix) 
        dtifit_Prefix = Number_Of_Subject_String;
    else
        dtifit_Prefix = [FA_Prefix '_' Number_Of_Subject_String];
    end

    if ~strcmp( Nii_Output_Path(end), filesep )
        Nii_Output_Path = [Nii_Output_Path, filesep];
    end
    SubjectFolder = [Nii_Output_Path Number_Of_Subject_String];
    % Create a folder to store temporary file
    Tmp_Folder = [SubjectFolder filesep 'tmp'];
    if ~exist(Tmp_Folder,'dir')
        mkdir(Tmp_Folder);
    end
    % Create a folder to store .done files
    Output_Done_Folder = [SubjectFolder filesep 'tmp' filesep 'OutputDone'];
    if ~exist(Output_Done_Folder,'dir')
        mkdir(Output_Done_Folder);
    end
    % Create a folder to store quantity control files
    Quality_Control_Folder = [SubjectFolder filesep 'quality_control'];
    if ~exist(Quality_Control_Folder,'dir')
        mkdir(Quality_Control_Folder);
    end
    % Create a folder to store image files in native space
    Native_Folder = [SubjectFolder filesep 'native_space'];
    if ~exist(Native_Folder,'dir')
        mkdir(Native_Folder);
    end
    if dti_opt.Normalizing_Flag
        % Create a folder to store transformated image files
        Transformation_Folder = [SubjectFolder filesep 'transformation'];
        if ~exist(Transformation_Folder,'dir')
            mkdir(Transformation_Folder);
        end
        % Create a folder to store image files in non-linear space
        NonLinear_Folder = [SubjectFolder filesep 'standard_space'];
        if ~exist(NonLinear_Folder,'dir')
            mkdir(NonLinear_Folder);
        end
    end
         
    % Save the raw path and the path of nii data to matrix file
    variable_name = ['subject_info_',Number_Of_Subject_String];
    Subject_Info_File = [Nii_Output_Path,'subject_info.mat'];
    tmp_PANDA = [Data_Raw_Path_Cell{i} '  ' Nii_Output_Path Number_Of_Subject_String '/'];
    eval([variable_name '=tmp_PANDA;']);
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
    pipeline.(Job_Name1).command             =  'g_dcm2nii_dwi( opt.Data_Raw_Folder_Path,opt.Nii_Output_Folder_Path,opt.Prefix,opt.JobName )';
       % if the files specified in the files_out.files are successfully
       % produced, the job is successfull
    pipeline.(Job_Name1).files_out.files     =  g_dcm2nii_dwi_FileOut( Job_Name1,Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dtifit_Prefix );
       % option of the job, will be used as parameters of g_dcm2nii_dwi
    pipeline.(Job_Name1).opt.Data_Raw_Folder_Path    =  Data_Raw_Path_Cell{i};
    pipeline.(Job_Name1).opt.Nii_Output_Folder_Path  =  [Nii_Output_Path filesep Number_Of_Subject_String filesep];
    pipeline.(Job_Name1).opt.Prefix          = dtifit_Prefix;
    pipeline.(Job_Name1).opt.JobName    =  Job_Name1;

    % Export parameters jobs
    Job_Name0 = [ 'DataParameters_',Number_Of_Subject_String ];
    pipeline.(Job_Name0).command             =  'g_DataParameters( opt.Data_Raw_Folder_Path,opt.Nii_Output_Folder_Path )';
    pipeline.(Job_Name0).files_in            =  pipeline.(Job_Name1).files_out.files;
    pipeline.(Job_Name0).files_out.files{1}  =  [Nii_Output_Path Number_Of_Subject_String filesep 'quality_control' filesep 'Scanning_Parameter' filesep 'ScanningParameters.mat'];
    pipeline.(Job_Name0).files_out.files{2}  =  [Nii_Output_Path Number_Of_Subject_String filesep 'quality_control' filesep 'Scanning_Parameter' filesep 'ScanningParameters.txt'];
    pipeline.(Job_Name0).opt.Data_Raw_Folder_Path    =  Data_Raw_Path_Cell{i};
    pipeline.(Job_Name0).opt.Nii_Output_Folder_Path  =  [Nii_Output_Path filesep Number_Of_Subject_String filesep];
    
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
    if ~strcmp(dti_opt.Inversion, 'No Inversion') | ~strcmp(dti_opt.Swap, 'No Swap')
        Job_Name91 = [ 'OrientationPatch_',Number_Of_Subject_String ];
        pipeline.(Job_Name91).command             =  'g_OrientationPatch(opt.Bvecs_File,opt.Inversion,opt.Swap)';
        pipeline.(Job_Name91).files_in.files      = pipeline.(Job_Name1).files_out.files;
        for j = 1:Quantity_Of_Sequence
            pipeline.(Job_Name91).opt.Bvecs_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 2};
        end
        pipeline.(Job_Name91).opt.Inversion       = dti_opt.Inversion;
        pipeline.(Job_Name91).opt.Swap            = dti_opt.Swap;
        for j = 1:Quantity_Of_Sequence
            pipeline.(Job_Name91).files_out.files{j}  = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'tmp' filesep dtifit_Prefix '_bvecs_' num2str(j,'%02.0f') '_Orientation'];
        end
    end
    
    % extractB0 job
    Job_Name2 = [ 'extractB0_',Number_Of_Subject_String ];
    pipeline.(Job_Name2).command             = 'g_extractB0(opt.DWI_File,opt.Bval_File,opt.JobName)';
    if ~dti_opt.RawDataResample_Flag
        pipeline.(Job_Name2).files_in.files  = pipeline.(Job_Name1).files_out.files;
        for j = 1:Quantity_Of_Sequence
            pipeline.(Job_Name2).opt.DWI_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 3};
            pipeline.(Job_Name2).opt.Bval_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 1};
        end
    else
        pipeline.(Job_Name2).files_in.files  = pipeline.(Job_Name90).files_out.files;
        for j = 1:Quantity_Of_Sequence
            pipeline.(Job_Name2).opt.DWI_File{j} = pipeline.(Job_Name90).files_out.files{j};
            pipeline.(Job_Name2).opt.Bval_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 1};
        end
    end
    pipeline.(Job_Name2).files_out.files     = g_extractB0_FileOut( Job_Name2,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name2).opt.JobName         =  Job_Name2;

    % BET job 
    Job_Name3 = [ 'BET_1_',Number_Of_Subject_String ];
    pipeline.(Job_Name3).command                 = 'g_BET( opt.BET_File,opt.f,opt.JobName )';
    pipeline.(Job_Name3).files_in.files          = pipeline.(Job_Name2).files_out.files;
    pipeline.(Job_Name3).files_out.files         = g_BET_1_FileOut( Job_Name3,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name3).opt.BET_File            = pipeline.(Job_Name2).files_out.files{1};
    pipeline.(Job_Name3).opt.f                   = dti_opt.BET_1_f;
    pipeline.(Job_Name3).opt.JobName    =  Job_Name3;
    
    % NIIcrop job
    if dti_opt.Cropping_Flag
        Job_Name4 = [ 'Split_Crop_',Number_Of_Subject_String ];    
    else
        Job_Name4 = [ 'Split_',Number_Of_Subject_String ];  
    end
    pipeline.(Job_Name4).command             = 'g_NIIcrop( opt.DWI_File,opt.B0Avg_FileName,opt.MaskFileName,opt.Cropping_Flag,opt.slice_gap,opt.JobName )';
    pipeline.(Job_Name4).files_in.files      = pipeline.(Job_Name3).files_out.files;
    pipeline.(Job_Name4).files_out.files     = g_NIIcrop_FileOut( Job_Name4,Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dti_opt.Cropping_Flag, ...
        dti_opt.RawDataResample_Flag,dtifit_Prefix );
    pipeline.(Job_Name4).files_out.variables = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'NIIcrop_output.mat']};
    if ~dti_opt.RawDataResample_Flag
        for j = 1:Quantity_Of_Sequence
            pipeline.(Job_Name4).opt.DWI_File{j} = pipeline.(Job_Name1).files_out.files{(j - 1) * 3 + 3};
        end
    else
        pipeline.(Job_Name4).opt.DWI_File    = pipeline.(Job_Name90).files_out.files;
    end
    pipeline.(Job_Name4).opt.B0Avg_FileName  = pipeline.(Job_Name2).files_out.files{1};
    pipeline.(Job_Name4).opt.MaskFileName    = pipeline.(Job_Name3).files_out.files{2};
    pipeline.(Job_Name4).opt.Cropping_Flag   = dti_opt.Cropping_Flag;
    pipeline.(Job_Name4).opt.slice_gap       = dti_opt.NIIcrop_slice_gap;
    pipeline.(Job_Name4).opt.JobName    =  Job_Name4;
    
    % EDDYCURRENT job
    Job_Name5 = [ 'EDDYCURRENT_',Number_Of_Subject_String ];
    pipeline.(Job_Name5).command                = 'g_EDDYCURRENT( opt.B0_File,files_in.variables{1},opt.QuantityOfSequence,opt.Inversion,opt.Swap,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name5).files_in.files1        = pipeline.(Job_Name4).files_out.files;
    if ~strcmp(dti_opt.Inversion, 'No Inversion') | ~strcmp(dti_opt.Swap, 'No Swap')
        pipeline.(Job_Name5).files_in.files2    = pipeline.(Job_Name91).files_out.files;
    end
    pipeline.(Job_Name5).files_in.variables     = pipeline.(Job_Name4).files_out.variables;
    pipeline.(Job_Name5).files_out.files        = g_EDDYCURRENT_FileOut( Job_Name5,Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dti_opt.RawDataResample_Flag,dtifit_Prefix );
    pipeline.(Job_Name5).files_out.variables    = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'EDDYCURRENT_output.mat']};
    if dti_opt.Cropping_Flag
        pipeline.(Job_Name5).opt.B0_File        = pipeline.(Job_Name4).files_out.files{end - 1};
    else
        pipeline.(Job_Name5).opt.B0_File        = pipeline.(Job_Name2).files_out.files{1};
    end
    pipeline.(Job_Name5).opt.QuantityOfSequence = Quantity_Of_Sequence;
    pipeline.(Job_Name5).opt.Inversion          = dti_opt.Inversion;
    pipeline.(Job_Name5).opt.Swap               = dti_opt.Swap;
    pipeline.(Job_Name5).opt.Prefix             = dtifit_Prefix;
    pipeline.(Job_Name5).opt.JobName    =  Job_Name5;

    % average job
    Job_Name6 = [ 'average_',Number_Of_Subject_String ];
    pipeline.(Job_Name6).command                     = 'g_average( files_in.variables{1},opt.QuantityOfSequence,opt.RawDataResample_Flag,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name6).files_in.files              = pipeline.(Job_Name5).files_out.files;
    pipeline.(Job_Name6).files_in.variables          = pipeline.(Job_Name5).files_out.variables;
    pipeline.(Job_Name6).files_out.files             = g_average_FileOut( Job_Name6,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name6).files_out.variables         = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'average_output.mat']};
    pipeline.(Job_Name6).opt.DataNii_folder          = [Nii_Output_Path Number_Of_Subject_String '/'];     
    pipeline.(Job_Name6).opt.QuantityOfSequence      = Quantity_Of_Sequence;
    pipeline.(Job_Name6).opt.RawDataResample_Flag    = dti_opt.RawDataResample_Flag;
    pipeline.(Job_Name6).opt.Prefix                  = dtifit_Prefix;
    pipeline.(Job_Name6).opt.JobName    =  Job_Name6;
    
    % BET_2 job
    Job_Name7 = [ 'BET_2_',Number_Of_Subject_String ];
    pipeline.(Job_Name7).command               = 'g_BET( opt.BET_File,opt.f,opt.JobName )';
    pipeline.(Job_Name7).files_in.files        = pipeline.(Job_Name6).files_out.files;
    pipeline.(Job_Name7).files_out.files       = g_BET_2_FileOut( Job_Name7,Nii_Output_Path,Number_Of_Subject_String );
    if dti_opt.Cropping_Flag
        pipeline.(Job_Name7).opt.BET_File      = pipeline.(Job_Name4).files_out.files{end - 1};  % b0 file
    else
        pipeline.(Job_Name7).opt.BET_File      = pipeline.(Job_Name2).files_out.files{1};
    end
    pipeline.(Job_Name7).opt.f                = dti_opt.BET_2_f;
    pipeline.(Job_Name7).opt.JobName    =  Job_Name7;
    
    % merge job
    Job_Name8 = [ 'merge_',Number_Of_Subject_String ];
    pipeline.(Job_Name8).command               =  'g_merge( opt.Nii_Output_Folder_Path,files_in.variables{1},opt.Prefix,opt.MaskFile,opt.JobName )';
    pipeline.(Job_Name8).files_in.files        =  pipeline.(Job_Name7).files_out.files;
    pipeline.(Job_Name8).files_in.variables    =  pipeline.(Job_Name6).files_out.variables;
    pipeline.(Job_Name8).files_out.files       =  g_merge_FileOut( Job_Name8,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name8).opt.Nii_Output_Folder_Path    =  [Nii_Output_Path Number_Of_Subject_String filesep];
    pipeline.(Job_Name8).opt.Prefix                    = dtifit_Prefix;
    pipeline.(Job_Name8).opt.MaskFile                  = [Nii_Output_Path Number_Of_Subject_String filesep 'native_space' filesep 'nodif_brain_mask.nii.gz'];
    pipeline.(Job_Name8).opt.JobName    =  Job_Name8;
    
    % LDH Calculation job
    if dti_opt.LDH_Flag
        Job_Name100 = ['LDH_',Number_Of_Subject_String ];
        pipeline.(Job_Name100).command           = 'g_DWI2LDH( opt.DWI4D,opt.Bval,opt.Nvoxel,opt.Prefix,opt.SubjectID,opt.type )';
        pipeline.(Job_Name100).files_in.files    = pipeline.(Job_Name8).files_out.files;
        pipeline.(Job_Name100).files_out.files{1}= [Nii_Output_Path Number_Of_Subject_String filesep 'native_space' filesep  dtifit_Prefix...
            '_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs.nii.gz'];
        pipeline.(Job_Name100).files_out.files{2}= [Nii_Output_Path Number_Of_Subject_String filesep 'native_space' filesep  dtifit_Prefix...
            '_' num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk.nii.gz'];
        pipeline.(Job_Name100).opt.DWI4D         = pipeline.(Job_Name8).files_out.files{3};
        pipeline.(Job_Name100).opt.Bval          = pipeline.(Job_Name8).files_out.files{1};
        pipeline.(Job_Name100).opt.Nvoxel        = dti_opt.LDH_Neighborhood - 1;
        pipeline.(Job_Name100).opt.Prefix        = FA_Prefix;
        pipeline.(Job_Name100).opt.SubjectID     = Number_Of_Subject_String;
        pipeline.(Job_Name100).opt.type          = 'both';
    end

    % dtifit job
    Job_Name9 = [ 'dtifit_',Number_Of_Subject_String ];
    pipeline.(Job_Name9).command             = 'g_dtifit( opt.fdt_dir,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name9).files_in.files1     = pipeline.(Job_Name8).files_out.files;
%     if dti_opt.LDH_Flag
%         pipeline.(Job_Name9).files_in.files2     = pipeline.(Job_Name100).files_out.files;
%     end
    pipeline.(Job_Name9).files_out.files     = g_dtifit_FileOut( Job_Name9,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name9).opt.fdt_dir         = [Nii_Output_Path Number_Of_Subject_String '/'];
    pipeline.(Job_Name9).opt.Prefix          = dtifit_Prefix;
    pipeline.(Job_Name9).opt.JobName    =  Job_Name9;

    if dti_opt.Normalizing_Flag
        % BeforeNormalize_FA job
        Job_Name10 = [ 'BeforeNormalize_FA_',Number_Of_Subject_String ];
        pipeline.(Job_Name10).command                = 'g_BeforeNormalize( opt.FA_file,opt.JobName )';
        pipeline.(Job_Name10).files_in.files         = pipeline.(Job_Name9).files_out.files;
        pipeline.(Job_Name10).files_out.files        = g_BeforeNormalize_FA_FileOut( Job_Name10,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name10).opt.FA_file            = pipeline.(Job_Name9).files_out.files{1};
        pipeline.(Job_Name10).opt.JobName    =  Job_Name10;

        % BeforeNormalize_MD job
        Job_Name11 = [ 'BeforeNormalize_MD_',Number_Of_Subject_String ];
        pipeline.(Job_Name11).command                = 'g_BeforeNormalize( opt.MD_file,opt.JobName )';
        pipeline.(Job_Name11).files_in.files         = pipeline.(Job_Name9).files_out.files;
        pipeline.(Job_Name11).files_out.files        = g_BeforeNormalize_MD_FileOut( Job_Name11,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name11).opt.MD_file            = pipeline.(Job_Name9).files_out.files{6};
        pipeline.(Job_Name11).opt.JobName    =  Job_Name11;

        % BeforeNormalize_L1 job
        Job_Name12 = [ 'BeforeNormalize_L1_',Number_Of_Subject_String ];
        pipeline.(Job_Name12).command                = 'g_BeforeNormalize( opt.L1_file,opt.JobName )';
        pipeline.(Job_Name12).files_in.files         = pipeline.(Job_Name9).files_out.files;
        pipeline.(Job_Name12).files_out.files        = g_BeforeNormalize_L1_FileOut( Job_Name12,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name12).opt.L1_file            = pipeline.(Job_Name9).files_out.files{2};
        pipeline.(Job_Name12).opt.JobName    =  Job_Name12;

        % BeforeNormalize_L23m job
        Job_Name13 = [ 'BeforeNormalize_L23m_',Number_Of_Subject_String ];
        pipeline.(Job_Name13).command                = 'g_BeforeNormalize( opt.L23m_file,opt.JobName )';
        pipeline.(Job_Name13).files_in.files         = pipeline.(Job_Name9).files_out.files;
        pipeline.(Job_Name13).files_out.files        = g_BeforeNormalize_L23m_FileOut( Job_Name13,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name13).opt.L23m_file          = pipeline.(Job_Name9).files_out.files{5};
        pipeline.(Job_Name13).opt.JobName    =  Job_Name13;
        
        if dti_opt.LDH_Flag
            % LDH Spearman job
            Job_Name101 = [ 'BeforeNormalize_LDHs_',Number_Of_Subject_String ];
            pipeline.(Job_Name101).command                = 'g_BeforeNormalize( opt.LDHs_file,opt.JobName )';
            pipeline.(Job_Name101).files_in.files{1}      = pipeline.(Job_Name100).files_out.files{1};
            pipeline.(Job_Name101).files_out.files        = g_BeforeNormalize_LDHs_FileOut( Job_Name101,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.LDH_Neighborhood - 1 );
            pipeline.(Job_Name101).opt.LDHs_file          = pipeline.(Job_Name100).files_out.files{1};
            pipeline.(Job_Name101).opt.JobName    =  Job_Name101;

            % LDH Kendall job
            Job_Name102 = [ 'BeforeNormalize_LDHk_',Number_Of_Subject_String ];
            pipeline.(Job_Name102).command                = 'g_BeforeNormalize( opt.LDHk_file,opt.JobName )';
            pipeline.(Job_Name102).files_in.files{1}      = pipeline.(Job_Name100).files_out.files{2};
            pipeline.(Job_Name102).files_out.files        = g_BeforeNormalize_LDHk_FileOut( Job_Name102,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.LDH_Neighborhood );
            pipeline.(Job_Name102).opt.LDHk_file          = pipeline.(Job_Name100).files_out.files{2};
            pipeline.(Job_Name102).opt.JobName    =  Job_Name102;
        end

        % FAnormalize job
        Job_Name15 = [ 'FAnormalize_',Number_Of_Subject_String ];
        pipeline.(Job_Name15).command             = 'g_FAnormalize( opt.FA_4tbss_file,opt.target,opt.JobName )';
        pipeline.(Job_Name15).files_in.files      = pipeline.(Job_Name10).files_out.files;
        pipeline.(Job_Name15).files_out.files     = g_FAnormalize_FileOut( Job_Name15,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name15).opt.FA_4tbss_file   = pipeline.(Job_Name10).files_out.files{1};
        pipeline.(Job_Name15).opt.target          = dti_opt.FAnormalize_target;
        pipeline.(Job_Name15).opt.JobName    =  Job_Name15;

        % applywarp_1 job
        Job_Name16 = [ 'applywarp_FA_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name16).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName,opt.target_fileName )';
        pipeline.(Job_Name16).files_in.files    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name16).files_out.files     = g_applywarp_1_FileOut( Job_Name16,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name16).opt.raw_file        = pipeline.(Job_Name10).files_out.files{1};
        pipeline.(Job_Name16).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
        pipeline.(Job_Name16).opt.ref_fileName    = dti_opt.applywarp_1_ref_fileName;
        pipeline.(Job_Name16).opt.JobName    =  Job_Name16;
        pipeline.(Job_Name16).opt.target_fileName = dti_opt.FAnormalize_target;
        
        % applywarp_3 job
        Job_Name18 = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name18).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name18).files_in.files1     = pipeline.(Job_Name11).files_out.files;
        pipeline.(Job_Name18).files_in.files2     = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name18).files_out.files    = g_applywarp_3_FileOut( Job_Name18,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name18).opt.raw_file        = pipeline.(Job_Name11).files_out.files{1};
        pipeline.(Job_Name18).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
        pipeline.(Job_Name18).opt.ref_fileName    = dti_opt.applywarp_3_ref_fileName;
        pipeline.(Job_Name18).opt.JobName    =  Job_Name18;
        
        % applywarp_5 job
        Job_Name20 = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name20).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name12).files_out.files;
        pipeline.(Job_Name20).files_in.files2    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name20).files_out.files     = g_applywarp_5_FileOut( Job_Name20,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name20).opt.raw_file        = pipeline.(Job_Name12).files_out.files{1};
        pipeline.(Job_Name20).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
        pipeline.(Job_Name20).opt.ref_fileName    = dti_opt.applywarp_5_ref_fileName;      
        pipeline.(Job_Name20).opt.JobName    =  Job_Name20;
        
        % applywarp_7 job
        Job_Name22 = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name22).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name22).files_in.files1    = pipeline.(Job_Name13).files_out.files;
        pipeline.(Job_Name22).files_in.files2    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name22).files_out.files   = g_applywarp_7_FileOut( Job_Name22,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name22).opt.raw_file        = pipeline.(Job_Name13).files_out.files{1};
        pipeline.(Job_Name22).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
        pipeline.(Job_Name22).opt.ref_fileName    = dti_opt.applywarp_7_ref_fileName;
        pipeline.(Job_Name22).opt.JobName    =  Job_Name22;
        
        if dti_opt.LDH_Flag
            % applywarp LDH Spearman job
            Job_Name103 = [ 'applywarp_LDHs_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name103).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
            pipeline.(Job_Name103).files_in.files1    = pipeline.(Job_Name101).files_out.files;
            pipeline.(Job_Name103).files_in.files2    = pipeline.(Job_Name15).files_out.files;
            pipeline.(Job_Name103).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix ...
                '_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm.nii.gz'];
            pipeline.(Job_Name103).opt.raw_file       = pipeline.(Job_Name101).files_out.files{1};
            pipeline.(Job_Name103).opt.warp_file      = pipeline.(Job_Name15).files_out.files{3};
            pipeline.(Job_Name103).opt.ref_fileName   = 1;
            pipeline.(Job_Name103).opt.JobName    =  Job_Name103;

            % applywarp LDH Kendall job
            Job_Name104 = [ 'applywarp_LDHk_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name104).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
            pipeline.(Job_Name104).files_in.files1    = pipeline.(Job_Name102).files_out.files;
            pipeline.(Job_Name104).files_in.files2    = pipeline.(Job_Name15).files_out.files;
            pipeline.(Job_Name104).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix ...
                '_' num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm.nii.gz'];
            pipeline.(Job_Name104).opt.raw_file       = pipeline.(Job_Name102).files_out.files{1};
            pipeline.(Job_Name104).opt.warp_file      = pipeline.(Job_Name15).files_out.files{3};
            pipeline.(Job_Name104).opt.ref_fileName   = 1;
            pipeline.(Job_Name104).opt.JobName    =  Job_Name104;
        end
    end
        
    if dti_opt.Resampling_Flag 
        if dti_opt.applywarp_2_ref_fileName ~= 1
            % applywarp_2 job
            Job_Name17 = [ 'applywarp_FA_',num2str(dti_opt.applywarp_2_ref_fileName),'mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name17).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
            pipeline.(Job_Name17).files_in.files    = pipeline.(Job_Name15).files_out.files;
            pipeline.(Job_Name17).files_out.files     = g_applywarp_2_FileOut( Job_Name17,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_2_ref_fileName );
            pipeline.(Job_Name17).opt.raw_file        = pipeline.(Job_Name10).files_out.files{1};
            pipeline.(Job_Name17).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
            pipeline.(Job_Name17).opt.ref_fileName    = dti_opt.applywarp_2_ref_fileName;
            pipeline.(Job_Name17).opt.JobName    =  Job_Name17;

            % applywarp_4 job
            Job_Name19 = [ 'applywarp_MD_',num2str(dti_opt.applywarp_4_ref_fileName),'mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name19).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
            pipeline.(Job_Name19).files_in.files1    = pipeline.(Job_Name11).files_out.files;
            pipeline.(Job_Name19).files_in.files2    = pipeline.(Job_Name15).files_out.files;
            pipeline.(Job_Name19).files_out.files    = g_applywarp_4_FileOut( Job_Name19,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_4_ref_fileName );
            pipeline.(Job_Name19).opt.raw_file        = pipeline.(Job_Name11).files_out.files{1};
            pipeline.(Job_Name19).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
            pipeline.(Job_Name19).opt.ref_fileName    = dti_opt.applywarp_4_ref_fileName;
            pipeline.(Job_Name19).opt.JobName    =  Job_Name19;

            % applywarp_6 job
            Job_Name21 = [ 'applywarp_L1_',num2str(dti_opt.applywarp_6_ref_fileName),'mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name21).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
            pipeline.(Job_Name21).files_in.files1    = pipeline.(Job_Name12).files_out.files;
            pipeline.(Job_Name21).files_in.files2    = pipeline.(Job_Name15).files_out.files;
            pipeline.(Job_Name21).files_out.files   = g_applywarp_6_FileOut( Job_Name21,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_6_ref_fileName );
            pipeline.(Job_Name21).opt.raw_file        = pipeline.(Job_Name12).files_out.files{1};
            pipeline.(Job_Name21).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
            pipeline.(Job_Name21).opt.ref_fileName    = dti_opt.applywarp_6_ref_fileName;
            pipeline.(Job_Name21).opt.JobName    =  Job_Name21;

            % applywarp_8 job
            Job_Name23 = [ 'applywarp_L23m_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name23).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
            pipeline.(Job_Name23).files_in.files1    = pipeline.(Job_Name13).files_out.files;
            pipeline.(Job_Name23).files_in.files2    = pipeline.(Job_Name15).files_out.files;
            pipeline.(Job_Name23).files_out.files   = g_applywarp_8_FileOut( Job_Name23,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_8_ref_fileName );
            pipeline.(Job_Name23).opt.raw_file        = pipeline.(Job_Name13) .files_out.files{1};
            pipeline.(Job_Name23).opt.warp_file       = pipeline.(Job_Name15).files_out.files{3};
            pipeline.(Job_Name23).opt.ref_fileName    = dti_opt.applywarp_8_ref_fileName;
            pipeline.(Job_Name23).opt.JobName    =  Job_Name23;
            
            if dti_opt.LDH_Flag
                % applywarp LDH Spearman job
                Job_Name105 = [ 'applywarp_LDHs_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name105).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
                pipeline.(Job_Name105).files_in.files1    = pipeline.(Job_Name101).files_out.files;
                pipeline.(Job_Name105).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                pipeline.(Job_Name105).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm.nii.gz'];
                pipeline.(Job_Name105).opt.raw_file       = pipeline.(Job_Name101).files_out.files{1};
                pipeline.(Job_Name105).opt.warp_file      = pipeline.(Job_Name15).files_out.files{3};
                pipeline.(Job_Name105).opt.ref_fileName   = dti_opt.applywarp_8_ref_fileName;
                pipeline.(Job_Name105).opt.JobName    =  Job_Name105;

                % applywarp LDH Kendall job
                Job_Name106 = [ 'applywarp_LDHk_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
                pipeline.(Job_Name106).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
                pipeline.(Job_Name106).files_in.files1    = pipeline.(Job_Name102).files_out.files;
                pipeline.(Job_Name106).files_in.files2    = pipeline.(Job_Name15).files_out.files;
                pipeline.(Job_Name106).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm.nii.gz'];
                pipeline.(Job_Name106).opt.raw_file       = pipeline.(Job_Name102).files_out.files{1};
                pipeline.(Job_Name106).opt.warp_file      = pipeline.(Job_Name15).files_out.files{3};
                pipeline.(Job_Name106).opt.ref_fileName   = dti_opt.applywarp_8_ref_fileName;
                pipeline.(Job_Name106).opt.JobName    =  Job_Name106;
            end
        end
    end

    if dti_opt.Smoothing_Flag
        % smoothNII_1 job
        Job_Name24 = [ 'smoothNII_FA_',num2str(dti_opt.applywarp_2_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name24).command           = 'g_smoothNII( opt.fileName,opt.kernel_size,opt.JobName )';
        if dti_opt.applywarp_2_ref_fileName ~= 1
            pipeline.(Job_Name24).files_in.files    = pipeline.(Job_Name17).files_out.files;
            pipeline.(Job_Name24).opt.fileName      = pipeline.(Job_Name17).files_out.files{1};
        else
            pipeline.(Job_Name24).files_in.files    = pipeline.(Job_Name16).files_out.files;
            pipeline.(Job_Name24).opt.fileName      = pipeline.(Job_Name16).files_out.files{1};
        end
        pipeline.(Job_Name24).files_out.files   = g_smoothNII_1_FileOut( Job_Name24,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_2_ref_fileName );

        pipeline.(Job_Name24).opt.kernel_size   = dti_opt.smoothNII_1_kernel_size;
        pipeline.(Job_Name24).opt.JobName    =  Job_Name24;

        % smoothNII_2 job
        Job_Name25 = [ 'smoothNII_MD_',num2str(dti_opt.applywarp_4_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name25).command           = 'g_smoothNII( opt.fileName,opt.kernel_size,opt.JobName )';
        if dti_opt.applywarp_4_ref_fileName ~= 1
            pipeline.(Job_Name25).files_in.files    = pipeline.(Job_Name19).files_out.files;
            pipeline.(Job_Name25).opt.fileName      = pipeline.(Job_Name19).files_out.files{1};
        else
            pipeline.(Job_Name25).files_in.files    = pipeline.(Job_Name18).files_out.files;
            pipeline.(Job_Name25).opt.fileName      = pipeline.(Job_Name18).files_out.files{1};
        end
        pipeline.(Job_Name25).files_out.files   = g_smoothNII_2_FileOut( Job_Name25,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_4_ref_fileName );

        pipeline.(Job_Name25).opt.kernel_size   = dti_opt.smoothNII_2_kernel_size;
        pipeline.(Job_Name25).opt.JobName    =  Job_Name25;

        % smoothNII_3 job
        Job_Name26 = [ 'smoothNII_L1_',num2str(dti_opt.applywarp_6_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name26).command           = 'g_smoothNII( opt.fileName,opt.kernel_size,opt.JobName )';
        if dti_opt.applywarp_6_ref_fileName ~= 1
            pipeline.(Job_Name26).files_in.files    = pipeline.(Job_Name21).files_out.files;
            pipeline.(Job_Name26).opt.fileName      = pipeline.(Job_Name21).files_out.files{1};
        else
            pipeline.(Job_Name26).files_in.files    = pipeline.(Job_Name20).files_out.files;
            pipeline.(Job_Name26).opt.fileName      = pipeline.(Job_Name20).files_out.files{1};
        end
        pipeline.(Job_Name26).files_out.files   = g_smoothNII_3_FileOut( Job_Name26,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_6_ref_fileName );
        pipeline.(Job_Name26).opt.kernel_size   = dti_opt.smoothNII_3_kernel_size;
        pipeline.(Job_Name26).opt.JobName    =  Job_Name26;

        % smoothNII_4 job
        Job_Name27 = [ 'smoothNII_L23m_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name27).command           = 'g_smoothNII( opt.fileName,opt.kernel_size,opt.JobName )';
        if dti_opt.applywarp_8_ref_fileName ~= 1
            pipeline.(Job_Name27).files_in.files    = pipeline.(Job_Name23).files_out.files;
            pipeline.(Job_Name27).opt.fileName      = pipeline.(Job_Name23).files_out.files{1};
        else
            pipeline.(Job_Name27).files_in.files    = pipeline.(Job_Name22).files_out.files;
            pipeline.(Job_Name27).opt.fileName      = pipeline.(Job_Name22).files_out.files{1};
        end
        pipeline.(Job_Name27).files_out.files   = g_smoothNII_4_FileOut( Job_Name27,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_8_ref_fileName );
        pipeline.(Job_Name27).opt.kernel_size   = dti_opt.smoothNII_4_kernel_size;
        pipeline.(Job_Name27).opt.JobName    =  Job_Name27;
        
        if dti_opt.LDH_Flag
            % smooth LDH Spearman job
            Job_Name107 = [ 'smoothNII_LDHs_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name107).command           = 'g_smoothNII( opt.fileName,opt.kernel_size,opt.JobName )';
            if dti_opt.applywarp_8_ref_fileName ~= 1
                pipeline.(Job_Name107).files_in.files    = pipeline.(Job_Name105).files_out.files;
                pipeline.(Job_Name107).opt.fileName      = pipeline.(Job_Name105).files_out.files{1};
            else
                pipeline.(Job_Name107).files_in.files    = pipeline.(Job_Name103).files_out.files;
                pipeline.(Job_Name107).opt.fileName      = pipeline.(Job_Name103).files_out.files{1};
            end
            pipeline.(Job_Name107).files_out.files{1}   = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') ...
                'LDHs_4normalize_to_target_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm_s' num2str(dti_opt.smoothNII_4_kernel_size) 'mm.nii.gz'];
            pipeline.(Job_Name107).opt.kernel_size   = dti_opt.smoothNII_4_kernel_size;
            pipeline.(Job_Name107).opt.JobName    =  Job_Name107;

            % smooth LDH Kendall job
            Job_Name108 = [ 'smoothNII_LDHk_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name108).command           = 'g_smoothNII( opt.fileName,opt.kernel_size,opt.JobName )';
            if dti_opt.applywarp_8_ref_fileName ~= 1
                pipeline.(Job_Name108).files_in.files    = pipeline.(Job_Name106).files_out.files;
                pipeline.(Job_Name108).opt.fileName      = pipeline.(Job_Name106).files_out.files{1};
            else
                pipeline.(Job_Name108).files_in.files    = pipeline.(Job_Name104).files_out.files;
                pipeline.(Job_Name108).opt.fileName      = pipeline.(Job_Name104).files_out.files{1};
            end
            pipeline.(Job_Name108).files_out.files{1}   = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' num2str(dti_opt.LDH_Neighborhood, '%02d') ...
                'LDHk_4normalize_to_target_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm_s' num2str(dti_opt.smoothNII_4_kernel_size) 'mm.nii.gz'];
            pipeline.(Job_Name108).opt.kernel_size   = dti_opt.smoothNII_4_kernel_size;
            pipeline.(Job_Name108).opt.JobName    =  Job_Name108;
        end
    end
    
    if dti_opt.Atlas_Flag
        % JHUatlas_1mm_1 job
        Job_Name28 = [ 'atlas_FA_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name28).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        Applywarp_FA_JobName = [ 'applywarp_FA_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name28).files_in.files1    = pipeline.(Applywarp_FA_JobName).files_out.files;
        pipeline.(Job_Name28).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name28).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name28).files_out.files   = g_JHUatlas_1mm_1_FileOut( Job_Name28,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name28).opt.Dmetric_fileName    = pipeline.(Applywarp_FA_JobName).files_out.files{1};
        pipeline.(Job_Name28).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name28).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name28).opt.JobName    =  Job_Name28;

        % JHUatlas_1mm_2 job
        Job_Name29 = [ 'atlas_MD_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name29).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        Applywarp_MD_JobName = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name29).files_in.files1    = pipeline.(Applywarp_MD_JobName).files_out.files;
        pipeline.(Job_Name29).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name29).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name29).files_out.files   = g_JHUatlas_1mm_2_FileOut( Job_Name29,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name29).opt.Dmetric_fileName    = pipeline.(Applywarp_MD_JobName).files_out.files{1};
        pipeline.(Job_Name29).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name29).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name29).opt.JobName    =  Job_Name29;

        % JHUatlas_1mm_3 job
        Job_Name30 = [ 'atlas_L1_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name30).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        Applywarp_L1_JobName = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name30).files_in.files1    = pipeline.(Applywarp_L1_JobName).files_out.files;
        pipeline.(Job_Name30).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name30).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name30).files_out.files   = g_JHUatlas_1mm_3_FileOut( Job_Name30,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name30).opt.Dmetric_fileName    = pipeline.(Applywarp_L1_JobName).files_out.files{1};
        pipeline.(Job_Name30).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name30).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name30).opt.JobName    =  Job_Name30;

        % JHUatlas_1mm_4 job
        Job_Name31 = [ 'atlas_L23m_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name31).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        Applywarp_L23m_JobName = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name31).files_in.files1    = pipeline.(Applywarp_L23m_JobName).files_out.files;
        pipeline.(Job_Name31).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name31).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name31).files_out.files   = g_JHUatlas_1mm_4_FileOut( Job_Name31,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name31).opt.Dmetric_fileName    = pipeline.(Applywarp_L23m_JobName).files_out.files{1};
        pipeline.(Job_Name31).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name31).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name31).opt.JobName    =  Job_Name31;
        
        if dti_opt.LDH_Flag
            % JHUatlas_1mm LDH Spearman job
            Job_Name109 = [ 'atlas_LDHs_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name109).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
            Applywarp_LDHs_JobName = [ 'applywarp_LDHs_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name109).files_in.files1   = pipeline.(Applywarp_LDHs_JobName).files_out.files;
            pipeline.(Job_Name109).files_in.files2    = pipeline.(Job_Name93).files_out.files;
            pipeline.(Job_Name109).files_in.files3    = pipeline.(Job_Name94).files_out.files;
            pipeline.(Job_Name109).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix ...
                '_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm.WMlabel'];
            pipeline.(Job_Name109).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix ...
                '_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm.WMtract'];
            pipeline.(Job_Name109).opt.Dmetric_fileName = pipeline.(Applywarp_LDHs_JobName).files_out.files{1};
            pipeline.(Job_Name109).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
            pipeline.(Job_Name109).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
            pipeline.(Job_Name109).opt.JobName    =  Job_Name109;

            % JHUatlas_1mm LDH Kendall job
            Job_Name110 = [ 'atlas_LDHk_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name110).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
            Applywarp_LDHk_JobName = [ 'applywarp_LDHk_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name110).files_in.files1   = pipeline.(Applywarp_LDHk_JobName).files_out.files;
            pipeline.(Job_Name110).files_in.files2    = pipeline.(Job_Name93).files_out.files;
            pipeline.(Job_Name110).files_in.files3    = pipeline.(Job_Name94).files_out.files;
            pipeline.(Job_Name110).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix ...
                '_' num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm.WMlabel'];
            pipeline.(Job_Name110).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix ...
                '_' num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm.WMtract'];
            pipeline.(Job_Name110).opt.Dmetric_fileName = pipeline.(Applywarp_LDHk_JobName).files_out.files{1};
            pipeline.(Job_Name110).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
            pipeline.(Job_Name110).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
            pipeline.(Job_Name110).opt.JobName    =  Job_Name110;
        end
    end
    
    % delete tmporary file
    Job_Name32 = [ 'delete_tmp_file_',Number_Of_Subject_String ];
    pipeline.(Job_Name32).command           = 'g_delete_tmp_file( opt.Nii_Output_Folder_Path,opt.Delete_Flag,opt.QuantityOfSequence,opt.Prefix,opt.JobName )';
    FileInQuantity = 0;
    if dti_opt.Smoothing_Flag
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name24).files_out.files{2};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name25).files_out.files{2};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 3} = pipeline.(Job_Name26).files_out.files{2};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 4} = pipeline.(Job_Name27).files_out.files{2};
        FileInQuantity = FileInQuantity + 4;
        if dti_opt.LDH_Flag
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name107).files_out.files{1};
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name108).files_out.files{1};
            FileInQuantity = FileInQuantity + 2;
        end
    end
    if dti_opt.Atlas_Flag
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name28).files_out.files{3};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name29).files_out.files{3};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 3} = pipeline.(Job_Name30).files_out.files{3};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 4} = pipeline.(Job_Name31).files_out.files{3};
        FileInQuantity = FileInQuantity + 4;
        if dti_opt.LDH_Flag
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name109).files_out.files{1};
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name109).files_out.files{2};
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 3} = pipeline.(Job_Name110).files_out.files{1};
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 4} = pipeline.(Job_Name110).files_out.files{2};
            FileInQuantity = FileInQuantity + 4;
        end
        
    end
    if ~dti_opt.Smoothing_Flag && ~dti_opt.Atlas_Flag && dti_opt.Resampling_Flag
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name17).files_out.files{1};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name19).files_out.files{1};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 3} = pipeline.(Job_Name21).files_out.files{1};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 4} = pipeline.(Job_Name23).files_out.files{1};
        FileInQuantity = FileInQuantity + 4;
        if dti_opt.LDH_Flag
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name105).files_out.files{1};
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name106).files_out.files{1};
            FileInQuantity = FileInQuantity + 2;
        end
    end
    if ~dti_opt.Smoothing_Flag && ~dti_opt.Atlas_Flag && (dti_opt.Resampling_Flag || dti_opt.Normalizing_Flag)
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name16).files_out.files{1};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name18).files_out.files{1};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 3} = pipeline.(Job_Name20).files_out.files{1};
        pipeline.(Job_Name32).files_in.files{FileInQuantity + 4} = pipeline.(Job_Name22).files_out.files{1};
        FileInQuantity = FileInQuantity + 4;
        if dti_opt.LDH_Flag
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 1} = pipeline.(Job_Name103).files_out.files{1};
            pipeline.(Job_Name32).files_in.files{FileInQuantity + 2} = pipeline.(Job_Name104).files_out.files{1};
            FileInQuantity = FileInQuantity + 2;
        end
    end
    if ~dti_opt.Normalizing_Flag
        pipeline.(Job_Name32).files_in.files = pipeline.(Job_Name9).files_out.files;
    end
    pipeline.(Job_Name32).files_out.files   = g_delete_tmp_file_FileOut( Job_Name32,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name32).opt.Nii_Output_Folder_Path    = [Nii_Output_Path filesep Number_Of_Subject_String '/'];
    pipeline.(Job_Name32).opt.Delete_Flag               = dti_opt.Delete_Flag;
    pipeline.(Job_Name32).opt.QuantityOfSequence        = Quantity_Of_Sequence;
    pipeline.(Job_Name32).opt.Prefix                    = dtifit_Prefix;
    pipeline.(Job_Name32).opt.JobName    =  Job_Name32;
 
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
    pipeline.(Job_Name33).files_out.files   = g_dismap_FileOut( Job_Name33,Nii_Output_Path );
    pipeline.(Job_Name33).opt.Nii_Output_Path   = Nii_Output_Path;
    pipeline.(Job_Name33).opt.threshold         = dti_opt.dismap_threshold;
end

for i = 1:length(Data_Raw_Path_Cell)
    DeterministicTrackingResultExist(i) = 1;
end

for i = 1:length(Data_Raw_Path_Cell)
    Number_Of_Subject = index_vector(i);
    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
    SubjectFolder = [Nii_Output_Path Number_Of_Subject_String];
    Native_Folder = [SubjectFolder filesep 'native_space'];
    % Basename for the output file of the dtifit
    if isempty(FA_Prefix)
        dtifit_Prefix = Number_Of_Subject_String;
    else
        dtifit_Prefix = [FA_Prefix '_' Number_Of_Subject_String];
    end
    
    if dti_opt.TBSS_Flag
        % skeleton_FA job
        Job_Name34 = [ 'skeleton_FA_',Number_Of_Subject_String ];
        pipeline.(Job_Name34).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName )';
        Applywarp_1_Name = [ 'applywarp_FA_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name34).files_in.files{1} = pipeline.(Applywarp_1_Name).files_out.files{1};
        pipeline.(Job_Name34).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
        pipeline.(Job_Name34).files_out.files   = g_2skeleton_FA_FileOut( Job_Name34,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name34).opt.fileName      = pipeline.(Applywarp_1_Name).files_out.files{1};
        pipeline.(Job_Name34).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
        pipeline.(Job_Name34).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
        pipeline.(Job_Name34).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
        pipeline.(Job_Name34).opt.threshold     = dti_opt.dismap_threshold;
        pipeline.(Job_Name34).opt.JobName    =  Job_Name34;

        % skeleton_MD job
        Job_Name35 = [ 'skeleton_MD_',Number_Of_Subject_String ];
        pipeline.(Job_Name35).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName )';
        Applywarp_3_Name = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name35).files_in.files{1} = pipeline.(Applywarp_3_Name).files_out.files{1};
        pipeline.(Job_Name35).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
        pipeline.(Job_Name35).files_out.files   = g_2skeleton_MD_FileOut( Job_Name35,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name35).opt.fileName      = pipeline.(Applywarp_3_Name).files_out.files{1};
        pipeline.(Job_Name35).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
        pipeline.(Job_Name35).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
        pipeline.(Job_Name35).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
        pipeline.(Job_Name35).opt.threshold     = dti_opt.dismap_threshold;
        pipeline.(Job_Name35).opt.JobName    =  Job_Name35;

        % skeleton_L1 job
        Job_Name36 = [ 'skeleton_L1_',Number_Of_Subject_String ];
        pipeline.(Job_Name36).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName )';
        Applywarp_5_Name = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name36).files_in.files{1} = pipeline.(Applywarp_5_Name).files_out.files{1};
        pipeline.(Job_Name36).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
        pipeline.(Job_Name36).files_out.files   = g_2skeleton_L1_FileOut( Job_Name36,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name36).opt.fileName      = pipeline.(Applywarp_5_Name).files_out.files{1};
        pipeline.(Job_Name36).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
        pipeline.(Job_Name36).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
        pipeline.(Job_Name36).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
        pipeline.(Job_Name36).opt.threshold     = dti_opt.dismap_threshold;
        pipeline.(Job_Name36).opt.JobName    =  Job_Name36;

        % skeleton_L23m job
        Job_Name37 = [ 'skeleton_L23m_',Number_Of_Subject_String ];
        pipeline.(Job_Name37).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName )';
        Applywarp_7_Name = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name37).files_in.files{1} = pipeline.(Applywarp_7_Name).files_out.files{1};
        pipeline.(Job_Name37).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
        pipeline.(Job_Name37).files_out.files   = g_2skeleton_L23m_FileOut( Job_Name37,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
        pipeline.(Job_Name37).opt.fileName      = pipeline.(Applywarp_7_Name).files_out.files{1};
        pipeline.(Job_Name37).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
        pipeline.(Job_Name37).opt.Mean_FA_fileName   = pipeline.(Job_Name33).files_out.files{1};
        pipeline.(Job_Name37).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
        pipeline.(Job_Name37).opt.threshold     = dti_opt.dismap_threshold;
        pipeline.(Job_Name37).opt.JobName    =  Job_Name37;
        
        if dti_opt.LDH_Flag
            % skeleton LDH Spearman job
            Job_Name111 = [ 'skeleton_LDHs_',Number_Of_Subject_String ];
            pipeline.(Job_Name111).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName )';
            Applywarp_LDHs_JobName = [ 'applywarp_LDHs_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name111).files_in.files{1} = pipeline.(Applywarp_LDHs_JobName).files_out.files{1};
            pipeline.(Job_Name111).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
            pipeline.(Job_Name111).files_out.files   = {[Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm_skeletonised.nii.gz']};
            pipeline.(Job_Name111).opt.fileName      = pipeline.(Applywarp_LDHs_JobName).files_out.files{1};
            pipeline.(Job_Name111).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
            pipeline.(Job_Name111).opt.Mean_FA_fileName = pipeline.(Job_Name33).files_out.files{1};
            pipeline.(Job_Name111).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
            pipeline.(Job_Name111).opt.threshold     = dti_opt.dismap_threshold;
            pipeline.(Job_Name111).opt.JobName       = Job_Name111;

            % skeleton LDH Kendall job
            Job_Name112 = [ 'skeleton_LDHk_',Number_Of_Subject_String ];
            pipeline.(Job_Name112).command           = 'g_2skeleton( opt.fileName,opt.FA_fileName,opt.Mean_FA_fileName,opt.Dst_fileName,opt.threshold,opt.JobName )';
            Applywarp_LDHk_JobName = [ 'applywarp_LDHk_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name112).files_in.files{1} = pipeline.(Applywarp_LDHk_JobName).files_out.files{1};
            pipeline.(Job_Name112).files_in.files{2} = pipeline.(Job_Name33).files_out.files{5};
            pipeline.(Job_Name112).files_out.files   = {[Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm_skeletonised.nii.gz']};
            pipeline.(Job_Name112).opt.fileName      = pipeline.(Applywarp_LDHk_JobName).files_out.files{1};
            pipeline.(Job_Name112).opt.FA_fileName   = pipeline.(Applywarp_1_Name).files_out.files{1};
            pipeline.(Job_Name112).opt.Mean_FA_fileName = pipeline.(Job_Name33).files_out.files{1};
            pipeline.(Job_Name112).opt.Dst_fileName  = pipeline.(Job_Name33).files_out.files{5}; 
            pipeline.(Job_Name112).opt.threshold     = dti_opt.dismap_threshold;
            pipeline.(Job_Name112).opt.JobName       = Job_Name112;
        end
        
        % Atlas results for tbss
        Job_Name113 = [ 'skeleton_atlas_FA_',Number_Of_Subject_String ];
        pipeline.(Job_Name113).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        pipeline.(Job_Name113).files_in.files{1} = pipeline.(Job_Name34).files_out.files{1};
        pipeline.(Job_Name113).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name113).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name113).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'FA_4normalize_to_target_1mm_skeletonised.WMlabel'];
        pipeline.(Job_Name113).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'FA_4normalize_to_target_1mm_skeletonised.WMtract'];
        pipeline.(Job_Name113).opt.Dmetric_fileName = pipeline.(Job_Name34).files_out.files{1};
        pipeline.(Job_Name113).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name113).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name113).opt.JobName    =  Job_Name113;
        
        Job_Name114 = [ 'skeleton_atlas_MD_',Number_Of_Subject_String ];
        pipeline.(Job_Name114).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        pipeline.(Job_Name114).files_in.files{1} = pipeline.(Job_Name35).files_out.files{1};
        pipeline.(Job_Name114).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name114).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name114).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'MD_4normalize_to_target_1mm_skeletonised.WMlabel'];
        pipeline.(Job_Name114).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'MD_4normalize_to_target_1mm_skeletonised.WMtract'];
        pipeline.(Job_Name114).opt.Dmetric_fileName = pipeline.(Job_Name35).files_out.files{1};
        pipeline.(Job_Name114).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name114).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name114).opt.JobName    =  Job_Name114;
        
        Job_Name115 = [ 'skeleton_atlas_L1_',Number_Of_Subject_String ];
        pipeline.(Job_Name115).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        pipeline.(Job_Name115).files_in.files{1} = pipeline.(Job_Name36).files_out.files{1};
        pipeline.(Job_Name115).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name115).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name115).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'L1_4normalize_to_target_1mm_skeletonised.WMlabel'];
        pipeline.(Job_Name115).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'L1_4normalize_to_target_1mm_skeletonised.WMtract'];
        pipeline.(Job_Name115).opt.Dmetric_fileName = pipeline.(Job_Name36).files_out.files{1};
        pipeline.(Job_Name115).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name115).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name115).opt.JobName    =  Job_Name115;
        
        Job_Name116 = [ 'skeleton_atlas_L23m_',Number_Of_Subject_String ];
        pipeline.(Job_Name116).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
        pipeline.(Job_Name116).files_in.files{1} = pipeline.(Job_Name37).files_out.files{1};
        pipeline.(Job_Name116).files_in.files2    = pipeline.(Job_Name93).files_out.files;
        pipeline.(Job_Name116).files_in.files3    = pipeline.(Job_Name94).files_out.files;
        pipeline.(Job_Name116).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'L23m_4normalize_to_target_1mm_skeletonised.WMlabel'];
        pipeline.(Job_Name116).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                'L23m_4normalize_to_target_1mm_skeletonised.WMtract'];
        pipeline.(Job_Name116).opt.Dmetric_fileName = pipeline.(Job_Name37).files_out.files{1};
        pipeline.(Job_Name116).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
        pipeline.(Job_Name116).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
        pipeline.(Job_Name116).opt.JobName    =  Job_Name116;
        
        if dti_opt.LDH_Flag
            Job_Name117 = [ 'skeleton_atlas_LDHs_',Number_Of_Subject_String ];
            pipeline.(Job_Name117).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
            pipeline.(Job_Name117).files_in.files{1} = pipeline.(Job_Name111).files_out.files{1};
            pipeline.(Job_Name117).files_in.files2    = pipeline.(Job_Name93).files_out.files;
            pipeline.(Job_Name117).files_in.files3    = pipeline.(Job_Name94).files_out.files;
            pipeline.(Job_Name117).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm_skeletonised.WMlabel'];
            pipeline.(Job_Name117).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs_4normalize_to_target_1mm_skeletonised.WMtract'];
            pipeline.(Job_Name117).opt.Dmetric_fileName = pipeline.(Job_Name111).files_out.files{1};
            pipeline.(Job_Name117).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
            pipeline.(Job_Name117).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
            pipeline.(Job_Name117).opt.JobName    =  Job_Name117;

            Job_Name118 = [ 'skeleton_atlas_LDHk_',Number_Of_Subject_String ];
            pipeline.(Job_Name118).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
            pipeline.(Job_Name118).files_in.files{1} = pipeline.(Job_Name112).files_out.files{1};
            pipeline.(Job_Name118).files_in.files2    = pipeline.(Job_Name93).files_out.files;
            pipeline.(Job_Name118).files_in.files3    = pipeline.(Job_Name94).files_out.files;
            pipeline.(Job_Name118).files_out.files{1} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm_skeletonised.WMlabel'];
            pipeline.(Job_Name118).files_out.files{2} = [Nii_Output_Path Number_Of_Subject_String filesep 'standard_space' filesep dtifit_Prefix '_' ...
                    num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk_4normalize_to_target_1mm_skeletonised.WMtract'];
            pipeline.(Job_Name118).opt.Dmetric_fileName = pipeline.(Job_Name112).files_out.files{1};
            pipeline.(Job_Name118).opt.WM_Label_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_label'];
            pipeline.(Job_Name118).opt.WM_Probtract_Atlas = [Nii_Output_Path filesep 'logs' filesep 'WM_tract_prob'];
            pipeline.(Job_Name118).opt.JobName    =  Job_Name118;
        end
        
    end

    if tracking_opt.DterminFiberTracking == 1
        % tracking
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
        
        Job_Name38 = [ 'DeterministicTracking_',Number_Of_Subject_String ];
%         DeterministicTrackingOutput{i} = g_DeterministicTracking_FileOut( Job_Name38,Nii_Output_Path,Number_Of_Subject_String,Option,dtifit_Prefix );
        
%         if ~exist(DeterministicTrackingOutput{i}{1}, 'file')
%             DeterministicTrackingResultExist(i) = 0;
%         end
%         if strcmp(Option.ApplySplineFilter, 'Yes')
%             if ~exist(DeterministicTrackingOutput{i}{2}, 'file')
%                 DeterministicTrackingResultExist(i) = 0;
%             end
%         end
%         if tracking_opt.DeterminTrackingOptionChange
%             DeterministicTrackingResultExist(i) = 0;
%         end
%         if ~DeterministicTrackingResultExist(i)   
        pipeline.(Job_Name38).command           = 'g_DeterministicTracking( opt.NativeFolderPath,opt.tracking_opt,opt.Prefix,opt.JobName )';
        merge_Name = [ 'merge_' Number_Of_Subject_String ];
        pipeline.(Job_Name38).files_in.files{1} = pipeline.(merge_Name).files_out.files{1};
        pipeline.(Job_Name38).files_in.files{2} = pipeline.(merge_Name).files_out.files{2};
        pipeline.(Job_Name38).files_in.files{3} = pipeline.(merge_Name).files_out.files{3};
        pipeline.(Job_Name38).files_out.files   = g_DeterministicTracking_FileOut( Job_Name38,Nii_Output_Path,Number_Of_Subject_String,Option,dtifit_Prefix );
        pipeline.(Job_Name38).opt.NativeFolderPath    = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'native_space'];
        pipeline.(Job_Name38).opt.tracking_opt        = Option;
        pipeline.(Job_Name38).opt.Prefix          = dtifit_Prefix;
        pipeline.(Job_Name38).opt.JobName    =  Job_Name38;
%         end
    end
        
    % Network Node Definition
    if tracking_opt.NetworkNode == 1 & ~tracking_opt.PartitionOfSubjects 
        FAFileName = [dtifit_Prefix '_FA'];
        FAPath = [Native_Folder filesep FAFileName '.nii.gz'];
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
        
        Job_Name60 = [ 'CopyT1_' Number_Of_Subject_String ];
        pipeline.(Job_Name60).command         = 'if ~strcmp(opt.T1ParentFolder,opt.T1Path);if ~exist(opt.T1Folder);mkdir(opt.T1Folder);end;system([''cp '' opt.T1Path '' '' opt.T1Folder]);end;';
        if strcmp(T1Suffix, '.gz')
            pipeline.(Job_Name60).files_out.files{1} = [T1Folder filesep T1FileName '.nii' T1Suffix];
        else
            pipeline.(Job_Name60).files_out.files{1} = [T1Folder filesep T1FileName T1Suffix];
        end
        pipeline.(Job_Name60).opt.T1Folder = T1Folder;
        pipeline.(Job_Name60).opt.T1ParentFolder = T1ParentFolder;
        pipeline.(Job_Name60).opt.T1Path = T1orPartitionOfSubjects_PathCell{i};
        
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
            pipeline.(Job_Name63).command            = 'g_resample_nii( opt.T1_Path, opt.ResampleResolution, files_out.files{1} )';
            if tracking_opt.T1Cropping_Flag
                pipeline.(Job_Name63).files_in.files = pipeline.(Job_Name62).files_out.files;
                pipeline.(Job_Name63).opt.T1_Path    = pipeline.(Job_Name62).files_out.files{1};
            elseif tracking_opt.T1Bet_Flag
                pipeline.(Job_Name63).files_in.files = pipeline.(Job_Name61).files_out.files;
                pipeline.(Job_Name63).opt.T1_Path    = pipeline.(Job_Name61).files_out.files{1};
            else
                pipeline.(Job_Name63).files_in.files = pipeline.(Job_Name60).files_out.files;
                pipeline.(Job_Name63).opt.T1_Path    = pipeline.(Job_Name60).files_out.files{1};
            end
            pipeline.(Job_Name63).opt.ResampleResolution = tracking_opt.T1ResampleResolution;
            pipeline.(Job_Name63).files_out.files{1} = [NewT1PathPrefix '_resample.nii.gz'];

            NewT1PathPrefix = [NewT1PathPrefix '_resample'];
        end
        
        if tracking_opt.T1Resample_Flag
            FinalT1 = pipeline.(Job_Name63).files_out.files{1};
        elseif tracking_opt.T1Cropping_Flag
            FinalT1 = pipeline.(Job_Name62).files_out.files{1};
        elseif tracking_opt.T1Bet_Flag
            FinalT1 = pipeline.(Job_Name61).files_out.files{1};
        else
            FinalT1 = pipeline.(Job_Name60).files_out.files{1};
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
        pipeline.(Job_Name65).command            = 'g_T1toMNI152( opt.T1_Path, opt.T1Template_Path )';
        pipeline.(Job_Name65).opt.T1_Path        = [NewT1PathPrefix '.nii.gz'];
        pipeline.(Job_Name65).opt.T1Template_Path    = tracking_opt.T1Template;
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
        pipeline.(Job_Name40).command           = 'g_DeterministicNetwork( opt.trackfilepath,opt.T1toFA_PartitionTemplate,opt.FAfilepath,opt.JobName )';
        if ~tracking_opt.PartitionOfSubjects 
            IndividualParcellated_Name = [ 'IndividualParcellated_' Number_Of_Subject_String ];
            pipeline.(Job_Name40).files_in.files1   = pipeline.(IndividualParcellated_Name).files_out;
        end
        Tracking_Name = [ 'DeterministicTracking_' Number_Of_Subject_String ];
%         pipeline.(Job_Name40).files_in.files2   = pipeline.(Tracking_Name).files_out;
        pipeline.(Job_Name40).files_in.files2   = pipeline.(Tracking_Name).files_out.files;
        if tracking_opt.PartitionOfSubjects
            pipeline.(Job_Name40).files_out.files   = g_DeterministicNetwork_FileOut( Job_Name40,Nii_Output_Path,Number_Of_Subject_String,tracking_opt,T1orPartitionOfSubjects_PathCell{i},dtifit_Prefix );
        else
            pipeline.(Job_Name40).files_out.files   = g_DeterministicNetwork_FileOut( Job_Name40,Nii_Output_Path,Number_Of_Subject_String,tracking_opt,tracking_opt.PartitionTemplate,dtifit_Prefix );
        end
        pipeline.(Job_Name40).opt.trackfilepath = pipeline.(Tracking_Name).files_out.files{1};
        if tracking_opt.PartitionOfSubjects 
            pipeline.(Job_Name40).opt.T1toFA_PartitionTemplate = T1orPartitionOfSubjects_PathCell{i};
        else
            pipeline.(Job_Name40).opt.T1toFA_PartitionTemplate = pipeline.(IndividualParcellated_Name).files_out.files{1};
        end
        dtifit_Name = [ 'dtifit_',Number_Of_Subject_String ];
        pipeline.(Job_Name40).opt.FAfilepath =  pipeline.(dtifit_Name).files_out.files{1};
        pipeline.(Job_Name40).opt.JobName    =  Job_Name40;
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
            Job_Name42 = [ 'BedpostX_' num2str(BedpostXJobNum, '%02.0f') '_' Number_Of_Subject_String ];
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
        for j = 1:10
            Job_Name = [ 'BedpostX_' num2str(j, '%02.0f') '_' Number_Of_Subject_String ];
            pipeline.(Job_Name43).files_in.files{j} = pipeline.(Job_Name).files_out.files{1};
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
            pipeline.(Job_Name44).opt.LabelFile   = T1orPartitionOfSubjects_PathCell{i};
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
        ProbabilisticNetworkJobQuantity = min(length(tracking_opt.LabelIdVector), 80);
        for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
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

        ProbabilisticNetworkPostJobQuantity = min(length(tracking_opt.LabelIdVector), 10);
        for ProbabilisticNetworkPostJobNum = 1:ProbabilisticNetworkPostJobQuantity
            Job_Name46 = [ 'ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f') '_'  Number_Of_Subject_String];
            pipeline.(Job_Name46).command        = 'g_track4NETpost_fdt( opt.seed, opt.fdt, opt.ProbabilisticNetworkPostJobNum, opt.prefix )';
            for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
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
            pipeline.(Job_Name46).opt.ProbabilisticNetworkPostJobNum = ProbabilisticNetworkPostJobNum;
            pipeline.(Job_Name46).files_out.files = g_track4NETpost_fdt_FileOut( Native_Folder, Number_Of_Subject_String, ProbabilisticNetworkPostJobNum );
            pipeline.(Job_Name46).opt.prefix = Number_Of_Subject_String;
        end
        
        Job_Name80 = [ 'ProbabilisticNetworkpost_MergeResults_' Number_Of_Subject_String ];
        pipeline.(Job_Name80).command        = 'g_ProbabilisticNetworkMergeResults(opt.ProbabilisticMatrix,opt.prefix,opt.ProbabilisticTrackingType,opt.LabelIdVector)';
        for j = 1:ProbabilisticNetworkPostJobQuantity
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

if tracking_opt.DterminFiberTracking == 1
    save([Nii_Output_Path filesep 'logs' filesep 'DeterministicTrackingResultExist.mat'], 'DeterministicTrackingResultExist');
end

Job_Name47 = 'ExportParametersToExcel';
% if exist([Nii_Output_Path filesep 'AllScanningParameters.xls'], 'file');
%     ParameterFile_Num = 1;
%     while 1
%         if ~exist([Nii_Output_Path filesep 'AllScanningParameters_' num2str(ParameterFile_Num) '.xls'], 'file')
%             ScanningParametersFile = [Nii_Output_Path filesep 'AllScanningParameters_' num2str(ParameterFile_Num) '.xls'];
%             break;
%         end
%     end
% else
ScanningParametersFile = [Nii_Output_Path filesep 'AllScanningParameters.xls'];
% end
pipeline.(Job_Name47).command        = 'g_ExportParametersToExcel( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
for i = 1:length(Data_Raw_Path_Cell)
    Number_Of_Subject = index_vector(i);
    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
    DataParametersJobName = [ 'DataParameters_',Number_Of_Subject_String ];
    pipeline.(Job_Name47).files_in.files{i} = pipeline.(DataParametersJobName).files_out.files{1};
end
% pipeline.(Job_Name47).files_out.files = ScanningParametersFile;
pipeline.(Job_Name47).opt.SubjectIDs = index_vector;
pipeline.(Job_Name47).opt.ResultantFile = ScanningParametersFile;

if dti_opt.Atlas_Flag
    
%     if exist([Nii_Output_Path filesep 'AllAtlasResults'], 'dir')
%         AtlasResultsDir_Num = 1;
%         while 1
%             if ~exist([Nii_Output_Path filesep 'AllScanningParameters_' num2str(AtlasResultsDir_Num) '.xls'], 'dir')
%                 AtlasResultsDir = [Nii_Output_Path filesep 'AllAtlasResults_' num2str(AtlasResultsDir_Num)];
%                 break;
%             end
%         end
%     else
    AtlasResultsDir = [Nii_Output_Path filesep 'AllAtlasResults'];
%     end
    
    Job_Name48 = 'ExportAtlasResults_FA_ToExcel';
    pipeline.(Job_Name48).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasFAJobName = [ 'atlas_FA_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name48).files_in.files{i * 2 - 1} = pipeline.(AtlasFAJobName).files_out.files{1};
        pipeline.(Job_Name48).files_in.files{i * 2} = pipeline.(AtlasFAJobName).files_out.files{2};
    end
    pipeline.(Job_Name48).files_out.files{1} = [AtlasResultsDir filesep 'WMlabelResults_FA.xls'];
    pipeline.(Job_Name48).files_out.files{2} = [AtlasResultsDir filesep 'WMtractResults_FA.xls'];
    pipeline.(Job_Name48).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name48).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name48).opt.ResultantFolder = AtlasResultsDir;
    pipeline.(Job_Name48).opt.Type = 'FA';

    Job_Name49 = 'ExportAtlasResults_MD_ToExcel';
    pipeline.(Job_Name49).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasMDJobName = [ 'atlas_MD_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name49).files_in.files{i * 2 - 1} = pipeline.(AtlasMDJobName).files_out.files{1};
        pipeline.(Job_Name49).files_in.files{i * 2} = pipeline.(AtlasMDJobName).files_out.files{2};
    end
    pipeline.(Job_Name49).files_out.files{1} = [AtlasResultsDir filesep 'WMlabelResults_MD.xls'];
    pipeline.(Job_Name49).files_out.files{2} = [AtlasResultsDir filesep 'WMtractResults_MD.xls'];
    pipeline.(Job_Name49).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name49).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name49).opt.ResultantFolder = AtlasResultsDir;
    pipeline.(Job_Name49).opt.Type = 'MD';

    Job_Name50 = 'ExportAtlasResults_L1_ToExcel';
    pipeline.(Job_Name50).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasL1JobName = [ 'atlas_L1_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name50).files_in.files{i * 2 - 1} = pipeline.(AtlasL1JobName).files_out.files{1};
        pipeline.(Job_Name50).files_in.files{i * 2} = pipeline.(AtlasL1JobName).files_out.files{2};
    end
    pipeline.(Job_Name50).files_out.files{1} = [AtlasResultsDir filesep 'WMlabelResults_L1.xls'];
    pipeline.(Job_Name50).files_out.files{2} = [AtlasResultsDir filesep 'WMtractResults_L1.xls'];
    pipeline.(Job_Name50).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name50).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name50).opt.ResultantFolder = AtlasResultsDir;
    pipeline.(Job_Name50).opt.Type = 'L1';

    Job_Name51 = 'ExportAtlasResults_L23m_ToExcel';
    pipeline.(Job_Name51).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasL23mJobName = [ 'atlas_L23m_1mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name51).files_in.files{i * 2 - 1} = pipeline.(AtlasL23mJobName).files_out.files{1};
        pipeline.(Job_Name51).files_in.files{i * 2} = pipeline.(AtlasL23mJobName).files_out.files{2};
    end
    pipeline.(Job_Name51).files_out.files{1} = [AtlasResultsDir filesep 'WMlabelResults_L23m.xls'];
    pipeline.(Job_Name51).files_out.files{2} = [AtlasResultsDir filesep 'WMtractResults_L23m.xls'];
    pipeline.(Job_Name51).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name51).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name51).opt.ResultantFolder = AtlasResultsDir;
    pipeline.(Job_Name51).opt.Type = 'L23m';
    
    if dti_opt.LDH_Flag
        Job_Name58 = 'ExportAtlasResults_LDHs_ToExcel';
        pipeline.(Job_Name58).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
        for i = 1:length(Data_Raw_Path_Cell)
            Number_Of_Subject = index_vector(i);
            Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            AtlasLDHsJobName = [ 'atlas_LDHs_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name58).files_in.files{i * 2 - 1} = pipeline.(AtlasLDHsJobName).files_out.files{1};
            pipeline.(Job_Name58).files_in.files{i * 2} = pipeline.(AtlasLDHsJobName).files_out.files{2};
        end
        pipeline.(Job_Name58).files_out.files{1} = [AtlasResultsDir filesep 'WMlabelResults_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs.xls'];
        pipeline.(Job_Name58).files_out.files{2} = [AtlasResultsDir filesep 'WMtractResults_' num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs.xls'];
        pipeline.(Job_Name58).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
        pipeline.(Job_Name58).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
        pipeline.(Job_Name58).opt.ResultantFolder = AtlasResultsDir;
        pipeline.(Job_Name58).opt.Type = [num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs'];

        Job_Name59 = 'ExportAtlasResults_LDHk_ToExcel';
        pipeline.(Job_Name59).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
        for i = 1:length(Data_Raw_Path_Cell)
            Number_Of_Subject = index_vector(i);
            Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            AtlasLDHkJobName = [ 'atlas_LDHk_1mm_',Number_Of_Subject_String ];
            pipeline.(Job_Name59).files_in.files{i * 2 - 1} = pipeline.(AtlasLDHkJobName).files_out.files{1};
            pipeline.(Job_Name59).files_in.files{i * 2} = pipeline.(AtlasLDHkJobName).files_out.files{2};
        end
        pipeline.(Job_Name59).files_out.files{1} = [AtlasResultsDir filesep 'WMlabelResults_' num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk.xls'];
        pipeline.(Job_Name59).files_out.files{2} = [AtlasResultsDir filesep 'WMtractResults_' num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk.xls'];
        pipeline.(Job_Name59).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
        pipeline.(Job_Name59).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
        pipeline.(Job_Name59).opt.ResultantFolder = AtlasResultsDir;
        pipeline.(Job_Name59).opt.Type = [num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk'];
    end
    
end

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
    
    if dti_opt.LDH_Flag
        Job_Name56 = 'MergeSkeleton_LDHs';
        pipeline.(Job_Name56).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
        for i = 1:length(Data_Raw_Path_Cell)
            Number_Of_Subject = index_vector(i);
            Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            SkeletonLDHsJobName = [ 'skeleton_LDHs_' Number_Of_Subject_String ];
            pipeline.(Job_Name56).files_in.files{i} = pipeline.(SkeletonLDHsJobName).files_out.files{1};
        end
        pipeline.(Job_Name56).files_out.files{1}   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_' ...
            num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs.nii.gz'];
        pipeline.(Job_Name56).opt.SubjectIDs   = index_vector;
        pipeline.(Job_Name56).opt.ResultantFile   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_' ...
            num2str(dti_opt.LDH_Neighborhood - 1, '%02d') 'LDHs.nii.gz'];

        Job_Name57 = 'MergeSkeleton_LDHk';
        pipeline.(Job_Name57).command           = 'g_MergeSkeleton( files_in.files, opt.SubjectIDs, opt.ResultantFile )';
        for i = 1:length(Data_Raw_Path_Cell)
            Number_Of_Subject = index_vector(i);
            Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            SkeletonLDHkJobName = [ 'skeleton_LDHk_' Number_Of_Subject_String ];
            pipeline.(Job_Name57).files_in.files{i} = pipeline.(SkeletonLDHkJobName).files_out.files{1};
        end
        pipeline.(Job_Name57).files_out.files{1}   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_' ...
           num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk.nii.gz'];
        pipeline.(Job_Name57).opt.SubjectIDs   = index_vector;
        pipeline.(Job_Name57).opt.ResultantFile   = [Nii_Output_Path filesep 'TBSS' filesep 'Merged4DSkeleton' filesep 'AllSkeleton_' ...
           num2str(dti_opt.LDH_Neighborhood, '%02d') 'LDHk.nii.gz'];
    end
   
    % Export atlas results for WM skeleton
    TBSS_AtlasResultsDir = [Nii_Output_Path filesep 'TBSS' filesep 'AllAtlasResults'];
    
    Job_Name118 = 'ExportAtlasResults_FASkeleton_ToExcel';
    pipeline.(Job_Name118).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasFASkeletonJobName = [ 'skeleton_atlas_FA_',Number_Of_Subject_String ];
        pipeline.(Job_Name118).files_in.files{i * 2 - 1} = pipeline.(AtlasFASkeletonJobName).files_out.files{1};
        pipeline.(Job_Name118).files_in.files{i * 2} = pipeline.(AtlasFASkeletonJobName).files_out.files{2};
    end
    pipeline.(Job_Name118).files_out.files{1} = [TBSS_AtlasResultsDir filesep 'WMlabelResults_FA.xls'];
    pipeline.(Job_Name118).files_out.files{2} = [TBSS_AtlasResultsDir filesep 'WMtractResults_FA.xls'];
    pipeline.(Job_Name118).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name118).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name118).opt.ResultantFolder = TBSS_AtlasResultsDir;
    pipeline.(Job_Name118).opt.Type = 'FA';
    
    Job_Name119 = 'ExportAtlasResults_MDSkeleton_ToExcel';
    pipeline.(Job_Name119).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasMDSkeletonJobName = [ 'skeleton_atlas_MD_',Number_Of_Subject_String ];
        pipeline.(Job_Name119).files_in.files{i * 2 - 1} = pipeline.(AtlasMDSkeletonJobName).files_out.files{1};
        pipeline.(Job_Name119).files_in.files{i * 2} = pipeline.(AtlasMDSkeletonJobName).files_out.files{2};
    end
    pipeline.(Job_Name119).files_out.files{1} = [TBSS_AtlasResultsDir filesep 'WMlabelResults_MD.xls'];
    pipeline.(Job_Name119).files_out.files{2} = [TBSS_AtlasResultsDir filesep 'WMtractResults_MD.xls'];
    pipeline.(Job_Name119).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name119).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name119).opt.ResultantFolder = TBSS_AtlasResultsDir;
    pipeline.(Job_Name119).opt.Type = 'MD';
    
    Job_Name120 = 'ExportAtlasResults_L1Skeleton_ToExcel';
    pipeline.(Job_Name120).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasL1SkeletonJobName = [ 'skeleton_atlas_L1_',Number_Of_Subject_String ];
        pipeline.(Job_Name120).files_in.files{i * 2 - 1} = pipeline.(AtlasL1SkeletonJobName).files_out.files{1};
        pipeline.(Job_Name120).files_in.files{i * 2} = pipeline.(AtlasL1SkeletonJobName).files_out.files{2};
    end
    pipeline.(Job_Name120).files_out.files{1} = [TBSS_AtlasResultsDir filesep 'WMlabelResults_L1.xls'];
    pipeline.(Job_Name120).files_out.files{2} = [TBSS_AtlasResultsDir filesep 'WMtractResults_L1.xls'];
    pipeline.(Job_Name120).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name120).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name120).opt.ResultantFolder = TBSS_AtlasResultsDir;
    pipeline.(Job_Name120).opt.Type = 'L1';
    
    Job_Name121 = 'ExportAtlasResults_L23mSkeleton_ToExcel';
    pipeline.(Job_Name121).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
    for i = 1:length(Data_Raw_Path_Cell)
        Number_Of_Subject = index_vector(i);
        Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
        AtlasL23mSkeletonJobName = [ 'skeleton_atlas_L23m_',Number_Of_Subject_String ];
        pipeline.(Job_Name121).files_in.files{i * 2 - 1} = pipeline.(AtlasL23mSkeletonJobName).files_out.files{1};
        pipeline.(Job_Name121).files_in.files{i * 2} = pipeline.(AtlasL23mSkeletonJobName).files_out.files{2};
    end
    pipeline.(Job_Name121).files_out.files{1} = [TBSS_AtlasResultsDir filesep 'WMlabelResults_L23m.xls'];
    pipeline.(Job_Name121).files_out.files{2} = [TBSS_AtlasResultsDir filesep 'WMtractResults_L23m.xls'];
    pipeline.(Job_Name121).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name121).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name121).opt.ResultantFolder = TBSS_AtlasResultsDir;
    pipeline.(Job_Name121).opt.Type = 'L23m';
    
    if dti_opt.LDH_Flag
        Job_Name122 = 'ExportAtlasResults_LDHsSkeleton_ToExcel';
        pipeline.(Job_Name122).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
        for i = 1:length(Data_Raw_Path_Cell)
            Number_Of_Subject = index_vector(i);
            Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            AtlasLDHsSkeletonJobName = [ 'skeleton_atlas_LDHs_',Number_Of_Subject_String ];
            pipeline.(Job_Name122).files_in.files{i * 2 - 1} = pipeline.(AtlasLDHsSkeletonJobName).files_out.files{1};
            pipeline.(Job_Name122).files_in.files{i * 2} = pipeline.(AtlasLDHsSkeletonJobName).files_out.files{2};
        end
        pipeline.(Job_Name122).files_out.files{1} = [TBSS_AtlasResultsDir filesep 'WMlabelResults_LDHs.xls'];
        pipeline.(Job_Name122).files_out.files{2} = [TBSS_AtlasResultsDir filesep 'WMtractResults_LDHs.xls'];
        pipeline.(Job_Name122).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
        pipeline.(Job_Name122).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
        pipeline.(Job_Name122).opt.ResultantFolder = TBSS_AtlasResultsDir;
        pipeline.(Job_Name122).opt.Type = 'LDHs';

        Job_Name123 = 'ExportAtlasResults_LDHkSkeleton_ToExcel';
        pipeline.(Job_Name123).command        = 'g_ExportAtlasResultsToExcel( files_in.files, opt.WMlabeImagePath, opt.WMtractImagePath, opt.ResultantFolder, opt.Type )';
        for i = 1:length(Data_Raw_Path_Cell)
            Number_Of_Subject = index_vector(i);
            Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
            AtlasLDHkSkeletonJobName = [ 'skeleton_atlas_LDHk_',Number_Of_Subject_String ];
            pipeline.(Job_Name123).files_in.files{i * 2 - 1} = pipeline.(AtlasLDHkSkeletonJobName).files_out.files{1};
            pipeline.(Job_Name123).files_in.files{i * 2} = pipeline.(AtlasLDHkSkeletonJobName).files_out.files{2};
        end
        pipeline.(Job_Name123).files_out.files{1} = [TBSS_AtlasResultsDir filesep 'WMlabelResults_LDHk.xls'];
        pipeline.(Job_Name123).files_out.files{2} = [TBSS_AtlasResultsDir filesep 'WMtractResults_LDHk.xls'];
        pipeline.(Job_Name123).opt.WMlabeImagePath = dti_opt.WM_Label_Atlas;
        pipeline.(Job_Name123).opt.WMtractImagePath = dti_opt.WM_Probtract_Atlas;
        pipeline.(Job_Name123).opt.ResultantFolder = TBSS_AtlasResultsDir;
        pipeline.(Job_Name123).opt.Type = 'LDHk';
    end
end

% Excute the pipeline
% psom_visu_dependencies(pipeline);
% pipeline
psom_run_pipeline(pipeline,pipeline_opt);

catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' Nii_Output_Path filesep 'logs' filesep 'dti_pipeline.error']);
end









