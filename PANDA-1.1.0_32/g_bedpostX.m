function g_bedpostX( NativeFolder, BedpostXJobNum, Fibers, Weight, Burnin )
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX
% 
% do bedpostx for several slices
%
% SYNTAX:
% G_BEDPOSTX( NATIVEFOLDER, BEDPOSTXJOBNUM, FIBERS, WEIGHT, BURNIN)
%__________________________________________________________________________
% INPUTS:
%
% NATIVEFOLDER
%        (string) 
%        the path of the foler which contains bvals, bvecs, data,
%        nodif_brain_mask
%
% BEDPOSTXJOBNUM
%        (integer) the serial number of bedpostx job
%
% FIBERS
%        (integer) number of fibers per voxel, default 2
%
% WEIGHT
%        (integer) ARD weight, more weight means less secondary fibers per voxel,
%        default 1
%
% BURNIN
%        (integer) burnin period, default 1000
%
%__________________________________________________________________________
% OUTPUTS:
%     
% See g_bedpostX_FileOut.m file
%__________________________________________________________________________
% USAGES:
%
%        1) g_bedpostX( NativeFolder, BedpostXJobNum, Fibers, Weight, Burnin )
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
% keywords: bedpostx, xfibres

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

njumps = 1250;
sampleevery = 25;
model = 1;

BedpostxFolder = [NativeFolder '.bedpostX'];
BvalsPath = [BedpostxFolder filesep 'bvals'];
BvecsPath = [BedpostxFolder filesep 'bvecs'];

[x, SliceQuantityString] = system(['fslval ' NativeFolder filesep 'data.nii.gz dim3']);
SliceQuantity = str2num(SliceQuantityString);

SlicesPerJob = fix(SliceQuantity / 10);
StartSliceNum = SlicesPerJob * (BedpostXJobNum - 1);
if BedpostXJobNum == 10
    Remainer = mod(SliceQuantity, 10);
    SlicesPerJob = SlicesPerJob + Remainer;
end

for i = 1:SlicesPerJob
    SliceCurrentNum =  StartSliceNum + i - 1;
    SliceCurrentNumString = num2str(SliceCurrentNum, '%04d');
    DataSlicePath{i} = [BedpostxFolder filesep 'diff_slices' filesep 'data_slice_' SliceCurrentNumString];
    MaskSlicePath = [BedpostxFolder filesep 'diff_slices' filesep 'nodif_brain_mask_slice_' SliceCurrentNumString];
    if exist(DataSlicePath{i}, 'dir')
        disp(['rm -rf ' DataSlicePath{i}]);
        system(['rm -rf ' DataSlicePath{i}]);
    end
    cmd = ['xfibres ' '--data=' DataSlicePath{i} ' --mask='  MaskSlicePath ' -b ' ...
           BvalsPath ' -r ' BvecsPath ' --forcedir --logdir=' DataSlicePath{i} ...
           ' --fudge=' num2str(Weight) ' --nj=' num2str(njumps) ' --bi=' num2str(Burnin) ...
           ' --model=' num2str(model) ' --nonlinear --se=' num2str(sampleevery) ...
           ' --upe=24 --nfibres=' num2str(Fibers) ' && touch ' DataSlicePath{i} filesep 'xfibres.done'];
    disp(cmd);
    system(cmd);
end

BedpostXDone = 1;
for i = 1:SlicesPerJob
    if ~exist([DataSlicePath{i} filesep 'xfibres.done'], 'file')
        BedpostXDone = 0;
        break;
    end
end

if BedpostXDone
    system(['touch ' BedpostxFolder filesep 'diff_slices' filesep 'BedpostX' num2str(BedpostXJobNum) '.done']);
end


