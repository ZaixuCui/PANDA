
function g_extractB0( DWI_FileName,reference,JobName)
%
%__________________________________________________________________________
% SUMMARY OF G_EXTRACTB0
% 
% Extract a volume on a gradient direction from an 4D image.
% Default: extract b0 volume from an 4D image.
%
% SYNTAX:
%
% 1) g_extractB0( DWI_FileName )
% 2) g_extractB0( DWI_FileName,reference )
% 3) g_extractB0( DWI_FileName,reference,JobName)
%__________________________________________________________________________
% INPUTS:
%
% DWI_FILENAME
%        (string) 
%        The full path of the NIfTI data.
%        For example: '/data/Handled_Data/001/DWI.nii'
%
% REFERENCE
%        (integer, default 0)
%        The start index of your ROI in time.
%
% JOBNAME
%        (string) 
%        The name of the job which call the command this time.It is 
%        determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
% See g_extractB0_..._FileOut.m file         
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslroi, b0

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
    reference = 0;
end

[a,b,c] = fileparts(DWI_FileName);
saved_b0_FileName = [ a filesep 'data_b0.nii.gz'];
cmd = cat(2, 'fslroi ', DWI_FileName, ' ', saved_b0_FileName , ' ', num2str(reference), ' 1');
disp(cmd);
system(cmd);

disp(cat(2, 'extracting b0 volume is done!'));
if nargin == 3
    cmd = ['touch ' a(1:end - 4) filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end
