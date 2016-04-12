
function g_Split_ROI(AtlasImage, ResultantFolder, JobName)
%
%__________________________________________________________________________
% SUMMARY OF G_SPLIT_ROI
% 
% Split altas into several files, each with one ROI. 
%
% SYNTAX:
%
% 1) g_Split_ROI( AtlasImage, ResultantFolder )
%__________________________________________________________________________
% INPUTS:
%
% ATLASIMAGE
%        (string) 
%        The full path of the atlas in the standard space.
%
% RESULTANTFOLDER
%        (string) 
%        The full path of the resultant folder.
%__________________________________________________________________________
% OUTPUTS:
%    
% A folder containing many files, each with one ROI.
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2013.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslmaths

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

% Calculate max value in the image
if ~exist(ResultantFolder, 'dir')
    mkdir(ResultantFolder);
end
mkdir([ResultantFolder filesep 'tmp']);
AtlasTmp = [ResultantFolder filesep 'tmp' filesep 'AtlasTmp'];
system(['fslchfiletype NIFTI_PAIR ' AtlasImage ' ' AtlasTmp]);
fid = fopen(cat(2,AtlasTmp,'.hdr'),'rb');
fseek(fid,40,'bof');
dim=fread(fid,8,'short');
fseek(fid,14,'cof');
datatype=fread(fid,1,'short');
fclose(fid);
prec   = {'uint8','int16','int32','float32','float64','int8','uint16','uint32'};
types  = [    2      4      8   16   64   256    512    768];

sel = find(types == datatype);

fid = fopen(cat(2,AtlasTmp,'.img'),'rb');
Atlas = fread(fid,prec{sel});
fclose(fid);
delete(cat(2,AtlasTmp,'.img'));
delete(cat(2,AtlasTmp,'.hdr'));
rmdir([ResultantFolder filesep 'tmp']);

maxValue = max(Atlas);

% Split atlas to ROIs
if strcmp(AtlasImage(end - 3:end), '.nii')
    [x AtlasName z] = fileparts(AtlasImage);
elseif strcmp(AtlasImage(end - 6:end), '.nii.gz')
    [x AtlasName z] = fileparts(AtlasImage);
    [x AtlasName z] = fileparts(AtlasName);
else
    error('Atlas image should .nii or .nii.gz');
end

DigitsQuantity = 0;
Tmp = maxValue;
while Tmp >= 1
    DigitsQuantity = DigitsQuantity + 1;
    Tmp = Tmp / 10;
end

for i = 1:maxValue
    IDString = num2str(i, ['''%0' num2str(DigitsQuantity) 'd''']);
    IDString = IDString(2:end - 1);
    ResultantFilePath{i} = [ResultantFolder filesep AtlasName '_' IDString '.nii.gz'];
    cmd = ['fslmaths ' AtlasImage ' -thr ' num2str(i) ' -uthr ' num2str(i) ' -bin ' ResultantFilePath{i}];
    system(cmd);
end

if nargin >= 3
    for i = 1:maxValue
        if ~exist(ResultantFilePath{i}, 'file')
            break;
        end
    end
    if i >= maxValue & exist(ResultantFilePath{i}, 'file')
        [Nii_Output_Path y z] = fileparts(ResultantFolder);
        system(['touch ' Nii_Output_Path filesep filesep JobName '.done']);
    end
end
