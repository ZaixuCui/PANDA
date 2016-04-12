function g_Invwarp( WarpVolume, ReferenceVolume )
%
%__________________________________________________________________________
% SUMMARY OF G_INVWARP
% 
% Produce inverse trasformation of non-linear warp. 
%
% SYNTAX:
%
% 1) g_Invwarp( WarpVolume, ReferenceVolume )
%__________________________________________________________________________
% INPUTS:
%
% WARPVOLUME
%        (string) 
%        The full path of the warp/shiftmap transform (volume).
%
% REFERENCEVOLUME
%        (string) 
%        The full path of the reference image.
%__________________________________________________________________________
% OUTPUTS:
%
% 
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: invwarp

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

[WarpParentFolder, WarpFileName, WarpSuffix] = fileparts(WarpVolume);
if strcmp(WarpSuffix, '.gz')
    InvwarpFile = [WarpParentFolder filesep WarpFileName(1:end - 4) '_inv.nii.gz'];
elseif strcmp(WarpSuffix, '.nii')
    InvwarpFile = [WarpParentFolder filesep WarpFileName '_inv.nii.gz'];
else
    error('not a NIFTI file');
end

command = cat(2,'invwarp -w ', WarpVolume, ' -r ', ReferenceVolume, ' -o ', InvwarpFile );
disp(command);
system(command);