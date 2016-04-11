
function g_PartitionTemplate2FA(fileName_FA, fileName_T1_bet, PartitionTemplateFilename, JobName)
%
%__________________________________________________________________________
% SUMMARY OF G_TRACKING
% 
% Employing the partition template to parcellate the brain into 90 regions
%
% SYNTAX:
% G_PartitionTemplate2FA( FILENAME_FA, FILENAME_T1_BET, PartitionTemplateFilename, JOBNAME )
%__________________________________________________________________________
% INPUTS:
%
% FILENAME_FA
%       (string)
%       path of FA file 
%
% FILENAME_T1_BET
%       (string)
%       path of T1 file
%
% PartitionTemplateFilename
%       (string)
%       path of partition template
%
% JOBNAME
%        (string) the name of the job which call the command this time.It
%        is determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
%__________________________________________________________________________
% USAGE:
%
%        1) g_PartitionTemplate2FA( fileName_FA, fileName_T1_bet, PartitionTemplateFilename )
%        2) g_PartitionTemplate2FA( fileName_FA, fileName_T1_bet, PartitionTemplateFilename, JobName )
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
% keywords: partition template, FA, T1

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

[NativeFolder, FAFileName, z] = fileparts(fileName_FA); 
[SubjectFolder, b, c] = fileparts(NativeFolder);
if strcmp(fileName_FA(end-6:end), '.nii.gz')
    FAtoT1_mat = [NativeFolder filesep FAFileName(1:end-4) '_2T1.mat'];
    FAtoT1_img = [NativeFolder filesep FAFileName(1:end-4) '_2T1'];
    [a, PartitionTemplateNamePrefix, Suffix] = fileparts(PartitionTemplateFilename);
    if strcmp(Suffix, '.gz')
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName(1:end-4) '_Parcellated_' PartitionTemplateNamePrefix(1:end-4)];
    elseif strcmp(Suffix, '.nii') | isempty(Suffix)
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName(1:end-4) '_Parcellated_' PartitionTemplateNamePrefix];
    end
elseif strcmp(fileName_FA(end-3:end), '.nii');
    FAtoT1_mat = [NativeFolder filesep FAFileName '_2T1.mat'];
    FAtoT1_img = [NativeFolder filesep FAFileName '_2T1'];
    [a, PartitionTemplateNamePrefix, Suffix] = fileparts(PartitionTemplateFilename);
    if strcmp(Suffix, '.gz')
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateNamePrefix(1:end-4)];
    elseif strcmp(Suffix, '.nii') | isempty(Suffix)
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateNamePrefix];
    end
else
    error('not a NIFTI file')
end

[fileName_T1_bet_parent, T1FileName, Suffix] = fileparts(fileName_T1_bet);
if ~exist([NativeFolder filesep T1FileName Suffix], 'file')
    copyfile(fileName_T1_bet, NativeFolder);
end

%Copy T1 to native folder, so the log file for T1 will be in the native foler
NewT1Name_bet = [NativeFolder filesep T1FileName Suffix]; 
if strcmp(fileName_T1_bet(end-6:end), '.nii.gz')
    T1toFA_mat = [NativeFolder filesep T1FileName(1:end-4) '_2FA.mat'];
    T1toMNI152 = [NativeFolder filesep T1FileName(1:end-4) '_2MNI152'];
    T1toMNI152_warp = [NativeFolder filesep T1FileName(1:end-4) '_2MNI152_warp'];
    T1toMNI152_warp_inv = [NativeFolder filesep T1FileName(1:end-4) '_2MNI152_warp_inv'];
elseif strcmp(fileName_T1_bet(end-3:end), '.nii');
    T1toFA_mat = [NativeFolder filesep T1FileName '_2FA.mat'];
    T1toMNI152 = [NativeFolder filesep T1FileName '_2MNI152'];
    T1toMNI152_warp = [NativeFolder filesep T1FileName '_2MNI152_warp'];
    T1toMNI152_warp_inv = [NativeFolder filesep T1FileName '_2MNI152_warp_inv'];
