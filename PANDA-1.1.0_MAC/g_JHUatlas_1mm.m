
function g_JHUatlas_1mm( Dmetric_fileName, WM_Label_Atlas, WM_Probtract_Atlas, JobName )
%
%__________________________________________________________________________
% SUMMARY OF G_JHUatlas_1mm
% 
% Generate regional dti measures according to JHU atlas 
%
% SYNTAX:
% G_JHUATLAS_1MM( DMETRIC_FILENAME, WM_LABEL_ATLAS, WM_PROBTRACT_ATLAS, JOBNAME )
%__________________________________________________________________________
% INPUTS:
%
% Dmetric_fileName
%        (string) the full path of the NIfTI data
%        For example: '/data/Handled_Data/001/001_FA_to_target_1mm.nii.gz'
%
% JOBNAME
%        (string) the name of the job which call the command this time.It
%        is determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%         
% See g_JUHatlas_1mm_..._FileOut.m file
%__________________________________________________________________________
% USAGES:
%
%        1) g_JHUatlas_1mm( Dmetric_fileName, WM_Label_Atlas, WM_Probtract_Atlas)
%        2) g_JHUatlas_1mm( Dmetric_fileName, WM_Label_Atlas, WM_Probtract_Atlas, JobName )
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslstats

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

disp(cat(2, 'processing ', Dmetric_fileName));
if strcmp(Dmetric_fileName(end - 6:end), '.nii.gz')
    Dmetric_WMlabel_fileName = cat(2,Dmetric_fileName(1:end - 7),'.WMlabel');
    Dmetric_WMtract_fileName = cat(2,Dmetric_fileName(1:end - 7),'.WMtract');
elseif strcmp(Dmetric_fileName(end-3:end), '.nii');
    Dmetric_WMlabel_fileName = cat(2,Dmetric_fileName(1:end - 4),'.WMlabel');
    Dmetric_WMtract_fileName = cat(2,Dmetric_fileName(1:end - 4),'.WMtract');
else
    error('not a NIFTI file')
end
% calculating the WM label
atlas_label_fileName = g_ls([WM_Label_Atlas filesep '*']);
WM_label_Region_Quantity = length(atlas_label_fileName);
fid = fopen(Dmetric_WMlabel_fileName, 'w');
for j = 1:WM_label_Region_Quantity
    cmd1 = cat(2, 'fslstats ', Dmetric_fileName, ' -k ', atlas_label_fileName{j}, ' -M');
    [status, result] = system(cmd1);
    fprintf(fid, result); 
end
fclose(fid);

% calculating the WM tract
atlas_tract_fileName = g_ls([WM_Probtract_Atlas filesep '*']);
WM_tract_Region_Quantity = length(atlas_tract_fileName);
fid = fopen(Dmetric_WMtract_fileName, 'w');
for k = 1:WM_tract_Region_Quantity
    cmd2 = cat(2, 'fslstats ', Dmetric_fileName, ' -k ', atlas_tract_fileName{k}, ' -M');
    [status, result] = system(cmd2);
    fprintf(fid, result); 
end
fclose(fid);

if nargin == 4
    [a,b,c] = fileparts(Dmetric_fileName);
    [SubjectFolder,b,c] = fileparts(a);
    cmd = ['touch ' SubjectFolder filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end





