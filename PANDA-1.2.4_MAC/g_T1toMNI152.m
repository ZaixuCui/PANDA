function g_T1toMNI152( T1FilePath )
%
%__________________________________________________________________________
% SUMMARY OF G_T1TOMNI152
% 
% Register T1 image to MNI152 space.
%
% SYNTAX:
%
% 1) g_T1toMNI152( T1FilePath )
%__________________________________________________________________________
% INPUTS:
%
% T1FILEPATH
%        (string) 
%        The full path of the T1 image to be registered.
%__________________________________________________________________________
% OUTPUTS:
%
% The T1 image registered to MNI152 space, and the slice pictures of
% registering.
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fsl_reg, slicesdir

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

[T1ParentFolder, T1FileName, T1Suffix] = fileparts(T1FilePath);
[SubjectFolder, b, c] = fileparts(T1ParentFolder);
if strcmp(T1Suffix, '.gz')
    T1toMNI152 = [T1ParentFolder filesep T1FileName(1:end-4) '_2MNI152'];
    T1toMNI152_warp = [T1ParentFolder filesep T1FileName(1:end-4) '_2MNI152_warp'];
elseif strcmp(T1Suffix, '.nii')
    T1toMNI152 = [T1ParentFolder filesep T1FileName '_2MNI152'];
    T1toMNI152_warp = [T1ParentFolder filesep T1FileName '_2MNI152_warp'];
else
    error('not a NIFTI file')
end

command = cat(2,'fsl_reg ', T1FilePath, ' ', PANDAPath, filesep, 'data', filesep, 'Templates', filesep, 'MNI152_T1_2mm_brain ', T1toMNI152);
disp(command);
system(command);

% Quality control for T1_2MNI152
% 'T1toMNI152_warp' doesn't contain '.nii.gz' or '.nii'
T1toMNI152Slicesdir = [SubjectFolder filesep 'quality_control' filesep 'T1_to_MNI152'];
if ~exist(T1toMNI152Slicesdir, 'dir')
    mkdir(T1toMNI152Slicesdir);
end
system(['cd ' T1toMNI152Slicesdir ' && slicesdir -o ' T1toMNI152 ' ' PANDAPath filesep 'data' filesep 'Templates' filesep 'MNI152_T1_2mm_brain']);