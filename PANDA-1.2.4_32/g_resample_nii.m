function g_resample_nii(nii_fileName, target_voxelsize, resampled_nii_fileName)
%
%__________________________________________________________________________
% SUMMARY OF G_RESAMPLE_NII
% 
% Resample the raw NIfTI with a certain resolution.
%
% SYNTAX:
%
% 1) g_resample_nii(nii_fileName, target_voxelsize, resampled_nii_fileName)
%__________________________________________________________________________
% INPUTS:
%
% NII_FILENAME
%        (string) 
%        The full path of the NIfTI data to be resampled.
%
% TARGET_VOXELSIZE
%        (array of integers) 
%        The final voxel size of the resampled data.
%        For example: [2 2 2]
%
% RESAMPLED_NII_FILENAME
%        (string) 
%        The full path of the resultant file.
%__________________________________________________________________________
% OUTPUTS:
%
% The resampled data with the voxel size user inputs.            
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: resample, fslcreatehd, flirt

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
disp(nii_fileName);
disp(target_voxelsize);
disp(resampled_nii_fileName);
[path, name, ext] = fileparts(nii_fileName);
if strcmp(ext, '.gz')
    tmp_fileName = [path name(1:end - 4) '_tmp.nii.gz'];
elseif strcmp(ext, '.nii')
    tmp_fileName = [path name '_tmp.nii.gz']
end
[FOVdim1, FOVdim2, FOVdim3, dim4, pixdim4, datatype] = getFOV(nii_fileName);
target_dim1 = round(FOVdim1 / target_voxelsize(1));
target_dim2 = round(FOVdim2 / target_voxelsize(2));
target_dim3 = round(FOVdim3 / target_voxelsize(3));
cmd1 = cat(2, 'fslcreatehd ', num2str(target_dim1), ' ', num2str(target_dim2), ' ', num2str(target_dim3), ' ', num2str(dim4), ...
               ' ', num2str(target_voxelsize(1)), ' ', num2str(target_voxelsize(2)), ' ', num2str(target_voxelsize(3)), ' ', num2str(pixdim4),... 
               ' 0 0 0 ', num2str(datatype), ' ', tmp_fileName);
disp(cmd1);
system(cmd1);

cmd2 = cat(2, 'flirt -in ', nii_fileName, ' -applyxfm -init $FSLDIR/etc/flirtsch/ident.mat -out ',...
             resampled_nii_fileName, ' -paddingsize 0.0 -interp trilinear -ref ', tmp_fileName);
disp(cmd2);
system(cmd2);

delete(tmp_fileName);
end



%%%%%%%%%%%%%%%% calculate the volume size of image %%%%%%%%%%%%%%%%%%%%%%%
function [FOVdim1, FOVdim2, FOVdim3, dim4, pixdim4, datatype]=getFOV(nii_fileName)

[status,message] = system(cat(2, 'fslinfo ', nii_fileName));
message = strtrim(message);
label = isspace(message);
label = 1 - label;
diff = label(1:end - 1) - label(2:end);
start_index = find(diff == -1); 
start_index = [1, start_index + 1];
end_index = find(diff == 1); 
end_index = [end_index, length(label)];
for i = 1:length(start_index)
    cell_item{i, 1} = message(start_index(i):end_index(i));
end

tmp = strcmpi('datatype', cell_item);
datatype = cell_item(find(tmp==1)+1);
datatype = str2num(datatype{1});

tmp = strcmpi('dim1', cell_item);
dim1 = cell_item(find(tmp == 1) + 1);
dim1 = str2num(dim1{1});

tmp = strcmpi('dim2', cell_item);
dim2 = cell_item(find(tmp == 1) + 1);
dim2 = str2num(dim2{1});

tmp = strcmpi('dim3', cell_item);
dim3 = cell_item(find(tmp == 1) + 1);
dim3 = str2num(dim3{1});

tmp = strcmpi('dim4', cell_item);
dim4 = cell_item(find(tmp == 1) + 1);
dim4 = str2num(dim4{1});

tmp = strcmpi('pixdim1', cell_item);
pixdim1 = cell_item(find(tmp == 1) + 1);
pixdim1 = str2num(pixdim1{1});

tmp = strcmpi('pixdim2', cell_item);
pixdim2 = cell_item(find(tmp == 1) + 1);
pixdim2 = str2num(pixdim2{1});

tmp = strcmpi('pixdim3', cell_item);
pixdim3 = cell_item(find(tmp == 1) + 1);
pixdim3 = str2num(pixdim3{1});

tmp = strcmpi('pixdim4', cell_item);
pixdim4 = cell_item(find(tmp == 1) + 1);
pixdim4 = str2num(pixdim4{1});

FOVdim1 = pixdim1 * dim1;
FOVdim2 = pixdim2 * dim2;
FOVdim3 = pixdim3 * dim3;

end

