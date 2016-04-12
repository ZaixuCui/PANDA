
function g_merge( DataNii_folder,files_in,Prefix,MaskFile )
%
%__________________________________________________________________________
% SUMMARY OF G_MERGE
% 
% Concatenate images of different runs in gradient directions.
%
% SYNTAX:
% 
% 1) g_merge( DataNii_folder,files_in,Prefix,MaskFile )
%__________________________________________________________________________
% INPUTS:
%
% DATANII_FOLDER
%        (string) 
%        The full path of the NIfTI data
%        For example: '/data/Handled_Data/001/'
%
% FILES_IN
%        (string) 
%        The full path of a .mat file which store three variables
%        'VolumePerSequence' 
%        VolumePerSequence:
%                 (integer)
%                 the quantity of volume for one scan 
%
% PREFIX
%       (string)
%       The prefix of the file name.
%
% MASKFILE
%       (string) 
%       The full path of the brain mask.
%__________________________________________________________________________
% OUTPUTS:
%         
% See g_merge_FileOut.m file
%__________________________________________________________________________
% COMMENTS:
%
% All image dimensions(except for the one being concatenated over) must be 
% the same in all input images.
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% See licensing information in the code
% keywords: fslmerge
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

load(files_in);

for i = 1:VolumePerSequence 
    VolumeAverage{i} = [DataNii_folder filesep 'tmp' filesep Prefix '_DWI_' num2str(i - 1,'%04.0f') '_average.nii.gz'];
end

VolumeAvergeMerge = [DataNii_folder filesep 'native_space' filesep 'data.nii.gz'];
cmd = ['fslmaths ' VolumeAverage{1} ' -mul ' MaskFile ' ' VolumeAverage{1}];
system(cmd);
system(['cp ' VolumeAverage{1} ' ' VolumeAvergeMerge]);
for i = 2:VolumePerSequence 
    cmd = ['fslmaths ' VolumeAverage{i} ' -mul ' MaskFile ' ' VolumeAverage{i}];
    system(cmd);
    cmd = ['fslmerge -t ' VolumeAvergeMerge  ' ' VolumeAvergeMerge ' ' VolumeAverage{i}];
    system(cmd);
end

% Rename bvecs_average as bvecs
system(['cp ' DataNii_folder filesep 'tmp' filesep Prefix '_bvecs_average ' DataNii_folder filesep 'native_space' filesep 'bvecs']);
% Rename bvals_average as bvals
system(['cp ' DataNii_folder filesep 'tmp' filesep Prefix '_bvals_average ' DataNii_folder filesep 'native_space' filesep 'bvals']);


