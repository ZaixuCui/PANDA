function g_CalculateJobStatusMain( DestinationPath_Edit, SubjectIDArray, dti_opt, tracking_opt, LockFlag )
% Calculate job status for PANDA, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%   Copyright(c) 2012
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%   Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%   Version 1.2.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
ErrMsgQuantity = 0;
% TrackingResultExistInfo = [DestinationPath_Edit filesep 'logs' filesep 'DeterministicTrackingResultExist.mat'];
while 1
    if ~exist(MonitorTagPath, 'file') & LockFlag
        break;
    end
    StatusFilePath = [DestinationPath_Edit filesep 'logs' filesep 'PIPE_status.mat'];
    if exist( StatusFilePath, 'file' )
        try 
            warning('off');
            cmdString = ['load ' StatusFilePath];
            eval(cmdString);
%             cmdString = ['load ' TrackingResultExistInfo];
%             eval(cmdString);
            SubjectQuantity = length(SubjectIDArray);
            JobName = {'dcm2nii_dwi', 'DataParameters'};
            if dti_opt.RawDataResample_Flag
                JobName = [JobName, {'ResampleRawData'}]; 
            end
            if ~strcmp(dti_opt.Inversion, 'No Inversion') & ~strcmp(dti_opt.Swap, 'No Swap')
                JobName = [JobName, {'OrientationPatch'}]; 
            end
            JobName = [JobName, {'extractB0', 'BET_1'}];
            if dti_opt.Cropping_Flag
                JobName = [JobName, {'Split_Crop'}];
            else
                JobName = [JobName, {'Split'}];
            end
            JobName = [JobName, {'EDDYCURRENT', 'average', 'BET_2', 'merge', 'dtifit'}];
            if dti_opt.LDH_Flag
                JobName = [JobName, {'LDH'}];
            end
            if dti_opt.Normalizing_Flag
                JobName = [JobName, {'BeforeNormalize_FA', 'BeforeNormalize_MD', 'BeforeNormalize_L1','BeforeNormalize_L23m',...
                'FAnormalize', 'applywarp_FA_1mm', 'applywarp_MD_1mm', 'applywarp_L1_1mm', 'applywarp_L23m_1mm'}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {'BeforeNormalize_LDHs', 'BeforeNormalize_LDHk', 'applywarp_LDHs_1mm', 'applywarp_LDHk_1mm'}];
                end
            end
            if dti_opt.Resampling_Flag 
                if dti_opt.applywarp_2_ref_fileName ~= 1  
                    JobName = [JobName, {['applywarp_FA_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                end
                if dti_opt.applywarp_4_ref_fileName ~= 1  
                    JobName = [JobName, {['applywarp_MD_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                end
                if dti_opt.applywarp_6_ref_fileName ~= 1
                    JobName = [JobName, {['applywarp_L1_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                end
                if dti_opt.applywarp_8_ref_fileName ~= 1
                    JobName = [JobName, {['applywarp_L23m_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                    if dti_opt.LDH_Flag
                        JobName = [JobName, {['applywarp_LDHs_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                        JobName = [JobName, {['applywarp_LDHk_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm']}];
                    end
                end
            end
            if dti_opt.Smoothing_Flag
                JobName = [JobName, {['smoothNII_FA_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm'], ...
                ['smoothNII_MD_' num2str(dti_opt.applywarp_4_ref_fileName) 'mm'],...
                ['smoothNII_L1_' num2str(dti_opt.applywarp_6_ref_fileName) 'mm'],...
                ['smoothNII_L23m_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm']}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {['smoothNII_LDHs_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm'], ...
                    ['smoothNII_LDHk_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm']}];
                end
            end
            if dti_opt.Atlas_Flag
                JobName = [JobName, {'atlas_FA_1mm', 'atlas_MD_1mm', 'atlas_L1_1mm', 'atlas_L23m_1mm'}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {'atlas_LDHs_1mm', 'atlas_LDHk_1mm'}];
                end
            end
            
            JobName = [JobName, {'delete_tmp_file'}];

            if dti_opt.TBSS_Flag == 1
                JobName = [JobName, {'TBSSDismap', 'skeleton_FA', 'skeleton_MD', 'skeleton_L1', 'skeleton_L23m' ...
                    'skeleton_atlas_FA', 'skeleton_atlas_MD', 'skeleton_atlas_L1', 'skeleton_atlas_L23m'}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {'skeleton_LDHs', 'skeleton_LDHk', 'skeleton_atlas_LDHs', 'skeleton_atlas_LDHk'}];
                end
            end
            if tracking_opt.DterminFiberTracking
                JobName = [JobName, {'DeterministicTracking'}];
            end
            if tracking_opt.NetworkNode && ~tracking_opt.PartitionOfSubjects 
                NetworkNodeJobName = {'CopyT1'};
                if tracking_opt.T1Bet_Flag
                    NetworkNodeJobName = [NetworkNodeJobName, {'BetT1'}];
                end
                if tracking_opt.T1Cropping_Flag
                    NetworkNodeJobName = [NetworkNodeJobName, {'T1Cropped'}];
                end
                if tracking_opt.T1Resample_Flag
                    NetworkNodeJobName = [NetworkNodeJobName, {'T1Resample'}];
                end
                NetworkNodeJobName = [NetworkNodeJobName, {'FAtoT1', 'T1toMNI152', 'Invwarp', 'IndividualParcellated'}];
                JobName = [JobName, NetworkNodeJobName];
            end
            if tracking_opt.DeterministicNetwork == 1
                JobName = [JobName, {'DeterministicNetwork'}];
            end
            if tracking_opt.BedpostxProbabilisticNetwork
                JobName = [JobName, {'BedpostX_preproc'}];
                for BedpostXJobNum = 1:10
                    JobName = [JobName, {['BedpostX_' num2str(BedpostXJobNum, '%02.0f')]}];
                end
                JobName = [JobName, {'BedpostX_postproc', 'ProbabilisticNetworkpre'}];
                ProbabilisticNetworkJobQuantity = min(length(tracking_opt.LabelIdVector), 80);
                for ProbabilisticNetworkJobNum = 1:ProbabilisticNetworkJobQuantity
                    JobName = [JobName, {['ProbabilisticNetwork_' num2str(ProbabilisticNetworkJobNum, '%02d')]}];
                end
                ProbabilisticNetworkPostJobQuantity = min(length(tracking_opt.LabelIdVector), 10);
                for ProbabilisticNetworkPostJobNum = 1:ProbabilisticNetworkPostJobQuantity
                    JobName = [JobName, {['ProbabilisticNetworkpost_' num2str(ProbabilisticNetworkPostJobNum, '%02.0f')]}];
                end
                JobName = [ JobName, {'ProbabilisticNetworkpost_MergeResults'}];
            end
            
            JobName = [JobName, {'ExportParametersToExcel'}];
            if dti_opt.Atlas_Flag | dti_opt.TBSS_Flag
                JobName = [JobName, {'Split_WMLabel', 'Split_WMProbtract'}];
            end
            if dti_opt.Atlas_Flag
                JobName = [JobName, {'ExportAtlasResults_FA_ToExcel', 'ExportAtlasResults_MD_ToExcel', ...
                    'ExportAtlasResults_L1_ToExcel', 'ExportAtlasResults_L23m_ToExcel'}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {'ExportAtlasResults_LDHs_ToExcel', 'ExportAtlasResults_LDHk_ToExcel'}];
                end
            end
            if dti_opt.TBSS_Flag == 1
                JobName = [JobName, {'MergeSkeleton_FA', 'MergeSkeleton_MD', 'MergeSkeleton_L1', 'MergeSkeleton_L23m', ...
                    'ExportAtlasResults_FASkeleton_ToExcel', 'ExportAtlasResults_MDSkeleton_ToExcel', ...
                    'ExportAtlasResults_L1Skeleton_ToExcel', 'ExportAtlasResults_L23mSkeleton_ToExcel'}];
                if dti_opt.LDH_Flag
                    JobName = [JobName, {'MergeSkeleton_LDHs', 'MergeSkeleton_LDHk', ...
                        'ExportAtlasResults_LDHsSkeleton_ToExcel', 'ExportAtlasResults_LDHkSkeleton_ToExcel'}];
                end
            end
            
            JobQuantity = length(JobName);
            SubjectIDArrayString = cell(SubjectQuantity, 1);
            StatusArray = cell(SubjectQuantity, 1);
            JobNameArray = cell(SubjectQuantity, 1);
            JobLeftArray = cell(SubjectQuantity, 1);
            for i = 1:SubjectQuantity 
            % Calculate job status of the ith subject
                RunningJobName = '';
                WaitJobName = '';
                SubmittedJobName = '';
                FailedJobName = '';
                JobLeft = 0;
                StatusArray{i} = 'none';
                SubjectID = SubjectIDArray(i);
                SubjectIDArrayString{i} = num2str(SubjectIDArray(i),'%05.0f');
%                 if tracking_opt.DterminFiberTracking & DeterministicTrackingResultExist(i)
%                     JobQuantity = JobQuantity - 1;
%                 end
                for j = 1:JobQuantity
                    % Check the status of all jobs of the ith subject and  acquire
                    % the status of the subject
                    % The subject has three situations:
                    %     1. 'failed': which job 
                    %     2. 'running': which job
                    %     3. 'submitted': which job
                    %     4. 'wait': which job
                    %     5. 'finished'
%                     if strcmp(JobName{j},'DeterministicTracking')
%                         if DeterministicTrackingResultExist(i)
%                             continue;
%                         end
%                     end
                    
                    if strcmp(JobName{j},'TBSSDismap') | strcmp(JobName{j},'ExportParametersToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_FA_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_MD_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_L1_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_L23m_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_LDHs_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_LDHk_ToExcel') ...
                            | strcmp(JobName{j},'MergeSkeleton_FA') | strcmp(JobName{j},'MergeSkeleton_MD') ...
                            | strcmp(JobName{j},'MergeSkeleton_L1') | strcmp(JobName{j},'MergeSkeleton_L23m') ...
                            | strcmp(JobName{j},'MergeSkeleton_LDHs') | strcmp(JobName{j},'MergeSkeleton_LDHk') ...
                            | strcmp(JobName{j},'ExportAtlasResults_FASkeleton_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_MDSkeleton_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_L1Skeleton_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_L23mSkeleton_ToExcel') ...
                            | strcmp(JobName{j},'ExportAtlasResults_LDHsSkeleton_ToExcel') | strcmp(JobName{j},'ExportAtlasResults_LDHkSkeleton_ToExcel') ...
                            | strcmp(JobName{j},'Split_WMLabel') | strcmp(JobName{j},'Split_WMProbtract')
                        VariableName = JobName{j};
                    else
                        VariableName = [JobName{j} '_' SubjectIDArrayString{i}];
                    end

                    if strcmp(eval(VariableName), 'running')
                        JobLeft = JobLeft + 1;
                        if isempty(RunningJobName)
                            RunningJobName = JobName{j};
                        end
                    elseif strcmp(eval(VariableName), 'submitted')
                        JobLeft = JobLeft + 1;
                        if isempty(SubmittedJobName)
                            SubmittedJobName = JobName{j};
                        end
                    elseif strcmp(eval(VariableName), 'none')
                        JobLeft = JobLeft + 1;
                        if isempty(WaitJobName)
                            WaitJobName = JobName{j};
                        end
                    elseif strcmp(eval(VariableName), 'failed')
                        JobLeft = JobLeft + 1;
                        if isempty(FailedJobName)
                            FailedJobName = JobName{j};
                        end
                    end
                end  
                if isempty(RunningJobName) & isempty(SubmittedJobName) ...
                        & isempty(WaitJobName) & isempty(FailedJobName)
                    StatusArray{i} = 'finished';
                    JobNameArray{i} = '';
                    JobLeftArray{i} = '0';
                elseif ~isempty(RunningJobName)
                    StatusArray{i} = 'running';
                    JobNameArray{i} = RunningJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                elseif ~isempty(SubmittedJobName)
                    StatusArray{i} = 'submitted';
                    JobNameArray{i} = SubmittedJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                elseif ~isempty(FailedJobName)
                    StatusArray{i} = 'failed';
                    JobNameArray{i} = FailedJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                elseif ~isempty(WaitJobName)
                    StatusArray{i} = 'wait';
                    JobNameArray{i} = WaitJobName;
                    JobLeftArray{i} = num2str(JobLeft);
                end
            end
            save([DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'], 'SubjectIDArrayString', 'StatusArray', 'JobNameArray', 'JobLeftArray');
            if nargin >= 5
                if ~LockFlag
                    pause(2);
                    if exist([DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'], 'file')
                        break;
                    end
                end
            end
            warning('on');
        catch err
            if ErrMsgQuantity == 0
                clc;
                disp(err.message);
                for e=1:length(err.stack)
                    fprintf('%s in %s at %i\n',err.stack(e).name,err.stack(e).file,err.stack(e).line);
                end
                none = 1;
                ErrMsgQuantity = ErrMsgQuantity + 1;
            end
        end
    end
end

