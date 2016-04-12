function g_T1Cropped( T1FilePath, T1CroppingGap )
%
%__________________________________________________________________________
% SUMMARY OF G_T1CROPPED
% 
% Select a cube which just includes the whole brain in the image to replace 
% the orginal image, thus saving memory space.
%
% SYNTAX:
%
% 1) g_T1Cropped( T1FilePath, T1CroppingGap )
%__________________________________________________________________________
% INPUTS:
%
% T1FILEPATH
%        (string) 
%        The full path of the T1 NIfTI image to be cropped.
%
% T1CROPPINGGAP
%        (single) 
%        The length from the boundary of the brain to the cube we select.
%        default: 3
%__________________________________________________________________________
% OUTPUTS:
%
% The cropped image.        
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslroi
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

if nargin <= 1
    T1CroppingGap = 3;
end

% Convert 'mm' to 'voxel size'
[status,message] = system(cat(2, 'fslinfo ', T1FilePath));
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

tmp = strcmpi('pixdim1', cell_item);
pixdim1 = cell_item(find(tmp == 1) + 1);
pixdim1 = str2num(pixdim1{1});

tmp = strcmpi('pixdim2', cell_item);
pixdim2 = cell_item(find(tmp == 1) + 1);
pixdim2 = str2num(pixdim2{1});

tmp = strcmpi('pixdim3', cell_item);
pixdim3 = cell_item(find(tmp == 1) + 1);
pixdim3 = str2num(pixdim3{1});

NewCroppingGapDim1 = T1CroppingGap / pixdim1  
NewCroppingGapDim2 = T1CroppingGap / pixdim2 
NewCroppingGapDim3 = T1CroppingGap / pixdim3 

% Crop the data
[T1ParentFolder, T1FileName, T1FileSuffix] = fileparts(T1FilePath);
mask_fileName = [T1ParentFolder filesep 'mask.nii.gz'];
system(['fslmaths ' T1FilePath ' -bin ' mask_fileName]);

[img, dims] = read_avw(mask_fileName);
Index = find(img);
[x,y,z] = ind2sub(dims(1:3)', Index);
x_min = min(x) - 1 - NewCroppingGapDim1;
x_max = max(x) - 1 + NewCroppingGapDim1;
x_size = x_max - x_min + 1;
y_min = min(y) - 1 - NewCroppingGapDim2;
y_max = max(y) - 1 + NewCroppingGapDim2;
y_size = y_max - y_min + 1;
z_min = min(z) - 1 - NewCroppingGapDim3;
z_max = max(z) - 1 + NewCroppingGapDim3;
z_size = z_max - z_min + 1;

if strcmp(T1FileSuffix, '.gz')
    CroppedT1_fileName = [T1ParentFolder filesep T1FileName(1:end - 4) '_crop.nii.gz'];
elseif strcmp(T1FileSuffix, '.nii')
    CroppedT1_fileName = [T1ParentFolder filesep T1FileName '_crop.nii.gz'];
end
crop_cmd = cat(2, 'fslroi ', T1FilePath, ' ', CroppedT1_fileName,...
    ' ', num2str(x_min), ' ', num2str(x_size),...
    ' ', num2str(y_min), ' ', num2str(y_size),...
    ' ', num2str(z_min), ' ', num2str(z_size));
disp(crop_cmd);
system(crop_cmd);

system(['rm ' mask_fileName]);
