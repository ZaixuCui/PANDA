function g_FAtoT1( fileName_FA, fileName_T1_bet )
%
%__________________________________________________________________________
% SUMMARY OF G_FATOT1
% 
% Register FA image to T1 image.
%
% SYNTAX:
%
% 1) g_FAtoT1( fileName_FA, fileName_T1_bet )
%__________________________________________________________________________
% INPUTS:
%
% FILENAME_FA
%        (string) 
%        The full path of the FA image to be registered.
%
% FILENAME_T1_BET
%        (string) 
%        The full path of T1 image after brain extraction.
%__________________________________________________________________________
% OUTPUTS:
%
% The FA image registered to T1 image, and the slice pictures of
% registering.
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: flirt, convert_xfm, slicesdir

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

[NativeFolder, FAFileName, FASuffix] = fileparts(fileName_FA); 
[SubjectFolder, b, c] = fileparts(NativeFolder);
[fileName_T1_bet_parent, T1FileName, T1Suffix] = fileparts(fileName_T1_bet);
if strcmp(FASuffix, '.gz')
    FAtoT1_mat = [fileName_T1_bet_parent filesep FAFileName(1:end-4) '_2T1.mat'];
    FAtoT1_img = [fileName_T1_bet_parent filesep FAFileName(1:end-4) '_2T1'];
elseif strcmp(FASuffix, '.nii');
    FAtoT1_mat = [fileName_T1_bet_parent filesep FAFileName '_2T1.mat'];
    FAtoT1_img = [fileName_T1_bet_parent filesep FAFileName '_2T1'];
else
    error('not a NIFTI file')
end

if strcmp(T1Suffix, '.gz')
    T1toFA_mat = [fileName_T1_bet_parent filesep T1FileName(1:end-4) '_2FA.mat'];
elseif strcmp(T1Suffix, '.nii');
    T1toFA_mat = [fileName_T1_bet_parent filesep T1FileName '_2FA.mat'];
else
    error('not a NIFTI file')
end

command = ['flirt -in ' fileName_FA ' -ref ' fileName_T1_bet ' -cost corratio -dof 12 -o ' FAtoT1_img ' -omat ' FAtoT1_mat ...
          ' && convert_xfm -omat ' T1toFA_mat ' -inverse ' FAtoT1_mat];
disp(command);
system(command);

% Quality control for FA_2T1
% 'FAtoT1_img' doesn't contain '.nii.gz' or '.nii'
FAtoT1Slicesdir = [SubjectFolder filesep 'quality_control' filesep 'FA_to_T1'];
if ~exist(FAtoT1Slicesdir, 'dir')
    mkdir(FAtoT1Slicesdir);
end 
system(['cd ' FAtoT1Slicesdir ' && slicesdir -o ' FAtoT1_img ' ' fileName_T1_bet]);

