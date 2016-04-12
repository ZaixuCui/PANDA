
function g_extractB0(DWI_FileName,Bval_FileName,JobName)
%
%__________________________________________________________________________
% SUMMARY OF G_EXTRACTB0
% 
% Extract a volume on a gradient direction from an 4D image.
% Default: extract b0 volume from an 4D image.
%
% SYNTAX:
%
% 2) g_extractB0( DWI_FileName,Bval_FileName )
% 3) g_extractB0( DWI_FileName,Bval_FileName,JobName)
%__________________________________________________________________________
% INPUTS:
%
% DWI_FILENAME
%        (cell of strings) 
%        Each of the cell is the full path of the NIfTI data.
%        For example: '/data/Handled_Data/001/DWI.nii'
%
% BVAL_FILENAME
%        (cell of strings)
%        Each of the cell is the full path of the bvals file.
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

Quantity_Of_Sequences = length(DWI_FileName);
[ParentFolder, ~, ~] = fileparts(DWI_FileName{1});
B0_Quantity = 1;
saved_b0_FileName = [ParentFolder filesep 'data_b0.nii.gz'];
cmd = ['fslroi ' DWI_FileName{1} ' ' saved_b0_FileName ' 0 1'];
disp(cmd);
system(cmd);

B0_Template = [ParentFolder filesep 'data_b0_template.nii.gz'];
cmd = ['cp ' saved_b0_FileName ' ' B0_Template];
disp(cmd);
system(cmd);

for i = 2:Quantity_Of_Sequences
    B0_Quantity = B0_Quantity + 1;
    B0_TmpImg = [ParentFolder filesep 'data_b0_tmp_' num2str(i) '.nii.gz'];
    cmd = ['fslroi ' DWI_FileName{i} ' ' B0_TmpImg ' 0 1'];
    disp(cmd);
    system(cmd);
    
    B0_TmpImg_Flirt = [ParentFolder filesep 'data_b0_tmp_flirt_' num2str(i) '.nii.gz'];
    cmd = ['flirt -in ' B0_TmpImg ' -ref ' B0_Template ' -nosearch -o ' B0_TmpImg_Flirt ' -paddingsize 1'];
    disp(cmd);
    system(cmd);
    
    cmd = ['fslmaths ' saved_b0_FileName ' -add ' B0_TmpImg_Flirt ' ' saved_b0_FileName];
    disp(cmd);
    system(cmd);
end


for i = 1:Quantity_Of_Sequences
    Bval = load(Bval_FileName{i});
    B0_Index = find(~Bval);
    for j = 2:length(B0_Index)
        B0_Quantity = B0_Quantity + 1;
        B0_TmpImg = [ParentFolder filesep 'data_b0_tmp_' num2str(i) '_' num2str(j) '.nii.gz'];
        cmd = ['fslroi ' DWI_FileName{i} ' ' B0_TmpImg ' ' num2str(B0_Index(j) - 1) ' 1'];
        disp(cmd);
        system(cmd);
        
        B0_TmpImg_Flirt = [ParentFolder filesep 'data_b0_tmp_flirt_' num2str(i) '_' num2str(j) '.nii.gz'];
        cmd = ['flirt -in ' B0_TmpImg ' -ref ' B0_Template ' -nosearch -o ' B0_TmpImg_Flirt ' -paddingsize 1'];
        disp(cmd);
        system(cmd);
        
        cmd = ['fslmaths ' saved_b0_FileName ' -add ' B0_TmpImg_Flirt ' ' saved_b0_FileName];
        disp(cmd)
        system(cmd);
    end
end

cmd = ['fslmaths ' saved_b0_FileName ' -div ' num2str(B0_Quantity) ' ' saved_b0_FileName];
disp(cmd);
system(cmd);

pause(4);
cmd = ['rm -rf ' ParentFolder filesep 'data_b0_tmp_*'];
disp(cmd);
system(cmd);
delete(B0_Template);

% Copy average b0 to native space folder
[SubjectFolder, ~, ~] = fileparts(ParentFolder);
system(['cp ' saved_b0_FileName ' ' SubjectFolder filesep 'native_space' filesep 'data_b0_average.nii.gz']);

disp(cat(2, 'extracting b0 volume is done!'));
if nargin == 3
    cmd = ['touch ' ParentFolder filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end
