function g_BrainParcellation_pipeline(FAPathCell, T1PathCell, BrainParcellation_opt, pipeline_opt)
%
%__________________________________________________________________________
% SUMMARY OF G_BRAINPARCELLATION_PIPELINE
% 
% The whole process of brain parcellation for any number of subjects
%
% SYNTAX:
%
% 1) g_BrainParcellation_pipeline( FAPathCell, T1PathCell )
% 2) g_BrainParcellation_pipeline( FAPathCell, T1PathCell, BrainParcellation_opt )
% 3) g_BrainParcellation_pipeline( FAPathCell, T1PathCell, BrainParcellation_opt, pipeline_opt )
%__________________________________________________________________________
% INPUTS:
%
% FAPATHCELL
%        (cell of strings)
%        The input cell, each of which is the full path of subject's FA.
%        FA is original FA calculated by dtifit.
%
% T1PATHCELL
%        (cell of strings)
%        The input cell, each of which is the path of subject's T1.
%        T1 image should be skull stripped.
%
% BrainParcellation_opt
%        If PartitionTemplatePath = 'default', then the default values will 
%        be assigned to all its fields.
%
%        (structure) with the following fields :
% 
%        T1Bet_Flag
%            (0 or 1, default 1)
%            The flag whether to do brain extraction for T1 image.
%
%        T1BetF
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
%        PartitionTemplatePath
%            (string, default AAL atlas with 90 regions)
%            The full path of gray matter altas in standard space.           
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
% keywords: brain parcellation, pipeline, psom
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
    disp('Please input subjects'' FA path.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
elseif nargin <= 1
    disp('Please input subjects'' T1 path.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
elseif ~iscell(FAPathCell)
    disp('The first parameter subjects'' FA paths should be a cell.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
elseif ~iscell(T1PathCell)
    disp('The second parameter subjects'' T1 paths should be a cell.');
    disp('see the help, type ''help g_BrainParcellation_pipeline''.');
else
    [FARows, FAColumns] = size(FAPathCell);
    if FAColumns ~= 1
        disp('The cell of FA path should be 1 column.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    
    [T1Rows, T1Columns] = size(T1PathCell);
    if T1Columns ~= 1
        disp('The cell of T1 path should be 1 column.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    
    if FARows ~= T1Rows
        disp('The number of rows of FA path Cell should be equal to the number of rows of T1 path cell.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    
    global PANDAPath;
    [PANDAPath y z] = fileparts(which('PANDA.m'));

    psom_gb_vars

    if nargin <= 2
        % The default value of brain parcellation opt parameters
        BrainParcellation_opt.T1Bet_Flag = 1;
        BrainParcellation_opt.T1BetF = 0.5;
        BrainParcellation_opt.T1Cropping_Flag = 1;
        BrainParcellation_opt.T1CroppingGap = 3;
        BrainParcellation_opt.T1Resample_Flag = 1;
        BrainParcellation_opt.T1ResampleResolution = [1 1 1];
        BrainParcellation_opt.PartitionTemplatePath = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
    elseif ~isstruct(BrainParcellation_opt) && ~strcmp(BrainParcellation_opt, 'default')
        disp('The value of the third parameter brain parcellation opt is invalid.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    elseif strcmp(BrainParcellation_opt, 'default')
        % The default value of brain parcellation opt parameters
        BrainParcellation_opt.T1Bet_Flag = 1;
        BrainParcellation_opt.T1BetF = 0.5;
        BrainParcellation_opt.T1Cropping_Flag = 1;
        BrainParcellation_opt.T1CroppingGap = 3;
        BrainParcellation_opt.T1Resample_Flag = 1;
        BrainParcellation_opt.T1ResampleResolution = [1 1 1];
        BrainParcellation_opt.PartitionTemplatePath = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
    else
        BrainParcellationOptFields = {'T1Bet_Flag', 'T1BetF', 'T1Cropping_flag', 'T1CroppingGap', ...
            'T1Resample_Flag', 'T1ResampleResolution', 'PartitionTemplatePath'};
        BrainParcellationOptFields_UserInputs = fieldnames(BrainParcellation_opt);
        for i = 1:length(BrainParcellationOptFields_UserInputs)
            if isempty(find(strcmp(BrainParcellationOptFields, BrainParcellationOptFields_UserInputs{i})))
                disp([BrainParcellationOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
                disp('See the help, type ''help g_BrainParcellation_pipeline''.');
                return;
            end
        end
        
        if ~isfield(BrainParcellation_opt, 'T1Bet_Flag')
            BrainParcellation_opt.T1Bet_Flag = 1;
        end
        if BrainParcellation_opt.T1Bet_Flag && ~isfield(BrainParcellation_opt, 'T1BetF')
            BrainParcellation_opt.T1BetF = 0.5;
        end
        if ~isfield(BrainParcellation_opt, 'T1Cropping_flag')
            BrainParcellation_opt.T1Cropping_Flag = 1;
        end
        if BrainParcellation_opt.T1Cropping_Flag && ~isfield(BrainParcellation_opt, 'T1CroppingGap')
            BrainParcellation_opt.T1CroppingGap = 3;
        end
        if ~isfield(BrainParcellation_opt, 'T1Resample_Flag')
            BrainParcellation_opt.T1Resample_Flag = 1;
        end
        if BrainParcellation_opt.T1Resample_Flag && ~isfield(BrainParcellation_opt, 'T1ResampleResolution')
            BrainParcellation_opt.T1ResampleResolution = [1 1 1];
        end
        if ~isfield(BrainParcellation_opt, 'PartitionTemplatePath')
            BrainParcellation_opt.PartitionTemplatePath = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_Contract_90_2MM'];
        end
    end
    
    if ~isnumeric(BrainParcellation_opt.T1Bet_Flag)
        disp('The T1Bet_Flag of BrainParcellation_opt should be 0 or 1');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if BrainParcellation_opt.T1Bet_Flag ~= 0 && BrainParcellation_opt.T1Bet_Flag ~= 1
        disp('The T1Bet_Flag of BrainParcellation_opt should be 0 or 1');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if ~isnumeric(BrainParcellation_opt.T1BetF)
        disp('The T1BetF of BrainParcellation_opt shoud be an positive value (0->1).');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if BrainParcellation_opt.T1BetF < 0 || BrainParcellation_opt.T1BetF > 1
        disp('The T1BetF of BrainParcellation_opt shoud be an positive value (0->1).');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if ~isnumeric(BrainParcellation_opt.T1Cropping_Flag)
        disp('The T1Cropping_Flag of BrainParcellation_opt should be 0 or 1');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if BrainParcellation_opt.T1Cropping_Flag ~= 0 && BrainParcellation_opt.T1Cropping_Flag ~= 1
        disp('The T1Cropping_Flag of BrainParcellation_opt should be 0 or 1');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end    
    if ~isnumeric(BrainParcellation_opt.T1CroppingGap)
        disp('The T1CroppingGap of the BrainParcellation_opt shoud be an positive integer.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if round(BrainParcellation_opt.T1CroppingGap) ~= BrainParcellation_opt.T1CroppingGap
        disp('The T1CroppingGap of the BrainParcellation_opt shoud be an integer.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if BrainParcellation_opt.T1CroppingGap <= 0
        disp('The T1CroppingGap of the BrainParcellation_opt shoud be an positive integer.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if ~isnumeric(BrainParcellation_opt.T1Resample_Flag)
        disp('The T1Resample_Flag of BrainParcellation_opt should be 0 or 1.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if BrainParcellation_opt.T1Resample_Flag ~= 0 && BrainParcellation_opt.T1Resample_Flag ~= 1
        disp('The T1Resample_Flag of BrainParcellation_opt should be 0 or 1.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end 
    try
        if length(BrainParcellation_opt.T1ResampleResolution) ~= 3
            disp('The T1ResampleResolution of BrainParcellation_opt should be 3 integers.');
            disp('see the help, type ''help g_BrainParcellation_pipeline''.');
            return;
        end
    catch
        disp('The T1ResampleResolution of BrainParcellation_opt is illegal.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    [x exist_flag] = system(['imtest ' BrainParcellation_opt.PartitionTemplatePath]);
    exist_flag = str2num(exist_flag);
    if ~(exist_flag == 1)
        disp(['The file ' BrainParcellation_opt.PartitionTemplatePath ' doesn''t exist.']);
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
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
        pipeline_opt.path_logs = [pwd '/BrainParcellation_logs/'];
    elseif ~isstruct(pipeline_opt) && ~strcmp(pipeline_opt, 'default')
        disp('The value of the fifth parameter pipeline opt is invalid.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
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
        pipeline_opt.path_logs = [pwd '/BrainParcellation_logs/'];
    elseif nargin >= 4
        
        PipelineOptFields = {'mode', 'qsub_options', 'mode_pipeline_manager', 'max_queued', ...
            'flag_verbose', 'flag_pause', 'path_logs'};
        PipelineOptFields_UserInputs = fieldnames(pipeline_opt);
        for i = 1:length(PipelineOptFields_UserInputs)
            if isempty(find(strcmp(PipelineOptFields, PipelineOptFields_UserInputs{i})))
                disp([PipelineOptFields_UserInputs{i} ' is not the field of pipeline opt.']);
                disp('See the help, type ''help g_BrainParcellation_pipeline''.');
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
            pipeline_opt.path_logs = [pwd '/BrainParcellation_logs/'];
        else
            pipeline_opt.path_logs = [pipeline_opt.path_logs '/BrainParcellation_logs/'];
        end
    end
    
    if ~strcmp(pipeline_opt.mode, 'batch') && ~strcmp(pipeline_opt.mode, 'qsub')
        disp('The mode of the pipeline should be ''batch'' or ''qsub''');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if ~isnumeric(pipeline_opt.max_queued)
        disp('The max queued of the pipeline shoud be an positive integer.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if round(pipeline_opt.max_queued) ~= pipeline_opt.max_queued
        disp('The max queued of the pipeline shoud be an integer.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
        return;
    end
    if pipeline_opt.max_queued <= 0
        disp('The max queued of the pipeline shoud be an positive integer.');
        disp('see the help, type ''help g_BrainParcellation_pipeline''.');
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
        for i = 1:length(FAPathCell)
            Number_Of_Subject_String = num2str(i, '%05.0f');
            [NativeFolder, FAFileName, FASuffix] = fileparts(FAPathCell{i}); 
            if strcmp(FASuffix, '.gz')
                [a, FAFileName, c] = fileparts(FAFileName);
            end
            [SubjectFolder, b, c] = fileparts(NativeFolder);
            T1Folder = [SubjectFolder filesep 'T1'];
            [T1ParentFolder, T1FileName, T1Suffix] = fileparts(T1PathCell{i});
            if strcmp(T1Suffix, '.gz')
                NewT1PathPrefix = [T1Folder filesep T1FileName(1:end - 4)];
                T1FileName = T1FileName(1:end - 4);
            elseif strcmp(T1Suffix, '.nii')
                NewT1PathPrefix = [T1Folder filesep T1FileName];
            else
                error('Not a .nii or .nii.gz file.');
            end

            if BrainParcellation_opt.T1Bet_Flag
                NewT1PathPrefix = [NewT1PathPrefix '_swap_bet'];
            end

            if BrainParcellation_opt.T1Cropping_Flag
                T1toFAMat = [NewT1PathPrefix '_crop_resample_2FA.mat'];
                if BrainParcellation_opt.T1Resample_Flag
                    T1toMNI152_warp_inv = [NewT1PathPrefix '_crop_resample_2MNI152_warp_inv.nii.gz'];
                else
                    T1toMNI152_warp_inv = [NewT1PathPrefix '_crop_2MNI152_warp_inv.nii.gz'];
                end
            else
                T1toFAMat = [NewT1PathPrefix '_resample_2FA.mat'];
                if BrainParcellation_opt.T1Resample_Flag
                    T1toMNI152_warp_inv = [NewT1PathPrefix '_resample_2MNI152_warp_inv.nii.gz'];
                else
                    T1toMNI152_warp_inv = [NewT1PathPrefix '_2MNI152_warp_inv.nii.gz'];
                end
            end

            Job_Name1 = [ 'CopyT1_' Number_Of_Subject_String ];
            pipeline.(Job_Name1).command         = 'if ~strcmp(opt.T1ParentFolder,opt.T1Path);if ~exist(opt.T1Folder);mkdir(opt.T1Folder);end;system([''cp '' opt.T1Path '' '' opt.T1Folder]);end;';
            pipeline.(Job_Name1).files_out.files{1} = [T1Folder filesep T1FileName '.nii.gz'];
            pipeline.(Job_Name1).opt.T1Folder = T1Folder;
            pipeline.(Job_Name1).opt.T1ParentFolder = T1ParentFolder;
            pipeline.(Job_Name1).opt.T1Path = T1PathCell{i};

            if BrainParcellation_opt.T1Bet_Flag
                Job_Name2 = [ 'BetT1_' Number_Of_Subject_String ];
                pipeline.(Job_Name2).command            = 'g_BetT1( opt.DataRaw_path, opt.bet_f )';
                pipeline.(Job_Name2).files_in.files     = pipeline.(Job_Name1).files_out.files;
                pipeline.(Job_Name2).files_out.files{1} = [T1Folder filesep T1FileName '_swap_bet.nii.gz'];
                pipeline.(Job_Name2).opt.DataRaw_path   = pipeline.(Job_Name1).files_out.files{1}; 
                pipeline.(Job_Name2).opt.bet_f          = BrainParcellation_opt.T1BetF;
            end

            if BrainParcellation_opt.T1Cropping_Flag
                Job_Name3 = ['T1Cropped_' Number_Of_Subject_String];
                pipeline.(Job_Name3).command            = 'g_T1Cropped( opt.T1FilePath, opt.T1CroppingGap )';
                if BrainParcellation_opt.T1Bet_Flag
                    pipeline.(Job_Name3).files_in.files = pipeline.(Job_Name2).files_out.files;
                    pipeline.(Job_Name3).opt.T1FilePath = [T1Folder filesep T1FileName '_swap_bet.nii.gz'];
                else
                    pipeline.(Job_Name3).files_in.files = pipeline.(Job_Name1).files_out.files;
                    pipeline.(Job_Name3).opt.T1FilePath = [T1Folder filesep T1FileName '.nii.gz'];
                end
                pipeline.(Job_Name3).files_out.files{1} = [NewT1PathPrefix '_crop.nii.gz'];
                pipeline.(Job_Name3).opt.T1CroppingGap  = BrainParcellation_opt.T1CroppingGap;


                NewT1PathPrefix = [NewT1PathPrefix '_crop'];
            end

            if BrainParcellation_opt.T1Resample_Flag
                Job_Name4 = ['T1Resample_' Number_Of_Subject_String];
                pipeline.(Job_Name4).command            = 'g_resample_nii( opt.T1_Path, opt.ResampleResolution, files_out.files{1} )';
                if BrainParcellation_opt.T1Cropping_Flag
                    pipeline.(Job_Name4).files_in.files = pipeline.(Job_Name3).files_out.files;
                    pipeline.(Job_Name4).opt.T1_Path    = pipeline.(Job_Name3).files_out.files{1};
                else
                    pipeline.(Job_Name4).files_in.files = pipeline.(Job_Name2).files_out.files;
                    pipeline.(Job_Name4).opt.T1_Path    = pipeline.(Job_Name2).files_out.files{1};
                end
                pipeline.(Job_Name4).opt.ResampleResolution = BrainParcellation_opt.T1ResampleResolution;
                pipeline.(Job_Name4).files_out.files{1} = [NewT1PathPrefix '_resample.nii.gz'];

                NewT1PathPrefix = [NewT1PathPrefix '_resample'];
            end

            if BrainParcellation_opt.T1Resample_Flag
                FinalT1 = pipeline.(Job_Name4).files_out.files{1};
            elseif BrainParcellation_opt.T1Cropping_Flag
                FinalT1 = pipeline.(Job_Name3).files_out.files{1};
            else
                FinalT1 = pipeline.(Job_Name2).files_out.files{1};
            end

            Job_Name5 = [ 'FAtoT1_' Number_Of_Subject_String ];
            pipeline.(Job_Name5).command            = 'g_FAtoT1( opt.FA_Path, opt.T1_Path)';
            pipeline.(Job_Name5).files_in.files{1}  = FinalT1;
            pipeline.(Job_Name5).opt.T1_Path        = FinalT1;
            pipeline.(Job_Name5).opt.FA_Path        = FAPathCell{i};
            pipeline.(Job_Name5).files_out.files{1}     = [T1Folder filesep FAFileName '_2T1.mat'];
            pipeline.(Job_Name5).files_out.files{2}     = [T1Folder filesep FAFileName '_2T1.nii.gz'];
            if strcmp(T1Suffix, '.gz')
                pipeline.(Job_Name5).files_out.files{3}     = [NewT1PathPrefix '_2FA.mat'];
            elseif strcmp(T1Suffix, '.nii')
                pipeline.(Job_Name5).files_out.files{3}     = [NewT1PathPrefix '_2FA.mat'];
            else
                error('Not a .nii or .nii.gz file.');
            end

            Job_Name6 = ['T1toMNI152_' Number_Of_Subject_String];
            pipeline.(Job_Name6).command            = 'g_T1toMNI152( opt.T1_Path )';
            pipeline.(Job_Name6).opt.T1_Path        = FinalT1;
            pipeline.(Job_Name6).files_in.files{1}      = FinalT1;
            pipeline.(Job_Name6).files_out.files{1}     = [NewT1PathPrefix '_2MNI152.nii.gz'];
            pipeline.(Job_Name6).files_out.files{2}     = [NewT1PathPrefix '_2MNI152_warp.nii.gz'];

            Job_Name7 = [ 'Invwarp_' Number_Of_Subject_String ];
            pipeline.(Job_Name7).command             = 'g_Invwarp( opt.WarpVolume, opt.ReferenceVolume )';
            pipeline.(Job_Name7).files_in.files{1}     = pipeline.(Job_Name6).files_out.files{2};
            pipeline.(Job_Name7).files_in.files{2}     = FinalT1;
            pipeline.(Job_Name7).files_out.files{1}    = T1toMNI152_warp_inv;
            pipeline.(Job_Name7).opt.ReferenceVolume   = FinalT1;
            pipeline.(Job_Name7).opt.WarpVolume        = pipeline.(Job_Name6).files_out.files{2};

            Job_Name8 = [ 'IndividualParcellated_' Number_Of_Subject_String ];
            pipeline.(Job_Name8).command             = 'g_IndividualParcellated( opt.FA_Path, opt.T1_Path, opt.PartitionTemplate, opt.T1toFAMat, opt.T1toMNI152_warp_inv )';
            pipeline.(Job_Name8).files_in.files{1} = pipeline.(Job_Name5).files_out.files{3};
            pipeline.(Job_Name8).files_in.files{2} = pipeline.(Job_Name7).files_out.files{1};
            pipeline.(Job_Name8).opt.PartitionTemplate = BrainParcellation_opt.PartitionTemplatePath;
            pipeline.(Job_Name8).opt.FA_Path = FAPathCell{i};
            pipeline.(Job_Name8).opt.T1toFAMat = pipeline.(Job_Name5).files_out.files{3};
            pipeline.(Job_Name8).opt.T1toMNI152_warp_inv = pipeline.(Job_Name7).files_out.files{1};
            pipeline.(Job_Name8).opt.T1_Path = FinalT1;
            [a, PartitionTemplateName, PartitionTemplateSuffix] = fileparts(BrainParcellation_opt.PartitionTemplatePath);
            if strcmp(PartitionTemplateSuffix, '.gz')
                T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateName(1:end-4) '.nii.gz'];
            elseif strcmp(PartitionTemplateSuffix, '.nii') || isempty(PartitionTemplateSuffix)
                T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateName '.nii.gz'];
            end
            pipeline.(Job_Name8).files_out.files{1} = T1toFA_PartitionTemplate;
        
        end

        psom_run_pipeline(pipeline,pipeline_opt);
    end
end


