
function g_EDDYCURRENT( B0_File,files_in,QuantityOfSequence,Prefix )
%
%__________________________________________________________________________
% SUMMARY OF G_EDDYCURRENT
% 
% Correct for eddy current distortions and simple head motion 
%
% SYNTAX:
% g_EDDYCURRENT( B0_File,files_in,QuantityOfSequence,Prefix )
%__________________________________________________________________________
% INPUTS:
%
% B0_FILE
%        (string) 
%        The full path of the b0 file.
%        For example: '/data/Handled_Data/001/data_b0.nii.gz'
%
% FILES_IN
%        (string) 
%        The full path of a .mat file which store two variables.
%        'VolumeCropped_fileName' and 'VolumePerSequence'.
%        VolumePerSequence:
%                 (integer)
%                 the quantity of volume for one scan 
%        VolumeCropped_fileName:
%                 (cell of string)
%                 VoVolumeCropped_fileName{i} is ith volume data
%                 as we know, the quantity of volume is 
%                 QuantityOfSequence*VolumePerSequence
%
% QUANTITYOFSEQUENCE
%        (integer) 
%        The quantity of scans.
%
% PREFIX
%        (string)
%        The prefix of file name.
%__________________________________________________________________________
% OUTPUTS:
%
% See g_EDDYCURRENT_FileOut.m file         
%__________________________________________________________________________
% COMMENTS:
% 
% Eddy currents in the gradient coils induce stretches and shears in the
% diffusion weighted images. These distortions are different for different
% gradient directions. The function correct for these distortions, and for 
% simple head motion, using affine registration to a reference volume.
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: flirt, avscale
% Please report bugs or requests to:
%   Zaixu Cui:            zaixucui@gmail.com
%   Suyu Zhong:           suyu.zhong@gmail.com
%   Gaolang Gong (PI):    gaolang.gong@gmail.com

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

% Register for each volume
for i = 1:length(VolumeCropped_fileName)
    [a,b,c] = fileparts(VolumeCropped_fileName{i});
    matFileName{i} = b(1:end-4);
    VolumeEddycurrent_fileName{i} = [a filesep b(1:end-4) '_eddy.nii.gz'];
    cmd = ['flirt -in ' VolumeCropped_fileName{i} ' -ref ' B0_File ' -nosearch -o ' VolumeEddycurrent_fileName{i} ' -paddingsize 1 -omat ' a filesep matFileName{i} '.mat'];
    system(cmd);
    % Save the ecclog to a cell variable
    cmd = ['tmp = load(''' a filesep matFileName{i} '.mat''' ',' '''-ascii'');'];
    eval(cmd);
    ecclog{i} = tmp;  
end

% Save the ecclog to a .mat file
[a,b,c] = fileparts(B0_File);
save ( [a(1:end - 4) filesep 'native_space' filesep 'ecclog.mat'], 'ecclog');

% Load bvecs File
num = 0;
bvecs_Raw = [];
for i = 1:QuantityOfSequence
    disp(a);
    disp(Prefix);
    disp(i);
    bvecsVectorTemp = load([ a filesep Prefix '_bvecs_' num2str(i,'%02.0f') ], '-ascii'); 
    bvecs_Raw = [bvecs_Raw bvecsVectorTemp];
    for j = 1:VolumePerSequence
        num = num + 1;
        bvecsVector{num}(1) = bvecsVectorTemp(1,j);
        bvecsVector{num}(2) = bvecsVectorTemp(2,j);
        bvecsVector{num}(3) = bvecsVectorTemp(3,j);
    end
end

% Save raw bvector
save ( [a(1:end - 4) filesep 'native_space' filesep 'bvecs_Raw.mat'], 'bvecs_Raw');

% Rotbvecs
for i = 1:length(VolumeCropped_fileName)
    [bvecs_new, AffineMatrix] = g_rotbvecs([a filesep matFileName{i} '.mat'], bvecsVector{i});
    bvecsVectorNew(1,i) = bvecs_new(1);
    bvecsVectorNew(2,i) = bvecs_new(2);
    bvecsVectorNew(3,i) = bvecs_new(3);
end

save ( [a filesep 'EDDYCURRENT_output.mat'], 'VolumeEddycurrent_fileName','VolumePerSequence','bvecsVectorNew');



% function g_rotbvecs
function [bvec_new, AffineMatrix]=g_rotbvecs(matFileName, bvec)

%__________________________________________________________________________
% SUMMARY OF g_rotbvecs2
% 
% This is to rotate the raw bvec after eddy-current FLIRT registration
%
% SYNTAX:
% [bvec_new, AffineMatrix]=g_rotbvecs2(matFileName, bvec)
%__________________________________________________________________________
% INPUTS:
%
% matFileName
%        (string) the full path of the resultant .mat file for a specific
%        DWI volume after flirting during eddy-current correction
%        For example: '/data/Handled_Data/001/volume0001.mat'
%
% bvec
%        (variable) the 3*1 vector corresponding to the diffusion direction
%        for a specific DWI volume
%        For example: [ 1
%                       0
%                       0 ]
%__________________________________________________________________________
% OUTPUTS:
%
% bvec_new: the rotated/corrected bvec with the rotation component of the
%           affine matrix
% AffineMatrix: the affine matrix from the .mat file
%__________________________________________________________________________
% USAGES:
%
%        1) [bvec_new, AffineMatrix]=g_rotbvecs2(matFileName, bvec)
%__________________________________________________________________________


AffineMatrix = load(matFileName, '-ascii');
[flag, results] = system(cat(2, '$FSLDIR/bin/avscale ',matFileName,' | head -5 | tail -4 '));
M = str2num(results);
RotM = M(1:3,1:3);
if size(bvec) == [1,3]
    bvec = bvec';
end
if size(bvec) ~= [3,1]
    error('bvec is incorrect');
end
bvec_new = RotM * bvec;

           
