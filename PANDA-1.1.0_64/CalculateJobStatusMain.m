function CalculateJobStatusMain( DestinationPath_Edit, SubjectIDArray, dti_opt, tracking_opt, LockFlag )
% Calculate job status for PANDA, by Zaixu Cui 
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  <a href="zaixucui@gmail.com">Zaixu Cui</a>
%   Version 1.1.0;
%   Date 
%   Last edited 
%--------------------------------------------------------------------------
MonitorTagPath = [DestinationPath_Edit filesep 'logs' filesep 'Monitor_Tag'];
ErrMsgQuantity = 0;
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
            SubjectQuantity = length(SubjectIDArray);
            JobName = {'dcm2nii_dwi', 'extractB0', 'BET_1', 'NIIcrop', ...
                       'EDDYCURRENT', 'average', 'merge',  'BET_2', 'dtifit', ...
                       'FA_BeforeNormalize', 'MD_BeforeNormalize', 'L1_BeforeNormalize', ...
                       'L23m_BeforeNormalize', 'FAnormalize', 'applywarp_FA_1mm', ...
                       'applywarp_MD_1mm', 'applywarp_L1_1mm', 'applywarp_L23m_1mm'};
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
            end
            JobName = [JobName, {['smoothNII_FA_' num2str(dti_opt.applywarp_2_ref_fileName) 'mm'], ...
                       ['smoothNII_MD_' num2str(dti_opt.applywarp_4_ref_fileName) 'mm'],...
                       ['smoothNII_L1_' num2str(dti_opt.applywarp_6_ref_fileName) 'mm'],...
                       ['smoothNII_L23m_' num2str(dti_opt.applywarp_8_ref_fileName) 'mm'], ... 
                       'atlas_FA_1mm', 'atlas_MD_1mm', 'atlas_L1_1mm', 'atlas_L23m_1mm', 'delete_tmp_file'}];
            TBSSJobName = {'TBSSDismap', 'skeleton_FA', 'skeleton_MD', 'skeleton_L1',...
                       'skeleton_L23m'};   
            if dti_opt.TBSS_Flag == 1
                JobName = [JobName, TBSSJobName];
            end
            if tracking_opt.DterminFiberTracking
                TrackingJobName = {'DeterministicTracking'};
                JobName = [JobName, TrackingJobName];
            end
            if tracking_opt.NetworkNode && ~tracking_opt.PartitionOfSubjects 
                NetworkNodeJobName = {'PartitionTemplate2FA'};
                JobName = [JobName, NetworkNodeJobName];
            end
            if tracking_opt.DeterministicNetwork == 1
                DeterministicNetworkJobName = {'FiberNumMatrix'};
                JobName = [JobName, DeterministicNetworkJobName];
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
                for j = 1:JobQuantity
                    % Check the status of all jobs of the ith subject and  acquire
                    % the status of the subject
                    % The subject has three situations:
                    %     1. 'failed': which job 
                    %     2. 'running': which job
                    %     3. 'submitted': which job
                    %     4. 'wait': which job
                    %     5. 'finished'
                    if strcmp(JobName{j},'TBSSDismap')
                        VariableName = JobName{j};
                    else
                        VariableName = [JobName{j} '_' SubjectIDArrayString{i}];
                    end

                    if strcmp(eval(VariableName), 'running')
                        if isempty(RunningJobName)
                            RunningJobName = JobName{j};
                        end
                    elseif strcmp(eval(VariableName), 'submitted')
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
                % If all jobs have been finished, and the probabilistic
                % network is selected, then we will check the status of
                % probabilistic network
