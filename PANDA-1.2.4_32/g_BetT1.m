function g_BetT1( T1FilePath, f )
%
%__________________________________________________________________________
% SUMMARY OF G_BETT1
% 
% Delete non-brain tissue from T1 image of the whole head.
%
% SYNTAX:
%
% 1) g_BetT1( T1FilePath, f )
%__________________________________________________________________________
% INPUTS:
% 
% T1FILEPATH
%        (string)
%        The full path of T1 NIfTI image.
%
% F
%        (single, default 0.25) 
%        Fractional intensity threshold (0->1); smaller values give larger 
%        brain outline estimates.
%__________________________________________________________________________
% OUTPUTS:
%
% The brain after brain extraction and the brain mask.    
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
% keywords: bet

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

if nargin <= 1
    f = 0.5;
end

[T1ParentFolder, T1FileName, Suffix] = fileparts(T1FilePath);
if strcmp(Suffix, '.gz')
    Data_Swap = [T1ParentFolder filesep T1FileName(1:end - 4) '_swap.nii.gz'];
    Data_Swap_Bet = [T1ParentFolder filesep T1FileName(1:end - 4) '_swap_bet.nii.gz'];
elseif strcmp(Suffix, '.nii')
    Data_Swap = [T1ParentFolder filesep T1FileName '_swap.nii.gz'];
    Data_Swap_Bet = [T1ParentFolder filesep T1FileName '_swap_bet.nii.gz'];
else
    error('Not a NIFTI file.');
end
cmd = ['fslswapdim ' T1FilePath ' RL PA IS ' Data_Swap ' && bet ' Data_Swap ' ' Data_Swap_Bet ' -f ' num2str(f) ' -R'];
disp(cmd);
system(cmd);

cmd = ['rm ' T1ParentFolder filesep '*.nii'];
system(cmd);




    

