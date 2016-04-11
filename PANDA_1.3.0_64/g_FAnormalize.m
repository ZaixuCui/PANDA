function g_FAnormalize( FA_4tbss_file,target,JobName,ResultantFolder )
%
%__________________________________________________________________________
% SUMMARY OF G_FANORMALIZE
% 
% Normalize FA to a template
%
% SYNTAX:
%
% 1) g_FAnormalize( FA_4tbss_file )
% 2) g_FAnormalize( FA_4tbss_file,target )
%__________________________________________________________________________
% INPUTS:
%
% FA_4TBSS_FILE
%        (string) 
%        The full path of the FA data to be normalized.
%        For example: '/data/Handled_Data/001/001_FA_4normalize.nii.gz'
%
% TARGET
%        (string, default FMRIB58_FA standard space image) 
%        Standard template for registering.
%
% JOBNAME
%        (string) 
%        The name of the job which call the command this time.It is 
%        determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
% The normalized data named ..._to_target.nii.gz.
% See g_FAnormalize_FileOut.m file       
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fsl_reg, fnirt

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

if nargin < 2
    target = '$FSLDIR/data/standard/FMRIB58_FA_1mm.nii.gz';
end

[ParentFolder,FileName,Suffix] = fileparts(FA_4tbss_file);
if nargin <= 3
    % 'FA_4tbss_file' file is under 'native' folder  
    [SubjectFolder,~,~] = fileparts(ParentFolder);
    Transformation_Folder = [SubjectFolder filesep 'transformation'];
else
    Transformation_Folder = [ResultantFolder filesep 'transformation'];
end
if ~exist(Transformation_Folder,'dir')
    mkdir(Transformation_Folder);
end
if strcmp(FA_4tbss_file(end-2:end), '.gz')
    FA_fileName_4tbss_to_target = cat(2, Transformation_Folder, filesep, FileName(1:end-4), '_to_target');
elseif strcmp(FA_4tbss_file(end-3:end), '.nii');
    FA_fileName_4tbss_to_target = cat(2, Transformation_Folder, filesep, FileName, '_to_target');
else
    error('not a NIFTI file');
end

% cp FA_4tbss_file to 'transformation' folder, so the log file will be in
% 'transformation' folder

New_FA = [ Transformation_Folder filesep FileName Suffix ];
cmd = [ 'cp ' FA_4tbss_file ' ' Transformation_Folder ' && fsl_reg '  New_FA ' ' ...
        target ' '  FA_fileName_4tbss_to_target ' -e -FA'];

disp(cmd);
system(cmd);

% system(['rm ' FA_4tbss_file]);

if nargin == 3
    cmd = ['touch ' SubjectFolder filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end