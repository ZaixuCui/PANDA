
function pipeline = g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt,dti_opt,tracking_opt,T1orPartitionOfSubjects_PathCell )
%
%__________________________________________________________________________
% SUMMARY OF G_DTI_PIPELINE
% 
% The whole process of DTI data processing for any number of subjects.
%
% SYNTAX:
% G_DTI_PIPELINE( DATA_RAW_PATH_CELL,INDEX_VECTOR,NII_OUTPUT_PATH,FA_PREFIX,PIPELINE_OPT,DTI_OPT )
%__________________________________________________________________________
% INPUTS:
%
% DATA_RAW_PATH_CELL
%        (cell of strings) the input folder cell, each of which includes
%        the dcm data for a single acquisition.
%        For example: 'Data_Raw_Path_Cell{1} = '/data/Raw_Data/DTI_test1/'
%        There are 2 possibilities under each cell:
%        (1) all dicom files ( single sequence or multiple sequence )
%        (2) multiple/single subdirectorys, each of which contains dicoms
%        for each sequence( multiple/repetitive sequence )
%
% INDEX_VECTOR
%        (cell of integers) the order of the subjects.
%        For example: index_vector = [1:5] 
%                     The resultant nii folder for each subject is like 
%                     '/data/Handled_Data/001/'
%
% NII_OUTPUT_PATH
%        (string) the path of output folder of nii data for all subjects
%        For example: '/data/Handled_Data/'
%
% FA_PREFIX
%        (string) basename for the output file of the dtifit
%
% PIPELINE_OPT
%        (struct)
%        opt of the psom pipeline 
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
%        1) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix )
%        2) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt )
%        3) g_dti_pipeline( Data_Raw_Path_Cell,index_vector,Nii_Output_Path,FA_Prefix,pipeline_opt,dti_opt )
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
% Neuroscience and Learning, Beijing Normal University, 2011.
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
    pipeline_opt.qsub_options = '-q all.q';
    pipeline_opt.mode_pipeline_manager = 'batch';
    pipeline_opt.max_queued = 100;
    pipeline_opt.flag_verbose = 1;
    pipeline_opt.flag_pause = 1;
    pipeline_opt.flag_update = 1;
    pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
elseif nargin >= 5
    if ~isfield(pipeline_opt,'flag_verbose')
        pipeline_opt.flag_verbose = 1;
    end
    if ~isfield(pipeline_opt,'flag_pause')
        pipeline_opt.flag_pause = 1;
    end
    if ~isfield(pipeline_opt,'flag_update')
        pipeline_opt.flag_update = 1;
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
        pipeline_opt.path_logs = [Nii_Output_Path '/logs/'];
    end
end
    
if nargin <= 5
    % The default value of opt will be used
    dti_opt = g_dti_opt();
else
    % The value user specified will be used, and those not be specified
    % will be default
    dti_opt_new = g_dti_opt(dti_opt);
    dti_opt = dti_opt_new;
end

if length(Data_Raw_Path_Cell) ~= length(index_vector)
    error('not match!');
end

