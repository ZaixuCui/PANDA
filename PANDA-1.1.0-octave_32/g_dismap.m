function g_dismap( FA_normalized_1mm_cell, saving_directory, threshold )
%
%__________________________________________________________________________
% SUMMARY OF G_DISMAP
% 
% Generate FA skeleton distance map
%
% SYNTAX:
% 
% 1) g_dismap( FA_normalized_1mm_cell, saving_directory, threshold )
%__________________________________________________________________________
% INPUTS:
%
% FA_NORMALIZED_1MM_CELL
%       (cell of strings)
%       The input cell, each of which is FA in the standard space with the
%       resolution of 1*1*1
%
% SAVING_DIRECTORY
%       (string)
%       The full path of the folder storing resultant files.
%       
% THRESHOLD
%       (float, default 0.2) 
%       FA threshold to exclude voxels in the grey matter or CSF.
%       Please reference:http://www.fmrib.ox.ac.uk/fsl/tbss/index.html
%__________________________________________________________________________
% OUTPUTS:
%
% Mean FA, mean FA skeleton, FA skeleton distance map, etc.
% See g_dismap_FileOut.m.
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
% See licensing information in the code
% keywords: fslmaths, tbss_skeleton, distancemap
% Please report bugs or requests to:
%   Zaixu Cui:         <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%   Suyu Zhong:        <a href="suyu.zhong@gmail.com">suyu.zhong@gmail.com</a>
%   Gaolang Gong (PI): <a href="gaolang.gong@gmail.com">gaolang.gong@gmail.com</a>

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

%% this is to generate the distance map for TBSS projection by using all FA images of your group
if ~exist([saving_directory filesep 'TBSS'])
    mkdir([saving_directory filesep 'TBSS']);
end
saving_directory = [saving_directory filesep 'TBSS'];
mean_FA=cat(2, saving_directory, filesep, 'mean_FA');
mean_FA_mask=cat(2, mean_FA, '_mask');
mean_FA_skeleton=cat(2, mean_FA, '_skeleton');
mean_FA_skeleton_mask=cat(2, mean_FA, '_skeleton_mask');
mean_FA_skeleton_mask_dst=cat(2, mean_FA, '_skeleton_mask_dst');

%% generate mean FA
disp('averaging the FA images...');
num_subjects=length(FA_normalized_1mm_cell);
cmd1=cat(2, 'fslmaths ',FA_normalized_1mm_cell{1});
cmd2=cat(2, 'fslmaths ',FA_normalized_1mm_cell{1});
for i=2:num_subjects
    cmd1=cat(2, cmd1,' -add ',FA_normalized_1mm_cell{i});
    cmd2=cat(2, cmd2,' -mas ',FA_normalized_1mm_cell{i});
end
cmd1=cat(2, cmd1, ' -div ', num2str(num_subjects), ' ', mean_FA);
disp(cmd1);
system(cmd1);

%% generate FA mask
disp('masking the FA images...');
cmd2=cat(2, cmd2,  ' -bin ', mean_FA_mask);
disp(cmd2);
system(cmd2);

%% generate FA skeleton
disp('generating the mean_FA_skeleton...');
cmd3=cat(2, 'tbss_skeleton -i ', mean_FA,  ' -o ', mean_FA_skeleton);
disp(cmd3);
system(cmd3);

%% generate binaried FA skeleton
disp('generating mean_FA_skeleton_mask ...');
cmd4=cat(2, 'fslmaths ', mean_FA_skeleton,  ' -thr ', num2str(threshold), ' -bin ', mean_FA_skeleton_mask);
disp(cmd4);
system(cmd4);

%% generate intermediate distance map
disp('generating mean_FA_skeleton_mask_dst ...');
cmd5=cat(2, 'fslmaths ', mean_FA_mask, ' -mul -1 -add 1 -add ', mean_FA_skeleton_mask, ' ', mean_FA_skeleton_mask_dst);
disp(cmd5);
system(cmd5);

%% generate final distance map
disp('re-generating mean_FA_skeleton_mask_dst ...');
cmd6=cat(2, 'distancemap -i ', mean_FA_skeleton_mask_dst,' -o ', mean_FA_skeleton_mask_dst);
disp(cmd6);
system(cmd6);
