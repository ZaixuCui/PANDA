function g_NIIcrop( DWI_FileName,B0Avg_FileName,mask_fileName,Cropping_Flag,slice_gap,JobName )
%
%__________________________________________________________________________
% SUMMARY OF G_NIICROP
% 
% Select a cube which just includes the whole brain in the image to replace 
% the orginal image, thus saving memory space.
%
% SYNTAX:
%
% 1) g_NIIcrop( DWI_FileName,B0Avg_FileName,mask_fileName )
% 2) g_NIIcrop( DWI_FileName,B0Avg_FileName,mask_fileName,Cropping_Flag )
% 3) g_NIIcrop( DWI_FileName,B0Avg_FileName,mask_fileName,Cropping_Flag,slice_gap )
% 4) g_NIIcrop( DWI_FileName,B0Avg_FileName,mask_fileName,Cropping_Flag,slice_gap,JobName )
%__________________________________________________________________________
% INPUTS:
%
% TARGET_FILENAME
%        (cell of strings)
%        The input cell, each is the full path of NIfTI data to be cropped. 
%        For example: TARGET_FILENAME{1} = '/data/Handled_Data/001/DWI_01.nii'
%
% B0Avg_FileName
%        (string)
%        The full path of the average b0 image.
%
% MASK_FILENAME
%        (string) 
%        The full path of the mask data produced by 'bet'.
%        For example: '/data/Handled_Data/001/nodif_brain_mask.nii.gz'
%
% CROPPING_FLAG
%        (integer, 0 or 1, default 1)
%        Flag indicates whether to crop image.
%
% SLICE_GAP
%        (single, default 3) 
%        The length from the boundary of the brain to the cube. 
%
% JOBNAME
%        (string) the name of the job which call the command this time.It
%        is determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
% See g_NIIcrop_FileOut.m file         
%__________________________________________________________________________
% COMMENTS:
%
% The data of DTI is large, while the memory of the computer is limited. So
% reducing the capacity of the data is important. With this function, now  
% we can submit more jobs at a time.
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslroi

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

if nargin <= 2
    Cropping_Flag = 1;
end

if nargin <= 3
    slice_gap = 3;
end

% Acquire DWI data from output of dcm2nii_dwi job
% QuantityOfDWI = (length(target_fileName) - 3) / 3;
% for i = 1:QuantityOfDWI
%     DWI_FileName{i} = target_fileName{(i - 1) * 3 + 3};
% end
QuantityOfDWI = length(DWI_FileName);
% dim4 is the quantity of Volumes per sequence
[status,dim4] = system([ 'fslval ', DWI_FileName{1}, ' dim4']);
dim4 = str2num(dim4);
VolumePerSequence = dim4;

% Split the data
for i = 1:QuantityOfDWI
    if strcmp(DWI_FileName{i}(end - 6:end), '.nii.gz')
        [a,b,c] = fileparts(DWI_FileName{i});
        system(['fslsplit ' DWI_FileName{i} ' ' a filesep b(1:end - 4) '_']);
    elseif strcmp(DWI_FileName{i}(end - 3:end), '.nii')
        [a,b,c] = fileparts(DWI_FileName{i});
        system(['fslsplit ' DWI_FileName{i} ' ' a filesep b '_']);
    end
end

% Acquire the name of splited data
QuantityOfVolume = 0;
for i = 1:QuantityOfDWI
    [a,b,c] = fileparts(DWI_FileName{i});
    for j = 0:VolumePerSequence - 1
        QuantityOfVolume = QuantityOfVolume + 1;
        if strcmp(DWI_FileName{i}(end - 6:end), '.nii.gz')
            VolumeName{QuantityOfVolume} = [a filesep b(1:end - 4) '_' num2str(j,'%04.0f') '.nii.gz'];
        elseif strcmp(DWI_FileName{i}(end - 3:end), '.nii')
            VolumeName{QuantityOfVolume} = [a filesep b '_' num2str(j,'%04.0f') '.nii.gz'];
        end
    end
