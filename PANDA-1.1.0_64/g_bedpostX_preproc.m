function g_bedpostX_preproc( NativeFolder )
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX_PREPROC
% 
% Some pretreatment before bedpostx
%
% SYNTAX:
% G_AVERAGE( NATIVEFOLDER )
%__________________________________________________________________________
% INPUTS:
%
% NATIVEFOLDER
%        (string)
%        the path of the foler which contains bvals, bvecs, data,
%        nodif_brain_mask
%
%__________________________________________________________________________
% OUTPUTS:
%     
% See g_bedpostX_preproc_FileOut.m file
%__________________________________________________________________________
% USAGES:
%
%        1) g_bedpostX_preproc( NativeFolder )
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
% Neuroscience and Learning, Beijing Normal University, 2011.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: bedpostx, pretreatment

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

BedpostXFolder = [NativeFolder '.bedpostX'];
if ~exist(BedpostXFolder, 'dir')
    mkdir(BedpostXFolder);
end
copyfile([NativeFolder filesep 'bvals'], BedpostXFolder);
copyfile([NativeFolder filesep 'bvecs'], BedpostXFolder);
copyfile([NativeFolder filesep 'nodif_brain_mask.nii.gz'], BedpostXFolder);
DiffSlecesPath = [BedpostXFolder filesep 'diff_slices'];
if ~exist(DiffSlecesPath, 'dir')
    rmdir(DiffSlecesPath, 's');
end
mkdir(DiffSlecesPath);
system(['fslslice ' NativeFolder filesep 'data.nii.gz ' DiffSlecesPath filesep 'data && touch ' DiffSlecesPath filesep 'DataSlice.done']);
system(['fslslice ' NativeFolder filesep 'nodif_brain_mask.nii.gz ' DiffSlecesPath filesep 'nodif_brain_mask && touch ' DiffSlecesPath filesep 'MaskSlice.done']);