%                 disp(JobLeftArray{i});
%                 if ~strcmp(StatusArray{i}, 'finished') & ~strcmp(StatusArray{i}, 'failed') & tracking_opt.BedpostxProbabilisticNetwork
%                     JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 2);
%                 else
                if tracking_opt.BedpostxProbabilisticNetwork
                     if strcmp(StatusArray{i}, 'finished') | strcmp(StatusArray{i}, 'failed')
                        % Status of Bedpostx
                        BedpostxJobName{1} = [ 'BedpostX_preproc_' SubjectIDArrayString{i} ];
                        BedpostXPreStatus = eval(BedpostxJobName{1});
                        for BedpostXJobNum = 1:10
                            BedpostxJobName{BedpostXJobNum + 1} = [ 'BedpostX_' SubjectIDArrayString{i} '_' num2str(BedpostXJobNum, '%02.0f') ];
                            BedpostXJobStatus{BedpostXJobNum} = eval(BedpostxJobName{BedpostXJobNum + 1});
                        end
                        BedpostxJobName{12} = [ 'BedpostX_postproc_' SubjectIDArrayString{i} ];
                        BedpostXPostStatus = eval(BedpostxJobName{12});
                        if strcmp(BedpostXPreStatus, 'none')
                            StatusArray{i} = 'wait';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 2);
                            JobNameArray{i} = 'BedpostX';
                        elseif strcmp(BedpostXPreStatus, 'submitted')
                            StatusArray{i} = 'submitted';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif strcmp(BedpostXPreStatus, 'running') 
                            StatusArray{i} = 'running';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif strcmp(BedpostXPostStatus, 'submitted')
                            StatusArray{i} = 'running';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif strcmp(BedpostXPostStatus, 'running')
                            StatusArray{i} = 'running';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif strcmp(BedpostXPostStatus, 'finished') %& ~strcmp(StatusArray{i}, 'failed')
                            % If Bedpostx is finished, we should check
                            % probabilistic network status
                            % Status of Probabilistic Fiber Tracking
                            ProbabilisticNetworkJobName{1} = ['ProbabilisticNetworkpre_' SubjectIDArrayString{i}];
                            ProbabilisticNetworkPreStatus = eval(ProbabilisticNetworkJobName{1});
                            for ProbabilisticNetworkNum = 1:length(tracking_opt.LabelIdVector)
                                ProbabilisticNetworkJobName{ProbabilisticNetworkNum + 1} = ['ProbabilisticNetwork_' SubjectIDArrayString{i} '_' num2str(ProbabilisticNetworkNum, '%02d')];
                                ProbabilisticNetworkJobStatus{ProbabilisticNetworkNum} = eval(ProbabilisticNetworkJobName{ProbabilisticNetworkNum + 1});
                            end
                            ProbabilisticNetworkPostJobName{ProbabilisticNetworkNum + 2} = [ 'ProbabilisticNetworkpost_' SubjectIDArrayString{i} ];
                            ProbabilisticNetworkPostStatus = eval(ProbabilisticNetworkPostJobName{ProbabilisticNetworkNum + 2});
                            if strcmp(ProbabilisticNetworkPreStatus, 'none')
                                StatusArray{i} = 'wait';
                                JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif  strcmp(ProbabilisticNetworkPreStatus, 'submitted')
                                StatusArray{i} = 'submitted';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif  strcmp(ProbabilisticNetworkPreStatus, 'running') 
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif strcmp(ProbabilisticNetworkPostStatus, 'none')
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif strcmp(ProbabilisticNetworkPostStatus, 'submitted')
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif strcmp(ProbabilisticNetworkPostStatus, 'running')
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif strcmp(ProbabilisticNetworkPostStatus, 'finished') & ~strcmp(StatusArray{i}, 'failed')
                                StatusArray{i} = 'finished';
                                JobNameArray{i} = '';
                            elseif length(cell2mat(strfind(ProbabilisticNetworkJobStatus, 'submitted')))
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif length(cell2mat(strfind(ProbabilisticNetworkJobStatus, 'running')))
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif length(cell2mat(strfind(ProbabilisticNetworkJobStatus, 'none'))) 
                                StatusArray{i} = 'running';
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            elseif length(cell2mat(strfind(ProbabilisticNetworkJobStatus, 'failed')))  & ~strcmp(StatusArray{i}, 'failed')
                                StatusArray{i} = 'failed';
                                JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                                JobNameArray{i} = 'ProbabilisticNetwork';
                            end
                        elseif length(cell2mat(strfind(BedpostXJobStatus, 'running'))) 
                            StatusArray{i} = 'running';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif length(cell2mat(strfind(BedpostXJobStatus, 'submitted'))) 
                            StatusArray{i} = 'running';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif length(cell2mat(strfind(BedpostXJobStatus, 'none')))
                            StatusArray{i} = 'running';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                            JobNameArray{i} = 'BedpostX';
                        elseif ~strcmp(StatusArray{i}, 'failed')
                            % If bedpostx fail and other jobs also failed,
                            % we will display other jobs
                            StatusArray{i} = 'failed';
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 2);
                            JobNameArray{i} = 'BedpostX';
                        end    
                     else
                        BedpostxPostJob = [ 'BedpostX_postproc_' SubjectIDArrayString{i} ];
                        BedpostXPostStatus = eval(BedpostxPostJob);
                        ProbabilisticNetworkPostJob = [ 'ProbabilisticNetworkpost_' SubjectIDArrayString{i} ];
                        ProbabilisticNetworkPostStatus = eval(ProbabilisticNetworkPostJob);
                        if ~strcmp(BedpostxPostJob, 'finished')
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 2);
                        elseif ~strcmp(ProbabilisticNetworkPostStatus, 'finished')
                            JobLeftArray{i} = num2str(str2num(JobLeftArray{i}) + 1);
                        end
                     end
                end
            end
            save([DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'], 'SubjectIDArrayString', 'StatusArray', 'JobNameArray', 'JobLeftArray');
            if nargin >= 5
                if ~LockFlag
                    pause(2);
                    if exist([DestinationPath_Edit filesep 'logs' filesep 'StatusTable.mat'])
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