end

for i = 1:QuantityOfVolume
    if strcmp(VolumeName{i}(end - 6:end), '.nii.gz')
        VolumeCropped_fileName{i} = cat(2,VolumeName{i}(1:end - 7), '_crop.nii.gz');
    elseif strcmp(target_fileName{i}(end - 3:end), '.nii')
        VolumeCropped_fileName{i} = cat(2,VolumeName{i}(1:end - 4), '_crop.nii.gz');
    else
        error('not a NIFTI file');  
    end
end

save ( [a filesep 'NIIcrop_output.mat'], 'VolumeCropped_fileName','VolumePerSequence' );

if Cropping_Flag
    VolumeName{end + 1} = B0Avg_FileName;
    [NativeFolder, FileName, ~] = fileparts(B0Avg_FileName);
    VolumeCropped_fileName{end + 1} = [NativeFolder filesep FileName(1:end-4) '_crop.nii.gz'];
    QuantityOfVolume = QuantityOfVolume + 1;
    
    [img, dims] = read_avw(mask_fileName);
    Index = find(img);
    [x,y,z] = ind2sub(dims(1:3)', Index);
    x_min = min(x) - 1 - slice_gap;
    x_max = max(x) - 1 + slice_gap;
    x_size = x_max - x_min + 1;
    y_min = min(y) - 1 - slice_gap;
    y_max = max(y) - 1 + slice_gap;
    y_size = y_max - y_min + 1;
    z_min = min(z) - 1 - slice_gap;
    z_max = max(z) - 1 + slice_gap;
    z_size = z_max - z_min + 1;
    for i = 1:QuantityOfVolume
        crop_cmd = cat(2, 'fslroi ', VolumeName{i}, ' ', VolumeCropped_fileName{i},...
                                ' ', num2str(x_min), ' ', num2str(x_size),...
                                ' ', num2str(y_min), ' ', num2str(y_size),...
                                ' ', num2str(z_min), ' ', num2str(z_size));
        system(crop_cmd);
        %% updated header
        [status,result]=system(cat(2, 'fslorient -getsform ', VolumeName{i}));
        sform=str2num(result);
        updated_sform=sform;
        updated_sform(4)=sform(4)+sform(1)*x_min+sform(2)*y_min+sform(3)*z_min;
        updated_sform(8)=sform(8)+sform(5)*x_min+sform(6)*y_min+sform(7)*z_min;
        updated_sform(12)=sform(12)+sform(9)*x_min+sform(10)*y_min+sform(11)*z_min;
        string=mat2str(updated_sform,2);string(1)=[];string(end)=[];
        [status,result]=system(cat(2, 'fslorient -setsform ', string, ' ', VolumeCropped_fileName{i}));
        %% updated header
        [status,result]=system(cat(2, 'fslorient -getqform ', VolumeName{i}));
        qform=str2num(result);
        updated_qform=qform;
        updated_qform(4)=qform(4)+qform(1)*x_min+qform(2)*y_min+qform(3)*z_min;
        updated_qform(8)=qform(8)+qform(5)*x_min+qform(6)*y_min+qform(7)*z_min;
        updated_qform(12)=qform(12)+qform(9)*x_min+qform(10)*y_min+qform(11)*z_min;
        string=mat2str(updated_qform,2);string(1)=[];string(end)=[];
        [status,result]=system(cat(2, 'fslorient -setqform ', string, ' ', VolumeCropped_fileName{i}));
    end
else
    for i = 1:QuantityOfVolume
        cp_cmd = ['cp ' VolumeName{i} ' ' VolumeCropped_fileName{i}];
        system(cp_cmd);
    end
end

if nargin == 6
    Success = 1;
    for i = 1:QuantityOfVolume
        if ~exist(VolumeCropped_fileName{i}, 'file')
            Success = 0;
        end
    end
    if Success == 1
        cmd = ['touch ' a(1:end - 4) filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
        system(cmd);
    end
end

