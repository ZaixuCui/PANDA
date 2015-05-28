function g_T1Dcm2nii( DataRaw_path, SubjectID, DataNii_folder, Prefix )
%
%__________________________________________________________________________
% SUMMARY OF G_BETT1
% 
% Convert DICOM files of T1 to NIfTI
%
% SYNTAX:
%
% 1) g_T1Dcm2nii( DataRaw_path, SubjectID, DataNii_folder, Prefix )
%__________________________________________________________________________
% INPUTS:
%
% DATARAW_PATH
%        (string) 
%        The full path of the raw DICOM/NIfTI data.
%        There are two possibilitis under the path:
%        1) DICOM files
%        2) NIfTI file (must be only one file)
%
% SUBJECTID
%        (integer) 
%        The id user sets for subject.
%
% DATANII_FOLDER
%        (string) 
%        The folder to store the resultant files.
%
% PREFIX
%        (string) 
%        The prefix of the names of resultant files.
%__________________________________________________________________________
% OUTPUTS:
%
% The NIfTI image of T1.
%__________________________________________________________________________
% COMMENTS:
%
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: dcm2nii

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

global PANDAPath;
[PANDAPath y z] = fileparts(which('PANDA.m'));

if ~isempty(Prefix)
    PrefixData = cat(2, Prefix, '_', num2str(SubjectID,'%05d'));
else
    PrefixData = num2str(SubjectID,'%05d');
end

if strcmp(DataRaw_path(end), filesep)
    DataRaw_cell = g_ls(cat(2, DataRaw_path,'*'));
else
    DataRaw_cell = g_ls(cat(2, DataRaw_path, filesep, '*'));
end
if ~exist(DataNii_folder, 'dir')
    mkdir(DataNii_folder);
end

system(['chmod +x ' PANDAPath filesep 'dcm2nii' filesep 'dcm2nii']);
convert = cat(2, PANDAPath, filesep, 'dcm2nii', filesep, 'dcm2nii -a n -m n -d n -e n -f n -i n -p n -r n -x n -g n -o ', DataNii_folder, ' ', DataRaw_cell{1});
disp(convert);
system(convert);

DataNii = g_ls([DataNii_folder filesep '*.nii']);
cmd = ['fslchfiletype NIFTI_GZ ' DataNii{1} ' ' DataNii_folder filesep PrefixData '_t1 && rm ' DataNii{1}];
system(cmd);