% Handle the data one subject after one and make them a big pipeline  
for i = 1:length(Data_Raw_Path_Cell)
    
    Number_Of_Subject = index_vector(i);
    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
    if ~strcmp( Data_Raw_Path_Cell{i}(end),'/' )
        Data_Raw_Path_Cell{i} = [Data_Raw_Path_Cell{i},'/'];
    end
    
    % Calculate the quantity of the sequences
    Quantity_Of_Sequence = g_Calculate_Sequence( Data_Raw_Path_Cell{i},i );

    % Basename for the output file of the dtifit
    if isempty(FA_Prefix) 
        dtifit_Prefix = Number_Of_Subject_String;
    else
        dtifit_Prefix = [FA_Prefix '_' Number_Of_Subject_String];
    end

    if ~strcmp( Nii_Output_Path(end),'/' )
        Nii_Output_Path = [Nii_Output_Path,'/'];
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
    pipeline.(Job_Name1).command             =  'g_dcm2nii_dwi( opt.Data_Raw_Folder_Path,opt.Nii_Output_Folder_Path,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name1).files_in            =  {};
       % if the files specified in the files_out.files are successfully
       % produced, the job is successfull
    pipeline.(Job_Name1).files_out.files     =  g_dcm2nii_dwi_FileOut( Job_Name1,Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dtifit_Prefix );
       % option of the job, will be used as parameters of g_dcm2nii_dwi
    pipeline.(Job_Name1).opt.Data_Raw_Folder_Path    =  Data_Raw_Path_Cell{i};
    pipeline.(Job_Name1).opt.Nii_Output_Folder_Path    =  [Nii_Output_Path filesep Number_Of_Subject_String filesep];
    pipeline.(Job_Name1).opt.Prefix          = dtifit_Prefix;
    pipeline.(Job_Name1).opt.JobName    =  Job_Name1;
    
    % extractB0 job
    Job_Name2 = [ 'extractB0_',Number_Of_Subject_String ];
    pipeline.(Job_Name2).command             = 'g_extractB0 ( opt.DWI_File,0,opt.JobName )';
    pipeline.(Job_Name2).files_in.files      = pipeline.(Job_Name1).files_out.files;
    pipeline.(Job_Name2).files_out.files     = g_extractB0_FileOut( Job_Name2,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name2).opt.DWI_File        = pipeline.(Job_Name1).files_out.files{3};
    pipeline.(Job_Name2).opt.JobName    =  Job_Name2;

    % BET job 
    Job_Name3 = [ 'BET_1_',Number_Of_Subject_String ];
    pipeline.(Job_Name3).command                 = 'g_BET( opt.BET_File,opt.f,opt.JobName )';
    pipeline.(Job_Name3).files_in.files          = pipeline.(Job_Name2).files_out.files;
    pipeline.(Job_Name3).files_out.files         = g_BET_1_FileOut( Job_Name3,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name3).opt.BET_File            = pipeline.(Job_Name2).files_out.files{1};
    pipeline.(Job_Name3).opt.f                   = dti_opt.BET_1_f;
    pipeline.(Job_Name3).opt.JobName    =  Job_Name3;
    
    % NIIcrop job
    Job_Name4 = [ 'NIIcrop_',Number_Of_Subject_String ];
    pipeline.(Job_Name4).command             = 'g_NIIcrop( opt.DWI_File,opt.MaskFileName,opt.slice_gap,opt.JobName )';
    pipeline.(Job_Name4).files_in.files      = pipeline.(Job_Name3).files_out.files;
    pipeline.(Job_Name4).files_out.files     = g_NIIcrop_FileOut( Job_Name4,Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dti_opt.NIIcrop_suffix_flag,dtifit_Prefix );
    pipeline.(Job_Name4).files_out.variables = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'NIIcrop_output.mat']};
    pipeline.(Job_Name4).opt.DWI_File        = pipeline.(Job_Name1).files_out.files;
    pipeline.(Job_Name4).opt.MaskFileName    = pipeline.(Job_Name3).files_out.files{2};
    pipeline.(Job_Name4).opt.slice_gap       = dti_opt.NIIcrop_slice_gap;
    pipeline.(Job_Name4).opt.JobName    =  Job_Name4;
    
    % EDDYCURRENT job
    Job_Name5 = [ 'EDDYCURRENT_',Number_Of_Subject_String ];
    pipeline.(Job_Name5).command                = 'g_EDDYCURRENT( opt.B0_File,files_in.variables{1},opt.QuantityOfSequence,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name5).files_in.files         = pipeline.(Job_Name4).files_out.files;
    pipeline.(Job_Name5).files_in.variables     = pipeline.(Job_Name4).files_out.variables;
    pipeline.(Job_Name5).files_out.files        = g_EDDYCURRENT_FileOut( Job_Name5,Nii_Output_Path,Number_Of_Subject_String,Quantity_Of_Sequence,dtifit_Prefix );
    pipeline.(Job_Name5).files_out.variables    = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'EDDYCURRENT_output.mat']};
    pipeline.(Job_Name5).opt.B0_File            = pipeline.(Job_Name4).files_out.files{1};
    pipeline.(Job_Name5).opt.QuantityOfSequence = Quantity_Of_Sequence;
    pipeline.(Job_Name5).opt.Prefix             = dtifit_Prefix;
    pipeline.(Job_Name5).opt.JobName    =  Job_Name5;

    % average job
    Job_Name6 = [ 'average_',Number_Of_Subject_String ];
    pipeline.(Job_Name6).command                     = 'g_average( files_in.variables{1},opt.QuantityOfSequence,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name6).files_in.files              = pipeline.(Job_Name5).files_out.files;
    pipeline.(Job_Name6).files_in.variables          = pipeline.(Job_Name5).files_out.variables;
    pipeline.(Job_Name6).files_out.files             = g_average_FileOut( Job_Name6,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name6).files_out.variables         = {[Nii_Output_Path Number_Of_Subject_String filesep 'tmp' filesep 'average_output.mat']};
    pipeline.(Job_Name6).opt.DataNii_folder          = [Nii_Output_Path Number_Of_Subject_String '/'];     
    pipeline.(Job_Name6).opt.QuantityOfSequence      = Quantity_Of_Sequence;
    pipeline.(Job_Name6).opt.Prefix                  = dtifit_Prefix;
    pipeline.(Job_Name6).opt.JobName    =  Job_Name6;
    
    % BET_2 job
    Job_Name7 = [ 'BET_2_',Number_Of_Subject_String ];
    pipeline.(Job_Name7).command               = 'g_BET( opt.BET_File,opt.f,opt.JobName )';
    pipeline.(Job_Name7).files_in.files        = pipeline.(Job_Name6).files_out.files;
    pipeline.(Job_Name7).files_out.files       = g_BET_2_FileOut( Job_Name7,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name7).opt.BET_File          = pipeline.(Job_Name6).files_out.files{4};  % b0 file
    pipeline.(Job_Name7).opt.f                 = dti_opt.BET_2_f;
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

    % dtifit job
    Job_Name9 = [ 'dtifit_',Number_Of_Subject_String ];
    pipeline.(Job_Name9).command             = 'g_dtifit( opt.fdt_dir,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name9).files_in.files      = pipeline.(Job_Name8).files_out.files;
    pipeline.(Job_Name9).files_out.files     = g_dtifit_FileOut( Job_Name9,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name9).opt.fdt_dir         = [Nii_Output_Path Number_Of_Subject_String '/'];
    pipeline.(Job_Name9).opt.Prefix          = dtifit_Prefix;
    pipeline.(Job_Name9).opt.JobName    =  Job_Name9;

    % FA_BeforeNormalize job
    Job_Name10 = [ 'FA_BeforeNormalize_',Number_Of_Subject_String ];
    pipeline.(Job_Name10).command                = 'g_BeforeNormalize( opt.FA_file,opt.JobName )';
    pipeline.(Job_Name10).files_in.files         = pipeline.(Job_Name9).files_out.files;
    pipeline.(Job_Name10).files_out.files        = g_FA_BeforeNormalize_FileOut( Job_Name10,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name10).opt.FA_file            = pipeline.(Job_Name9).files_out.files{1};
    pipeline.(Job_Name10).opt.JobName    =  Job_Name10;
    
    % MD_BeforeNormalize job
    Job_Name11 = [ 'MD_BeforeNormalize_',Number_Of_Subject_String ];
    pipeline.(Job_Name11).command                = 'g_BeforeNormalize( opt.MD_file,opt.JobName )';
    pipeline.(Job_Name11).files_in.files         = pipeline.(Job_Name9).files_out.files;
    pipeline.(Job_Name11).files_out.files        = g_MD_BeforeNormalize_FileOut( Job_Name11,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name11).opt.MD_file            = pipeline.(Job_Name9).files_out.files{6};
    pipeline.(Job_Name11).opt.JobName    =  Job_Name11;
    
    % L1_BeforeNormalize job
    Job_Name12 = [ 'L1_BeforeNormalize_',Number_Of_Subject_String ];
    pipeline.(Job_Name12).command                = 'g_BeforeNormalize( opt.L1_file,opt.JobName )';
    pipeline.(Job_Name12).files_in.files         = pipeline.(Job_Name9).files_out.files;
    pipeline.(Job_Name12).files_out.files        = g_L1_BeforeNormalize_FileOut( Job_Name12,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name12).opt.L1_file            = pipeline.(Job_Name9).files_out.files{2};
    pipeline.(Job_Name12).opt.JobName    =  Job_Name12;
    
    % L23m_BeforeNormalize job
    Job_Name13 = [ 'L23m_BeforeNormalize_',Number_Of_Subject_String ];
    pipeline.(Job_Name13).command                = 'g_BeforeNormalize( opt.L23m_file,opt.JobName )';
    pipeline.(Job_Name13).files_in.files         = pipeline.(Job_Name9).files_out.files;
    pipeline.(Job_Name13).files_out.files        = g_L23m_BeforeNormalize_FileOut( Job_Name13,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name13).opt.L23m_file            = pipeline.(Job_Name9).files_out.files{5};
    pipeline.(Job_Name13).opt.JobName    =  Job_Name13;

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
    pipeline.(Job_Name16).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
    pipeline.(Job_Name16).opt.ref_fileName    = dti_opt.applywarp_1_ref_fileName;
    pipeline.(Job_Name16).opt.JobName    =  Job_Name16;
    pipeline.(Job_Name16).opt.target_fileName = dti_opt.FAnormalize_target;

    % applywarp_2 job
    if dti_opt.applywarp_2_ref_fileName ~= 1
        Job_Name17 = [ 'applywarp_FA_',num2str(dti_opt.applywarp_2_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name17).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name17).files_in.files    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name17).files_out.files     = g_applywarp_2_FileOut( Job_Name17,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_2_ref_fileName );
        pipeline.(Job_Name17).opt.raw_file        = pipeline.(Job_Name10).files_out.files{1};
        pipeline.(Job_Name17).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
        pipeline.(Job_Name17).opt.ref_fileName    = dti_opt.applywarp_2_ref_fileName;
        pipeline.(Job_Name17).opt.JobName    =  Job_Name17;
    end

    % applywarp_3 job
    Job_Name18 = [ 'applywarp_MD_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name18).command            = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
    pipeline.(Job_Name18).files_in.files1     = pipeline.(Job_Name11).files_out.files;
    pipeline.(Job_Name18).files_in.files2     = pipeline.(Job_Name15).files_out.files;
    pipeline.(Job_Name18).files_out.files    = g_applywarp_3_FileOut( Job_Name18,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name18).opt.raw_file        = pipeline.(Job_Name11).files_out.files{1};
    pipeline.(Job_Name18).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
    pipeline.(Job_Name18).opt.ref_fileName    = dti_opt.applywarp_3_ref_fileName;
    pipeline.(Job_Name18).opt.JobName    =  Job_Name18;

    % applywarp_4 job
    if dti_opt.applywarp_4_ref_fileName ~= 1
        Job_Name19 = [ 'applywarp_MD_',num2str(dti_opt.applywarp_4_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name19).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name19).files_in.files1    = pipeline.(Job_Name11).files_out.files;
        pipeline.(Job_Name19).files_in.files2    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name19).files_out.files    = g_applywarp_4_FileOut( Job_Name19,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_4_ref_fileName );
        pipeline.(Job_Name19).opt.raw_file        = pipeline.(Job_Name11).files_out.files{1};
        pipeline.(Job_Name19).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
        pipeline.(Job_Name19).opt.ref_fileName    = dti_opt.applywarp_4_ref_fileName;
        pipeline.(Job_Name19).opt.JobName    =  Job_Name19;
    end

    % applywarp_5 job
    Job_Name20 = [ 'applywarp_L1_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name20).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
    pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name12).files_out.files;
    pipeline.(Job_Name20).files_in.files2    = pipeline.(Job_Name15).files_out.files;
    pipeline.(Job_Name20).files_out.files     = g_applywarp_5_FileOut( Job_Name20,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name20).opt.raw_file        = pipeline.(Job_Name12).files_out.files{1};
    pipeline.(Job_Name20).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
    pipeline.(Job_Name20).opt.ref_fileName    = dti_opt.applywarp_5_ref_fileName;      
    pipeline.(Job_Name20).opt.JobName    =  Job_Name20;
 
    % applywarp_6 job
    if dti_opt.applywarp_6_ref_fileName ~= 1
        Job_Name21 = [ 'applywarp_L1_',num2str(dti_opt.applywarp_6_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name21).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name12).files_out.files;
        pipeline.(Job_Name21).files_in.files2    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name21).files_out.files   = g_applywarp_6_FileOut( Job_Name21,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_6_ref_fileName );
        pipeline.(Job_Name21).opt.raw_file        = pipeline.(Job_Name12).files_out.files{1};
        pipeline.(Job_Name21).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
        pipeline.(Job_Name21).opt.ref_fileName    = dti_opt.applywarp_6_ref_fileName;
        pipeline.(Job_Name21).opt.JobName    =  Job_Name21; 
    end

    % applywarp_7 job
    Job_Name22 = [ 'applywarp_L23m_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name22).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
    pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name13).files_out.files;
    pipeline.(Job_Name22).files_in.files2    = pipeline.(Job_Name15).files_out.files;
    pipeline.(Job_Name22).files_out.files   = g_applywarp_7_FileOut( Job_Name22,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name22).opt.raw_file        = pipeline.(Job_Name13).files_out.files{1};
    pipeline.(Job_Name22).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
    pipeline.(Job_Name22).opt.ref_fileName    = dti_opt.applywarp_7_ref_fileName;
    pipeline.(Job_Name22).opt.JobName    =  Job_Name22;

    % applywarp_8 job
    if dti_opt.applywarp_8_ref_fileName ~= 1
        Job_Name23 = [ 'applywarp_L23m_',num2str(dti_opt.applywarp_8_ref_fileName),'mm_',Number_Of_Subject_String ];
        pipeline.(Job_Name23).command           = 'g_applywarp( opt.raw_file,opt.warp_file,opt.ref_fileName,opt.JobName )';
        pipeline.(Job_Name20).files_in.files1    = pipeline.(Job_Name13).files_out.files;
        pipeline.(Job_Name23).files_in.files2    = pipeline.(Job_Name15).files_out.files;
        pipeline.(Job_Name23).files_out.files   = g_applywarp_8_FileOut( Job_Name23,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.applywarp_8_ref_fileName );
        pipeline.(Job_Name23).opt.raw_file        = pipeline.(Job_Name13) .files_out.files{1};
        pipeline.(Job_Name23).opt.warp_file       = pipeline.(Job_Name15).files_out.files{4};
        pipeline.(Job_Name23).opt.ref_fileName    = dti_opt.applywarp_8_ref_fileName;
        pipeline.(Job_Name23).opt.JobName    =  Job_Name23;
    end

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
    if dti_opt.applywarp_6_ref_fileName ~= 1
        pipeline.(Job_Name27).files_in.files    = pipeline.(Job_Name23).files_out.files;
        pipeline.(Job_Name27).opt.fileName      = pipeline.(Job_Name23).files_out.files{1};
    else
        pipeline.(Job_Name27).files_in.files    = pipeline.(Job_Name22).files_out.files;
        pipeline.(Job_Name27).opt.fileName      = pipeline.(Job_Name22).files_out.files{1};
    end
    pipeline.(Job_Name27).files_out.files   = g_smoothNII_4_FileOut( Job_Name27,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix,dti_opt.smoothNII_2_kernel_size,dti_opt.applywarp_8_ref_fileName );
    pipeline.(Job_Name27).opt.kernel_size   = dti_opt.smoothNII_4_kernel_size;
    pipeline.(Job_Name27).opt.JobName    =  Job_Name27;

    % JHUatlas_1mm_1 job
    Job_Name28 = [ 'atlas_FA_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name28).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
    pipeline.(Job_Name28).files_in.files    = pipeline.(Job_Name16).files_out.files;
    pipeline.(Job_Name28).files_out.files   = g_JHUatlas_1mm_1_FileOut( Job_Name28,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name28).opt.Dmetric_fileName    = pipeline.(Job_Name16).files_out.files{1};
    pipeline.(Job_Name28).opt.WM_Label_Atlas = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name28).opt.WM_Probtract_Atlas = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name28).opt.JobName    =  Job_Name28;

    % JHUatlas_1mm_2 job
    Job_Name29 = [ 'atlas_MD_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name29).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
    pipeline.(Job_Name29).files_in.files    = pipeline.(Job_Name18).files_out.files;
    pipeline.(Job_Name29).files_out.files   = g_JHUatlas_1mm_2_FileOut( Job_Name29,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name29).opt.Dmetric_fileName    = pipeline.(Job_Name18).files_out.files{1};
    pipeline.(Job_Name29).opt.WM_Label_Atlas = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name29).opt.WM_Probtract_Atlas = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name29).opt.JobName    =  Job_Name29;

    % JHUatlas_1mm_3 job
    Job_Name30 = [ 'atlas_L1_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name30).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
    pipeline.(Job_Name30).files_in.files    = pipeline.(Job_Name20).files_out.files;
    pipeline.(Job_Name30).files_out.files   = g_JHUatlas_1mm_3_FileOut( Job_Name30,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name30).opt.Dmetric_fileName    = pipeline.(Job_Name20).files_out.files{1};
    pipeline.(Job_Name30).opt.WM_Label_Atlas = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name30).opt.WM_Probtract_Atlas = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name30).opt.JobName    =  Job_Name30;

    % JHUatlas_1mm_4 job
    Job_Name31 = [ 'atlas_L23m_1mm_',Number_Of_Subject_String ];
    pipeline.(Job_Name31).command           = 'g_JHUatlas_1mm( opt.Dmetric_fileName,opt.WM_Label_Atlas,opt.WM_Probtract_Atlas,opt.JobName )';
    pipeline.(Job_Name31).files_in.files    = pipeline.(Job_Name22).files_out.files;
    pipeline.(Job_Name31).files_out.files   = g_JHUatlas_1mm_4_FileOut( Job_Name31,Nii_Output_Path,Number_Of_Subject_String,dtifit_Prefix );
    pipeline.(Job_Name31).opt.Dmetric_fileName    = pipeline.(Job_Name22).files_out.files{1};
    pipeline.(Job_Name31).opt.WM_Label_Atlas = dti_opt.WM_Label_Atlas;
    pipeline.(Job_Name31).opt.WM_Probtract_Atlas = dti_opt.WM_Probtract_Atlas;
    pipeline.(Job_Name31).opt.JobName    =  Job_Name31;
    
    % delete tmporary file
    Job_Name32 = [ 'delete_tmp_file_',Number_Of_Subject_String ];
    pipeline.(Job_Name32).command           = 'g_delete_tmp_file( opt.Nii_Output_Folder_Path,opt.Delete_Flag,opt.QuantityOfSequence,opt.Prefix,opt.JobName )';
    pipeline.(Job_Name32).files_in.files{1} = pipeline.(Job_Name24).files_out.files{2};
    pipeline.(Job_Name32).files_in.files{2} = pipeline.(Job_Name25).files_out.files{2};
    pipeline.(Job_Name32).files_in.files{3} = pipeline.(Job_Name26).files_out.files{2};
    pipeline.(Job_Name32).files_in.files{4} = pipeline.(Job_Name27).files_out.files{2};
    pipeline.(Job_Name32).files_in.files{5} = pipeline.(Job_Name28).files_out.files{3};
    pipeline.(Job_Name32).files_in.files{6} = pipeline.(Job_Name29).files_out.files{3};
    pipeline.(Job_Name32).files_in.files{7} = pipeline.(Job_Name30).files_out.files{3};
    pipeline.(Job_Name32).files_in.files{8} = pipeline.(Job_Name31).files_out.files{3};
    pipeline.(Job_Name32).files_out.files   = g_delete_tmp_file_FileOut( Job_Name32,Nii_Output_Path,Number_Of_Subject_String );
    pipeline.(Job_Name32).opt.Nii_Output_Folder_Path    = [Nii_Output_Path filesep Number_Of_Subject_String '/'];
    pipeline.(Job_Name32).opt.Delete_Flag               = dti_opt.Delete_Flag;
    pipeline.(Job_Name32).opt.QuantityOfSequence        = Quantity_Of_Sequence;
    pipeline.(Job_Name32).opt.Prefix                     = dtifit_Prefix;
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
    Number_Of_Subject = index_vector(i);
    Number_Of_Subject_String = num2str(Number_Of_Subject,'%05.0f');
    
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
    end

    if tracking_opt.DterminFiberTracking == 1
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

        Job_Name38 = [ 'DeterministicTracking_',Number_Of_Subject_String ];
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
    end
        
    % Network Node Definition
    if tracking_opt.NetworkNode == 1 && ~tracking_opt.PartitionOfSubjects 
        Job_Name39 = [ 'PartitionTemplate2FA_',Number_Of_Subject_String ];
        pipeline.(Job_Name39).command           = 'g_PartitionTemplate2FA( opt.FA_Path,opt.T1_Path,opt.PartitionTemplate,opt.JobName )';
        dtifit_Name = [ 'dtifit_' Number_Of_Subject_String ];
        pipeline.(Job_Name39).files_in.files   = pipeline.(dtifit_Name).files_out;
        FAPath = pipeline.(dtifit_Name).files_out.files{1};
        pipeline.(Job_Name39).files_out.files   = g_PartitionTemplate2FA_FileOut( Job_Name39,FAPath,tracking_opt.PartitionTemplate );
        pipeline.(Job_Name39).opt.FA_Path       = FAPath;
        pipeline.(Job_Name39).opt.T1_Path       = T1orPartitionOfSubjects_PathCell{i};
        pipeline.(Job_Name39).opt.PartitionTemplate   = tracking_opt.PartitionTemplate;
        pipeline.(Job_Name39).opt.JobName    =  Job_Name39;
    end
        
    % Deterministic Network
    if tracking_opt.DeterministicNetwork == 1
        Job_Name40 = [ 'FiberNumMatrix_',Number_Of_Subject_String ];
        pipeline.(Job_Name40).command           = 'g_FiberNumMatrix( opt.trackfilepath,opt.T1toFA_PartitionTemplate,opt.FAfilepath,opt.JobName )';
        if ~tracking_opt.PartitionOfSubjects 
            PartitionTemplate2FA_Name = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
            pipeline.(Job_Name40).files_in.files1   = pipeline.(PartitionTemplate2FA_Name).files_out;
        end
        tracking_Name = [ 'DeterministicTracking_' Number_Of_Subject_String ];
        pipeline.(Job_Name40).files_in.files2   = pipeline.(tracking_Name).files_out;
        if tracking_opt.PartitionOfSubjects
            pipeline.(Job_Name40).files_out.files   = g_FiberNumMatrix_FileOut( Job_Name40,Nii_Output_Path,Number_Of_Subject_String,tracking_opt,T1orPartitionOfSubjects_PathCell{i},dtifit_Prefix );
        else
            pipeline.(Job_Name40).files_out.files   = g_FiberNumMatrix_FileOut( Job_Name40,Nii_Output_Path,Number_Of_Subject_String,tracking_opt,tracking_opt.PartitionTemplate,dtifit_Prefix );
        end
        pipeline.(Job_Name40).opt.trackfilepath = pipeline.(tracking_Name).files_out.files{16};
        if tracking_opt.PartitionOfSubjects 
            pipeline.(Job_Name40).opt.T1toFA_PartitionTemplate = T1orPartitionOfSubjects_PathCell{i};
        else
            pipeline.(Job_Name40).opt.T1toFA_PartitionTemplate = pipeline.(PartitionTemplate2FA_Name).files_out.files{1};
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
        for j = 1:10
            Job_Name = [ 'BedpostX_' Number_Of_Subject_String '_' num2str(j, '%02.0f') ];
            pipeline.(Job_Name43).files_in.files{j} = pipeline.(Job_Name).files_out.files{1};
        end
        pipeline.(Job_Name43).files_out.files = g_bedpostX_postproc_FileOut( BedpostxFolder );
        pipeline.(Job_Name43).opt.BedpostxFolder = BedpostxFolder;
        pipeline.(Job_Name43).opt.Fibers = tracking_opt.Fibers;
    end
    
    % Probabilistic Network
    if tracking_opt.BedpostxProbabilisticNetwork
        ResultantFolder = [Nii_Output_Path filesep Number_Of_Subject_String filesep 'Network' filesep 'Probabilistic']; 
        Job_Name44 = [ 'ProbabilisticNetworkpre_',Number_Of_Subject_String ];
        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
            pipeline.(Job_Name44).command        = 'g_OPDtrackNETpre( opt.LabelFile, opt.LabelVector, opt.ResultantFolder )';
        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
            pipeline.(Job_Name44).command        = 'g_PDtrackNETpre( opt.LabelFile, opt.LabelVector, opt.ResultantFolder )';
        end
        Bedpostx_Name = [ 'BedpostX_postproc_' Number_Of_Subject_String ];
        pipeline.(Job_Name44).files_in.files = pipeline.(Bedpostx_Name).files_out.files;
        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
            pipeline.(Job_Name44).files_out.files   = g_OPDtrackNETpre_FileOut( ResultantFolder, tracking_opt.LabelIdVector );
        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
            pipeline.(Job_Name44).files_out.files   = g_PDtrackNETpre_FileOut( ResultantFolder, tracking_opt.LabelIdVector );
        end
        if tracking_opt.PartitionOfSubjects
            pipeline.(Job_Name44).opt.LabelFile   = T1orPartitionOfSubjects_PathCell{i};
        else
            PartitionTemplate2FA_Name = [ 'PartitionTemplate2FA_' Number_Of_Subject_String ];
            pipeline.(Job_Name44).files_in.Labelfiles  = pipeline.(PartitionTemplate2FA_Name).files_out.files;
            pipeline.(Job_Name44).opt.LabelFile   = pipeline.(PartitionTemplate2FA_Name).files_out.files{1};
        end
        pipeline.(Job_Name44).opt.LabelVector     = tracking_opt.LabelIdVector;
        pipeline.(Job_Name44).opt.ResultantFolder = ResultantFolder;
        
        for j = 1:length(tracking_opt.LabelIdVector)
            LabelSeedFileName = pipeline.(Job_Name44).files_out.files{2 * j};
            LabelTermFileName = pipeline.(Job_Name44).files_out.files{2 * j + 1};
            Job_Name45 = [ 'ProbabilisticNetwork_' Number_Of_Subject_String '_' num2str(j, '%02d')];
            if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
                pipeline.(Job_Name45).command        = 'g_OPDtrackNET( opt.BedostxFolder, opt.LabelSeedFileName, opt.LabelTermFileName, opt.TargetsTxtFileName, opt.JobName )';
            elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
                pipeline.(Job_Name45).command        = 'g_PDtrackNET( opt.BedostxFolder, opt.LabelSeedFileName, opt.LabelTermFileName, opt.TargetsTxtFileName, opt.JobName )';
            end
            ProbabilisticNetworkPre_Name = [ 'ProbabilisticNetworkpre_',Number_Of_Subject_String ];
            pipeline.(Job_Name45).files_in.files{1} = pipeline.(Job_Name44).files_out.files{1};
            pipeline.(Job_Name45).files_in.files{2} = LabelSeedFileName;
            pipeline.(Job_Name45).files_in.files{3} = LabelTermFileName;
            BedpostxFolder = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'native_space.bedpostX'];
            pipeline.(Job_Name45).files_out.files   = g_OPDtrackNET_FileOut( LabelSeedFileName, Job_Name45 );
            pipeline.(Job_Name45).opt.BedostxFolder = BedpostxFolder;  
            pipeline.(Job_Name45).opt.LabelSeedFileName = LabelSeedFileName;
            pipeline.(Job_Name45).opt.LabelTermFileName = LabelTermFileName;
            pipeline.(Job_Name45).opt.TargetsTxtFileName = pipeline.(Job_Name44).files_out.files{1};
            pipeline.(Job_Name45).opt.JobName = Job_Name45;
        end
        
        Job_Name46 = [ 'ProbabilisticNetworkpost_' Number_Of_Subject_String ];
        pipeline.(Job_Name46).command        = 'g_track4NETpost_fdt( opt.seed, opt.fdt, opt.prefix )';
        for j = 1:length(tracking_opt.LabelIdVector)
            Job_Name = [ 'ProbabilisticNetwork_' Number_Of_Subject_String '_' num2str(j, '%02d')];
            pipeline.(Job_Name46).files_in.files{j}       = pipeline.(Job_Name).files_out.files{1};
        end
        if strcmp(tracking_opt.ProbabilisticTrackingType, 'OPD')
            for id = 1:length(tracking_opt.LabelIdVector)
                pipeline.(Job_Name46).opt.seed{id} = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'Network' filesep 'Probabilistic' ...
                                                      filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') '_OPDtrackNET' filesep 'Label' num2str(tracking_opt.LabelIdVector(id), '%02.0f') '_SeedMask.nii.gz' ];
                pipeline.(Job_Name46).opt.fdt{id} = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'Network' filesep 'Probabilistic' ...
                                                      filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') '_OPDtrackNET' filesep 'fdt_paths.nii.gz' ];
            end
        elseif strcmp(tracking_opt.ProbabilisticTrackingType, 'PD')
            for id = 1:length(tracking_opt.LabelIdVector)
                pipeline.(Job_Name46).opt.seed{id} = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'Network' filesep 'Probabilistic' ...
                                                       filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') '_PDtrackNET' filesep 'Label' num2str(tracking_opt.LabelIdVector(id), '%02.0f') '_SeedMask.nii.gz' ];
                pipeline.(Job_Name46).opt.fdt{id} = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'Network' filesep 'Probabilistic' ...
                                                       filesep 'Label' num2str(tracking_opt.LabelIdVector(id),'%02.0f') '_PDtrackNET' filesep 'fdt_paths.nii.gz' ];
            end
        end
        NativeFolderPath = [ Nii_Output_Path filesep Number_Of_Subject_String filesep 'native_space'];
        pipeline.(Job_Name46).opt.prefix = dtifit_Prefix;
        pipeline.(Job_Name46).files_out.files = g_track4NETpost_fdt_FileOut( NativeFolderPath, dtifit_Prefix );
    end
end

% Excute the pipeline
% psom_visu_dependencies(pipeline);
psom_run_pipeline(pipeline,pipeline_opt);

catch err
    disp(err.message);
    for e=1:length(err.stack)
        fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
    end
    system(['touch ' Nii_Output_Path filesep 'logs' filesep 'dti_pipeline.error']);
end









