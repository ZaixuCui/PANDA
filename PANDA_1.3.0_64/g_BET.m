
function g_BET( Raw_FileName,f,JobName )
%
%__________________________________________________________________________
% SUMMARY OF G_BET
% 
% Delete non-brain tissue from an image of the whole head
%
% SYNTAX:
%
% 1) g_BET( Raw_FileName )
% 2) g_BET( Raw_FileName, f )
% 3) g_BET( Raw_FileName, f, JobName )
%__________________________________________________________________________
% INPUTS:
%
% RAW_FILENAME
%        (string) 
%        The full path of the NIfTI data.
%        For example: '/data/Handled_Data/001/data_b0.nii.gz'
%
% F
%        (single, default 0.25) 
%        Fractional intensity threshold (0->1); smaller values give larger 
%        brain outline estimates.
%
% JOBNAME
%        (string) the name of the job which call the command this time.It
%        is determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
% See g_BET_..._FileOut.m file         
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
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

if nargin < 2
    f = 0.25;
end

% In pipeline, data_b0.nii.gz is under 'tmp' file
[a,~,~] = fileparts(Raw_FileName);
[a,~,~] = fileparts(a); 
NativeFolder = [ a filesep 'native_space'];
if ~exist(NativeFolder)
    mkdir(NativeFolder);
end
output_base = cat(2, NativeFolder, filesep, 'nodif_brain');
cmd = cat(2, 'bet ', Raw_FileName, ' ', output_base, ' -f ', num2str(f), ' -m -n -R');
disp(cmd);
system(cmd);

if nargin == 3
    cmd = ['touch ' a filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end