else
    error('not a NIFTI file')
end

command = cat(2,'flirt -in ', fileName_FA, ' -ref ',NewT1Name_bet, ' -cost corratio -dof 12 -o ',FAtoT1_img,' -omat ', FAtoT1_mat);
disp(command);
system(command);

command = cat(2,'convert_xfm -omat ', T1toFA_mat, ' -inverse ', FAtoT1_mat);
disp(command);
system(command);

command = cat(2,'fsl_reg ', NewT1Name_bet, ' ', PANDAPath, filesep, 'data', filesep, 'Templates', filesep, 'MNI152_T1_2mm_brain ', T1toMNI152);
disp(command);
system(command);

command = cat(2,'invwarp -w ', T1toMNI152_warp, ' -r ', NewT1Name_bet, ' -o ', T1toMNI152_warp_inv);
disp(command);
system(command);

if nargin == 2
    PartitionTemplateFilename = [PANDAPath filesep 'data' filesep 'atlases' filesep 'AAL' filesep 'AAL_116_2MM'];
end
command = cat(2,'applywarp -i ', PartitionTemplateFilename, ' -o ', T1toFA_PartitionTemplate, ' -r ',fileName_FA,' -w ',...
          T1toMNI152_warp_inv, ' --postmat=', T1toFA_mat, ' --interp=nn');
disp(command);
system(command);

if strcmp(NewT1Name_bet(end-6:end), '.nii.gz')
    filename_FA_binarise = [NewT1Name_bet(end-6:end) '_bin.nii.gz'];
elseif strcmp(NewT1Name_bet(end-3:end), '.nii')
    filename_FA_binarise = [NewT1Name_bet(end-3:end) '_bin.nii'];
end
system(['fslmaths ' fileName_FA ' -bin ' filename_FA_binarise]);
system(['fslmaths ' T1toFA_PartitionTemplate ' -mul ' filename_FA_binarise ' ' T1toFA_PartitionTemplate]);

% Quantity control for T1
T1Slicerdir = [SubjectFolder filesep 'quality_control' filesep 'T1'];
if ~exist(T1Slicerdir, 'dir')
    mkdir(T1Slicerdir);
end 
[a, T1name, c] = fileparts(NewT1Name_bet); 
if strcmp(NewT1Name_bet(end-6:end), '.nii.gz')
    system(['slicer ' NewT1Name_bet ' -a ' T1Slicerdir filesep T1name(1:end-4) '_QC.png']);
elseif strcmp(NewT1Name_bet(end-3:end), '.nii')
    system(['slicer ' NewT1Name_bet ' -a ' T1Slicerdir filesep T1name '_QC.png']);
end
% Quantity control for FA_2T1
% 'FAtoT1_img' doesn't contain '.nii.gz' or '.nii'
FAtoT1Slicesdir = [SubjectFolder filesep 'quality_control' filesep 'FA_to_T1'];
if ~exist(FAtoT1Slicesdir, 'dir')
    mkdir(FAtoT1Slicesdir);
end 
system(['cd ' FAtoT1Slicesdir ' && slicesdir -o ' FAtoT1_img ' ' NewT1Name_bet]);
% Quantity control for T1_2MNI152
% 'T1toMNI152_warp' doesn't contain '.nii.gz' or '.nii'
T1toMNI152Slicesdir = [SubjectFolder filesep 'quality_control' filesep 'T1_to_MNI152'];
if ~exist(T1toMNI152Slicesdir, 'dir')
    mkdir(T1toMNI152Slicesdir);
end
system(['cd ' T1toMNI152Slicesdir ' && slicesdir -o ' T1toMNI152 ' ' PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain']);

if nargin == 4
    cmd = ['touch ' SubjectFolder filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end







