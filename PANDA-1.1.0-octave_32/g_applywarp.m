
function g_applywarp( raw_file,warp_file,resolution,target_fileName )
%
%__________________________________________________________________________
% SUMMARY OF G_APPLYWARP
% 
% Apply the warps estimated by fnirt to some images.
%
% SYNTAX:
%
% 1) g_applywarp( raw_file,warp_file )
% 2) g_applywarp( raw_file,warp_file,resolution )
% 3) g_applywarp( raw_file,warp_file,resolution,JobName )
% 4) g_applywarp( raw_file,warp_file,resolution,JobName,target_fileName )
%__________________________________________________________________________
% INPUTS:
%
% RAW_FILE
%        (string) 
%        The full path of the NIfTI data to be written to standard space.
%        For example: '/data/Handled_Data/001/001_FA.nii.gz'
%
% WARP_FILE
%        (string) 
%        The full path of warps estimated by fnirt
%        For example:
%        '/data/Handled_Data/001/001_FA_4normalize_to_target_warp.nii.gz'
%
% resolution
%        (integer: 1 or 2)
%        The final resolution of the normalized data.
%        1: 'FMRIB58_FA_1mm.nii.gz' as reference
%            i.e. resampling the data at 1x1x1mm resolution in MNI space
%        2: 'MNI152_T1_2mm.nii.gz' as reference
%            i.e. resampling the data at 2x2x2mm resolution in MNI space
%
% TARGET_FILENAME
%        (string)
%        For quanlity control of registering.
%__________________________________________________________________________
% OUTPUTS:
%
% Data in the standard space with a certain resolution.
% See g_applywarp_..._FileOut.m file.        
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
% keywords: applywarp
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
global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));

if nargin < 3
    resolution = 1;
end 

if resolution == 1
    ref_fileName = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
    Suffix = '1mm';
elseif resolution == 2
    ref_fileName = [PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm.nii.gz'];
    Suffix = '2mm';
end

[a,b,c] = fileparts(raw_file);
[SubjectFolder,b,c] = fileparts(a);
if strcmp(raw_file(end-6:end), '.nii.gz')
    [a,b,c] = fileparts(raw_file);
    outputfile = cat(2, SubjectFolder, filesep, 'standard_space', filesep, b(1:end - 4), '_to_target_', Suffix);
elseif strcmp(raw_file(end-3:end), '.nii');
    [a,b,c] = fileparts(raw_file);
    outputfile = cat(2, SubjectFolder, filesep, 'standard_space', filesep, b, '_to_target_', Suffix);
else
    error('not a NIFTI file');
end
disp(SubjectFolder);
disp(outputfile);

cmd = cat(2, 'applywarp -i ', raw_file, ' -o ', outputfile, ' -r ', ref_fileName, ' -w ', warp_file, ' --rel');
disp(cmd);
system(cmd);

if nargin == 4
    FANormalized1mmSlicedir = [SubjectFolder filesep 'quality_control' filesep 'FA_Normalized_1mm'];
    if ~exist(FANormalized1mmSlicedir, 'dir')
        mkdir(FANormalized1mmSlicedir);
    end
    system(cat(2,'cd ', FANormalized1mmSlicedir, ' && slicesdir -o ', outputfile, ' ', target_fileName));
end



