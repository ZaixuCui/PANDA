function g_BetT1_pipeline( DataRaw_pathCell, SubjectID, Destination_Path, File_Prefix, BetT1_opt, pipeline_opt )
%
%__________________________________________________________________________
% SUMMARY OF G_BETT1_PIPELINE
% 
% The whole process of brain extraction of T1 images for any number of subjects.
%
% SYNTAX:
%
% 1) g_BetT1_pipeline( DataRaw_pathCell, SubjectID, Destination_Path, File_Prefix )
% 2) g_BetT1_pipeline( DataRaw_pathCell, SubjectID, Destination_Path, File_Prefix, BetT1_opt )
% 3) g_BetT1_pipeline( DataRaw_pathCell, SubjectID, Destination_Path, File_Prefix, BetT1_opt, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% DATARAW_PATHCELL
%        (cell of strings) 
%        The input folder cell, each of which includes the DICOM/NIfTI data.
%        1. DICOM data
%           Only DICOM of T1 can be in the input folder.
%        2. NIfTI data
%           Only one NIfTI image can be in the input folder.
%
% SUBJECTID
%        (cell of integers) 
%        The order of the subjects.
%        For example: SubjectID = [1:5] 
%                     The resultant folder for each subject is like 
%                     '/data/Handled_Data/00001/'
%
% DESTINATION_PATH
%        (string) 
%        The full path of resultant folder for all subjects.
%        For example: '/data/Handled_Data/'
%
% File_Prefix
%        (string) 
%        Basename for the output file. 
%
% BETT1_OPT
%
%        If pipeline_opt = 'default', then the default values will be
%        assigned to all its fields.
%
%        (structure) with the following fields : 
%
%        BetT1_f_threshold
%            (single, default 0.5)
%            Fractional intensity thershold (0->1);
%            smaller values give larger brain outline estimates
%
%        T1Cropping_Flag
%            (0 or 1, default 1)
%            The flag whether to crop the T1 image.
%
%        T1CroppingGap
%            (integer, default 3, Only needed when T1Cropping_Flag=1)
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
% PIPELINE_OPT
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
    disp('Please input subjects'' raw DICOM data.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if ~iscell(DataRaw_pathCell)
    disp('The first parameter should be a cell.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
[RawDataRows, RawDataColumns] = size(DataRaw_pathCell);
if RawDataColumns ~= 1
    disp('The quantity of columns of raw data cell should be 1.');
    disp('DataRaw_pathCell is a n*1 matrix.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if nargin <= 1
    disp('Please assign IDs for the subjects.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if RawDataRows ~= length(SubjectID)
    disp('The quantity of raw data should be equal to the quantity of IDs.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if nargin <= 2
    disp('Please input the path of folder storing the resultant files.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
try
    if ~exist(Destination_Path, 'dir')
        mkdir(Destination_Path);
        if ~strcmp(Destination_Path(1), filesep)
            Destination_Path = [pwd filesep Destination_Path];
        end
    else
        x = 1;
        save([Destination_Path filesep 'permission_tag.mat'], 'x');
    end
catch
    disp('Maybe the Destination_Path is illegal or permission denied.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if nargin <= 3
    File_Prefix = '';
end

if nargin <= 4
    % The default value of BetT1 opt parameters
    BetT1_opt.BetT1_f_threshold = 0.5;
    BetT1_opt.T1Cropping_Flag = 1;
    BetT1_opt.T1CroppingGap = 3;
    BetT1_opt.T1Resample_Flag = 1;
    BetT1_opt.T1ResampleResolution = [1 1 1];
elseif ~isstruct(BetT1_opt) && ~strcmp(BetT1_opt, 'default')
    disp('The value of the fifth parameter BetT1_opt is invalid.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
elseif strcmp(BetT1_opt, 'default')
    % The default value of BetT1 opt parameters
    clear pipeline_opt;
    BetT1_opt.BetT1_f_threshold = 0.5;
    BetT1_opt.T1Cropping_Flag = 1;
    BetT1_opt.T1CroppingGap = 3;
    BetT1_opt.T1Resample_Flag = 1;
    BetT1_opt.T1ResampleResolution = [1 1 1];
elseif nargin >= 5
    
    BetT1OptFields = {'BetT1_f_threshold', 'T1Cropping_Flag', 'T1CroppingGap', 'T1Resample_Flag', ...
        'T1ResampleResolution'};
    BetT1OptFields_UserInputs = fieldnames(BetT1_opt);
    for i = 1:length(BetT1OptFields_UserInputs)
        if isempty(find(strcmp(BetT1OptFields, BetT1OptFields_UserInputs{i})))
            disp([BetT1OptFields_UserInputs{i} ' is not the field of BetT1 opt.']);
            disp('See the help, type ''help g_BetT1_pipeline''.');
            return;
        end
    end
    
    if ~isfield(BetT1_opt, 'BetT1_f_threshold')
        BetT1_opt.BetT1_f_threshold = 0.5;
    end
    if ~isfield(BetT1_opt, 'T1Cropping_Flag')
        BetT1_opt.T1Cropping_Flag = 1;
    end
    if BetT1_opt.T1Cropping_Flag
        if ~isfield(BetT1_opt, 'T1CroppingGap')
            BetT1_opt.T1CroppingGap = 3;
        end
    end
    if ~isfield(BetT1_opt, 'T1Resample_Flag')
        BetT1_opt.T1Resample_Flag = 1;
    end
    if BetT1_opt.T1Resample_Flag
        if ~isfield(BetT1_opt, 'T1ResampleResolution')
            BetT1_opt.T1ResampleResolution = [1 1 1];
        end
    end
    
    if ~isnumeric(BetT1_opt.BetT1_f_threshold)
        disp('The BetT1_f_threshold of BetT1_opt shoud be an positive value (0->1).');
        disp('see the help, type ''help g_BetT1_pipeline''.');
        return;
    end
    if BetT1_opt.BetT1_f_threshold < 0 || BetT1_opt.BetT1_f_threshold > 1
        disp('The BetT1_f_threshold of BetT1_opt shoud be an positive value (0->1).');
        disp('see the help, type ''help g_BetT1_pipeline''.');
        return;
    end
    if ~isnumeric(BetT1_opt.T1Cropping_Flag)
        disp('The T1Cropping_Flag of BetT1_opt should be 0 or 1');
        disp('see the help, type ''help g_BetT1_pipeline''.');
        return;
    end
    if BetT1_opt.T1Cropping_Flag ~= 0 && BetT1_opt.T1Cropping_Flag ~= 1
        disp('The T1Cropping_Flag of BetT1_opt should be 0 or 1');
        disp('see the help, type ''help g_BetT1_pipeline''.');
        return;
    end    
    if BetT1_opt.T1Cropping_Flag
        if ~isnumeric(BetT1_opt.T1CroppingGap)
            disp('The T1CroppingGap of the BetT1_opt shoud be an positive integer.');
            disp('see the help, type ''help g_BetT1_pipeline''.');
            return;
        end
        if round(BetT1_opt.T1CroppingGap) ~= BetT1_opt.T1CroppingGap
            disp('The T1CroppingGap of the BetT1_opt shoud be an integer.');
            disp('see the help, type ''help g_BetT1_pipeline''.');
            return;
        end
        if BetT1_opt.T1CroppingGap <= 0
            disp('The T1CroppingGap of the BetT1_opt shoud be an positive integer.');
            disp('see the help, type ''help g_BetT1_pipeline''.');
            return;
        end
    end
    if ~isnumeric(BetT1_opt.T1Resample_Flag)
        disp('The T1Resample_Flag of BetT1_opt should be 0 or 1.');
        disp('see the help, type ''help g_BetT1_pipeline''.');
        return;
    end
    if BetT1_opt.T1Resample_Flag ~= 0 && BetT1_opt.T1Resample_Flag ~= 1
        disp('The T1Resample_Flag of BetT1_opt should be 0 or 1.');
        disp('see the help, type ''help g_BetT1_pipeline''.');
        return;
    end 
    if BetT1_opt.T1Resample_Flag
        try
            if length(BetT1_opt.T1ResampleResolution) ~= 3
                disp('The T1ResampleResolution of BetT1_opt should be 3 integers.');
                disp('see the help, type ''help g_BetT1_pipeline''.');
                return;
            end
        catch
            disp('The T1ResampleResolution of BetT1_opt is illegal.');
            disp('see the help, type ''help g_BetT1_pipeline''.');
            return;
        end
    end
end
        
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

if nargin <= 5
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
    pipeline_opt.path_logs = [Destination_Path '/logs/'];
elseif ~isstruct(pipeline_opt) && ~strcmp(pipeline_opt, 'default')
    disp('The value of the fifth parameter pipeline opt is invalid.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
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
    pipeline_opt.path_logs = [Destination_Path '/logs/'];
elseif nargin >= 6
    
    PipelineOptFields = {'mode', 'qsub_options', 'mode_pipeline_manager', 'max_queued', ...
        'flag_verbose', 'flag_pause', 'path_logs'};
    PipelineOptFields_UserInputs = fieldnames(pipeline_opt);
    for i = 1:length(PipelineOptFields_UserInputs)
        if isempty(find(strcmp(PipelineOptFields, PipelineOptFields_UserInputs{i})))
            disp([PipelineOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
            disp('See the help, type ''help g_BetT1_pipeline''.');
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
        pipeline_opt.path_logs = [Destination_Path '/logs/'];
    else
        pipeline_opt.path_logs = [pipeline_opt.path_logs '/logs/'];
    end
end

if ~strcmp(pipeline_opt.mode, 'batch') && ~strcmp(pipeline_opt.mode, 'qsub')
    disp('The mode of the pipeline should be ''batch'' or ''qsub''');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if ~isnumeric(pipeline_opt.max_queued)
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if round(pipeline_opt.max_queued) ~= pipeline_opt.max_queued
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end
if pipeline_opt.max_queued <= 0
    disp('The max queued of the pipeline shoud be an positive integer.');
    disp('see the help, type ''help g_BetT1_pipeline''.');
    return;
end

for i = 1:length(DataRaw_pathCell)
    
    Number_Of_Subject_String = num2str(SubjectID(i), '%05.0f');
    ResultantFolder = [Destination_Path filesep Number_Of_Subject_String filesep 'T1'];
    
    if (length(dir(DataRaw_pathCell{i})) - 2) ~= 1
        Job_Name1 = ['dcm2nii_' Number_Of_Subject_String];
        pipeline.(Job_Name1).command            = 'g_T1Dcm2nii( opt.DataRaw_path, opt.index, opt.DataNii_folder, opt.prefix )';
        if File_Prefix
            pipeline.(Job_Name1).files_out.files{1} = [ResultantFolder filesep File_Prefix '_' Number_Of_Subject_String '_t1.nii.gz'];
        else
            pipeline.(Job_Name1).files_out.files{1} = [ResultantFolder filesep Number_Of_Subject_String '_t1.nii.gz'];
        end
        pipeline.(Job_Name1).opt.DataRaw_path = DataRaw_pathCell{i};
        pipeline.(Job_Name1).opt.index = SubjectID(i);
        pipeline.(Job_Name1).opt.DataNii_folder   = [Destination_Path filesep Number_Of_Subject_String filesep 'T1'];
        pipeline.(Job_Name1).opt.prefix         = File_Prefix;
    end
    
    Job_Name2 = ['BetT1_' Number_Of_Subject_String];
    if (length(dir(DataRaw_pathCell{i})) - 2) ~= 1
        pipeline.(Job_Name2).command            = 'g_BetT1( files_in.files{1}, opt.bet_f )';
        pipeline.(Job_Name2).files_in.files     = pipeline.(Job_Name1).files_out.files;
    else
        OriginalT1 = g_ls([DataRaw_pathCell{i} filesep '*']);
        if File_Prefix
            NewT1 = [ResultantFolder filesep File_Prefix '_' Number_Of_Subject_String '_t1.nii.gz'];
        else
            NewT1 = [ResultantFolder filesep Number_Of_Subject_String '_t1.nii.gz'];
        end
        pipeline.(Job_Name2).command            = ['system(''cp ' OriginalT1{1} ' ' NewT1 ''');' ... 
            'g_BetT1( opt.NewT1, opt.bet_f )'];
        pipeline.(Job_Name2).opt.NewT1          = NewT1;
    end
    if File_Prefix
        pipeline.(Job_Name2).files_out.files{1} = [ResultantFolder filesep File_Prefix '_' Number_Of_Subject_String '_t1_swap_bet.nii.gz'];
    else
        pipeline.(Job_Name2).files_out.files{1} = [ResultantFolder filesep Number_Of_Subject_String '_t1_swap_bet.nii.gz'];
    end
    pipeline.(Job_Name2).opt.bet_f          = BetT1_opt.BetT1_f_threshold;
    
    if File_Prefix
        NewT1PathPrefix = [ResultantFolder filesep File_Prefix '_' Number_Of_Subject_String '_t1_swap_bet'];
    else
        NewT1PathPrefix = [ResultantFolder filesep Number_Of_Subject_String '_t1_swap_bet'];
    end
    
    if BetT1_opt.T1Cropping_Flag
        Job_Name3 = ['T1Cropped_' Number_Of_Subject_String];
        pipeline.(Job_Name3).command            = 'g_T1Cropped( files_in.files{1}, opt.T1CroppingGap )';
        pipeline.(Job_Name3).files_in.files     = pipeline.(Job_Name2).files_out.files;
        if File_Prefix
            pipeline.(Job_Name3).files_out.files{1} = [ResultantFolder filesep File_Prefix '_' Number_Of_Subject_String '_t1_swap_bet_crop.nii.gz'];
            NewT1PathPrefix = [ResultantFolder filesep File_Prefix '_' Number_Of_Subject_String '_t1_swap_bet_crop'];
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

psom_run_pipeline(pipeline,pipeline_opt);


