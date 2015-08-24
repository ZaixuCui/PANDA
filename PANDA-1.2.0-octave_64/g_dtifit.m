function g_dtifit( fdt_dir,Prefix )
%
%__________________________________________________________________________
% SUMMARY OF G_DTIFIT
% 
% Calculate diffusion tensor model for each voxel.
%
% SYNTAX:
%
% 1) g_dtifit( fdt_dir,Prefix )
%__________________________________________________________________________
% INPUTS:
%
% FDT_DIR
%        (string) 
%        Full path of a folder containing four files as listed, if do 
%        deterministic fiber tracking, deterministic network construction 
%        and bedpostx & probabilistic network construction.
%        1) A 4D image named data.nii.gz containing diffusion-weighted 
%           volumes and volumes without diffusion weighting.
%        2) A 3D binary brain mask volume named nodif_brain_mask.nii.gz.
%        3) A text file named bvecs containing gradient directions for 
%           diffusion weighted volumes.
%        4) A text file named bvals containing b-values applied for each 
%           volume acquisition.
%
% PREFIX
%        (string) 
%        The prefix of the name for the output file. 
%__________________________________________________________________________
% OUTPUTS:
%
% 12 files will be produced.
%    <Prefix>_V1 - 1st eigenvector
%    <Prefix>_V2 - 2nd eigenvector
%    <Prefix>_V3 - 3rd eigenvector
%    <Prefix>_L1 - 1st eigenvalue
%    <Prefix>_L2 - 2nd eigenvalue
%    <Prefix>_L3 - 3rd eigenvalue
%    <Prefix>_L23m - eigenvalue on the vertical direction
%    <Prefix>_MD - mean diffusivity
%    <Prefix>_FA - fractional anisotropy
%    <Prefix>_MO - mode of the anisotropy
%    <Prefix>_S0 - raw T2 signal with no diffusion weighting
% See g_dtifit_FileOut.m file
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: dtifit
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
  
data_file = cat(2, fdt_dir, filesep, 'native_space', filesep, 'data');
out_file = cat(2, fdt_dir, filesep, 'native_space', filesep, Prefix);
mask_file = cat(2,fdt_dir, filesep, 'native_space', filesep, 'nodif_brain_mask');
bvec_file = cat(2,fdt_dir, filesep, 'native_space', filesep, 'bvecs');
bval_file = cat(2,fdt_dir, filesep, 'native_space', filesep, 'bvals');
cmd = cat(2, 'dtifit -k ', data_file,  ' -m ',mask_file, ' -r ',bvec_file, ' -b ', bval_file, ' -o ',out_file);
disp(cmd);
system(cmd);
pause(2);
FASlicerdir = [fdt_dir filesep 'quality_control' filesep 'FA' filesep];
if ~exist(FASlicerdir, 'dir')
    mkdir(FASlicerdir);
end
system(cat(2, 'slicer ', out_file, '_FA.nii.gz -a ', FASlicerdir, Prefix, '_FA_QC.png'));
L2fileName = cat(2,out_file, '_L2.nii.gz');
L3fileName = cat(2,out_file, '_L3.nii.gz');
L23mfileName = cat(2,out_file, '_L23m.nii.gz');
cmd = cat(2, 'fslmaths ', L2fileName, ' -add ', L3fileName, ' -div 2 ', L23mfileName);
system(cmd);

