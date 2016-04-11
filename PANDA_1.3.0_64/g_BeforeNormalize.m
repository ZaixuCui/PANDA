 
function g_BeforeNormalize( raw_file,JobName )
%
%__________________________________________________________________________
% SUMMARY OF G_BEFORENORMALIZE
% 
% Some pre-process before Normalize FA to template
%
% SYNTAX:
%
% 1) g_BeforeNormalize( raw_file )
% 2) g_BeforeNormalize( raw_file, JobName )
%__________________________________________________________________________
% INPUTS:
%
% RAW_FILE
%        (string) 
%        The full path of the data to be handled.
%        For example: '/data/Handled_Data/001/001_FA.nii.gz'
%
% JOBNAME
%        (string) the name of the job which call the command this time.It
%        is determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%         
% See g_BeforeNormalize_..._FileOut.m file.
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: pre-processing, fslmaths

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
    
if strcmp(raw_file(end-6:end), '.nii.gz')
    raw_file_4tbss = cat(2,raw_file(1:end-7), '_4normalize');
    raw_file_4tbss_mask = cat(2,raw_file(1:end-7), '_4normalize_mask');
elseif strcmp(raw_file(end-3:end), '.nii');
    raw_file_4tbss = cat(2,raw_file(1:end-4),'_4normalize');
    raw_file_4tbss_mask = cat(2,raw_file(1:end-4),'_4normalize_mask');
else
    error('not a NIFTI file');
end
%preprocessing FA
[status,dim1] = system(cat(2, 'fslval ', raw_file, ' dim1'));
dim1 = str2double(dim1);
[status,dim2] = system(cat(2, 'fslval ', raw_file, ' dim2'));
dim2 = str2double(dim2);
[status,dim3] = system(cat(2, 'fslval ', raw_file, ' dim3'));
dim3 = str2double(dim3);

cmd1=['!fslmaths ' raw_file ' -min 1 -ero -roi 1 ' num2str(dim1-2) ' 1 ' num2str(dim2-2) ...
                    ' 1 ' num2str(dim3-2) ' 0 1 ' raw_file_4tbss];
eval(cmd1);        
%creat mask for fnirt
cmd2=cat(2, 'fslmaths ', raw_file_4tbss,' -bin ', raw_file_4tbss_mask);
system(cmd2);

if nargin == 2
    [a,b,c] = fileparts(raw_file);
    [a,b,c] = fileparts(a);
    cmd = ['touch ' a filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end

